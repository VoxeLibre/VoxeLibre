local mod = vl_tuning

mod.keep_inventory = vl_tuning.setting("gamerule:keepInventory", "bool", {
	default = minetest.settings:get_bool("mcl_keepInventory", false),
})

