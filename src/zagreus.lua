---@meta _
-- Post-True Ending Infernal Contract: always offer until the player accepts it.

zagreus = {}

-- Vanilla ZagreusContractRequirement without ChanceToPlay.
zagreus.ContractRequirementNoChance = {
	NamedRequirements = { "InfernalContractUnlocked" },
	NamedRequirementsFalse = { "StandardPackageBountyActive" },
	{
		PathFalse = { "CurrentRun", "RoomCountCache", "C_Boss01" },
	},
}

function zagreus.DebugLog(message)
	if config.debugLog then
		print("[FatedEncounters] " .. tostring(message))
	end
end

---@param run table|nil
---@return boolean
function zagreus.IsInfernalContractUnlockedForRun(run)
	run = run or game.CurrentRun
	if run == nil or game.GameState == nil or not game.GameState.ReachedTrueEnding then
		return false
	end
	return game.IsGameStateEligible(run, zagreus.ContractRequirementNoChance)
end

---@param room table
---@return boolean
function zagreus.ShouldForceContractOnRoom(room)
	if not config.guaranteeZagContract then
		return false
	end
	local state = tracker.GetState()
	if state == nil or not state.PendingZagContract then
		return false
	end
	if room == nil or room.ZagContractDestinationId == nil then
		return false
	end
	return game.IsGameStateEligible(room, zagreus.ContractRequirementNoChance)
end

function zagreus.WrapCreateRoom(base, roomData, args)
	local room = base(roomData, args)
	if zagreus.ShouldForceContractOnRoom(room) then
		room.ZagreusContractSuccess = true
		zagreus.DebugLog("Forced Infernal Contract on room " .. tostring(room.Name))
	end
	return room
end

function zagreus.WrapContractExitPresentation(base, currentRun, exitDoor, args)
	base(currentRun, exitDoor, args)
	local state = tracker.GetState(currentRun)
	if state ~= nil and state.PendingZagContract then
		state.PendingZagContract = false
		zagreus.DebugLog("Infernal Contract accepted; guarantee fulfilled for this run")
	end
end

function zagreus.RegisterHooks()
	modutil.mod.Path.Wrap("CreateRoom", zagreus.WrapCreateRoom, mod)
	modutil.mod.Path.Wrap("ContractExitPresentation", zagreus.WrapContractExitPresentation, mod)
end

mod.Zagreus = zagreus
