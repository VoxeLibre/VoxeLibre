--|||||||||||||||||||||||
--||||| STONECUTTER |||||
--|||||||||||||||||||||||


local S = minetest.get_translator("mcl_stonecutter")

-- compatible items for the stonecutter
local compaitble_items = {
}

local FMT = {
	item_image_button = "item_image_button[%f,%f;%f,%f;%s;%s;%s]",
}

-- formspecs
local function show_stonecutter_formspec(items, input)
	local cut_items = {}
	local x_len = 0
	local y_len = 0.5

	-- This loops through all the items that can be made and inserted into the formspec
	if items ~= nil then
		for index, value in pairs(items) do
			x_len = x_len + 1
			if x_len > 5 then
				y_len = y_len + 1
				x_len = 1
			end
			local test = string.format(FMT.item_image_button,x_len+1,y_len,1,1, value, "item_button", value)
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

-- Strips the start of the item like "mcl_core:" and removes any numbers or whitespaces after it
local function get_item_string_name(input)
	local colonIndex = string.find(input, ":")
	if colonIndex then
        input = string.sub(input, colonIndex + 1)
    else
		return input
	end
	local whitespaceIndex = string.find(input, "%s")
	if whitespaceIndex then
        return string.sub(input, 1, whitespaceIndex - 1)
    else
        return input
    end
end

-- Updates the formspec
local function update_stonecutter_slots(meta)
	local inv = meta:get_inventory()
	local input = inv:get_stack("input", 1)
	local name = input:get_name()
	local new_output = meta:get_string("cut_stone")

	-- Checks if input is in the array
	if minetest.get_item_group(name, "stonecuttable") > 0 then
		local cuttable_recipes = {}
		local name_stripped = get_item_string_name(input:to_string())
		if name_stripped ~= "" then
			-- Strings for the possible items it can craft into
			local stair = "mcl_stairs:stair_"..name_stripped
			local slab = "mcl_stairs:slab_"..name_stripped
			local wall = "mcl_walls:"..name_stripped
			local smooth = "mcl_core:"..name_stripped.."_smooth"

			-- Goes through and checks if the item exists and inserts it into the table
			if minetest.registered_items[slab] ~= nil then
				table.insert(cuttable_recipes, slab)
			end
			if minetest.registered_items[stair] ~= nil then
				table.insert(cuttable_recipes, stair)
			end
			if minetest.registered_items[wall] ~= nil then
				table.insert(cuttable_recipes, wall)
			end
			if minetest.registered_items[smooth] ~= nil then
				local smooth_stair = "mcl_stairs:stair_"..name_stripped.."_smooth"
				local smooth_slab = "mcl_stairs:slab_"..name_stripped.."_smooth"

				table.insert(cuttable_recipes, smooth)
				if minetest.registered_items[smooth_slab] ~= nil then
					table.insert(cuttable_recipes, smooth_slab)
				end
				if minetest.registered_items[smooth_stair] ~= nil then
					table.insert(cuttable_recipes, smooth_stair)
				end
			end
		end
		meta:set_string("formspec", show_stonecutter_formspec(cuttable_recipes))
	else
		meta:set_string("formspec", show_stonecutter_formspec(nil))
	end

	-- Checks if the chosen item is a slab or not, if it's a slab set the output to be a stack of 2
	if new_output ~= '' then
		local cut_item = ItemStack(new_output)
		if string.find(new_output, "mcl_stairs:slab_") then
			cut_item:set_count(2)
		else
			cut_item:set_count(1)
		end
		inv:set_stack("output", 1, cut_item)
	else
		inv:set_stack("output", 1, "")
	end
end

-- Only drop the items that were in the input slot
local function drop_stonecutter_items(pos, meta)
	local inv = meta:get_inventory()
	for i=1, inv:get_size("input") do
		local stack = inv:get_stack("input", i)
		if not stack:is_empty() then
			local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
			minetest.add_item(p, stack)
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

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest.get_meta(pos)
		local meta2 = meta:to_table()
		meta:from_table(oldmetadata)
		drop_stonecutter_items(pos, meta)
		meta:from_table(meta2)
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		elseif to_list == "output" then
			return 0
		elseif from_list == "output" and to_list == "input" then
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			if inv:get_stack(to_list, to_index):is_empty() then
				return count
			else
				return 0
			end
		else
			return count
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
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		if listname == "output" then
			local inv = meta:get_inventory()
			local input = inv:get_stack("input", 1)
			input:take_item()
			inv:set_stack("input", 1, input)
			if input:get_count() == 0 then
				meta:set_string("cut_stone", nil)
			end
		else
			meta:set_string("cut_stone", nil)
		end
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
		if not player:get_player_control().sneak then
			local meta = minetest.get_meta(pos)
			update_stonecutter_slots(meta)
		end
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local sender_name = sender:get_player_name()
		if minetest.is_protected(pos, sender_name) then
			minetest.record_protection_violation(pos, sender_name)
			return
		end
		if fields.item_button then
			local meta = minetest.get_meta(pos)
			meta:set_string("cut_stone", fields.item_button)
			update_stonecutter_slots(meta)
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
