# mod.info File Format

Based on https://pzwiki.net/wiki/Mod.info

## Required Parameters
- `name` — displayed name in mod manager
- `id` — unique mod identifier (use `AuthorName_ModName` format)

## Recommended Parameters
- `author`, `description`, `modversion`, `poster`, `icon`

## Optional Parameters
- `versionMin`, `versionMax`, `tags` (e.g., "Build 42")
- `require=\modId1,\modId2` — required mods (backslash prefix)
- `incompatible=\modId1` — incompatible mods
- `url` — link shown in mod manager
- `loadModAfter`, `loadModBefore` — load ordering (experimental)

## Format Rules
- No spaces around `=`: `name=ModName` (not `name = ModName`)
- Backslash prefix for mod IDs in require/incompatible
- Comma separation for multiple values
- File must be named `mod.info` (lowercase for Linux/macOS)
- UTF-8 encoding

## Recommended Order

```
name=Your Mod Name
id=YourUniqueModId
author=YourUsername
description=Your mod description
poster=poster.png
icon=icon.png
modversion=1.0.0
tags=Build 42
versionMin=42.0
url=https://your-website.com
require=\RequiredMod1,\RequiredMod2
incompatible=\IncompatibleMod1
```
