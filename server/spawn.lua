NA.Server.Spawn = {}

RegisterNetEvent('na:requestCharacters')
AddEventHandler('na:requestCharacters', function()
    local src = source
    local license = NA.Server.Spawn.GetLicense(src)

    if not license then
        DropPlayer(src, 'No license identifier found')
        return
    end

    local chars = MySQL.query.await('SELECT citizenId, firstname, lastname, gender, dateofbirth, appearance, playtime, last_played, health, hunger, thirst FROM na_players WHERE license = ? ORDER BY last_played DESC', { license })

    TriggerClientEvent('na:characterList', src, chars or {})
end)

RegisterNetEvent('na:selectCharacter')
AddEventHandler('na:selectCharacter', function(citizenId)
    local src = source
    local license = NA.Server.Spawn.GetLicense(src)

    if not license then DropPlayer(src, 'No license') return end

    local playerData = MySQL.query.await('SELECT * FROM na_players WHERE citizenId = ? AND license = ?', { citizenId, license })

    if not playerData or #playerData == 0 then
        DropPlayer(src, 'Character not found')
        return
    end

    NA.Server.Spawn.LoadCharacter(src, playerData[1])
end)

RegisterNetEvent('na:saveCharacter')
AddEventHandler('na:saveCharacter', function(data)
    local src = source
    local license = NA.Server.Spawn.GetLicense(src)

    if not license then DropPlayer(src, 'No license') return end

    local citizenId = 'NA_' .. NA.GetRandomString(12)
    local appearance = data.appearance and NA.SerializeForDb(data.appearance) or '{}'

    MySQL.insert('INSERT INTO na_players (citizenId, license, name, firstname, lastname, gender, dateofbirth, appearance) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        { citizenId, license, data.firstname .. ' ' .. data.lastname, data.firstname, data.lastname, data.gender or 'male', data.dateofbirth or 'Unknown', appearance })

    local newChar = MySQL.query.await('SELECT * FROM na_players WHERE citizenId = ?', { citizenId })
    if newChar and #newChar > 0 then
        NA.Server.Spawn.LoadCharacter(src, newChar[1])
    end
end)

RegisterNetEvent('na:deleteCharacter')
AddEventHandler('na:deleteCharacter', function(citizenId)
    local src = source
    local license = NA.Server.Spawn.GetLicense(src)

    MySQL.query('DELETE FROM na_players WHERE citizenId = ? AND license = ?', { citizenId, license })

    local remaining = MySQL.query.await('SELECT citizenId, firstname, lastname FROM na_players WHERE license = ?', { license })
    TriggerClientEvent('na:characterList', src, remaining or {})
end)

function NA.Server.Spawn.GetLicense(src)
    local identifiers = GetPlayerIdentifiers(src)
    for _, id in ipairs(identifiers) do
        if string.find(id, 'license:') then
            return id:sub(9)
        end
    end
    return nil
end

function NA.Server.Spawn.LoadCharacter(src, charData)
    charData.position = NA.DeserializeFromDb(charData.position)
    charData.stats = NA.DeserializeFromDb(charData.stats)
    charData.skills = NA.DeserializeFromDb(charData.skills)
    charData.reputation = NA.DeserializeFromDb(charData.reputation)
    charData.inventory = NA.DeserializeFromDb(charData.inventory)
    charData.infection_mutations = NA.DeserializeFromDb(charData.infection_mutations)
    charData.appearance = NA.DeserializeFromDb(charData.appearance)

    local player = {
        source = src,
        charData = charData,
        ped = GetPlayerPed(src),
        infection = {
            strain = charData.infection_strain,
            level = charData.infection_level or 0,
            mutations = charData.infection_mutations or {},
            mutated = charData.infection_level and charData.infection_level >= 80 or false,
        },
        stats = NA.MergeTables({ strength = 10, endurance = 10, perception = 10, intelligence = 10, agility = 10, luck = 10 }, charData.stats or {}),
        skills = NA.MergeTables({ crafting = 0, combat = 0, survival = 0, medical = 0 }, charData.skills or {}),
        reputation = charData.reputation or {},
        tethered = {},
        radioFreq = NexusAftermath.Config.radio.defaultFreq,
        isStaff = NA.Server.CheckStaff(src, charData.citizenId),
        settings = {},
        lastSave = os.time(),
    }

    NA.Players[src] = player

    if player.isStaff then
        NA.Server.Staff[src] = true
    end

    TriggerClientEvent('na:characterSpawn', src, {
        charData = charData,
        infection = player.infection,
        stats = player.stats,
        skills = player.skills,
        reputation = player.reputation,
        config = {
            safeZones = NexusAftermath.Config.safeZones,
            spawn = NexusAftermath.Config.spawn,
            maxWeight = 100,
            slots = 50,
        },
        world = {
            tier = NA.Server.WorldTier,
            score = NA.Server.WorldScore,
            activeEvents = NA.Server.ActiveEvents,
        }
    })

    NA.Log(src, 'player_joined', { citizenId = charData.citizenId })
end

RegisterNetEvent('na:updatePosition')
AddEventHandler('na:updatePosition', function(coords, heading)
    local src = source
    local player = NA.Players[src]
    if not player or not player.charData then return end

    MySQL.update('UPDATE na_players SET position = ?, last_played = CURRENT_TIMESTAMP WHERE citizenId = ?',
        { json.encode({ x = coords.x, y = coords.y, z = coords.z, heading = heading }), player.charData.citizenId })
end)
