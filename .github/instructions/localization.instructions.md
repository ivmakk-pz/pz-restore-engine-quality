---
applyTo: '**/Translate/**/*_*.txt'
---

# Localization Instructions for Your Project Zomboid Mod

## File Structure and Naming
- Follow Project Zomboid's standard: `Translate/{language}/{File}_{language}.txt`
- Create files in: `Contents/mods/RestoreEngineQuality/42/media/lua/shared/Translate/{LANGUAGE}/`
- Required files: `IG_UI_{LANGUAGE}.txt` and `UI_{LANGUAGE}.txt`

## Supported Language Codes (Build 42)

| Code | Language | Encoding |
|------|----------|----------|
| AR | Español (AR) - Argentina Spanish | Cp1252 |
| CA | Catalan | ISO-8859-15 |
| CH | Traditional Chinese | UTF-8 |
| CN | Simplified Chinese | UTF-8 |
| CS | Czech | Cp1250 |
| DA | Danish | UTF-8 |
| DE | Deutsch - German | UTF-8 |
| EN | English | UTF-8 |
| ES | Español (ES) - Spanish | UTF-8 |
| FI | Finnish | UTF-8 |
| FR | Français - French | UTF-8 |
| HU | Hungarian | UTF-8 |
| ID | Indonesia | UTF-8 |
| IT | Italiano | UTF-8 |
| JP | Japanese | UTF-8 |
| KO | Korean | UTF-16 |
| NL | Nederlands - Dutch | UTF-8 |
| NO | Norsk - Norwegian | UTF-8 |
| PH | Tagalog - Filipino | UTF-8 |
| PL | Polish | UTF-8 |
| PT | Portuguese | UTF-8 |
| PTBR | Brazilian Portuguese | UTF-8 |
| RO | Romanian | UTF-8 |
| RU | Russian | UTF-8 |
| TH | Thai | UTF-8 |
| TR | Turkish | UTF-8 |
| UA | Ukrainian | UTF-8 |

**Note**: Most languages use UTF-8 encoding in Build 42. Special encodings:
- KO (Korean): UTF-16
- CS (Czech): Cp1250  
- CA (Catalan): ISO-8859-15
- AR (Argentina Spanish): Cp1252

## Translation File Types

### `IG_UI_{LANGUAGE}.txt`
- **Purpose**: In-game UI elements, tooltips, and status displays
- **Prefix**: `IGUI_REQ_`
- **Format**: `IGUI_REQ_{LANGUAGE} = { ... }`

### `UI_{LANGUAGE}.txt`
- **Purpose**: Mod settings menu options and interface text  
- **Prefix**: `UI_REQ_`
- **Format**: `UI_REQ_{LANGUAGE} = { ... }`

## Variable Naming Rules
- **ALL variables must contain your mod prefix in the name**
- Format: `<EntryPrefix>_<MOD_PREFIX>_<var_name>`
- Keep exact variable names from English files - only translate string values
- Use descriptive, clear variable names
- Settings format: `UI_options_<MOD_PREFIX>_<setting_name>`

## Translation Requirements
1. **Maintain exact variable names** - translate only the quoted string values
2. **Preserve formatting** including line breaks, HTML-like tags (`<BR>`, `<LINE>`, etc.)
3. **Keep technical terms** like your mod prefix untranslated
4. **Use correct encoding** - See language table above for specific encoding requirements
5. **Translate all entries** from both English reference files

## Example Format
```lua
-- IG_UI_DE.txt
IGUI_REQ_DE = {
    IGUI_REQ_Example_Text = "Beispiel Text",
    IGUI_REQ_Another_Example = "Weiteres Beispiel",
}

-- UI_DE.txt  
UI_REQ_DE = {
    UI_options_REQ_title = "Your Mod Title",
    UI_options_REQ_exampleOption = "Beispiel Option",
}
```

## Reference Files
Use these English files as translation base:
- `Contents/mods/RestoreEngineQuality/42/media/lua/shared/Translate/EN/IG_UI_EN.txt`
- `Contents/mods/RestoreEngineQuality/42/media/lua/shared/Translate/EN/UI_EN.txt`
