# Changelog

## [Unreleased]

## [0.3.0] - 2026-05-20

### Added

- `config_migrate.lua` to upgrade existing user configs when the config schema version changes.
- Contributing guide, README contributing section, and GitHub issue/PR templates.

### Changed

- Thunderstore package name is now `FatedEncounters` (plugin folder `MarcoAntolini-FatedEncounters`); docs and templates updated from the old hyphenated slug.
- Internal config `version` is no longer described in r2modman; it is still updated automatically for migrations.
- Removed `guaranteeFieldNPCs` master switch; `fieldNPCs.*` toggles are now the only control for field NPC guarantees.
- Config schema version bumped to `4`; migrating from v3 disables all `fieldNPCs.*` if `guaranteeFieldNPCs` was false (preserves Chronos-only setups).
- README configuration table, examples, and troubleshooting for correct plugin folder naming.

### Fixed

- `StartNewRun` wrapper now returns the run table from vanilla code. Without this, starting a run from the hub crashed with `attempt to index local 'currentRun' (a nil value)` in `DeathLoopLogic.lua`.

## [0.2.0] - 2026-05-18

### Added

- Field NPC encounter guarantees (Nemesis, Artemis, Heracles, Icarus, Athena): once per run, forced in an eligible biome after you enter it.
- Postgame guarantees after True Ending: Zagreus Infernal Contract (when unlocked) and Neo-Chronos clearing.
- Per-NPC toggles under `fieldNPCs`, with `guaranteeFieldNPCs` as a master switch.
- `randomizeFieldNPCBiome`: assign each enabled field NPC a random eligible biome at run start instead of the first biome you visit.
- Chalk-backed config with descriptions for r2modman’s config editor.
- README: configuration guide, options table, and examples.

### Changed

- Thunderstore description and README clarify **once per run** behavior (not once per biome).
- Config schema version `3` (Chalk merges new keys into existing user `.cfg` files).
