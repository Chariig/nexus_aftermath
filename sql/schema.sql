-- Nexus: Aftermath Database Schema

CREATE DATABASE IF NOT EXISTS nexus_aftermath;
USE nexus_aftermath;

-- Players table (multicharacter support)
CREATE TABLE IF NOT EXISTS na_players (
    citizenId VARCHAR(50) PRIMARY KEY,
    license VARCHAR(100) NOT NULL,
    name VARCHAR(100),
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10) DEFAULT 'male',
    dateofbirth VARCHAR(20) DEFAULT 'Unknown',
    appearance TEXT DEFAULT '{}',
    health INT DEFAULT 200,
    armor INT DEFAULT 0,
    hunger INT DEFAULT 100,
    thirst INT DEFAULT 100,
    infection_strain VARCHAR(50) DEFAULT NULL,
    infection_level INT DEFAULT 0,
    infection_mutations TEXT DEFAULT '[]',
    stats TEXT DEFAULT '{"strength":10,"endurance":10,"perception":10,"intelligence":10,"agility":10,"luck":10}',
    inventory TEXT DEFAULT '[]',
    position TEXT DEFAULT '{}',
    skills TEXT DEFAULT '{"crafting":0,"combat":0,"survival":0,"medical":0}',
    reputation TEXT DEFAULT '{}',
    playtime INT DEFAULT 0,
    last_played TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_license (license),
    INDEX idx_name (name)
);

-- Buildings/Structures
CREATE TABLE IF NOT EXISTS na_buildings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    owner_citizenId VARCHAR(50),
    structure_type VARCHAR(50),
    pos_x FLOAT, pos_y FLOAT, pos_z FLOAT,
    rot_x FLOAT DEFAULT 0, rot_y FLOAT DEFAULT 0, rot_z FLOAT DEFAULT 0,
    health INT DEFAULT 100,
    max_health INT DEFAULT 100,
    integrity INT DEFAULT 100,
    data TEXT DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_owner (owner_citizenId),
    INDEX idx_type (structure_type),
    INDEX idx_pos (pos_x, pos_y, pos_z)
);

-- Echoes (memory fragments)
CREATE TABLE IF NOT EXISTS na_echoes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    creator_citizenId VARCHAR(50),
    pos_x FLOAT, pos_y FLOAT, pos_z FLOAT,
    event_type VARCHAR(50),
    data TEXT,
    recording MEDIUMTEXT,
    decay_at BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_pos (pos_x, pos_y, pos_z),
    INDEX idx_creator (creator_citizenId),
    INDEX idx_event_type (event_type),
    INDEX idx_decay (decay_at)
);

-- Factions
CREATE TABLE IF NOT EXISTS na_factions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE,
    tag VARCHAR(10) UNIQUE,
    owner_citizenId VARCHAR(50),
    members TEXT DEFAULT '[]',
    reputation TEXT DEFAULT '{}',
    territory TEXT DEFAULT '{}',
    color VARCHAR(7) DEFAULT '#FFFFFF',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_owner (owner_citizenId),
    INDEX idx_name (name)
);

-- World state persistence
CREATE TABLE IF NOT EXISTS na_world_state (
    id INT AUTO_INCREMENT PRIMARY KEY,
    `key` VARCHAR(100) UNIQUE,
    value TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_key (`key`)
);

-- Staff administration
CREATE TABLE IF NOT EXISTS na_staff (
    citizenId VARCHAR(50) PRIMARY KEY,
    `rank` VARCHAR(20) DEFAULT 'moderator',
    permissions TEXT DEFAULT '[]',
    assigned_by VARCHAR(50),
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_rank (`rank`)
);

-- Radio frequency history
CREATE TABLE IF NOT EXISTS na_radio_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    frequency FLOAT,
    sender_citizenId VARCHAR(50),
    message TEXT,
    transmission_range FLOAT,
    encrypted BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_freq (frequency),
    INDEX idx_sender (sender_citizenId),
    INDEX idx_sent_at (sent_at)
);

-- Player kill/death tracking
CREATE TABLE IF NOT EXISTS na_combat_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    attacker_citizenId VARCHAR(50),
    victim_citizenId VARCHAR(50),
    weapon VARCHAR(50),
    damage INT,
    pos_x FLOAT, pos_y FLOAT, pos_z FLOAT,
    occurred_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_attacker (attacker_citizenId),
    INDEX idx_victim (victim_citizenId),
    INDEX idx_occurred (occurred_at)
);

-- Player economy/transactions
CREATE TABLE IF NOT EXISTS na_economy (
    id INT AUTO_INCREMENT PRIMARY KEY,
    citizenId VARCHAR(50),
    transaction_type VARCHAR(20),
    item_name VARCHAR(50),
    amount INT,
    balance_before INT,
    balance_after INT,
    location TEXT,
    transacted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_citizen (citizenId),
    INDEX idx_type (transaction_type),
    INDEX idx_time (transacted_at)
);

-- Server ban list
CREATE TABLE IF NOT EXISTS na_bans (
    id INT AUTO_INCREMENT PRIMARY KEY,
    license VARCHAR(100),
    citizenId VARCHAR(50),
    reason TEXT,
    banned_by VARCHAR(50),
    ban_expiry BIGINT,
    banned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_license (license),
    INDEX idx_citizen (citizenId)
);

-- Server events log
CREATE TABLE IF NOT EXISTS na_event_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    event_type VARCHAR(50),
    event_name VARCHAR(100),
    initiator VARCHAR(50),
    pos_x FLOAT, pos_y FLOAT, pos_z FLOAT,
    data TEXT,
    occurred_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_event_type (event_type),
    INDEX idx_occurred (occurred_at)
);

-- Default world state
INSERT IGNORE INTO na_world_state (`key`, value) VALUES ('world_tier', 'safe');
INSERT IGNORE INTO na_world_state (`key`, value) VALUES ('world_score', '100');
INSERT IGNORE INTO na_world_state (`key`, value) VALUES ('total_deaths', '0');
INSERT IGNORE INTO na_world_state (`key`, value) VALUES ('total_infections', '0');
INSERT IGNORE INTO na_world_state (`key`, value) VALUES ('server_uptime', '0');
