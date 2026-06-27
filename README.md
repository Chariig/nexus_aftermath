# Nexus: Aftermath

## A Custom Standalone FiveM Apocalypse Framework

Nexus: Aftermath is a **completely custom, standalone framework** for FiveM apocalypse servers. 
It does NOT depend on ESX, QBCore, or any other framework. It is its own unique ecosystem.

---

## What Makes It Better Than GT-Ai

### 1. Neural Infection System
Unlike GT-Ai's basic infection, Nexus: Aftermath features **4 unique pathogen strains**:
- **The Glitch** - Digital-physical corruption with screen artifacts and control loss
- **The Spore** - Fungal pathogen with coughing, vision decay, and area contamination
- **The Hollow** - Empathy erosion turning players into hostile NPCs  
- **The Void** - Reality-warping pathogen with phase shifting and dimensional tears

Each strain has **5 stages of progression**, unique **mutations**, and requires specific **craftable cures**.

### 2. Echo Memory System (UNIQUE)
When a player dies, their last moments are recorded as an **Echo** - a memory fragment that persists in the world. Other players can find these echoes, learning what happened and discovering the stories of fallen survivors. Echoes decay over time, creating organic world storytelling that GT-Ai lacks.

### 3. Adaptive World Tier System
The world evolves based on **collective player actions**:
- **Safe Zone** - Resources plentiful, danger low
- **Unstable** - The world is shifting
- **Critical** - Full apocalypse mode
- **Collapse** - Reality breaking down

Player infection rates, building integrity, and active events all influence the world state.

### 4. Scavenger AI with Memory
NPC scavengers that **remember** player interactions. They compete for resources, have distinct personalities (looters, traders, hostiles), and share information with each other. If you're hostile to one scavenger, others in the zone will know.

### 5. Tether System (UNIQUE)
Players can link together via **tethers**, sharing:
- Health pools (damage is distributed)
- Inventory access (teleport items between tethered players)
- Senses (see through each other's proximity)
- Creates emergent team gameplay not found in GT-Ai

### 6. Radio System with Physics
Full frequency-based radio communication with:
- Signal range based on terrain and weather
- Amplifier items to boost range
- Frequency scanning and jamming
- Encrypted transmissions

### 7. Structural Integrity Engine
Buildings aren't static - they have:
- Material decay based on world tier
- Structural integrity that affects health
- Collapse physics that damage nearby entities
- Need for maintenance and repair

### 8. Dynamic Events
Procedurally generated world events:
- Horde migrations
- Toxic storms
- Supply drops
- Earthquakes
- Void tears
- Radiation spikes

---

## Installation

### Requirements
- FiveM FXServer (Recommended build)
- MySQL/MariaDB database
- `oxmysql` resource
- `ox_lib` resource

### Setup

1. Clone this repository to your server's `resources` folder:
```
cp -r nexus_apocalypse /path/to/server/resources/
```

2. Import the database schema:
```
mysql -u root -p nexus_aftermath < resources/nexus_apocalypse/sql/schema.sql
```

3. Configure your `server.cfg`:
```
exec resources/oxmysql/config.cfg
exec resources/nexus_apocalypse/resources.cfg

set mysql_host "localhost"
set mysql_database "nexus_aftermath"
set mysql_username "root"
set mysql_password ""
```

4. Start the server

## Configuration

Edit `config.lua` to customize:
- World tier starting state
- Infection rate multiplier
- Resource availability multiplier
- Safe zone locations
- Building limits
- Tether range and limits
- Radio frequency range

## Keybinds

| Key | Action |
|-----|--------|
| TAB | Open Inventory |
| R | Open Radio |
| C | Open Crafting |
| E | Scan for Echoes |
| B | Enter Build Mode |
| F7 | Toggle HUD |
| ESC | Close UI |

## Unique Features at a Glance

| Feature | Nexus: Aftermath | GT-Ai |
|---------|------------------|-------|
| Framework | Custom standalone | Custom (gtai_) |
| Infection | 4 strains, 5 stages, mutations | Basic infection |
| World Evolution | Dynamic tier system | Static world |
| NPC Memory | Scavengers remember you | Basic wanderers |
| Player Tethers | Health/inventory/sense share | Not present |
| Death Echoes | Persistent memory fragments | Not present |
| Radio Physics | Range/terrain/jamming | Basic chat |
| Building Physics | Integrity/collapse/decay | Basic building |
| Procedural Events | 7 event types | Not present |
| Crafting Skills | 4 skill trees with levels | Basic crafting |

## License
Custom framework - All rights reserved
