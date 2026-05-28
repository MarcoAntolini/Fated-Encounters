---@meta _
-- Per-run state on `run.FatedEncounters`: pending allies, biome visits, Zagreus/Chronos flags.

tracker = {}

local FIELD_NPCS = { "Nemesis", "Artemis", "Heracles", "Icarus", "Athena" }

---@param npc FatedNPC
---@return boolean
function tracker.IsFieldNPCEnabled(npc)
	local allies = config.allies
	local perNpc = allies ~= nil and allies.fieldNPCs or nil
	if perNpc == nil then
		return false
	end
	local enabled = perNpc[npc]
	if enabled == nil then
		return false
	end
	return enabled == true
end

---@return boolean
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

--- Chaos Trials are single-region: every enabled ally that can appear there is pinned to that region (shuffle ignored).
--- Mutates `state.Pending` / `state.AssignedBiome` in place so the caller's references stay valid.
---@param state FatedEncountersRunState
---@param biome FatedBiome
local function applyChaosTrialAllySetup(state, biome)
	state.ChaosTrialBiome = biome
	state.NeedsChaosTrialSetup = false
	state.Pending = state.Pending or {}
	state.AssignedBiome = state.AssignedBiome or {}
	state.BiomesEntered = state.BiomesEntered or {}
	for k in pairs(state.Pending) do
		state.Pending[k] = nil
	end
	for k in pairs(state.AssignedBiome) do
		state.AssignedBiome[k] = nil
	end

	local labels = {}
	for _, npc in ipairs(FIELD_NPCS) do
		if tracker.IsFieldNPCEnabled(npc) and encounters.NPCCanAppearInBiome(npc, biome) then
			state.Pending[npc] = true
			state.AssignedBiome[npc] = biome
			table.insert(labels, npc)
		end
	end

	state.BiomesEntered[biome] = true
	if config.debugLog then
		local allyText = #labels > 0 and table.concat(labels, ", ") or "none"
		tracker.DebugLog("Chaos Trial region " .. biome .. ": guaranteeing " .. allyText)
	end
end

---@param run table|nil
---@return boolean
function tracker.UsesAssignedBiome(run)
	if run_modes.ShouldBypassChaosTrialRequirements(run) then
		return true
	end
	-- Dream Dives pick regions one at a time from a pool, visiting only 4 of 8 possible biomes.
	-- Pre-assigning a random region risks pinning to a biome the run never visits; spawn
	-- opportunistically in the first eligible visited region instead.
	if run_modes.IsDreamDive(run) then
		return false
	end
	local allies = config.allies
	return allies ~= nil and allies.randomizeFieldNPCBiome == true
end

---@param run table
---@return FatedEncountersRunState
function tracker.CreateState(run)
	local pending = {}
	local assignedBiome = {}
	local biomesEntered = {}
	local chaosTrialBiome = nil
	local needsChaosTrialSetup = false

	if run_modes.ShouldApplyFieldGuarantees(run) then
		if run_modes.ShouldBypassChaosTrialRequirements(run) then
			chaosTrialBiome = run_modes.GetChaosTrialBiome(run)
			if chaosTrialBiome ~= nil then
				local stateStub = {
					Pending = pending,
					AssignedBiome = assignedBiome,
					BiomesEntered = biomesEntered,
				}
				applyChaosTrialAllySetup(stateStub, chaosTrialBiome)
				chaosTrialBiome = stateStub.ChaosTrialBiome
				needsChaosTrialSetup = stateStub.NeedsChaosTrialSetup
			else
				needsChaosTrialSetup = true
			end
		else
			-- Dream Dives draw 4 of 8 possible regions lazily during transitions, so we can't
			-- predict the route. Skip random pre-assignment and let allies fire in the first
			-- eligible region visited (see UsesAssignedBiome).
			local isDreamDive = run_modes.IsDreamDive(run)
			local shuffle = config.allies ~= nil and config.allies.randomizeFieldNPCBiome == true
			for _, npc in ipairs(FIELD_NPCS) do
				if tracker.IsFieldNPCEnabled(npc) then
					pending[npc] = true
					if shuffle and not isDreamDive then
						assignedBiome[npc] = encounters.PickRandomBiomeForNPC(npc)
						if assignedBiome[npc] ~= nil then
							tracker.DebugLog("Assigned " .. npc .. " to biome " .. assignedBiome[npc])
						end
					end
				end
			end
			if isDreamDive and shuffle then
				tracker.DebugLog(
					"Dream Dive: random-region shuffle ignored (regions decided at biome transitions); "
						.. "allies will fire in the first eligible region visited"
				)
			end
		end
	end

	local pendingZagContract = false
	local pendingChronosClearing = false

	if run_modes.ShouldApplyZagGuarantee(run) and run ~= nil then
		pendingZagContract = zagreus.IsInfernalContractUnlockedForRun(run)
	end

	if run_modes.ShouldApplyChronosGuarantee(run) then
		pendingChronosClearing = true
	end

	return {
		Pending = pending,
		AssignedBiome = assignedBiome,
		BiomesEntered = biomesEntered,
		ActiveForceNPC = nil,
		PendingZagContract = pendingZagContract,
		PendingChronosClearing = pendingChronosClearing,
		ChaosTrialBiome = chaosTrialBiome,
		NeedsChaosTrialSetup = needsChaosTrialSetup,
	}
end

---@param run table
---@param state FatedEncountersRunState
local function logGuaranteeDecisions(run, state)
	if not config.debugLog then
		return
	end

	if tracker.HasAnyFieldNPCEnabled() and not run_modes.ShouldApplyFieldGuarantees(run) then
		tracker.DebugLog("Ally guarantees skipped: " .. run_modes.FieldGuaranteeSkipReason(run))
	end

	local postTE = config.postTrueEnding
	if postTE ~= nil and postTE.guaranteeZagContract then
		if not run_modes.ShouldApplyZagGuarantee(run) then
			tracker.DebugLog("Infernal Contract guarantee skipped: " .. run_modes.ZagGuaranteeSkipReason(run))
		elseif not state.PendingZagContract then
			tracker.DebugLog(
				"Infernal Contract guarantee skipped: requirements not met this run (True Ending / contract unlock)"
			)
		end
	end

	if postTE ~= nil and postTE.guaranteeChronosClearing and not run_modes.ShouldApplyChronosGuarantee(run) then
		tracker.DebugLog("Reformed Chronos guarantee skipped: " .. run_modes.ChronosGuaranteeSkipReason(run))
	end
end

---@param run table
---@param state FatedEncountersRunState
local function logRunInitSummary(run, state)
	if not config.debugLog then
		return
	end

	local pendingAllies = {}
	for _, npc in ipairs(FIELD_NPCS) do
		if state.Pending[npc] then
			local label = npc
			if state.AssignedBiome[npc] ~= nil then
				label = label .. "@" .. state.AssignedBiome[npc]
			end
			table.insert(pendingAllies, label)
		end
	end

	local allyText = #pendingAllies > 0 and table.concat(pendingAllies, ", ") or "none"
	if state.NeedsChaosTrialSetup then
		allyText = "pending region detection"
	elseif state.ChaosTrialBiome ~= nil then
		allyText = allyText .. " (Chaos Trial region " .. state.ChaosTrialBiome .. ")"
	end
	local extras = {}
	if state.PendingZagContract then
		table.insert(extras, "Infernal Contract")
	end
	if state.PendingChronosClearing then
		table.insert(extras, "reformed Chronos")
	end

	local summary = "Run start (" .. run_modes.DescribeRun(run) .. "): pending allies=" .. allyText
	if #extras > 0 then
		summary = summary .. "; also " .. table.concat(extras, ", ")
	end
	tracker.DebugLog(summary)
end

---@param run table
function tracker.InitRun(run)
	if run == nil or run.FatedEncounters ~= nil then
		return
	end
	local state = tracker.CreateState(run)
	run.FatedEncounters = state
	logGuaranteeDecisions(run, state)
	logRunInitSummary(run, state)
end

--- Lazy init when guarantees apply but StartNewRun ran before bounty/mode flags were set.
---@param run table|nil
function tracker.EnsureInitialized(run)
	run = run or game.CurrentRun
	if run == nil then
		return
	end
	if run.FatedEncounters == nil then
		if not run_modes.ShouldApplyFieldGuarantees(run) then
			return
		end
		tracker.InitRun(run)
	end
end

--- Finish Chaos Trial ally setup once the trial region is known (shuffle is ignored).
---@param run table|nil
---@param biome FatedBiome|nil
function tracker.EnsureChaosTrialSetup(run, biome)
	if not run_modes.ShouldBypassChaosTrialRequirements(run) then
		return
	end

	run = run or game.CurrentRun
	if run == nil then
		return
	end

	tracker.EnsureInitialized(run)

	local state = tracker.GetState(run)
	if state == nil or not state.NeedsChaosTrialSetup then
		return
	end

	biome = biome or run_modes.GetChaosTrialBiome(run)
	if biome == nil then
		return
	end

	applyChaosTrialAllySetup(state, biome)
end

---@param run table|nil
---@return FatedEncountersRunState|nil
function tracker.GetState(run)
	run = run or game.CurrentRun
	if run == nil then
		return nil
	end
	return run.FatedEncounters
end

--- Debug-log Dream Dive context when a new region is entered: visited regions, the
--- remaining game-side region pool, and which pending allies can spawn in this region.
---@param run table
---@param biome FatedBiome
---@param state FatedEncountersRunState
local function logDreamDiveBiomeEntered(run, biome, state)
	if not config.debugLog or not run_modes.IsDreamDive(run) then
		return
	end

	local pool = {}
	if type(run.DreamBiomePool) == "table" then
		for _, b in ipairs(run.DreamBiomePool) do
			table.insert(pool, b)
		end
		table.sort(pool)
	end

	local entered = {}
	for b, was in pairs(state.BiomesEntered or {}) do
		if was then
			table.insert(entered, b)
		end
	end
	table.sort(entered)

	local eligibleHere = {}
	for _, npc in ipairs(FIELD_NPCS) do
		if state.Pending[npc] and encounters.NPCCanAppearInBiome(npc, biome) then
			table.insert(eligibleHere, npc)
		end
	end

	tracker.DebugLog(
		"Dream Dive region "
			.. biome
			.. " entered (visited so far: "
			.. (#entered > 0 and table.concat(entered, ",") or biome)
			.. "; remaining pool: "
			.. (#pool > 0 and table.concat(pool, ",") or "(none)")
			.. "). Pending allies eligible here: "
			.. (#eligibleHere > 0 and table.concat(eligibleHere, ", ") or "none")
	)
end

---@param run table
---@param biome FatedBiome
function tracker.MarkBiomeEntered(run, biome)
	local state = tracker.GetState(run)
	if state == nil or biome == nil then
		return
	end
	local isNewBiome = state.BiomesEntered[biome] ~= true
	state.BiomesEntered[biome] = true
	if isNewBiome then
		logDreamDiveBiomeEntered(run, biome, state)
	end
end

---@param run table
---@param npc FatedNPC
---@return boolean
function tracker.IsPending(run, npc)
	local state = tracker.GetState(run)
	return state ~= nil and state.Pending[npc] == true
end

---@param run table
---@return FatedNPC[]
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
---@param npc FatedNPC
---@param biome FatedBiome
---@return boolean
function tracker.IsNPCEligibleForBiomeThisRun(run, npc, biome)
	if not tracker.IsPending(run, npc) then
		return false
	end
	local state = tracker.GetState(run)
	if state == nil or not encounters.NPCCanAppearInBiome(npc, biome) then
		return false
	end
	if tracker.UsesAssignedBiome(run) then
		local assigned = state.AssignedBiome and state.AssignedBiome[npc]
		if assigned == nil or assigned ~= biome then
			return false
		end
	end
	return state.BiomesEntered[biome] == true
end

---@param run table
---@param npc FatedNPC
function tracker.MarkFulfilled(run, npc)
	local state = tracker.GetState(run)
	if state == nil then
		return
	end
	state.Pending[npc] = false
	tracker.DebugLog("Fulfilled guarantee for " .. npc)
end

--- Ignore intro encounters; vanilla may force those before the run guarantee counts.
---@param run table
---@param encounter table
function tracker.OnEncounterRecorded(run, encounter)
	if not run_modes.ShouldApplyFieldGuarantees(run) or encounter == nil or encounter.Name == nil then
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

---@param base function
---@param prevRun table|nil
---@param args table|nil
---@return table
function tracker.WrapStartNewRun(base, prevRun, args)
	local run = base(prevRun, args)
	if game.CurrentRun == nil then
		return run
	end
	if run_modes.ShouldInitRunForRun(game.CurrentRun) then
		tracker.InitRun(game.CurrentRun)
	else
		run_modes.LogWhyNoRunInit(game.CurrentRun)
	end
	return run
end

---@param base function
---@param currentRun table
---@param currentRoom table
function tracker.WrapStartRoom(base, currentRun, currentRoom)
	base(currentRun, currentRoom)
	if not run_modes.ShouldApplyFieldGuarantees(currentRun) or currentRun == nil or currentRoom == nil then
		return
	end
	local biome = encounters.RoomSetToBiome(currentRoom.RoomSetName)
	if biome ~= nil then
		tracker.EnsureChaosTrialSetup(currentRun, biome)
		tracker.MarkBiomeEntered(currentRun, biome)
	end
end

---@param base function
---@param run table
---@param encounter table
function tracker.WrapRecordEncounter(base, run, encounter)
	base(run, encounter)
	tracker.OnEncounterRecorded(run, encounter)
end

mod.Tracker = tracker
