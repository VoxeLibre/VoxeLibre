--[[
This mod implements the API to register digging groups for mcl_autogroup.  The
rest of the mod is implemented and documented in the mod _mcl_autogroup.

The mod is split up into two parts, mcl_autogroup and _mcl_autogroup.
mcl_autogroup contains the API functions used to register custom digging groups.
_mcl_autogroup contains most of the code.  The leading underscore in the name
"_mcl_autogroup" is used to force Minetest to load that part of the mod as late
as possible.  Minetest loads mods in reverse alphabetical order.
--]]
mcl_autogroup = {}
mcl_autogroup.registered_diggroups = {}

function mcl_autogroup.register_diggroup(group, def)
	mcl_autogroup.registered_diggroups[group] = def or {}
end
