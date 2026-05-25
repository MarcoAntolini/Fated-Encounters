# Changelog

## [Unreleased]

## [0.3.3] - 2026-05-25

### Changed

- Thunderstore description, README, and r2modman config text use plain in-game language (regions, allies, True Ending) instead of internal terms like field NPC, biome, or clearing.
- Chronos is documented as the reformed Chronos conversation in the hub between Erebus and Oceanus after True Ending—not the Asphodel send event.
- GitHub issue and PR templates use the same plain-language terms.

## [0.3.2] - 2026-05-20

### Fixed

- GitHub release notes were empty when `CHANGELOG.md` had a duplicate version heading before the section with content.

### Changed

- Release workflow no longer runs ChangeLogger; cut `CHANGELOG.md` and bump `thunderstore.toml` locally before dispatch (see CONTRIBUTING).
- Release workflow skips the bot commit when `CHANGELOG.md` and `thunderstore.toml` are already updated for the tag.
- Changelog compare links added for `0.3.0` and `0.2.0`.
- README: removed troubleshooting for legacy plugin folder names (superseded by the `FatedEncounters` package rename in 0.3.0).

## [0.3.1] - 2026-05-20

### Fixed

- Thunderstore package icon must be 256×256; optimized root `icon.png`.
- Thunderstore README banner did not load (markdown image for release URL rewrite; `images/` kept out of Git LFS for GitHub raw hotlinking).

### Changed

- README header uses `images/banner.png` (512×512); release workflow also rewrites HTML `img src` paths.
- Thunderstore package page links added across README, CONTRIBUTING, and GitHub issue templates.
- GitHub Release workflow populates release notes from the matching `CHANGELOG.md` section.

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

[unreleased]: https://github.com/MarcoAntolini/Fated-Encounters/compare/0.3.3...HEAD
[0.3.3]: https://github.com/MarcoAntolini/Fated-Encounters/compare/0.3.2...0.3.3
[0.3.2]: https://github.com/MarcoAntolini/Fated-Encounters/compare/0.3.1...0.3.2
[0.3.1]: https://github.com/MarcoAntolini/Fated-Encounters/compare/d5bbaa167f637392114433bc6c0dd3888f3aae8e...0.3.1
[0.3.0]: https://github.com/MarcoAntolini/Fated-Encounters/compare/d2725e2...0.3.0
[0.2.0]: https://github.com/MarcoAntolini/Fated-Encounters/compare/817f31c6c1798f388aa4e5bb83944e0d4a0464dc...d2725e2
