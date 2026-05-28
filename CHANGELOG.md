# Changelog

## [0.4.0](https://github.com/MarcoAntolini/Fated-Encounters/compare/0.3.3...0.4.0) - 2026-05-26

### Added

- **In-game settings UI:** ImGui panel and menu bar entry (**Fated Encounters**) for all options; stays available when **Mod enabled** is off; syncs with r2modman Config (same `.cfg` file).
- **Chaos Trials support:** **Apply ally guarantees in Chaos Trials** (off by default) guarantees each enabled ally once in that trial's region—curated bounties and randomized Underworld/Surface trials at Difficulty 1 and 2—bypassing base-game bounty and depth gates when forcing encounters.
- **Dream Dives support:** **Apply ally guarantees in Dream Dives** (off by default) for Hypnos Dream Dives. **Random region per ally at run start** is ignored—the route picks four regions as you progress, so each enabled ally is guaranteed in the first eligible region you actually visit on that path.
- **Dream Dive Infernal Contract:** **Guarantee Infernal Contract in Dream Dives** (off by default) when **Guarantee Zagreus Infernal Contract** is on—separate from ally guarantees.
- **Debug log:** run-start summary of pending guarantees; in Dream Dives, a line per region entered (visited regions, remaining pool, eligible pending allies); console lines when guarantees are skipped or a pending ally could not be forced—useful when reporting bugs.

### Changed

- Config reorganized into **Allies**, **After True Ending**, and **Chaos Trials & Dream Dives** sections (schema version 6; existing `.cfg` files migrate automatically, including legacy flat keys).
- Reformed Chronos and Infernal Contract guarantees no longer run on Chaos Trials or Dream Dives (except the optional Dream Dive contract toggle).
- **README:** **Settings reference** maps in-game section names to config keys; adds **Examples**, a settings panel screenshot, sync notes (**Refresh All Edits** in r2modman after in-game changes), and when each option takes effect in gameplay.
- **Contributing guide:** New **Documentation** section with module map and Lua/EmmyLua conventions for pull requests.
- GitHub issue and PR templates mention the in-game **Fated Encounters** settings window, Chaos Trials, and Dream Dives.
- Thunderstore description highlights in-game settings and optional Chaos Trials / Dream Dives support.

### Fixed

- In-game settings now save reliably to the shared `.cfg` file; pre-v6 flat keys are cleaned up on upgrade instead of fighting nested settings.
- Fixed duplicate **MarcoAntolini-FatedEncounters** entries in r2modman Config after repeated in-game saves.

## [0.3.3](https://github.com/MarcoAntolini/Fated-Encounters/compare/0.3.2...0.3.3) - 2026-05-25

### Changed

- Thunderstore description, README, and r2modman config text use plain in-game language (regions, allies, True Ending) instead of internal terms like field NPC, biome, or clearing.
- Chronos is documented as the reformed Chronos conversation in the hub between Erebus and Oceanus after True Ending—not the Asphodel send event.
- GitHub issue and PR templates use the same plain-language terms.

## [0.3.2](https://github.com/MarcoAntolini/Fated-Encounters/compare/0.3.1...0.3.2) - 2026-05-20

### Fixed

- GitHub release notes were empty when `CHANGELOG.md` had a duplicate version heading before the section with content.

### Changed

- Release workflow no longer runs ChangeLogger; cut `CHANGELOG.md` and bump `thunderstore.toml` locally before dispatch (see CONTRIBUTING).
- Release workflow skips the bot commit when `CHANGELOG.md` and `thunderstore.toml` are already updated for the tag.
- Changelog compare links added for `0.3.0` and `0.2.0`.
- README: removed troubleshooting for legacy plugin folder names (superseded by the `FatedEncounters` package rename in 0.3.0).

## [0.3.1](https://github.com/MarcoAntolini/Fated-Encounters/compare/d5bbaa167f637392114433bc6c0dd3888f3aae8e...0.3.1) - 2026-05-20

### Fixed

- Thunderstore package icon must be 256×256; optimized root `icon.png`.
- Thunderstore README banner did not load (markdown image for release URL rewrite; `images/` kept out of Git LFS for GitHub raw hotlinking).

### Changed

- README header uses `images/banner.png` (512×512); release workflow also rewrites HTML `img src` paths.
- Thunderstore package page links added across README, CONTRIBUTING, and GitHub issue templates.
- GitHub Release workflow populates release notes from the matching `CHANGELOG.md` section.

## [0.3.0](https://github.com/MarcoAntolini/Fated-Encounters/compare/d2725e2...0.3.0) - 2026-05-20

### Added

- `config_migrate.lua` to upgrade existing user configs when the config schema version changes.
- Contributing guide, README contributing section, and GitHub issue/PR templates.

### Changed

- Thunderstore package name is now `FatedEncounters` (plugin folder `MarcoAntolini-FatedEncounters`); docs and templates updated from the old hyphenated slug.
- Internal config `version` is no longer described in r2modman; it is still updated automatically for migrations.
- Removed `guaranteeFieldNPCs` master switch; `fieldNPCs.`* toggles are now the only control for field NPC guarantees.
- Config schema version bumped to `4`; migrating from v3 disables all `fieldNPCs.*` if `guaranteeFieldNPCs` was false (preserves Chronos-only setups).
- README configuration table, examples, and troubleshooting for correct plugin folder naming.

### Fixed

- `StartNewRun` wrapper now returns the run table from vanilla code. Without this, starting a run from the hub crashed with `attempt to index local 'currentRun' (a nil value)` in `DeathLoopLogic.lua`.

## [0.2.0](https://github.com/MarcoAntolini/Fated-Encounters/compare/817f31c6c1798f388aa4e5bb83944e0d4a0464dc...d2725e2) - 2026-05-18

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

