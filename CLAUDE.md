# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Project Zomboid mod (Build 42+) that adds engine quality restoration to the vehicle mechanics menu. Players consume engine parts and apply mechanic skill to incrementally restore engine quality (0-100%), improving power and reducing loudness.

- **Mod ID**: `Ivmakk_RestoreEngineQuality`
- **Steam Workshop ID**: 3543612325
- **Game versions**: 42.15+ (current), 42.12 (legacy)

## Development

There are no build steps, linting, or automated tests. Development is manual: edit Lua files, launch the game, test in-game.

**Debug mode**: Toggle `DEBUG_MODE` in `REQ_Utils.lua`. When true, errors surface immediately (fail-fast); when false, `pcall` wraps the main override and falls back to vanilla on failure.

**Testing**: Manually in Project Zomboid. After implementing features, provide step-by-step in-game testing instructions (items to spawn, actions to perform, expected outcomes, edge cases).

## Directory Structure

| Path | Purpose |
|------|---------|
| `Contents/mods/RestoreEngineQuality/42.15/` | **Active development** — current version source |
| `Contents/mods/RestoreEngineQuality/42.12/` | Legacy version (same codebase, pinned to older builds) |
| `PZ_files/` | **Deprecated** — vanilla reference files, to be removed (use game context repo via `pz-modding` skill instead) |
| `workshop_assets/` | Steam Workshop images and metadata |
| `.claude/skills/` | Project skills (pz-modding, pz-mod-release, pz-mod-localization, pz-mod-multi-version) |
| `.github/instructions/` | Legacy Copilot instruction files (reference material) |
| `.github/prompts/` | Legacy Copilot prompts (superseded by `.claude/skills/`) |

Both version folders contain the same 10 Lua modules. When making changes, update **both** unless the change is version-specific.

## Architecture

Entry point is `REQ_Client.lua`, which hooks `Events.OnInitGlobalModData` to initialize the mod once. All modules use Lua `require` and return a table.

**Module dependency flow:**

```
REQ_Client (entry, event hook)
├── REQ_ISVehicleMechanics (patches vanilla context menu)
│   ├── REQ_ISRestoreEngineQuality (ISBaseTimedAction subclass)
│   ├── REQ_Tooltips (builds requirement/preview tooltip)
│   ├── REQ_Requirements (validates skill, wrench, parts, key, quality)
│   └── REQ_RestorationPlan (calculates quality gain, power, loudness)
├── REQ_ModOptions (PZAPI.ModOptions slider for parts-per-iteration)
└── REQ_Utils (logging, debug toggle)

REQ_Requirements → REQ_RequirementResults (result container class)
REQ_Requirements, REQ_ISRestoreEngineQuality → REQ_Inventory (recursive container ops)
REQ_RestorationPlan → REQ_ModOptions (reads parts-per-iteration setting)
```

**Key patterns:**
- Vanilla method patching: stores `ISVehicleMechanics.doPartContextMenu` as original, replaces with extended version that calls original first then appends restoration option
- OOP via metatables: `REQ_RestorationPlan` and `REQ_RequirementResults` use `setmetatable` with `__index`
- Action queueing: pathfind → open hood → timed restoration → close hood
- Recursive inventory: counts/consumes items across nested containers (backpacks inside inventory)
- Multiplayer: calls `vehicle:transmitEngine()` and `character:sendObjectChange()` after modifications

## Code Style

- LuaLS/EmmyLua type annotations (`---@param`, `---@return`) on all functions
- Section separators: `-- ===...=== --` with ALL CAPS section name
- `table.concat()` for complex string building (5+ parts), `..` for simple concatenation
- Numeric `for i = 1, #t` loops over `ipairs`
- Minimal pcall: only around the main initialization/override, not individual functions
- Comments explain "why" not "what"; no redundant parameter descriptions

## Release Workflow

Uses git-flow-style branching. Invoke `/pz-mod-release` skill for the full process.

1. Develop on `release/X.Y.Z` branch
2. `/pz-mod-release` — bumps version, finalizes all three changelogs, updates version references, then merges/tags/pushes when confirmed

**Files to keep in sync on release**: `mod.info` (both version folders), `CHANGELOG.md`, `workshop_assets/workshop_updates.txt`, `common/ChangeLog.txt`, README version badge.

## Commit Messages

Keep a Changelog-ready format. Start with category prefix: `Added:`, `Changed:`, `Fixed:`, `Removed:`, `Deprecated:`, `Security:`. Imperative mood, 72 chars max.

## Conventions

- `workshop_description.txt` uses Steam BBCode (`[b]`, `[h1]`, `[list][*]`), not Markdown
- Mod option naming: `UI_options_REQ_<optionName>` for labels, `_tooltip` suffix for tooltips
- Localization prefix: `IGUI_REQ_` for in-game UI, `UI_options_REQ_` for settings menu
- Localization format: JSON in 42.15 (`IG_UI.json`, `UI.json`), Lua text in 42.12 (`IG_UI_{LANG}.txt`, `UI_{LANG}.txt`)
- Do not create mod options or localizations unless explicitly asked — implement core functionality first

## Error Handling

- **Guaranteed singletons** (getPlayer, ScriptManager, game events): no nil checks, let it crash
- **Optional data** (mod configs, item properties, dynamic data): use `or` fallbacks
- **Main override only**: pcall wraps `REQ_ISVehicleMechanics.initialize()` to fall back to vanilla on complete failure
- Never pcall individual helper functions — fail fast during development

## Mod Options API

Options use `PZAPI.ModOptions`. Full API reference in `.claude/skills/pz-modding/references/mod-options.md`. Do not create options unless explicitly asked. Use positive phrasing ("Show X" not "Hide X"). Labels/tooltips go in localization files.
