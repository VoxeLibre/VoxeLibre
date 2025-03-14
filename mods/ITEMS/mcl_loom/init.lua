local S = minetest.get_translator(minetest.get_current_modname())
local C = minetest.colorize
local F = minetest.formspec_escape

local FORMSPEC_NAME = "mcl_loom:loom"

mcl_loom = {}

mcl_loom.registered_recipes = {}
mcl_loom.pattern_items = {}

function mcl_loom.register_recipe(def)
	local name = def.name
	if not name then
		error("Name of the pattern must be provided")
	end
	if mcl_loom.registered_recipes[name] then
		error("Pattern named " .. name .. " already registered")
	end
	local pattern = def.pattern_item
	if pattern and not minetest.registered_items[pattern] then
		error("Item used for the pattern is not registered: " .. pattern)
	end

	local pdef = {}
	pdef.count = def.count or 1
	pdef.pattern = pattern
	if pattern then mcl_loom.pattern_items[pattern] = true end

	mcl_loom.registered_recipes[name] = pdef
end

local pattern_names = {
	"border",
	"bricks",
	"circle",
	"cross",
	"curly_border",
	"diagonal_up_left",
	"diagonal_up_right",
	"diagonal_right",
	"diagonal_left",
	"gradient",
	"gradient_up",
	"half_horizontal_bottom",
	"half_horizontal",
	"half_vertical",
	"half_vertical_right",
	"thing",
	"rhombus",
	"small_stripes",
	"square_bottom_left",
	"square_bottom_right",
	"square_top_left",
	"square_top_right",
	"straight_cross",
	"stripe_bottom",
	"stripe_center",
	"stripe_downleft",
	"stripe_downright",
	"stripe_left",
	"stripe_middle",
	"stripe_right",
	"stripe_top",
	"triangle_bottom",
	"triangle_top",
	"triangles_bottom",
	"triangles_top",
}

for _, n in pairs(pattern_names) do
	mcl_loom.register_recipe({
		name = n,
	})
end

local function form_patterns_table()
	-- Buttons are 3.5 / 4 = 0.875 wide
-- 	local formspec = "style_type[item_image_button;noclip=false;content_offset=0]"
	local formspec = ""
	local i = 1
	for item, def in pairs(mcl_loom.registered_recipes) do
		local x = ((i - 1) % 4) * 0.875
		local y = (math.floor((i - 1) / 4)) * 0.875

		formspec = formspec ..
			string.format("item_image_button[%f,%f;0.875,0.875;%s;%s;]", x, y,
				"mcl_banners:banner_preview_" .. item .. "_red", item)
		i = i + 1
	end
	return formspec
end

local dye_to_colorid_mapping = {}
for colorid, colortab in pairs(mcl_banners.colors) do
	dye_to_colorid_mapping[colortab[5]] = colorid
end

local function add_layer(banner, pattern, color)
	local layers = minetest.deserialize(banner:get_meta():get_string("layers")) or {}
	table.insert(layers, { pattern = pattern, color = dye_to_colorid_mapping[color:get_name()] })
	banner:get_meta():set_string("layers", minetest.serialize(layers))
	return banner
end

local function build_loom_form(player)
	local inv = player:get_inventory()
	local selected = player:get_meta():get_string("mcl_loom:selected")

	local banner = inv:get_stack("loom_input", 1)
	local dye = inv:get_stack("loom_input", 2)
	local pattern = inv:get_stack("loom_input", 3)

	local container_content = "style_type[item_image_button;noclip=false;content_offset=0]" ..
		(selected ~= "" and "style[" .. selected .. ";border=false;bgimg=mcl_inventory_button9_pressed.png;bgimg_pressed=mcl_inventory_button9_pressed.png;bgimg_middle=2,2]" or "")

	if not banner:is_empty() and not dye:is_empty() then
		if not pattern:is_empty() then
			inv:set_stack("output", 1, add_layer(banner, pattern:get_name():split(":")[2]:split("_")[1], dye))
			local item = pattern:get_name():split(":")[2]:split("_")[1]
			container_content = container_content ..
				string.format("item_image_button[0,0;0.875,0.875;%s;%s]", "mcl_banners:banner_preview_" .. item .. "_red", item)
		else
			container_content = container_content .. form_patterns_table()
		end
	end

	local output = inv:get_stack("output", 1)
	local preview = mcl_banners.make_banner_texture(mcl_banners.color_reverse(output:get_name()), minetest.deserialize(output:get_meta():get_string("layers")) or {})

	local banner_model = "model[9.55,0.7;1.4,2.3;keeper;amc_banner_hanging.b3d;" ..
	preview .. ";0,-180;false;false;x=0,y=0;0]"

	local formspec = table.concat({
		"formspec_version[4]",
		"size[11.75,10.425]",
		"label[0.375,0.375;" .. F(C(mcl_formspec.label_color, S("Loom"))) .. "]",

		-- PLACEHOLDER: "box[0.375,0.75;3.5,3.5;#222222]",
		"image[0.375,0.75;3.5,3.5;mcl_loom_inventory.png]",

		-- Banner input slot
		mcl_formspec.get_itemslot_bg_v4(1, 1.5, 1, 1),
		banner:is_empty() and mcl_formspec.get_itemslot_bg_v4(1, 1.5, 1, 1, 0, "mcl_loom_inventory_banner.png") or "",
		"list[current_player;loom_input;1,1.5;1,1;0]",

		-- Dye input slot
		mcl_formspec.get_itemslot_bg_v4(2.25, 1.5, 1, 1),
		dye:is_empty() and mcl_formspec.get_itemslot_bg_v4(2.25, 1.5, 1, 1, 0, "mcl_loom_inventory_dye.png") or "",
		"list[current_player;loom_input;2.25,1.5;1,1;1]",

		-- Pattern input slot
		mcl_formspec.get_itemslot_bg_v4(1.625, 2.75, 1, 1),
		pattern:is_empty() and mcl_formspec.get_itemslot_bg_v4(1.625, 2.75, 1, 1, 0, "mcl_loom_inventory_pattern.png") or "",
		"list[current_player;loom_input;1.625,2.75;1,1;2]",

		-- Container background
		"image[4.450,0.7;3.6,3.6;mcl_inventory_background9.png;2]",

		-- Style for item image buttons
		"style_type[item_image_button;noclip=false;content_offset=0]",

		-- Scroll Container with buttons if needed
		"scroll_container[4.5,0.75;3.5,3.5;scroll;vertical;0.875]",
		container_content,
		"scroll_container_end[]",

		-- Scrollbar
		-- TODO: style the scrollbar correctly when possible
		"scrollbaroptions[min=0;max=" ..
		math.max(math.floor(#pattern_names / 4) + 1 - 4, 0) .. ";smallstep=1;largesteps=1]",
		"scrollbar[8,0.7;0.75,3.6;vertical;scroll;0]",

		banner_model,

		-- Output slot
		mcl_formspec.get_itemslot_bg_v4(9.75, 3.1, 1, 1, 0.2),
		"list[current_player;loom_output;9.75,3.1;1,1;]",

		-- Player inventory
		"label[0.375,4.7;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]",
		mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
		"list[current_player;main;0.375,5.1;9,3;9]",

		mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
		"list[current_player;main;0.375,9.05;9,1;]",

		"listring[current_player;loom_output]",
		"listring[current_player;main]",
		"listring[current_player;loom_input]",
		"listring[current_player;main]",
	})

	tt.reload_itemstack_description(inv:get_stack("output", 1))
	return formspec
end

-- Get the player configured stack size when taking items from loom inventory
---@param player mt.PlayerObjectRef
---@return integer
local function get_stack_size(player)
	return player:get_meta():get_int("mcl_loom:switch_stack")
end

-- Set the player configured stack size when taking items from loom inventory
---@param player mt.PlayerObjectRef
---@param n integer
local function set_stack_size(player, n)
	player:get_meta():set_int("mcl_loom :switch_stack", n)
end


---Display loom menu to a player
---@param player mt.PlayerObjectRef
function mcl_loom.show_loom_form(player)
	minetest.show_formspec(player:get_player_name(), FORMSPEC_NAME,
		build_loom_form(player))
end

---Change the selected output item.
---@param player mt.PlayerObjectRef
---@param item_name? string The item name of the output
function set_selected_item(player, item_name)
	player:get_meta():set_string("mcl_loom:selected", item_name and item_name or "")
end

minetest.register_on_joinplayer(function(player)
	local inv = player:get_inventory()

	inv:set_size("loom_input", 3)
	inv:set_size("loom_output", 1)

	set_selected_item(player, nil)

	--The player might have items remaining in the slots from the previous join; this is likely
	--when the server has been shutdown and the server didn't clean up the player inventories.
	mcl_util.move_player_list(player, "loom_input")
	player:get_inventory():set_list("loom_output", {})
end)

minetest.register_on_leaveplayer(function(player)
	mcl_util.move_player_list(player, "loom_input")
	player:get_inventory():set_list("loom_output", {})
end)

-- minetest.register_on_player_receive_fields(function(player, formname, fields)
-- 	if not fields.quit and formname:find("mcl_loom") then
-- 		local p = formname:split(":")[2]:split("_")
-- 		local pos = vector.new(tonumber(p[1]), tonumber(p[2]), tonumber(p[3]))
-- 		local pattern; for k, _ in pairs(fields) do if k ~= "scroll" then pattern = k break end end; if not pattern then return end
-- 		local inv = minetest.get_meta(pos):get_inventory(); if not inv then return end
-- 		inv:set_stack("output", 1, add_layer(inv:get_stack("input", 1), pattern, inv:get_stack("input", 2)))
-- 		show_loom_formspec(pos, player)
-- 	end
-- end)

-- on_construct = function(pos)
-- 		local inv = minetest.get_meta(pos):get_inventory()
-- 		inv:set_size("input", 3)
-- 		inv:set_size("output", 1)
-- 	end,
-- 	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
-- 		if minetest.is_protected(pos, player:get_player_name()) or listname == "output" then
-- 			return 0
-- 		else
-- 			local name = stack:get_name()
-- 			if (index == 1 and not name:find("banner_item")) or (index == 2 and not name:find("mcl_dye")) or (index == 3 and not name:find("pattern")) then return 0 end
-- 			return stack:get_count()
-- 		end
-- 	end,
-- 	on_metadata_inventory_put = function(pos, _, _, _, player)
-- 		local inv = minetest.get_meta(pos):get_inventory()
-- 		if not inv:get_stack("input", 1):is_empty() and not inv:get_stack("input", 2):is_empty() then
-- 			show_loom_formspec(pos, player)
-- 		end
-- 	end,
-- 	on_metadata_inventory_take = function(pos, listname, index, stack, player)
-- 		local inv = minetest.get_meta(pos):get_inventory()
-- 		if listname == "output" then
-- 			local count = stack:get_count()
-- 			local first = inv:get_stack("input", 1); first:take_item(count); inv:set_stack("input", 1, first)
-- 			local second = inv:get_stack("input", 2); second:take_item(count); inv:set_stack("input", 2, second)
-- 		else
-- 			inv:set_stack("output", 1, "")
-- 		end
-- 		show_loom_formspec(pos, player)
-- 	end,
-- 	allow_metadata_inventory_move = function() return 0 end,
-- 	after_dig_node = function(pos, _, oldmetadata, _)
-- 		local meta = minetest.get_meta(pos)
-- 		local meta2 = meta:to_table()
-- 		meta:from_table(oldmetadata)
-- 		local inv = meta:get_inventory()
-- 		for i = 1, inv:get_size("input") do
-- 			local stack = inv:get_stack("input", i)
-- 			if not stack:is_empty() then
-- 				minetest.add_item(vector.offset(pos,
-- 					math.random(0, 10) / 10 - 0.5,
-- 					0,
-- 					math.random(0, 10) / 10 - 0.5
-- 				), stack)
-- 			end
-- 		end
-- 		meta:from_table(meta2)
-- 	end,

---Update content of the loom output slot with the input slots and the selected pattern
---@param player mt.PlayerObjectRef
function update_loom_slots(player)
	local meta = player:get_meta()
	local inv = player:get_inventory()

	local input = inv:get_stack("loom_input", 1)
	local selected = meta:get_string("mcl_loom:selected")
	local recipe = mcl_loom.registered_recipes[selected]
	local stack_size = meta:get_int("mcl_loom:switch_stack")
	minetest.chat_send_all(selected)

	if recipe then
		local woven_item = ItemStack(output_item)
		local count = math.min(math.floor(stack_size/recipe.count), input:get_count()) * recipe.count
		if count < recipe.count then count = recipe.count end
		woven_item:set_count(count)
		minetest.chat_send_all(woven_item:get_name())
		inv:set_stack("loom_output", 1, woven_item)
	else
		inv:set_stack("loom_output", 1, nil)
	end

	mcl_loom.show_loom_form(player)
end

--Drop items in slots and reset selected item on closing
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= FORMSPEC_NAME then return end

	if fields.quit then
		mcl_util.move_player_list(player, "loom_input")
		player:get_inventory():set_list("loom_output", {})
		return
	end

-- 	if fields.__switch_stack then
-- 		local switch = 1
-- 		if get_stack_size(player) == 1 then
-- 			switch = 64
-- 		end
-- 		set_stack_size(player, switch)
-- 		update_loom_slots(player)
-- 		mcl_loom.show_loom_form(player)
-- 		return
-- 	end

	for field_name, value in pairs(fields) do
		if field_name ~= "scroll" then
			local itemname = field_name
			player:get_meta():set_string("mcl_loom:selected", itemname)
			set_selected_item(player, itemname)
			update_loom_slots(player)
			mcl_loom.show_loom_form(player)
			break
		end
	end
end)

minetest.register_allow_player_inventory_action(function(player, action, inventory, inventory_info)
	if action == "move" then
		if inventory_info.to_list == "loom_output" then
			return 0
		end

		if inventory_info.to_list == "loom_input" and inventory_info.to_index == 3 then
			local item_name = inventory:get_stack(inventory_info.from_list, inventory_info.from_index):get_name()
			if mcl_loom.pattern_items[item_name] then
				return inventory_info.count
			else
				return 0
			end
		end

		if inventory_info.from_list == "loom_output" and inventory_info.to_list == "loom_input" then
			if inventory:get_stack(inventory_info.to_list, inventory_info.to_index):is_empty() then
				return inventory_info.count
			else
				return 0
			end
		end

		if inventory_info.from_list == "loom_output" then
			local selected = player:get_meta():get_string("mcl_loom:selected")
			local recipe = mcl_loom.registered_recipes[selected]
			local pattern = inventory:get_stack("loom_input", 3)
			if pattern:is_empty() and recipe.pattern
				or pattern:get_name() ~= recipe.pattern then
					return 0
			end
		end

	elseif action == "put" then
		if inventory_info.listname == "loom_output" then
			return 0
		end
		if inventory_info.listname == "loom_input" and inventory_info.index == 3 then
			local item_name = inventory_info.stack:get_name()
			if mcl_loom.pattern_items[item_name] then
				return inventory_info.count
			else
				return 0
			end
		end
	elseif action == "take" then
		if inventory_info.listname == "loom_output" then
			local selected = player:get_meta():get_string("mcl_loom:selected")
			local recipe = mcl_loom.registered_recipes[selected]
			local pattern = inventory:get_stack("loom_input", 3)
			if pattern:is_empty() and recipe.pattern
				or pattern:get_name() ~= recipe.pattern then
					return 0
			end
		end
	end
end)

local function remove_from_input(player, inventory, crafted_count)
	local meta = player:get_meta()
	local selected = meta:get_string("mcl_loom:selected")

	-- selected should normally never be nil, but just in case
	if selected then
		local recipe = mcl_loom.registered_recipes[selected]
		local pattern = inventory:get_stack("loom_input", 3)
		if pattern:is_empty() and not recipe.pattern
			or pattern:get_name() == recipe.pattern then
				local istack = inventory:get_stack("loom_input", 1)
				local dye = inventory:get_stack("loom_input", 2)
				istack:set_count(math.max(0, istack:get_count() - count))
				dye:set_count(math.max(0, dye:get_count() - count))
				inventory:set_stack("loom_input", 1, istack)
				inventory:set_stack("loom_input", 2, dye)
		end
	end
end

minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
	if action == "move" then
		if inventory_info.to_list == "loom_input" or inventory_info.from_list == "loom_input" then
			update_loom_slots(player)
			return
		elseif inventory_info.from_list == "loom_output" then
			remove_from_input(player, inventory, inventory_info.count)
			update_loom_slots(player)
		end
	elseif action == "put" then
		if inventory_info.listname == "loom_input" or inventory_info.listname == "loom_input" then
			update_loom_slots(player)
		end
	elseif action == "take" then
		if inventory_info.listname == "loom_output" then
			remove_from_input(player, inventory, inventory_info.stack:get_count())
			update_loom_slots(player)
		end
	end
end)

minetest.register_node("mcl_loom:loom", {
	description = S("Loom"),
	_tt_help = S("Used to create banner designs"),
	_doc_items_longdesc = S("This is the shepherd villager's work station. It is used to create banner designs."),
	tiles = {
		"loom_top.png", "loom_bottom.png",
		"loom_side.png", "loom_side.png",
		"loom_side.png", "loom_front.png"
	},
	paramtype2 = "facedir",
	groups = { axey = 2, handy = 1, deco_block = 1, material_wood = 1, flammable = 1 },
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 2.5,

	on_rightclick = function(pos, node, player, itemstack)
		if not player:get_player_control().sneak then
			mcl_loom.show_loom_form(player)
		end
	end,
})

minetest.register_craft({
	output = "mcl_loom:loom",
	recipe = {
		{ "",                    "",                    "" },
		{ "mcl_mobitems:string", "mcl_mobitems:string", "" },
		{ "group:wood",          "group:wood",          "" },
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_loom:loom",
	burntime = 15,
})
