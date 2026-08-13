# Copilot code-review instructions

Project Zomboid Build 42 Lua mod (`Ivmakk_RestoreEngineQuality`). Use these rules when reviewing pull requests. Flag violations; do not rewrite unrelated code. There are no automated tests - testing is manual in-game, so do not ask for test files.

## Multiplayer correctness (highest priority)

- **Timed actions must be globals.** An `ISBaseTimedAction:derive("Name")` must be assigned to a global named exactly `Name` (e.g. `ISRestoreEngineQuality = REQ_ISRestoreEngineQuality`). MP reconstructs networked actions by type name via `_G`; a `local`-only assignment works in SP but breaks MP with `no such function "Name.new"`.
- **Load side matters.** `shared/` loads on client and server; `client/` only on client; `server/` only on server. Code reachable server-side must not depend on client-only definitions. Flag a server-reachable path that reads a `client/`-only global without a fallback.
- **Server-authoritative state cannot be set from the client.** Engine mutators pair with a `transmitX()` guarded by `GameServer.server` (e.g. `BaseVehicle.transmitEngine()`), so a client-side mutation is silently overwritten. Flag client-side engine writes that expect to persist.
- **After mutating engine state**, the code must call `vehicle:transmitEngine()` and `character:sendObjectChange(...)` so MP clients sync. Flag a mutation missing either.

## Vanilla method patching

- Store the original before overriding (`original_` prefix), then call it inside the replacement. Flag an override that drops the original when it should chain (the mod extends `ISVehicleMechanics.doPartContextMenu`, not replaces it).
- `pcall` belongs only around the main override/init so total failure falls back to vanilla. Flag `pcall` wrapping individual helpers - it hides failures that should fail fast in dev.

## Error handling

- **Guaranteed singletons** (`getPlayer()`, `ScriptManager.instance`, game events): no nil checks - let it crash.
- **Optional data** (mod option values, optional item properties, dynamic modData): use `or` fallbacks.
- Flag both mistakes: defensive nil-guards around guaranteed singletons, and missing fallbacks on genuinely optional data.

## Lua style

- LuaLS/EmmyLua annotations (`---@param`, `---@return`) on functions; keep them minimal (types over prose, `unknown` when unknown). No redundant parameter descriptions.
- Comments explain "why", not "what". Flag obvious/restating comments.
- Do not reference plan phases, step numbers, or ticket IDs in code comments.
- `table.concat()` for 5+ string parts or loops; plain `..` for simple cases. Numeric `for i = 1, #t do` over `ipairs` for arrays.

## Scope discipline

- **Do not add mod options or localization entries unless the PR explicitly asks.** Flag new `PZAPI.ModOptions` entries or new `IGUI_REQ_`/`UI_options_REQ_` keys that aren't the PR's stated purpose.
- Mod option labels use positive phrasing ("Show X", not "Hide X"), naming `UI_options_REQ_<optionName>` with `_tooltip` suffix for tooltips.
- Localization is JSON (`IG_UI.json`, `UI.json`) - flag new `.txt` Translate files.
- Changes must trace to the PR's stated intent; flag unrelated refactors or reformatting.

## Release hygiene

- Commit messages start with a Keep-a-Changelog prefix (`Added:`/`Changed:`/`Fixed:`/`Removed:`/`Deprecated:`/`Security:`), imperative, subject <=72 chars.
- A version bump must stay consistent across `mod.info` (`modversion`), `CHANGELOG.md`, `workshop_assets/workshop_updates.txt`, and `common/ChangeLog.txt`. Flag a bump that updates only some.
- The mod is GPL-3.0; flag added third-party code without a compatible license.
