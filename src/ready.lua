---@meta _
-- One-time setup: import feature modules and register game hooks (not re-run on hot reload).

import 'encounters.lua'
import 'run_modes.lua'
import 'tracker.lua'
import 'zagreus.lua'
import 'chronos.lua'
import 'guarantee.lua'

if not mod.HooksRegistered then
	mod.HooksRegistered = true
	guarantee.RegisterHooks()
end
