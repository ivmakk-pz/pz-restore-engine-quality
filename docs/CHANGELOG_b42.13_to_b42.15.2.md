# Restore Engine Quality - Changelog for b42.13.1 through b42.15.2

## Overview

This document tracks relevant Project Zomboid game changes from **Build 42.13.1** through **Build 42.15.2** that affect vehicle mechanics, engine systems, inventory APIs, or this mod's functionality.

The mod hooks into `ISVehicleMechanics.doPartContextMenu`, reads engine quality via `vehicle:getEngineQuality()`, updates it via `vehicle:setEngineFeature()`, syncs it via `vehicle:transmitEngine()`, and searches/consumes Engine Parts recursively across all carried containers via `getInventory():getFirstTypeRecurse()` / `containsTypeRecurse()` / `getNumberOfItem()`.

---

## Build 42.13.1 — December 18, 2025

**Source:** https://theindiestone.com/forums/index.php?/topic/89477-42131-unstable-hotfix-released/

### 🔧 Direct Bug Fixes

- **Fixed Ratchet Wrench causing error when taking Engine Parts**
  - Any action that consumed Engine Parts from inventory while a Ratchet Wrench was present could throw an exception
  - This affected the vanilla engine repair flow and would have equally affected this mod's `REQ_Inventory.consumeItemsByTypeRecurse()`, which removes Engine Parts from containers one by one via `getFirstTypeRecurse()`

- **Fixed exception when trying to start an engine while there is no battery installed**
  - Starting an engine when no battery was present caused a Java exception
  - Relevant because this mod calls `vehicle:transmitEngine()` after updating engine quality; a missing battery edge case could have caused follow-on errors in prior builds

### 🚗 Vehicle Stability

- Fixed vehicles getting stuck in the air after collisions (general vehicle world-state stability)

### 💡 Impact on Restore Engine Quality

- No mod code changes required
- The Engine Parts consumption fix in this patch means the mod's part-removal logic is no longer at risk of triggering the wrench-related exception observed in 42.13.0

---

## Build 42.13.2 — January 19, 2026

**Source:** https://theindiestone.com/forums/index.php?/topic/90923-42132-unstable-hotfix-released/

### 🔄 Changes Overview

No vehicle mechanics, engine, or inventory API changes relevant to this mod. Fixes were focused on MP stability, animal pathfinding, and fluid/container bugs.

### 💡 Impact on Restore Engine Quality

- No changes required — full compatibility maintained

---

## Build 42.14.0 — February 16, 2026

**Source:** https://theindiestone.com/forums/index.php?/topic/91647-42140-unstable-released/

### 🚗 Vehicle System Changes

- **Added "Wash Vehicle" to Vehicle Radial Menu**
  - A new option was added to the vehicle radial/context menu system
  - This mod extends `ISVehicleMechanics.doPartContextMenu` by storing and chaining the original method. The "Wash Vehicle" entry is added to the radial menu (a separate system), so there is no conflict — but it confirms the vehicle context menu API continues to be extended by the game

- **Fine-tuned VehicleHit mechanics in SP/MP**
  - Vehicle damage handling reworked for both singleplayer and multiplayer
  - `vehicle:transmitEngine()` (used by this mod after each restoration) is unaffected; this change relates to collision damage packets

- **Removed the fluid container component from vehicle gas tanks**
  - API-level change to vehicle part scripts; the `VehiclePart` API used by this mod (`part:getId()`, `part:getVehicle()`) is unaffected — only the gas tank's fluid container component was removed

- **Fixed vehicle and trailer teleport to north-west corner of a chunk**
  - General vehicle position stability in MP; ensures `vehicle:transmitEngine()` sends data for the correct vehicle instance

- **Fixed max bag/trunk capacity locked at 100**
  - Container capacity was capped at 100 regardless of actual value
  - Relevant to `REQ_Inventory`: the mod recurses into bags worn by the player to find and consume Engine Parts; inaccurate capacity reporting could have caused edge cases when the inventory was near the false cap

### ⚖️ New Behavior in Vehicles

- **Characters with an encumbrance moodle in a vehicle will accumulate discomfort**
  - New game mechanic: being overloaded while riding in a vehicle now causes discomfort
  - The mod calls `vehicle:setEngineFeature()` and `vehicle:transmitEngine()` while the player is standing outside the vehicle, so this does not affect restoration actions; noted for awareness

### 💡 Impact on Restore Engine Quality

| Area                                                    | Status                                                                     |
| ------------------------------------------------------- | -------------------------------------------------------------------------- |
| `ISVehicleMechanics.doPartContextMenu` chain override   | Unaffected — new vehicle menu options are in a separate system             |
| `REQ_Inventory` recursive container search              | Improved — bag capacity bug fixed, less risk of false inventory-full state |
| `vehicle:transmitEngine()` sync                         | Unaffected by vehicle damage changes                                       |
| `VehiclePart` API (`part:getId()`, `part:getVehicle()`) | No changes                                                                 |

No mod code changes required.

---

## Build 42.14.1 — February 18, 2026

**Source:** https://theindiestone.com/forums/index.php?/topic/91799-42141-unstable-hotfix-released/

### 🔄 Changes Overview

SP and MP hotfix only — vehicle exit stuck fix, weapon sync, and hearing trait fixes. No engine, vehicle mechanics API, or inventory changes.

### 💡 Impact on Restore Engine Quality

- No changes required — full compatibility maintained

---

## Build 42.15.0 — March 9, 2026

**Source:** https://theindiestone.com/forums/index.php?/topic/92435-42150-unstable-released/

### 🔧 Critical Direct Fix

- **Fixed error that occurred when taking Engine Parts while a Wrench was in an unequipped bag**
  - This is the most directly relevant fix in the entire 42.13–42.15 range
  - The exact scenario this mod creates: the mod auto-equips a Wrench from the player's inventory (potentially from a bag) via `ISVehiclePartMenu.toPlayerInventory()` and `ISInventoryPaneContextMenu.equipWeapon()`, then immediately initiates the timed restoration action which calls `REQ_Inventory.consumeItemsByTypeRecurse()` to remove Engine Parts across all containers
  - In prior builds, having the Wrench in an unequipped bag while taking Engine Parts threw an error — this would have fired during or just after the mod's action sequence
  - **After this fix:** the full mod flow (equip wrench from bag → restore engine → consume parts from containers) runs without errors

### 🛠️ Modding System Fixes

- **Fixed `COMMON/VERSION` folders not being detected correctly**
  - Game now only requires one of the two folders — directly relevant to this mod's `common/` + `42.15/` directory structure
- **Translation files are now JSON** — this mod's `42.15` folder already uses `UI.json` and `IG_UI.json`, so no action required
- Fixed mod translation loading order
- Fixed mod file comparison between client and server
- Fixed `ModID` / `WorkshopID` logic
- Added translation support for `mod.info` (title, description)

### 💡 Impact on Restore Engine Quality

| Area                                           | Status                                                       |
| ---------------------------------------------- | ------------------------------------------------------------ |
| Engine Parts + Wrench-in-bag error             | **Fixed by game** — mod flow now error-free in this scenario |
| `REQ_Inventory.consumeItemsByTypeRecurse()`    | Now fully safe when Wrench is in an unequipped bag           |
| Translation files (`UI.json`, `IG_UI.json`)    | Already in correct JSON format — no action needed            |
| Mod directory structure (`common/` + `42.15/`) | Now reliably detected by game engine                         |

No mod code changes required. The Engine Parts fix automatically resolves the previously latent error in the mod's restore sequence.

---

## Build 42.15.1 — March 10, 2026

**Source:** https://theindiestone.com/forums/index.php?/topic/92519-42151-unstable-hotfix-released/

### 🔄 Changes Overview

Single fix: game not loading when username contains non-ASCII characters. No vehicle, engine, or mod-system changes.

### 💡 Impact on Restore Engine Quality

- No changes required — full compatibility maintained

---

## Build 42.15.2 — March 11, 2026

**Source:** https://theindiestone.com/forums/index.php?/topic/92591-42152-unstable-hotfix-released/

### 🔄 Changes Overview

Three fixes: additional non-ASCII username loading fix, animals not moving when rope is attached, and `GlobalModDataPacket` error. No vehicle or mod-system changes.

### 💡 Impact on Restore Engine Quality

- No changes required — full compatibility maintained

---

## Summary Table

| Version | Date       | Relevant Changes                                                                                                           | Mod Update Required                               |
| ------- | ---------- | -------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------- |
| 42.13.1 | 2025-12-18 | Ratchet Wrench + Engine Parts error fixed; engine start exception fixed                                                    | No                                                |
| 42.13.2 | 2026-01-19 | None                                                                                                                       | No                                                |
| 42.14.0 | 2026-02-16 | Vehicle context menu extended; bag capacity bug fixed; vehicle sync stability                                              | No                                                |
| 42.14.1 | 2026-02-18 | None                                                                                                                       | No                                                |
| 42.15.0 | 2026-03-09 | **Engine Parts + unequipped Wrench-bag error fixed** (directly affects mod's action sequence); modding system improvements | No (game fix resolves latent error automatically) |
| 42.15.1 | 2026-03-10 | None                                                                                                                       | No                                                |
| 42.15.2 | 2026-03-11 | None                                                                                                                       | No                                                |

---

**Last Updated:** March 15, 2026
**Covers:** Project Zomboid Builds 42.13.1 through 42.15.2
**Mod Version at Time of Writing:** 1.1.0
