# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Contributing guide, README contributing section, and GitHub issue/PR templates.

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
