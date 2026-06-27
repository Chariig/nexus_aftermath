NA.Viruses = NA.Viruses or {}

NA.Viruses.Strains = {
    ['the_glitch'] = {
        label = 'The Glitch',
        description = 'A digital-physical pathogen that corrupts neural interfaces. Origins unknown.',
        rarity = 'common',
        transmission = { airborne = 0.3, blood = 0.8, contact = 0.5, animal = 0.2 },
        stages = {
            { threshold = 0, label = 'Asymptomatic', effects = {} },
            { threshold = 20, label = 'Digital Static', effects = { { type = 'screen_glitch', severity = 0.2 }, { type = 'audio_distortion', severity = 0.1 } } },
            { threshold = 40, label = 'Interface Corruption', effects = { { type = 'screen_glitch', severity = 0.5 }, { type = 'random_movement', severity = 0.2 }, { type = 'skill_decay', severity = 0.3 } } },
            { threshold = 60, label = 'System Failure', effects = { { type = 'screen_glitch', severity = 0.8 }, { type = 'random_movement', severity = 0.5 }, { type = 'health_decay', severity = 0.3 }, { type = 'hallucination', severity = 0.4 } } },
            { threshold = 80, label = 'The Glitch Complete', effects = { { type = 'loss_of_control', severity = 1.0 }, { type = 'transformation', strain = 'the_glitch' } } },
        },
        mutations = {
            'static_aura',
            'digital_echo',
            'corruption_touch',
            'neural_overload',
        },
        cures = {
            { name = 'purge_injector', effectiveness = 0.8, ingredients = { 'circuit_board', 'antiviral_compound', 'pure_ethanol' } },
            { name = 'neural_reset', effectiveness = 0.5, ingredients = { 'defibrillator', 'saline', 'adrenaline' } },
        },
    },
    ['the_spore'] = {
        label = 'The Spore',
        description = 'A fungal pathogen that consumes hosts from within. Thrives in damp, dark environments.',
        rarity = 'common',
        transmission = { airborne = 0.7, blood = 0.3, contact = 0.6, animal = 0.4 },
        stages = {
            { threshold = 0, label = 'Spore Inhalation', effects = {} },
            { threshold = 20, label = 'Spore Colonization', effects = { { type = 'coughing', severity = 0.3 }, { type = 'stamina_decay', severity = 0.2 } } },
            { threshold = 40, label = 'Fungal Growth', effects = { { type = 'health_decay', severity = 0.2 }, { type = 'vision_obscured', severity = 0.3 }, { type = 'coughing', severity = 0.6 } } },
            { threshold = 60, label = 'Internal Bloom', effects = { { type = 'health_decay', severity = 0.5 }, { type = 'vision_obscured', severity = 0.6 }, { type = 'random_movement', severity = 0.4 }, { type = 'spore_release', severity = 0.3 } } },
            { threshold = 80, label = 'The Bloom', effects = { { type = 'transformation', strain = 'the_spore' }, { type = 'mass_spore_release', severity = 1.0 } } },
        },
        mutations = {
            'spore_bomb',
            'fungal_armor',
            'spore_sight',
            'mycelium_network',
        },
        cures = {
            { name = 'antifungal_surge', effectiveness = 0.7, ingredients = { 'antifungal', 'steroids', 'filter_mask' } },
            { name = 'cryo_treatment', effectiveness = 0.4, ingredients = { 'liquid_nitrogen', 'ethanol', 'syringe' } },
        },
    },
    ['the_hollow'] = {
        label = 'The Hollow',
        description = 'A pathogen that erodes empathy and cognition, turning hosts into hollow shells driven by base instinct.',
        rarity = 'uncommon',
        transmission = { airborne = 0.2, blood = 0.9, contact = 0.3, animal = 0.1 },
        stages = {
            { threshold = 0, label = 'Exposure', effects = {} },
            { threshold = 20, label = 'Emotional Blunting', effects = { { type = 'screen_grayscale', severity = 0.2 }, { type = 'social_penalty', severity = 0.3 } } },
            { threshold = 40, label = 'Instinct Override', effects = { { type = 'hostile_urges', severity = 0.3 }, { type = 'fear_suppression', severity = 0.5 }, { type = 'pain_suppression', severity = 0.4 } } },
            { threshold = 60, label = 'Hollow Rage', effects = { { type = 'forced_combat', severity = 0.4 }, { type = 'ally_hostile', severity = 0.3 }, { type = 'strength_boost', severity = 0.5 } } },
            { threshold = 80, label = 'The Hollowing', effects = { { type = 'transformation', strain = 'the_hollow' } } },
        },
        mutations = {
            'rage_control',
            'hollow_sense',
            'pack_mind',
            'blood_frenzy',
        },
        cures = {
            { name = 'empathy_regenerator', effectiveness = 0.6, ingredients = { 'neural_stimulator', 'serotonin', 'memory_echo_fragment' } },
            { name = 'lobotomy_patch', effectiveness = 0.3, ingredients = { 'icepick', 'alcohol', 'bandages' } },
        },
    },
    ['the_void'] = {
        label = 'The Void',
        description = 'A reality-warping pathogen that phases matter between dimensions. Extremely rare and dangerous.',
        rarity = 'rare',
        transmission = { airborne = 0.1, blood = 0.4, contact = 0.1, animal = 0.0 },
        stages = {
            { threshold = 0, label = 'Phase Shift', effects = {} },
            { threshold = 15, label = 'Reality Flicker', effects = { { type = 'phase_shift', severity = 0.2 }, { type = 'screen_glitch', severity = 0.3 } } },
            { threshold = 30, label = 'Dimensional Bleed', effects = { { type = 'phase_shift', severity = 0.4 }, { type = 'teleport_random', severity = 0.2 }, { type = 'hallucination', severity = 0.5 } } },
            { threshold = 50, label = 'Void Exposure', effects = { { type = 'phase_shift', severity = 0.7 }, { type = 'health_decay', severity = 0.4 }, { type = 'inventory_corruption', severity = 0.3 } } },
            { threshold = 70, label = 'Void Ascension', effects = { { type = 'transformation', strain = 'the_void' } } },
        },
        mutations = {
            'phase_walk',
            'void_touch',
            'dimensional_pocket',
            'reality_tear',
        },
        cures = {
            { name = 'reality_anchor', effectiveness = 0.9, ingredients = { 'quantum_stabilizer', 'dimensional_core', 'pure_energy_cell' } },
        },
    },
}

NA.Viruses.Resistances = {
    genetic = { label = 'Genetic Resistance', description = 'Natural immunity passed through genes. Rare.', prevalence = 0.05 },
    environmental = { label = 'Environmental Adaptation', description = 'Built up through exposure to harsh conditions.', prevalence = 0.15 },
    synthetic = { label = 'Synthetic Immunity', description = 'Engineered through nano-augmentation.', prevalence = 0.08 },
}

NA.Viruses.Symptoms = {
    screen_glitch = {
        label = 'Screen Glitch',
        description = 'Visual artifacts corrupt your display.',
        treatment = { rest = 0.1, antiviral = 0.4 },
    },
    audio_distortion = {
        label = 'Audio Distortion',
        description = 'Sounds become warped and unsettling.',
        treatment = { rest = 0.1, audio_filter = 0.6 },
    },
    random_movement = {
        label = 'Sporadic Movement',
        description = 'Your body moves involuntarily.',
        treatment = { sedative = 0.5, restraint = 0.3 },
    },
    health_decay = {
        label = 'Health Degeneration',
        description = 'Your body is deteriorating.',
        treatment = { medkit = 0.3, antibiotic = 0.5, rest = 0.2 },
    },
    stamina_decay = {
        label = 'Fatigue',
        description = 'You tire extremely quickly.',
        treatment = { stimulant = 0.5, rest = 0.4, food = 0.2 },
    },
    hallucination = {
        label = 'Hallucinations',
        description = 'You see things that are not there.',
        treatment = { antipsychotic = 0.6, rest = 0.3 },
    },
    coughing = {
        label = 'Violent Coughing',
        description = 'Loud coughing fits that attract attention.',
        treatment = { cough_syrup = 0.5, rest = 0.3, mask = 0.4 },
    },
    vision_obscured = {
        label = 'Blurred Vision',
        description = 'Your vision is partially obscured.',
        treatment = { eye_drops = 0.4, rest = 0.3 },
    },
    social_penalty = {
        label = 'Social Withdrawal',
        description = 'NPCs are less trusting of you.',
        treatment = { time = 0.2, empathy_boost = 0.5 },
    },
    hostile_urges = {
        label = 'Hostile Urges',
        description = 'You feel compelled to attack.',
        treatment = { sedative = 0.5, isolation = 0.3 },
    },
    fear_suppression = {
        label = 'Fear Suppression',
        description = 'You feel no fear. This seems useful, but danger is real.',
        treatment = { adrenaline_regulator = 0.4 },
    },
    pain_suppression = {
        label = 'Pain Suppression',
        description = 'You cannot feel damage. You might not notice you are dying.',
        treatment = { neural_reset = 0.5 },
    },
    phase_shift = {
        label = 'Phase Shift',
        description = 'Your matter is becoming unstable. Objects pass through you.',
        treatment = { reality_anchor = 0.8, quantum_stabilizer = 0.6 },
    },
    teleport_random = {
        label = 'Spatial Displacement',
        description = 'You randomly teleport short distances.',
        treatment = { gravity_anchor = 0.5, reality_anchor = 0.7 },
    },
    inventory_corruption = {
        label = 'Inventory Corruption',
        description = 'Items in your inventory become corrupted or vanish.',
        treatment = { quantum_restoration = 0.5, backup_restore = 0.8 },
    },
    transformation = {
        label = 'Transformation',
        description = 'You are transforming into something else.',
        treatment = { none = 0.0 },
    },
}

NA.Viruses.Treatments = {
    antiviral = { label = 'Antiviral Compound', craftable = true, ingredients = { 'herbs', 'alcohol', 'filter' } },
    antibiotic = { label = 'Antibiotics', craftable = true, ingredients = { 'mold_culture', 'sugar', 'water' } },
    sedative = { label = 'Sedative', craftable = true, ingredients = { 'herbs', 'alcohol', 'syringe' } },
    stimulant = { label = 'Stimulant', craftable = true, ingredients = { 'chemicals', 'caffeine', 'syringe' } },
    antipsychotic = { label = 'Antipsychotic', craftable = true, ingredients = { 'chemicals', 'herbs', 'filter' } },
    reality_anchor = { label = 'Reality Anchor', craftable = true, ingredients = { 'quantum_stabilizer', 'graviton_coil', 'power_cell' } },
}

function NA.Viruses.GetInfectionProgress(currentInfection)
    if currentInfection >= 80 then return 5 end
    if currentInfection >= 60 then return 4 end
    if currentInfection >= 40 then return 3 end
    if currentInfection >= 20 then return 2 end
    return 1
end

function NA.Viruses.GetStageEffects(strainName, infectionLevel)
    local strain = NA.Viruses.Strains[strainName]
    if not strain then return {} end
    local stageIdx = NA.Viruses.GetInfectionProgress(infectionLevel)
    local stage = strain.stages[stageIdx]
    return stage and stage.effects or {}
end

function NA.Viruses.CanMutate(strainName)
    local strain = NA.Viruses.Strains[strainName]
    if not strain or not strain.mutations then return false end
    return #strain.mutations > 0 and math.random() < 0.05
end

function NA.Viruses.GetRandomMutation(strainName)
    local strain = NA.Viruses.Strains[strainName]
    if not strain or not strain.mutations or #strain.mutations == 0 then return nil end
    return strain.mutations[math.random(#strain.mutations)]
end

function NA.Viruses.GetTransmissionChance(strainName, method)
    local strain = NA.Viruses.Strains[strainName]
    if not strain or not strain.transmission then return 0 end
    return strain.transmission[method] or 0
end
