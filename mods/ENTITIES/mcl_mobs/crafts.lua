
local S = minetest.get_translator("mcl_mobs")

-- name tag
minetest.register_craftitem("mcl_mobs:nametag", {
	description = S("Name Tag"),
	_tt_help = S("Give names to mobs").."\n"..S("Set name at anvil"),
	_doc_items_longdesc = S("A name tag is an item to name a mob."),
	_doc_items_usagehelp = S("Before you use the name tag, you need to set a name at an anvil. Then you can use the name tag to name a mob. This uses up the name tag."),
	inventory_image = "mobs_nametag.png",
	wield_image = "mobs_nametag.png",
	stack_max = 64,
	groups = { tool=1 },
})

minetest.register_alias("mobs:nametag", "mcl_mobs:nametag")
