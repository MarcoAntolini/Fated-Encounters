local default = {
	version = 2;
	enabled = true;
	guaranteeFieldNPCs = true;
	fieldNPCs = {
		Nemesis = true;
		Artemis = true;
		Heracles = true;
		Icarus = true;
		Athena = true;
	};
	guaranteeZagContract = true;
	guaranteeChronosClearing = true;
	debugLog = false;
}

local descript = {
	version = "Config schema version (used when new options are added).";
	enabled = "Enable or disable the entire mod.";
	guaranteeFieldNPCs = "Master switch for field NPC guarantees (Nemesis, Artemis, Heracles, Icarus, Athena). When off, the per-NPC options below are ignored.";
	fieldNPCs = {
		Nemesis = "Guarantee a Nemesis field encounter in each biome you visit this run.";
		Artemis = "Guarantee an Artemis field encounter in each biome you visit this run.";
		Heracles = "Guarantee a Heracles field encounter in each biome you visit this run.";
		Icarus = "Guarantee an Icarus field encounter in each biome you visit this run.";
		Athena = "Guarantee an Athena field encounter in each biome you visit this run.";
	};
	guaranteeZagContract = "After True Ending: guarantee the Zagreus Infernal Contract when it is unlocked for that run.";
	guaranteeChronosClearing = "After True Ending: guarantee the Neo-Chronos clearing encounter.";
	debugLog = "Print debug messages to the game console (for troubleshooting).";
}

return default, descript
