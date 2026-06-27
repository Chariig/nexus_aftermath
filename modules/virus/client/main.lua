NA.Client.Virus = {}

RegisterNetEvent('na:infectionContract')
AddEventHandler('na:infectionContract', function(strainName)
    AnimpostfxPlay('DrugsAliensMix', 3000, true)
    ShakeGameplayCam('JOLT_SHAKE', 1.0)
    DoScreenFadeOut(500)
    Citizen.Wait(500)
    DoScreenFadeIn(500)
end)

RegisterNetEvent('na:infectionMutated')
AddEventHandler('na:infectionMutated', function(mutation)
    AnimpostfxPlay('Scanner', 3000, true)
    NA.Client.ShowNotification('~p~Your body is changing...~s~ Mutation: ' .. mutation, 'infection', 10000)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if NA.Client.Infection and NA.Client.Infection.strain then
            local level = NA.Client.Infection.level or 0
            if level >= 40 then
                if math.random() < 0.1 then
                    local shakeIntensity = (level / 100) * 2
                    ShakeGameplayCam('JOLT_SHAKE', shakeIntensity)
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000)
        if NA.Client.Infection and NA.Client.Infection.strain and NA.Client.Infection.level >= 30 then
            local strain = NA.Viruses.Strains[NA.Client.Infection.strain]
            if strain then
                local stage = NA.Viruses.GetInfectionProgress(NA.Client.Infection.level)
                local stageData = strain.stages[stage]
                if stageData then
                    NA.Client.ShowNotification('~o~Stage ' .. stage .. ': ' .. stageData.label .. '~s~', 'info')
                end
            end
        end
    end
end)
