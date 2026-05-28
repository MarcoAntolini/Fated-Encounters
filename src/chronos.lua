---@meta _
-- Post–True Ending reformed Chronos in the Erebus–Oceanus hub (Story_Chronos_01 / NPC_Chronos_02).

chronos = {}

function chronos.DebugLog(message)
	if config.debugLog then
		print("[FatedEncounters] " .. tostring(message))
	end
end

--- Patch vanilla Story_Chronos_01 so SpawnChronosForTaunt always rolls when eligible.
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

--- Mark guarantee fulfilled when reformed Chronos spawns (NPC_Chronos_02).
---@param base function
---@param source table
---@param args table|nil
function chronos.WrapSpawnChronosForTaunt(base, source, args)
	base(source, args)
	local postTE = config.postTrueEnding
	if postTE == nil or not postTE.guaranteeChronosClearing then
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

--- Patch encounter data and wrap SpawnChronosForTaunt.
function chronos.RegisterHooks()
	chronos.PatchNeoChronosSpawnChance()
	modutil.mod.Path.Wrap("SpawnChronosForTaunt", chronos.WrapSpawnChronosForTaunt, mod)
end

mod.Chronos = chronos
