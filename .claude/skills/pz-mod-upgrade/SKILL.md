---
name: pz-mod-upgrade
description: >
  Use this skill when upgrading a PZ mod to support a newer game build. Activates when
  the user says "upgrade to latest build", "update for 42.x", "migrate to new version",
  "check API compatibility", "what changed since our build", or when the mod's versionMin
  is behind the current game build. Covers: game changelog analysis, API verification
  against source, implementation planning, and phased execution.
---

# PZ Mod Upgrade Workflow

Upgrades a mod from its last tested game build to the latest available build. Uses the game context repo (see `pz-modding` skill) for release notes and source diffs.

## Step 1: Audit Current State

Gather baseline info:
- Published mod version and branch (check `mod.info` on master)
- Last tested game build (`versionMin` or known from history)
- Current game build (check latest tag in context repo: `git tag --sort=-version:refname`)
- Steam beta branches (check if "outdatedunstable" still serves older builds — if both branches are on the same build, multi-version support may be unnecessary)

## Step 2: Build Game Changelog

Create `docs/CHANGELOG_b{FROM}_to_b{TO}.md` documenting game changes relevant to the mod.

**From release notes** (context repo `release_notes/` directory):
- Read each release note between the mod's last tested build and the latest
- Extract only changes that could affect the mod's specific APIs, systems, and patterns

**Filter for mod-relevant changes:**
- APIs the mod calls directly (list them from the mod's `require` statements and method calls)
- Systems the mod patches or extends (context menus, timed actions, vehicle parts, inventory)
- Modding infrastructure (mod loading, translation format, script syntax)
- Discard unrelated changes (new content, balance tweaks, unrelated bug fixes)

For builds with no relevant changes, note "No relevant changes" in one line — don't pad.

## Step 3: Verify API Compatibility

Compare actual source files between context repo tags using `git diff {OLD_TAG}..{NEW_TAG}`.

**For each API the mod uses, check:**
- Method signature unchanged? (parameters, return values)
- Method body logic changed? (could affect behavior the mod depends on)
- Method moved to different file/scope? (client → shared, renamed)
- New required parameters or enum types?

**Check patterns:**
```
git diff {OLD}..{NEW} -- path/to/file.lua    # Full diff
git diff {OLD}..{NEW} --stat -- path/to/      # Overview of what changed
```

**Report each API as:** UNCHANGED / SIGNATURE CHANGED / LOGIC CHANGED / FILE MOVED

**Gotchas:**
- Don't trust release notes alone — they miss internal refactors. Always diff the source.
- Check if constants the mod uses (like `predicateNotBroken`) are local to another file — moving code to `shared/` can break access to `client/`-scoped locals.
- Enum migrations (string → enum) may still work via auto-coercion but should be updated for correctness.
- If context repo lacks a tag for an intermediate build, diff between the nearest available tags.

## Step 4: Create Implementation Plan

Create `docs/plan-v{VERSION}-migration.md` with:
- Goal, context, scope, out-of-scope sections
- Numbered phases with checkbox steps (use `ticket-implementation-plan` skill format)
- Reference specific files, line numbers, and API changes from Steps 2-3
- Always include a final Verify phase with in-game testing steps

**Common phases for a build upgrade:**
1. Structural changes (folder rename, multi-version decisions, mod.info)
2. File moves (client → shared for MP, if applicable)
3. Code fixes (API migrations, deprecated calls, new patterns)
4. Reference file updates
5. Release metadata (version bump, changelogs)
6. In-game verification

## Step 5: Execute Phase by Phase

- Work through each phase sequentially
- Check off steps as completed
- If a new issue is discovered during testing, add it to the plan rather than fixing silently
- After code changes, test in-game before marking the phase done

## Step 6: Verify In-Game

Minimum test checklist:
- Mod loads without console errors
- Core feature works on vanilla content
- Core feature works on popular modded content (if applicable)
- Mod options render and apply correctly
- No regression in existing functionality

## Gotchas

- **Steam beta branches change**: always verify which builds are actually available to players before deciding on multi-version support. "outdatedunstable" may have caught up to "unstable".
- **`shared/` vs `client/` scope**: when moving files to `shared/` for MP, audit every `require` chain. A shared file cannot access locals from client-scoped files.
- **Translation format**: Build 42.15+ uses JSON, earlier uses Lua-table `.txt`. Check if the mod's localization needs format migration.
- **pcall masking errors**: if the mod wraps initialization in pcall, errors during testing may be silently swallowed. Temporarily enable debug/verbose logging.
- **Workshop comments**: check the mod's Steam Workshop page for player-reported issues — they often reveal exactly which APIs broke and on which build.
