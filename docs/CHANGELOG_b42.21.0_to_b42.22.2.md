# Restore Engine Quality - Game Changes b42.21.0 to b42.22.2

Last published mod version: **1.2.3** (tested on b42.21.0 SP & MP, `versionMin=42.17`, single `42/` folder)

This document tracks Project Zomboid changes relevant to updating this mod. The mod patches `ISVehicleMechanics.doPartContextMenu`, uses an `ISBaseTimedAction` subclass registered as the global `ISRestoreEngineQuality`, reads/writes engine quality via `vehicle:getEngineQuality()`/`setEngineFeature()`/`transmitEngine()`, sends `IsoObjectChange.MECHANIC_ACTION_DONE`, and consumes items recursively from player inventory.

Source: `docs/CHANGELOG_42.21.0_to_42.22.2.md` and `release_notes/42.22.*.md` in the `pz-modding-llm-context` repo, the repo's `scan_mods.py` and `typecheck_mods.py` checkers (`--old 42.21.0 --target 42.22.2`, and in reverse against `42.15.2`, the nearest tag below `versionMin`), plus a diff of the vehicle Lua, `BaseVehicle`, `ItemContainer` and `LuaTimedActionNew`.

---

## Build 42.22.0 to 42.22.2 - 2026-10-27 to 2026-11-09

42.22 first went to the new Pre-Release branch (42.22.0, hotfix 42.22.1) and reached Stable as 42.22.2.

### Relevant Changes

- **`IsoPlayer:isTimedActionInstant()` override removed**: the mod calls it in `getDuration()`. The method is still on `IsoGameCharacter` with the same signature. The base method now does the permission check with `Capability.UseTimedActionInstantCheat` in place of the old MP access-level check. No change needed.
- **`ISRepairEngine:complete()` hardened**: vanilla now also returns false when `self.part:getId() ~= "Engine"`, so a client cannot send another part. The mod's `complete()` checks only `not self.part`. Optional hardening, not a break.
- **`LuaTimedActionNew` (networked timed actions)**: `ActionManager` calls take `IsoPlayer` in place of `PlayerID`, and `stop()` now sends a `GeneralAction` packet so the server cancels the action too. The confirm/reject flow that ends the client action is the same. The mod does not call `ActionManager`.
- **`VehicleCommands` lost `fixPart`, `setTirePressure`, `setDoorOpen`**: the mod does not send vehicle commands.
- **Container methods return `List` in place of `PZArrayList`**: the mod does not call the affected methods (`getVehicleItemContainers`, `getAllContainers` and others).
- **Release notes**: car keys no longer appear next to untouched cars after the player returns to the area, and crowbar forcing is new for doors and windows of buildings. Neither changes the vehicle lock check (`VehicleUtils.RequiredKeyNotFound` is unchanged).

### Impact: No mod code changes required.

---

## API Verification (b42.22.2)

| API used by the mod | Status in 42.22.2 |
|---|---|
| `ISVehicleMechanics.doPartContextMenu` (wrapped) | Unchanged |
| `ISVehicleMenu.onExit(player)` | File changed, function body unchanged |
| `ISInventoryPaneContextMenu.equipWeapon(item, primary, twoHands, playerNum)` | File changed, function body unchanged |
| `ISVehiclePartMenu.toPlayerInventory(player, item)` | File changed, function body unchanged |
| `ISPathFindAction:pathToVehicleArea(player, vehicle, area)` | Unchanged |
| `ISOpenVehicleDoor` / `ISCloseVehicleDoor` / `ISUnlockVehicleDoor` | Unchanged |
| `ISTimedActionQueue.add` / `hasActionType` | File changed, function bodies unchanged |
| `VehicleUtils.getItems(playerNum)` / `VehicleUtils.RequiredKeyNotFound(part, player)` | Unchanged |
| `vehicle:getEngineQuality()` / `getEngineLoudness()` / `getEnginePower()` / `setEngineFeature(...)` / `transmitEngine()` / `getPartById(id)` | Unchanged |
| `character:isTimedActionInstant()` | Override on `IsoPlayer` removed, base method on `IsoGameCharacter` unchanged in signature |
| `ItemContainer:getFirstTypeRecurse` / `getFirstTagEvalRecurse` / `containsTypeRecurse` / `getNumberOfItem` / `DoRemoveItem` | Unchanged |
| `ISBaseTimedAction` (`new`, `isValid`, `start`, `stop`, `perform`, `complete`, `getDuration`) | Unchanged |
| `PZAPI.ModOptions` | Unchanged |

Type check: the same diagnostics on 42.21.0 and 42.22.2, and on 42.22.2 and 42.15.2. None only on the target build.

### Release Checklist

- [x] Load the mod on b42.22.2 in SP and on a dedicated server (MP), restore an engine once each, and check `console.txt` and `DebugLog-server.txt` for errors. Done 2026-11-10: SP and nosteam dedicated server (client and server both `version=42.22.2`). The restore completed on a vanilla car and on the KI5 '91 Range Rover (`damnlib` + `91range`), and vanilla Repair Engine also completed. No Lua stack traces or `Perform failed` lines in either log.
- [x] After the in-game test passes, change the "tested on" line in `workshop_description.bbcode` to b42.22.2.
- Optional: add the vanilla `self.part:getId() ~= "Engine"` check to `REQ_ISRestoreEngineQuality:complete()`.

---

**Covers:** Project Zomboid Build 42.22.0 to 42.22.2

**Last Updated:** 2026-11-10
