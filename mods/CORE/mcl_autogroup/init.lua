--[[
This mod implements the API to register digging groups for mcl_autogroups.  The
rest of the mod is implemented and documented in the mod "_mcl_autogroup".

The mcl_autogroups mod is split up into two mods, mcl_autogroups and
_mcl_autogroups.  mcl_autogroups contains the API functions used to register
custom digging groups.  _mcl_autogroups contains parts of the mod which need to
be executed after loading all other mods.
--]]
mcl_autogroup = {}
mcl_autogroup.registered_digtime_groups = {}

function mcl_autogroup.register_digtime_group(group, def)
	mcl_autogroup.registered_digtime_groups[group] = def or {}
end
