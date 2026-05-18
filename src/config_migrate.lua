---@meta _
-- One-time config migrations when Chalk bumps `version` in config.lua.

config_migrate = {}

local FIELD_NPCS = { "Nemesis", "Artemis", "Heracles", "Icarus", "Athena" }

---@param cfg table Chalk config wrapper
function config_migrate.Apply(cfg)
	local version = cfg.version or 1
	if version >= 4 then
		return
	end
	-- Removed guaranteeFieldNPCs: preserve Chronos-only / all-field-off saves.
	if cfg.guaranteeFieldNPCs == false and cfg.fieldNPCs ~= nil then
		for _, npc in ipairs(FIELD_NPCS) do
			cfg.fieldNPCs[npc] = false
		end
	end
	cfg.version = 4
end

return config_migrate
