---@meta _
-- Chaos Trials / Dream Dives detection; gates ally, Zagreus, and Chronos guarantees per mode.

run_modes = {}

---@param run table|nil
---@return boolean
function run_modes.IsDreamDive(run)
	run = run or game.CurrentRun
	return run ~= nil and run.IsDreamRun == true
end

--- True for both curated (`StandardPackageBountyActive`) and random Chaos Trials
--- (`PackageBountyRandom{Underworld,Surface}_Difficulty{1,2}`). Both kinds set
--- `run.ActiveBounty` and inherit `IsPackagedBounty = true` from
--- `DefaultPackagedBounty` / `BasePackageBountyRandom` in vanilla `BountyData`.
---@param run table|nil
---@return boolean
function run_modes.IsChaosTrial(run)
	run = run or game.CurrentRun
	if run == nil then
		return false
	end
	local bountyName = run.ActiveBounty
	if type(bountyName) ~= "string" or bountyName == "" then
		return false
	end
	local bountyData = game.BountyData and game.BountyData[bountyName]
	return bountyData ~= nil and bountyData.IsPackagedBounty == true
end

---@param run table|nil
---@return boolean
function run_modes.IsNormalRun(run)
	return not run_modes.IsDreamDive(run) and not run_modes.IsChaosTrial(run)
end

---@return table
local function runModesConfig()
	return config.runModes or {}
end

---@param run table|nil
---@return boolean
function run_modes.ShouldApplyFieldGuarantees(run)
	if config.enabled == false then
		return false
	end
	if not tracker.HasAnyFieldNPCEnabled() then
		return false
	end
	if run_modes.IsChaosTrial(run) then
		return runModesConfig().chaosTrials == true
	end
	if run_modes.IsDreamDive(run) then
		return runModesConfig().dreamDives == true
	end
	return true
end

---@param run table|nil
---@return boolean
function run_modes.ShouldApplyZagGuarantee(run)
	local postTE = config.postTrueEnding
	if postTE == nil or not postTE.guaranteeZagContract then
		return false
	end
	if run_modes.IsChaosTrial(run) then
		return false
	end
	if run_modes.IsDreamDive(run) then
		return runModesConfig().dreamDivesZagContract == true
	end
	return true
end

---@param run table|nil
---@return boolean
function run_modes.ShouldApplyChronosGuarantee(run)
	local postTE = config.postTrueEnding
	if postTE == nil or not postTE.guaranteeChronosClearing then
		return false
	end
	if run_modes.IsChaosTrial(run) or run_modes.IsDreamDive(run) then
		return false
	end
	return true
end

---@param run table|nil
---@return boolean
function run_modes.ShouldInitRunForRun(run)
	if config.enabled == false or run == nil then
		return false
	end
	return run_modes.ShouldApplyFieldGuarantees(run)
		or run_modes.ShouldApplyZagGuarantee(run)
		or run_modes.ShouldApplyChronosGuarantee(run)
end

---@param run table|nil
---@return boolean
function run_modes.ShouldBypassChaosTrialRequirements(run)
	return run_modes.IsChaosTrial(run) and runModesConfig().chaosTrials == true
end

--- Single-letter region for the active Chaos Trial, when known.
--- `currentRun.ActiveBounty` is the bounty name string; `BountyData[name].StartingBiome` is "F", "G", ...
---@param run table|nil
---@return FatedBiome|nil
function run_modes.GetChaosTrialBiome(run)
	run = run or game.CurrentRun
	if run == nil or not run_modes.IsChaosTrial(run) then
		return nil
	end

	local function normalizeBiomeChar(value)
		if type(value) ~= "string" or value == "" then
			return nil
		end
		local biome = encounters.RoomSetToBiome(value)
		if biome ~= nil then
			return biome
		end
		if #value == 1 and encounters.GetNPCsForBiome(value)[1] ~= nil then
			return value
		end
		return nil
	end

	local bountyName = run.ActiveBounty
	if type(bountyName) == "string" and game.BountyData ~= nil then
		local bountyData = game.BountyData[bountyName]
		if bountyData ~= nil then
			local biome = normalizeBiomeChar(bountyData.StartingBiome)
				or normalizeBiomeChar(bountyData.BiomeChar)
				or normalizeBiomeChar(bountyData.Biome)
			if biome ~= nil then
				return biome
			end
		end
	end

	if run.CurrentRoom ~= nil then
		return encounters.RoomSetToBiome(run.CurrentRoom.RoomSetName)
	end

	return nil
end

function run_modes.DebugLog(message)
	if config.debugLog then
		print("[FatedEncounters] " .. tostring(message))
	end
end

---@param run table|nil
---@return string
function run_modes.DescribeRun(run)
	if run_modes.IsDreamDive(run) then
		return "Dream Dive"
	end
	if run_modes.IsChaosTrial(run) then
		return "Chaos Trial"
	end
	return "normal run"
end

---@param run table|nil
---@return string
function run_modes.FieldGuaranteeSkipReason(run)
	if config.enabled == false then
		return "mod disabled"
	end
	if not tracker.HasAnyFieldNPCEnabled() then
		return "no allies enabled in settings"
	end
	if run_modes.IsChaosTrial(run) and runModesConfig().chaosTrials ~= true then
		return "Chaos Trial (ally guarantees off in settings)"
	end
	if run_modes.IsDreamDive(run) and runModesConfig().dreamDives ~= true then
		return "Dream Dive (ally guarantees off in settings)"
	end
	return "not active this run"
end

---@param run table|nil
---@return string
function run_modes.ZagGuaranteeSkipReason(run)
	if run_modes.IsChaosTrial(run) then
		return "not offered in Chaos Trials"
	end
	if run_modes.IsDreamDive(run) and runModesConfig().dreamDivesZagContract ~= true then
		return "Dream Dive (Infernal Contract toggle off in settings)"
	end
	return "not active this run"
end

---@param run table|nil
---@return string
function run_modes.ChronosGuaranteeSkipReason(run)
	if run_modes.IsChaosTrial(run) or run_modes.IsDreamDive(run) then
		return "only on normal runs after True Ending"
	end
	return "not active this run"
end

---@param run table
function run_modes.LogWhyNoRunInit(run)
	if not config.debugLog then
		return
	end

	run_modes.DebugLog("Run start (" .. run_modes.DescribeRun(run) .. "): no guarantees tracked")

	if config.enabled == false then
		run_modes.DebugLog("  Mod disabled in settings")
		return
	end

	local postTE = config.postTrueEnding
	local anySetting = tracker.HasAnyFieldNPCEnabled()
		or (postTE ~= nil and postTE.guaranteeZagContract)
		or (postTE ~= nil and postTE.guaranteeChronosClearing)

	if not anySetting then
		run_modes.DebugLog("  No guarantee options enabled in settings")
		return
	end

	if tracker.HasAnyFieldNPCEnabled() then
		run_modes.DebugLog("  Allies: " .. run_modes.FieldGuaranteeSkipReason(run))
	end
	if postTE ~= nil and postTE.guaranteeZagContract then
		run_modes.DebugLog("  Infernal Contract: " .. run_modes.ZagGuaranteeSkipReason(run))
	end
	if postTE ~= nil and postTE.guaranteeChronosClearing then
		run_modes.DebugLog("  Reformed Chronos: " .. run_modes.ChronosGuaranteeSkipReason(run))
	end
end

mod.RunModes = run_modes
