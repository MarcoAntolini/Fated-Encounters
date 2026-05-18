# Fated Encounters

A Hades II mod that guarantees NPC encounters you would normally miss on a run—field combats (Nemesis, Artemis, Heracles, Icarus, Athena) and, after True Ending, Zagreus’s Infernal Contract and the Neo-Chronos clearing.

Install with [r2modman](https://thunderstore.io/c/hades-ii/p/ebkr/r2modman/) or Thunderstore. Requires [Hell2Modding](https://thunderstore.io/c/hades-ii/p/Hell2Modding/Hell2Modding/) and the dependencies listed on the Thunderstore page.

## How it works

- **Field NPCs:** For each enabled NPC, the mod tracks which biomes you enter and forces a pending encounter when you are eligible, instead of leaving it to RNG and cooldowns.
- **Zagreus:** After True Ending, can guarantee the Infernal Contract on runs where that content is unlocked.
- **Chronos:** After True Ending, can guarantee the Neo-Chronos clearing encounter.

## Configuration

Settings are managed with [Chalk](https://thunderstore.io/c/hades-ii/p/SGG_Modding/Chalk/) and appear in **r2modman → Config** (or in your profile’s `ReturnOfModding/config/` as `MarcoAntolini-Fated-Encounters.cfg`).

Defaults live in `src/config.lua`. The first time you load the mod, Chalk creates or updates the `.cfg` file from those defaults. Changing options in r2modman edits the `.cfg`; you do not need to edit Lua unless you are developing the mod.

**Note:** Config files persist even if you uninstall the mod. Remove or reset the `.cfg` manually if you want a clean slate.

### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enabled` | bool | `true` | Master switch for the whole mod. |
| `guaranteeFieldNPCs` | bool | `true` | Master switch for all field NPC guarantees. When `false`, every `fieldNPCs.*` option is ignored. |
| `fieldNPCs.Nemesis` | bool | `true` | Guarantee Nemesis in biomes you visit this run. |
| `fieldNPCs.Artemis` | bool | `true` | Guarantee Artemis in biomes you visit this run. |
| `fieldNPCs.Heracles` | bool | `true` | Guarantee Heracles in biomes you visit this run. |
| `fieldNPCs.Icarus` | bool | `true` | Guarantee Icarus in biomes you visit this run. |
| `fieldNPCs.Athena` | bool | `true` | Guarantee Athena in biomes you visit this run. |
| `guaranteeZagContract` | bool | `true` | After True Ending: guarantee Zagreus Infernal Contract when unlocked. |
| `guaranteeChronosClearing` | bool | `true` | After True Ending: guarantee Neo-Chronos clearing. |
| `debugLog` | bool | `false` | Print `[FatedEncounters]` messages to the console. |

### Examples

- **All field NPCs, no postgame:** `guaranteeFieldNPCs = true`, all `fieldNPCs.* = true`, `guaranteeZagContract = false`, `guaranteeChronosClearing = false`.
- **Only Nemesis and Artemis:** `guaranteeFieldNPCs = true`, enable only those two under `fieldNPCs`, disable the rest.
- **Turn off all field guarantees but keep Chronos:** `guaranteeFieldNPCs = false`, `guaranteeChronosClearing = true` (requires True Ending progress in your save).

## Development

See the [Hades II Mod Wiki](https://sgg-modding.github.io/Hades2ModWiki/) and the [mod template](https://github.com/SGG-Modding/Hades2ModTemplate). Symlink `src` into your r2modman profile’s `ReturnOfModding/plugins/MarcoAntolini-Fated-Encounters` for live reload while editing.

## License

MIT — see [LICENSE](LICENSE).
