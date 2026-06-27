NA.Client.Scavengers = NA.Client.Scavengers or {}

RegisterNetEvent('na:scavengerSpawned')
AddEventHandler('na:scavengerSpawned', function(scavId, zoneLabel, coords)
    NA.Client.Scavengers[scavId] = {
        id = scavId,
        zone = zoneLabel,
        coords = coords,
        entity = nil,
        state = 'spawning',
        blip = nil,
    }
end)

RegisterNetEvent('na:scavengerMove')
AddEventHandler('na:scavengerMove', function(scavId, targetCoords, state)
    local scav = NA.Client.Scavengers[scavId]
    if not scav then return end
    scav.state = state
    scav.targetCoords = targetCoords
end)

RegisterNetEvent('na:scavengerSearch')
AddEventHandler('na:scavengerSearch', function(scavId, zoneCoords)
    local scav = NA.Client.Scavengers[scavId]
    if not scav then return end
    scav.state = 'searching'
    DrawMarker(1, zoneCoords.x, zoneCoords.y, zoneCoords.z, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 0.5, 255, 255, 0, 50, false, false, 2, nil, nil, false)
end)

RegisterNetEvent('na:scavengerDespawned')
AddEventHandler('na:scavengerDespawned', function(scavId)
    local scav = NA.Client.Scavengers[scavId]
    if scav then
        if DoesEntityExist(scav.entity) then DeleteEntity(scav.entity) end
        if scav.blip and DoesBlipExist(scav.blip) then RemoveBlip(scav.blip) end
        NA.Client.Scavengers[scavId] = nil
    end
end)

RegisterNetEvent('na:scavengerAttack')
AddEventHandler('na:scavengerAttack', function(scavId, targetSrc)
    NA.Client.ShowNotification('~r~A scavenger is attacking!~s~', 'error', 5000)
end)

RegisterNetEvent('na:scavengerThreaten')
AddEventHandler('na:scavengerThreaten', function(scavId)
    NA.Client.ShowNotification('~y~A scavenger is watching you...~s~', 'info', 3000)
end)

RegisterNetEvent('na:scavengerTrade')
AddEventHandler('na:scavengerTrade', function(scavId, inventory)
    local msg = '~y~Scavenger Trader~s~ offers: '
    for _, item in ipairs(inventory) do
        local def = NA.Items.GetDefinition(item.name)
        msg = msg .. (def and def.label or item.name) .. 'x' .. item.count .. ' '
    end
    NA.Client.ShowNotification(msg, 'info', 8000)
end)
