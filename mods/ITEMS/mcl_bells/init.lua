local S = minetest.get_translator(minetest.get_current_modname())

mcl_bells = {}

local has_mcl_wip = minetest.get_modpath("mcl_wip")

minetest.register_node("mcl_bells:bell", {
	description = S("Bell"),
	inventory_image = "bell.png",
	drawtype = "plantlike",
	tiles = {"bell.png"},
	stack_max = 64,
	selection_box = {
		type = "fixed",
		fixed = {
			-4/16, -6/16, -4/16,
			 4/16,  7/16,  4/16,
		},
	},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=2, deco_block=1 },
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
})

if has_mcl_wip then
	mcl_wip.register_wip_item("mcl_bells:bell")
end
