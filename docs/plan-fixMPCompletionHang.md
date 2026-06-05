# Fix: MP restore action hangs at 100% (never completes)

## Report

NyxRaven (Workshop comment): "I tested it just now in MP (hosted) with friends and I still can't use this option. I've everything, load up the action and do it. Once it reaches 100% doing the action it never completes."

## Root Cause

The timed action class is declared `local`, so the server cannot reconstruct it for the networked timed-action transaction.

`Contents/mods/RestoreEngineQuality/42/media/lua/shared/REQ_ISRestoreEngineQuality.lua:13`:

```lua
local REQ_ISRestoreEngineQuality = ISBaseTimedAction:derive("ISRestoreEngineQuality")
```

MP completion flow, traced through the decompiled engine:

1. Because the action defines a `complete()` method, the engine sets `useCustomRemoteTimedActionSync = false` (`LuaTimedActionNew.java:76`). This opts the action into the server-synced net-transaction path instead of completing locally.
2. On an MP client, `start()` opens a net transaction and sends a Request packet carrying `Type = "ISRestoreEngineQuality"` plus the `new()` arguments (`LuaTimedActionNew.java:128-131`).
3. The server rebuilds the action **by global name**: `LuaManager.getFunctionObject("ISRestoreEngineQuality.new")` (`NetTimedAction.java:150,161`), which resolves only against the global Lua env (`LuaManager.java:1402-1420`).
4. The class is `local` (returned from the module via `require`, never assigned to a global), so the lookup fails and `action = null` (`NetTimedAction.java:162-164`).
5. The server never marks the transaction `Done`. The client bar fills to 100% (`setWaitForFinished`) and waits for a completion signal that never arrives → permanent hang. The actual restoration logic in `complete()` also only runs server-side (`LuaTimedActionNew.java:164`: `if (!GameClient.client)`), so it never executes either.

Singleplayer works because there is no net transaction — `complete()` runs locally.

Vanilla `ISRepairEngine` and every other vanilla vehicle timed action are declared as **globals** (e.g. `ISRepairEngine = ISBaseTimedAction:derive("ISRepairEngine")`), so the server resolves and reconstructs them. The mod broke this contract by using `local`.

Corroboration — **the bug is join-only.** On a hosted (listen) server the host player runs as the server: `start()` skips the net transaction and `complete()` runs locally (`LuaTimedActionNew.java:128` and `:164`, both gated on `GameClient.client`). So the host never sees the hang — only joining clients, whose action goes through the net transaction and fails reconstruction. This matches the report ("hosted with friends … friends can't complete it").

## Fix Direction

**Option A — make the action class global. This is the only correct fix.** The completion logic *must* run on the server because vehicle state is server-authoritative:

- `BaseVehicle.transmitEngine()` is a no-op unless `GameServer.server` (`BaseVehicle.java:9460-9463`).
- `setEngineFeature()` (`BaseVehicle.java:8332`) called on a client mutates only that client's local copy; the server's authoritative state overwrites it on the next vehicle sync.

So the change can only persist and replicate if `complete()` executes server-side, which is exactly what the net-transaction path does (`NetTimedAction.java:132-134` runs the Lua `complete` on the server). Keeping `complete()` and making the class resolvable server-side (global) is required.

**Option B (move logic into `perform()`, drop `complete()`) is rejected.** Without `complete()` the engine sets `useCustomRemoteTimedActionSync = true` and `perform()` runs only on the acting client — where `transmitEngine()` does nothing and the engine edit is local-only. The restoration would not replicate and would likely revert. Client-authoritative is not viable for vehicle state.

Server-side safety of `complete()` is confirmed by parity with vanilla `ISRepairEngine:complete()`, which runs server-side under the same path and calls the same families of APIs: `addXp`, `getInventory():...DoRemoveItem` + `sendRemoveItemFromContainer`, a `transmit*`, and `sendObjectChange(IsoObjectChange.MECHANIC_ACTION_DONE, ...)`. The mod's `consumeItemsByTypeRecurse` already pairs `DoRemoveItem` with `sendRemoveItemFromContainer` (`REQ_Inventory.lua:36-37`), so consumption syncs correctly.

## Out of scope (deferred)

**Parts-per-iteration in MP — deferred to a later release.** With Option A the server runs `complete()` and reads `REQ_ModOptions.getEnginePartsPerIteration()` server-side. `PZAPI.ModOptions` values are client-local and never sent to the server, and `REQ_Client.lua` (in `client/`) never runs `REQ_ModOptions.initialize()` server-side, so the call returns its default of `2` on the server (`REQ_ModOptions.lua:18`). Net effect in MP: the restoration always uses `2` parts per iteration regardless of a client's slider, and a client whose slider differs from `2` sees a tooltip preview that overstates the result. This is cosmetic/balance only — no hang, no error — and with the default `2` everywhere there is no visible difference.

A constructor-passthrough (smuggle the client's slider value through the timed action's net args) would make the server honor it, but with the wrong ownership: a per-client balance value is exploitable (set to `1` for cheap repairs) and inconsistent across players. `PZAPI.ModOptions` is designed for client-side tuning, not server-authoritative balance. The correct MP home for this value is a **sandbox option** (`SandboxVars`, defined in `media/sandbox-options.txt`): set per world/server and synced to all clients, so the server computation and the client preview read the same authoritative value. That is a separate design task and is **out of scope for the current release**.

Decision for this release: parts-per-iteration stays a client-side slider (correct in singleplayer); MP uses the fixed default of `2`. Revisit via a sandbox option later. Tracked under "Deferred follow-up" below.

## Implementation Plan

> **Rule**: Check off each step as it is completed. Update this plan if blockers or scope changes are encountered.

### 1. Reproduce

- [ ] Create a `fix/mp-completion-hang` branch (or a `release/X.Y.Z` branch if shipping immediately)
- [ ] Confirm the hang as a **joining client** in a hosted MP session: spawn EngineParts + wrench, lower engine quality, run restore, observe bar freeze at 100%
- [ ] Confirm the **host player** does NOT hang (validates the join-only diagnosis)
- [ ] Confirm singleplayer still completes correctly (baseline)

### 2. Make the action class global (core fix — resolves the hang)

- [x] Keep `REQ_ISRestoreEngineQuality.lua:13` (`local REQ_ISRestoreEngineQuality = ISBaseTimedAction:derive("ISRestoreEngineQuality")`) unchanged, and add one line immediately after: `ISRestoreEngineQuality = REQ_ISRestoreEngineQuality` (with a comment noting MP reconstructs the action by this global type name)
- [x] Confirm the global name matches the `derive()` type string exactly (`ISRestoreEngineQuality`) — the networked side reconstructs by that string via `LuaManager.get(type)` + `getFunctionObject(type..".new")` (`NetTimedActionPacket.java:21-23` and `:149-161`)
- [x] The `require`/`local`/`return` usage in the rest of the module and in `REQ_ISVehicleMechanics.lua:5,116,119` keeps working unchanged (still points at the same table)
- [ ] Remove the duplicate copy during dev: unsubscribe Workshop `3543612325` (or rename `...\108600\3543612325\`) so the unfixed published copy cannot shadow the local `Zomboid\Workshop` copy on load

### 3. Audit `complete()` for server-side safety

- [x] Confirm every module used by `complete()` resolves server-side: `REQ_RestorationPlan`, `REQ_Inventory`, `REQ_ModOptions`, `REQ_Utils` — all in `media/lua/shared/` ✓ (verified none transitively pull from `client/`)
- [x] Confirm the API calls match vanilla server-safe usage: `setEngineFeature`, `transmitEngine`, `consumeItemsByTypeRecurse` (`DoRemoveItem` + `sendRemoveItemFromContainer`), `addXp`, `sendObjectChange(IsoObjectChange.MECHANIC_ACTION_DONE, ...)` ✓
- [x] Confirm `complete()` returns `true` on the no-op path (no parts / no gain) so the transaction still reaches `Done` and the client never hangs (`REQ_ISRestoreEngineQuality.lua:94`)

### 4. Regression test

- [x] Hosted MP (joining client): bar completes without hanging; quality increases; requirement checks (skill, key, wrench) behave; wrench/parts pulled from a bag work — confirmed in-game
- [ ] Singleplayer: restore completes, quality increases, EngineParts consumed, XP granted (re-confirm after the change)
- [ ] Hosted MP (host player): bar reaches 100% and completes; quality/parts/XP apply
- [ ] Confirm engine quality/power/loudness replicate to other players (not just the actor)
- [ ] Edge: insufficient parts / no wrench / no key → option greyed out, no hang
- [ ] Edge: cancel mid-action (walk away) → action stops cleanly, no stuck transaction
- [ ] Note (expected, not a failure): in MP the restoration uses the default `2` parts/iteration regardless of a client's slider — see "Out of scope (deferred)"

### 5. Verify

- [ ] No errors in the joining client's `console.txt` or the server log during a full MP restore cycle
- [ ] Engine quality, power, and loudness apply correctly after completion (on the joining client)
- [ ] Update changelogs per `/pz-mod-release` when shipping (CHANGELOG.md, workshop_updates.txt, common/ChangeLog.txt, mod.info)

## Deferred follow-up

- [ ] Move parts-per-iteration from the client `PZAPI.ModOptions` slider to a sandbox option (`media/sandbox-options.txt` + `SandboxVars.Ivmakk_RestoreEngineQuality.*`) so it is server-authoritative and synced to clients in MP. Separate release. See "Out of scope (deferred)".
