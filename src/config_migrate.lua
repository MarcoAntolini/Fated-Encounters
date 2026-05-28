---@meta _
-- One-time config migrations when Chalk bumps `version` in config.lua. Add a block per bump.

config_migrate = {}

local FIELD_NPCS = { "Nemesis", "Artemis", "Heracles", "Icarus", "Athena" }

---@param nested boolean|nil
---@param legacy boolean|nil
---@param default boolean
---@return boolean
local function nestedOrLegacy(nested, legacy, default)
	if nested ~= nil then
		return nested == true
	end
	if legacy ~= nil then
		return legacy == true
	end
	return default
end

---@param cfg table Chalk config wrapper
---@return boolean
function config_migrate.HasLegacyFlatKeys(cfg)
	return cfg.fieldNPCs ~= nil
		or cfg.randomizeFieldNPCBiome ~= nil
		or cfg.guaranteeZagContract ~= nil
		or cfg.guaranteeChronosClearing ~= nil
end

---@param cfg table Chalk config wrapper
---@return table Plain nested config table for chalk.replace (drops legacy flat keys).
function config_migrate.BuildCleanV6Config(cfg)
	local allies = cfg.allies or {}
	local fieldNPCs = allies.fieldNPCs or cfg.fieldNPCs or {}
	local postTE = cfg.postTrueEnding or {}
	local runModes = cfg.runModes or {}

	local clean = {
		version = 6;
		enabled = cfg.enabled ~= false;
		debugLog = cfg.debugLog == true;
		allies = {
			randomizeFieldNPCBiome = nestedOrLegacy(
				allies.randomizeFieldNPCBiome,
				cfg.randomizeFieldNPCBiome,
				false
			);
			fieldNPCs = {};
		};
		postTrueEnding = {
			guaranteeZagContract = nestedOrLegacy(
				postTE.guaranteeZagContract,
				cfg.guaranteeZagContract,
				true
			);
			guaranteeChronosClearing = nestedOrLegacy(
				postTE.guaranteeChronosClearing,
				cfg.guaranteeChronosClearing,
				true
			);
		};
		runModes = {
			chaosTrials = runModes.chaosTrials == true;
			dreamDives = runModes.dreamDives == true;
			dreamDivesZagContract = runModes.dreamDivesZagContract == true;
		};
	}

	for _, npc in ipairs(FIELD_NPCS) do
		clean.allies.fieldNPCs[npc] = nestedOrLegacy(fieldNPCs[npc], cfg.fieldNPCs and cfg.fieldNPCs[npc], true)
	end

	return clean
end

---@param cfg table Chalk config wrapper
---@param clean table Plain nested config from BuildCleanV6Config
function config_migrate.ApplyCleanToWrapper(cfg, clean)
	cfg.version = clean.version
	cfg.enabled = clean.enabled
	cfg.debugLog = clean.debugLog
	cfg.allies.randomizeFieldNPCBiome = clean.allies.randomizeFieldNPCBiome
	for _, npc in ipairs(FIELD_NPCS) do
		cfg.allies.fieldNPCs[npc] = clean.allies.fieldNPCs[npc]
	end
	cfg.postTrueEnding.guaranteeZagContract = clean.postTrueEnding.guaranteeZagContract
	cfg.postTrueEnding.guaranteeChronosClearing = clean.postTrueEnding.guaranteeChronosClearing
	cfg.runModes.chaosTrials = clean.runModes.chaosTrials
	cfg.runModes.dreamDives = clean.runModes.dreamDives
	cfg.runModes.dreamDivesZagContract = clean.runModes.dreamDivesZagContract
end

---@param cfg table Chalk config wrapper
---@return table cfg Possibly replaced Chalk wrapper after persisting.
function config_migrate.Persist(cfg)
	config_migrate.Apply(cfg)
	local clean = config_migrate.BuildCleanV6Config(cfg)
	if config_migrate.HasLegacyFlatKeys(cfg) then
		local _, descript = import 'config.lua'
		return select(1, chalk.replace(chalk.original(cfg), clean, descript))
	end
	config_migrate.ApplyCleanToWrapper(cfg, clean)
	chalk.original(cfg):save()
	return cfg
end

---@param cfg table Chalk config wrapper
---@param loaded table Decoded [config] table from disk
function config_migrate.ApplyLoaded(cfg, loaded)
	if loaded.enabled ~= nil then
		cfg.enabled = loaded.enabled
	end
	if loaded.debugLog ~= nil then
		cfg.debugLog = loaded.debugLog
	end

	local allies = loaded.allies
	if allies ~= nil then
		if allies.randomizeFieldNPCBiome ~= nil then
			cfg.allies.randomizeFieldNPCBiome = allies.randomizeFieldNPCBiome
		elseif loaded.randomizeFieldNPCBiome ~= nil then
			cfg.allies.randomizeFieldNPCBiome = loaded.randomizeFieldNPCBiome
		end
		local fieldNPCs = allies.fieldNPCs
		if fieldNPCs ~= nil then
			for _, npc in ipairs(FIELD_NPCS) do
				if fieldNPCs[npc] ~= nil then
					cfg.allies.fieldNPCs[npc] = fieldNPCs[npc]
				end
			end
		elseif loaded.fieldNPCs ~= nil then
			for _, npc in ipairs(FIELD_NPCS) do
				if loaded.fieldNPCs[npc] ~= nil then
					cfg.allies.fieldNPCs[npc] = loaded.fieldNPCs[npc]
				end
			end
		end
	elseif loaded.randomizeFieldNPCBiome ~= nil then
		cfg.allies.randomizeFieldNPCBiome = loaded.randomizeFieldNPCBiome
	elseif loaded.fieldNPCs ~= nil then
		for _, npc in ipairs(FIELD_NPCS) do
			if loaded.fieldNPCs[npc] ~= nil then
				cfg.allies.fieldNPCs[npc] = loaded.fieldNPCs[npc]
			end
		end
	end

	local postTE = loaded.postTrueEnding
	if postTE ~= nil then
		if postTE.guaranteeZagContract ~= nil then
			cfg.postTrueEnding.guaranteeZagContract = postTE.guaranteeZagContract
		elseif loaded.guaranteeZagContract ~= nil then
			cfg.postTrueEnding.guaranteeZagContract = loaded.guaranteeZagContract
		end
		if postTE.guaranteeChronosClearing ~= nil then
			cfg.postTrueEnding.guaranteeChronosClearing = postTE.guaranteeChronosClearing
		elseif loaded.guaranteeChronosClearing ~= nil then
			cfg.postTrueEnding.guaranteeChronosClearing = loaded.guaranteeChronosClearing
		end
	else
		if loaded.guaranteeZagContract ~= nil then
			cfg.postTrueEnding.guaranteeZagContract = loaded.guaranteeZagContract
		end
		if loaded.guaranteeChronosClearing ~= nil then
			cfg.postTrueEnding.guaranteeChronosClearing = loaded.guaranteeChronosClearing
		end
	end

	local runModes = loaded.runModes
	if runModes ~= nil then
		if runModes.chaosTrials ~= nil then
			cfg.runModes.chaosTrials = runModes.chaosTrials
		end
		if runModes.dreamDives ~= nil then
			cfg.runModes.dreamDives = runModes.dreamDives
		end
		if runModes.dreamDivesZagContract ~= nil then
			cfg.runModes.dreamDivesZagContract = runModes.dreamDivesZagContract
		end
	end
end

---@param cfg table Chalk config wrapper
function config_migrate.Apply(cfg)
	local version = cfg.version or 1

	if version < 4 then
		-- v4: removed top-level guaranteeFieldNPCs; preserve Chronos-only / all-allies-off saves.
		if cfg.guaranteeFieldNPCs == false and cfg.fieldNPCs ~= nil then
			for _, npc in ipairs(FIELD_NPCS) do
				cfg.fieldNPCs[npc] = false
			end
		end
		cfg.version = 4
		version = 4
	end

	if version < 5 then
		-- v5: Chaos Trials / Dream Dives run-mode toggles (default off).
		cfg.runModes = cfg.runModes or {}
		if cfg.runModes.chaosTrials == nil then
			cfg.runModes.chaosTrials = false
		end
		if cfg.runModes.dreamDives == nil then
			cfg.runModes.dreamDives = false
		end
		if cfg.runModes.dreamDivesZagContract == nil then
			cfg.runModes.dreamDivesZagContract = false
		end
		cfg.version = 5
		version = 5
	end

	if version < 6 then
		-- v6: nest allies.* and postTrueEnding.* config keys.
		cfg.allies = cfg.allies or {}
		if cfg.fieldNPCs ~= nil and cfg.allies.fieldNPCs == nil then
			cfg.allies.fieldNPCs = cfg.fieldNPCs
		end
		if cfg.randomizeFieldNPCBiome ~= nil and cfg.allies.randomizeFieldNPCBiome == nil then
			cfg.allies.randomizeFieldNPCBiome = cfg.randomizeFieldNPCBiome
		end
		cfg.postTrueEnding = cfg.postTrueEnding or {}
		if cfg.guaranteeZagContract ~= nil and cfg.postTrueEnding.guaranteeZagContract == nil then
			cfg.postTrueEnding.guaranteeZagContract = cfg.guaranteeZagContract
		end
		if cfg.guaranteeChronosClearing ~= nil and cfg.postTrueEnding.guaranteeChronosClearing == nil then
			cfg.postTrueEnding.guaranteeChronosClearing = cfg.guaranteeChronosClearing
		end
		cfg.version = 6
	end
end

return config_migrate
