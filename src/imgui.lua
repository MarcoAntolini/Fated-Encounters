---@meta _
-- In-game settings UI. Saves to Chalk config after edits; polls disk for r2modman changes.

local ALLY_NPCS = { "Nemesis", "Artemis", "Heracles", "Icarus", "Athena" }

local SAVE_DEBOUNCE_SEC = 0.2
local RELOAD_POLL_SEC = 1.0
local SAVE_RELOAD_GRACE_SEC = 0.5
local LOCAL_EDIT_RELOAD_BLOCK_SEC = 3.0

local function syncStore()
	mod.Gui = mod.Gui or {}
	mod.Gui.sync = mod.Gui.sync or {}
	return mod.Gui.sync
end

local function nowSeconds()
	if rom.ImGui.GetTime then
		return rom.ImGui.GetTime()
	end
	return os.clock()
end

local function configFilePath()
	return chalk.original(config).config_file_path
end

local function readConfigFingerprint()
	local path = configFilePath()
	if path == nil then
		return nil
	end
	local file = io.open(path, "rb")
	if file == nil then
		return nil
	end
	local content = file:read("*a")
	file:close()
	return content
end

local function persistConfig()
	local ok = pcall(function()
		config = config_migrate.Persist(config)
		public.config = config
	end)
	return ok
end

local function noteConfigFileAsSeen()
	syncStore().lastKnownFingerprint = readConfigFingerprint()
end

local function commitConfigSave()
	if not persistConfig() then
		return false
	end

	local sync = syncStore()
	sync.saveDueAt = nil
	sync.lastSelfSaveAt = nowSeconds()
	sync.lastKnownFingerprint = readConfigFingerprint()
	return true
end

local function scheduleConfigSave()
	syncStore().saveDueAt = nowSeconds() + SAVE_DEBOUNCE_SEC
end

local function onConfigEdited()
	local sync = syncStore()
	sync.lastLocalEditAt = nowSeconds()
	sync.saveDueAt = nowSeconds()
	commitConfigSave()
end

local function flushConfigSaveIfDue()
	local sync = syncStore()
	if sync.saveDueAt == nil then
		return
	end
	if nowSeconds() < sync.saveDueAt then
		return
	end
	commitConfigSave()
end

local function reloadConfigFromDisk()
	local path = configFilePath()
	if path == nil then
		return false
	end

	local ok, data = pcall(rom.toml.decodeFromFile, path)
	if not ok or data == nil then
		return false
	end
	local loaded = select(2, next(data))
	if loaded == nil then
		return false
	end

	config_migrate.ApplyLoaded(config, loaded)
	config_migrate.Apply(config)
	if config_migrate.HasLegacyFlatKeys(config) then
		scheduleConfigSave()
	end
	syncStore().lastSelfSaveAt = nowSeconds()
	noteConfigFileAsSeen()
	return true
end

local function pollConfigFromDiskIfDue()
	local sync = syncStore()
	local now = nowSeconds()
	if now - (sync.lastPollAt or 0) < RELOAD_POLL_SEC then
		return
	end
	sync.lastPollAt = now

	if sync.saveDueAt ~= nil then
		return
	end
	if now - (sync.lastSelfSaveAt or 0) < SAVE_RELOAD_GRACE_SEC then
		return
	end
	if now - (sync.lastLocalEditAt or 0) < LOCAL_EDIT_RELOAD_BLOCK_SEC then
		return
	end

	local fingerprint = readConfigFingerprint()
	if fingerprint == nil or fingerprint == sync.lastKnownFingerprint then
		return
	end

	reloadConfigFromDisk()
end

local function tickConfigSync()
	flushConfigSaveIfDue()
	pollConfigFromDiskIfDue()
end

---@param label string
---@param get fun(): boolean
---@param set fun(value: boolean)
local function checkbox(label, get, set)
	local value, changed = rom.ImGui.Checkbox(label, get())
	if changed then
		set(value)
		onConfigEdited()
	end
end

local function drawGeneral()
	checkbox("Mod enabled", function()
		return config.enabled == true
	end, function(value)
		config.enabled = value
	end)

	if config.enabled == false then
		rom.ImGui.TextWrapped(
			"Guarantees are off. Reload your mod profile after turning this back on so hooks register."
		)
	end
end

local function drawAllies()
	if config.allies == nil or config.allies.fieldNPCs == nil then
		rom.ImGui.Text("Allies config missing.")
		return
	end

	rom.ImGui.TextWrapped(
		"Guarantee each ally once per run in an eligible region (first region you enter, "
			.. "or a random one if shuffle is on)."
	)
	rom.ImGui.Spacing()

	for _, npc in ipairs(ALLY_NPCS) do
		checkbox(npc, function()
			return config.allies.fieldNPCs[npc] == true
		end, function(value)
			config.allies.fieldNPCs[npc] = value
		end)
	end

	rom.ImGui.Spacing()
	checkbox("Random region per ally at run start", function()
		return config.allies.randomizeFieldNPCBiome == true
	end, function(value)
		config.allies.randomizeFieldNPCBiome = value
	end)
	rom.ImGui.TextWrapped(
		"Dream Dives ignore this: their regions are picked one at a time as you transition, "
			.. "so allies always appear in the first eligible region you visit."
	)
end

local function drawPostTrueEnding()
	if config.postTrueEnding == nil then
		rom.ImGui.Text("postTrueEnding config missing.")
		return
	end

	rom.ImGui.TextWrapped("Only applies on normal runs after True Ending. Not used in Chaos Trials or Dream Dives.")
	rom.ImGui.Spacing()

	checkbox("Guarantee Zagreus Infernal Contract", function()
		return config.postTrueEnding.guaranteeZagContract == true
	end, function(value)
		config.postTrueEnding.guaranteeZagContract = value
	end)

	checkbox("Guarantee reformed Chronos in the Erebus–Oceanus hub", function()
		return config.postTrueEnding.guaranteeChronosClearing == true
	end, function(value)
		config.postTrueEnding.guaranteeChronosClearing = value
	end)
end

local function drawRunModes()
	if config.runModes == nil then
		rom.ImGui.Text("runModes config missing.")
		return
	end

	checkbox("Apply ally guarantees in Chaos Trials", function()
		return config.runModes.chaosTrials == true
	end, function(value)
		config.runModes.chaosTrials = value
	end)

	checkbox("Apply ally guarantees in Dream Dives", function()
		return config.runModes.dreamDives == true
	end, function(value)
		config.runModes.dreamDives = value
	end)

	checkbox("Guarantee Infernal Contract in Dream Dives", function()
		return config.runModes.dreamDivesZagContract == true
	end, function(value)
		config.runModes.dreamDivesZagContract = value
	end)
end

local function drawMenu()
	drawGeneral()

	rom.ImGui.Separator()

	if rom.ImGui.CollapsingHeader("Allies") then
		drawAllies()
	end

	if rom.ImGui.CollapsingHeader("After True Ending") then
		drawPostTrueEnding()
	end

	if rom.ImGui.CollapsingHeader("Chaos Trials & Dream Dives") then
		drawRunModes()
	end

	rom.ImGui.Separator()
	rom.ImGui.TextWrapped(
		"Same settings file as r2modman Config—click Refresh All Edits there after you change options here. "
			.. "Ally toggles apply on the next run."
	)
end

local WINDOW_TITLE = "Fated Encounters"
local MENU_TITLE = "Fated Encounters"
local WINDOW_MIN_WIDTH = 480
local WINDOW_FLAGS = rom.ImGuiWindowFlags and rom.ImGuiWindowFlags.AlwaysAutoResize or 64

local function beginSettingsWindow()
	rom.ImGui.SetNextWindowSizeConstraints(WINDOW_MIN_WIDTH, 0, 10000, 10000)
	return rom.ImGui.Begin(WINDOW_TITLE, WINDOW_FLAGS)
end

noteConfigFileAsSeen()

mod.Gui = mod.Gui or {}
mod.Gui.tickConfigSync = tickConfigSync
mod.Gui.drawSettingsMenu = drawMenu
mod.Gui.beginSettingsWindow = beginSettingsWindow

if not _PLUGIN._fatedEncountersGuiRegistered then
	_PLUGIN._fatedEncountersGuiRegistered = true

	rom.gui.add_imgui(function()
		mod.Gui.tickConfigSync()
		if mod.Gui.beginSettingsWindow() then
			mod.Gui.drawSettingsMenu()
			rom.ImGui.End()
		end
	end)

	rom.gui.add_to_menu_bar(function()
		mod.Gui.tickConfigSync()
		if rom.ImGui.BeginMenu(MENU_TITLE) then
			mod.Gui.drawSettingsMenu()
			rom.ImGui.EndMenu()
		end
	end)
end

mod.Gui.DrawMenu = drawMenu
