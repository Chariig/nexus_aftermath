NA.Server.Buildings = NA.Server.Buildings or {}

NA.Server.Buildings.Definitions = {
    wall_wood = {
        label = 'Wooden Wall',
        model = 'prop_box_wood02',
        health = 200,
        materials = { wood_plank = 5, scrap_metal = 2 },
        category = 'defense',
        decay = 0.1,
        weight = 5,
    },
    wall_metal = {
        label = 'Metal Wall',
        model = 'prop_skid_metal_02',
        health = 500,
        materials = { scrap_metal = 8, wood_plank = 2 },
        category = 'defense',
        decay = 0.05,
        weight = 10,
    },
    floor_spikes = {
        label = 'Floor Spikes',
        model = 'prop_mp_spikes',
        health = 50,
        materials = { scrap_metal = 3, wood_plank = 2 },
        category = 'trap',
        decay = 0.2,
        weight = 3,
        damage = 30,
    },
    storage_crate = {
        label = 'Storage Crate',
        model = 'prop_box_wood04',
        health = 100,
        materials = { wood_plank = 4, scrap_metal = 1 },
        category = 'storage',
        decay = 0.05,
        weight = 8,
        slots = 20,
    },
    bed = {
        label = 'Sleeping Bag',
        model = 'v_ilev_methbed',
        health = 50,
        materials = { cloth = 3 },
        category = 'comfort',
        decay = 0.1,
        weight = 2,
    },
    watchtower = {
        label = 'Watchtower',
        model = 'prop_fnclog_07',
        health = 300,
        materials = { wood_plank = 10, scrap_metal = 5 },
        category = 'defense',
        decay = 0.08,
        weight = 15,
    },
    generator = {
        label = 'Generator',
        model = 'prop_generator_03a',
        health = 150,
        materials = { circuitry = 3, wire = 5, scrap_metal = 4 },
        category = 'utility',
        decay = 0.15,
        weight = 12,
        fuelConsumption = 1,
    },
    radio_tower = {
        label = 'Radio Tower',
        model = 'prop_antenna_01',
        health = 200,
        materials = { scrap_metal = 6, wire = 8, circuitry = 2 },
        category = 'utility',
        decay = 0.1,
        weight = 10,
        rangeBoost = 1.5,
    },
}

RegisterNetEvent('na:placeStructure')
AddEventHandler('na:placeStructure', function(structureType, coords, rotation)
    local src = source
    local player = NA.GetPlayer(src)
    if not player then return end

    local def = NA.Server.Buildings.Definitions[structureType]
    if not def then
        NA.ShowNotification(src, 'Unknown structure type', 'error')
        return
    end

    local structureCount = 0
    for _, building in pairs(NA.Server.Buildings) do
        if building.owner == player.charData.citizenId then
            structureCount = structureCount + 1
        end
    end
    if structureCount >= NexusAftermath.Config.buildings.maxStructuresPerPlayer then
        NA.ShowNotification(src, 'Max structures placed', 'error')
        return
    end

    for material, amount in pairs(def.materials) do
        if not NA.Server.Inventory.HasItem(src, material, amount) then
            NA.ShowNotification(src, 'Missing materials', 'error')
            return
        end
    end

    for material, amount in pairs(def.materials) do
        NA.Server.Inventory.RemoveItem(src, material, amount)
    end

    local building = {
        id = 'BLD_' .. NA.GetRandomString(8),
        owner = player.charData.citizenId,
        type = structureType,
        coords = coords,
        rotation = rotation or { x = 0, y = 0, z = 0 },
        health = def.health,
        maxHealth = def.health,
        integrity = 100,
        decay = def.decay or 0.1,
        category = def.category or 'misc',
        data = {},
        createdAt = os.time(),
        lastUpdated = os.time(),
    }

    NA.Server.Buildings[building.id] = building

    local success = MySQL.insert.await('INSERT INTO na_buildings (owner_citizenId, structure_type, pos_x, pos_y, pos_z, rot_x, rot_y, rot_z, health, max_health, integrity, data) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        { building.owner, structureType, coords.x, coords.y, coords.z, rotation.x or 0, rotation.y or 0, rotation.z or 0, def.health, def.health, 100, '{}' })

    TriggerClientEvent('na:structurePlaced', -1, {
        id = building.id,
        type = structureType,
        coords = coords,
        rotation = rotation,
        owner = player.charData.citizenId,
        health = def.health,
    })

    NA.ShowNotification(src, 'Structure placed', 'success')
    NA.Log(src, 'structure_placed', { type = structureType, id = building.id })
end)

RegisterNetEvent('na:removeStructure')
AddEventHandler('na:removeStructure', function(buildingId)
    local src = source
    local player = NA.GetPlayer(src)
    if not player then return end

    local building = NA.Server.Buildings[buildingId]
    if not building then
        NA.ShowNotification(src, 'Structure not found', 'error')
        return
    end

    if building.owner ~= player.charData.citizenId and not player.isStaff then
        NA.ShowNotification(src, 'You do not own this structure', 'error')
        return
    end

    NA.Server.Buildings[buildingId] = nil
    MySQL.query('DELETE FROM na_buildings WHERE id = ?', { buildingId })

    TriggerClientEvent('na:structureRemoved', -1, buildingId)
    NA.ShowNotification(src, 'Structure removed', 'info')
end)

RegisterNetEvent('na:repairStructure')
AddEventHandler('na:repairStructure', function(buildingId)
    local src = source
    local player = NA.GetPlayer(src)
    if not player then return end

    local building = NA.Server.Buildings[buildingId]
    if not building then
        NA.ShowNotification(src, 'Structure not found', 'error')
        return
    end

    if building.owner ~= player.charData.citizenId then
        NA.ShowNotification(src, 'You do not own this structure', 'error')
        return
    end

    local hasTools = NA.Server.Inventory.HasItem(src, 'hammer', 1)
    if not hasTools then
        NA.ShowNotification(src, 'You need a hammer to repair', 'error')
        return
    end

    local repairAmount = 20
    local hasMaterials = NA.Server.Inventory.HasItem(src, 'scrap_metal', 2)
    if hasMaterials then
        NA.Server.Inventory.RemoveItem(src, 'scrap_metal', 2)
    else
        repairAmount = 10
    end

    building.health = NA.Clamp(building.health + repairAmount, 0, building.maxHealth)
    building.lastUpdated = os.time()

    TriggerClientEvent('na:structureHealthUpdate', -1, buildingId, building.health, building.maxHealth)
    NA.ShowNotification(src, 'Structure repaired: +' .. repairAmount .. ' HP', 'success')
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        local tierCfg = NA.World.GetTierConfig(NA.Server.WorldTier)

        for id, building in pairs(NA.Server.Buildings) do
            if NexusAftermath.Config.buildings.structuralIntegrity then
                local decayAmount = building.decay * tierCfg.decayRate
                building.integrity = NA.Clamp(building.integrity - decayAmount, 0, 100)

                if building.integrity < 30 then
                    building.health = NA.Clamp(building.health - 2, 0, building.maxHealth)
                    TriggerClientEvent('na:structureHealthUpdate', -1, id, building.health, building.maxHealth)
                end

                if building.integrity < 10 and math.random() < 0.05 then
                    if NexusAftermath.Config.buildings.collapseDamage then
                        local def = NA.Server.Buildings.Definitions[building.type]
                        local damageRadius = def and def.weight or 5
                        TriggerClientEvent('na:structureCollapse', -1, id, building.coords, damageRadius)
                    end
                    NA.Server.Buildings[id] = nil
                    MySQL.query('DELETE FROM na_buildings WHERE id = ?', { id })
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000)
        local buildings = MySQL.query.await('SELECT * FROM na_buildings')
        if buildings then
            for _, row in ipairs(buildings) do
                if not NA.Server.Buildings[row.id] then
                    NA.Server.Buildings[row.id] = {
                        id = row.id,
                        owner = row.owner_citizenId,
                        type = row.structure_type,
                        coords = { x = row.pos_x, y = row.pos_y, z = row.pos_z },
                        rotation = { x = row.rot_x, y = row.rot_y, z = row.rot_z },
                        health = row.health,
                        maxHealth = row.max_health,
                        integrity = row.integrity,
                        decay = (NA.Server.Buildings.Definitions[row.structure_type] or {}).decay or 0.1,
                        category = (NA.Server.Buildings.Definitions[row.structure_type] or {}).category or 'misc',
                        data = NA.DeserializeFromDb(row.data),
                        createdAt = row.created_at and os.time() or os.time(),
                        lastUpdated = row.last_updated and os.time() or os.time(),
                    }
                end
            end
        end
    end
end)

exports('GetBuildings', function() return NA.Server.Buildings end)
exports('GetBuildingDefs', function() return NA.Server.Buildings.Definitions end)
exports('GetPlayerBuildings', function(citizenId)
    local playerBldgs = {}
    for id, building in pairs(NA.Server.Buildings) do
        if building.owner == citizenId then
            playerBldgs[id] = building
        end
    end
    return playerBldgs
end)
