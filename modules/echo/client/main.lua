NA.Client.Echo = {}

RegisterNetEvent('na:echoNearby')
AddEventHandler('na:echoNearby', function(echoId, coords)
    local dist = #(GetEntityCoords(PlayerPedId()) - vector3(coords.x, coords.y, coords.z))
    if dist < 50 then
        NA.Client.ShowNotification('~b~An echo pulses nearby~s~', 'echo', 4000)
    end
end)

RegisterNetEvent('na:echoPlayback')
AddEventHandler('na:echoPlayback', function(echo)
    AnimpostfxPlay('BoatHeist', 2000, true)

    Citizen.Wait(2000)

    if echo.recording and echo.recording.type == 'death' then
        local deathPos = echo.recording.position
        if deathPos then
            local blip = AddBlipForCoord(deathPos.x, deathPos.y, deathPos.z)
            SetBlipSprite(blip, 161)
            SetBlipColour(blip, 1)
            SetBlipScale(blip, 0.8)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString('Death Echo: ' .. echo.recording.playerName)
            EndTextCommandSetBlipName(blip)
            Citizen.Wait(10000)
            RemoveBlip(blip)
        end
    end

    local msg = '~b~Echo Playback~s~\n'
    if echo.recording then
        if echo.recording.infection then
            msg = msg .. '~r~Infected at time of death: ~s~' .. echo.recording.infection .. '\n'
        end
        msg = msg .. '~w~' .. (echo.creatorName or 'Unknown Survivor') .. ' - ' .. os.date('%c', echo.recording.timestamp or os.time())
    end
    NA.Client.ShowNotification(msg, 'echo', 8000)
end)

RegisterNetEvent('na:recordEcho')
AddEventHandler('na:recordEcho', function()
    local coords = GetEntityCoords(PlayerPedId())
    local recording = {
        type = 'player_action',
        playerName = GetPlayerName(PlayerId()),
        timestamp = os.time(),
        position = { x = coords.x, y = coords.y, z = coords.z },
        health = GetEntityHealth(PlayerPedId()),
        infection = NA.Client.Infection and NA.Client.Infection.strain,
    }

    TriggerServerEvent('na:recordEcho', {
        coords = { x = coords.x, y = coords.y, z = coords.z },
        eventType = 'player_action',
        recording = recording,
    })
end)

-- Record death echo locally
AddEventHandler('gameEventTriggered', function(name, args)
    if name == 'CEventDeath' then
        local ped = PlayerPedId()
        if args[1] == ped then
            Citizen.CreateThread(function()
                Citizen.Wait(3000)
                TriggerServerEvent('na:playerDied')
            end)
        end
    end
end)
