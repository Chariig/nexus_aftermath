NA.Client = NA.Client or {}
NA.Client.PlayerData = NA.Client.PlayerData or {}
NA.Client.WorldData = NA.Client.WorldData or {}
NA.Client.Infection = NA.Client.Infection or {}
NA.Client.Tethered = NA.Client.Tethered or {}
NA.Client.CurrentRadioFreq = NexusAftermath.Config.radio.defaultFreq
NA.Client.InventoryOpen = false
NA.Client.CraftingOpen = false
NA.Client.RadioOpen = false
NA.Client.IsLoaded = false

RegisterNetEvent('na:worldSync')
AddEventHandler('na:worldSync', function(data)
    NA.Client.WorldData = data
end)

RegisterNetEvent('na:worldTierChanged')
AddEventHandler('na:worldTierChanged', function(tier, config)
    NA.Client.WorldData.tier = tier
    if config then
        SetClockTime(12, 0, 0)
    end
end)

RegisterNetEvent('na:notification')
AddEventHandler('na:notification', function(data)
    NA.Client.ShowNotification(data.message, data.type, data.length)
end)

RegisterNetEvent('na:advancedNotif')
AddEventHandler('na:advancedNotif', function(data)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(data.text)
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterNetEvent('na:updateHealth')
AddEventHandler('na:updateHealth', function(health)
    NA.Client.PlayerData.health = health
    SetEntityHealth(PlayerPedId(), health)
end)

RegisterNetEvent('na:updateHunger')
AddEventHandler('na:updateHunger', function(hunger)
    NA.Client.PlayerData.hunger = hunger
end)

RegisterNetEvent('na:updateThirst')
AddEventHandler('na:updateThirst', function(thirst)
    NA.Client.PlayerData.thirst = thirst
end)

RegisterNetEvent('na:skillUp')
AddEventHandler('na:skillUp', function(skill, newLevel, gained)
    NA.Client.Skills[skill] = newLevel
    NA.Client.ShowNotification('~g~' .. skill:upper() .. '~s~ +' .. gained .. ' (Level: ' .. newLevel .. ')', 'success')
end)

RegisterNetEvent('na:updateInventory')
AddEventHandler('na:updateInventory', function(data)
    NA.Client.PlayerData.inventory = data.inventory
    if NA.Client.InventoryOpen then
        SendNUIMessage({ type = 'updateInventory', inventory = data.inventory })
    end
end)

RegisterNetEvent('na:openInventory')
AddEventHandler('na:openInventory', function(data)
    NA.Client.InventoryOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'openInventory',
        inventory = data.inventory,
        maxWeight = data.maxWeight,
        maxSlots = data.maxSlots,
        items = data.items,
    })
end)

function NA.Client.SetupKeybinds()
    RegisterCommand('+na_inventory', function()
        if not NA.Client.IsLoaded then return end
        if NA.Client.InventoryOpen then
            NA.Client.CloseInventory()
        else
            TriggerServerEvent('na:getInventory')
        end
    end, false)
    RegisterKeyMapping('+na_inventory', 'Open Inventory', 'keyboard', 'TAB')

    RegisterCommand('+na_radio', function()
        if not NA.Client.IsLoaded or NA.Client.RadioOpen then return end
        NA.Client.OpenRadio()
    end, false)
    RegisterKeyMapping('+na_radio', 'Open Radio', 'keyboard', 'R')

    RegisterCommand('+na_crafting', function()
        if not NA.Client.IsLoaded or NA.Client.CraftingOpen then return end
        TriggerServerEvent('na:getCraftingRecipes')
    end, false)
    RegisterKeyMapping('+na_crafting', 'Open Crafting', 'keyboard', 'C')

    RegisterCommand('+na_echo', function()
        if not NA.Client.IsLoaded then return end
        local coords = GetEntityCoords(PlayerPedId())
        TriggerServerEvent('na:getNearbyEchoes', { x = coords.x, y = coords.y, z = coords.z })
    end, false)
    RegisterKeyMapping('+na_echo', 'Scan for Echoes', 'keyboard', 'E')
end

function NA.Client.ShowNotification(message, type, length)
    type = type or 'info'
    length = length or 4000
    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(0, 1)
end

function NA.Client.CloseInventory()
    NA.Client.InventoryOpen = false
    NA.Client.CraftingOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = 'closeInventory' })
end

RegisterNUICallback('closeInventory', function()
    NA.Client.CloseInventory()
end)

RegisterNUICallback('useItem', function(data)
    TriggerServerEvent('na:useItem', data.itemName, data.slot)
end)

RegisterNUICallback('dropItem', function(data)
    TriggerServerEvent('na:dropItem', data.slot, data.count or 1)
end)

RegisterNUICallback('swapItem', function(data)
    TriggerServerEvent('na:swapItems', data.slot1, data.slot2)
end)

-- Crafting callbacks
RegisterNetEvent('na:craftingRecipes')
AddEventHandler('na:craftingRecipes', function(recipes, skills)
    NA.Client.CraftingOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'openCrafting',
        recipes = recipes,
        skills = skills,
    })
end)

RegisterNUICallback('craftItem', function(data)
    TriggerServerEvent('na:craftItem', data.recipeName)
end)

-- Radio UI
function NA.Client.OpenRadio()
    NA.Client.RadioOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'openRadio',
        frequency = NA.Client.CurrentRadioFreq,
    })
end

RegisterNUICallback('setRadioFreq', function(data)
    NA.Client.CurrentRadioFreq = tonumber(data.frequency)
    TriggerServerEvent('na:radioSetFreq', NA.Client.CurrentRadioFreq)
end)

RegisterNUICallback('radioTransmit', function(data)
    TriggerServerEvent('na:radioTransmit', data.message, NA.Client.CurrentRadioFreq, data.encrypted or false)
end)

RegisterNUICallback('closeRadio', function()
    NA.Client.RadioOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = 'closeRadio' })
end)

RegisterNetEvent('na:radioReceive')
AddEventHandler('na:radioReceive', function(transmission)
    local msg = '[#' .. math.floor(transmission.frequency) .. ' MHz] ' .. transmission.playerName .. ': ' .. transmission.message
    NA.Client.ShowNotification(msg, 'radio', 6000)
    if NA.Client.RadioOpen then
        SendNUIMessage({ type = 'radioMessage', transmission = transmission })
    end
end)

RegisterNetEvent('na:radioTransmitConfirm')
AddEventHandler('na:radioTransmitConfirm', function(recipients)
    if recipients > 0 then
        NA.Client.ShowNotification('Transmitted to ' .. recipients .. ' listener(s)', 'success')
    else
        NA.Client.ShowNotification('No one on this frequency', 'info')
    end
end)

-- Infection effects
RegisterNetEvent('na:infectionUpdate')
AddEventHandler('na:infectionUpdate', function(infection)
    NA.Client.Infection = infection
    if infection.strain and infection.level >= 40 then
        NA.Client.StartInfectionEffects(infection)
    else
        NA.Client.StopInfectionEffects()
    end
end)

RegisterNetEvent('na:infectionContract')
AddEventHandler('na:infectionContract', function(strainName)
    local strain = NA.Viruses.Strains[strainName]
    if strain then
        NA.Client.ShowNotification('~r~CONTRACTED:~s~ ' .. strain.label .. ' - ' .. strain.description, 'infection', 10000)
    end
    SetFlash(0, 0, 500, 7000, 500)
end)

RegisterNetEvent('na:infectionMutated')
AddEventHandler('na:infectionMutated', function(mutation)
    NA.Client.ShowNotification('~p~Your infection has mutated: ' .. mutation, 'infection', 8000)
    AnimpostfxPlay('Scanner', 3000, true)
end)

function NA.Client.StartInfectionEffects(infection)
    local strain = NA.Viruses.Strains[infection.strain]
    if not strain then return end

    local stage = NA.Viruses.GetInfectionProgress(infection.level)
    local effects = strain.stages[stage] and strain.stages[stage].effects or {}

    for _, effect in ipairs(effects) do
        if effect.type == 'screen_glitch' then
            if not NA.Client.GlitchActive then
                NA.Client.GlitchActive = true
                Citizen.CreateThread(function()
                    while NA.Client.GlitchActive and NA.Client.Infection.strain do
                        if GetRandomFloatInRange(0, 1) < effect.severity * 0.3 then
                            AnimpostfxPlay('DrugsAliensMix', 500, true)
                        end
                        Citizen.Wait(2000)
                    end
                end)
            end
        elseif effect.type == 'health_decay' then
            NA.Client.HealthDecay = effect.severity
            Citizen.CreateThread(function()
                while NA.Client.HealthDecay and NA.Client.Infection.strain do
                    local health = GetEntityHealth(PlayerPedId())
                    SetEntityHealth(PlayerPedId(), health - NA.Client.HealthDecay)
                    Citizen.Wait(10000)
                end
            end)
        elseif effect.type == 'vision_obscured' then
            NA.Client.VisionObscured = effect.severity
        elseif effect.type == 'screen_grayscale' then
            AnimpostfxPlay('BoatHeist', 1000, true)
        end
    end
end

function NA.Client.StopInfectionEffects()
    NA.Client.GlitchActive = false
    NA.Client.HealthDecay = nil
    NA.Client.VisionObscured = nil
    AnimpostfxStopAll()
end

-- Tethered visual
RegisterNetEvent('na:tetherCreated')
AddEventHandler('na:tetherCreated', function(targetSrc)
    table.insert(NA.Client.Tethered, targetSrc)
    NA.Client.ShowNotification('You are now tethered', 'success')
end)

RegisterNetEvent('na:tetherBroken')
AddEventHandler('na:tetherBroken', function(targetSrc)
    for i, t in ipairs(NA.Client.Tethered) do
        if t == targetSrc then table.remove(NA.Client.Tethered, i); break end
    end
    NA.Client.ShowNotification('Tether broken', 'info')
end)

-- Echo system
RegisterNetEvent('na:nearbyEchoes')
AddEventHandler('na:nearbyEchoes', function(echoes)
    if #echoes == 0 then
        NA.Client.ShowNotification('No echoes nearby', 'info')
        return
    end
    NA.Client.NearbyEchoes = echoes
    for _, echo in ipairs(echoes) do
        local dist = math.floor(echo.distance)
        NA.Client.ShowNotification('Echo found: ' .. echo.eventType .. ' (' .. dist .. 'm away)', 'echo', 5000)
    end
end)

RegisterNetEvent('na:echoPlayback')
AddEventHandler('na:echoPlayback', function(echo)
    NA.Client.ShowNotification('~b~Echo Playback:~s~ ' .. (echo.eventType or echo.event_type), 'info', 8000)
    if echo.recording then
        local rec = echo.recording
        if rec.type == 'death' then
            NA.Client.ShowNotification('~r~Death Echo:~s~ ' .. (rec.playerName or 'Unknown') .. ' fell here', 'echo', 6000)
        else
            NA.Client.ShowNotification('~b~Memory fragment from a fallen survivor~s~', 'echo', 4000)
        end
    end
end)

-- World item spawning
RegisterNetEvent('na:spawnWorldItem')
AddEventHandler('na:spawnWorldItem', function(itemName, count, x, y, z)
    local modelHash = GetHashKey('prop_cs_cardbox_01')
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(10)
    end

    local obj = CreateObject(modelHash, x, y, z, true, false, false)
    SetEntityAsMissionEntity(obj, true, true)
    FreezeEntityPosition(obj, true)
    PlaceObjectOnGroundProperly(obj)

    NA.Client.WorldItems = NA.Client.WorldItems or {}
    table.insert(NA.Client.WorldItems, { obj = obj, item = itemName, count = count, coords = { x = x, y = y, z = z } })

    local pickupRange = 2.0
    Citizen.CreateThread(function()
        while DoesEntityExist(obj) do
            Citizen.Wait(500)
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local dist = #(pos - vector3(x, y, z))
            if dist < pickupRange then
                NA.Client.ShowNotification('Press ~INPUT_CONTEXT~ to pick up ' .. (NA.Items.Definitions[itemName] or {}).label or itemName, 'info')
                if IsControlJustPressed(0, 38) then
                    TriggerServerEvent('na:addItem', itemName, count)
                    DeleteEntity(obj)
                    break
                end
            end
        end
    end)
end)

-- 3D text for structures
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if NA.Client.NearbyEchoes then
            for _, echo in ipairs(NA.Client.NearbyEchoes) do
                local dist = #(GetEntityCoords(PlayerPedId()) - vector3(echo.coords.x, echo.coords.y, echo.coords.z))
                if dist < 50 then
                    local alpha = 255 - (dist * 5)
                    if alpha > 0 then
                        DrawMarker(28, echo.coords.x, echo.coords.y, echo.coords.z + 1.5, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 100, 200, 255, alpha, false, false, 2, nil, nil, false)
                    end
                end
            end
        end

        if NA.Client.VisionObscured then
            DrawRect(0.5, 0.5, 1.0, 1.0, 0, 0, 0, math.floor(NA.Client.VisionObscured * 100))
        end

        Citizen.Wait(0)
    end
end)

-- Hunger/Thirst decay
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(120000)
        if NA.Client.PlayerData then
            NA.Client.PlayerData.hunger = math.max(0, (NA.Client.PlayerData.hunger or 100) - 2)
            NA.Client.PlayerData.thirst = math.max(0, (NA.Client.PlayerData.thirst or 100) - 3)
            if NA.Client.PlayerData.hunger == 0 or NA.Client.PlayerData.thirst == 0 then
                local health = GetEntityHealth(PlayerPedId())
                SetEntityHealth(PlayerPedId(), health - 5)
            end
        end
    end
end)

-- Sync with server
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if NA.Client.IsLoaded then
            TriggerServerEvent('na:playerHeartbeat')
        end
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(100)
    NA.Client.Spawn.Init()
end)
