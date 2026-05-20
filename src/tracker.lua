---@meta _
-- Per-run state for guaranteed NPC encounters.

tracker = {}

local FIELD_NPCS = { "Nemesis", "Artemis", "Heracles", "Icarus", "Athena" }

---@param npc string
---@return boolean
function tracker.IsFieldNPCEnabled(npc)
	local perNpc = config.fieldNPCs
	if perNpc == nil then
		return false
	end
	local enabled = perNpc[npc]
	if enabled == nil then
		return false
	end
	return enabled == true
end

function tracker.HasAnyFieldNPCEnabled()
	for _, npc in ipairs(FIELD_NPCS) do
		if tracker.IsFieldNPCEnabled(npc) then
			return true
		end
	end
	return false
end

function tracker.DebugLog(message)
	if config.debugLog then
		print("[FatedEncounters] " .. tostring(message))
	end
end

---@param run table
function tracker.CreateState(run)
	local pending = {}
	local assignedBiome = {}
	for _, npc in ipairs(FIELD_NPCS) do
		if tracker.IsFieldNPCEnabled(npc) then
			pending[npc] = true
			if config.randomizeFieldNPCBiome then
				assignedBiome[npc] = encounters.PickRandomBiomeForNPC(npc)
				if assignedBiome[npc] ~= nil then
					tracker.DebugLog("Assigned " .. npc .. " to biome " .. assignedBiome[npc])
				end
			end
		end
	end

	local pendingZagContract = false
	local pendingChronosClearing = false
	local reachedTrueEnding = game.GameState ~= nil and game.GameState.ReachedTrueEnding == true

	if reachedTrueEnding and config.guaranteeZagContract and run ~= nil then
		pendingZagContract = zagreus.IsInfernalContractUnlockedForRun(run)
	end

	if reachedTrueEnding and config.guaranteeChronosClearing then
		pendingChronosClearing = true
	end

	return {
		Pending = pending,
		AssignedBiome = assignedBiome,
		BiomesEntered = {},
		ActiveForceNPC = nil,
		PendingZagContract = pendingZagContract,
		PendingChronosClearing = pendingChronosClearing,
	}
end

---@param run table
function tracker.InitRun(run)
	if run == nil then
		return
	end
	run.FatedEncounters = tracker.CreateState(run)
	tracker.DebugLog("Initialized FatedEncounters run state")
end

function tracker.ShouldInitRun()
	return tracker.HasAnyFieldNPCEnabled()
		or config.guaranteeZagContract
		or config.guaranteeChronosClearing
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
	local state = tracker.GetState(run)
	if state == nil or not encounters.NPCCanAppearInBiome(npc, biome) then
		return false
	end
	if config.randomizeFieldNPCBiome then
		local assigned = state.AssignedBiome and state.AssignedBiome[npc]
		if assigned == nil or assigned ~= biome then
			return false
		end
	end
	return state.BiomesEntered[biome] == true
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
	if not tracker.HasAnyFieldNPCEnabled() or encounter == nil or encounter.Name == nil then
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
	local run = base(prevRun, args)
	if tracker.ShouldInitRun() and game.CurrentRun ~= nil then
		tracker.InitRun(game.CurrentRun)
	end
	return run
end

function tracker.WrapStartRoom(base, currentRun, currentRoom)
	base(currentRun, currentRoom)
	if not tracker.HasAnyFieldNPCEnabled() or currentRun == nil or currentRoom == nil then
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
