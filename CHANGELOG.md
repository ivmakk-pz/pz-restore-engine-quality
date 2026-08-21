# Changelog

## [Unreleased]

## [1.2.2] - 2026-08-21

### Fixed
- Added safeguards for a rare multiplayer case where the restoration animation could keep looping instead of finishing.
- The parts-per-iteration option no longer resets to default when you save Mod Options from the title screen.

## [1.2.1] - 2026-06-05

### Fixed
- Multiplayer engine restoration never completing for players who joined a host (action stuck at 100%): the timed action is now registered as a global so the server can reconstruct it over the network. Completes the multiplayer fix started in 1.2.0.

## [1.2.0] - 2026-05-24

### Changed
- Updated for Build 42.17+ (dropped legacy 42.12 support)
- Wrench detection now uses item tags instead of type string, supporting Ratchet Wrench and other WRENCH-tagged tools
- Engine parts removal now uses DoRemoveItem for proper weight recalculation
- Moved timed action and core logic to shared Lua scope for multiplayer compatibility
- Migrated sendObjectChange to IsoObjectChange enum
- Localization files switched to JSON format (Build 42.15+ standard)
- Restore option now visible without vehicle key (greyed out with requirements tooltip instead of hidden)
- Shortened mod options description for better readability

### Fixed
- Multiplayer error "no such function ISRestoreEngineQuality.new" caused by timed action in client-only scope
- Mechanics UI not flashing success/failure after restoration due to string-based sendObjectChange
- Player carry weight not updating after consuming engine parts
- Ratchet Wrench and other WRENCH-tagged tools not recognized for restoration requirement

### Added
- ChangeLog.txt for compatibility with "Mod Update and Alert System" and "[B42] Mod Manager" mods

## [1.1.0] - 2025-08-09

### Added
- Auto-open vehicle hood when starting engine restoration
- Auto-equip Wrench when required

### Fixed
- Engine parts in containers (e.g., bags) outside the main inventory were not consumed

## [1.0.0] - 2025-08-07

### Added
- Initial release
- Restore your vehicle's engine quality with a Wrench, Spare Engine Parts, and Mechanical skill 4+
