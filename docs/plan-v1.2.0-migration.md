# v1.2.0 — Migrate to Latest Game Build (42.18.0)

## Goal

Update the Restore Engine Quality mod from its last published state (v1.1.0, tested on b42.13.1, single `42/` folder) to support the current game build (42.18.0).

## Context

- Published mod: v1.1.0 on master, `versionMin=42.10.0`, single `42/` folder
- Release branch `release/1.2.0` already has: multi-version folders (`42.12/` + `42.15/`), JSON localization in 42.15, updated `PZ_files/` references
- API verification (see `docs/CHANGELOG_b42.14_to_b42.18.md`): only one breaking change — `sendObjectChange` must use `IsoObjectChange.MECHANIC_ACTION_DONE` enum instead of string
- All other APIs (doPartContextMenu, ISBaseTimedAction, setEngineFeature, transmitEngine, VehicleUtils, inventory) are confirmed unchanged between 42.13.1 and 42.18.0
- **Multi-version dropped**: Steam "outdatedunstable" and "unstable" branches are both at 42.18.0. Default public is B41 (irrelevant, different codebase). No B42 player is on a build older than 42.15. Single `42/` folder with `versionMin=42.15` covers the entire player base.

## Scope

- Structural: revert to single `42/` folder, drop `42.12/`, add `ChangeLog.txt` for in-game alerts
- Code: fix sendObjectChange enum, wrench tag lookup, DoRemoveItem, DEBUG_MODE
- Metadata: version bump, versionMin update
- Docs: changelogs, workshop update notes

## Out of Scope

- New features or gameplay changes (those come after migration)
- Localization for additional languages (separate task via `/pz-mod-localization`)
- Build 41 support (completely different codebase, not our audience)

## Implementation Plan

> **Rule**: Check off each step as it is completed. Update this plan if blockers or scope changes are encountered.

### 1. Revert to single version folder

The release branch currently has `42.12/` + `42.15/`. Simplify back to a single `42/` folder based on the 42.15 source (which has JSON localization and current code).

- [x] Rename `42.15/` to `42/`
- [x] Delete `42.12/` folder entirely
- [x] Update `42/mod.info`: set `versionMin=42.17`, remove `versionMax` if present
- [x] Verify JSON localization files are in place (`42/media/lua/shared/Translate/EN/IG_UI.json`, `UI.json`)

### 2. Add `common/` folder and in-game changelog alert

The `common/` folder is a sibling of the version folder (not inside it). Required for proper mod visibility in-game — all other mods (ForagingTooltipExtended, BoilingEggs, template) have it.

- [x] Create `Contents/mods/RestoreEngineQuality/common/` directory — already existed
- [x] Add `common/.gitkeep`
- [x] Create `common/ChangeLog.txt` with entries for v1.0.0 and v1.1.0 (oldest at top, newest at bottom)

### 3. Move timed action + dependencies to `shared/` (MP compatibility)

Vanilla vehicle timed actions (`ISRepairEngine`, etc.) live in `shared/` so the server can load them. Our timed action is in `client/`, causing `"no such function ISRestoreEngineQuality.new"` in MP. Move it and the modules it `require`s to `shared/`. Client-only UI modules stay in `client/` (they can import from `shared/`).

**Move to `media/lua/shared/`:**
- [x] `REQ_ISRestoreEngineQuality.lua` — timed action (requires REQ_Requirements, REQ_Utils, REQ_Inventory, REQ_RestorationPlan)
- [x] `REQ_Requirements.lua` — used by timed action's `isValid()`
- [x] `REQ_RequirementResults.lua` — data container returned by REQ_Requirements
- [x] `REQ_RestorationPlan.lua` — used by timed action's `complete()`
- [x] `REQ_Inventory.lua` — used by timed action's `complete()` for item consumption
- [x] `REQ_ModOptions.lua` — value getter used by REQ_RestorationPlan
- [x] `REQ_Utils.lua` — logging utility used by all modules

**Keep in `media/lua/client/`:**
- [x] `REQ_Client.lua` — entry point, hooks `Events.OnInitGlobalModData`
- [x] `REQ_ISVehicleMechanics.lua` — patches context menu UI
- [x] `REQ_Tooltips.lua` — builds ISToolTip (client-only UI class)

### 4. Fix code issues

Issues identified by comparing mod code against vanilla b42.18 implementations.

**sendObjectChange enum migration (REQ_ISRestoreEngineQuality.lua:90):**
- [x] Change `self.character:sendObjectChange('mechanicActionDone', { success = true })` to `self.character:sendObjectChange(IsoObjectChange.MECHANIC_ACTION_DONE, { success = true })`

**Wrench lookup: use tag instead of type string (CRITICAL):**
- [x] `REQ_ISVehicleMechanics.lua` (`onRestoreEngineQuality`): capture `tagToItem` from `VehicleUtils.getItems(playerNum)`, use `tagToItem[ItemTag.WRENCH][1]`
- [x] `REQ_Requirements.lua` (`checkWrenchRequirement`): use `getFirstTagEvalRecurse(ItemTag.WRENCH, predicateNotBroken)`

**Item removal: use DoRemoveItem (REQ_Inventory.lua:36):**
- [x] Replace `container:Remove(item)` with `container:DoRemoveItem(item)` in `consumeItemsByTypeRecurse`

**DEBUG_MODE (REQ_Utils.lua):**
- [x] Set `DEBUG_MODE = false` for production release

### 5. Remove `PZ_files/` reference folder

Redundant — vanilla source files are available version-tagged in the game context repo via the `pz-modding` skill. Keeping local copies risks acting on stale references.

- [x] Delete `PZ_files/` directory entirely

### 6. Prepare release metadata

- [x] Bump `modversion=1.2.0` in `42/mod.info`
- [x] Update `CHANGELOG.md`: move unreleased entries to `## [1.2.0] - 2026-05-24` section
- [x] Update `workshop_assets/workshop_updates.txt` with plain text entry
- [x] Append v1.2.0 entry to `common/ChangeLog.txt` (at bottom)
- [x] ~~Update README.md version badge~~ — no version badge exists, skipped

### 7. Verify

- [x] Launch PZ on latest build (42.18.0), load the mod
- [x] Open vehicle mechanics menu on a car with engine quality < 100%
- [x] Confirm "Restore Engine Quality" option appears with correct tooltip
- [x] Perform restoration: verify parts consumed, quality increases, XP granted
- [x] Test with `Base.Wrench` — requirement shows green, action executes
- [x] Test with Ratchet Wrench (or any WRENCH-tagged item) — same result
- [x] After restoration, confirm mechanics UI flashes green (sendObjectChange fires correctly)
- [x] Check player carry weight updates after consuming engine parts (DoRemoveItem working)
- [x] Confirm no `[REQ] DEBUG` spam in console
- [x] ~~Check multiplayer sync~~ — out of scope for SP-focused release
- [x] Verify mod options slider works (Settings → Mods → Restore Engine Quality)
- [x] Verify `ChangeLog.txt` displays in-game alert on first load after update (via Mod Change Log mod)
- [x] Test on modded vehicle (KI5) — restoration works correctly
