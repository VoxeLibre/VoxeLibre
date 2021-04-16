local formspec = "size[9,9]" ..
		   "label[0,4.0;" .. minetest.formspec_escape(minetest.colorize(mcl_colors.DARK_GRAY, "Inventory")) .. "]" ..
		   "list[current_player;main;0,4.5;9,3;9]" ..
		   mcl_formspec.get_itemslot_bg(0,4.5,9,3) ..
		   "list[current_player;main;0,7.74;9,1;]" ..
		   mcl_formspec.get_itemslot_bg(0,7.74,9,1) ..
		   "list[context;input;1,2.5;1,1;]" ..
		   mcl_formspec.get_itemslot_bg(1,2.5,1,1) ..
		   "list[context;input;4,2.5;1,1;1]" ..
		   mcl_formspec.get_itemslot_bg(4,2.5,1,1) ..
		   "list[context;output;8,2.5;1,1;]" ..
		   mcl_formspec.get_itemslot_bg(8,2.5,1,1) ..
		   "label[3,0.1;" .. minetest.formspec_escape(minetest.colorize(mcl_colors.DARK_GRAY, "Upgrade Gear")) .. "]" ..
		   "button[7,0.7;2,1;name_button;" .. minetest.formspec_escape("Upgrade Gear") .. "]" ..
		   "listring[context;output]"..
		   "listring[current_player;main]"..
		   "listring[context;input]"..
		   "listring[current_player;main]"


local function upgrade(itemstack)
	itemstack:set_name(itemstack:get_name():gsub("diamond", "netherite"))
end

minetest.register_node("mcl_smithing_table:table", {
	description = "Smithing table",

	stack_max = 64,
	groups = {pickaxey = 2, deco_block = true},

	tiles = {
		"mcl_smithing_table_top.png", "mcl_smithing_table_front.png", "mcl_smithing_table_side.png",
		"mcl_smithing_table_side.png", "mcl_smithing_table_side.png", "mcl_smithing_table_side.png",
		"mcl_smithing_table_side.png", "mcl_smithing_table_side.png", "mcl_smithing_table_bottom.png"
	},

	on_construct = function(pos)
        minetest.get_meta(pos):set_string("formspec", formspec)
    end,

	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 2.5
})