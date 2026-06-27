NA.Client.Tether = {}

RegisterNetEvent('na:tetherRequest')
AddEventHandler('na:tetherRequest', function(requesterSrc)
    NA.Client.PendingTether = requesterSrc
    NA.Client.ShowNotification('Tether request received. Press ~INPUT_CONTEXT~ to accept.', 'info', 10000)

    Citizen.CreateThread(function()
        local timer = 0
        while NA.Client.PendingTether and timer < 100 do
            Citizen.Wait(100)
            timer = timer + 1
            if IsControlJustPressed(0, 38) then
                TriggerServerEvent('na:tetherAccept', requesterSrc)
                NA.Client.PendingTether = nil
                break
            end
        end
        NA.Client.PendingTether = nil
    end)
end)

RegisterNetEvent('na:tetherCreated')
AddEventHandler('na:tetherCreated', function(targetSrc)
    NA.Client.Tethered = NA.Client.Tethered or {}
    table.insert(NA.Client.Tethered, targetSrc)
    NA.Client.ShowNotification('~b~Tether established~s~', 'success')
end)

RegisterNetEvent('na:tetherBroken')
AddEventHandler('na:tetherBroken', function(targetSrc)
    for i, t in ipairs(NA.Client.Tethered or {}) do
        if t == targetSrc then
            table.remove(NA.Client.Tethered, i)
            NA.Client.ShowNotification('~r~Tether broken~s~', 'info')
            return
        end
    end
end)

-- Visual tether lines
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if NA.Client.Tethered and #NA.Client.Tethered > 0 then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local bone = GetPedBoneIndex(ped, 0)

            for _, tSrc in ipairs(NA.Client.Tethered) do
                local tPed = GetPlayerPed(GetPlayerFromServerId(tSrc))
                if DoesEntityExist(tPed) then
                    local tCoords = GetEntityCoords(tPed)
                    local dist = #(coords - tCoords)
                    if dist < 150 then
                        local r = math.floor(NA.Lerp(255, 100, dist / 150))
                        local g = math.floor(NA.Lerp(100, 255, dist / 150))
                        local b = 255
                        DrawLine(coords.x, coords.y, coords.z + 0.5, tCoords.x, tCoords.y, tCoords.z + 0.5, r, g, b, 150)
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
end)
