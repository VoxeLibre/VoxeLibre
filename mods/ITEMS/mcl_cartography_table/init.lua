local S = minetest.get_translator(minetest.get_current_modname())
local C = minetest.colorize
local F = minetest.formspec_escape

local function refresh_cartography(pos, player)
	local formspec = table.concat({
		"formspec_version[4]",
		"size[11.75,10.425]",
		"label[0.375,0.375;" .. F(C(mcl_formspec.label_color, S("Cartography Table"))) .. "]",

		-- First input slot
		mcl_formspec.get_itemslot_bg_v4(1, 0.75, 1, 1),
		"list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";input;1,0.75;1,1;1]",

		-- Cross icon
		"image[1,2;1,1;mcl_anvils_inventory_cross.png]",

		-- Second input slot
		mcl_formspec.get_itemslot_bg_v4(1, 3.25, 1, 1),
		"list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";input;1,3.25;1,1;]",

		-- Arrow
		"image[2.7,2;2,1;mcl_anvils_inventory_arrow.png]",

		-- Output slot
		mcl_formspec.get_itemslot_bg_v4(9.75, 2, 1, 1, 0.2),
		"list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";output;9.75,2;1,1;]",

		-- Player inventory
		"label[0.375,4.7;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]",
		mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
		"list[current_player;main;0.375,5.1;9,3;9]",

		mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
		"list[current_player;main;0.375,9.05;9,1;]",
	})

	local inv = minetest.get_meta(pos):get_inventory()
	local map = inv:get_stack("input", 2)
	local texture = mcl_maps.load_map_item(map)
	local marker = inv:get_stack("input", 1):get_name()

	if marker == "mcl_maps:empty_map" then
		if texture then
			formspec = formspec .. table.concat({
				"image[6.125,0.5;3,3;mcl_maps_map_background.png]",
				"image[6.375,0.75;2.5,2.5;" .. texture .. "]",
				"image[5.125,1.5;3,3;mcl_maps_map_background.png]",
				"image[5.375,1.75;2.5,2.5;" .. texture .. "]"
			})
		else
			formspec = formspec .. table.concat({
				"image[6.125,0.5;3,3;mcl_maps_map_background.png]",
				"image[5.125,1.5;3,3;mcl_maps_map_background.png]"
			})
		end
		if not map:is_empty() then
			map:set_count(2)
			inv:set_stack("output", 1, map)
		end
	else
		formspec = formspec .. "image[5.125,0.5;4,4;mcl_maps_map_background.png]"
		--formspec = formspec .. "box[5.125,0.5;4,4;#FFFFFF]"
		if texture then formspec = formspec .. "image[5.375,0.75;3.5,3.5;" .. texture .. "]" end
		if marker == "xpanes:pane_natural_flat" and not map:is_empty() then
			if map:get_meta():get_int("locked") == 1 then
				formspec = formspec .. table.concat({
					"image[3.2,2;1,1;mcl_core_barrier.png]",
					"image[8.375,3.75;0.5,0.5;mcl_core_barrier.png]"
				})
			else
				formspec = formspec .. "image[8.375,3.75;0.5,0.5;mcl_core_barrier.png]"
				map:get_meta():set_int("locked", 1)
				inv:set_stack("output", 1, map)
			end
		end
	end

	minetest.show_formspec(player:get_player_name(), "mcl_cartography_table", formspec)
end

local allowed_to_put = {
	--["mcl_core:paper"] = true, Requires missing features with increasing map size
	["mcl_maps:empty_map"] = true,
	["xpanes:pane_natural_flat"] = true
}

minetest.register_node("mcl_cartography_table:cartography_table", {
	description = S("Cartography Table"),
	_tt_help = S("Used to create or copy maps"),
	_doc_items_longdesc = S("Is used to create or copy maps for use."),
	tiles = {
		"mcl_cartography_table_top.png", "mcl_cartography_table_side3.png",
		"mcl_cartography_table_side3.png", "mcl_cartography_table_side2.png",
		"mcl_cartography_table_side3.png", "mcl_cartography_table_side1.png"
	},
	paramtype2 = "facedir",
	groups = { axey = 2, handy = 1, deco_block = 1, material_wood = 1, flammable = 1 },
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 2.5,
	on_construct = function(pos)
		local inv = minetest.get_meta(pos):get_inventory()
		inv:set_size("input", 2)
		inv:set_size("output", 1)
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if minetest.is_protected(pos, player:get_player_name()) or listname == "output" then
			return 0
		else
			if index == 2 and not stack:get_name():find("filled_map") then return 0 end
			if index == 1 and not allowed_to_put[stack:get_name()] then return 0 end
			return stack:get_count()
		end
	end,
	on_metadata_inventory_put = function(pos, _, _, _, player)
		refresh_cartography(pos, player)
	end,
	on_metadata_inventory_take = function(pos, listname, _, _, player)
		local inv = minetest.get_meta(pos):get_inventory()
		if listname == "output" then
			local first = inv:get_stack("input", 2); first:take_item(); inv:set_stack("input", 2, first)
			local second = inv:get_stack("input", 1); second:take_item(); inv:set_stack("input", 1, second)
		else
			inv:set_stack("output", 1, "")
		end
		refresh_cartography(pos, player)
	end,
	allow_metadata_inventory_move = function() return 0 end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		return 0 and minetest.is_protected(pos, player:get_player_name()) or stack:get_count()
	end,
	on_rightclick = function(pos, node, player, itemstack)
		if not player:get_player_control().sneak then refresh_cartography(pos, player) end
	end,
	after_dig_node = function(pos, _, oldmetadata, _)
		local meta = minetest.get_meta(pos)
		local meta2 = meta:to_table()
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		for i = 1, inv:get_size("input") do
			local stack = inv:get_stack("input", i)
			if not stack:is_empty() then
				minetest.add_item(vector.offset(pos,
					math.random(0, 10) / 10 - 0.5,
					0,
					math.random(0, 10) / 10 - 0.5
				), stack)
			end
		end
		meta:from_table(meta2)
	end,
})

minetest.register_craft({
	output = "mcl_cartography_table:cartography_table",
	recipe = {
		{ "mcl_core:paper", "mcl_core:paper", "" },
		{ "group:wood", "group:wood", "" },
		{ "group:wood", "group:wood", "" },
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_cartography_table:cartography_table",
	burntime = 15,
})
