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
| Mechanics Level | Standard Cars (requires 4) | Heavy-Duty Cars (requires 5) | Sports / Luxury / Modern (requires 6) |
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

Mod logging: toggle `DEBUG_MODE` in `REQ_Utils.lua`. Messages are prefixed `[REQ]`; with debug off only warnings and errors print.

**Set engine quality to 30% via Lua console** — single player only, stand next to the car:
```
local v = getPlayer():getNearVehicle(); if v then local p = v:getScript():getEngineForce() * 0.6; v:setEngineFeature(30, v:getEngineLoudness() * 2.7, p); v:transmitEngine() end
```
`setEngineFeature` divides loudness by 2.7 internally, so pass `loudness * 2.7` to leave loudness unchanged.

This does nothing in multiplayer: engine state is server-authoritative and `transmitEngine()` is a no-op on clients. Engine quality also cannot be lowered through gameplay — it is set when the vehicle is created, and installing an engine part resets it to 100%, so admin-spawned vehicles always start at 100%. For a server-side way to set it, see [`dev/README.md`](dev/README.md).

## License

GPL-3.0. Copyright (C) 2025 ivmakk.

You are free to use, study, and modify this mod. Any redistributed or reuploaded modified version must stay GPL-3.0, keep the original author credit, and publish its full source. Contributions back to the repository are welcome. See [`LICENSE`](LICENSE) for the full text.

Note: this license is not retroactive. Versions released before the relicense stay under their original MIT terms for whoever holds them; GPL-3.0 applies going forward.
