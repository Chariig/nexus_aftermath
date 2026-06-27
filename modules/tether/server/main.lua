NA.Server.Tether = {}

RegisterNetEvent('na:tetherRequest')
AddEventHandler('na:tetherRequest', function(targetSrc)
    local src = source
    local player = NA.GetPlayer(src)
    local target = NA.GetPlayer(targetSrc)

    if not player or not target then
        NA.ShowNotification(src, 'Target not found', 'error')
        return
    end

    if src == targetSrc then
        NA.ShowNotification(src, 'Cannot tether to yourself', 'error')
        return
    end

    if #player.tethered >= NexusAftermath.Config.tether.maxTethered then
        NA.ShowNotification(src, 'Max tethered players reached', 'error')
        return
    end

    if #target.tethered >= NexusAftermath.Config.tether.maxTethered then
        NA.ShowNotification(src, 'Target has max tethered players', 'error')
        return
    end

    local coords = GetEntityCoords(GetPlayerPed(src))
    local targetCoords = GetEntityCoords(GetPlayerPed(targetSrc))
    local dist = NA.Distance({ x = coords.x, y = coords.y, z = coords.z }, { x = targetCoords.x, y = targetCoords.y, z = targetCoords.z })

    if dist > NexusAftermath.Config.tether.maxRange then
        NA.ShowNotification(src, 'Target is too far', 'error')
        return
    end

    NA.ShowNotification(targetSrc, player.charData.name .. ' wants to tether with you. Press ~INPUT_CONTEXT~ to accept.', 'info', 10000)
    TriggerClientEvent('na:tetherRequest', targetSrc, src)
end)

RegisterNetEvent('na:tetherAccept')
AddEventHandler('na:tetherAccept', function(requesterSrc)
    local src = source
    local player = NA.GetPlayer(src)
    local requester = NA.GetPlayer(requesterSrc)

    if not player or not requester then return end

    table.insert(player.tethered, requesterSrc)
    table.insert(requester.tethered, src)

    NA.Server.Tether.CreateTetherLink(src, requesterSrc)

    NA.ShowNotification(src, 'Tethered with ' .. requester.charData.name, 'success')
    NA.ShowNotification(requesterSrc, 'Tethered with ' .. player.charData.name, 'success')
    NA.Log(src, 'tether_established', { with = requester.charData.citizenId })
end)

RegisterNetEvent('na:tetherBreak')
AddEventHandler('na:tetherBreak', function(targetSrc)
    local src = source
    NA.Server.Player.RemoveFromTethers(src)
    NA.ShowNotification(src, 'Tether broken', 'info')
    if NA.Players[targetSrc] then
        NA.ShowNotification(targetSrc, 'Tether broken', 'info')
    end
end)

function NA.Server.Tether.CreateTetherLink(src1, src2)
    TriggerClientEvent('na:tetherCreated', src1, src2)
    TriggerClientEvent('na:tetherCreated', src2, src1)
end

function NA.Server.Tether.GetTetheredPlayers(src)
    local player = NA.GetPlayer(src)
    if not player then return {} end
    return player.tethered
end

function NA.Server.Tether.ShareHealth(src, healthChange)
    local player = NA.GetPlayer(src)
    if not player or not NexusAftermath.Config.tether.shareHealth then return end

    for _, tSrc in ipairs(player.tethered) do
        local tPlayer = NA.GetPlayer(tSrc)
        if tPlayer then
            local coords = GetEntityCoords(GetPlayerPed(src))
            local tCoords = GetEntityCoords(GetPlayerPed(tSrc))
            local dist = NA.Distance({ x = coords.x, y = coords.y, z = coords.z }, { x = tCoords.x, y = tCoords.y, z = tCoords.z })

            if dist <= NexusAftermath.Config.tether.maxRange then
                local sharedAmount = healthChange * 0.3
                tPlayer.charData.health = NA.Clamp((tPlayer.charData.health or 200) + sharedAmount, 0, 200)
                TriggerClientEvent('na:updateHealth', tSrc, tPlayer.charData.health)
            end
        end
    end
end

function NA.Server.Tether.ShareItem(src, itemName, count, targetSrc)
    local player = NA.GetPlayer(src)
    local target = NA.GetPlayer(targetSrc)
    if not player or not target then return false end

    local isTethered = false
    for _, t in ipairs(player.tethered) do
        if t == targetSrc then isTethered = true; break end
    end
    if not isTethered then return false end

    if not NexusAftermath.Config.tether.shareInventory then
        NA.ShowNotification(src, 'Inventory sharing is disabled', 'error')
        return false
    end

    local coords = GetEntityCoords(GetPlayerPed(src))
    local tCoords = GetEntityCoords(GetPlayerPed(targetSrc))
    local dist = NA.Distance({ x = coords.x, y = coords.y, z = coords.z }, { x = tCoords.x, y = tCoords.y, z = tCoords.z })

    if dist > NexusAftermath.Config.tether.maxRange then
        NA.ShowNotification(src, 'Target is too far to transfer items', 'error')
        return false
    end

    if not NA.Server.Inventory.HasItem(src, itemName, count) then
        NA.ShowNotification(src, 'You do not have this item', 'error')
        return false
    end

    return true
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        for src, player in pairs(NA.Players) do
            if #player.tethered > 0 then
                local coords = GetEntityCoords(GetPlayerPed(src))
                for _, tSrc in ipairs(player.tethered) do
                    if not NA.Players[tSrc] then
                        NA.Server.Player.RemoveFromTethers(src)
                        break
                    end
                    local tCoords = GetEntityCoords(GetPlayerPed(tSrc))
                    local dist = NA.Distance({ x = coords.x, y = coords.y, z = coords.z }, { x = tCoords.x, y = tCoords.y, z = tCoords.z })
                    if dist > NexusAftermath.Config.tether.maxRange * 1.5 then
                        NA.ShowNotification(src, 'Tether with ' .. (NA.Players[tSrc] or {}).charData.name .. ' is breaking - too far!', 'error')
                        NA.ShowNotification(tSrc, 'Tether with ' .. player.charData.name .. ' is breaking - too far!', 'error')
                        if dist > NexusAftermath.Config.tether.maxRange * 2.5 then
                            NA.Server.Player.RemoveFromTethers(src)
                            break
                        end
                    end
                end
            end
        end
    end
end)

exports('GetTether', function(src) return NA.Server.Tether.GetTetheredPlayers(src) end)
exports('ShareHealth', NA.Server.Tether.ShareHealth)
