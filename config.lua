NexusAftermath = NexusAftermath or {}

NexusAftermath.Config = {
    debug = GetConvar('na_debug', 'false') == 'true',
    maxPlayers = tonumber(GetConvar('na_max_players', '64')),
    worldTier = GetConvar('na_world_tier', 'auto'),
    infectionRate = tonumber(GetConvar('na_infection_rate', '1.0')),
    resourceMult = tonumber(GetConvar('na_resource_mult', '1.0')),

    serverName = 'Nexus: Aftermath',
    serverDesc = 'An apocalypse like no other. The world remembers everything.',

    spawn = {
        x = -1042.0,
        y = -2744.0,
        z = 21.0,
        heading = 210.0,
        label = 'Ravenswood Safe Zone'
    },

    safeZones = {
        { coords = vector3(-1042.0, -2744.0, 21.0), radius = 150.0, label = 'Ravenswood Safe Zone' },
        { coords = vector3(1850.0, 3700.0, 33.0), radius = 100.0, label = 'Sandy Shores Shelter' },
        { coords = vector3(-450.0, -1700.0, 18.0), radius = 80.0, label = 'Vespucci Beach Bunker' },
    },

    world = {
        tierProgression = true,
        cycleTime = 3600000,
        radiationWind = true,
        dynamicWeather = true,
        dayNightCycle = true,
    },

    infection = {
        enabled = true,
        airborneTransmission = true,
        animalReservoir = true,
        mutationEnabled = true,
        cureCraftable = true,
        stages = 5,
    },

    echo = {
        enabled = true,
        recordDuration = 30,
        maxEchoes = 100,
        echoDecayTime = 604800,
    },

    buildings = {
        enabled = true,
        maxStructuresPerPlayer = 25,
        structuralIntegrity = true,
        collapseDamage = true,
        materialDecay = true,
    },

    tether = {
        enabled = true,
        maxTethered = 6,
        maxRange = 100.0,
        shareHealth = true,
        shareInventory = true,
        shareSenses = true,
    },

    radio = {
        enabled = true,
        minFreq = 1.0,
        maxFreq = 999.0,
        defaultFreq = 420.0,
        baseRange = 500.0,
        ampRangeMult = 3.0,
        jammingEnabled = true,
    },

    scavengers = {
        enabled = true,
        maxPerZone = 5,
        respawnTime = 300000,
        competitionMemory = true,
        factionBehavior = true,
    },

    factions = {
        enabled = true,
        maxFactions = 20,
        minPlayersPerFaction = 3,
        territoryInfluence = true,
        reputationDecay = true,
    },
}
