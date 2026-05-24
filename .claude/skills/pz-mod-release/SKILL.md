---
name: pz-mod-release
description: >
  Use this skill when releasing a PZ mod version: preparing changelogs, bumping versions,
  or finalizing a release. Activates when the user says "release", "prepare release",
  "bump version", "post release", "finalize release", "tag release", or asks to
  update version numbers across mod files.
---

# PZ Mod Release Workflow

## Step 1: Determine Version

- **If on a release branch** (e.g., `release/1.2.1`): extract version from branch name
- **If on main/master**: determine next version based on changes (patch/minor/major)
- Confirm with the user before proceeding

## Step 2: Update Changelogs

Update all three changelog files with consistent content:

1. **`CHANGELOG.md`** — move `[Unreleased]` entries to new version section `## [VERSION] - YYYY-MM-DD` (newest-first order)

2. **`workshop_assets/workshop_updates.txt`** — add plain text entry at top (newest-first). Format:
   ```
   vVERSION - YYYY-MM-DD

   Added
   - Feature description

   Fixed
   - Bug fix description
   ```
   No markdown formatting. Hyphens for bullets. Double blank line between versions.

3. **`common/ChangeLog.txt`** — append at BOTTOM (oldest-first order). Format:
   ```
   [ vVERSION - YYYY-MM-DD ]
   Added:
   - Feature description
   [ ------ ]
   ```

If no unreleased changes exist, review recent commits and add entries.

## Step 3: Update Version References

1. **`mod.info`** — update `modversion=` field (check all version folders if multi-version)
2. **`README.md`** — update version badge: `![Mod Version](https://img.shields.io/badge/Version-VERSION-blue)`
3. **Version constant in code** — if the mod has a `MOD_VERSION` constant in a utils/client Lua file, update it

## Step 4: Validate

- All files have consistent version numbers
- Changelog entries match across all three files
- `[Unreleased]` section in CHANGELOG.md is empty
- ChangeLog.txt has the new entry at the bottom

## Post-Release (when user confirms)

After the user confirms the release is ready:

1. **Check existing tag format** to match convention (`v1.2.0` vs `1.2.0`):
   ```
   git tag --sort=-version:refname
   ```

2. **Merge and tag**:
   ```
   git checkout master
   git merge release/[VERSION]
   git tag [TAG]
   git push origin master
   git push origin [TAG]
   ```

3. **Clean up release branch**:
   ```
   git branch -d release/[VERSION]
   git push origin --delete release/[VERSION]
   ```

Do not merge or tag until the user explicitly confirms.

## Gotchas

- ChangeLog.txt is oldest-first (append at bottom), CHANGELOG.md is newest-first (add at top). Getting this backwards breaks the in-game alert display.
- The `workshop_updates.txt` uses NO markdown — plain text only, no `###`, `**`, etc.
- Some mods have version constants in Lua files (e.g., `MOD_VERSION = "1.2.0"`) — check for these before finishing.
- Multi-version mods have multiple `mod.info` files (one per version folder) — update all of them.
