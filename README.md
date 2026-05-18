# Fated Encounters

A Hades II mod that guarantees NPC encounters you would normally miss on a run—field combats (Nemesis, Artemis, Heracles, Icarus, Athena) and, after True Ending, Zagreus’s Infernal Contract and the Neo-Chronos clearing.

Install with [r2modman](https://thunderstore.io/c/hades-ii/p/ebkr/r2modman/) or Thunderstore. Requires [Hell2Modding](https://thunderstore.io/c/hades-ii/p/Hell2Modding/Hell2Modding/) and the dependencies listed on the Thunderstore page.

## How it works

- **Field NPCs:** Each enabled NPC is guaranteed **once per run**. The mod forces their field encounter in an eligible biome after you enter that biome, then stops tracking them for the rest of the run.
  - **Default:** The biome is whichever eligible region you reach **first** on your route.
  - **Optional (`randomizeFieldNPCBiome`):** At run start, each NPC is assigned **one random** eligible biome and is only forced there (you must still visit that biome).
- **Zagreus:** After True Ending, can guarantee the Infernal Contract once per run where that content is unlocked.
- **Chronos:** After True Ending, can guarantee the Neo-Chronos clearing encounter once per run.

## Configuration

Settings are managed with [Chalk](https://thunderstore.io/c/hades-ii/p/SGG_Modding/Chalk/) and appear in **r2modman → Config** (or in your profile’s `ReturnOfModding/config/` as `MarcoAntolini-Fated-Encounters.cfg`).

Defaults live in `src/config.lua`. The first time you load the mod, Chalk creates or updates the `.cfg` file from those defaults. Changing options in r2modman edits the `.cfg`; you do not need to edit Lua unless you are developing the mod.

**Note:** Config files persist even if you uninstall the mod. Remove or reset the `.cfg` manually if you want a clean slate.

### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enabled` | bool | `true` | Master switch for the whole mod. |
| `guaranteeFieldNPCs` | bool | `true` | Master switch for all field NPC guarantees. When `false`, every `fieldNPCs.*` option is ignored. |
| `fieldNPCs.Nemesis` | bool | `true` | Guarantee meeting Nemesis **once** this run. |
| `fieldNPCs.Artemis` | bool | `true` | Guarantee meeting Artemis **once** this run. |
| `fieldNPCs.Heracles` | bool | `true` | Guarantee meeting Heracles **once** this run. |
| `fieldNPCs.Icarus` | bool | `true` | Guarantee meeting Icarus **once** this run. |
| `fieldNPCs.Athena` | bool | `true` | Guarantee meeting Athena **once** this run. |
| `randomizeFieldNPCBiome` | bool | `false` | Pick a random eligible biome per field NPC at run start instead of the first biome you visit. |
| `guaranteeZagContract` | bool | `true` | After True Ending: guarantee Zagreus Infernal Contract once per run when unlocked. |
| `guaranteeChronosClearing` | bool | `true` | After True Ending: guarantee Neo-Chronos clearing once per run. |
| `debugLog` | bool | `false` | Print `[FatedEncounters]` messages to the console. |

### Examples

- **All field NPCs, no postgame:** `guaranteeFieldNPCs = true`, all `fieldNPCs.* = true`, `guaranteeZagContract = false`, `guaranteeChronosClearing = false`.
- **Only Nemesis and Artemis:** `guaranteeFieldNPCs = true`, enable only those two under `fieldNPCs`, disable the rest.
- **Random biomes each run:** `randomizeFieldNPCBiome = true` (with field NPCs enabled). Check `debugLog` to see assigned biomes in the console.
- **Turn off all field guarantees but keep Chronos:** `guaranteeFieldNPCs = false`, `guaranteeChronosClearing = true` (requires True Ending progress in your save).

## Development

See the [Hades II Mod Wiki](https://sgg-modding.github.io/Hades2ModWiki/) and the [mod template](https://github.com/SGG-Modding/Hades2ModTemplate). Symlink `src` into your r2modman profile’s `ReturnOfModding/plugins/MarcoAntolini-Fated-Encounters` for live reload while editing.

## License

MIT — see [LICENSE](LICENSE).
