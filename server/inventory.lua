NA.Server.Inventory = {}

RegisterNetEvent('na:getInventory')
AddEventHandler('na:getInventory', function()
    local src = source
    local player = NA.GetPlayer(src)
    if not player then return end
    TriggerClientEvent('na:openInventory', src, {
        inventory = player.charData.inventory or {},
        maxWeight = 100,
        maxSlots = 50,
        items = NA.Items.Definitions,
    })
end)

RegisterNetEvent('na:useItem')
AddEventHandler('na:useItem', function(itemName, slot)
    local src = source
    local player = NA.GetPlayer(src)
    if not player then return end
    local inventory = player.charData.inventory or {}
    local item = inventory[slot]
    if not item or item.name ~= itemName then
        NA.ShowNotification(src, 'Item not found', 'error')
        return
    end

    local def = NA.Items.GetDefinition(itemName)
    if not def then return end

    if def.type == 'consumable' then
        NA.Server.Inventory.UseConsumable(src, player, item, def)
    elseif def.type == 'weapon' then
        NA.Server.Inventory.EquipWeapon(src, player, item, def)
    elseif def.type == 'tool' then
        NA.Server.Inventory.UseTool(src, player, item, def)
    end
end)

function NA.Server.Inventory.UseConsumable(src, player, item, def)
    if def.healAmount then
        player.charData.health = NA.Clamp((player.charData.health or 200) + def.healAmount, 0, 200)
        TriggerClientEvent('na:updateHealth', src, player.charData.health)
    end
    if def.hunger then
        player.charData.hunger = NA.Clamp((player.charData.hunger or 100) + def.hunger, 0, 100)
        TriggerClientEvent('na:updateHunger', src, player.charData.hunger)
    end
    if def.thirst then
        player.charData.thirst = NA.Clamp((player.charData.thirst or 100) + def.thirst, 0, 100)
        TriggerClientEvent('na:updateThirst', src, player.charData.thirst)
    end
    if def.infectionReduce and player.infection and player.infection.level then
        player.infection.level = NA.Clamp(player.infection.level - def.infectionReduce, 0, 100)
        TriggerClientEvent('na:infectionUpdate', src, player.infection)
    end

    item.count = item.count - 1
    if item.count <= 0 then
        table.remove(player.charData.inventory, item.slot or 1)
    end

    NA.Server.Inventory.SendUpdate(src, player)
    NA.ShowNotification(src, 'Used ' .. def.label, 'success')
    NA.Log(src, 'item_used', { item = itemName })
end

function NA.Server.Inventory.UseTool(src, player, item, def)
    if def.durability then
        item.metadata = item.metadata or {}
        item.metadata.durability = (item.metadata.durability or def.durability) - 1
        if item.metadata.durability <= 0 then
            table.remove(player.charData.inventory, item.slot or 1)
            NA.ShowNotification(src, 'Your ' .. def.label .. ' broke', 'error')
        end
    end
    NA.Server.Inventory.SendUpdate(src, player)
end

function NA.Server.Inventory.EquipWeapon(src, player, item, def)
    player.equippedWeapon = item.name
    TriggerClientEvent('na:equipWeapon', src, item.name, def)
    NA.ShowNotification(src, 'Equipped ' .. def.label, 'success')
end

RegisterNetEvent('na:addItem')
AddEventHandler('na:addItem', function(itemName, count, metadata)
    local src = source
    local player = NA.GetPlayer(src)
    if not player then return end

    count = count or 1
    metadata = metadata or {}
    local def = NA.Items.GetDefinition(itemName)
    if not def then return end

    local inventory = player.charData.inventory or {}
    local totalWeight = 0
    for _, invItem in ipairs(inventory) do
        totalWeight = totalWeight + (NA.Items.GetWeight(invItem.name, invItem.count))
    end

    local newWeight = NA.Items.GetWeight(itemName, count)
    if totalWeight + newWeight > 100 then
        NA.ShowNotification(src, 'Inventory full', 'error')
        return
    end

    if def.stackable then
        for _, invItem in ipairs(inventory) do
            if invItem.name == itemName then
                invItem.count = invItem.count + count
                NA.Server.Inventory.SendUpdate(src, player)
                return
            end
        end
    end

    table.insert(inventory, {
        name = itemName,
        count = count,
        metadata = metadata,
        slot = #inventory + 1,
    })
    player.charData.inventory = inventory
    NA.Server.Inventory.SendUpdate(src, player)
    NA.Log(src, 'item_added', { item = itemName, count = count })
end)

RegisterNetEvent('na:removeItem')
AddEventHandler('na:removeItem', function(itemName, count)
    local src = source
    local player = NA.GetPlayer(src)
    if not player then return end

    count = count or 1
    local inventory = player.charData.inventory or {}

    for i, invItem in ipairs(inventory) do
        if invItem.name == itemName then
            invItem.count = invItem.count - count
            if invItem.count <= 0 then
                table.remove(inventory, i)
            end
            NA.Server.Inventory.SendUpdate(src, player)
            return
        end
    end
    NA.ShowNotification(src, 'Item not found', 'error')
end)

RegisterNetEvent('na:dropItem')
AddEventHandler('na:dropItem', function(slot, count)
    local src = source
    local player = NA.GetPlayer(src)
    if not player then return end

    count = count or 1
    local inventory = player.charData.inventory or {}
    local item = inventory[slot]
    if not item then return end

    item.count = item.count - count
    if item.count <= 0 then
        table.remove(inventory, slot)
    end

    local coords = GetEntityCoords(GetPlayerPed(src))
    TriggerClientEvent('na:spawnWorldItem', -1, item.name, count, coords.x, coords.y, coords.z - 1)
    NA.Server.Inventory.SendUpdate(src, player)
end)

RegisterNetEvent('na:swapItems')
AddEventHandler('na:swapItems', function(slot1, slot2)
    local src = source
    local player = NA.GetPlayer(src)
    if not player then return end
    local inventory = player.charData.inventory or {}
    inventory[slot1], inventory[slot2] = inventory[slot2], inventory[slot1]
    NA.Server.Inventory.SendUpdate(src, player)
end)

function NA.Server.Inventory.SendUpdate(src, player)
    TriggerClientEvent('na:updateInventory', src, {
        inventory = player.charData.inventory or {},
    })
end

function NA.Server.Inventory.HasItem(src, itemName, count)
    local player = NA.GetPlayer(src)
    if not player then return false end
    count = count or 1
    for _, invItem in ipairs(player.charData.inventory or {}) do
        if invItem.name == itemName and invItem.count >= count then
            return true
        end
    end
    return false
end

function NA.Server.Inventory.GetItemCount(src, itemName)
    local player = NA.GetPlayer(src)
    if not player then return 0 end
    local total = 0
    for _, invItem in ipairs(player.charData.inventory or {}) do
        if invItem.name == itemName then
            total = total + invItem.count
        end
    end
    return total
end

exports('HasItem', NA.Server.Inventory.HasItem)
exports('GetItemCount', NA.Server.Inventory.GetItemCount)
exports('AddItem', function(src, item, count, meta) TriggerEvent('na:addItem', src, { item, count, meta }) end)
