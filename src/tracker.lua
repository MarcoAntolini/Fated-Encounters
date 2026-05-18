---@meta _
-- Per-run state for guaranteed NPC encounters.

tracker = {}

local FIELD_NPCS = { "Nemesis", "Artemis", "Heracles", "Icarus", "Athena" }

function tracker.DebugLog(message)
	if config.debugLog then
		print("[FatedEncounters] " .. tostring(message))
	end
end

function tracker.CreateState()
	local pending = {}
	for _, npc in ipairs(FIELD_NPCS) do
		pending[npc] = true
	end
	return {
		Pending = pending,
		BiomesEntered = {},
		ActiveForceNPC = nil,
	}
end

---@param run table
function tracker.InitRun(run)
	if run == nil then
		return
	end
	run.FatedEncounters = tracker.CreateState()
	tracker.DebugLog("Initialized FatedEncounters run state")
end

---@param run table|nil
---@return table|nil
function tracker.GetState(run)
	run = run or game.CurrentRun
	if run == nil then
		return nil
	end
	return run.FatedEncounters
end

---@param run table
---@param biome string
function tracker.MarkBiomeEntered(run, biome)
	local state = tracker.GetState(run)
	if state == nil or biome == nil then
		return
	end
	state.BiomesEntered[biome] = true
end

---@param run table
---@param npc string
---@return boolean
function tracker.IsPending(run, npc)
	local state = tracker.GetState(run)
	return state ~= nil and state.Pending[npc] == true
end

---@param run table
---@return string[]
function tracker.GetPendingNPCs(run)
	local state = tracker.GetState(run)
	if state == nil then
		return {}
	end
	local pending = {}
	for _, npc in ipairs(encounters.NPCPriority) do
		if state.Pending[npc] then
			table.insert(pending, npc)
		end
	end
	return pending
end

---@param run table
---@param npc string
---@param biome string
---@return boolean
function tracker.IsNPCEligibleForBiomeThisRun(run, npc, biome)
	if not tracker.IsPending(run, npc) then
		return false
	end
	local biomes = encounters.BiomesByNPC[npc]
	if biomes == nil then
		return false
	end
	local canSpawnHere = false
	for _, b in ipairs(biomes) do
		if b == biome then
			canSpawnHere = true
			break
		end
	end
	if not canSpawnHere then
		return false
	end
	local state = tracker.GetState(run)
	return state ~= nil and state.BiomesEntered[biome] == true
end

---@param run table
---@param npc string
function tracker.MarkFulfilled(run, npc)
	local state = tracker.GetState(run)
	if state == nil then
		return
	end
	state.Pending[npc] = false
	tracker.DebugLog("Fulfilled guarantee for " .. npc)
end

---@param run table
---@param encounter table
function tracker.OnEncounterRecorded(run, encounter)
	if not config.guaranteeFieldNPCs or encounter == nil or encounter.Name == nil then
		return
	end
	if encounters.IsIntroEncounter(encounter.Name) then
		return
	end
	local npc = encounters.GetNPCForEncounter(encounter.Name)
	if npc ~= nil then
		tracker.MarkFulfilled(run, npc)
	end
end

function tracker.WrapStartNewRun(base, prevRun, args)
	base(prevRun, args)
	if config.guaranteeFieldNPCs and game.CurrentRun ~= nil then
		tracker.InitRun(game.CurrentRun)
	end
end

function tracker.WrapStartRoom(base, currentRun, currentRoom)
	base(currentRun, currentRoom)
	if not config.guaranteeFieldNPCs or currentRun == nil or currentRoom == nil then
		return
	end
	local biome = encounters.RoomSetToBiome(currentRoom.RoomSetName)
	if biome ~= nil then
		tracker.MarkBiomeEntered(currentRun, biome)
	end
end

function tracker.WrapRecordEncounter(base, run, encounter)
	base(run, encounter)
	tracker.OnEncounterRecorded(run, encounter)
end

mod.Tracker = tracker
