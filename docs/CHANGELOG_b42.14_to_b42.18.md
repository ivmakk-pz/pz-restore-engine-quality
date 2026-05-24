# Restore Engine Quality — Game Changes b42.14.0 through b42.18.0

Last published mod version: **1.1.0** (tested on b42.13.1, `versionMin=42.10.0`, single `42/` folder)

This document tracks Project Zomboid changes relevant to updating this mod. The mod patches `ISVehicleMechanics.doPartContextMenu`, uses an `ISBaseTimedAction` subclass, reads/writes engine quality via `vehicle:getEngineQuality()`/`setEngineFeature()`/`transmitEngine()`, and consumes items recursively from player inventory.

---

## Build 42.14.0 — 2026-02-16

### Relevant Changes

- **Fixed "Repair Engine" exploit**: percentage was calculated from all engine parts in backpacks but only removed from main inventory. Confirms the game tightened inventory consumption logic — our `REQ_Inventory.consumeItemsByTypeRecurse()` already handles this correctly by consuming from the actual container holding the item.
- **Fixed max bag/trunk capacity locked at 100**: affects recursive inventory searches when bags were near the false cap.
- **Timed action fixes**: eating with equipped mask, bandages, smoking, destroy-for-fuel. General ISBaseTimedAction stability improvements.
- **Added "Wash Vehicle" to Vehicle Radial Menu**: separate from part context menu system, no conflict with our `doPartContextMenu` hook.
- **Removed fluid container component from vehicle gas tanks**: `VehiclePart` API (`part:getId()`, `part:getVehicle()`) unaffected.
- **Added IsoObjectChange enum**: replaces string-based object change. Our `character:sendObjectChange()` call may need verification.

### Impact: No mod code changes required.

---

## Build 42.14.1 — 2026-02-18

No relevant changes.

---

## Build 42.15.0 — 2026-03-09

### Relevant Changes

- **Fixed error when taking Engine Parts while Wrench is in unequipped bag**: directly affects our flow — mod equips wrench from bag via `ISVehiclePartMenu.toPlayerInventory()` then immediately consumes engine parts via `consumeItemsByTypeRecurse()`. This game fix resolves a latent error in our action sequence.
- **Translation files now use JSON**: `IG_UI.json` and `UI.json` instead of `IG_UI_{LANG}.txt` and `UI_{LANG}.txt`. No language suffix in JSON filenames or keys.
- **Fixed COMMON/VERSION folders detection**: game now only requires one of the two folders. Validates our multi-version directory structure.
- **Added translation support for mod.info** (title, description): optional feature we could adopt.
- **Fixed mod translation loading order**.
- **Fixed ModID/WorkshopID logic**.

### Impact: Localization format change requires JSON files in the 42.15+ folder (already done on release branch). No Lua code changes required.

---

## Build 42.15.1 — 2026-03-10

No relevant changes.

---

## Build 42.15.2 — 2026-03-11

No relevant changes.

---

## Build 42.16.0 — 2026-03-31

### Relevant Changes

- **Fixed fuel consumption for idling engine having wrong calculation**: engine-related calculation change; our `setEngineFeature(quality, loudness, power)` calls set absolute values so this shouldn't conflict, but worth verifying the engine power formula still matches.
- **VehicleRequestPacket rate is limited**: MP throttling on vehicle state changes. Our `vehicle:transmitEngine()` call is a one-shot after restoration completes, not spammed, so no issue.
- **Fixed not being able to transfer single items from stack into loot containers**: general inventory transfer fix.
- **Vehicle Lightbar Control UI Panel can now be repositioned**: confirms vehicle UI system continues to evolve independently of part context menus.
- **Fixed crafting recipes that use Drainable items**: unrelated to our mod but shows recipe system changes.

### Impact: No mod code changes required. Verify engine power formula still matches if vanilla `ISRepairEngine.lua` changed.

---

## Build 42.16.1 — 2026-04-02

No relevant changes.

---

## Build 42.16.2 — 2026-04-08

No relevant changes. (Controller/gamepad vehicle interaction fixes only.)

---

## Build 42.17.0 — 2026-04-20

### Relevant Changes

- **Fixed timed fluid actions not working properly when queued**: confirms ISTimedActionQueue had bugs with sequential actions. Our mod queues pathfind → open hood → restore → close hood. If vanilla fixed queueing issues, our sequence benefits automatically.
- **Fixed exception when uninstalling vehicle parts**: general VehiclePart operation stability.
- **Fixed characters interacting with items from a distance**: tightens interaction range validation. Our action starts after pathfinding to the vehicle area, so we should be fine.
- **Fixed "double-tap" door interactions causing doors to instantly open and close**: relevant to our open/close hood sequence — `ISOpenVehicleDoor`/`ISCloseVehicleDoor` queued actions should work more reliably.

### Impact: No mod code changes required. Our queued action sequence benefits from these fixes.

---

## Build 42.18.0 — 2026-05-11

### Relevant Changes

- **Fixed "Success" or "Failure" text not flashing in the mechanics UI when installing or uninstalling a part**: confirms ISVehicleMechanics UI rendering was updated. Verify our context menu option still renders correctly.
- **Fixed Vehicle name text overflowing in Vehicle Mechanics panel**: UI layout change in the mechanics panel.
- **Fixed vehicle radial menus not closing when exiting/entering vehicles**: radial menu system fix, separate from our part context menu.
- **Fixed "Smash Window" not appearing in vehicle radial menu at certain angles**: more radial menu fixes.
- **Fixed transferring a large stack of items being interrupted on its own**: inventory transfer stability.
- **New Lua APIs added**: `getModTags()`, `setTags()` for CraftRecipe; `getItems()` for InputScript; new zombie speed methods; `SyncFactionServer` event. None directly needed by this mod but shows active API expansion.
- **Fixed crash when remote vehicle with trailer collides**: MP vehicle stability.
- **Fixed calorie burn rate applying incorrectly when sitting in a vehicle**: vehicle state calculation fix.

### Impact: No mod code changes required. Verify mechanics panel UI still displays our context menu option correctly.

---

## Summary: What Needs Updating for v1.2.0

### Required Changes

| Change | Reason |
|--------|--------|
| Multi-version folder structure (`42.12/` + `42.15/`) | Support both legacy and current builds |
| `42.12/mod.info`: add `versionMax=42.12.99` | Lock legacy folder to old builds |
| `42.15/mod.info`: set `versionMin=42.15` | Target current builds |
| Localization: JSON format in `42.15/` | b42.15 switched from .txt to .json |
| Add `common/` folder with `ChangeLog.txt` | In-game changelog alert system |
| Migrate `sendObjectChange` to enum in `42.15/` | Vanilla vehicle actions now use `IsoObjectChange.MECHANIC_ACTION_DONE` instead of string `'mechanicActionDone'` |

### `sendObjectChange` Migration Detail

The mod currently uses:
```lua
self.character:sendObjectChange('mechanicActionDone', { success = true })
```

All vanilla vehicle timed actions in 42.18.0 now use:
```lua
self.character:sendObjectChange(IsoObjectChange.MECHANIC_ACTION_DONE, { success = true })
```

The Java signature changed from `String` to `IsoObjectChange` enum. However, the enum has a `lookup(String)` fallback and one vanilla file (`ClientCommands.lua`) still passes a string in 42.18.0, so strings likely still work through auto-coercion. **Migrate to enum form for correctness and forward compatibility.** The `42.12/` folder should keep the string form since that build predates the enum.

### Verified Unchanged APIs (42.13.1 → 42.18.0)

| API | Status |
|-----|--------|
| `ISVehicleMechanics:doPartContextMenu(self, part, x, y)` | Unchanged |
| `ISBaseTimedAction` lifecycle (isValid, waitToStart, update, start, stop, perform) | Unchanged (new `interruptWaitToStart` added, non-breaking) |
| `ISTimedActionQueue.add()` | Unchanged |
| `ISPathFindAction:pathToVehicleArea(player, vehicle, area)` | Unchanged |
| `ISOpenVehicleDoor:new(character, vehicle, part)` | Logic improved (nil guards added), signature unchanged |
| `ISCloseVehicleDoor:new(character, vehicle, part)` | Logic improved (nil guards added), signature unchanged |
| `ISVehiclePartMenu.toPlayerInventory(player, item)` | Unchanged |
| `ISInventoryPaneContextMenu.equipWeapon(item, primary, twoHands, playerNum)` | Unchanged |
| `VehicleUtils.RequiredKeyNotFound(part, player)` | Unchanged |
| `VehicleUtils.getItems(playerNum)` | Now searches nested containers (beneficial, no code change needed) |
| `vehicle:getEngineQuality()` / `setEngineFeature(quality, loudness, power)` / `transmitEngine()` | Unchanged |
| `VehiclePart:getId()` / `getVehicle()` / `getDoor()` / `getInventoryItem()` | Unchanged |
| `PZAPI.ModOptions` | Unchanged (consumer patterns same) |

### No Code Changes Needed For

- Engine Parts + Wrench-in-bag error (fixed by game in 42.15.0)
- Timed action queueing bugs (fixed by game in 42.17.0)
- Max bag capacity bug (fixed by game in 42.14.0)
- Multi-version mod folder detection (fixed by game in 42.15.0)
- Recursive item search in `VehicleUtils.getItems` (game now handles nested containers)

---

**Covers:** Project Zomboid Builds 42.14.0 through 42.18.0
**Last Updated:** 2026-05-24
**Target Mod Version:** 1.2.0
