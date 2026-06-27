NA.Server.Echo = {}

RegisterNetEvent('na:recordEcho')
AddEventHandler('na:recordEcho', function(data)
    local src = source
    local player = NA.GetPlayer(src)
    if not player then return end

    local coords = data.coords
    local eventType = data.eventType or 'player_action'
    local recording = data.recording or {}

    local echo = {
        creator = player.charData.citizenId,
        creatorName = player.charData.name,
        coords = coords,
        eventType = eventType,
        data = recording,
        recording = recording,
        decayAt = os.time() + (NexusAftermath.Config.echo.echoDecayTime or 604800),
        createdAt = os.time(),
    }

    local success = MySQL.insert.await('INSERT INTO na_echoes (creator_citizenId, pos_x, pos_y, pos_z, event_type, data, recording, decay_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        { echo.creator, coords.x, coords.y, coords.z, eventType, NA.SerializeForDb(data), NA.SerializeForDb(recording), echo.decayAt })

    if success then
        echo.id = success
        NA.Server.EchoRegistry[echo.id] = echo

        local nearbyPlayers = NA.GetPlayersInRange({ x = coords.x, y = coords.y, z = coords.z }, 50.0)
        for nearSrc in pairs(nearbyPlayers) do
            if nearSrc ~= src then
                TriggerClientEvent('na:echoNearby', nearSrc, echo.id, coords)
            end
        end

        NA.ShowNotification(src, 'Echo recorded', 'success')
        NA.Log(src, 'echo_recorded', { echoId = echo.id, eventType = eventType })
    end
end)

RegisterNetEvent('na:playEcho')
AddEventHandler('na:playEcho', function(echoId)
    local src = source
    local echo = NA.Server.EchoRegistry[echoId]
    if not echo then
        local result = MySQL.query.await('SELECT * FROM na_echoes WHERE id = ?', { echoId })
        if result and #result > 0 then
            echo = result[1]
            echo.data = NA.DeserializeFromDb(echo.data)
            echo.recording = NA.DeserializeFromDb(echo.recording)
        else
            NA.ShowNotification(src, 'Echo has faded away', 'error')
            return
        end
    end

    TriggerClientEvent('na:echoPlayback', src, echo)
end)

RegisterNetEvent('na:echoDeath')
AddEventHandler('na:echoDeath', function()
    local src = source
    local player = NA.GetPlayer(src)
    if not player then return end

    local coords = GetEntityCoords(GetPlayerPed(src))

    local recording = {
        type = 'death',
        playerName = player.charData.name,
        timestamp = os.time(),
        position = NA.VectorToTable(coords),
        health = player.charData.health,
        infection = player.infection.strain,
    }

    Citizen.Wait(2000)

    local echo = {
        creator = player.charData.citizenId,
        creatorName = player.charData.name,
        coords = { x = coords.x, y = coords.y, z = coords.z },
        eventType = 'player_death',
        recording = recording,
        decayAt = os.time() + (NexusAftermath.Config.echo.echoDecayTime or 604800),
        createdAt = os.time(),
    }

    local success = MySQL.insert.await('INSERT INTO na_echoes (creator_citizenId, pos_x, pos_y, pos_z, event_type, data, recording, decay_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        { echo.creator, coords.x, coords.y, coords.z, 'player_death', NA.SerializeForDb({}), NA.SerializeForDb(recording), echo.decayAt })

    if success then
        echo.id = success
        NA.Server.EchoRegistry[echo.id] = echo
        NA.Debug('Death echo created for', player.charData.name, 'at', coords.x, coords.y, coords.z)
    end
end)

RegisterNetEvent('na:getNearbyEchoes')
AddEventHandler('na:getNearbyEchoes', function(coords)
    local src = source
    local player = NA.GetPlayer(src)
    if not player then return end

    local nearby = {}
    for id, echo in pairs(NA.Server.EchoRegistry) do
        local dist = NA.Distance(coords, echo.coords)
        if dist <= 100.0 then
            nearby[#nearby+1] = {
                id = id,
                coords = echo.coords,
                eventType = echo.eventType,
                creatorName = echo.creatorName,
                createdAt = echo.createdAt,
                distance = dist,
            }
        end
    end

    table.sort(nearby, function(a, b) return a.distance < b.distance end)

    local dbResult = MySQL.query.await('SELECT id, pos_x, pos_y, pos_z, event_type, creator_citizenId, created_at FROM na_echoes WHERE pos_x BETWEEN ? AND ? AND pos_y BETWEEN ? AND ? AND decay_at > ?',
        { coords.x - 100, coords.x + 100, coords.y - 100, coords.y + 100, os.time() })

    if dbResult then
        for _, row in ipairs(dbResult) do
            if not NA.Server.EchoRegistry[row.id] then
                local dist = NA.Distance(coords, { x = row.pos_x, y = row.pos_y, z = row.pos_z })
                if dist <= 100 then
                    nearby[#nearby+1] = {
                        id = row.id,
                        coords = { x = row.pos_x, y = row.pos_y, z = row.pos_z },
                        eventType = row.event_type,
                        creatorName = 'Unknown Survivor',
                        createdAt = row.created_at and os.time() or os.time(),
                        distance = dist,
                    }
                end
            end
        end
    end

    TriggerClientEvent('na:nearbyEchoes', src, nearby)
end)

-- When a player dies, automatically record an echo
RegisterNetEvent('na:playerDied')
AddEventHandler('na:playerDied', function()
    local src = source
    Citizen.CreateThread(function()
        Citizen.Wait(1000)
        TriggerEvent('na:echoDeath', src)
    end)
end)

exports('GetEchoes', function() return NA.Server.EchoRegistry end)
exports('GetEcho', function(id) return NA.Server.EchoRegistry[id] end)
