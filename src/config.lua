local default = {
	version = 4;
	enabled = true;
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
	enabled = "Enable or disable the entire mod.";
	fieldNPCs = {
		Nemesis = "Guarantee you meet Nemesis in combat once this run (first eligible region you visit, or a random one if random region shuffle is on).";
		Artemis = "Guarantee you meet Artemis in combat once this run (first eligible region you visit, or a random one if random region shuffle is on).";
		Heracles = "Guarantee you meet Heracles in combat once this run (first eligible region you visit, or a random one if random region shuffle is on).";
		Icarus = "Guarantee you meet Icarus in combat once this run (first eligible region you visit, or a random one if random region shuffle is on).";
		Athena = "Guarantee you meet Athena in combat once this run (first eligible region you visit, or a random one if random region shuffle is on).";
	};
	randomizeFieldNPCBiome = "When on, each enabled ally is assigned one random eligible region at run start and only appears there. When off, they appear in the first eligible region you enter this run.";
	guaranteeZagContract = "After True Ending: guarantee Zagreus offers the Infernal Contract once per run when that content is unlocked.";
	guaranteeChronosClearing = "After True Ending: guarantee Chronos appears for a conversation in the hub between Erebus and Oceanus once per run (not the Asphodel send event).";
	debugLog = "Print debug messages to the game console (for troubleshooting).";
}

return default, descript
