---@meta _
-- Force pending field NPC encounters via ChooseEncounter / IsEncounterEligible hooks.

guarantee = {}

function guarantee.DebugLog(message)
	if config.debugLog then
		print("[FatedEncounters] " .. tostring(message))
	end
end

---@param room table
---@return boolean
function guarantee.ShouldProcessRoom(room)
	if not config.guaranteeFieldNPCs then
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

---@param base function
---@param currentRun table
---@param room table
---@param nextEncounterData table
---@param args table|nil
---@return boolean
function guarantee.IsEligibleWithoutCooldown(base, currentRun, room, nextEncounterData, args)
	local copy = game.DeepCopyTable(nextEncounterData)
	guarantee.StripCooldownNamedRequirements(copy)
	return base(currentRun, room, copy, args)
end

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
	if not room.LegalEncountersDictionary[encounterName] then
		return nil
	end
	local encounterData = game.EncounterData[encounterName]
	if encounterData == nil then
		return nil
	end
	if currentRun.IsDreamRun and encounters.IsDreamBlockedEncounter(encounterName) then
		return nil
	end
	if not game.IsEncounterEligible(currentRun, room, encounterData, args) then
		return nil
	end
	return guarantee.ApplyIntroEncounterSwap(encounterData)
end

---@param currentRun table
---@param room table
---@param args table|nil
---@return table|nil
function guarantee.TryPickForcedEncounter(currentRun, room, args)
	if not guarantee.ShouldProcessRoom(room) then
		return nil
	end

	local biome = encounters.RoomSetToBiome(room.RoomSetName)
	if biome == nil then
		return nil
	end

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
			end
		end
	end

	return nil
end

function guarantee.WrapIsEncounterEligible(base, currentRun, room, nextEncounterData, args)
	if base(currentRun, room, nextEncounterData, args) then
		return true
	end
	if not guarantee.IsBypassingCooldown(currentRun, nextEncounterData) then
		return false
	end
	return guarantee.IsEligibleWithoutCooldown(base, currentRun, room, nextEncounterData, args)
end

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
