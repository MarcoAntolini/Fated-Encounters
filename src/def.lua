---@meta MarcoAntolini-FatedEncounters
-- Public config and mod API types for other plugins (EmmyLua / VS Code).

---@alias FatedNPC "Nemesis" | "Artemis" | "Heracles" | "Icarus" | "Athena"
--- Room-set prefix for an eligible ally region (first letter of RoomSetName).
---@alias FatedBiome "F" | "G" | "H" | "I" | "N" | "O" | "P"

--- Per-NPC field guarantee toggles; each enabled NPC is guaranteed once per run.
---@class FatedEncountersFieldNPCConfig
---@field Nemesis boolean
---@field Artemis boolean
---@field Heracles boolean
---@field Icarus boolean
---@field Athena boolean

---@class FatedEncountersAlliesConfig
---@field fieldNPCs FatedEncountersFieldNPCConfig
---@field randomizeFieldNPCBiome boolean Pick a random eligible biome per field NPC at run start.

---@class FatedEncountersPostTrueEndingConfig
---@field guaranteeZagContract boolean After True Ending: guarantee Zagreus Infernal Contract once per run.
---@field guaranteeChronosClearing boolean After True Ending: guarantee reformed Chronos in the Erebus–Oceanus hub once per run.

---@class FatedEncountersRunModesConfig
---@field chaosTrials boolean Apply field ally guarantees during Chaos Trials.
---@field dreamDives boolean Apply field ally guarantees during Dream Dives.
---@field dreamDivesZagContract boolean Guarantee Infernal Contract in Dream Dives when enabled (independent of ally guarantees).

--- Per-run guarantee tracking on `run.FatedEncounters` (see mod.Tracker).
---@class FatedEncountersRunState
---@field Pending table<FatedNPC, boolean> Allies still waiting for their once-per-run meeting.
---@field AssignedBiome table<FatedNPC, FatedBiome|nil> Fixed region when random shuffle is on, or Chaos Trial region.
---@field BiomesEntered table<FatedBiome, boolean> Regions entered this run (ally triggers after first visit).
---@field ActiveForceNPC FatedNPC|nil Set only while ChooseEncounter is forcing an ally.
---@field PendingZagContract boolean Infernal Contract not yet accepted this run.
---@field PendingChronosClearing boolean Reformed Chronos hub encounter not yet seen this run.
---@field ChaosTrialBiome FatedBiome|nil Trial region when ally guarantees run in a Chaos Trial.
---@field NeedsChaosTrialSetup boolean|nil True until the trial region is detected and allies are pinned.

--- User-facing config (Chalk wrapper; assigned in main.lua as `public.config`).
---@class FatedEncountersConfig
---@field version number Chalk merge version; do not edit unless you know why.
---@field enabled boolean Master switch for the entire mod.
---@field debugLog boolean Log debug lines to the console.
---@field allies FatedEncountersAlliesConfig Field ally guarantees for normal and special runs.
---@field postTrueEnding FatedEncountersPostTrueEndingConfig Post–True Ending content guarantees.
---@field runModes FatedEncountersRunModesConfig Per-mode toggles for Chaos Trials and Dream Dives.

---@class MarcoAntolini-FatedEncounters.Public
---@field config FatedEncountersConfig Set in main.lua via chalk.auto.

---@type MarcoAntolini-FatedEncounters.Public
local public = {}

--[[
  After the mod registers (when `enabled` is true), ModUtil exposes:

  - mod.Tracker — run state (`IsPending`, `GetState`, `IsFieldNPCEnabled`, …)
  - mod.RunModes — Chaos Trial / Dream Dive detection and gating
  - mod.Encounters — biome/NPC encounter tables and lookups
  - mod.Guarantee — ChooseEncounter / eligibility hooks
  - mod.Zagreus — Infernal Contract guarantee
  - mod.Chronos — reformed Chronos hub guarantee
  - mod.Gui — ImGui settings panel (`DrawMenu`)

  Access from another plugin: local fe = rom.mods['MarcoAntolini-FatedEncounters']
  Config paths: config.allies.fieldNPCs, config.postTrueEnding, config.runModes
]]

return public
