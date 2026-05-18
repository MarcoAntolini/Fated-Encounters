---@meta _
-- Post-True Ending Neo-Chronos at the Erebus clearing (F_PostBoss01).

chronos = {}

function chronos.DebugLog(message)
	if config.debugLog then
		print("[FatedEncounters] " .. tostring(message))
	end
end

function chronos.PatchNeoChronosSpawnChance()
	local encounter = game.EncounterData.Story_Chronos_01
	if encounter == nil or encounter.StartRoomUnthreadedEvents == nil then
		chronos.DebugLog("Story_Chronos_01 not found; skipping Neo-Chronos patch")
		return
	end

	for _, event in ipairs(encounter.StartRoomUnthreadedEvents) do
		if event.FunctionName == "SpawnChronosForTaunt"
			and event.Args ~= nil
			and event.Args.UnitName == "NPC_Chronos_02" then
			event.ChanceToPlay = 1
			chronos.DebugLog("Set Neo-Chronos SpawnChronosForTaunt ChanceToPlay to 1")
			return
		end
	end

	chronos.DebugLog("Neo-Chronos SpawnChronosForTaunt event not found")
end

function chronos.WrapSpawnChronosForTaunt(base, source, args)
	base(source, args)
	if not config.guaranteeChronosClearing then
		return
	end
	if args == nil or args.UnitName ~= "NPC_Chronos_02" then
		return
	end
	local state = tracker.GetState()
	if state ~= nil and state.PendingChronosClearing then
		state.PendingChronosClearing = false
		chronos.DebugLog("Neo-Chronos spawned at Erebus clearing; guarantee fulfilled for this run")
	end
end

function chronos.RegisterHooks()
	chronos.PatchNeoChronosSpawnChance()
	modutil.mod.Path.Wrap("SpawnChronosForTaunt", chronos.WrapSpawnChronosForTaunt, mod)
end

mod.Chronos = chronos
