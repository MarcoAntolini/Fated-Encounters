---@meta _
-- Ally encounter names, eligible regions, and eligibility helpers (vanilla EncounterData names).

---@alias FatedNPC "Nemesis" | "Artemis" | "Heracles" | "Icarus" | "Athena"
---@alias FatedBiome "F" | "G" | "H" | "I" | "N" | "O" | "P"

encounters = {}

-- Order used when multiple NPCs are pending in the same biome.
encounters.NPCPriority = { "Nemesis", "Artemis", "Heracles", "Icarus", "Athena" }

-- Biomes where each NPC can appear in vanilla pools (player must visit one to trigger guarantee).
encounters.BiomesByNPC = {
	Nemesis = { "F", "G", "H", "I" },
	Artemis = { "F", "G", "N" },
	Heracles = { "N", "O", "P" },
	Icarus = { "O", "P" },
	Athena = { "P" },
}

-- Intro encounters: vanilla may force these first; do not count as run guarantee fulfilled.
encounters.IntroEncounters = {
	ArtemisCombatIntro = "Artemis",
	NemesisCombatIntro = "Nemesis",
	HeraclesCombatIntro = "Heracles",
	IcarusCombatIntro = "Icarus",
	AthenaCombatIntro = "Athena",
}

-- Encounters blocked on dream runs (PathFalse IsDreamRun in vanilla).
encounters.DreamBlockedEncounters = {
	NemesisRandomEvent = true,
	BridgeNemesisRandomEvent = true,
}

-- NamedRequirements stripped only when forcing a pending guarantee (phase 2+).
encounters.CooldownNamedRequirements = {
	NoRecentFieldNPCEncounter = true,
	NoRecentNemesisEncounter = true,
	NoRecentHeraclesEncounter = true,
}

-- NamedRequirementsFalse stripped when forcing during Chaos Trials.
encounters.ModeBypassNamedRequirementsFalse = {
	StandardPackageBountyActive = true,
}

-- Unique encounter names per NPC per biome (combat + nemesis random events).
encounters.ByNPCAndBiome = {
	Nemesis = {
		F = { "NemesisCombatF", "NemesisRandomEvent" },
		G = { "NemesisCombatG", "NemesisRandomEvent" },
		H = { "NemesisCombatH", "NemesisRandomEvent" },
		I = { "NemesisCombatI" },
	},
	Artemis = {
		F = { "ArtemisCombatF", "ArtemisCombatF2" },
		G = { "ArtemisCombatG", "ArtemisCombatG2" },
		N = { "ArtemisCombatN", "ArtemisCombatN2" },
	},
	Heracles = {
		N = { "HeraclesCombatN", "HeraclesCombatN2" },
		O = { "HeraclesCombatO", "HeraclesCombatO2" },
		P = { "HeraclesCombatP", "HeraclesCombatP2" },
	},
	Icarus = {
		O = { "IcarusCombatO", "IcarusCombatO2" },
		P = { "IcarusCombatP" },
	},
	Athena = {
		P = { "AthenaCombatP", "AthenaCombatP02" },
	},
}

-- encounterName -> NPC (built once).
encounters._encounterToNPC = nil

local function buildEncounterToNPC()
	if encounters._encounterToNPC then
		return encounters._encounterToNPC
	end
	local map = {}
	for npc, biomes in pairs(encounters.ByNPCAndBiome) do
		for _, names in pairs(biomes) do
			for _, encounterName in ipairs(names) do
				map[encounterName] = npc
			end
		end
	end
	for introName, npc in pairs(encounters.IntroEncounters) do
		map[introName] = npc
	end
	encounters._encounterToNPC = map
	return map
end

---@param encounterName string
---@return FatedNPC|nil
function encounters.GetNPCForEncounter(encounterName)
	return buildEncounterToNPC()[encounterName]
end

---@param encounterName string
---@param npc FatedNPC
---@return boolean
function encounters.EncounterBelongsToNPC(encounterName, npc)
	return encounters.GetNPCForEncounter(encounterName) == npc
end

---@param encounterName string
---@return boolean
function encounters.IsIntroEncounter(encounterName)
	return encounters.IntroEncounters[encounterName] ~= nil
end

---@param encounterName string
---@return boolean
function encounters.IsDreamBlockedEncounter(encounterName)
	if encounters.DreamBlockedEncounters[encounterName] then
		return true
	end
	local data = game.EncounterData[encounterName]
	if data == nil or data.GameStateRequirements == nil then
		return false
	end
	return encounters._requirementsBlockDreamRun(data.GameStateRequirements)
end

---@param requirements table
---@return boolean
function encounters._requirementsBlockDreamRun(requirements)
	for _, req in ipairs(requirements) do
		if req.PathFalse then
			local path = req.PathFalse
			if path[1] == "CurrentRun" and path[2] == "IsDreamRun" then
				return true
			end
		end
		if req.OrRequirements then
			for _, orGroup in ipairs(req.OrRequirements) do
				if encounters._requirementsBlockDreamRun(orGroup) then
					return true
				end
			end
		end
	end
	return false
end

-- Depth-comparison fields used by ally encounters (BiomeDepthCache >= 3/4 etc.).
-- Random Chaos Trial paths are too short to satisfy these naturally, so we strip them
-- only when we've already committed to forcing a specific pending ally.
encounters._depthRequirementFields = {
	BiomeDepthCache = true,
	BiomeEncounterDepth = true,
	RunDepthCache = true,
	BiomeDepth = true,
	EncounterDepth = true,
}

---@param requirements table
function encounters._stripChaosTrialBlockedRequirements(requirements)
	local i = 1
	while i <= #requirements do
		local req = requirements[i]
		if req.OrRequirements then
			for _, orGroup in ipairs(req.OrRequirements) do
				encounters._stripChaosTrialBlockedRequirements(orGroup)
			end
			i = i + 1
		elseif req.PathFalse
			and req.PathFalse[1] == "CurrentRun"
			and type(req.PathFalse[2]) == "string"
			and (req.PathFalse[2] == "ActiveBounty" or req.PathFalse[2]:find("Bounty") ~= nil) then
			table.remove(requirements, i)
		else
			i = i + 1
		end
	end
end

---@param requirements table
function encounters._stripChaosTrialDepthRequirements(requirements)
	local i = 1
	while i <= #requirements do
		local req = requirements[i]
		if req.OrRequirements then
			for _, orGroup in ipairs(req.OrRequirements) do
				encounters._stripChaosTrialDepthRequirements(orGroup)
			end
			i = i + 1
		elseif req.Path
			and req.Path[1] == "CurrentRun"
			and type(req.Path[2]) == "string"
			and encounters._depthRequirementFields[req.Path[2]]
			and req.Comparison ~= nil then
			table.remove(requirements, i)
		else
			i = i + 1
		end
	end
end

---@param encounterData table
function encounters.ClearChaosTrialForceDepthGates(encounterData)
	encounterData.MinDepth = nil
	encounterData.MaxDepth = nil
	encounterData.RequiredMinDepth = nil
	encounterData.RequiredMaxDepth = nil
	encounterData.MinimumDepth = nil
	encounterData.MaximumDepth = nil
	encounterData.RequiredMinBiomeDepth = nil
	encounterData.RequiredMaxBiomeDepth = nil
end

---@param name string
---@return boolean
local function shouldStripChaosTrialNamedRequirementFalse(name)
	if encounters.ModeBypassNamedRequirementsFalse[name] then
		return true
	end
	return type(name) == "string" and (name:find("Bounty") ~= nil or name:find("Package") ~= nil)
end

---@param encounterData table
function encounters.StripChaosTrialBlockedRequirements(encounterData)
	if encounterData.GameStateRequirements == nil then
		return
	end
	encounters._stripChaosTrialBlockedRequirements(encounterData.GameStateRequirements)
	encounters._stripChaosTrialDepthRequirements(encounterData.GameStateRequirements)
	for _, req in ipairs(encounterData.GameStateRequirements) do
		if req.NamedRequirementsFalse ~= nil then
			local filtered = {}
			for _, name in ipairs(req.NamedRequirementsFalse) do
				if not shouldStripChaosTrialNamedRequirementFalse(name) then
					table.insert(filtered, name)
				end
			end
			req.NamedRequirementsFalse = filtered
		end
	end
end

---@param biome string
---@return string[]
function encounters.GetEncounterNamesForBiome(biome)
	local names = {}
	local seen = {}
	for _, biomes in pairs(encounters.ByNPCAndBiome) do
		local biomeEncounters = biomes[biome]
		if biomeEncounters then
			for _, encounterName in ipairs(biomeEncounters) do
				if not seen[encounterName] then
					seen[encounterName] = true
					table.insert(names, encounterName)
				end
			end
		end
	end
	return names
end

---@param biome string
---@param pendingNPCs FatedNPC[]
---@return string[]
function encounters.GetEncounterNamesForPendingInBiome(biome, pendingNPCs)
	local names = {}
	local seen = {}
	local pendingSet = {}
	for _, npc in ipairs(pendingNPCs) do
		pendingSet[npc] = true
	end
	for npc, biomes in pairs(encounters.ByNPCAndBiome) do
		if pendingSet[npc] then
			local biomeEncounters = biomes[biome]
			if biomeEncounters then
				for _, encounterName in ipairs(biomeEncounters) do
					if not seen[encounterName] then
						seen[encounterName] = true
						table.insert(names, encounterName)
					end
				end
			end
		end
	end
	return names
end

---@param roomSetName string|nil
---@return FatedBiome|nil
function encounters.RoomSetToBiome(roomSetName)
	if roomSetName == nil or roomSetName == "" then
		return nil
	end
	local biome = roomSetName:sub(1, 1)
	for _, biomes in pairs(encounters.ByNPCAndBiome) do
		if biomes[biome] then
			return biome
		end
	end
	return nil
end

---@param npc FatedNPC
---@return FatedBiome|nil
function encounters.PickRandomBiomeForNPC(npc)
	local biomes = encounters.BiomesByNPC[npc]
	if biomes == nil or #biomes == 0 then
		return nil
	end
	if #biomes == 1 then
		return biomes[1]
	end
	return biomes[RandomInt(#biomes)]
end

---@param npc FatedNPC
---@param biome FatedBiome
---@return boolean
function encounters.NPCCanAppearInBiome(npc, biome)
	local biomes = encounters.BiomesByNPC[npc]
	if biomes == nil then
		return false
	end
	for _, b in ipairs(biomes) do
		if b == biome then
			return true
		end
	end
	return false
end

---@param biome string
---@return FatedNPC[]
function encounters.GetNPCsForBiome(biome)
	local npcs = {}
	for _, npc in ipairs(encounters.NPCPriority) do
		local biomes = encounters.BiomesByNPC[npc]
		if biomes then
			for _, b in ipairs(biomes) do
				if b == biome then
					table.insert(npcs, npc)
					break
				end
			end
		end
	end
	return npcs
end

mod.Encounters = encounters
