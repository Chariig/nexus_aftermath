NA.Client.HUD = NA.Client.HUD or {}
NA.Client.HUD.ShowHUD = true

RegisterCommand('+na_hud', function()
    NA.Client.HUD.ShowHUD = not NA.Client.HUD.ShowHUD
end, false)
RegisterKeyMapping('+na_hud', 'Toggle HUD', 'keyboard', 'F7')

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if NA.Client.IsLoaded and NA.Client.HUD.ShowHUD then
            local ped = PlayerPedId()
            local health = GetEntityHealth(ped)
            local armor = GetPedArmour(ped)
            local coords = GetEntityCoords(ped)
            local street1, street2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
            local streetName = GetStreetNameFromHashKey(street1)
            local areaName = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
            local location = streetName
            if street2 ~= 0 then
                location = location .. ' / ' .. GetStreetNameFromHashKey(street2)
            end

            local inVehicle = IsPedInAnyVehicle(ped, false)
            local vehicleSpeed = 0
            local vehicleFuel = 0
            local rpm = 0
            local gear = 0

            if inVehicle then
                local vehicle = GetVehiclePedIsIn(ped, false)
                vehicleSpeed = math.floor(GetEntitySpeed(vehicle) * 3.6)
                vehicleFuel = GetVehicleFuelLevel(vehicle)
                rpm = GetVehicleCurrentRpm(vehicle)
                gear = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'nInitialDriveGears')
            end

            SendNUIMessage({
                type = 'updateHUD',
                data = {
                    health = health,
                    armor = armor,
                    hunger = NA.Client.PlayerData.hunger or 100,
                    thirst = NA.Client.PlayerData.thirst or 100,
                    infection = NA.Client.Infection,
                    tier = NA.Client.WorldData.tier or 'safe',
                    playerCount = NA.Client.WorldData.playerCount or 0,
                    location = location,
                    area = areaName,
                    inVehicle = inVehicle,
                    speed = vehicleSpeed,
                    fuel = vehicleFuel,
                    rpm = rpm,
                    gear = gear,
                    radioFreq = NA.Client.CurrentRadioFreq,
                    tethered = #NA.Client.Tethered > 0 and NA.Client.Tethered or nil,
                    skills = NA.Client.Skills,
                }
            })
        end

        Citizen.Wait(250)
    end
end)

RegisterNetEvent('na:worldEventStarted')
AddEventHandler('na:worldEventStarted', function(eventName, config, center)
    SendNUIMessage({
        type = 'worldEvent',
        event = {
            name = eventName,
            label = config.label,
            description = config.description,
            duration = config.duration,
            coords = { x = center.x, y = center.y, z = center.z },
        }
    })
end)

RegisterNetEvent('na:worldEventEnded')
AddEventHandler('na:worldEventEnded', function(eventName)
    SendNUIMessage({ type = 'worldEventEnded', event = eventName })
end)
