NA.Client.Effects = {}

local infectionThreads = {}

RegisterNetEvent('na:infectionUpdate')
AddEventHandler('na:infectionUpdate', function(infection)
    NA.Client.Infection = infection
    if infection and infection.strain and infection.level >= 20 then
        NA.Client.Effects.StartEffectThread(infection)
    else
        NA.Client.Effects.StopEffectThread()
    end
end)

function NA.Client.Effects.StartEffectThread(infection)
    if infectionThreads.active then return end
    infectionThreads.active = true

    Citizen.CreateThread(function()
        while infectionThreads.active and NA.Client.Infection and NA.Client.Infection.strain do
            local level = NA.Client.Infection.level or 0
            local strain = NA.Client.Infection.strain

            if level >= 20 then
                if math.random() < 0.05 then
                    ShakeGameplayCam('JOLT_SHAKE', (level / 100) * 0.5)
                end
            end

            if level >= 40 then
                if math.random() < 0.08 then
                    AnimpostfxPlay('DrugsAliensMix', 500, true)
                end
                local health = GetEntityHealth(PlayerPedId())
                if health > 20 then
                    SetEntityHealth(PlayerPedId(), health - (level / 100))
                end
            end

            if level >= 60 then
                if math.random() < 0.03 then
                    SetFlash(0, 0, 100, 3000, 100)
                end
                if math.random() < 0.02 then
                    local randomDir = math.random(1, 4)
                    if randomDir == 1 then SetPedDesiredHeading(PlayerPedId(), GetEntityHeading(PlayerPedId()) + 90) end
                    if randomDir == 2 then SetPedDesiredHeading(PlayerPedId(), GetEntityHeading(PlayerPedId()) - 90) end
                end
            end

            if level >= 80 then
                if math.random() < 0.1 then
                    AnimpostfxPlay('Scanner', 1000, true)
                end
                DoScreenFadeOut(100)
                Citizen.Wait(100)
                DoScreenFadeIn(100)
            end

            Citizen.Wait(3000)
        end
    end)
end

function NA.Client.Effects.StopEffectThread()
    infectionThreads.active = false
    AnimpostfxStopAll()
    StopGameplayCamShaking(true)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000)
        if NA.Client.Infection and NA.Client.Infection.strain and NA.Client.Infection.level > 0 then
            local coords = GetEntityCoords(PlayerPedId())
            TriggerServerEvent('na:virus:checkAirborne', { x = coords.x, y = coords.y, z = coords.z })
        end
    end
end)

-- Radiation effects
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if NA.Client.WorldData and NA.Client.WorldData.radiationZones then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local radiation = 0

            for _, zone in ipairs(NA.Client.WorldData.radiationZones) do
                local dist = #(coords - vector3(zone.coords.x, zone.coords.y, zone.coords.z))
                if dist <= zone.radius then
                    local falloff = 1 - (dist / zone.radius)
                    radiation = math.max(radiation, zone.intensity * falloff)
                end
            end

            if radiation > 0.2 then
                local health = GetEntityHealth(ped)
                if health > 10 then
                    SetEntityHealth(ped, health - (radiation * 2))
                end
                if math.random() < 0.3 then
                    SetFlash(0, 0, 100, 2000, 100)
                end
                local alpha = math.floor(radiation * 150)
                SetPlayerWeaponDefenseModifier(PlayerId(), 1.0 - (radiation * 0.5))

                if radiation > 0.6 then
                    NA.Client.ShowNotification('~r~High radiation detected!~s~', 'error', 4000)
                end
            end
        end
    end
end)

-- Safe zone effects
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)
        if NA.Client.Config and NA.Client.Config.safeZones then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local inSafeZone = false

            for _, zone in ipairs(NA.Client.Config.safeZones) do
                local dist = #(coords - zone.coords)
                if dist <= zone.radius then
                    inSafeZone = true
                    break
                end
            end

            if inSafeZone and not NA.Client.InSafeZone then
                NA.Client.InSafeZone = true
                NA.Client.ShowNotification('~g~Entering Safe Zone~s~', 'success')
                SetEntityHealth(ped, math.min(GetEntityHealth(ped) + 10, 200))
            elseif not inSafeZone and NA.Client.InSafeZone then
                NA.Client.InSafeZone = false
                NA.Client.ShowNotification('~y~Leaving Safe Zone - Stay safe~s~', 'info')
            end
        end
    end
end)
