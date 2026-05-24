---
name: pz-modding
description: >
  Use this skill when working on Project Zomboid mods or any PZ-related code.
  Activates when the user mentions PZ, Project Zomboid, Zomboid modding, Lua mods for PZ,
  or is working in a directory containing mod.info, media/lua, or PZ mod structure.
  Also activates when the user asks about game APIs, item scripts, recipes, or
  how vanilla game systems work.
---

# Project Zomboid Modding

## Context Locations

- **Game context repo**: decompiled Java source, game Lua scripts, script definitions, release notes, modding docs. Read files from here to look up game APIs, method signatures, vanilla implementations, and script syntax. Default path: `~/games/pz-modding-llm-context` (or platform equivalent).
- **Mod template**: [pz-mod-template-ivmakk](https://github.com/ivmakk/pz-mod-template-ivmakk) — shared mod structure, changelog conventions, localization patterns, release workflow.
- **Steam Workshop mods**: installed workshop mods by Steam ID. Default path: `<Steam>/steamapps/workshop/content/108600/`.

## Game Architecture

Project Zomboid is a Java game engine with a Lua modding layer. Key paths in the context repo:

- `decompiled/zombie/` — Java source (the engine)
- `game/media/lua/client/` — client-side Lua (UI, interactions, foraging, crafting)
- `game/media/lua/server/` — server-side Lua (game rules, networking)
- `game/media/lua/shared/` — shared Lua (utilities, common functions)
- `game/media/scripts/` — game data definitions (items, recipes, vehicles, fluids) in `.txt` format
- `docs/` — PZwiki references, migration guides, changelogs

## Lua Patching Java Methods

```lua
local index = __classmetatables[JavaClassName.class].__index
local original_methodName = index.methodName

index.methodName = function(self, param1, param2, ...)
    -- custom logic, optionally calling original_methodName(self, param1, ...)
end
```

- Always store the original method before overriding
- Use `original_` prefix for naming
- Consider wrapping in `pcall` for safety on unstable builds

## Game Script Syntax

Files in `game/media/scripts/` use: `module Base { item ItemName { Key = Value, } }` with mandatory commas, `/* */` comments. Types: items, recipes, CraftRecipes (Build 42), EvolvedRecipes, fluids, vehicles, entities, MultiStageBuild.

## PZ Mod Structure

```
ModName/
├── mod.info              # Mod metadata (name, id, description, require)
├── media/
│   ├── lua/
│   │   ├── client/       # Client-side scripts
│   │   ├── server/       # Server-side scripts
│   │   └── shared/       # Shared scripts (including Translate/)
│   └── scripts/          # Custom item/recipe definitions
├── common/
│   └── ChangeLog.txt     # In-game changelog alert (oldest-first order)
└── workshop.txt          # Steam Workshop metadata
```

For `mod.info` format details, read `references/mod-info.md`.

## Multi-Version Support

PZ supports version-specific mod folders (e.g., `42.12/` and `42.13/`). The game automatically loads the folder matching the player's build.

## Lua Code Conventions

### Type Annotations
Use LuaLS/EmmyLua annotations (`---@param`, `---@return`, `---@type`). Keep them minimal — types over descriptions. Use `unknown` when type can't be determined.

### Comments
Focus on "why" not "what". No obvious comments. Use `-- === SECTION NAME === --` separators in large files.

### Error Handling
- No fallbacks for guaranteed game singletons (`getPlayer()`, `ScriptManager.instance`)
- Fallbacks only for genuinely optional data (mod configs, optional item properties)
- Use `pcall` only for the main mod entry point to fall back to vanilla on complete failure

### Performance
- Use numeric `for i = 1, #t do` over `ipairs(t)` for arrays
- Use `table.concat()` for 5+ string parts or loops; `..` for simple cases

### Testing
No automated tests. All testing is manual in-game. Include testing steps when implementing features.

## Changelog System

Three files track changes in different formats:
1. **`CHANGELOG.md`** — Keep a Changelog format, newest-first
2. **`workshop_assets/workshop_updates.txt`** — plain text for Steam Workshop, newest-first
3. **`common/ChangeLog.txt`** — in-game alert system, oldest-first (appended at bottom)

For changelog alert system format, read `references/changelog-alert-system.md`.

## Commit Messages

Keep a Changelog-ready format. Start with category: `Added:`, `Changed:`, `Fixed:`, `Removed:`, `Deprecated:`, `Security:`. Imperative mood, ≤72 chars.

## Workshop Descriptions

`workshop_description.txt` (or `.bbcode`) uses Steam BBCode syntax, not Markdown.

## Mod Options API

For the PZAPI.ModOptions API reference, read `references/mod-options.md`.

## Workflow Tips

- When unsure about a game API, read the decompiled Java source in the context repo before guessing.
- For vanilla implementations, search `game/media/lua/` in the context repo.
- For item/recipe properties, check `docs/` and `game/media/scripts/`.
