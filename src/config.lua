local default = {
	version = 3;
	enabled = true;
	guaranteeFieldNPCs = true;
	fieldNPCs = {
		Nemesis = true;
		Artemis = true;
		Heracles = true;
		Icarus = true;
		Athena = true;
	};
	randomizeFieldNPCBiome = false;
	guaranteeZagContract = true;
	guaranteeChronosClearing = true;
	debugLog = false;
}

local descript = {
	version = "Config schema version (used when new options are added).";
	enabled = "Enable or disable the entire mod.";
	guaranteeFieldNPCs = "Master switch for field NPC guarantees (Nemesis, Artemis, Heracles, Icarus, Athena). When off, the per-NPC options below are ignored.";
	fieldNPCs = {
		Nemesis = "Guarantee you meet Nemesis once this run (first eligible biome you visit, or a random one if randomizeFieldNPCBiome is on).";
		Artemis = "Guarantee you meet Artemis once this run (first eligible biome you visit, or a random one if randomizeFieldNPCBiome is on).";
		Heracles = "Guarantee you meet Heracles once this run (first eligible biome you visit, or a random one if randomizeFieldNPCBiome is on).";
		Icarus = "Guarantee you meet Icarus once this run (first eligible biome you visit, or a random one if randomizeFieldNPCBiome is on).";
		Athena = "Guarantee you meet Athena once this run (first eligible biome you visit, or a random one if randomizeFieldNPCBiome is on).";
	};
	randomizeFieldNPCBiome = "When on, each enabled field NPC is assigned one random eligible biome at run start and only forced there. When off, they appear in the first eligible biome you enter this run.";
	guaranteeZagContract = "After True Ending: guarantee the Zagreus Infernal Contract once per run when it is unlocked.";
	guaranteeChronosClearing = "After True Ending: guarantee the Neo-Chronos clearing encounter once per run.";
	debugLog = "Print debug messages to the game console (for troubleshooting).";
}

return default, descript
