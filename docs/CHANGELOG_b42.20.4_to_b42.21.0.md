# Restore Engine Quality - Game Changes b42.20.4 to b42.21.0

Last published mod version: **1.2.2** (tested on b42.20.4 SP & MP, `versionMin=42.17`, single `42/` folder)

This document tracks Project Zomboid changes relevant to updating this mod. The mod patches `ISVehicleMechanics.doPartContextMenu`, uses an `ISBaseTimedAction` subclass registered as the global `ISRestoreEngineQuality`, reads/writes engine quality via `vehicle:getEngineQuality()`/`setEngineFeature()`/`transmitEngine()`, sends `IsoObjectChange.MECHANIC_ACTION_DONE`, and consumes items recursively from player inventory.

Source: `docs/CHANGELOG_42.20.4_to_42.21.0.md` in the `pz-modding-llm-context` repo, plus a diff of every engine method and vanilla Lua function this mod calls.

---

## Build 42.21.0 - 2026-09-28

### Relevant Changes

- **`ISVehicleMechanics.lua` changed**: only the keybind code (`isKeyConsumed`, `onKeyRelease`) moved to `KeybindId` constants. `doPartContextMenu`, which this mod wraps, is unchanged.
- **`ISVehicleMenu.lua` changed**: only the keybind handlers (`onKeyPressed`, `onKeyStartPressed`). `ISVehicleMenu.onExit` is unchanged.
- **`ISEquipWeaponAction:getDuration()` removed**: the action now uses the base `maxTime`, so the old `0` duration for an item already in hand is gone. No effect here: `ISEquipWeaponAction:start()` still calls `forceComplete()` when the wrench is already equipped, so `equipWeapon` adds no delay before the restore action.
- **`Vehicles.lua` changed**: `Vehicles.CheckEngine.GasTank` now uses `hasEnoughGasToRun()`, and an engine with too little gas fails with `EngineNotWorking` instead of `OutOfFuel`. Headlight init no longer creates items. None of these touch engine quality, and `VehicleUtils.getItems` / `VehicleUtils.RequiredKeyNotFound` are unchanged.
- **`IsoObjectChange` gained `VEHICLE_HIT_OBJECT`**: it is appended at the end, so `MECHANIC_ACTION_DONE` keeps its ordinal.
- **New action-tracking signatures** (`isActionDone(player, id)` and related): this mod does not call them. Its timed action uses the standard `ISBaseTimedAction` flow.
- **Server blocks item transfers in no-loot safehouses**: this applies to container transfers. The mod consumes engine parts with `DoRemoveItem`, which is not a transfer.
- **Name matches that are not this mod's API**: `IsoGridSquare:getDoor(boolean)` was removed, but the mod calls `VehiclePart:getDoor()`, which is unchanged. The `addItem` / `getDuration` / `remove` signature changes are on `TradingManager` and `ActionManager`, which are not exposed to Lua.

### Impact: No mod code changes required.

---

## API Verification (b42.21.0)

| API used by the mod | Status in 42.21.0 |
|---|---|
| `ISVehicleMechanics.doPartContextMenu` (wrapped) | Unchanged |
| `ISVehicleMenu.onExit(player)` | Unchanged |
| `ISInventoryPaneContextMenu.equipWeapon(item, primary, twoHands, playerNum)` | Unchanged; the queued `ISEquipWeaponAction` lost `getDuration()` but still force-completes when already equipped |
| `ISVehiclePartMenu.toPlayerInventory(player, item)` | Unchanged |
| `ISPathFindAction:pathToVehicleArea(player, vehicle, area)` | Unchanged |
| `ISOpenVehicleDoor` / `ISCloseVehicleDoor` / `ISUnlockVehicleDoor` | Unchanged |
| `VehicleUtils.getItems(playerNum)` / `VehicleUtils.RequiredKeyNotFound(part, player)` | Unchanged |
| `vehicle:getEngineQuality()` / `getEngineLoudness()` / `getEnginePower()` / `setEngineFeature(...)` / `transmitEngine()` / `getPartById(id)` | Unchanged |
| `VehiclePart:getId()` / `getVehicle()` / `getDoor()` / `getInventoryItem()` / `getArea()` | Unchanged |
| `VehicleDoor:isOpen()` / `isLocked()` | Unchanged |
| `character:sendObjectChange(IsoObjectChange.MECHANIC_ACTION_DONE, ...)` | Unchanged |
| `ItemContainer:getFirstTypeRecurse` / `getFirstTagEvalRecurse` / `containsTypeRecurse` / `getNumberOfItem` / `DoRemoveItem` | Unchanged |
| `ISBaseTimedAction` (`new`, `isValid`, `start`, `stop`, `perform`, `complete`, `getDuration`) | Unchanged |
| `PZAPI.ModOptions` | Unchanged |

### Release Checklist for 1.2.3

- Load the mod on b42.21.0 in SP and on a dedicated server (MP), restore an engine once each, and check `console.txt` and `DebugLog-server.txt` for errors.
- After the in-game test passes, change the "tested on" line in `workshop_description.bbcode` to b42.21.0.

---

**Covers:** Project Zomboid Build 42.21.0
**Last Updated:** 2026-10-13
**Target Mod Version:** 1.2.3
