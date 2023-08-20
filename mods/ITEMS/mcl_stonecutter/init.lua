--|||||||||||||||||||||||
--||||| STONECUTTER |||||
--|||||||||||||||||||||||


local S = minetest.get_translator("mcl_stonecutter")

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
			table.insert(cut_items,string.format("item_image_button[%f,%f;%f,%f;%s;%s;%s]",x_len+1,y_len,1,1, value, value, ""))
		end
	end

	local formspec = "size[9,8.75]"..
	"label[0,4.0;"..minetest.formspec_escape(minetest.colorize("#313131", S("Inventory"))).."]"..
	"label[1,0.1;"..minetest.formspec_escape(minetest.colorize("#313131", S("Stone Cutter"))).."]"..
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


--Checks for the string for the different stair and wall positions that shouldn't be craftable
local function check(item_name, input_name)
	print(item_name)
	if string.match(item_name, "mcl_walls") then
		if string.match(item_name, "%d") then
			return true
		end
	end
	if string.match(item_name, "_outer") then
		return true
	elseif string.match(item_name, "_inner") then
		return true
	elseif string.match(item_name, "_top") then
		return true
	elseif string.match(item_name, "_double") then
		return true
	end
	if minetest.get_item_group(item_name, "stonecutter_stage") == 0 and minetest.get_item_group(input_name, "stonecutter_stage") > 0 then
		return true
	end
	return false
end


-- Updates the formspec
local function update_stonecutter_slots(pos,str)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local input = inv:get_stack("input", 1)
	local name = input:get_name()
	local compat_item = minetest.get_item_group(name, "stonecuttable")

	-- Checks if input is in the group
	if compat_item > 0 then
		local cuttable_recipes = {}
		for item_name, item_def in pairs(minetest.registered_items) do
			if item_def.groups and item_def.groups["stonecutter_output"] == compat_item then
				if check(item_name, name) == false and name ~= item_name then
					table.insert(cuttable_recipes, item_name)
				end
			end
		end
		meta:set_string("formspec", show_stonecutter_formspec(cuttable_recipes))
	else
		meta:set_string("formspec", show_stonecutter_formspec(nil))
	end

	-- Checks if the chosen item is a slab or not, if it's a slab set the output to be a stack of 2
	if minetest.get_item_group(str, "stonecutter_output") > 0 then
		local cut_item = ItemStack(str)
		if string.match(str, "mcl_stairs:slab_") then
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
	local meta = minetest.get_meta(pos)
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
	on_destruct = drop_stonecutter_items,
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
		update_stonecutter_slots(pos)
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
		update_stonecutter_slots(pos)
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
		update_stonecutter_slots(pos)
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
			update_stonecutter_slots(pos)
		end
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local sender_name = sender:get_player_name()
		if minetest.is_protected(pos, sender_name) then
			minetest.record_protection_violation(pos, sender_name)
			return
		end
		if fields then
			for field_name, value in pairs(fields) do
				local item_name = tostring(field_name)
				if item_name then
					update_stonecutter_slots(pos, item_name)
				end
			end
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
