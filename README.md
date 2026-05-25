<div align="center">

![Fated Encounters mod banner](./images/banner.png)

</div>

# Fated Encounters

**[Thunderstore](https://thunderstore.io/c/hades-ii/p/MarcoAntolini/FatedEncounters/)** · [Report a bug](https://github.com/MarcoAntolini/Fated-Encounters/issues/new?template=bug_report.yml) · [Request a feature](https://github.com/MarcoAntolini/Fated-Encounters/issues/new?template=feature_request.yml)

A Hades II mod that makes sure you do not miss important encounters on a run: combat meetings with Nemesis, Artemis, Heracles, Icarus, and Athena; and after the True Ending, Zagreus's Infernal Contract and Chronos in the hub between Erebus and Oceanus.

Install with [r2modman](https://thunderstore.io/c/hades-ii/p/ebkr/r2modman/) or [Thunderstore](https://thunderstore.io/c/hades-ii/p/MarcoAntolini/FatedEncounters/). Requires [Hell2Modding](https://thunderstore.io/c/hades-ii/p/Hell2Modding/Hell2Modding/) and the dependencies listed on the [package page](https://thunderstore.io/c/hades-ii/p/MarcoAntolini/FatedEncounters/).

## How it works

- **Allies (Nemesis, Artemis, Heracles, Icarus, Athena):** Turn on each character under `fieldNPCs` in config. Each enabled ally is guaranteed **once per run**. The mod makes their encounter happen in an eligible region after you enter that region, then stops tracking them for the rest of the run.
  - **Default:** The region is whichever eligible one you reach **first** on your route.
  - **Optional (`randomizeFieldNPCBiome`):** At run start, each ally is assigned **one random** eligible region and only appears there (you must still visit that region).
- **Zagreus:** After the True Ending, can guarantee the Infernal Contract once per run where that content is unlocked on your save.
- **Chronos:** After the True Ending, can guarantee **reformed Chronos** appears for a conversation in the **hub room between Erebus and Oceanus** (the transition area after the Erebus guardian). Once per run. This is not the event where Chronos sends you to Asphodel.

## Configuration

Settings are managed with [Chalk](https://thunderstore.io/c/hades-ii/p/SGG_Modding/Chalk/) and appear in **r2modman → Config** (or in your profile's `ReturnOfModding/config/` as `MarcoAntolini-FatedEncounters.cfg`).

**Note:** Config files persist even if you uninstall the mod. Delete or reset `MarcoAntolini-FatedEncounters.cfg` manually for a clean slate.

### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enabled` | bool | `true` | Master switch for the entire mod. When `false`, the mod does nothing. |
| `fieldNPCs.Nemesis` | bool | `true` | Guarantee meeting Nemesis **once** this run. |
| `fieldNPCs.Artemis` | bool | `true` | Guarantee meeting Artemis **once** this run. |
| `fieldNPCs.Heracles` | bool | `true` | Guarantee meeting Heracles **once** this run. |
| `fieldNPCs.Icarus` | bool | `true` | Guarantee meeting Icarus **once** this run. |
| `fieldNPCs.Athena` | bool | `true` | Guarantee meeting Athena **once** this run. |
| `randomizeFieldNPCBiome` | bool | `false` | At run start, assign each enabled ally a random eligible region (only appears there). When `false`, use the first eligible region you enter. |
| `guaranteeZagContract` | bool | `true` | After True Ending: guarantee Zagreus offers the Infernal Contract once per run when unlocked. |
| `guaranteeChronosClearing` | bool | `true` | After True Ending: guarantee Chronos in the Erebus–Oceanus hub once per run (conversation encounter, not the Asphodel send). |
| `debugLog` | bool | `false` | Print `[FatedEncounters]` messages to the game console (useful when reporting bugs). |

### Examples

- **All allies, nothing after True Ending:** `enabled = true`, all `fieldNPCs.* = true`, `guaranteeZagContract = false`, `guaranteeChronosClearing = false`.
- **Only Nemesis and Artemis:** enable only those two under `fieldNPCs`, disable the rest.
- **Random region each run:** `randomizeFieldNPCBiome = true` with the allies you want enabled; use `debugLog` to see assigned regions in the console.
- **Chronos only (no allies):** all `fieldNPCs.* = false`, `guaranteeChronosClearing = true` (requires True Ending on your save).
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
