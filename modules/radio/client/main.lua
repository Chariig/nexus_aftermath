NA.Client.Radio = {}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if NA.Client.CurrentRadioFreq and NA.Client.CurrentRadioFreq ~= 0 then
            if math.random() < 0.05 then
                local staticIntensity = math.random()
                if staticIntensity > 0.7 then
                    -- Subtle radio static indicator
                end
            end
        end
    end
end)

RegisterNetEvent('na:radioReceive')
AddEventHandler('na:radioReceive', function(transmission)
    if transmission.jammed then
        NA.Client.ShowNotification('~r~JAMMED~s~ Signal interference on ' .. math.floor(transmission.frequency) .. ' MHz', 'error')
        return
    end

    local signalStrength = 'weak'
    local dist = #(GetEntityCoords(PlayerPedId()) - vector3(transmission.coords.x, transmission.coords.y, transmission.coords.z))
    local ratio = dist / transmission.range
    if ratio < 0.3 then
        signalStrength = 'strong'
    elseif ratio < 0.6 then
        signalStrength = 'moderate'
    end

    local prefix = ''
    if transmission.encrypted then prefix = '~y~[ENCRYPTED]~s~ ' end

    NA.Client.ShowNotification(prefix .. '~w~[' .. math.floor(transmission.frequency) .. ' MHz]~s~ ' .. transmission.playerName .. ': ' .. transmission.message, 'radio', 6000 + (#transmission.message * 50))
end)

RegisterNetEvent('na:radioScanResult')
AddEventHandler('na:radioScanResult', function(frequencies)
    if #frequencies == 0 then
        NA.Client.ShowNotification('No active frequencies detected', 'info')
        return
    end
    local msg = '~g~Active frequencies:~s~ '
    for i, freq in ipairs(frequencies) do
        msg = msg .. math.floor(freq) .. ' MHz'
        if i < #frequencies then msg = msg .. ', ' end
    end
    NA.Client.ShowNotification(msg, 'info', 8000)
end)
