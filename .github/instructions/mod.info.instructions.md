---
applyTo: 'mod.info'
---

# mod.info File Format Instructions

Based on the official Project Zomboid wiki specifications: https://pzwiki.net/wiki/Mod.info

## File Requirements

- **File name**: Must be `mod.info` (lowercase for Linux/macOS compatibility)
- **Location**: Must be placed in the mod folder (versioning folder recommended)
- **Format**: Simple text file with `.info` extension
- **Encoding**: UTF-8

## Required Parameters

### Essential (Minimum Required)
- `name` - The displayed name for your mod in the game's mod manager
- `id` - Unique mod identifier used in mod lists (must be unique across all mods)

### Recommended Core Parameters
- `author` - Name of the author(s), should be your username if original
- `description` - Description shown in mod manager (supports ISRichTextPanel tags)
- `modversion` - Version of the mod

## Optional Parameters

### Media
- `poster` - Main image for mod manager (can specify multiple: `poster=image1.png poster=image2.png`)
- `icon` - Small image next to mod name in list (can reuse poster)

### Compatibility
- `versionMin` - Minimum game version required
- `versionMax` - Maximum game version supported
- `tags` - Build version tags (e.g., "Build 42")
- `require` - Required mods (format: `require=\modId1,\modId2`)
- `incompatible` - Incompatible mods (format: `incompatible=\modId1,\modId2`)

### Advanced
- `url` - URL link shown in mod manager (for donations, documentation, etc.)
- `pack` - Name of packs that need to be loaded
- `tiledef` - Tiledef with ID added by mod (format: `tiledef=PackName ID`)
- `loadModAfter` - Load after specified mods (experimental)
- `loadModBefore` - Load before specified mods (experimental)

## Parameter Format Rules

1. **No spaces around equals sign**: `name=ModName` ✅, `name = ModName` ❌
2. **Backslash prefix for mod IDs**: `incompatible=\OtherModId`
3. **Comma separation for multiple values**: `require=\mod1,\mod2`
4. **Case sensitivity**: Parameter names are case-sensitive
5. **Line endings**: Use standard line endings (LF or CRLF)

## Recommended Parameter Order

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

## Best Practices

1. **Unique ID**: Use format `AuthorName_ModName` to avoid conflicts
2. **Version numbering**: Use semantic versioning (major.minor.patch)
3. **File paths**: Images can be in subfolders (e.g., `media/poster.png`)
4. **Cross-platform**: Use lowercase filename for compatibility
5. **Documentation**: Keep descriptions clear and informative
6. **Dependencies**: Clearly specify required and incompatible mods

## Common Issues to Avoid

- Using spaces around the equals sign
- Forgetting backslash prefix for mod IDs
- Using non-unique mod IDs
- Missing required parameters (name, id)
- Case-sensitive parameter names
- Using uppercase in filename on Linux/macOS

## Validation Checklist

- [ ] File named `mod.info` (lowercase)
- [ ] Contains at minimum `name` and `id` parameters
- [ ] All mod ID references use backslash prefix
- [ ] No spaces around equals signs
- [ ] Images referenced actually exist
- [ ] Version numbers follow semantic versioning
- [ ] Description is clear and informative
- [ ] Author field matches your username