NA.Server.Virus = {}

RegisterNetEvent('na:checkInfection')
AddEventHandler('na:checkInfection', function()
    local src = source
    local player = NA.GetPlayer(src)
    if not player then return end
    TriggerClientEvent('na:infectionUpdate', src, player.infection)
end)

RegisterNetEvent('na:infectPlayer')
AddEventHandler('na:infectPlayer', function(strainName)
    local src = source
    local player = NA.GetPlayer(src)
    if not player then return end

    local strain = NA.Viruses.Strains[strainName]
    if not strain then return end

    if player.infection.strain then
        NA.ShowNotification(src, 'You are already infected with ' .. (NA.Viruses.Strains[player.infection.strain] or {}).label or 'unknown', 'error')
        return
    end

    player.infection.strain = strainName
    player.infection.level = 5
    player.infection.mutations = {}
    player.infection.mutated = false

    TriggerClientEvent('na:infectionUpdate', src, player.infection)
    TriggerClientEvent('na:infectionContract', src, strainName)
    NA.ShowNotification(src, 'You feel something wrong... very wrong.', 'infection', 8000)
    NA.Log(src, 'infected', { strain = strainName })
end)

RegisterNetEvent('na:cureInfection')
AddEventHandler('na:cureInfection', function()
    local src = source
    local player = NA.GetPlayer(src)
    if not player then return end

    if not player.infection.strain then
        NA.ShowNotification(src, 'You are not infected', 'error')
        return
    end

    local strain = NA.Viruses.Strains[player.infection.strain]
    local cureItem = nil
    local cureEffectiveness = 0

    for _, invItem in ipairs(player.charData.inventory or {}) do
        if strain and strain.cures then
            for _, cure in ipairs(strain.cures) do
                local itemDef = NA.Items.GetDefinition(cure.name)
                if itemDef and invItem.name == cure.name then
                    cureItem = cure
                    cureEffectiveness = cure.effectiveness
                    break
                end
            end
        end
        if cureItem then break end
    end

    if not cureItem then
        NA.ShowNotification(src, 'You need a cure for this strain', 'error')
        return
    end

    player.infection.level = NA.Clamp(player.infection.level - (100 * cureEffectiveness), 0, 100)

    if player.infection.level == 0 then
        player.infection.strain = nil
        player.infection.mutations = {}
        player.infection.mutated = false
        NA.ShowNotification(src, 'You have been cured!', 'success', 6000)
        NA.Log(src, 'cured', { strain = strain })
    else
        NA.ShowNotification(src, 'Infection reduced by ' .. math.floor(cureEffectiveness * 100) .. '%', 'info')
    end

    for i, invItem in ipairs(player.charData.inventory or {}) do
        if invItem.name == cureItem.name then
            invItem.count = invItem.count - 1
            if invItem.count <= 0 then table.remove(player.charData.inventory, i) end
            break
        end
    end

    TriggerClientEvent('na:infectionUpdate', src, player.infection)
    TriggerClientEvent('na:updateInventory', src, { inventory = player.charData.inventory })
end)

RegisterNetEvent('na:transmitInfection')
AddEventHandler('na:transmitInfection', function(targetSrc)
    local src = source
    local player = NA.GetPlayer(src)
    local target = NA.GetPlayer(targetSrc)
    if not player or not target then return end
    if not player.infection.strain then return end
    if target.infection.strain then return end

    local strain = NA.Viruses.Strains[player.infection.strain]
    if not strain then return end

    local method = 'blood'
    local chance = NA.Viruses.GetTransmissionChance(player.infection.strain, method)
    local stageMult = (player.infection.level / 100) * 1.5
    chance = chance * stageMult

    if math.random() < chance then
        target.infection.strain = player.infection.strain
        target.infection.level = player.infection.level * 0.3
        target.infection.mutations = {}
        target.infection.mutated = false

        TriggerClientEvent('na:infectionUpdate', targetSrc, target.infection)
        TriggerClientEvent('na:infectionContract', targetSrc, player.infection.strain)
        NA.ShowNotification(targetSrc, 'You feel a contamination...', 'infection', 6000)
        NA.Log(src, 'infection_transmitted', { from = player.charData.citizenId, to = target.charData.citizenId })
    end
end)

NA.RegisterNetEvent('virus:checkAirborne', function(coords)
    local src = source
    local player = NA.GetPlayer(src)
    if not player or not player.infection.strain then return end

    local strain = NA.Viruses.Strains[player.infection.strain]
    if not strain then return end

    local airborneChance = NA.Viruses.GetTransmissionChance(player.infection.strain, 'airborne')
    if airborneChance <= 0 then return end

    local nearby = NA.GetPlayersInRange(coords, 10.0)
    for nearSrc, nearData in pairs(nearby) do
        if nearSrc ~= src then
            local nearPlayer = nearData.player
            if nearPlayer and not nearPlayer.infection.strain then
                local infectChance = airborneChance * (player.infection.level / 100) * 0.1
                if math.random() < infectChance then
                    nearPlayer.infection.strain = player.infection.strain
                    nearPlayer.infection.level = 2
                    nearPlayer.infection.mutations = {}
                    nearPlayer.infection.mutated = false
                    TriggerClientEvent('na:infectionUpdate', nearSrc, nearPlayer.infection)
                    TriggerClientEvent('na:infectionContract', nearSrc, player.infection.strain)
                    NA.ShowNotification(nearSrc, 'You inhaled something foul...', 'infection', 6000)
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(30000)
        for src, player in pairs(NA.Players) do
            if player.infection and player.infection.strain then
                local radiation = 0
                local ped = GetPlayerPed(src)
                if ped then
                    local coords = GetEntityCoords(ped)
                    radiation = NA.World.GetRadiationAt({ x = coords.x, y = coords.y, z = coords.z })
                end
                if radiation > 0.3 then
                    player.infection.level = NA.Clamp((player.infection.level or 0) + radiation * 0.5, 0, 100)
                    TriggerClientEvent('na:infectionUpdate', src, player.infection)
                end

                -- Check if in safe zone (infection reduces)
                local inSafeZone = false
                for _, zone in ipairs(NexusAftermath.Config.safeZones) do
                    local ped = GetPlayerPed(src)
                    if ped then
                        local coords = GetEntityCoords(ped)
                        local dist = NA.Distance({ x = coords.x, y = coords.y, z = coords.z }, { x = zone.coords.x, y = zone.coords.y, z = zone.coords.z })
                        if dist <= zone.radius then
                            inSafeZone = true
                            break
                        end
                    end
                end
                if inSafeZone then
                    player.infection.level = NA.Clamp((player.infection.level or 0) - 0.5, 0, 100)
                    if player.infection.level <= 0 then
                        player.infection.strain = nil
                        player.infection.level = 0
                        player.infection.mutations = {}
                        player.infection.mutated = false
                        NA.ShowNotification(src, 'The safe zone has purged your infection.', 'success', 5000)
                    end
                    TriggerClientEvent('na:infectionUpdate', src, player.infection)
                end
            end
        end
    end
end)

function NA.Server.Virus.InfectRandomPlayer()
    local online = NA.GetOnlinePlayers()
    if #online == 0 then return end
    local src = online[math.random(#online)]
    local player = NA.Players[src]
    if not player or player.infection.strain then return end
    local strains = { 'the_glitch', 'the_spore', 'the_hollow', 'the_void' }
    local strain = strains[math.random(#strains)]
    if strain == 'the_void' and math.random() > 0.2 then
        strain = 'the_glitch'
    end
    player.infection.strain = strain
    player.infection.level = 10
    TriggerClientEvent('na:infectionUpdate', src, player.infection)
    TriggerClientEvent('na:infectionContract', src, strain)
    NA.ShowNotification(src, 'You feel a presence entering your mind...', 'infection', 8000)
    NA.Log(src, 'randomly_infected', { strain = strain })
end

exports('InfectPlayer', function(src, strain) TriggerEvent('na:infectPlayer', src, { strain }) end)
exports('CurePlayer', function(src) TriggerEvent('na:cureInfection', src) end)
exports('GetInfection', function(src)
    local player = NA.GetPlayer(src)
    if not player then return nil end
    return player.infection
end)
