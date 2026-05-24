# Restore Engine Quality

[![Steam Workshop](https://img.shields.io/badge/Steam%20Workshop-View-blue)](https://steamcommunity.com/sharedfiles/filedetails/?id=3543612325)

A Project Zomboid mod that allows players to restore degraded vehicle engine quality beyond standard repair limits.

## Features

- **Engine Quality Restoration**: Improve engine quality from any percentage up to 100%
- **Skill-Based Mechanics**: Higher Mechanics skill provides better quality increases per iteration
- **Configurable Resource Cost**: Adjust engine parts consumption (1-5 per restoration, default: 2)
- **Smart Integration**: Seamless vehicle mechanics menu integration with mod compatibility

## Usage

**Requirements**: Wrench, Engine Parts, appropriate Mechanics skill level, vehicle key  
**Access**: Right-click vehicle engine part → "Restore Engine Quality"  
**Process**: Each restoration consumes engine parts and improves quality based on your skill

## How It Works

**Engine Quality vs Engine Condition:**
- **Engine Condition** (repairable in vanilla): Physical state of engine parts, affects durability
- **Engine Quality** (this mod): Inherent engine performance rating (0-100%), affects:
  - Engine starting reliability (lower quality = higher chance to fail starting)
  - Engine power output (higher quality = more horsepower)
  - Cold weather starting (quality ≤65% struggles in cold weather)

Quality improvement per restoration = `1 + (Mechanics Level - Required Level) / 2` (max 5%)

**Restoration Results by Mechanics Level:**
| Mechanics Level | Standard Cars (1%) | Heavy-Duty Cars (1%) | Sports Cars (1%) |
|-----------------|--------------------|--------------------|------------------|
| 4               | 1%                 | n/a                | n/a              |
| 5               | 1%                 | 1%                 | n/a              |
| 6               | 2%                 | 1%                 | 1%               |
| 7               | 2%                 | 2%                 | 1%               |
| 8               | 3%                 | 2%                 | 2%               |
| 9               | 3%                 | 3%                 | 2%               |
| 10              | 4%                 | 3%                 | 3%               |

## Requirements

- Project Zomboid Build 42.17+
- Compatible with most vehicle and mechanics mods

## Debug / Testing

Enable debug mode in PZ, open Vehicle Mechanics panel, click `ISVehicleMechanics.cheat=true` at the top to enable cheat options. Then RMB on Engine to access "CHEAT: Get Key" for a vehicle key.

**Set engine quality to 30% via Lua console** (stand next to car):
```
local v = getPlayer():getNearVehicle(); if v then local p = v:getScript():getEngineForce() * 0.6; v:setEngineFeature(30, v:getEngineLoudness(), p); v:transmitEngine() end
```
