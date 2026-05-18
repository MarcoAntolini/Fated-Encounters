---@meta MarcoAntolini-Fated-Encounters

---@alias FatedNPC "Nemesis" | "Artemis" | "Heracles" | "Icarus" | "Athena"

--- Per-NPC field guarantee toggles; each enabled NPC is guaranteed once per run.
---@class FatedEncountersFieldNPCConfig
---@field Nemesis boolean
---@field Artemis boolean
---@field Heracles boolean
---@field Icarus boolean
---@field Athena boolean

--- User-facing config (Chalk wrapper; assigned in main.lua as `public.config`).
---@class FatedEncountersConfig
---@field version number Chalk merge version; do not edit unless you know why.
---@field enabled boolean Master switch for the entire mod.
---@field fieldNPCs FatedEncountersFieldNPCConfig
---@field randomizeFieldNPCBiome boolean Pick a random eligible biome per field NPC at run start.
---@field guaranteeZagContract boolean After True Ending: guarantee Zagreus Infernal Contract once per run.
---@field guaranteeChronosClearing boolean After True Ending: guarantee Neo-Chronos clearing once per run.
---@field debugLog boolean Log debug lines to the console.

---@class MarcoAntolini-Fated-Encounters.Public
---@field config FatedEncountersConfig Set in main.lua via chalk.auto.

---@type MarcoAntolini-Fated-Encounters.Public
local public = {}

--[[
  After the mod registers (when `enabled` is true), ModUtil exposes:

  - mod.Tracker — run state (`IsPending`, `GetState`, `IsFieldNPCEnabled`, …)
  - mod.Encounters — biome/NPC encounter tables and lookups
  - mod.Guarantee — ChooseEncounter / eligibility hooks
  - mod.Zagreus — Infernal Contract guarantee
  - mod.Chronos — Neo-Chronos clearing guarantee

  Access from another plugin: local fe = rom.mods['MarcoAntolini-Fated-Encounters']
]]

return public
