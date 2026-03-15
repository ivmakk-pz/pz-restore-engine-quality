# Plan: Fix B42.15 Compatibility Issues

## Summary

Four bugs found by comparing the mod's 42.15 code against the b42.15.2 PZ source files. The mod was last tested on b42.13 and was not adapted to follow changes in how vanilla code handles wrenches, mechanic action events, and item removal.

---

## Issues Found

### Issue 1 — CRITICAL: Wrench lookup uses type string, not tag

Vanilla b42 identifies wrenches via `tagToItem[ItemTag.WRENCH]` and `getFirstTagEvalRecurse(ItemTag.WRENCH, predicateNotBroken)`. The mod uses:

- `REQ_ISVehicleMechanics.lua` (`onRestoreEngineQuality`): `typeToItem["Base.Wrench"]` — only captures `typeToItem`, ignores `tagToItem`
- `REQ_Requirements.lua` (`checkWrenchRequirement`): `containsTypeRecurse("Wrench")` — misses any wrench not named exactly `Base.Wrench`

**Result:** Player with a Ratchet Wrench or any other WRENCH-tagged item sees the option greyed out, and the action silently does nothing even if they somehow trigger it.

**Fix:**
- `onRestoreEngineQuality`: capture both `local typeToItem, tagToItem = VehicleUtils.getItems(...)`, then use `tagToItem[ItemTag.WRENCH] and tagToItem[ItemTag.WRENCH][1]`
- `checkWrenchRequirement`: replace `hasTypeRecurse(character, "Wrench")` with `character:getInventory():getFirstTagEvalRecurse(ItemTag.WRENCH, predicateNotBroken)` — mirrors vanilla's `getWrench()`
- `REQ_Inventory.hasTypeRecurse` usage for the wrench check can be left or removed — it becomes unused for the wrench requirement

---

### Issue 2 — MEDIUM: `sendObjectChange` uses string literal instead of Java constant

Vanilla `ISRepairEngine:complete()` calls:
```lua
self.character:sendObjectChange(IsoObjectChange.MECHANIC_ACTION_DONE, { success = (done > 0) })
```

The mod (`REQ_ISRestoreEngineQuality.lua`) calls:
```lua
self.character:sendObjectChange('mechanicActionDone', { success = true })
```

`IsoObjectChange.MECHANIC_ACTION_DONE` is a Java enum constant — the string `'mechanicActionDone'` doesn't match it. `Events.OnMechanicActionDone` never fires, so the vehicle mechanics UI never flashes green/red after restoration.

**Fix:** `IsoObjectChange.MECHANIC_ACTION_DONE` instead of `'mechanicActionDone'`

---

### Issue 3 — LOW: `container:Remove(item)` instead of `container:DoRemoveItem(item)`

Vanilla `ISRepairEngine:complete()` (b42.15.2) uses `container:DoRemoveItem(item)`. The mod's `REQ_Inventory.lua` `consumeItemsByTypeRecurse` uses `container:Remove(item)`. `DoRemoveItem` fires proper cleanup (weight recalculation, container events). `Remove` just removes from the list — player carry weight won't update after consuming engine parts.

**Fix:** `container:DoRemoveItem(item)`

---

### Issue 4 — LOW: `DEBUG_MODE = true` in production

`REQ_Utils.lua` has `local DEBUG_MODE = true`. Every user will get console spam.

**Fix:** `local DEBUG_MODE = false`

---

## Files to Change

| File | Change |
|------|--------|
| `REQ_ISVehicleMechanics.lua` | Capture `tagToItem` from `VehicleUtils.getItems`; use `tagToItem[ItemTag.WRENCH][1]` |
| `REQ_Requirements.lua` | Replace `containsTypeRecurse("Wrench")` with `getFirstTagEvalRecurse(ItemTag.WRENCH, predicateNotBroken)` |
| `REQ_ISRestoreEngineQuality.lua` | `'mechanicActionDone'` → `IsoObjectChange.MECHANIC_ACTION_DONE` |
| `REQ_Inventory.lua` | `container:Remove(item)` → `container:DoRemoveItem(item)` |
| `REQ_Utils.lua` | `DEBUG_MODE = true` → `DEBUG_MODE = false` |

---

## Out of Scope

- Loudness calculation (`calculateLoudnessFeature`) — correctly preserves the current stored value
- Engine power `math.max` guard — intentional design, not a bug
- Extra `equipWeapon` call in `onRestoreEngineQuality` — not breaking anything

---

## Verification Steps

1. Test with `Base.Wrench` — requirement shown as green, action executes
2. Test with a Ratchet Wrench (or any WRENCH-tagged non-base-wrench) — same result
3. After completing the action, confirm mechanics UI flashes green
4. Check player weight is correct after consuming engine parts
5. Confirm no `[REQ] DEBUG` spam in console
