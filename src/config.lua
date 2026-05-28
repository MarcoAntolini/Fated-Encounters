-- Chalk defaults and r2modman field descriptions. Bump `version` when adding keys; migrate in config_migrate.lua.

local default = {
	version = 6;
	enabled = true;
	debugLog = false;
	allies = {
		fieldNPCs = {
			Nemesis = true;
			Artemis = true;
			Heracles = true;
			Icarus = true;
			Athena = true;
		};
		randomizeFieldNPCBiome = false;
	};
	postTrueEnding = {
		guaranteeZagContract = true;
		guaranteeChronosClearing = true;
	};
	runModes = {
		chaosTrials = false;
		dreamDives = false;
		dreamDivesZagContract = false;
	};
}

local descript = {
	enabled = "Enable or disable the entire mod.";
	debugLog = "Print debug messages to the game console (for troubleshooting).";
	allies = {
		fieldNPCs = {
			Nemesis = "Guarantee you meet Nemesis in combat once this run (first eligible region you visit, or a random one if random region shuffle is on).";
			Artemis = "Guarantee you meet Artemis in combat once this run (first eligible region you visit, or a random one if random region shuffle is on).";
			Heracles = "Guarantee you meet Heracles in combat once this run (first eligible region you visit, or a random one if random region shuffle is on).";
			Icarus = "Guarantee you meet Icarus in combat once this run (first eligible region you visit, or a random one if random region shuffle is on).";
			Athena = "Guarantee you meet Athena in combat once this run (first eligible region you visit, or a random one if random region shuffle is on).";
		};
		randomizeFieldNPCBiome = "When on, each enabled ally is assigned one random eligible region at run start and only appears there. When off, they appear in the first eligible region you enter this run. Ignored during Dream Dives—those regions are drawn at biome transitions, so allies always fire in the first eligible region visited.";
	};
	postTrueEnding = {
		guaranteeZagContract = "After True Ending: guarantee Zagreus offers the Infernal Contract once per run when that content is unlocked.";
		guaranteeChronosClearing = "After True Ending: guarantee Chronos appears for a conversation in the hub between Erebus and Oceanus once per run (not the Asphodel send event).";
	};
	runModes = {
		chaosTrials = "Apply ally guarantees during Chaos Trials (curated and randomized trials). Off by default; the base game blocks or gates allies in these short runs.";
		dreamDives = "Apply ally guarantees during Hypnos Dream Dives. Off by default.";
		dreamDivesZagContract = "Guarantee the Infernal Contract during Dream Dives when the True Ending Zagreus option is on. Separate from ally guarantees. May not trigger if no contract shop room appears.";
	};
}

return default, descript
