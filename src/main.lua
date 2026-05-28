---@meta _
-- Mod entry: Chalk config, ReLoad early/late lifecycle, ImGui on every reload.

---@diagnostic disable-next-line: undefined-global
local mods = rom.mods

---@module 'LuaENVY-ENVY-auto'
mods['LuaENVY-ENVY'].auto()
---@diagnostic disable: lowercase-global

---@diagnostic disable-next-line: undefined-global
rom = rom
---@diagnostic disable-next-line: undefined-global
_PLUGIN = _PLUGIN

---@module 'game'
game = rom.game
---@module 'game-import'
import_as_fallback(game)

---@module 'SGG_Modding-SJSON'
sjson = mods['SGG_Modding-SJSON']
---@module 'SGG_Modding-ModUtil'
modutil = mods['SGG_Modding-ModUtil']

---@module 'SGG_Modding-Chalk'
chalk = mods["SGG_Modding-Chalk"]
---@module 'SGG_Modding-ReLoad'
reload = mods['SGG_Modding-ReLoad']

---@module 'config'
config = chalk.auto 'config.lua'
---@module 'config_migrate'
config_migrate = import 'config_migrate.lua'
config_migrate.Apply(config)
if config_migrate.HasLegacyFlatKeys(config) then
	config = config_migrate.Persist(config)
end
public.config = config

local function on_ready()
	mod = modutil.mod.Mod.Register(_PLUGIN.guid)
	if config.enabled == false then
		return
	end

	import 'ready.lua'
end

local function on_reload()
	-- Settings UI stays available when the mod is disabled.
	import 'imgui.lua'

	if config.enabled == false then
		return
	end

	import 'reload.lua'
end

local function on_ready_late()
	if config.enabled == false then return end

	import 'ready_late.lua'
end

local function on_reload_late()
	if config.enabled == false then return end

	import 'reload_late.lua'
end

local loader = reload.auto_multiple()

modutil.once_loaded.game(function()
	loader.load("early", on_ready, on_reload)
end)

mods.on_all_mods_loaded(function()
	modutil.once_loaded.game(function()
		loader.load("late", on_ready_late, on_reload_late)
	end)
end)
