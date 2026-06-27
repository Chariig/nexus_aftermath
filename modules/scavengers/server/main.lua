NA.Server.Scavengers = {}

NA.Server.Scavengers.Memory = {}

function NA.Server.Scavengers.CreateScavenger(zoneLabel, zoneCoords)
    local id = 'SCAV_' .. NA.GetRandomString(8)
    local scavTypes = { 'looter', 'wanderer', 'hostile', 'trader', 'hermit' }
    local scavType = scavTypes[math.random(#scavTypes)]

    local scav = {
        id = id,
        type = scavType,
        state = 'spawning',
        zone = zoneLabel,
        homeCoords = zoneCoords,
        coords = zoneCoords,
        health = 100,
        aggression = NA.RandomRange(20, 80),
        strength = NA.RandomRange(10, 50),
        perception = NA.RandomRange(30, 70),
        speed = NA.RandomRange(0.5, 1.5),
        inventory = {},
        lootMemory = {},
        faction = nil,
        createdAt = os.time(),
        lastAction = os.time(),
        patrolTarget = nil,
        patrolIndex = 1,
        patrolPoints = NA.Server.Scavengers.GeneratePatrolPoints(zoneCoords, 5),
    }

    if scavType == 'trader' then
        scav.aggression = NA.RandomRange(5, 20)
        scav.inventory = NA.Server.Scavengers.GenerateTraderInventory()
    elseif scavType == 'hostile' then
        scav.aggression = NA.RandomRange(60, 100)
        scav.strength = NA.RandomRange(30, 80)
        local weapons = { 'melee_makeshift', 'melee_knife', 'weapon_bat' }
        table.insert(scav.inventory, { name = weapons[math.random(#weapons)], count = 1 })
    elseif scavType == 'looter' then
        scav.perception = NA.RandomRange(50, 90)
    end

    return scav
end

function NA.Server.Scavengers.GeneratePatrolPoints(center, count)
    local points = {}
    for i = 1, count do
        local angle = (i / count) * math.pi * 2
        local radius = NA.RandomRange(20, 80)
        points[#points+1] = vector3(
            center.x + math.cos(angle) * radius,
            center.y + math.sin(angle) * radius,
            center.z
        )
    end
    return points
end

function NA.Server.Scavengers.GenerateTraderInventory()
    local inv = {}
    local possibleItems = { 'bandage', 'canned_food', 'water_bottle', 'antibiotic', 'battery', 'lockpick', 'pistol_ammo', 'herbs', 'cloth' }
    local count = math.random(2, 5)
    for i = 1, count do
        local item = possibleItems[math.random(#possibleItems)]
        local found = false
        for _, invItem in ipairs(inv) do
            if invItem.name == item then
                invItem.count = invItem.count + math.random(1, 3)
                found = true
                break
            end
        end
        if not found then
            table.insert(inv, { name = item, count = math.random(1, 3) })
        end
    end
    return inv
end

function NA.Server.Scavengers.ProcessAI(scav)
    local now = os.time()
    if now - scav.lastAction < 5 then return end
    scav.lastAction = now

    if scav.state == 'spawning' then
        scav.state = 'patrolling'
        return
    end

    -- Check for player proximity
    local nearbyPlayers = NA.GetPlayersInRange(scav.homeCoords, 150.0)

    if #nearbyPlayers == 0 then
        scav.state = 'patrolling'
        NA.Server.Scavengers.DoPatrol(scav)
        return
    end

    -- React to nearest player
    local nearestSrc, nearestDist = nil, 200
    for src, data in pairs(nearbyPlayers) do
        if data.distance < nearestDist then
            nearestDist = data.distance
            nearestSrc = src
        end
    end

    if nearestSrc then
        local player = NA.Players[nearestSrc]

        -- Check memory
        local memoryKey = player.charData.citizenId .. '_' .. scav.zone
        local memory = NA.Server.Scavengers.Memory[memoryKey]
        local hostility = 0

        if memory then
            hostility = memory.hostility or 0
            if memory.lastEncounter and (now - memory.lastEncounter) < 3600 then
                hostility = hostility * 1.5
            end
        end

        local threatLevel = scav.aggression + hostility

        if nearestDist < 20 and (scav.type == 'hostile' or threatLevel > 100) then
            scav.state = 'attacking'
            TriggerClientEvent('na:scavengerAttack', -1, scav.id, nearestSrc)
        elseif nearestDist < 40 and scav.type == 'trader' then
            scav.state = 'trading'
            TriggerClientEvent('na:scavengerTrade', nearestSrc, scav.id, scav.inventory)
        elseif nearestDist < 30 then
            if scav.aggression < 40 then
                scav.state = 'fleeing'
            else
                scav.state = 'aggressive'
            end
            if scav.state == 'fleeing' then
                local fleeDir = math.random() * math.pi * 2
                local fleePos = vector3(
                    scav.homeCoords.x + math.cos(fleeDir) * 100,
                    scav.homeCoords.y + math.sin(fleeDir) * 100,
                    scav.homeCoords.z
                )
                TriggerClientEvent('na:scavengerMove', -1, scav.id, fleePos, 'fleeing')
            else
                scav.state = 'threatening'
                TriggerClientEvent('na:scavengerThreaten', nearestSrc, scav.id)
            end
        end

        NA.Server.Scavengers.Memory[memoryKey] = {
            hostility = (memory and memory.hostility or 0) + (scav.type == 'hostile' and 5 or 1),
            lastEncounter = now,
        }

        -- Share memory between scavs in same zone (competition memory)
        if NexusAftermath.Config.scavengers.competitionMemory then
            for otherId, otherScav in pairs(NA.Server.ScavengerPools[scav.zone] or {}) do
                if otherId ~= scav.id then
                    local otherKey = player.charData.citizenId .. '_' .. otherScav.zone
                    NA.Server.Scavengers.Memory[otherKey] = NA.Server.Scavengers.Memory[memoryKey]
                end
            end
        end
    else
        NA.Server.Scavengers.DoPatrol(scav)
    end
end

function NA.Server.Scavengers.DoPatrol(scav)
    if not scav.patrolPoints or #scav.patrolPoints == 0 then return end

    scav.patrolIndex = (scav.patrolIndex % #scav.patrolPoints) + 1
    local target = scav.patrolPoints[scav.patrolIndex]

    if target then
        TriggerClientEvent('na:scavengerMove', -1, scav.id, target, 'patrolling')
        if math.random() < 0.2 then
            scav.state = 'searching'
            TriggerClientEvent('na:scavengerSearch', -1, scav.id, scav.homeCoords)
        end
    end
end

RegisterNetEvent('na:scavengerKilled')
AddEventHandler('na:scavengerKilled', function(scavId)
    local src = source

    for zoneLabel, pool in pairs(NA.Server.ScavengerPools) do
        for i, scav in ipairs(pool) do
            if scav.id == scavId then
                -- Drop loot
                if #scav.inventory > 0 then
                    local coords = GetEntityCoords(GetPlayerPed(src))
                    for _, item in ipairs(scav.inventory) do
                        TriggerClientEvent('na:spawnWorldItem', -1, item.name, item.count, coords.x, coords.y, coords.z - 1)
                    end
                end

                table.remove(pool, i)
                TriggerClientEvent('na:scavengerDespawned', -1, scavId)
                NA.Log(src, 'scavenger_killed', { scavId = scavId, zone = zoneLabel })

                -- Respawn timer
                Citizen.CreateThread(function()
                    Citizen.Wait(NexusAftermath.Config.scavengers.respawnTime)
                    local newScav = NA.Server.Scavengers.CreateScavenger(zoneLabel, scav.homeCoords)
                    table.insert(pool, newScav)
                    TriggerClientEvent('na:scavengerSpawned', -1, newScav.id, zoneLabel, scav.homeCoords)
                end)
                return
            end
        end
    end
end)

RegisterNetEvent('na:scavengerTradeComplete')
AddEventHandler('na:scavengerTradeComplete', function(scavId)
    for _, pool in pairs(NA.Server.ScavengerPools) do
        for i, scav in ipairs(pool) do
            if scav.id == scavId then
                table.remove(pool, i)
                TriggerClientEvent('na:scavengerDespawned', -1, scavId)
                return
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000)
        for zoneLabel, pool in pairs(NA.Server.ScavengerPools) do
            for _, scav in ipairs(pool) do
                NA.Server.Scavengers.ProcessAI(scav)
            end
        end
    end
end)

exports('GetScavengerPool', function(zone) return NA.Server.ScavengerPools[zone] end)
exports('GetScavengerMemory', function() return NA.Server.Scavengers.Memory end)
