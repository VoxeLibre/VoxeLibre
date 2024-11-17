local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local mod = vl_tuning

mod.keep_inventory = {}
vl_tuning.setting("gamerule:keepInventory", "bool", {
	default = minetest.settings:get_bool("mcl_keepInventory", false),
	set = function(val) mod.keep_inventory[1] = val end,
	get = function() return mod.keep_inventory[1] end,
})
mod.respawn_blocks_explode = {}
vl_tuning.setting("gamerule:respawnBlocksExplode", "bool", {
	description = S("Prevents beds/respawn anchors from exploding in other dimensions."),
	default = true,
	set = function(val) mod.respawn_blocks_explode[1] = val end,
	get = function() return mod.respawn_blocks_explode[1] end,
})

