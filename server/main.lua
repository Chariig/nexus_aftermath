NA.Server = {}
NA.Server.Staff = NA.Server.Staff or {}

AddEventHandler('onServerResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    NA.Debug('Nexus: Aftermath v2.0.0 starting...')
    NA.Debug('Max Players:', NexusAftermath.Config.maxPlayers)
    NA.Debug('World Tier:', NexusAftermath.Config.worldTier)
    NA.Debug('Infection Rate:', NexusAftermath.Config.infectionRate)

    local success, result = pcall(exports.oxmysql.query, exports.oxmysql, 'SELECT 1')
    if success then
        NA.Debug('Database connected successfully')
    else
        NA.Debug('WARNING: Database connection failed - ' .. tostring(result))
    end

    NA.Server.InitTables()

    SetGameType('Nexus: Aftermath')
    SetMapName('Apocalyptic San Andreas')

    NA.Server.WorldTier = 'safe'
    NA.Server.WorldScore = 100
    NA.Server.ActiveEvents = {}
    NA.Server.ScavengerPools = {}
    NA.Server.Buildings = {}
    NA.Server.EchoRegistry = {}
    NA.Server.TetherNetwork = {}
    NA.Server.RadioFrequencies = {}
    NA.Server.Factions = {}
    NA.Server.InfectionIndex = {}

    NA.Server.SetupTimers()
    NA.Server.RegisterCommands()

    NA.Debug('Nexus: Aftermath started successfully')
end)

function NA.Server.InitTables()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS na_players (
            citizenId VARCHAR(50) PRIMARY KEY,
            license VARCHAR(100) UNIQUE,
            name VARCHAR(100),
            firstname VARCHAR(50),
            lastname VARCHAR(50),
            gender VARCHAR(10),
            dateofbirth VARCHAR(20),
            health INT DEFAULT 200,
            armor INT DEFAULT 0,
            hunger INT DEFAULT 100,
            thirst INT DEFAULT 100,
            infection_strain VARCHAR(50) DEFAULT NULL,
            infection_level INT DEFAULT 0,
            infection_mutations TEXT DEFAULT '[]',
            stats TEXT DEFAULT '{}',
            inventory TEXT DEFAULT '[]',
            position TEXT DEFAULT '{}',
            skills TEXT DEFAULT '{}',
            reputation TEXT DEFAULT '{}',
            playtime INT DEFAULT 0,
            last_played TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]])

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS na_buildings (
            id INT AUTO_INCREMENT PRIMARY KEY,
            owner_citizenId VARCHAR(50),
            structure_type VARCHAR(50),
            pos_x FLOAT, pos_y FLOAT, pos_z FLOAT,
            rot_x FLOAT, rot_y FLOAT, rot_z FLOAT,
            health INT DEFAULT 100,
            max_health INT DEFAULT 100,
            integrity INT DEFAULT 100,
            data TEXT DEFAULT '{}',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_owner (owner_citizenId)
        )
    ]])

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS na_echoes (
            id INT AUTO_INCREMENT PRIMARY KEY,
            creator_citizenId VARCHAR(50),
            pos_x FLOAT, pos_y FLOAT, pos_z FLOAT,
            event_type VARCHAR(50),
            data TEXT,
            recording MEDIUMTEXT,
            decay_at BIGINT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_pos (pos_x, pos_y, pos_z),
            INDEX idx_decay (decay_at)
        )
    ]])

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS na_factions (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100) UNIQUE,
            tag VARCHAR(10),
            owner_citizenId VARCHAR(50),
            members TEXT DEFAULT '[]',
            reputation TEXT DEFAULT '{}',
            territory TEXT DEFAULT '{}',
            color VARCHAR(7) DEFAULT '#FFFFFF',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_owner (owner_citizenId)
        )
    ]])

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS na_world_state (
            id INT AUTO_INCREMENT PRIMARY KEY,
            `key` VARCHAR(100) UNIQUE,
            value TEXT,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ]])

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS na_staff (
            citizenId VARCHAR(50) PRIMARY KEY,
            `rank` VARCHAR(20) DEFAULT 'moderator',
            permissions TEXT DEFAULT '[]',
            assigned_by VARCHAR(50),
            assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]])
end

function NA.Server.SetupTimers()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(NexusAftermath.Config.world.cycleTime)
            NA.Server.UpdateWorldTier()
        end
    end)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(60000)
            NA.Server.TickWorldEvents()
        end
    end)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(10000)
            NA.Server.TickInfection()
        end
    end)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(30000)
            NA.Server.TickScavengers()
        end
    end)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(120000)
            NA.Server.TickEchoDecay()
        end
    end)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(5000)
            NA.Server.SyncWorldState()
        end
    end)
end

function NA.Server.UpdateWorldTier()
    local totalPlayers = #(GetPlayers())
    local avgInfection = 0
    local count = 0
    for _, player in pairs(NA.Players) do
        if player.infection and player.infection.level then
            avgInfection = avgInfection + player.infection.level
            count = count + 1
        end
    end
    if count > 0 then avgInfection = avgInfection / count end

    local buildingIntegrity = 0
    local buildingCount = 0
    for _, building in pairs(NA.Server.Buildings) do
        buildingIntegrity = buildingIntegrity + (building.integrity or 100)
        buildingCount = buildingCount + 1
    end
    if buildingCount > 0 then buildingIntegrity = buildingIntegrity / buildingCount end

    local activeEvents = #NA.Server.ActiveEvents

    local score = 100
    score = score - (avgInfection * 0.3)
    score = score - ((100 - buildingIntegrity) * 0.1)
    score = score - (activeEvents * 5)
    score = score - (math.random() * 2)

    if totalPlayers == 0 then
        score = score - 1
    end

    NA.Server.WorldScore = NA.Clamp(score, 0, 100)

    local newTier = 'safe'
    if NA.Server.WorldScore < 25 then
        newTier = 'collapse'
    elseif NA.Server.WorldScore < 50 then
        newTier = 'critical'
    elseif NA.Server.WorldScore < 75 then
        newTier = 'unstable'
    end

    if newTier ~= NA.Server.WorldTier then
        NA.Server.WorldTier = newTier
        local tierCfg = NA.World.GetTierConfig(newTier)
        NA.Debug('World tier changed to:', newTier, '(Score:', NA.Server.WorldScore, ')')
        TriggerClientEvent('na:worldTierChanged', -1, newTier, tierCfg)
        NA.ShowAdvancedNotif(-1, 'World Tier Changed', newTier:upper(), tierCfg.description, 'CHAR_LESTER_DEATHWISH')
    end
end

function NA.Server.TickWorldEvents()
    local tierCfg = NA.World.GetTierConfig(NA.Server.WorldTier)
    if math.random() < tierCfg.eventChance then
        local eventName = NA.World.GetRandomEvent(NA.Server.WorldTier)
        if eventName then
            NA.Server.StartWorldEvent(eventName)
        end
    end

    local toRemove = {}
    for name, event in pairs(NA.Server.ActiveEvents) do
        if os.time() >= event.endTime then
            table.insert(toRemove, name)
        end
    end
    for _, name in ipairs(toRemove) do
        NA.Server.EndWorldEvent(name)
    end
end

function NA.Server.StartWorldEvent(eventName)
    local eventCfg = NA.World.GetEventConfig(eventName)
    if not eventCfg then return end

    local center = nil
    if eventName == 'supply_drop' then
        local zone = NA.World.ScavengeZones[math.random(#NA.World.ScavengeZones)]
        center = zone.coords
    else
        local zone = NA.World.ScavengeZones[math.random(#NA.World.ScavengeZones)]
        center = zone.coords
    end

    NA.Server.ActiveEvents[eventName] = {
        config = eventCfg,
        startTime = os.time(),
        endTime = os.time() + (eventCfg.duration / 1000),
        center = center,
        radius = eventCfg.radius,
    }

    NA.Debug('World event started:', eventName, 'at', center)
    TriggerClientEvent('na:worldEventStarted', -1, eventName, eventCfg, center)
    NA.ShowAdvancedNotif(-1, 'WORLD EVENT: ' .. eventCfg.label, '', eventCfg.description, 'CHAR_LESTER_DEATHWISH')
end

function NA.Server.EndWorldEvent(eventName)
    NA.Server.ActiveEvents[eventName] = nil
    NA.Debug('World event ended:', eventName)
    TriggerClientEvent('na:worldEventEnded', -1, eventName)
end

function NA.Server.TickInfection()
    for src, player in pairs(NA.Players) do
        if player.infection and player.infection.strain then
            local rate = NexusAftermath.Config.infectionRate
            local tierMult = NA.World.GetTierConfig(NA.Server.WorldTier).infectionMult
            local progression = rate * tierMult * (0.5 + math.random() * 0.5)

            player.infection.level = NA.Clamp((player.infection.level or 0) + progression, 0, 100)

            if player.infection.level >= 80 and not player.infection.mutated then
                if math.random() < 0.1 then
                    local mutation = NA.Viruses.GetRandomMutation(player.infection.strain)
                    if mutation then
                        player.infection.mutation = mutation
                        player.infection.mutated = true
                        NA.Debug('Player', src, 'mutated with', mutation)
                        TriggerClientEvent('na:infectionMutated', src, mutation)
                    end
                end
            end

            TriggerClientEvent('na:infectionUpdate', src, player.infection)
        end
    end
end

function NA.Server.TickScavengers()
    local tierCfg = NA.World.GetTierConfig(NA.Server.WorldTier)
    local maxScav = math.floor(NexusAftermath.Config.scavengers.maxPerZone * tierCfg.scavengerMult)

    for _, zone in ipairs(NA.World.ScavengeZones) do
        if not NA.Server.ScavengerPools[zone.label] then
            NA.Server.ScavengerPools[zone.label] = {}
        end

        local current = #NA.Server.ScavengerPools[zone.label]
        if current < maxScav and math.random() < 0.3 then
            local scav = {
                id = NA.GetRandomString(8),
                zone = zone.label,
                coords = zone.coords,
                state = 'searching',
                inventory = {},
                aggression = math.random() * 100,
                strength = math.random() * 100,
                createdAt = os.time(),
                lastAction = os.time(),
            }
            table.insert(NA.Server.ScavengerPools[zone.label], scav)
            TriggerClientEvent('na:scavengerSpawned', -1, scav.id, zone.label, zone.coords)
        end
    end
end

function NA.Server.TickEchoDecay()
    local now = os.time()
    local toRemove = {}
    for id, echo in pairs(NA.Server.EchoRegistry) do
        if now >= echo.decayAt then
            table.insert(toRemove, id)
        end
    end
    for _, id in ipairs(toRemove) do
        NA.Server.EchoRegistry[id] = nil
        MySQL.query('DELETE FROM na_echoes WHERE id = ?', { id })
    end
    if #toRemove > 0 then
        NA.Debug('Decayed', #toRemove, 'echoes')
    end
end

function NA.Server.SyncWorldState()
    TriggerClientEvent('na:worldSync', -1, {
        tier = NA.Server.WorldTier,
        score = NA.Server.WorldScore,
        activeEvents = NA.Server.ActiveEvents,
        playerCount = #(GetPlayers()),
        scavengerCount = NA.Server.GetTotalScavengers(),
        buildingCount = NA.TableSize(NA.Server.Buildings),
        radiationZones = NA.World.RadiationZones,
    })
    MySQL.query('INSERT INTO na_world_state (`key`, value) VALUES (?, ?) ON DUPLICATE KEY UPDATE value = ?',
        { 'world_tier', NA.Server.WorldTier, NA.Server.WorldTier })
end

function NA.Server.GetTotalScavengers()
    local count = 0
    for _, pool in pairs(NA.Server.ScavengerPools) do
        count = count + #pool
    end
    return count
end

function NA.Server.RegisterCommands()
    RegisterCommand('na_debug', function(source, args)
        if source == 0 then
            NexusAftermath.Config.debug = not NexusAftermath.Config.debug
            print('[NA] Debug mode:', NexusAftermath.Config.debug)
        end
    end, true)

    RegisterCommand('na_tier', function(source, args)
        if source == 0 or NA.Server.Staff[source] then
            if args[1] and NA.World.Tiers[args[1]] then
                NA.Server.WorldTier = args[1]
                NA.Debug('Manual world tier set to:', args[1])
            else
                NA.ShowNotification(source, 'Current tier: ' .. NA.Server.WorldTier .. ' (Score: ' .. NA.Server.WorldScore .. ')', 'info')
            end
        end
    end, false)

    RegisterCommand('na_event', function(source, args)
        if source == 0 or NA.Server.Staff[source] then
            if args[1] and NA.World.Events[args[1]] then
                NA.Server.StartWorldEvent(args[1])
                NA.ShowNotification(source, 'Event started: ' .. args[1], 'success')
            else
                NA.ShowNotification(source, 'Usage: /na_event [event_name]', 'error')
            end
        end
    end, false)
end

exports('GetWorldTier', function() return NA.Server.WorldTier end)
exports('GetWorldScore', function() return NA.Server.WorldScore end)
exports('GetActiveEvents', function() return NA.Server.ActiveEvents end)
exports('GetScavengerPools', function() return NA.Server.ScavengerPools end)
exports('GetBuildings', function() return NA.Server.Buildings end)
exports('GetEchoRegistry', function() return NA.Server.EchoRegistry end)
exports('GetTetherNetwork', function() return NA.Server.TetherNetwork end)
