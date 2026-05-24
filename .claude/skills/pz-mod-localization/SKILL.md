---
name: pz-mod-localization
description: >
  Use this skill when adding or updating translations/localizations for a PZ mod.
  Activates when the user says "add localization", "translate", "add language",
  "add German/French/Spanish/etc translation", or asks about PZ translation files.
---

# PZ Mod Localization

## Format: TXT (Build 42.14 and earlier) vs JSON (Build 42.15+)

Build 42.15.0 switched translation files from Lua-table `.txt` to `.json` (release note: "Localization clean-up. Translation files are now in json"). Builds 42.14.1 and earlier use `.txt`. Check the mod's target build to determine which format to use. Multi-version mods need both formats in their respective version folders.

### JSON format (Build 42.15+)

Files: `IG_UI.json` and `UI.json` (no language suffix in filename).

```json
{
    "IGUI_{MOD_PREFIX}_Example": "Example Text",
    "IGUI_{MOD_PREFIX}_Another": "Another Example"
}
```

- Flat key-value JSON object
- Keys are the translation variable names
- No wrapper table, no language suffix in keys

### TXT format (Build 42.14 and earlier)

Files: `IG_UI_{LANG}.txt` and `UI_{LANG}.txt` (language code in filename).

```lua
IGUI_{MOD_PREFIX}_{LANG} = {
    IGUI_{MOD_PREFIX}_Example = "Beispiel Text",
    IGUI_{MOD_PREFIX}_Another = "Weiteres Beispiel",
}
```

- Lua table assignment
- Table name includes mod prefix AND language code (e.g., `IGUI_FTE_DE`)
- Trailing commas on each entry

### Multi-version example

```
Contents/mods/{MOD_NAME_CODE}/
├── 42.15/media/lua/shared/Translate/
│   ├── EN/IG_UI.json          # JSON format
│   └── DE/IG_UI.json
├── 42.12/media/lua/shared/Translate/
│   ├── EN/IG_UI_EN.txt        # TXT format
│   └── DE/IG_UI_DE.txt
```

## File Structure

Translation files go in: `media/lua/shared/Translate/{LANG}/`

Two files per language:
- `IG_UI` — in-game UI elements, tooltips, status displays
- `UI` — mod settings menu options and interface text

## Translation Rules

- Keep exact variable names/keys from English files — translate only the string values
- Preserve formatting tags (`<BR>`, `<LINE>`, `<RGB:r,g,b>`, etc.)
- Keep mod prefix untranslated
- Settings use: `UI_options_{MOD_PREFIX}_<settingName>` and `_tooltip` suffix

## Supported Languages (Build 42)

| Code | Language | Encoding |
|------|----------|----------|
| AR | Argentina Spanish | Cp1252 |
| CA | Catalan | ISO-8859-15 |
| CH | Traditional Chinese | UTF-8 |
| CN | Simplified Chinese | UTF-8 |
| CS | Czech | Cp1250 |
| DA | Danish | UTF-8 |
| DE | German | UTF-8 |
| EN | English | UTF-8 |
| ES | Spanish | UTF-8 |
| FI | Finnish | UTF-8 |
| FR | French | UTF-8 |
| HU | Hungarian | UTF-8 |
| ID | Indonesian | UTF-8 |
| IT | Italian | UTF-8 |
| JP | Japanese | UTF-8 |
| KO | Korean | UTF-16 |
| NL | Dutch | UTF-8 |
| NO | Norwegian | UTF-8 |
| PH | Filipino | UTF-8 |
| PL | Polish | UTF-8 |
| PT | Portuguese | UTF-8 |
| PTBR | Brazilian Portuguese | UTF-8 |
| RO | Romanian | UTF-8 |
| RU | Russian | UTF-8 |
| TH | Thai | UTF-8 |
| TR | Turkish | UTF-8 |
| UA | Ukrainian | UTF-8 |

## Workflow

1. Determine the target build to pick the right format (JSON or TXT)
2. Read the English reference files
3. Create the target language directory if it doesn't exist
4. Create both translation files with all entries translated
5. For multi-version mods, create translations in both version folders using the appropriate format

## Gotchas

- **Build 42.15.0+ uses JSON**, 42.14.1 and earlier use TXT. Using the wrong format will silently fail.
- JSON files have NO language suffix in filename (`UI.json` not `UI_DE.json`). TXT files DO (`UI_DE.txt`).
- JSON keys have no language suffix. TXT table names include both mod prefix and language code.
- Korean (KO) uses UTF-16, not UTF-8.
- Czech (CS) uses Cp1250, Catalan (CA) uses ISO-8859-15, Argentina Spanish (AR) uses Cp1252.
