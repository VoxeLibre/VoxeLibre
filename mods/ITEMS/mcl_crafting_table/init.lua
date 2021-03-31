local S = minetest.get_translator("mcl_crafting_table")
local formspec_escape = minetest.formspec_escape
local show_formspec = minetest.show_formspec
local C = minetest.colorize
local text_color = mcl_colors.DARK_GRAY
local itemslot_bg = mcl_formspec.get_itemslot_bg

mcl_crafting_table = {}
function mcl_crafting_table.show_crafting_form(player)
	player:get_inventory():set_width("craft", 3)
	player:get_inventory():set_size("craft", 9)

	show_formspec(player:get_player_name(), "main",
		"size[9,8.75]"..
		"image[4.7,1.5;1.5,1;gui_crafting_arrow.png]"..
		"label[0,4;"..formspec_escape(C(text_color, S("Inventory"))).."]"..
		"list[current_player;main;0,4.5;9,3;9]"..
		itemslot_bg(0,4.5,9,3)..
		"list[current_player;main;0,7.74;9,1;]"..
		itemslot_bg(0,7.74,9,1)..
		"label[1.75,0;"..formspec_escape(C(text_color, S("Crafting"))).."]"..
		"list[current_player;craft;1.75,0.5;3,3;]"..
		itemslot_bg(1.75,0.5,3,3)..
		"list[current_player;craftpreview;6.1,1.5;1,1;]"..
		itemslot_bg(6.1,1.5,1,1)..
		"image_button[0.75,1.5;1,1;craftguide_book.png;__mcl_craftguide;]"..
		"tooltip[__mcl_craftguide;"..formspec_escape(S("Recipe book")).."]"..
		"listring[current_player;main]"..
		"listring[current_player;craft]"
	)
end

local show_crafting_form = mcl_crafting_table.show_crafting_form  --cache function for better performances
minetest.register_node("mcl_crafting_table:crafting_table", {
	description = S("Crafting Table"),
	_tt_help = S("3×3 crafting grid"),
	_doc_items_longdesc = S("A crafting table is a block which grants you access to a 3×3 crafting grid which allows you to perform advanced crafts."),
	_doc_items_usagehelp = S("Rightclick the crafting table to access the 3×3 crafting grid."),
	_doc_items_hidden = false,
	is_ground_content = false,
	tiles = {"crafting_workbench_top.png", "default_wood.png", "crafting_workbench_side.png",
		"crafting_workbench_side.png", "crafting_workbench_front.png", "crafting_workbench_front.png"},
	paramtype2 = "facedir",
	groups = {handy=1,axey=1, deco_block=1, material_wood=1,flammable=-1},
	on_rightclick = function(pos, node, player, itemstack)
		show_crafting_form(player)
	end,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 2.5,
})

minetest.register_craft({
	output = "mcl_crafting_table:crafting_table",
	recipe = {
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"}
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_crafting_table:crafting_table",
	burntime = 15,
})

minetest.register_alias("crafting:workbench", "mcl_crafting_table:crafting_table")
minetest.register_alias("mcl_inventory:workbench", "mcl_crafting_table:crafting_table")
