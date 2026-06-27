NA.Server.Radio = {}

NA.Server.Radio.ActiveTransmissions = {}
NA.Server.Radio.FrequencyHistory = {}

RegisterNetEvent('na:radioTransmit')
AddEventHandler('na:radioTransmit', function(message, frequency, isEncrypted)
    local src = source
    local player = NA.GetPlayer(src)
    if not player then return end

    frequency = frequency or player.radioFreq or NexusAftermath.Config.radio.defaultFreq
    frequency = tonumber(frequency)

    if not frequency or frequency < NexusAftermath.Config.radio.minFreq or frequency > NexusAftermath.Config.radio.maxFreq then
        NA.ShowNotification(src, 'Invalid frequency', 'error')
        return
    end

    local coords = GetEntityCoords(GetPlayerPed(src))

    -- Range calculation with amplifier check
    local hasAmp = NA.Server.Inventory.HasItem(src, 'radio_transmitter', 1)
    local baseRange = NexusAftermath.Config.radio.baseRange
    if hasAmp then baseRange = baseRange * NexusAftermath.Config.radio.ampRangeMult end

    -- Terrain and weather affect signal
    local tierCfg = NA.World.GetTierConfig(NA.Server.WorldTier)
    local interference = 1.0
    if NA.Server.WorldTier == 'critical' or NA.Server.WorldTier == 'collapse' then
        interference = 0.6
    end

    local range = baseRange * interference

    -- Check for jammers
    local jammed = false
    for _, jammer in pairs(NA.Server.Radio.ActiveTransmissions) do
        if jammer.type == 'jammer' and jammer.freq == frequency then
            local jamDist = NA.Distance({ x = coords.x, y = coords.y, z = coords.z }, jammer.coords)
            if jamDist <= jammer.range then
                jammed = true
                break
            end
        end
    end

    local transmission = {
        source = src,
        frequency = frequency,
        message = message,
        coords = { x = coords.x, y = coords.y, z = coords.z },
        range = range,
        timestamp = os.time(),
        encrypted = isEncrypted or false,
        jammed = jammed,
        playerName = player.charData.name,
    }

    if jammed then
        NA.ShowNotification(src, 'Your transmission was jammed!', 'error')
        return
    end

    table.insert(NA.Server.Radio.FrequencyHistory, {
        freq = frequency,
        count = (NA.Server.Radio.FrequencyHistory[frequency] or 0) + 1,
        lastUsed = os.time(),
    })

    -- Send to players within range who are on this frequency
    local recipients = 0
    for tgtSrc, tgtPlayer in pairs(NA.Players) do
        if tgtSrc ~= src then
            local tgtCoords = GetEntityCoords(GetPlayerPed(tgtSrc))
            local tgtFreq = tgtPlayer.radioFreq or NexusAftermath.Config.radio.defaultFreq

            if math.abs(tgtFreq - frequency) < 0.5 then
                local dist = NA.Distance({ x = coords.x, y = coords.y, z = coords.z }, { x = tgtCoords.x, y = tgtCoords.y, y = tgtCoords.z })
                local hasScanner = NA.Server.Inventory.HasItem(tgtSrc, 'radio_scanner', 1)
                local effectiveRange = range
                if hasScanner then effectiveRange = effectiveRange * 1.5 end
                if dist <= effectiveRange then
                    TriggerClientEvent('na:radioReceive', tgtSrc, transmission)
                    recipients = recipients + 1
                end
            end
        end
    end

    TriggerClientEvent('na:radioTransmitConfirm', src, recipients)
    NA.Log(src, 'radio_transmit', { freq = frequency, recipients = recipients, message = message })
end)

RegisterNetEvent('na:radioSetFreq')
AddEventHandler('na:radioSetFreq', function(frequency)
    local src = source
    local player = NA.GetPlayer(src)
    if not player then return end

    frequency = tonumber(frequency)
    if not frequency or frequency < NexusAftermath.Config.radio.minFreq or frequency > NexusAftermath.Config.radio.maxFreq then
        NA.ShowNotification(src, 'Frequency must be between ' .. NexusAftermath.Config.radio.minFreq .. ' and ' .. NexusAftermath.Config.radio.maxFreq, 'error')
        return
    end

    player.radioFreq = frequency
    NA.ShowNotification(src, 'Radio set to ' .. frequency .. ' MHz', 'info')
end)

RegisterNetEvent('na:radioJam')
AddEventHandler('na:radioJam', function(frequency)
    local src = source
    local player = NA.GetPlayer(src)
    if not player then return end
    if not NexusAftermath.Config.radio.jammingEnabled then
        NA.ShowNotification(src, 'Jamming is not enabled on this server', 'error')
        return
    end

    local hasJammer = NA.Server.Inventory.HasItem(src, 'radio_scanner', 1)
    if not hasJammer then
        NA.ShowNotification(src, 'You need a radio scanner to jam signals', 'error')
        return
    end

    local coords = GetEntityCoords(GetPlayerPed(src))
    NA.Server.Radio.ActiveTransmissions[src] = {
        type = 'jammer',
        freq = tonumber(frequency),
        coords = { x = coords.x, y = coords.y, z = coords.z },
        range = 100.0,
        startedAt = os.time(),
    }

    NA.ShowNotification(src, 'Jamming frequency ' .. frequency .. ' MHz', 'success', 5000)
    NA.Log(src, 'radio_jam_start', { freq = frequency })
end)

RegisterNetEvent('na:radioStopJam')
AddEventHandler('na:radioStopJam', function()
    local src = source
    NA.Server.Radio.ActiveTransmissions[src] = nil
    NA.ShowNotification(src, 'Jamming stopped', 'info')
end)

RegisterNetEvent('na:radioScan')
AddEventHandler('na:radioScan', function()
    local src = source
    local player = NA.GetPlayer(src)
    if not player then return end

    local hasScanner = NA.Server.Inventory.HasItem(src, 'radio_scanner', 1)
    if not hasScanner then
        NA.ShowNotification(src, 'You need a radio scanner', 'error')
        return
    end

    local activeFreqs = {}
    for _, history in pairs(NA.Server.Radio.FrequencyHistory) do
        if os.time() - history.lastUsed < 300 then
            activeFreqs[#activeFreqs+1] = history.freq
        end
    end

    TriggerClientEvent('na:radioScanResult', src, activeFreqs)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        local toRemove = {}
        for src, jammer in pairs(NA.Server.Radio.ActiveTransmissions) do
            if os.time() - jammer.startedAt > 120 then
                table.insert(toRemove, src)
            end
        end
        for _, src in ipairs(toRemove) do
            NA.Server.Radio.ActiveTransmissions[src] = nil
            local player = NA.Players[src]
            if player then
                NA.ShowNotification(src, 'Your jammer has run out of power', 'info')
            end
        end
    end
end)

exports('GetActiveFrequencies', function() return NA.Server.Radio.FrequencyHistory end)
exports('GetActiveTransmissions', function() return NA.Server.Radio.ActiveTransmissions end)
