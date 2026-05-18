# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Per-NPC toggles under `fieldNPCs` (Nemesis, Artemis, Heracles, Icarus, Athena), with `guaranteeFieldNPCs` as a master switch for field guarantees.
- `randomizeFieldNPCBiome`: assign each field NPC a random eligible biome at run start instead of the first biome you visit.
- Chalk descriptions for all config options (shown in r2modman’s config editor).
- README configuration section: options table, examples, and how to edit via r2modman or `.cfg`.

### Changed

- Config and README wording clarified: field NPCs are guaranteed **once per run**, not once per biome.
- Config schema version bumped to `3` (Chalk merges new keys into existing user configs).
