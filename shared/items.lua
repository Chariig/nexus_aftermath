NA.Items = NA.Items or {}

NA.Items.Categories = {
    weapons = 'Weapons',
    medical = 'Medical Supplies',
    food = 'Food & Water',
    materials = 'Materials',
    tools = 'Tools',
    electronics = 'Electronics',
    chemicals = 'Chemicals',
    components = 'Components',
    rare = 'Rare Items',
    lore = 'Lore Items',
    infection = 'Infection Related',
}

NA.Items.Definitions = {
    -- Resources
    scrap_metal = { label = 'Scrap Metal', weight = 0.5, category = 'materials', type = 'material', description = 'Bent and rusted metal. Can be refined.', decay = 7200 },
    wood_plank = { label = 'Wood Plank', weight = 0.8, category = 'materials', type = 'material', description = 'Salvaged wood. Useful for building.', decay = 14400 },
    cloth = { label = 'Cloth', weight = 0.1, category = 'materials', type = 'material', description = 'Torn fabric. Can be used for bandages or crafting.' },
    plastic = { label = 'Plastic Scrap', weight = 0.2, category = 'materials', type = 'material', description = 'Miscellaneous plastic pieces.' },
    glass_shard = { label = 'Glass Shard', weight = 0.1, category = 'materials', type = 'material', description = 'Sharp glass. Can be used as a cutting tool.', decay = 3600 },
    rubber = { label = 'Rubber', weight = 0.3, category = 'materials', type = 'material', description = 'Flexible rubber material.' },
    circuitry = { label = 'Circuit Board', weight = 0.1, category = 'electronics', type = 'component', description = 'Salvaged circuit board. Useful for electronics.' },
    wire = { label = 'Copper Wire', weight = 0.05, category = 'electronics', type = 'component', description = 'Length of copper wire.' },
    battery = { label = 'Battery', weight = 0.3, category = 'electronics', type = 'component', description = 'Standard battery. Can be recharged.', decay = 0 },
    power_cell = { label = 'Power Cell', weight = 0.5, category = 'electronics', type = 'component', description = 'High-capacity energy storage.' },
    quantum_stabilizer = { label = 'Quantum Stabilizer', weight = 0.4, category = 'rare', type = 'component', description = 'EXPERIMENTAL: Stabilizes quantum fluctuations.' },
    dimensional_core = { label = 'Dimensional Core', weight = 0.8, category = 'rare', type = 'component', description = 'EXPERIMENTAL: Contains a pocket dimension.' },

    -- Medical
    bandage = { label = 'Bandage', weight = 0.1, category = 'medical', type = 'consumable', description = 'Basic wound dressing. Heals 15 HP.', healAmount = 15, useTime = 3000 },
    medkit = { label = 'Medical Kit', weight = 0.5, category = 'medical', type = 'consumable', description = 'Full medical kit. Heals 50 HP.', healAmount = 50, useTime = 5000 },
    syringe = { label = 'Syringe', weight = 0.05, category = 'medical', type = 'tool', description = 'Empty syringe. Can be used to draw blood or inject.' },
    herbs = { label = 'Medicinal Herbs', weight = 0.05, category = 'medical', type = 'material', description = 'Wild herbs with natural healing properties.', decay = 3600 },
    antiviral_compound = { label = 'Antiviral Compound', weight = 0.1, category = 'infection', type = 'consumable', description = 'Slows viral progression by 30%.', infectionReduce = 30 },
    antifungal = { label = 'Antifungal Solution', weight = 0.1, category = 'infection', type = 'consumable', description = 'Fights fungal infections.', infectionReduce = 25 },
    vaccine_blank = { label = 'Blank Vaccine', weight = 0.1, category = 'infection', type = 'tool', description = 'An empty vaccine matrix. Needs a sample to create a cure.' },
    cure_prototype = { label = 'Prototype Cure', weight = 0.2, category = 'infection', type = 'consumable', description = 'A experimental cure for one specific strain.', infectionReduce = 100 },

    -- Food
    canned_food = { label = 'Canned Food', weight = 0.3, category = 'food', type = 'consumable', description = 'Preserved food. Lasts a long time.', hunger = 30, decay = 28800 },
    water_bottle = { label = 'Water Bottle', weight = 0.3, category = 'food', type = 'consumable', description = 'Clean drinking water.', thirst = 40 },
    purified_water = { label = 'Purified Water', weight = 0.3, category = 'food', type = 'consumable', description = 'Filtered and purified water. Safe to drink.', thirst = 50 },
    rotten_food = { label = 'Rotten Food', weight = 0.3, category = 'food', type = 'consumable', description = 'Spoiled. Eating this could make you sick.', hunger = 10, infectionChance = 0.3, decay = 0 },
    mre = { label = 'MRE', weight = 0.4, category = 'food', type = 'consumable', description = 'Military Meals Ready-to-Eat.', hunger = 50, thirst = 10, decay = 43200 },

    -- Tools
    crowbar = { label = 'Crowbar', weight = 1.0, category = 'tools', type = 'tool', description = 'Useful for prying open doors and crates.', durability = 100, damage = 10 },
    hammer = { label = 'Hammer', weight = 0.8, category = 'tools', type = 'tool', description = 'Building and repairing.', durability = 100, damage = 5 },
    wrench = { label = 'Wrench', weight = 0.6, category = 'tools', type = 'tool', description = 'Fixing mechanical objects.', durability = 100 },
    screwdriver = { label = 'Screwdriver', weight = 0.1, category = 'tools', type = 'tool', description = 'Small precision tool.', durability = 50 },
    flashlight = { label = 'Flashlight', weight = 0.2, category = 'tools', type = 'tool', description = 'Handheld light source. Batteries drain over time.', durability = 30 },
    lockpick = { label = 'Lockpick', weight = 0.05, category = 'tools', type = 'tool', description = 'For picking locks. Breaks easily.', durability = 5 },
    radio_scanner = { label = 'Radio Scanner', weight = 0.3, category = 'tools', type = 'radio', description = 'Scans radio frequencies for signals.', durability = 50 },
    radio_transmitter = { label = 'Radio Transmitter', weight = 0.5, category = 'tools', type = 'radio', description = 'Boosts your radio signal range.', durability = 100 },

    -- Weapons
    melee_makeshift = { label = 'Makeshift Club', weight = 0.8, category = 'weapons', type = 'weapon', description = 'A pipe with nails. Gets the job done.', damage = 20, durability = 30 },
    melee_knife = { label = 'Combat Knife', weight = 0.2, category = 'weapons', type = 'weapon', description = 'Sharp and deadly at close range.', damage = 35, durability = 50 },
    ranged_pistol = { label = 'Scavenged Pistol', weight = 0.6, category = 'weapons', type = 'weapon', description = 'A worn but functional sidearm.', damage = 25, durability = 80, ammoType = 'pistol_ammo' },
    ranged_rifle = { label = 'Hunting Rifle', weight = 2.0, category = 'weapons', type = 'weapon', description = 'Bolt-action rifle. Reliable and accurate.', damage = 60, durability = 100, ammoType = 'rifle_ammo' },
    ranged_shotgun = { label = 'Police Shotgun', weight = 2.5, category = 'weapons', type = 'weapon', description = 'Devastating at close range.', damage = 80, durability = 70, ammoType = 'shotgun_ammo' },
    throwable_molotov = { label = 'Molotov Cocktail', weight = 0.5, category = 'weapons', type = 'throwable', description = 'Fire bomb. Creates a temporary fire zone.' },
    throwable_flashbang = { label = 'Flashbang', weight = 0.3, category = 'weapons', type = 'throwable', description = 'Blinds and disorients in a radius.' },

    -- Ammo
    pistol_ammo = { label = 'Pistol Ammo', weight = 0.01, category = 'weapons', type = 'ammo', description = '9mm ammunition.', stackable = true },
    rifle_ammo = { label = 'Rifle Ammo', weight = 0.02, category = 'weapons', type = 'ammo', description = '.308 ammunition.', stackable = true },
    shotgun_ammo = { label = 'Shotgun Shells', weight = 0.03, category = 'weapons', type = 'ammo', description = '12 gauge shells.', stackable = true },

    -- Chemicals
    pure_ethanol = { label = 'Pure Ethanol', weight = 0.2, category = 'chemicals', type = 'material', description = 'High-proof alcohol. Useful for crafting and sterilization.' },
    chemicals = { label = 'Chemical Mix', weight = 0.2, category = 'chemicals', type = 'material', description = 'Assorted chemicals.' },
    acid = { label = 'Acid Solution', weight = 0.3, category = 'chemicals', type = 'material', description = 'Corrosive liquid. Handle with care.' },
    liquid_nitrogen = { label = 'Liquid Nitrogen', weight = 0.4, category = 'chemicals', type = 'material', description = 'Extremely cold. Useful for preservation and crafting.', decay = 1800 },
    adhesive = { label = 'Adhesive', weight = 0.1, category = 'chemicals', type = 'material', description = 'Strong bonding agent.' },

    -- Rare/Legendary
    memory_echo_fragment = { label = 'Memory Echo Fragment', weight = 0.0, category = 'rare', type = 'lore', description = 'A fragment of someone else\'s memory. Glows faintly.', unique = true },
    neural_stimulator = { label = 'Neural Stimulator', weight = 0.2, category = 'rare', type = 'tool', description = 'EXPERIMENTAL: Stimulates neural regeneration.', unique = true },
    defibrillator = { label = 'Defibrillator', weight = 1.0, category = 'rare', type = 'tool', description = 'Can restart a heart or reset neural patterns.' },
    graviton_coil = { label = 'Graviton Coil', weight = 0.6, category = 'rare', type = 'component', description = 'EXPERIMENTAL: Manipulates local gravity.' },
    pure_energy_cell = { label = 'Pure Energy Cell', weight = 0.3, category = 'rare', type = 'component', description = 'Contains pure, stable energy.' },
    ancient_data_drive = { label = 'Ancient Data Drive', weight = 0.05, category = 'rare', type = 'lore', description = 'Contains pre-apocalypse data. May reveal secrets.', unique = true },
    anomalous_artifact = { label = 'Anomalous Artifact', weight = 0.2, category = 'rare', type = 'lore', description = 'An object from... somewhere else. It hums with unknown energy.', unique = true },

    -- Echo-related
    echo_recorder = { label = 'Echo Recorder', weight = 0.1, category = 'tools', type = 'tool', description = 'Records a short clip of your surroundings for posterity.' },
    echo_playback = { label = 'Echo Fragment', weight = 0.0, category = 'lore', type = 'lore', description = 'A recorded moment frozen in time.', unique = true },
}

function NA.Items.GetDefinition(name)
    return NA.Items.Definitions[name]
end

function NA.Items.CanStack(name)
    local item = NA.Items.Definitions[name]
    return item and item.stackable or false
end

function NA.Items.GetWeight(name, count)
    local item = NA.Items.Definitions[name]
    if not item then return count * 0.1 end
    return (item.weight or 0.1) * (count or 1)
end

function NA.Items.IsWeapon(name)
    local item = NA.Items.Definitions[name]
    return item and item.type == 'weapon'
end

function NA.Items.IsConsumable(name)
    local item = NA.Items.Definitions[name]
    return item and item.type == 'consumable'
end

function NA.Items.IsTool(name)
    local item = NA.Items.Definitions[name]
    return item and item.type == 'tool'
end

function NA.Items.GetCategoryItems(category)
    local items = {}
    for name, def in pairs(NA.Items.Definitions) do
        if def.category == category then
            items[name] = def
        end
    end
    return items
end

function NA.Items.SearchItems(query)
    local results = {}
    local q = string.lower(query)
    for name, def in pairs(NA.Items.Definitions) do
        if string.find(string.lower(name), q) or string.find(string.lower(def.label), q) or string.find(string.lower(def.description), q) then
            results[name] = def
        end
    end
    return results
end
