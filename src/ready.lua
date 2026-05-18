---@meta _
-- One-time setup (not reloaded on hot reload during gameplay).

import 'encounters.lua'
import 'tracker.lua'
import 'zagreus.lua'
import 'chronos.lua'
import 'guarantee.lua'

if not mod.HooksRegistered then
	mod.HooksRegistered = true
	guarantee.RegisterHooks()
end
