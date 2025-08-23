local S = minetest.get_translator("mcl_barrels")
local F = minetest.formspec_escape
local C = minetest.colorize

--TODO: fix barrel rotation placement

local open_barrels = {}

local drop_content = mcl_util.drop_items_from_meta_container("main")

---@param pos Vector
local function on_blast(pos)
	local node = minetest.get_node(pos)
	drop_content(pos, node)
	minetest.remove_node(pos)
end

-- Simple protection checking functions
local function protection_check_move(pos, from_list, from_index, to_list, to_index, count, player)
	local name = player:get_player_name()
	if minetest.is_protected(pos, name) then
		minetest.record_protection_violation(pos, name)
		return 0
	else
		return count
	end
end

local function protection_check_put_take(pos, listname, index, stack, player)
	local name = player:get_player_name()
	if minetest.is_protected(pos, name) then
		minetest.record_protection_violation(pos, name)
		return 0
	else
		return stack:get_count()
	end
end

local function barrel_open(pos, node, clicker)
	local name = minetest.get_meta(pos):get_string("name")

	if name == "" then
		name = S("Barrel")
	end

	local playername = clicker:get_player_name()

	minetest.show_formspec(playername,
		"mcl_barrels:barrel_" .. pos.x .. "_" .. pos.y .. "_" .. pos.z,
		table.concat({
			"formspec_version[4]",
			"size[11.75,10.425]",

			"label[0.375,0.375;" .. F(C(mcl_formspec.label_color, name)) .. "]",
			mcl_formspec.get_itemslot_bg_v4(0.375, 0.75, 9, 3),
			"list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";main;0.375,0.75;9,3;]",
			"label[0.375,4.7;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]",
			mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
			"list[current_player;main;0.375,5.1;9,3;9]",

			mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
			"list[current_player;main;0.375,9.05;9,1;]",
			"listring[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";main]",
			"listring[current_player;main]",
		})
	)

	minetest.swap_node(pos, { name = "mcl_barrels:barrel_open", param2 = node.param2 })
	open_barrels[playername] = pos
	minetest.sound_play({name="mcl_barrels_default_barrel_open", gain=0.5}, {
		pos = pos,
		max_hear_distance = 16,
	}, true)
end

---@param pos Vector
local function close_forms(pos)
	local players = minetest.get_connected_players()
	local formname = "mcl_barrels:barrel_" .. pos.x .. "_" .. pos.y .. "_" .. pos.z
	for p = 1, #players do
		if vector.distance(players[p]:get_pos(), pos) <= 30 then
			minetest.close_formspec(players[p]:get_player_name(), formname)
		end
	end
end

---@param pos Vector
local function update_after_close(pos)
	local node = minetest.get_node_or_nil(pos)
	if not node then return end
	if node.name == "mcl_barrels:barrel_open" then
		minetest.swap_node(pos, { name = "mcl_barrels:barrel_closed", param2 = node.param2 })
		minetest.sound_play({name="mcl_barrels_default_barrel_close", gain=0.5}, {
			pos = pos,
			max_hear_distance = 16,
		}, true)

	end
end

---@param player ObjectRef
local function close_barrel(player)
	local name = player:get_player_name()
	local open = open_barrels[name]
	if open == nil then
		return
	end

	update_after_close(open)

	open_barrels[name] = nil
end

minetest.register_node("mcl_barrels:barrel_closed", {
	description = S("Barrel"),
	_tt_help = S("27 inventory slots"),
	_doc_items_longdesc = S("Barrels are containers which provide 27 inventory slots."),
	_doc_items_usagehelp = S("To access its inventory, rightclick it. When broken, the items will drop out."),
	tiles = { "mcl_barrels_barrel_top.png^[transformR270", "mcl_barrels_barrel_bottom.png", "mcl_barrels_barrel_side.png" },
	paramtype = "light",
	paramtype2 = "facedir",
	on_place = function(itemstack, placer, pointed_thing)
		minetest.rotate_and_place(itemstack, placer, pointed_thing,
			minetest.is_creative_enabled(placer:get_player_name()), {}
			, false)
		return itemstack
	end,
	stack_max = 64,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	groups = { handy = 1, axey = 1, container = 2, material_wood = 1, flammable = -1, deco_block = 1 },
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("main", 9 * 3)
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		minetest.get_meta(pos):set_string("name", itemstack:get_meta():get_string("name"))
	end,
	allow_metadata_inventory_move = protection_check_move,
	allow_metadata_inventory_take = protection_check_put_take,
	allow_metadata_inventory_put = protection_check_put_take,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff in barrel at " .. minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff to barrel at " .. minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" takes stuff from barrel at " .. minetest.pos_to_string(pos))
	end,
	after_dig_node = drop_content,
	on_blast = on_blast,
	on_rightclick = barrel_open,
	on_destruct = close_forms,
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 2.5,
	_mcl_comparator_get_reading = function(pos)
		local inv = core.get_meta(pos):get_inventory()
		return mcl_comparators.read_inventory(inv, "main")
	end,
})

minetest.register_node("mcl_barrels:barrel_open", {
	description = S("Barrel Open"),
	_tt_help = S("27 inventory slots"),
	_doc_items_longdesc = S("Barrels are containers which provide 27 inventory slots."),
	_doc_items_usagehelp = S("To access its inventory, rightclick it. When broken, the items will drop out."),
	_doc_items_create_entry = false,
	tiles = { "mcl_barrels_barrel_top_open.png", "mcl_barrels_barrel_bottom.png", "mcl_barrels_barrel_side.png" },
	paramtype = "light",
	paramtype2 = "facedir",
	drop = "mcl_barrels:barrel_closed",
	stack_max = 64,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	groups = {
		handy = 1,
		axey = 1,
		container = 2,
		material_wood = 1,
		flammable = -1,
		deco_block = 1,
		not_in_creative_inventory = 1
	},
	allow_metadata_inventory_move = protection_check_move,
	allow_metadata_inventory_take = protection_check_put_take,
	allow_metadata_inventory_put = protection_check_put_take,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff in barrel at " .. minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff to barrel at " .. minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" takes stuff from barrel at " .. minetest.pos_to_string(pos))
	end,
	after_dig_node = drop_content,
	on_blast = on_blast,
	on_rightclick = barrel_open,
	on_destruct = close_forms,
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 2.5,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname:find("mcl_barrels:") == 1 and fields.quit then
		close_barrel(player)
	end
end)

minetest.register_on_leaveplayer(function(player)
	close_barrel(player)
end)

--Minecraft Java Edition craft
minetest.register_craft({
	output = "mcl_barrels:barrel_closed",
	recipe = {
		{ "group:wood", "group:wood_slab", "group:wood" },
		{ "group:wood", "",                "group:wood" },
		{ "group:wood", "group:wood_slab", "group:wood" },
	},
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_barrels:barrel_closed",
	burntime = 15,
})
