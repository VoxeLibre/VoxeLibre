local S = minetest.get_translator("mcl_barrels")
local F = minetest.formspec_escape
local C = minetest.colorize

--TODO: fix barrel rotation placement

local open_barrels = {}

local drop_content = mcl_util.drop_items_from_meta_container("main")

local function on_blast(pos)
	local node = minetest.get_node(pos)
	drop_content(pos, node)
	minetest.remove_node(pos)
end

local function barrel_open(pos, node, clicker)
	local name = minetest.get_meta(pos):get_string("name")

	if name == "" then
		name = S("Barrel")
	end

	local playername = clicker:get_player_name()

	minetest.show_formspec(playername,
		"mcl_barrels:barrel_"..pos.x.."_"..pos.y.."_"..pos.z,
		table.concat({
			"size[9,8.75]",
			"label[0,0;"..F(C("#313131", name)).."]",
			"list[nodemeta:"..pos.x..","..pos.y..","..pos.z..";main;0,0.5;9,3;]",
			mcl_formspec.get_itemslot_bg(0, 0.5, 9, 3),
			"label[0,4.0;"..F(C("#313131", S("Inventory"))).."]",
			"list[current_player;main;0,4.5;9,3;9]",
			mcl_formspec.get_itemslot_bg(0, 4.5, 9, 3),
			"list[current_player;main;0,7.74;9,1;]",
			mcl_formspec.get_itemslot_bg(0, 7.74, 9, 1),
			"listring[nodemeta:"..pos.x..","..pos.y..","..pos.z..";main]",
			"listring[current_player;main]",
		})
	)

	minetest.swap_node(pos,	{ name = "mcl_barrels:barrel_open", param2 = node.param2 })
	open_barrels[playername] = pos
end

local function close_forms(pos)
	local players = minetest.get_connected_players()
	local formname = "mcl_barrels:barrel_"..pos.x.."_"..pos.y.."_"..pos.z
	for p = 1, #players do
		if vector.distance(players[p]:get_pos(), pos) <= 30 then
			minetest.close_formspec(players[p]:get_player_name(), formname)
		end
	end
end

local function update_after_close(pos)
	local node = minetest.get_node_or_nil(pos)
	if not node then return end
	if node.name == "mcl_barrels:barrel_open" then
		minetest.swap_node(pos, {name = "mcl_barrels:barrel_closed", param2 = node.param2})
	end
end

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
	tiles = {"mcl_barrels_barrel_top.png^[transformR270", "mcl_barrels_barrel_bottom.png", "mcl_barrels_barrel_side.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	--on_place = mcl_util.rotate_axis,
	on_place = function(itemstack, placer, pointed_thing)
		minetest.rotate_and_place(itemstack, placer, pointed_thing, minetest.is_creative_enabled(placer:get_player_name()), {}, false)
		return itemstack
	end,
	stack_max = 64,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	groups = {handy = 1, axey = 1, container = 2, material_wood = 1, flammable = -1, deco_block = 1},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("main", 9*3)
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		minetest.get_meta(pos):set_string("name", itemstack:get_meta():get_string("name"))
	end,
	after_dig_node = drop_content,
	on_blast = on_blast,
	on_rightclick = barrel_open,
	on_destruct = close_forms,
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 2.5,
})

minetest.register_node("mcl_barrels:barrel_open", {
	description = S("Barrel Open"),
	_tt_help = S("27 inventory slots"),
	_doc_items_longdesc = S("Barrels are containers which provide 27 inventory slots."),
	_doc_items_usagehelp = S("To access its inventory, rightclick it. When broken, the items will drop out."),
	_doc_items_create_entry = false,
	tiles = {"mcl_barrels_barrel_top_open.png", "mcl_barrels_barrel_bottom.png", "mcl_barrels_barrel_side.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	drop = "mcl_barrels:barrel_closed",
	stack_max = 64,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	groups = {handy = 1, axey = 1, container = 2, material_wood = 1, flammable = -1, deco_block = 1, not_in_creative_inventory = 1},
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
		{"group:wood", "group:wood_slab", "group:wood"},
		{"group:wood", "",                "group:wood"},
		{"group:wood", "group:wood_slab", "group:wood"},
	}
})