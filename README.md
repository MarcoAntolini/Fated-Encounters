<div align="center">

![Fated Encounters mod banner](./images/banner.png)

</div>

# Fated Encounters

**[Thunderstore](https://thunderstore.io/c/hades-ii/p/MarcoAntolini/FatedEncounters/)** · [Report a bug](https://github.com/MarcoAntolini/Fated-Encounters/issues/new?template=bug_report.yml) · [Request a feature](https://github.com/MarcoAntolini/Fated-Encounters/issues/new?template=feature_request.yml)

A Hades II mod that guarantees NPC encounters you would normally miss on a run—field combats (Nemesis, Artemis, Heracles, Icarus, Athena) and, after True Ending, Zagreus’s Infernal Contract and the Neo-Chronos clearing.

Install with [r2modman](https://thunderstore.io/c/hades-ii/p/ebkr/r2modman/) or [Thunderstore](https://thunderstore.io/c/hades-ii/p/MarcoAntolini/FatedEncounters/). Requires [Hell2Modding](https://thunderstore.io/c/hades-ii/p/Hell2Modding/Hell2Modding/) and the dependencies listed on the [package page](https://thunderstore.io/c/hades-ii/p/MarcoAntolini/FatedEncounters/).

## How it works

- **Field NPCs:** Turn on each NPC under `fieldNPCs` in config. Each enabled NPC is guaranteed **once per run**. The mod forces their field encounter in an eligible biome after you enter that biome, then stops tracking them for the rest of the run.
  - **Default:** The biome is whichever eligible region you reach **first** on your route.
  - **Optional (`randomizeFieldNPCBiome`):** At run start, each NPC is assigned **one random** eligible biome and is only forced there (you must still visit that biome).
- **Zagreus:** After True Ending, can guarantee the Infernal Contract once per run where that content is unlocked.
- **Chronos:** After True Ending, can guarantee the Neo-Chronos clearing encounter once per run.

## Configuration

Settings are managed with [Chalk](https://thunderstore.io/c/hades-ii/p/SGG_Modding/Chalk/) and appear in **r2modman → Config** (or in your profile’s `ReturnOfModding/config/` as `MarcoAntolini-FatedEncounters.cfg`).

**Note:** Config files persist even if you uninstall the mod. Delete or reset `MarcoAntolini-FatedEncounters.cfg` manually for a clean slate.

### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enabled` | bool | `true` | Master switch for the entire mod. When `false`, hooks do not run. |
| `fieldNPCs.Nemesis` | bool | `true` | Guarantee meeting Nemesis **once** this run. |
| `fieldNPCs.Artemis` | bool | `true` | Guarantee meeting Artemis **once** this run. |
| `fieldNPCs.Heracles` | bool | `true` | Guarantee meeting Heracles **once** this run. |
| `fieldNPCs.Icarus` | bool | `true` | Guarantee meeting Icarus **once** this run. |
| `fieldNPCs.Athena` | bool | `true` | Guarantee meeting Athena **once** this run. |
| `randomizeFieldNPCBiome` | bool | `false` | At run start, assign each enabled field NPC a random eligible biome (only forced there). When `false`, use the first eligible biome you enter. |
| `guaranteeZagContract` | bool | `true` | After True Ending: guarantee Zagreus Infernal Contract once per run when unlocked for that run. |
| `guaranteeChronosClearing` | bool | `true` | After True Ending: guarantee Neo-Chronos clearing once per run. |
| `debugLog` | bool | `false` | Print `[FatedEncounters]` messages to the game console (useful when reporting bugs). |

### Examples

- **All field NPCs, no postgame:** `enabled = true`, all `fieldNPCs.* = true`, `guaranteeZagContract = false`, `guaranteeChronosClearing = false`.
- **Only Nemesis and Artemis:** enable only those two under `fieldNPCs`, disable the rest.
- **Random biomes each run:** `randomizeFieldNPCBiome = true` with the NPCs you want enabled; use `debugLog` to see assigned biomes in the console.
- **Chronos only (no field NPCs):** all `fieldNPCs.* = false`, `guaranteeChronosClearing = true` (requires True Ending on your save).
- **Disable everything temporarily:** `enabled = false`.

## Contributing

Contributions are welcome—bug reports, feature ideas, docs, and code.

- **[Thunderstore page](https://thunderstore.io/c/hades-ii/p/MarcoAntolini/FatedEncounters/)** — install, versions, and dependencies.
- **[Contributing guide](CONTRIBUTING.md)** — dev setup (r2modman symlink), change expectations, and releases.
- **[Report a bug](https://github.com/MarcoAntolini/Fated-Encounters/issues/new?template=bug_report.yml)** — use the template so we can reproduce issues.
- **[Request a feature](https://github.com/MarcoAntolini/Fated-Encounters/issues/new?template=feature_request.yml)** — describe behavior and config ideas.
- **[Open a pull request](https://github.com/MarcoAntolini/Fated-Encounters/compare)** — see the PR checklist in [`.github/pull_request_template.md`](.github/pull_request_template.md).

For general Hades II modding help (loader, dependencies, other mods), the [Hades II Modding Discord](https://discord.gg/KuMbyrN) is a good place to ask.

## License

MIT — see [LICENSE](LICENSE).
