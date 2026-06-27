NA.Server.Factions = NA.Server.Factions or {}

RegisterNetEvent('na:createFaction')
AddEventHandler('na:createFaction', function(name, tag, color)
    local src = source
    local player = NA.GetPlayer(src)
    if not player then return end

    if not name or not tag then
        NA.ShowNotification(src, 'Name and tag required', 'error')
        return
    end

    if string.len(tag) > 5 then
        NA.ShowNotification(src, 'Tag must be 5 characters or less', 'error')
        return
    end

    local existing = MySQL.query.await('SELECT id FROM na_factions WHERE name = ? OR tag = ?', { name, tag })
    if existing and #existing > 0 then
        NA.ShowNotification(src, 'Faction name or tag already exists', 'error')
        return
    end

    local faction = {
        name = name,
        tag = tag,
        owner = player.charData.citizenId,
        members = { { citizenId = player.charData.citizenId, name = player.charData.name, rank = 'leader' } },
        reputation = {},
        territory = {},
        color = color or '#FFFFFF',
        createdAt = os.time(),
    }

    local success = MySQL.insert.await('INSERT INTO na_factions (name, tag, owner_citizenId, members, reputation, territory, color) VALUES (?, ?, ?, ?, ?, ?, ?)',
        { name, tag, player.charData.citizenId, NA.SerializeForDb(faction.members), '{}', '{}', faction.color })

    if success then
        faction.id = success
        NA.Server.Factions[success] = faction
        NA.ShowNotification(src, 'Faction ' .. name .. ' created', 'success')
        NA.Log(src, 'faction_created', { faction = name, tag = tag })
    end
end)

RegisterNetEvent('na:inviteToFaction')
AddEventHandler('na:inviteToFaction', function(factionId, targetSrc)
    local src = source
    local player = NA.GetPlayer(src)
    local target = NA.GetPlayer(targetSrc)
    if not player or not target then return end

    local faction = NA.Server.Factions[factionId]
    if not faction then
        NA.ShowNotification(src, 'Faction not found', 'error')
        return
    end

    if faction.owner ~= player.charData.citizenId then
        NA.ShowNotification(src, 'Only the faction owner can invite', 'error')
        return
    end

    NA.ShowNotification(targetSrc, 'You have been invited to ' .. faction.name .. ' by ' .. player.charData.name .. '. Press ~INPUT_CONTEXT~ to join.', 'info', 15000)
    TriggerClientEvent('na:factionInvite', targetSrc, factionId, faction.name, src)
end)

RegisterNetEvent('na:joinFaction')
AddEventHandler('na:joinFaction', function(factionId)
    local src = source
    local player = NA.GetPlayer(src)
    if not player then return end

    local faction = NA.Server.Factions[factionId]
    if not faction then
        NA.ShowNotification(src, 'Faction no longer exists', 'error')
        return
    end

    table.insert(faction.members, { citizenId = player.charData.citizenId, name = player.charData.name, rank = 'member' })
    MySQL.update('UPDATE na_factions SET members = ? WHERE id = ?', { NA.SerializeForDb(faction.members), factionId })

    NA.ShowNotification(src, 'You joined ' .. faction.name, 'success')
    NA.Log(src, 'faction_joined', { faction = faction.name })
end)

RegisterNetEvent('na:leaveFaction')
AddEventHandler('na:leaveFaction', function(factionId)
    local src = source
    local player = NA.GetPlayer(src)
    if not player then return end

    local faction = NA.Server.Factions[factionId]
    if not faction then return end

    if faction.owner == player.charData.citizenId then
        NA.ShowNotification(src, 'Transfer ownership before leaving', 'error')
        return
    end

    for i, member in ipairs(faction.members) do
        if member.citizenId == player.charData.citizenId then
            table.remove(faction.members, i)
            break
        end
    end

    MySQL.update('UPDATE na_factions SET members = ? WHERE id = ?', { NA.SerializeForDb(faction.members), factionId })
    NA.ShowNotification(src, 'You left ' .. faction.name, 'info')
end)

RegisterNetEvent('na:getFactions')
AddEventHandler('na:getFactions', function()
    local src = source
    local factionsList = {}
    for id, faction in pairs(NA.Server.Factions) do
        factionsList[#factionsList+1] = {
            id = id,
            name = faction.name,
            tag = faction.tag,
            memberCount = #faction.members,
            color = faction.color,
        }
    end
    TriggerClientEvent('na:factionsList', src, factionsList)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000)
        local factions = MySQL.query.await('SELECT * FROM na_factions')
        if factions then
            for _, row in ipairs(factions) do
                if not NA.Server.Factions[row.id] then
                    NA.Server.Factions[row.id] = {
                        id = row.id,
                        name = row.name,
                        tag = row.tag,
                        owner = row.owner_citizenId,
                        members = NA.DeserializeFromDb(row.members),
                        reputation = NA.DeserializeFromDb(row.reputation),
                        territory = NA.DeserializeFromDb(row.territory),
                        color = row.color,
                        createdAt = row.created_at,
                    }
                end
            end
        end
    end
end)

function NA.Server.Factions.GetPlayerFaction(citizenId)
    for id, faction in pairs(NA.Server.Factions) do
        for _, member in ipairs(faction.members) do
            if member.citizenId == citizenId then
                return id, faction, member.rank
            end
        end
    end
    return nil, nil, nil
end

function NA.Server.Factions.ModifyReputation(factionId, target, amount)
    local faction = NA.Server.Factions[factionId]
    if not faction then return end
    faction.reputation[target] = (faction.reputation[target] or 0) + amount
    MySQL.update('UPDATE na_factions SET reputation = ? WHERE id = ?', { NA.SerializeForDb(faction.reputation), factionId })
end

exports('GetFactions', function() return NA.Server.Factions end)
exports('GetPlayerFaction', NA.Server.Factions.GetPlayerFaction)
exports('ModifyReputation', NA.Server.Factions.ModifyReputation)
