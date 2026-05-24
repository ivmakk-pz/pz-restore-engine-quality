---
name: pz-mod-multi-version
description: >
  Use this skill when a PZ mod needs to support multiple game builds from a single workshop item.
  Activates when the user says "multi-version", "support older build", "add version folder",
  "versionMin/versionMax", "backport", or asks about supporting both stable and unstable
  PZ builds simultaneously.
---

# Multi-Version Mod Structure

Supports multiple Project Zomboid builds from a single Steam Workshop item. The game automatically loads the appropriate version folder based on the player's build.

## Folder Structure

```
Contents/mods/{MOD_NAME_CODE}/
├── {NEW_BUILD}/              # Development version (e.g., 42.15/)
│   ├── mod.info              # versionMin={NEW_BUILD}, no versionMax
│   └── media/lua/
│       ├── client/
│       └── shared/Translate/
├── {OLD_BUILD}/              # Stable version (e.g., 42.12/)
│   ├── mod.info              # versionMin={OLD_BUILD}.0, versionMax={OLD_BUILD}.99
│   └── media/lua/
│       ├── client/
│       └── shared/Translate/
└── common/                   # Shared assets (must exist, even if empty)
    ├── .gitkeep
    ├── ChangeLog.txt
    └── media/
```

## mod.info Version Configuration

### Newer build folder (e.g., `42.15/`)
```ini
versionMin=42.15
```
No `versionMax` — supports all future builds in this series.
No trailing `.0` on versionMin.

### Older build folder (e.g., `42.12/`)
```ini
versionMin=42.12.0
versionMax=42.12.99
```
Explicit range locks this folder to 42.12.x only.

### Synchronized fields (must be identical in both mod.info files)
- `modversion` — same version number so players see consistent version
- `id` — same mod ID for workshop detection
- `name` — same display name

## How Game Version Detection Works

1. Game scans each subfolder's `mod.info` for version constraints
2. Checks `versionMin` (game build must be >=) and `versionMax` (must be <=)
3. Loads the first matching folder
4. `common/` folder is always loaded regardless of version

## Development Workflow

### New features
1. Implement in the newer build folder first
2. Test on that build
3. Decide if backporting to older build folder is needed
4. Backport if beneficial and API-compatible

### Bug fixes
1. Fix in newer build folder
2. Backport to older folder if the bug exists there too

### Releases
1. Update `modversion` in ALL `mod.info` files
2. Update version constants in ALL Lua utils files (if present)
3. Synchronize translations between all version folders
4. Update `common/ChangeLog.txt`

### Localization
Add translations to both version folders and keep them synchronized.

## Migration from Single Version

To migrate from a single `42/` folder:

1. Rename `42/` to the newer build folder (e.g., `42.15/`)
2. Copy it to the older build folder (e.g., `42.12/`)
3. Update newer `mod.info`: set `versionMin=42.15`, remove `versionMax`
4. Update older `mod.info`: set `versionMin=42.12.0`, add `versionMax=42.12.99`
5. Create `common/` folder with `.gitkeep`
6. Move `ChangeLog.txt` to `common/` if it exists
7. Remove any build-specific code from the older folder that uses newer APIs

## Common Pitfalls

- **Missing `versionMax` on older folder** — it will load on newer builds too, conflicting with the newer folder
- **Trailing `.0` on newer build's `versionMin`** — use `42.15` not `42.15.0`
- **Different `modversion` across folders** — causes player confusion about which version they have
- **Forgetting to sync translations** — players on one build get untranslated text
- **Missing `common/` folder** — must exist even if empty (add `.gitkeep`)

## Pre-Release Checklist

- [ ] All `mod.info` files have identical `modversion`, `id`, `name`
- [ ] Newer folder: `versionMin` set, NO `versionMax`
- [ ] Older folder: both `versionMin` and `versionMax` set
- [ ] Version constants synchronized in Lua files (if present)
- [ ] Translations synchronized between all version folders
- [ ] `common/ChangeLog.txt` updated
- [ ] Tested on each supported build
