# In-Game Changelog Alert System

## Purpose
`ChangeLog.txt` in `common/` folder displays changelog notifications in-game when players load the mod.

## File Location
`Contents/mods/{MOD_NAME_CODE}/common/ChangeLog.txt`

## Format

```
[ vVERSION - YYYY-MM-DD ]
Added:
- Feature 1
- Feature 2
Fixed:
- Bug fix 1
[ ------ ]
```

## Rules
- Date header: `[ v1.2.0 - 2025-10-05 ]`
- For multiple updates same day: `[ v1.2.0 #2 - 2025-10-05 ]`
- Sections: `Added:`, `Changed:`, `Deprecated:`, `Removed:`, `Fixed:`, `Security:` (only include sections with content)
- Bullet points with `- ` prefix
- End each entry with `[ ------ ]`
- **Order: oldest at TOP, newest at BOTTOM** (opposite of CHANGELOG.md)
- The alert system displays in reverse, so oldest-first in file = newest-first in UI

## Optional Alert Config
Add at top of file for custom buttons:
```
[ ALERT_CONFIG ]
link1 = Button Text = URL,
link2 = Another Button = URL,
[ ------ ]
```
External URLs must use: `https://steamcommunity.com/linkfilter/?u=YOUR_URL`
