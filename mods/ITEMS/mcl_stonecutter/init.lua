--|||||||||||||||||||||||
--||||| STONECUTTER |||||
--|||||||||||||||||||||||

-- TO-DO:
-- * Add GUI

local S = minetest.get_translator(minetest.get_current_modname())

local recipes = {
	{"mcl_core:cobble", "mcl_stairs:slab_cobble", "mcl_walls:cobble", "mcl_stairs:stair_cobble"},
	{"mcl_core:granite", "mcl_stairs:slab_granite", "mcl_walls:granite", "mcl_stairs:stair_granite", "mcl_core:granite_smooth", "mcl_stairs:stair_granite_smooth", "mcl_stairs:slab_granite_smooth"},
	{"mcl_core:diorite", "mcl_stairs:slab_diorite", "mcl_walls:diorite", "mcl_stairs:stair_diorite", "mcl_core:diorite_smooth", "mcl_stairs:stair_diorite_smooth", "mcl_stairs:slab_diorite_smooth"},
}


local FMT = {
	item_image_button = "item_image_button[%f,%f;%f,%f;%s;%s;%s]",
	item_image = "item_image[%f,%f;%f,%f;%s]",
}

local function show_stonecutter_formspec(items, input)
	local cut_items = {}

	local x_len = 0
	local y_len = 0.5

	if items ~= nil then
		for index, value in pairs(items) do
			x_len = x_len + 1
			if x_len > 5 then
				y_len = y_len + 1
				x_len = 1
			end
			local test = string.format(FMT.item_image_button,x_len+1,y_len,1,1, value, value, "")
			cut_items[index] = test
		end
	end

	local formspec = "size[9,8.75]"..
	"label[0,4.0;"..minetest.formspec_escape(minetest.colorize("#313131", S("Inventory"))).."]"..
	"label[1,0.1;"..minetest.formspec_escape(minetest.colorize("#313131", S("Stonecutter"))).."]"..
	"list[context;main;0,0;8,4;]"..
	"list[current_player;main;0,4.5;9,3;9]"..
	mcl_formspec.get_itemslot_bg(0,4.5,9,3)..
	"list[current_player;main;0,7.74;9,1;]"..
	mcl_formspec.get_itemslot_bg(0,7.74,9,1)..
	"list[context;input;0.5,1.7;1,1;]"..
	mcl_formspec.get_itemslot_bg(0.5,1.7,1,1)..
	"list[context;output;7.5,1.7;1,1;]"..
	mcl_formspec.get_itemslot_bg(7.5,1.7,1,1)..
	table.concat(cut_items)..
	"listring[context;output]"..
	"listring[current_player;main]"..
	"listring[context;input]"..
	"listring[current_player;main]"

	return formspec
end

local function update_stonecutter_slots(meta)
	local inv = meta:get_inventory()
	local input = inv:get_stack("input", 1)
	local name = input:get_name()

	local new_output
	for index, value in pairs(recipes) do
		if name == value[1] then
			meta:set_string("formspec", show_stonecutter_formspec(recipes[index]))
		end
	end
end


minetest.register_node("mcl_stonecutter:stonecutter", {
	description = S("Stone Cutter"),
	_tt_help = S("Used to cut stone like materials."),
	_doc_items_longdesc = S("Stonecutters are used to create stairs and slabs from stone like materials. It is also the jobsite for the Stone Mason Villager."),
	tiles = {
		"mcl_stonecutter_top.png",
		"mcl_stonecutter_bottom.png",
		"mcl_stonecutter_side.png",
		"mcl_stonecutter_side.png",
		{name="mcl_stonecutter_saw.png", 
		animation={
			type="vertical_frames", 
			aspect_w=16, 
			aspect_h=16, 
			length=1
		}},
		{name="mcl_stonecutter_saw.png", 
		animation={
			type="vertical_frames", 
			aspect_w=16, 
			aspect_h=16, 
			length=1
		}}
	},
	use_texture_alpha = "clip",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { pickaxey=1, material_stone=1 },
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.0625, 0.5}, -- NodeBox1
			{-0.4375, 0.0625, 0, 0.4375, 0.5, 0}, -- NodeBox2
		}
	},
	_mcl_blast_resistance = 3.5,
	_mcl_hardness = 3.5,
	sounds = mcl_sounds.node_sound_stone_defaults(),

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local meta = minetest.get_meta(pos)
		if from_list == "output" and to_list == "input" then
			local inv = meta:get_inventory()
			for i=1, inv:get_size("input") do
				if i ~= to_index then
					local istack = inv:get_stack("input", i)
					istack:set_count(math.max(0, istack:get_count() - count))
					inv:set_stack("input", i, istack)
				end
			end
		end
		update_stonecutter_slots(meta)
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		elseif listname == "output" then
			return 0
		else
			return stack:get_count()
		end
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		update_stonecutter_slots(meta)
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("input", 1)
		inv:set_size("output", 1)
		local form = show_stonecutter_formspec()
		meta:set_string("formspec", form)
	end,

	on_rightclick = function(pos, node, player, itemstack)
		local name = player:get_player_name()
		if not player:get_player_control().sneak then
			local meta = minetest.get_meta(pos)
			--show_stonecutter_formspec(name, "main", player)
			update_stonecutter_slots(meta)
			--meta:set_string("formspec", show_stonecutter_formspec(items[1]))
		end
	end,
})

minetest.register_craft({
	output = "mcl_stonecutter:stonecutter",
	recipe = {
		{ "", "", "" },
		{ "", "mcl_core:iron_ingot", "" },
		{ "mcl_core:stone", "mcl_core:stone", "mcl_core:stone" },
	}
})
