NA.Server.Player = {}

RegisterServerEvent('na:playerJoin')
AddEventHandler('na:playerJoin', function()
    local source = source
    NA.Debug('Player joining:', source)

    local identifiers = GetPlayerIdentifiers(source)
    local license, citizenId, steamId, name = nil, nil, nil, GetPlayerName(source)

    for _, id in ipairs(identifiers) do
        if string.find(id, 'license:') then license = id:sub(9) end
        if string.find(id, 'steam:') then steamId = id:sub(7) end
    end

    if not license then
        DropPlayer(source, 'No license identifier found')
        return
    end

    local playerData = MySQL.query.await('SELECT * FROM na_players WHERE license = ?', { license })

    local charData = nil
    if playerData and #playerData > 0 then
        charData = playerData[1]
        charData.inventory = NA.DeserializeFromDb(charData.inventory)
        charData.position = NA.DeserializeFromDb(charData.position)
        charData.stats = NA.DeserializeFromDb(charData.stats)
        charData.skills = NA.DeserializeFromDb(charData.skills)
        charData.reputation = NA.DeserializeFromDb(charData.reputation)
        charData.infection_mutations = NA.DeserializeFromDb(charData.infection_mutations)
        NA.Debug('Player loaded from DB:', license)
    else
        citizenId = 'NA_' .. NA.GetRandomString(12)
        charData = {
            citizenId = citizenId,
            license = license,
            name = name,
            firstname = 'Survivor',
            lastname = tostring(math.random(1000, 9999)),
            gender = 'male',
            dateofbirth = 'Unknown',
            health = 200,
            armor = 0,
            hunger = 100,
            thirst = 100,
            infection_strain = nil,
            infection_level = 0,
            infection_mutations = {},
            stats = {
                strength = 10,
                endurance = 10,
                perception = 10,
                intelligence = 10,
                agility = 10,
                luck = 10,
            },
            inventory = {},
            position = NexusAftermath.Config.spawn,
            skills = { crafting = 0, combat = 0, survival = 0, medical = 0 },
            reputation = {},
            playtime = 0,
        }
        MySQL.insert('INSERT INTO na_players (citizenId, license, name, firstname, lastname, health, armor, hunger, thirst, stats, inventory, position, skills, reputation) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            { citizenId, license, name, charData.firstname, charData.lastname, 200, 0, 100, 100, NA.SerializeForDb(charData.stats), '[]', NA.SerializeForDb(NexusAftermath.Config.spawn), NA.SerializeForDb(charData.skills), '{}' })
        NA.Debug('New player created:', citizenId)
    end

    local player = {
        source = source,
        charData = charData,
        ped = GetPlayerPed(source),
        infection = {
            strain = charData.infection_strain,
            level = charData.infection_level or 0,
            mutations = charData.infection_mutations or {},
            mutated = charData.infection_level and charData.infection_level >= 80 or false,
        },
        stats = NA.MergeTables({ strength = 10, endurance = 10, perception = 10, intelligence = 10, agility = 10, luck = 10 }, charData.stats or {}),
        skills = NA.MergeTables({ crafting = 0, combat = 0, survival = 0, medical = 0 }, charData.skills or {}),
        reputation = charData.reputation or {},
        tethered = {},
        radioFreq = NexusAftermath.Config.radio.defaultFreq,
        isStaff = NA.Server.CheckStaff(source, citizenId),
        settings = {},
        lastSave = os.time(),
    }

    NA.Players[source] = player

    if player.isStaff then
        NA.Server.Staff[source] = true
    end

    TriggerClientEvent('na:playerDataLoaded', source, {
        charData = charData,
        infection = player.infection,
        stats = player.stats,
        skills = player.skills,
        reputation = player.reputation,
        config = {
            safeZones = NexusAftermath.Config.safeZones,
            spawn = NexusAftermath.Config.spawn,
            maxWeight = 100,
            slots = 50,
        },
        world = {
            tier = NA.Server.WorldTier,
            score = NA.Server.WorldScore,
            activeEvents = NA.Server.ActiveEvents,
        }
    })

    NA.Log(source, 'player_joined', { citizenId = charData.citizenId })
end)

AddEventHandler('playerDropped', function(reason)
    local source = source
    local player = NA.Players[source]
    if not player then return end

    local coords = GetEntityCoords(GetPlayerPed(source))
    player.charData.position = NA.VectorToTable(coords)
    player.charData.infection_strain = player.infection.strain
    player.charData.infection_level = player.infection.level
    player.charData.infection_mutations = player.infection.mutations

    MySQL.update('UPDATE na_players SET health = ?, armor = ?, hunger = ?, thirst = ?, infection_strain = ?, infection_level = ?, infection_mutations = ?, position = ?, stats = ?, skills = ?, reputation = ? WHERE citizenId = ?',
        {
            player.charData.health or 200,
            player.charData.armor or 0,
            player.charData.hunger or 100,
            player.charData.thirst or 100,
            player.infection.strain,
            player.infection.level,
            NA.SerializeForDb(player.infection.mutations),
            NA.SerializeForDb(player.charData.position),
            NA.SerializeForDb(player.stats),
            NA.SerializeForDb(player.skills),
            NA.SerializeForDb(player.reputation),
            player.charData.citizenId,
        })

    NA.Server.Player.RemoveFromTethers(source)
    NA.Players[source] = nil
    NA.Server.Staff[source] = nil
    NA.Log(source, 'player_left', { reason = reason })
end)

function NA.Server.Player.Save(player)
    if not player then return end
    local coords = GetEntityCoords(GetPlayerPed(player.source))
    player.charData.position = NA.VectorToTable(coords)
    MySQL.update('UPDATE na_players SET health = ?, armor = ?, hunger = ?, thirst = ?, infection_strain = ?, infection_level = ?, infection_mutations = ?, position = ?, stats = ?, skills = ?, reputation = ?, playtime = playtime + ? WHERE citizenId = ?',
        {
            player.charData.health or 200,
            player.charData.armor or 0,
            player.charData.hunger or 100,
            player.charData.thirst or 100,
            player.infection.strain,
            player.infection.level,
            NA.SerializeForDb(player.infection.mutations),
            NA.SerializeForDb(player.charData.position),
            NA.SerializeForDb(player.stats),
            NA.SerializeForDb(player.skills),
            NA.SerializeForDb(player.reputation),
            math.floor((os.time() - (player.lastSave or os.time())) / 60),
            player.charData.citizenId,
        })
    player.lastSave = os.time()
end

function NA.Server.Player.RemoveFromTethers(source)
    local player = NA.Players[source]
    if not player then return end
    for _, tetheredSrc in ipairs(player.tethered) do
        local tetheredPlayer = NA.Players[tetheredSrc]
        if tetheredPlayer then
            for i, src in ipairs(tetheredPlayer.tethered) do
                if src == source then
                    table.remove(tetheredPlayer.tethered, i)
                    break
                end
            end
            TriggerClientEvent('na:tetherBroken', tetheredSrc, source)
        end
    end
    player.tethered = {}
end

function NA.Server.CheckStaff(source, citizenId)
    if source == 0 then return true end
    local result = MySQL.query.await('SELECT * FROM na_staff WHERE citizenId = ?', { citizenId })
    return result and #result > 0
end

exports('GetPlayer', NA.GetPlayer)
exports('GetPlayers', NA.GetOnlinePlayers)
exports('SavePlayer', NA.Server.Player.Save)
