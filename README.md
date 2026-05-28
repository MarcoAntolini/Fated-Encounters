

Fated Encounters mod banner



# Fated Encounters

**[Install on Thunderstore →](https://thunderstore.io/c/hades-ii/p/MarcoAntolini/FatedEncounters/)**

**Before installing:** Back up your Hades II profile saves (on Windows: `%USERPROFILE%\Saved Games\Hades II\Profile*.sav`) in case a mod update or unknown issue affects your progress. Mod settings are stored separately and persist after uninstall—see [Settings reference](#settings-reference).

A Hades II mod that makes sure you do not miss important encounters on a run: combat meetings with Nemesis, Artemis, Heracles, Icarus, and Athena; and after the True Ending, Zagreus's Infernal Contract and reformed Chronos in the hub between Erebus and Oceanus. Change everything from an **in-game settings window** or **r2modman Config**.

## How it works

- **Allies (Nemesis, Artemis, Heracles, Icarus, Athena):** Turn on each character you want in **Allies** (in-game settings or r2modman). Each enabled ally is guaranteed **once per run**. The mod makes their encounter happen in an eligible region after you enter that region, then stops tracking them for the rest of the run.
  - **Default:** The region is whichever eligible one you reach **first** on your route.
  - **Optional shuffle:** At run start, assign each enabled ally **one random** eligible region—they only appear there (you must still visit that region). **Dream Dives ignore this**—their four regions are picked one at a time at biome transitions, so allies always appear in the first eligible region visited.
- **After True Ending — Zagreus:** Guarantee the Infernal Contract once per run when that content is unlocked on your save.
- **After True Ending — Chronos:** Guarantee **reformed Chronos** for a conversation in the **hub room between Erebus and Oceanus** (the transition area after the Erebus guardian). Once per run. This is not the event where Chronos sends you to Asphodel.
- **Chaos Trials and Dream Dives:** On a normal run, the options above apply as usual. Packaged **Chaos Trials** and Hypnos **Dream Dives** are **off by default**—turn them on if you want ally guarantees in those modes too. Infernal Contract during Dream Dives is a separate optional toggle. Reformed Chronos never applies in Chaos Trials or Dream Dives.

## Examples

- **All allies, nothing after True Ending:** enable all allies; turn off both **After True Ending** options.
- **Only Nemesis and Artemis:** enable just those two under **Allies**; disable the rest.
- **Random region each run:** turn on **Random region per ally at run start** with the allies you want; enable **Debug log** in r2modman (see [Settings reference](#settings-reference)) to see assigned regions in the console.
- **Chronos only (no allies):** disable all allies; enable **Guarantee reformed Chronos in the Erebus–Oceanus hub** (requires True Ending on your save).
- **Chaos Trials allies:** under **Chaos Trials & Dream Dives**, enable **Apply ally guarantees in Chaos Trials** and pick allies under **Allies**.
- **Dream Dives allies:** enable **Apply ally guarantees in Dream Dives** and pick allies under **Allies**.
- **Disable everything temporarily:** turn off **Mod enabled**.

---

## Settings reference



Fated Encounters settings panel in the mod overlay



Open **Fated Encounters** from the mod overlay menu bar, or pick the floating panel in the mod list. The table below maps each in-game section and label to its r2modman config key. Both edit the same file—in r2modman, click **Refresh All Edits** after in-game changes; in-game picks up r2modman saves within a couple of seconds.

Settings are stored with [Chalk](https://thunderstore.io/c/hades-ii/p/SGG_Modding/Chalk/) in your profile as `ReturnOfModding/config/MarcoAntolini-FatedEncounters.cfg`. Config files persist even if you uninstall the mod—delete or reset `MarcoAntolini-FatedEncounters.cfg` manually for a clean slate.

**When changes take effect in gameplay:**

- **Mod enabled (on/off):** reload your mod profile (or restart the game) so guarantee hooks register or unregister.
- **Allies and random region shuffle:** mostly apply on your **next run**. The current run keeps whichever allies were already pending.
- **Chaos Trials and Dream Dives toggles:** can apply on the **current run** once synced.
- **After True Ending options (Zagreus, Chronos):** pending flags are set at run start, like allies.


| Section                    | In-game label                                        | Config key                                | Default | Description                                                                                                                                                                    |
| -------------------------- | ---------------------------------------------------- | ----------------------------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| —                          | Mod enabled                                          | `enabled`                                 | `true`  | Master switch for the entire mod. When off, the mod does nothing.                                                                                                              |
| Allies                     | Nemesis                                              | `allies.fieldNPCs.Nemesis`                | `true`  | Guarantee meeting Nemesis **once** this run.                                                                                                                                   |
| Allies                     | Artemis                                              | `allies.fieldNPCs.Artemis`                | `true`  | Guarantee meeting Artemis **once** this run.                                                                                                                                   |
| Allies                     | Heracles                                             | `allies.fieldNPCs.Heracles`               | `true`  | Guarantee meeting Heracles **once** this run.                                                                                                                                  |
| Allies                     | Icarus                                               | `allies.fieldNPCs.Icarus`                 | `true`  | Guarantee meeting Icarus **once** this run.                                                                                                                                    |
| Allies                     | Athena                                               | `allies.fieldNPCs.Athena`                 | `true`  | Guarantee meeting Athena **once** this run.                                                                                                                                    |
| Allies                     | Random region per ally at run start                  | `allies.randomizeFieldNPCBiome`           | `false` | At run start, assign each enabled ally a random eligible region (only appears there). When off, use the first eligible region you enter. Ignored during Dream Dives—regions are drawn at biome transitions, so allies always fire in the first eligible region visited. |
| After True Ending          | Guarantee Zagreus Infernal Contract                  | `postTrueEnding.guaranteeZagContract`     | `true`  | After True Ending: guarantee Zagreus offers the Infernal Contract once per run when unlocked.                                                                                  |
| After True Ending          | Guarantee reformed Chronos in the Erebus–Oceanus hub | `postTrueEnding.guaranteeChronosClearing` | `true`  | After True Ending: guarantee reformed Chronos in the Erebus–Oceanus hub once per run (conversation encounter, not the Asphodel send).                                          |
| Chaos Trials & Dream Dives | Apply ally guarantees in Chaos Trials                | `runModes.chaosTrials`                    | `false` | Apply ally guarantees during **Chaos Trials** (curated and randomized trials). Off by default—the base game blocks or gates allies in these short runs.                          |
| Chaos Trials & Dream Dives | Apply ally guarantees in Dream Dives                 | `runModes.dreamDives`                     | `false` | Apply ally guarantees during **Dream Dives**. Off by default.                                                                                                                  |
| Chaos Trials & Dream Dives | Guarantee Infernal Contract in Dream Dives           | `runModes.dreamDivesZagContract`          | `false` | Guarantee the Infernal Contract during Dream Dives when the True Ending Zagreus option is on. Separate from ally guarantees; may not trigger if no contract shop room appears. |
| —                          | —                                                    | `debugLog`                                | `false` | **r2modman only.** Print `[FatedEncounters]` messages to the game console (useful when reporting bugs).                                                                        |


## Support

Found a problem or have an idea?

- **[Report a bug](https://github.com/MarcoAntolini/Fated-Encounters/issues/new?template=bug_report.yml)** — use the template so we can reproduce it.
- **[Request a feature](https://github.com/MarcoAntolini/Fated-Encounters/issues/new?template=feature_request.yml)** — describe the behavior you want.

Enable **Debug log** in r2modman (see [Settings reference](#settings-reference)) before reporting issues—it helps a lot.

## Contributing

Code and docs PRs are welcome. See **[CONTRIBUTING.md](CONTRIBUTING.md)** for dev setup and what to include in a pull request.

## License

MIT — see [LICENSE](LICENSE).