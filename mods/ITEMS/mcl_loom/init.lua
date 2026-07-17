local S = minetest.get_translator(minetest.get_current_modname())
local C = minetest.colorize
local F = minetest.formspec_escape

local formspec_name = "mcl_loom:loom"

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

local function form_patterns_table()
	-- Buttons are 3.5 / 4 = 0.875 wide
	local formspec = "style_type[item_image_button;noclip=false;content_offset=0]"
	for i, item in ipairs(pattern_names) do
		local x = ((i - 1) % 4) * 0.875
		local y = (math.floor((i - 1) / 4)) * 0.875

		formspec = formspec ..
			string.format("item_image_button[%f,%f;0.875,0.875;%s;%s;]", x, y,
				"mcl_banners:banner_preview_" .. item .. "_red", item)
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
	tt.reload_itemstack_description(banner)
	return banner
end

local function show_loom_formspec(player)
	local inv = player:get_inventory()

	local banner = inv:get_stack("loom_input", 1)
	local dye = inv:get_stack("loom_input", 2)
	local pattern = inv:get_stack("loom_input", 3)

	local container_content = ""

	if not banner:is_empty() and not dye:is_empty() then
		if not pattern:is_empty() then
			inv:set_stack("loom_output", 1, add_layer(banner, pattern:get_name():split(":")[2]:split("_")[1], dye))
			local item = pattern:get_name():split(":")[2]:split("_")[1]
			container_content = string.format("item_image[0,0;0.875,0.875;%s]", "mcl_banners:banner_preview_" .. item .. "_red")
		else
			container_content = form_patterns_table()
		end
	end

	local output = inv:get_stack("loom_output", 1)
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
		"list[current_player;loom_input;1,1.5;1,1;]",

		-- Dye input slot
		mcl_formspec.get_itemslot_bg_v4(2.25, 1.5, 1, 1),
		dye:is_empty() and mcl_formspec.get_itemslot_bg_v4(2.25, 1.5, 1, 1, 0, "mcl_loom_inventory_dye.png") or "",
		"list[current_player;loom_input;2.25,1.5;1,1;1]",

		-- Pattern input slot
		mcl_formspec.get_itemslot_bg_v4(1.625, 2.75, 1, 1),
		pattern:is_empty() and mcl_formspec.get_itemslot_bg_v4(1.625, 2.75, 1, 1, 0, "mcl_loom_inventory_pattern.png") or
		"",
		"list[current_player;loom_input;1.625,2.75;1,1;2]",

		-- Container background
		"image[4.450,0.7;3.6,3.6;mcl_inventory_background9.png;2]",

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

	tt.reload_itemstack_description(inv:get_stack("loom_output", 1))
	minetest.show_formspec(player:get_player_name(), formspec_name, formspec)
end

minetest.register_on_joinplayer(function(player)
	local inv = player:get_inventory()

	inv:set_size("loom_input", 3)
	inv:set_size("loom_output", 1)

	-- The player might have items remaining in the slots from the previous join; this is likely
	-- when the server has been shutdown and the server didn't clean up the player inventories.
	mcl_util.move_player_list(player, "loom_input")
	inv:set_list("loom_output", {})
end)

minetest.register_on_leaveplayer(function(player)
	mcl_util.move_player_list(player, "loom_input")
	player:get_inventory():set_list("loom_output", {})
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= formspec_name then return end

	local inv = player:get_inventory()
	if fields.quit then
		mcl_util.move_player_list(player, "loom_input")
		inv:set_list("loom_output", {})
		return
	end

	for _, pattern in ipairs(pattern_names) do
		if fields[pattern] then
			inv:set_stack("loom_output", 1,
				add_layer(inv:get_stack("loom_input", 1), pattern, inv:get_stack("loom_input", 2)))
			show_loom_formspec(player)
			return
		end
	end
end)

local function allow_loom_input(index, stack, count)
	local name = stack:get_name()
	if (index == 1 and not name:find("banner_item"))
			or (index == 2 and not name:find("mcl_dye"))
			or (index == 3 and not name:find("pattern")) then
		return 0
	end
	return count
end

minetest.register_allow_player_inventory_action(function(_, action, inventory, inventory_info)
	if action == "move" then
		if inventory_info.to_list == "loom_output" then
			return 0
		end

		if (inventory_info.from_list == "loom_input" or inventory_info.from_list == "loom_output")
				and inventory_info.to_list == "loom_input" then
			return 0
		end

		if inventory_info.to_list == "loom_input" then
			local stack = inventory:get_stack(inventory_info.from_list, inventory_info.from_index)
			return allow_loom_input(inventory_info.to_index, stack, inventory_info.count)
		end
	elseif action == "put" then
		if inventory_info.listname == "loom_output" then
			return 0
		end

		if inventory_info.listname == "loom_input" then
			return allow_loom_input(inventory_info.index, inventory_info.stack,
				inventory_info.stack:get_count())
		end
	end
end)

local function update_loom_slots(player)
	player:get_inventory():set_stack("loom_output", 1, nil)
	show_loom_formspec(player)
end

local function remove_from_loom_inputs(inventory, count)
	local banner = inventory:get_stack("loom_input", 1)
	banner:take_item(count)
	inventory:set_stack("loom_input", 1, banner)

	local dye = inventory:get_stack("loom_input", 2)
	dye:take_item(count)
	inventory:set_stack("loom_input", 2, dye)
end

minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
	if action == "move" then
		if inventory_info.from_list == "loom_output" then
			remove_from_loom_inputs(inventory, inventory_info.count)
			show_loom_formspec(player)
		elseif inventory_info.to_list == "loom_input" or inventory_info.from_list == "loom_input" then
			update_loom_slots(player)
		end
	elseif action == "put" then
		if inventory_info.listname == "loom_input" then
			update_loom_slots(player)
		end
	elseif action == "take" then
		if inventory_info.listname == "loom_output" then
			remove_from_loom_inputs(inventory, inventory_info.stack:get_count())
			show_loom_formspec(player)
		elseif inventory_info.listname == "loom_input" then
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
		if not player:get_player_control().sneak then show_loom_formspec(player) end
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
