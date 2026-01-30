local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local mod = vl_tuning

vl_tuning.setting("gamerule:creativeInstantKill", "bool", {
	description = S("Allows creative players to kill mobs with only a single punch."),
	default = true,
	set = function(val) core.settings:set_bool("vl_creative_instant_kill", val) end,
	get = function() return core.settings:get_bool("vl_creative_instant_kill", true) end,
})
local keep_inventory
vl_tuning.setting("gamerule:keepInventory", "bool", {
	default = minetest.settings:get_bool("mcl_keepInventory", false),
	set = function(val) keep_inventory = val end,
	get = function() return keep_inventory end,
})
local respawn_blocks_explode
vl_tuning.setting("gamerule:respawnBlocksExplode", "bool", {
	description = S("Prevents beds/respawn anchors from exploding in other dimensions."),
	default = true,
	set = function(val) respawn_blocks_explode = val end,
	get = function() return respawn_blocks_explode end,
})

