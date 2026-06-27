NA.World = NA.World or {}

NA.World.Tiers = {
    safe = {
        label = 'Safe Zone',
        description = 'The apocalypse is distant. Resources are plentiful.',
        color = '#4CAF50',
        zombieMult = 0.3,
        resourceMult = 2.0,
        infectionMult = 0.2,
        radiationMult = 0.1,
        eventChance = 0.01,
        scavengerMult = 0.5,
        decayRate = 0.1,
    },
    unstable = {
        label = 'Unstable',
        description = 'The world is shifting. Danger increases.',
        color = '#FF9800',
        zombieMult = 0.7,
        resourceMult = 1.3,
        infectionMult = 0.6,
        radiationMult = 0.4,
        eventChance = 0.04,
        scavengerMult = 0.8,
        decayRate = 0.4,
    },
    critical = {
        label = 'Critical',
        description = 'The apocalypse is in full swing. Fight for survival.',
        color = '#F44336',
        zombieMult = 1.2,
        resourceMult = 0.8,
        infectionMult = 1.2,
        radiationMult = 0.8,
        eventChance = 0.08,
        scavengerMult = 1.2,
        decayRate = 0.7,
    },
    collapse = {
        label = 'Collapse',
        description = 'Reality is breaking down. Nothing is safe.',
        color = '#9C27B0',
        zombieMult = 2.0,
        resourceMult = 0.4,
        infectionMult = 2.0,
        radiationMult = 1.5,
        eventChance = 0.15,
        scavengerMult = 1.5,
        decayRate = 1.0,
    },
}

NA.World.Events = {
    horde_migration = {
        label = 'Horde Migration',
        description = 'A massive horde is moving through the area.',
        icon = 'zombie',
        duration = 300000,
        cooldown = 1800000,
        minTier = 'unstable',
        radius = 200.0,
    },
    toxic_storm = {
        label = 'Toxic Storm',
        description = 'A cloud of toxic gas is spreading across the region.',
        icon = 'cloud',
        duration = 240000,
        cooldown = 3600000,
        minTier = 'unstable',
        radius = 300.0,
    },
    supply_drop = {
        label = 'Supply Drop',
        description = 'An emergency supply crate is falling from the sky.',
        icon = 'crate',
        duration = 120000,
        cooldown = 900000,
        minTier = 'safe',
        radius = 10.0,
    },
    earthquake = {
        label = 'Earthquake',
        description = 'The ground is shaking. Structures may collapse.',
        icon = 'quake',
        duration = 30000,
        cooldown = 3600000,
        minTier = 'unstable',
        radius = 500.0,
    },
    void_tear = {
        label = 'Void Tear',
        description = 'A rift between dimensions has opened. Anomalous creatures emerge.',
        icon = 'void',
        duration = 600000,
        cooldown = 7200000,
        minTier = 'critical',
        radius = 100.0,
    },
    radiation_spike = {
        label = 'Radiation Spike',
        description = 'Background radiation has spiked to dangerous levels.',
        icon = 'radiation',
        duration = 180000,
        cooldown = 2700000,
        minTier = 'unstable',
        radius = 400.0,
    },
    animal_frenzy = {
        label = 'Animal Frenzy',
        description = 'Local wildlife has become aggressive and hostile.',
        icon = 'paw',
        duration = 180000,
        cooldown = 2400000,
        minTier = 'unstable',
        radius = 150.0,
    },
}

NA.World.ScavengeZones = {
    { coords = vector3(2500.0, 2800.0, 40.0), radius = 100.0, label = 'Abandoned Mall', tier = 'medium', resources = { 'electronics', 'food', 'cloth' } },
    { coords = vector3(-600.0, -2000.0, 20.0), radius = 80.0, label = 'Docks Warehouse', tier = 'medium', resources = { 'materials', 'tools', 'chemicals' } },
    { coords = vector3(1200.0, -1500.0, 35.0), radius = 60.0, label = 'Construction Site', tier = 'high', resources = { 'materials', 'tools', 'rare' } },
    { coords = vector3(-1800.0, 800.0, 30.0), radius = 120.0, label = 'Military Outpost', tier = 'high', resources = { 'weapons', 'medical', 'rare' } },
    { coords = vector3(100.0, 1900.0, 25.0), radius = 50.0, label = 'Gas Station', tier = 'low', resources = { 'food', 'chemicals', 'tools' } },
    { coords = vector3(-1200.0, -1200.0, 10.0), radius = 90.0, label = 'Port Terminal', tier = 'medium', resources = { 'materials', 'electronics', 'tools' } },
    { coords = vector3(400.0, 2500.0, 45.0), radius = 70.0, label = 'Mountain Bunker', tier = 'high', resources = { 'rare', 'weapons', 'medical' } },
    { coords = vector3(-800.0, 5500.0, 35.0), radius = 60.0, label = 'Sandy Shores', tier = 'low', resources = { 'food', 'materials', 'chemicals' } },
    { coords = vector3(1700.0, 3200.0, 45.0), radius = 40.0, label = 'Harmony Hub', tier = 'low', resources = { 'food', 'tools' } },
    { coords = vector3(-1400.0, -500.0, 35.0), radius = 100.0, label = 'Airport Cargo', tier = 'high', resources = { 'electronics', 'rare', 'weapons', 'medical' } },
}

NA.World.Zones = {
    quarantine_tower = {
        coords = vector3(460.0, -1000.0, 25.0),
        radius = 200.0,
        label = 'Quarantine Tower',
        type = 'landmark',
        radiation = 0.6,
        loot_tier = 'high',
        infected_density = 1.5,
    },
    lab_38 = {
        coords = vector3(-200.0, 1300.0, 15.0),
        radius = 150.0,
        label = 'Lab 38',
        type = 'lab',
        radiation = 0.8,
        loot_tier = 'rare',
        infected_density = 2.0,
        requires_keycard = true,
    },
    the_nest = {
        coords = vector3(2500.0, -500.0, 90.0),
        radius = 100.0,
        label = 'The Nest',
        type = 'hive',
        radiation = 1.0,
        loot_tier = 'legendary',
        infected_density = 3.0,
    },
    refuge_island = {
        coords = vector3(-2000.0, 5000.0, 5.0),
        radius = 300.0,
        label = 'Refuge Island',
        type = 'safe_haven',
        radiation = 0.0,
        loot_tier = 'none',
        infected_density = 0.0,
    },
    underground_shelter_7 = {
        coords = vector3(700.0, -2000.0, -50.0),
        radius = 80.0,
        label = 'Shelter 7',
        type = 'bunker',
        radiation = 0.2,
        loot_tier = 'high',
        infected_density = 0.3,
    },
}

NA.World.RadiationZones = {
    {
        coords = vector3(460.0, -1000.0, 25.0),
        radius = 150.0,
        intensity = 0.7,
        label = 'Quarantine Fallout',
        color = { r = 0, g = 255, b = 0 },
    },
    {
        coords = vector3(-200.0, 1300.0, 15.0),
        radius = 120.0,
        intensity = 0.9,
        label = 'Lab 38 Leak',
        color = { r = 255, g = 0, b = 0 },
    },
}

function NA.World.GetTierConfig(tierName)
    return NA.World.Tiers[tierName] or NA.World.Tiers.safe
end

function NA.World.GetEventConfig(eventName)
    return NA.World.Events[eventName]
end

function NA.World.GetRandomEvent(minTier)
    local available = {}
    for name, event in pairs(NA.World.Events) do
        local tierPriority = { safe = 1, unstable = 2, critical = 3, collapse = 4 }
        local eventMinPriority = tierPriority[event.minTier] or 1
        local currentPriority = tierPriority[minTier] or 1
        if currentPriority >= eventMinPriority then
            available[name] = event
        end
    end
    if NA.TableSize(available) == 0 then return nil end
    local names = {}
    for name in pairs(available) do names[#names+1] = name end
    return names[math.random(#names)]
end

function NA.World.GetScavengeZoneByLocation(coords)
    for _, zone in ipairs(NA.World.ScavengeZones) do
        if NA.Distance(coords, zone.coords) <= zone.radius then
            return zone
        end
    end
    return nil
end

function NA.World.GetZoneByLocation(coords)
    for name, zone in pairs(NA.World.Zones) do
        if NA.Distance(coords, zone.coords) <= zone.radius then
            return name, zone
        end
    end
    return nil, nil
end

function NA.World.GetRadiationAt(coords)
    local total = 0
    for _, zone in ipairs(NA.World.RadiationZones) do
        local dist = NA.Distance(coords, zone.coords)
        if dist <= zone.radius then
            local falloff = 1 - (dist / zone.radius)
            total = total + (zone.intensity * falloff)
        end
    end
    -- Wind drift radiation
    if NA.World.CurrentWind then
        local windOffset = vector3(
            NA.World.CurrentWind.x * 50,
            NA.World.CurrentWind.y * 50,
            0
        )
        for _, zone in ipairs(NA.World.RadiationZones) do
            local driftedCoords = vector3(zone.coords.x + windOffset.x, zone.coords.y + windOffset.y, zone.coords.z)
            local dist = NA.Distance(coords, driftedCoords)
            if dist <= zone.radius * 1.5 then
                local falloff = 1 - (dist / (zone.radius * 1.5))
                total = total + (zone.intensity * falloff * 0.3)
            end
        end
    end
    return NA.Clamp(total, 0, 1)
end
