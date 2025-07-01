--|||||||||||||||||||||||
--||||| STONECUTTER |||||
--|||||||||||||||||||||||

-- The stonecutter is implemented just like the crafting table, meaning the node doesn't have any state.
-- Instead it trigger the display of a per-player menu. The input and output slots, the wanted item are stored into the player meta.
--
-- Player inventory lists:
--  * stonecutter_input (1)
--  * stonecutter_output (1)
-- Player meta:
--  * mcl_stonecutter:selected (string, wanted item name)
--  * mcl_stonecutter:switch_stack (int, wanted craft count: 1 or 64 = once or until full stack)


local S = minetest.get_translator("mcl_stonecutter")
local C = minetest.colorize
local show_formspec = minetest.show_formspec

local formspec_name = "mcl_stonecutter:stonecutter"

mcl_stonecutter = {}


---Table of registered recipes
---
---```lua
---mcl_stonecutter.registered_recipes = {
---    ["mcl_core:input_item"] = {
---        ["mcl_core:output_item"] = 1,
---        ["mcl_core:output_item2"] = 2,
---    },
---}
---```
---@type table<string, table<string, integer>>
mcl_stonecutter.registered_recipes = {}


---Registers a recipe for the stonecutter
---@param input string Name of a registered item
---@param output string Name of a registered item
---@param count? integer Number of the output, defaults to `1`
function mcl_stonecutter.register_recipe(input, output, count)
	if mcl_stonecutter.registered_recipes[input] and mcl_stonecutter.registered_recipes[input][output] then
		minetest.log("warning",
			"[mcl_stonecutter] Recipe already registered: [" .. input .. "] -> [" .. output .. " " .. count .. "]")
		return
	end

	if not minetest.registered_items[input] then
		error("Input is not a registered item: " .. input)
	end

	if not minetest.registered_items[output] then
		error("Output is not a registered item: " .. output)
	end

	count = count or 1

	if not mcl_stonecutter.registered_recipes[input] then
		mcl_stonecutter.registered_recipes[input] = {}
	end

	mcl_stonecutter.registered_recipes[input][output] = count

	local fallthrough = mcl_stonecutter.registered_recipes[output]
	if fallthrough then
		for o, c in pairs(fallthrough) do
			if not mcl_stonecutter.registered_recipes[input][o] then
				mcl_stonecutter.register_recipe(input, o, c * count)
			end
		end
	end

	for i, recipes in pairs(mcl_stonecutter.registered_recipes) do
		for name, c in pairs(recipes) do
			if name == input and not mcl_stonecutter.registered_recipes[i][output] then
				mcl_stonecutter.register_recipe(i, output, c * count)
			end
		end
	end
end

---Luanti currently (5.7) doesn't prevent using `:` characters in field names
---But using them prevent the buttons from beeing styled with `style[]` elements
---https://github.com/minetest/minetest/issues/14013

---@param itemname string
local function itenname_to_fieldname(itemname)
	return string.gsub(itemname, ":", "__")
end

---@param fieldname string
local function fieldname_to_itemname(fieldname)
	return string.gsub(fieldname, "__", ":")
end

-- Get the player configured stack size when taking items from creative inventory
---@param player mt.PlayerObjectRef
---@return integer
local function get_stack_size(player)
	return player:get_meta():get_int("mcl_stonecutter:switch_stack")
end

-- Set the player configured stack size when taking items from creative inventory
---@param player mt.PlayerObjectRef
---@param n integer
local function set_stack_size(player, n)
	player:get_meta():set_int("mcl_stonecutter:switch_stack", n)
end

---Build the formspec for the stonecutter with given output button
---@param player mt.PlayerObjectRef
---@param items? table<string, integer>
local function build_stonecutter_formspec(player, items)
	local meta = player:get_meta()
	local selected = meta:get_string("mcl_stonecutter:selected")

	items = items or {}

	-- Buttons are 3.5 / 4 = 0.875 wide
	local c = 0
	local items_content = "style_type[item_image_button;noclip=false;content_offset=0]" ..
		(selected ~= "" and "style[" .. itenname_to_fieldname(selected) .. ";border=false;bgimg=mcl_inventory_button9_pressed.png;bgimg_pressed=mcl_inventory_button9_pressed.png;bgimg_middle=2,2]" or "")

	for name, count in table.pairs_by_keys(items) do
		c = c + 1
		local x = ((c - 1) % 4) * 0.875
		local y = (math.floor((c - 1) / 4)) * 0.875

		items_content = items_content ..
			string.format("item_image_button[%f,%f;0.875,0.875;%s;%s;]", x, y,
				name, itenname_to_fieldname(name), tostring(count))
	end

	local formspec = table.concat({
		"formspec_version[4]",
		"size[11.75,10.425]",
		"label[0.375,0.375;" .. C(mcl_formspec.label_color, S("Stone Cutter")) .. "]",

		-- Pattern input slot
		mcl_formspec.get_itemslot_bg_v4(1.625, 2, 1, 1),
		"list[current_player;stonecutter_input;1.625,2;1,1;]",

		-- Container background
		"image[4.075,0.7;3.6,3.6;mcl_inventory_stonecutter.png;2]",

		-- Style for item image buttons
		"style_type[item_image_button;noclip=false;content_offset=0]",

		-- Scroll Container with buttons if needed
		"scroll_container[4.125,0.75;3.5,3.5;scroll;vertical;0.875]",
		items_content,
		"scroll_container_end[]",

		-- Scrollbar
		-- TODO: style the scrollbar correctly when possible
		"scrollbaroptions[min=0;max=" ..
		math.max(math.floor(#items / 4) + 1 - 4, 0) .. ";smallstep=1;largesteps=1]",
		"scrollbar[7.625,0.7;0.75,3.6;vertical;scroll;0]",

		-- Switch stack size button
		"image_button[9.75,0.75;1,1;mcl_stonecutter_saw.png^[verticalframe:3:1;__switch_stack;]",
		"label[10.25,1.5;" .. C("#FFFFFF", tostring(get_stack_size(player))) .. "]",
		"tooltip[__switch_stack;" .. S("Switch stack size") .. "]",

		-- Output slot
		mcl_formspec.get_itemslot_bg_v4(9.75, 2, 1, 1, 0.2),
		"list[current_player;stonecutter_output;9.75,2;1,1;]",

		-- Player inventory
		"label[0.375,4.7;" .. C(mcl_formspec.label_color, S("Inventory")) .. "]",
		mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
		"list[current_player;main;0.375,5.1;9,3;9]",

		mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
		"list[current_player;main;0.375,9.05;9,1;]",

		"listring[current_player;stonecutter_output]",
		"listring[current_player;main]",
		"listring[current_player;stonecutter_input]",
		"listring[current_player;main]",
	})

	return formspec
end


---Display stonecutter menu to a player
---@param player mt.PlayerObjectRef
function mcl_stonecutter.show_stonecutter_form(player)
	show_formspec(player:get_player_name(), formspec_name,
		build_stonecutter_formspec(player,
			mcl_stonecutter.registered_recipes[player:get_inventory():get_stack("stonecutter_input", 1):get_name()]))
end

---Change the selected output item.
---@param player mt.PlayerObjectRef
---@param item_name? string The item name of the output
function set_selected_item(player, item_name)
	player:get_meta():set_string("mcl_stonecutter:selected", item_name and item_name or "")
end

minetest.register_on_joinplayer(function(player)
	local inv = player:get_inventory()

	inv:set_size("stonecutter_input", 1)
	inv:set_size("stonecutter_output", 1)

	set_selected_item(player, nil)

	--The player might have items remaining in the slots from the previous join; this is likely
	--when the server has been shutdown and the server didn't clean up the player inventories.
	mcl_util.move_player_list(player, "stonecutter_input")
	player:get_inventory():set_list("stonecutter_output", {})
end)

minetest.register_on_leaveplayer(function(player)
	set_selected_item(player, nil)

	mcl_util.move_player_list(player, "stonecutter_input")
	player:get_inventory():set_list("stonecutter_output", {})
end)

---Update content of the stonecutter output slot with the input slot and the selected item
---@param player mt.PlayerObjectRef
function update_stonecutter_slots(player)
	local meta = player:get_meta()
	local inv = player:get_inventory()

	local input = inv:get_stack("stonecutter_input", 1)
	local recipes = mcl_stonecutter.registered_recipes[input:get_name()]
	local output_item = meta:get_string("mcl_stonecutter:selected")
	local stack_size = meta:get_int("mcl_stonecutter:switch_stack")

	if recipes then
		if output_item then
			local recipe = recipes[output_item]
			if recipe then
				local cut_item = ItemStack(output_item)
				local count = math.min(math.floor(stack_size/recipe), input:get_count()) * recipe
				if count < recipe then count = recipe end
				cut_item:set_count(count)
				inv:set_stack("stonecutter_output", 1, cut_item)
			else
				inv:set_stack("stonecutter_output", 1, nil)
			end
		else
			inv:set_stack("stonecutter_output", 1, nil)
		end
	else
		inv:set_stack("stonecutter_output", 1, nil)
	end

	mcl_stonecutter.show_stonecutter_form(player)
end

--Drop items in slots and reset selected item on closing
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= formspec_name then return end

	if fields.quit then
		mcl_util.move_player_list(player, "stonecutter_input")
		player:get_inventory():set_list("stonecutter_output", {})
		return
	end

	if fields.__switch_stack then
		local switch = 1
		if get_stack_size(player) == 1 then
			switch = 64
		end
		set_stack_size(player, switch)
		update_stonecutter_slots(player)
		mcl_stonecutter.show_stonecutter_form(player)
		return
	end

	for field_name, value in pairs(fields) do
		if field_name ~= "scroll" then
			local itemname = fieldname_to_itemname(field_name)
			set_selected_item(player, itemname)
			update_stonecutter_slots(player)
			mcl_stonecutter.show_stonecutter_form(player)
			break
		end
	end
end)


minetest.register_allow_player_inventory_action(function(player, action, inventory, inventory_info)
	if action == "move" then
		if inventory_info.to_list == "stonecutter_output" then
			return 0
		end

		if inventory_info.from_list == "stonecutter_output" and inventory_info.to_list == "stonecutter_input" then
			if inventory:get_stack(inventory_info.to_list, inventory_info.to_index):is_empty() then
				return inventory_info.count
			else
				return 0
			end
		end

		if inventory_info.from_list == "stonecutter_output" then
			local selected = player:get_meta():get_string("mcl_stonecutter:selected")
			local istack = inventory:get_stack("stonecutter_input", 1)
			local recipes = mcl_stonecutter.registered_recipes[istack:get_name()]
			if not selected or not recipes then return 0 end
			local recipe = recipes[selected]
			local remainder = inventory_info.count % recipe
			if remainder ~= 0 then
				return 0
			end
		end
	elseif action == "put" then
		if inventory_info.to_list == "stonecutter_output" then
			return 0
		end
		if inventory_info.from_list == "stonecutter_output" then
			local selected = player:get_meta():get_string("mcl_stonecutter:selected")
			local istack = inventory:get_stack("stonecutter_input", 1)
			local recipes = mcl_stonecutter.registered_recipes[istack:get_name()]
			if not selected or not recipes then return 0 end
			local recipe = recipes[selected]
			local remainder = inventory_info.stack:get_count() % recipe
			if remainder ~= 0 then
				return 0
			end
		end
	end
end)

local function remove_from_input(player, inventory, crafted_count)
	local meta = player:get_meta()
	local selected = meta:get_string("mcl_stonecutter:selected")
	local istack = inventory:get_stack("stonecutter_input", 1)
	local recipes = mcl_stonecutter.registered_recipes[istack:get_name()]
	local stack_size = meta:get_int("mcl_stonecutter:switch_stack")

	-- selected should normally never be nil, but just in case
	if selected and recipes then
		local recipe = recipes[selected]
		local count = crafted_count/recipe
		if count < 1 then count = 1 end
		istack:set_count(math.max(0, istack:get_count() - count))
		inventory:set_stack("stonecutter_input", 1, istack)
	end
end

minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
	if action == "move" then
		if inventory_info.to_list == "stonecutter_input" or inventory_info.from_list == "stonecutter_input" then
			update_stonecutter_slots(player)
			return
		elseif inventory_info.from_list == "stonecutter_output" then
			remove_from_input(player, inventory, inventory_info.count)
			update_stonecutter_slots(player)
		end
	elseif action == "put" then
		if inventory_info.listname == "stonecutter_input" or inventory_info.listname == "stonecutter_input" then
			update_stonecutter_slots(player)
		end
	elseif action == "take" then
		if inventory_info.listname == "stonecutter_output" then
			remove_from_input(player, inventory, inventory_info.stack:get_count())
			update_stonecutter_slots(player)
		end
	end
end)

minetest.register_node("mcl_stonecutter:stonecutter", {
	description = S("Stone Cutter"),
	_tt_help = S("Used to cut stone like materials."),
	_doc_items_longdesc = S("Stonecutters are used to create stairs and slabs from stone like materials. It is also the jobsite for the Stone Mason Villager."),
	tiles = {
		"mcl_stonecutter_top.png",
		"mcl_stonecutter_bottom.png",
		"mcl_stonecutter_side.png",
		"mcl_stonecutter_side.png",
		{
			name = "mcl_stonecutter_saw.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1
			}
		},
		{
			name = "mcl_stonecutter_saw.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.15
			}
		}
	},
	use_texture_alpha = "clip",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { pickaxey = 1, material_stone = 1, deco_block = 1 },
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.5,    -0.5,   -0.5, 0.5,    0.0625, 0.5 }, -- NodeBox1
			{ -0.4375, 0.0625, 0,    0.4375, 0.5,    0 }, -- NodeBox2
		}
	},
	_mcl_blast_resistance = 3.5,
	_mcl_hardness = 3.5,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	on_rightclick = function(pos, node, player, itemstack)
		if not player:get_player_control().sneak then
			mcl_stonecutter.show_stonecutter_form(player)
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
