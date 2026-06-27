NA.Client.Buildings = NA.Client.Buildings or {}
NA.Client.PlacedStructures = NA.Client.PlacedStructures or {}

RegisterNetEvent('na:structurePlaced')
AddEventHandler('na:structurePlaced', function(data)
    local building = {
        id = data.id,
        type = data.type,
        coords = vector3(data.coords.x, data.coords.y, data.coords.z),
        rotation = vector3(data.rotation.x or 0, data.rotation.y or 0, data.rotation.z or 0),
        owner = data.owner,
        health = data.health,
        entity = nil,
    }

    local modelHash = GetHashKey('prop_box_wood02')
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Citizen.Wait(10) end

    building.entity = CreateObjectNoOffset(modelHash, building.coords.x, building.coords.y, building.coords.z, true, false, false)
    SetEntityHeading(building.entity, building.rotation.z)
    FreezeEntityPosition(building.entity, true)
    SetEntityInvincible(building.entity, false)
    SetEntityHealth(building.entity, data.health)

    NA.Client.PlacedStructures[data.id] = building
end)

RegisterNetEvent('na:structureRemoved')
AddEventHandler('na:structureRemoved', function(buildingId)
    local building = NA.Client.PlacedStructures[buildingId]
    if building and DoesEntityExist(building.entity) then
        DeleteEntity(building.entity)
    end
    NA.Client.PlacedStructures[buildingId] = nil
end)

RegisterNetEvent('na:structureHealthUpdate')
AddEventHandler('na:structureHealthUpdate', function(buildingId, health, maxHealth)
    local building = NA.Client.PlacedStructures[buildingId]
    if building and DoesEntityExist(building.entity) then
        SetEntityHealth(building.entity, health)
        building.health = health
    end
end)

RegisterNetEvent('na:structureCollapse')
AddEventHandler('na:structureCollapse', function(buildingId, coords, radius)
    local building = NA.Client.PlacedStructures[buildingId]

    if building and DoesEntityExist(building.entity) then
        SetEntityAsMissionEntity(building.entity, false, true)
        DeleteEntity(building.entity)
    end

    NA.Client.PlacedStructures[buildingId] = nil
    NA.Client.ShowNotification('~r~A structure has collapsed!~s~', 'error', 5000)

    ShakeGameplayCam('JOLT_SHAKE', radius / 5)

    for i = 1, math.floor(radius) do
        local offset = vector3(
            math.random(-radius, radius),
            math.random(-radius, radius),
            math.random(0, radius)
        )
        local particlePos = vector3(coords.x, coords.y, coords.z) + offset
        SetPedDesiredHeading(PlayerPedId(), GetEntityHeading(PlayerPedId()) + 45)
    end
end)

-- Building interaction
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        for id, building in pairs(NA.Client.PlacedStructures) do
            if DoesEntityExist(building.entity) then
                local dist = #(coords - GetEntityCoords(building.entity))
                if dist < 5.0 then
                    local health = GetEntityHealth(building.entity)
                    local healthPct = math.floor((health / 200) * 100)

                    if dist < 2.0 then
                        NA.Client.DrawText3D(
                            GetEntityCoords(building.entity).x,
                            GetEntityCoords(building.entity).y,
                            GetEntityCoords(building.entity).z + 1.5,
                            '~w~[E] ~g~' .. building.type .. ' ~w~(' .. healthPct .. '%)'
                        )
                        if IsControlJustPressed(0, 38) then
                            TriggerServerEvent('na:removeStructure', id)
                        end
                    else
                        DrawMarker(1, GetEntityCoords(building.entity).x, GetEntityCoords(building.entity).y, GetEntityCoords(building.entity).z + 2.0, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 255, 255, 255, 50, false, false, 2, nil, nil, false)
                    end
                end
            end
        end
    end
end)

-- Building placement preview
NA.Client.PlacementMode = false
NA.Client.PlacementType = nil
NA.Client.PlacementObject = nil

RegisterCommand('+na_build', function()
    if not NA.Client.IsLoaded then return end
    if NA.Client.PlacementMode then
        NA.Client.CancelPlacement()
        return
    end

    TriggerServerEvent('na:getCraftingRecipes')
    NA.Client.PlacementMode = true
end, false)
RegisterKeyMapping('+na_build', 'Open Build Menu', 'keyboard', 'B')

function NA.Client.CancelPlacement()
    NA.Client.PlacementMode = false
    NA.Client.PlacementType = nil
    if DoesEntityExist(NA.Client.PlacementObject) then DeleteEntity(NA.Client.PlacementObject) end
    NA.Client.PlacementObject = nil
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if NA.Client.PlacementMode and NA.Client.PlacementType then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local forward = GetEntityForwardVector(ped)
            local placePos = coords + forward * 3.0

            if NA.Client.PlacementObject then
                SetEntityCoords(NA.Client.PlacementObject, placePos.x, placePos.y, placePos.z - 1.0)
            end

            DrawMarker(1, placePos.x, placePos.y, placePos.z - 1.0, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.5, 0, 255, 0, 100, false, false, 2, nil, nil, false)

            if IsControlJustPressed(0, 38) then
                local heading = GetEntityHeading(ped)
                TriggerServerEvent('na:placeStructure', NA.Client.PlacementType, { x = placePos.x, y = placePos.y, z = placePos.z - 1.0 }, { x = 0, y = 0, z = heading })
                NA.Client.PlacementType = nil
            end
        end
    end
end)

function NA.Client.DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry('STRING')
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end
