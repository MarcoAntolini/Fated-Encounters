---@meta _
-- Ally encounter forcing via ChooseEncounter and IsEncounterEligible hooks.

guarantee = {}

--- Unwrapped game IsEncounterEligible (set in WrapIsEncounterEligible).
guarantee._baseIsEncounterEligible = nil

function guarantee.DebugLog(message)
	if config.debugLog then
		print("[FatedEncounters] " .. tostring(message))
	end
end

--- Skip hub-only or single-Empty legal encounter lists (no real combat pool).
---@param room table
---@param currentRun table|nil
---@return boolean
function guarantee.ShouldProcessRoom(room, currentRun)
	currentRun = currentRun or game.CurrentRun
	if not run_modes.ShouldApplyFieldGuarantees(currentRun) then
		return false
	end
	if room == nil or room.LegalEncounters == nil or room.LegalEncountersDictionary == nil then
		return false
	end
	if room.LegalEncountersDictionary["Empty"] then
		local legalCount = 0
		for _ in pairs(room.LegalEncountersDictionary) do
			legalCount = legalCount + 1
		end
		if legalCount <= 1 then
			return false
		end
	end
	return true
end

--- Phase 2+: drop vanilla cooldown NamedRequirements while forcing a pending ally.
---@param encounterData table
function guarantee.StripCooldownNamedRequirements(encounterData)
	if encounterData.GameStateRequirements == nil then
		return
	end
	for _, req in ipairs(encounterData.GameStateRequirements) do
		if req.NamedRequirements ~= nil then
			local filtered = {}
			for _, name in ipairs(req.NamedRequirements) do
				if not encounters.CooldownNamedRequirements[name] then
					table.insert(filtered, name)
				end
			end
			req.NamedRequirements = filtered
		end
	end
end

---@param encounterData table
---@param currentRun table
function guarantee.StripForceBypassRequirements(encounterData, currentRun)
	guarantee.StripCooldownNamedRequirements(encounterData)
	if run_modes.ShouldBypassChaosTrialRequirements(currentRun) then
		encounters.StripChaosTrialBlockedRequirements(encounterData)
		encounters.ClearChaosTrialForceDepthGates(encounterData)
	end
end

---@param currentRun table
---@param encounterData table
---@return boolean
function guarantee.IsBypassingCooldown(currentRun, encounterData)
	local state = tracker.GetState(currentRun)
	if state == nil or state.ActiveForceNPC == nil or encounterData == nil then
		return false
	end
	return encounters.EncounterBelongsToNPC(encounterData.Name, state.ActiveForceNPC)
end

--- Chaos Trials omit allies from LegalEncounters; inject for the duration of one eligibility check.
---@param room table
---@param encounterName string
---@param fn fun(): boolean
---@return boolean
function guarantee.WithTemporaryLegalEncounter(room, encounterName, fn)
	local wasInDict = room.LegalEncountersDictionary[encounterName]
	local listIndex = nil

	if not wasInDict then
		room.LegalEncountersDictionary[encounterName] = true
	end
	if room.LegalEncounters ~= nil then
		local wasInList = false
		for _, name in ipairs(room.LegalEncounters) do
			if name == encounterName then
				wasInList = true
				break
			end
		end
		if not wasInList then
			table.insert(room.LegalEncounters, encounterName)
			listIndex = #room.LegalEncounters
		end
	end

	local ok, result = pcall(fn)
	if not ok then
		error(result)
	end

	if not wasInDict then
		room.LegalEncountersDictionary[encounterName] = nil
	end
	if listIndex ~= nil and room.LegalEncounters ~= nil then
		table.remove(room.LegalEncounters, listIndex)
	end

	return result
end

--- Eligibility for an active force pick (cooldown + bounty bypass, legal pool inject in Chaos Trials).
---@param currentRun table
---@param room table
---@param encounterData table
---@param args table|nil
---@return boolean
function guarantee.IsEncounterEligibleForForce(currentRun, room, encounterData, args)
	local base = guarantee._baseIsEncounterEligible
	if base == nil then
		return game.IsEncounterEligible(currentRun, room, encounterData, args)
	end

	local function checkWithBypass()
		if guarantee.IsBypassingCooldown(currentRun, encounterData) then
			return guarantee.IsEligibleWithoutCooldown(base, currentRun, room, encounterData, args)
		end
		return base(currentRun, room, encounterData, args)
	end

	if run_modes.ShouldBypassChaosTrialRequirements(currentRun)
		and not room.LegalEncountersDictionary[encounterData.Name] then
		return guarantee.WithTemporaryLegalEncounter(room, encounterData.Name, checkWithBypass)
	end

	return checkWithBypass()
end

---@param base function
---@param currentRun table
---@param room table
---@param nextEncounterData table
---@param args table|nil
---@return boolean
function guarantee.IsEligibleWithoutCooldown(base, currentRun, room, nextEncounterData, args)
	local copy = game.DeepCopyTable(nextEncounterData)
	guarantee.StripForceBypassRequirements(copy, currentRun)
	return base(currentRun, room, copy, args)
end

--- Swap to intro encounter when vanilla would force a first-meeting variant.
---@param encounterData table
---@return table
function guarantee.ApplyIntroEncounterSwap(encounterData)
	if encounterData.EnemySet == nil then
		return encounterData
	end
	for _, enemyName in pairs(encounterData.EnemySet) do
		local enemyData = game.EnemyData[enemyName]
		if enemyData ~= nil and enemyData.ForceIntroduction
			and not game.HasEncounterBeenCompleted(enemyData.IntroEncounterName) then
			local introEncounter = game.EncounterData[enemyData.IntroEncounterName]
			if introEncounter ~= nil then
				return introEncounter
			end
		end
	end
	return encounterData
end

---@param currentRun table
---@param room table
---@param encounterName string
---@param args table|nil
---@return table|nil
function guarantee.TryEncounterForForce(currentRun, room, encounterName, args)
	-- Chaos Trials drop allies from the room pool; eligibility bypass handles the rest.
	if not room.LegalEncountersDictionary[encounterName]
		and not run_modes.ShouldBypassChaosTrialRequirements(currentRun) then
		return nil
	end
	local encounterData = game.EncounterData[encounterName]
	if encounterData == nil then
		return nil
	end
	if currentRun.IsDreamRun and encounters.IsDreamBlockedEncounter(encounterName) then
		return nil
	end
	-- Chaos Trials: curated ally pool is authoritative; vanilla IsEncounterEligible stays too strict.
	if run_modes.ShouldBypassChaosTrialRequirements(currentRun)
		and guarantee.IsBypassingCooldown(currentRun, encounterData) then
		return guarantee.ApplyIntroEncounterSwap(encounterData)
	end
	if not guarantee.IsEncounterEligibleForForce(currentRun, room, encounterData, args) then
		if config.debugLog then
			guarantee.DebugLog("  " .. encounterName .. " not eligible for force in this room")
		end
		return nil
	end
	return guarantee.ApplyIntroEncounterSwap(encounterData)
end

---@param currentRun table
---@param room table
---@param args table|nil
---@return table|nil
function guarantee.TryPickForcedEncounter(currentRun, room, args)
	if not guarantee.ShouldProcessRoom(room, currentRun) then
		return nil
	end

	local biome = encounters.RoomSetToBiome(room.RoomSetName)
	if biome == nil then
		return nil
	end

	tracker.EnsureInitialized(currentRun)
	tracker.EnsureChaosTrialSetup(currentRun, biome)
	tracker.MarkBiomeEntered(currentRun, biome)

	local state = tracker.GetState(currentRun)
	if state == nil then
		return nil
	end

	for _, npc in ipairs(encounters.NPCPriority) do
		if tracker.IsNPCEligibleForBiomeThisRun(currentRun, npc, biome) then
			local biomeEncounters = encounters.ByNPCAndBiome[npc][biome]
			if biomeEncounters ~= nil then
				state.ActiveForceNPC = npc
				local picked = nil
				for _, encounterName in ipairs(biomeEncounters) do
					picked = guarantee.TryEncounterForForce(currentRun, room, encounterName, args)
					if picked ~= nil then
						break
					end
				end
				state.ActiveForceNPC = nil

				if picked ~= nil then
					guarantee.DebugLog("Forcing " .. picked.Name .. " for pending " .. npc .. " in biome " .. biome)
					return picked
				end
				guarantee.DebugLog(
					"Pending " .. npc .. " in biome " .. biome .. ": no eligible encounter could be forced"
				)
			else
				guarantee.DebugLog("Pending " .. npc .. " in biome " .. biome .. ": no encounter pool for this ally")
			end
		end
	end

	return nil
end

---@param base function
---@param currentRun table
---@param room table
---@param nextEncounterData table
---@param args table|nil
---@return boolean
function guarantee.WrapIsEncounterEligible(base, currentRun, room, nextEncounterData, args)
	guarantee._baseIsEncounterEligible = base
	if base(currentRun, room, nextEncounterData, args) then
		return true
	end
	if not guarantee.IsBypassingCooldown(currentRun, nextEncounterData) then
		return false
	end
	return guarantee.IsEligibleWithoutCooldown(base, currentRun, room, nextEncounterData, args)
end

---@param base function
---@param currentRun table
---@param room table
---@param args table|nil
---@return table|nil
function guarantee.WrapChooseEncounter(base, currentRun, room, args)
	args = args or {}

	if game.ForceNextEncounter ~= nil or currentRun.ForceNextEncounterData ~= nil then
		return base(currentRun, room, args)
	end

	local forcedData = guarantee.TryPickForcedEncounter(currentRun, room, args)
	if forcedData ~= nil then
		return game.SetupEncounter(forcedData, room)
	end

	return base(currentRun, room, args)
end

--- Register all guarantee Path.Wrap hooks (idempotent via ready.lua guard).
function guarantee.RegisterHooks()
	modutil.mod.Path.Wrap("StartNewRun", tracker.WrapStartNewRun, mod)
	modutil.mod.Path.Wrap("StartRoom", tracker.WrapStartRoom, mod)
	modutil.mod.Path.Wrap("RecordEncounter", tracker.WrapRecordEncounter, mod)
	modutil.mod.Path.Wrap("IsEncounterEligible", guarantee.WrapIsEncounterEligible, mod)
	modutil.mod.Path.Wrap("ChooseEncounter", guarantee.WrapChooseEncounter, mod)
	zagreus.RegisterHooks()
	chronos.RegisterHooks()
end

mod.Guarantee = guarantee
