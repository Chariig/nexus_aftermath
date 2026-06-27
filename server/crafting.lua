NA.Server.Crafting = {}

NA.Server.Crafting.Recipes = {
    -- Medical
    bandage = {
        label = 'Craft Bandage',
        ingredients = { cloth = 2, herbs = 1 },
        result = { name = 'bandage', count = 1 },
        skill = 'medical',
        skillReq = 0,
        time = 5000,
        category = 'medical',
    },
    medkit = {
        label = 'Craft Medical Kit',
        ingredients = { bandage = 2, herbs = 3, adhesive = 1 },
        result = { name = 'medkit', count = 1 },
        skill = 'medical',
        skillReq = 20,
        time = 10000,
        category = 'medical',
    },
    antiviral_compound = {
        label = 'Craft Antiviral',
        ingredients = { herbs = 3, pure_ethanol = 1, syringe = 1 },
        result = { name = 'antiviral_compound', count = 1 },
        skill = 'medical',
        skillReq = 30,
        time = 15000,
        category = 'medical',
    },
    antifungal = {
        label = 'Craft Antifungal',
        ingredients = { chemicals = 2, herbs = 2, pure_ethanol = 1 },
        result = { name = 'antifungal', count = 1 },
        skill = 'medical',
        skillReq = 15,
        time = 10000,
        category = 'medical',
    },

    -- Weapons
    melee_makeshift = {
        label = 'Craft Makeshift Club',
        ingredients = { scrap_metal = 2, wood_plank = 1, cloth = 1 },
        result = { name = 'melee_makeshift', count = 1 },
        skill = 'crafting',
        skillReq = 0,
        time = 8000,
        category = 'weapons',
    },
    throwable_molotov = {
        label = 'Craft Molotov',
        ingredients = { cloth = 1, pure_ethanol = 1, glass_shard = 1 },
        result = { name = 'throwable_molotov', count = 2 },
        skill = 'crafting',
        skillReq = 10,
        time = 6000,
        category = 'weapons',
    },
    throwable_flashbang = {
        label = 'Craft Flashbang',
        ingredients = { chemicals = 2, circuitry = 1, scrap_metal = 1 },
        result = { name = 'throwable_flashbang', count = 1 },
        skill = 'crafting',
        skillReq = 40,
        time = 20000,
        category = 'weapons',
    },
    pistol_ammo = {
        label = 'Craft Pistol Ammo',
        ingredients = { scrap_metal = 1, chemicals = 1 },
        result = { name = 'pistol_ammo', count = 12 },
        skill = 'crafting',
        skillReq = 15,
        time = 10000,
        category = 'weapons',
    },
    rifle_ammo = {
        label = 'Craft Rifle Ammo',
        ingredients = { scrap_metal = 2, chemicals = 2 },
        result = { name = 'rifle_ammo', count = 8 },
        skill = 'crafting',
        skillReq = 25,
        time = 15000,
        category = 'weapons',
    },

    -- Tools
    lockpick = {
        label = 'Craft Lockpick',
        ingredients = { scrap_metal = 1, wire = 1 },
        result = { name = 'lockpick', count = 1 },
        skill = 'crafting',
        skillReq = 20,
        time = 8000,
        category = 'tools',
    },
    flashlight = {
        label = 'Craft Flashlight',
        ingredients = { battery = 1, wire = 1, plastic = 1 },
        result = { name = 'flashlight', count = 1 },
        skill = 'crafting',
        skillReq = 10,
        time = 10000,
        category = 'tools',
    },
    radio_scanner = {
        label = 'Craft Radio Scanner',
        ingredients = { circuitry = 2, wire = 3, battery = 1 },
        result = { name = 'radio_scanner', count = 1 },
        skill = 'crafting',
        skillReq = 30,
        time = 20000,
        category = 'tools',
    },

    -- Survival
    purified_water = {
        label = 'Purify Water',
        ingredients = { water_bottle = 1, chemicals = 1 },
        result = { name = 'purified_water', count = 1 },
        skill = 'survival',
        skillReq = 0,
        time = 5000,
        category = 'food',
    },
    mre = {
        label = 'Craft MRE',
        ingredients = { canned_food = 2, water_bottle = 1 },
        result = { name = 'mre', count = 1 },
        skill = 'survival',
        skillReq = 15,
        time = 8000,
        category = 'food',
    },
}

RegisterNetEvent('na:craftItem')
AddEventHandler('na:craftItem', function(recipeName)
    local src = source
    local player = NA.GetPlayer(src)
    if not player then return end

    local recipe = NA.Server.Crafting.Recipes[recipeName]
    if not recipe then
        NA.ShowNotification(src, 'Unknown recipe', 'error')
        return
    end

    local skillLevel = player.skills[recipe.skill] or 0
    if skillLevel < recipe.skillReq then
        NA.ShowNotification(src, 'Need ' .. recipe.skillReq .. ' ' .. recipe.skill .. ' skill', 'error')
        return
    end

    for ingredient, amount in pairs(recipe.ingredients) do
        if not NA.Server.Inventory.HasItem(src, ingredient, amount) then
            NA.ShowNotification(src, 'Missing: ' .. (NA.Items.GetDefinition(ingredient) or {}).label or ingredient, 'error')
            return
        end
    end

    for ingredient, amount in pairs(recipe.ingredients) do
        NA.Server.Inventory.RemoveItem(src, ingredient, amount)
    end

    Citizen.Wait(recipe.time)

    if not NA.Players[src] then return end

    TriggerEvent('na:addItem', src, recipe.result.name, recipe.result.count)

    local skillGain = math.random(1, 3)
    player.skills[recipe.skill] = (player.skills[recipe.skill] or 0) + skillGain
    TriggerClientEvent('na:skillUp', src, recipe.skill, player.skills[recipe.skill], skillGain)

    NA.ShowNotification(src, 'Crafted ' .. recipe.label, 'success')
    NA.Log(src, 'item_crafted', { recipe = recipeName, result = recipe.result })
end)

RegisterNetEvent('na:getCraftingRecipes')
AddEventHandler('na:getCraftingRecipes', function()
    local src = source
    local player = NA.GetPlayer(src)
    if not player then return end
    TriggerClientEvent('na:craftingRecipes', src, NA.Server.Crafting.Recipes, player.skills)
end)

exports('GetRecipes', function() return NA.Server.Crafting.Recipes end)
