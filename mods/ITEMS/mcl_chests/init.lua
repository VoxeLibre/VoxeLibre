local S = minetest.get_translator("mcl_chests")
local mod_doc = minetest.get_modpath("doc")

local no_rotate, simple_rotate
if minetest.get_modpath("screwdriver") then
	no_rotate = screwdriver.disallow
	simple_rotate = screwdriver.rotate_simple
end

--[[ List of open chests.
Key: Player name
Value:
    If player is using a chest: { pos = <chest node position> }
    Otherwise: nil ]]
local open_chests = {}
-- To be called if a player opened a chest
local player_chest_open = function(player, pos)
	open_chests[player:get_player_name()] = { pos = pos }
end

-- Simple protection checking functions
local protection_check_move = function(pos, from_list, from_index, to_list, to_index, count, player)
	local name = player:get_player_name()
	if minetest.is_protected(pos, name) then
		minetest.record_protection_violation(pos, name)
		return 0
	else
		return count
	end
end
local protection_check_put_take = function(pos, listname, index, stack, player)
	local name = player:get_player_name()
	if minetest.is_protected(pos, name) then
		minetest.record_protection_violation(pos, name)
		return 0
	else
		return stack:get_count()
	end
end

local trapped_chest_mesecons_rules = mesecon.rules.pplate

-- To be called when a chest is closed (only relevant for trapped chest atm)
local chest_update_after_close = function(pos)
	local node = minetest.get_node(pos)

	if node.name == "mcl_chests:trapped_chest_on" then
		minetest.swap_node(pos, {name="mcl_chests:trapped_chest", param2 = node.param2})
		mesecon.receptor_off(pos, trapped_chest_mesecons_rules)
	elseif node.name == "mcl_chests:trapped_chest_on_left" then
		minetest.swap_node(pos, {name="mcl_chests:trapped_chest_left", param2 = node.param2})
		mesecon.receptor_off(pos, trapped_chest_mesecons_rules)

		local pos_other = mcl_util.get_double_container_neighbor_pos(pos, node.param2, "left")
		minetest.swap_node(pos_other, {name="mcl_chests:trapped_chest_right", param2 = node.param2})
		mesecon.receptor_off(pos_other, trapped_chest_mesecons_rules)
	elseif node.name == "mcl_chests:trapped_chest_on_right" then
		minetest.swap_node(pos, {name="mcl_chests:trapped_chest_right", param2 = node.param2})
		mesecon.receptor_off(pos, trapped_chest_mesecons_rules)

		local pos_other = mcl_util.get_double_container_neighbor_pos(pos, node.param2, "right")
		minetest.swap_node(pos_other, {name="mcl_chests:trapped_chest_left", param2 = node.param2})
		mesecon.receptor_off(pos_other, trapped_chest_mesecons_rules)
	end
end

-- To be called if a player closed a chest
local player_chest_close = function(player)
	local name = player:get_player_name()
	if open_chests[name] == nil then
		return
	end
	local pos = open_chests[name].pos
	chest_update_after_close(pos)

	open_chests[name] = nil
end

-- This is a helper function to register both chests and trapped chests. Trapped chests will make use of the additional parameters
local register_chest = function(basename, desc, longdesc, usagehelp, tt_help, tiles_table, hidden, mesecons, on_rightclick_addendum, on_rightclick_addendum_left, on_rightclick_addendum_right, drop, canonical_basename)
-- START OF register_chest FUNCTION BODY
if not drop then
	drop = "mcl_chests:"..basename
else
	drop = "mcl_chests:"..drop
end
-- The basename of the "canonical" version of the node, if set (e.g.: trapped_chest_on → trapped_chest).
-- Used to get a shared formspec ID and to swap the node back to the canonical version in on_construct.
if not canonical_basename then
	canonical_basename = basename
end

local double_chest_add_item = function(top_inv, bottom_inv, listname, stack)
	if not stack or stack:is_empty() then
		return
	end

	local name = stack:get_name()

	local top_off = function(inv, stack)
		for c, chest_stack in ipairs(inv:get_list(listname)) do
			if stack:is_empty() then
				break
			end

			if chest_stack:get_name() == name and chest_stack:get_free_space() > 0 then
				stack = chest_stack:add_item(stack)
				inv:set_stack(listname, c, chest_stack)
			end
		end

		return stack
	end

	stack = top_off(top_inv, stack)
	stack = top_off(bottom_inv, stack)

	if not stack:is_empty() then
		stack = top_inv:add_item(listname, stack)
		if not stack:is_empty() then
			bottom_inv:add_item(listname, stack)
		end
	end
end

local drop_items_chest = function(pos, oldnode, oldmetadata)
	local meta = minetest.get_meta(pos)
	local meta2 = meta
	if oldmetadata then
		meta:from_table(oldmetadata)
	end
	local inv = meta:get_inventory()
	for i=1,inv:get_size("main") do
		local stack = inv:get_stack("main", i)
		if not stack:is_empty() then
			local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
			minetest.add_item(p, stack)
		end
	end
	meta:from_table(meta2:to_table())
end

local on_chest_blast = function(pos)
	local node = minetest.get_node(pos)
	drop_items_chest(pos, node)
	minetest.remove_node(pos)
end

minetest.register_node("mcl_chests:"..basename, {
	description = desc,
	_tt_help = tt_help,
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usagehelp,
	_doc_items_hidden = hidden,
	tiles = tiles_table.small,
	paramtype = "light",
	paramtype2 = "facedir",
	stack_max = 64,
	drop = drop,
	groups = {handy=1,axey=1, container=2, deco_block=1, material_wood=1,flammable=-1},
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_construct = function(pos)
		local param2 = minetest.get_node(pos).param2
		local meta = minetest.get_meta(pos)
		--[[ This is a workaround for Minetest issue 5894
		<https://github.com/minetest/minetest/issues/5894>.
		Apparently if we don't do this, large chests initially don't work when
		placed at chunk borders, and some chests randomly don't work after
		placing. ]]
		-- FIXME: Remove this workaround when the bug has been fixed.
		-- BEGIN OF WORKAROUND --
		meta:set_string("workaround", "ignore_me")
		meta:set_string("workaround", nil) -- Done to keep metadata clean
		-- END OF WORKAROUND --
		local inv = meta:get_inventory()
		inv:set_size("main", 9*3)
		--[[ The "input" list is *another* workaround (hahahaha!) around the fact that Minetest
		does not support listrings to put items into an alternative list if the first one
		happens to be full. See <https://github.com/minetest/minetest/issues/5343>.
		This list is a hidden input-only list and immediately puts items into the appropriate chest.
		It is only used for listrings and hoppers. This workaround is not that bad because it only
		requires a simple “inventory allows” check for large chests.]]
		-- FIXME: Refactor the listrings as soon Minetest supports alternative listrings
		-- BEGIN OF LISTRING WORKAROUND
		inv:set_size("input", 1)
		-- END OF LISTRING WORKAROUND
		if minetest.get_node(mcl_util.get_double_container_neighbor_pos(pos, param2, "right")).name == "mcl_chests:"..canonical_basename then
			minetest.swap_node(pos, {name="mcl_chests:"..canonical_basename.."_right",param2=param2})
			local p = mcl_util.get_double_container_neighbor_pos(pos, param2, "right")
			minetest.swap_node(p, { name = "mcl_chests:"..canonical_basename.."_left", param2 = param2 })
		elseif minetest.get_node(mcl_util.get_double_container_neighbor_pos(pos, param2, "left")).name == "mcl_chests:"..canonical_basename then
			minetest.swap_node(pos, {name="mcl_chests:"..canonical_basename.."_left",param2=param2})
			local p = mcl_util.get_double_container_neighbor_pos(pos, param2, "left")
			minetest.swap_node(p, { name = "mcl_chests:"..canonical_basename.."_right", param2 = param2 })
		else
			minetest.swap_node(pos, { name = "mcl_chests:"..canonical_basename, param2 = param2 })
		end
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		minetest.get_meta(pos):set_string("name", itemstack:get_meta():get_string("name"))
	end,
	after_dig_node = drop_items_chest,
	on_blast = on_chest_blast,
	allow_metadata_inventory_move = protection_check_move,
	allow_metadata_inventory_take = protection_check_put_take,
	allow_metadata_inventory_put = protection_check_put_take,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in chest at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to chest at "..minetest.pos_to_string(pos))
		-- BEGIN OF LISTRING WORKAROUND
		if listname == "input" then
			local inv = minetest.get_inventory({type="node", pos=pos})
			inv:add_item("main", stack)
		end
		-- END OF LISTRING WORKAROUND
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from chest at "..minetest.pos_to_string(pos))
	end,
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 2.5,

	on_rightclick = function(pos, node, clicker)
		if minetest.registered_nodes[minetest.get_node({x = pos.x, y = pos.y + 1, z = pos.z}).name].groups.opaque == 1 then
			-- won't open if there is no space from the top
			return false
		end
		local name = minetest.get_meta(pos):get_string("name")
		if name == "" then
			name = S("Chest")
		end

		minetest.show_formspec(clicker:get_player_name(),
		"mcl_chests:"..canonical_basename.."_"..pos.x.."_"..pos.y.."_"..pos.z,
		"size[9,8.75]"..
		"label[0,0;"..minetest.formspec_escape(minetest.colorize("#313131", name)).."]"..
		"list[nodemeta:"..pos.x..","..pos.y..","..pos.z..";main;0,0.5;9,3;]"..
		mcl_formspec.get_itemslot_bg(0,0.5,9,3)..
		"label[0,4.0;"..minetest.formspec_escape(minetest.colorize("#313131", S("Inventory"))).."]"..
		"list[current_player;main;0,4.5;9,3;9]"..
		mcl_formspec.get_itemslot_bg(0,4.5,9,3)..
		"list[current_player;main;0,7.74;9,1;]"..
		mcl_formspec.get_itemslot_bg(0,7.74,9,1)..
		"listring[nodemeta:"..pos.x..","..pos.y..","..pos.z..";main]"..
		"listring[current_player;main]")

		if on_rightclick_addendum then
			on_rightclick_addendum(pos, node, clicker)
		end
	end,

	on_destruct = function(pos)
		local players = minetest.get_connected_players()
		for p=1, #players do
			minetest.close_formspec(players[p]:get_player_name(), "mcl_chests:"..canonical_basename.."_"..pos.x.."_"..pos.y.."_"..pos.z)
		end
	end,
	mesecons = mesecons,
	on_rotate = simple_rotate,
})

minetest.register_node("mcl_chests:"..basename.."_left", {
	tiles = tiles_table.left,
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {handy=1,axey=1, container=5,not_in_creative_inventory=1, material_wood=1,flammable=-1},
	drop = drop,
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_construct = function(pos)
		local n = minetest.get_node(pos)
		local param2 = n.param2
		local p = mcl_util.get_double_container_neighbor_pos(pos, param2, "left")
		if not p or minetest.get_node(p).name ~= "mcl_chests:"..canonical_basename.."_right" then
			n.name = "mcl_chests:"..canonical_basename
			minetest.swap_node(pos, n)
		end
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		minetest.get_meta(pos):set_string("name", itemstack:get_meta():get_string("name"))
	end,
	on_destruct = function(pos)
		local n = minetest.get_node(pos)
		if n.name == "mcl_chests:"..basename then
			return
		end

		local players = minetest.get_connected_players()
		for p=1, #players do
			minetest.close_formspec(players[p]:get_player_name(), "mcl_chests:"..canonical_basename.."_"..pos.x.."_"..pos.y.."_"..pos.z)
		end

		local param2 = n.param2
		local p = mcl_util.get_double_container_neighbor_pos(pos, param2, "left")
		if not p or minetest.get_node(p).name ~= "mcl_chests:"..basename.."_right" then
			return
		end
		for pl=1, #players do
			minetest.close_formspec(players[pl]:get_player_name(), "mcl_chests:"..canonical_basename.."_"..p.x.."_"..p.y.."_"..p.z)
		end
		minetest.swap_node(p, { name = "mcl_chests:"..basename, param2 = param2 })
	end,
	after_dig_node = drop_items_chest,
	on_blast = on_chest_blast,
	allow_metadata_inventory_move = protection_check_move,
	allow_metadata_inventory_take = protection_check_put_take,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		-- BEGIN OF LISTRING WORKAROUND
		elseif listname == "input" then
			local inv = minetest.get_inventory({type="node", pos=pos})
			if inv:room_for_item("main", stack) then
				return -1
			else
				local other_pos = mcl_util.get_double_container_neighbor_pos(pos, minetest.get_node(pos).param2, "left")
				local other_inv = minetest.get_inventory({type="node", pos=other_pos})
				if other_inv:room_for_item("main", stack) then
					return -1
				else
					return 0
				end
			end
		-- END OF LISTRING WORKAROUND
		else
			return stack:get_count()
		end
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in chest at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to chest at "..minetest.pos_to_string(pos))
		-- BEGIN OF LISTRING WORKAROUND
		if listname == "input" then
			local inv = minetest.get_inventory({type="node", pos=pos})
			local other_pos = mcl_util.get_double_container_neighbor_pos(pos, minetest.get_node(pos).param2, "left")
			local other_inv = minetest.get_inventory({type="node", pos=other_pos})

			double_chest_add_item(inv, other_inv, "main", stack)
		end
		-- END OF LISTRING WORKAROUND
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from chest at "..minetest.pos_to_string(pos))
	end,
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 2.5,

	on_rightclick = function(pos, node, clicker)
		local pos_other = mcl_util.get_double_container_neighbor_pos(pos, node.param2, "left")
		if minetest.registered_nodes[minetest.get_node({x = pos.x, y = pos.y + 1, z = pos.z}).name].groups.opaque == 1
			or minetest.registered_nodes[minetest.get_node({x = pos_other.x, y = pos_other.y + 1, z = pos_other.z}).name].groups.opaque == 1 then
				-- won't open if there is no space from the top
				return false
		end

		local name = minetest.get_meta(pos):get_string("name")
		if name == "" then
			name = minetest.get_meta(pos_other):get_string("name")
		end
		if name == "" then
			name = S("Large Chest")
		end

		minetest.show_formspec(clicker:get_player_name(),
		"mcl_chests:"..canonical_basename.."_"..pos.x.."_"..pos.y.."_"..pos.z,
		"size[9,11.5]"..
		"label[0,0;"..minetest.formspec_escape(minetest.colorize("#313131", name)).."]"..
		"list[nodemeta:"..pos.x..","..pos.y..","..pos.z..";main;0,0.5;9,3;]"..
		mcl_formspec.get_itemslot_bg(0,0.5,9,3)..
		"list[nodemeta:"..pos_other.x..","..pos_other.y..","..pos_other.z..";main;0,3.5;9,3;]"..
		mcl_formspec.get_itemslot_bg(0,3.5,9,3)..
		"label[0,7;"..minetest.formspec_escape(minetest.colorize("#313131", S("Inventory"))).."]"..
		"list[current_player;main;0,7.5;9,3;9]"..
		mcl_formspec.get_itemslot_bg(0,7.5,9,3)..
		"list[current_player;main;0,10.75;9,1;]"..
		mcl_formspec.get_itemslot_bg(0,10.75,9,1)..
		-- BEGIN OF LISTRING WORKAROUND
		"listring[current_player;main]"..
		"listring[nodemeta:"..pos.x..","..pos.y..","..pos.z..";input]"..
		-- END OF LISTRING WORKAROUND
		"listring[current_player;main]"..
		"listring[nodemeta:"..pos.x..","..pos.y..","..pos.z..";main]"..
		"listring[current_player;main]"..
		"listring[nodemeta:"..pos_other.x..","..pos_other.y..","..pos_other.z..";main]")

		if on_rightclick_addendum_left then
			on_rightclick_addendum_left(pos, node, clicker)
		end
	end,
	mesecons = mesecons,
	on_rotate = no_rotate,
})

minetest.register_node("mcl_chests:"..basename.."_right", {
	tiles = tiles_table.right,
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {handy=1,axey=1, container=6,not_in_creative_inventory=1, material_wood=1,flammable=-1},
	drop = drop,
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_construct = function(pos)
		local n = minetest.get_node(pos)
		local param2 = n.param2
		local p = mcl_util.get_double_container_neighbor_pos(pos, param2, "right")
		if not p or minetest.get_node(p).name ~= "mcl_chests:"..canonical_basename.."_left" then
			n.name = "mcl_chests:"..canonical_basename
			minetest.swap_node(pos, n)
		end
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		minetest.get_meta(pos):set_string("name", itemstack:get_meta():get_string("name"))
	end,
	on_destruct = function(pos)
		local n = minetest.get_node(pos)
		if n.name == "mcl_chests:"..basename then
			return
		end

		local players = minetest.get_connected_players()
		for p=1, #players do
			minetest.close_formspec(players[p]:get_player_name(), "mcl_chests:"..canonical_basename.."_"..pos.x.."_"..pos.y.."_"..pos.z)
		end

		local param2 = n.param2
		local p = mcl_util.get_double_container_neighbor_pos(pos, param2, "right")
		if not p or minetest.get_node(p).name ~= "mcl_chests:"..basename.."_left" then
			return
		end
		for pl=1, #players do
			minetest.close_formspec(players[pl]:get_player_name(), "mcl_chests:"..canonical_basename.."_"..p.x.."_"..p.y.."_"..p.z)
		end
		minetest.swap_node(p, { name = "mcl_chests:"..basename, param2 = param2 })
		local meta = minetest.get_meta(pos)
	end,
	after_dig_node = drop_items_chest,
	on_blast = on_chest_blast,
	allow_metadata_inventory_move = protection_check_move,
	allow_metadata_inventory_take = protection_check_put_take,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		-- BEGIN OF LISTRING WORKAROUND
		elseif listname == "input" then
			local other_pos = mcl_util.get_double_container_neighbor_pos(pos, minetest.get_node(pos).param2, "right")
			local other_inv = minetest.get_inventory({type="node", pos=other_pos})
			if other_inv:room_for_item("main", stack) then
				return -1
			else
				local inv = minetest.get_inventory({type="node", pos=pos})
				if inv:room_for_item("main", stack) then
					return -1
				else
					return 0
				end
			end
		-- END OF LISTRING WORKAROUND
		else
			return stack:get_count()
		end
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in chest at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to chest at "..minetest.pos_to_string(pos))
		-- BEGIN OF LISTRING WORKAROUND
		if listname == "input" then
			local other_pos = mcl_util.get_double_container_neighbor_pos(pos, minetest.get_node(pos).param2, "right")
			local other_inv = minetest.get_inventory({type="node", pos=other_pos})
			local inv = minetest.get_inventory({type="node", pos=pos})

			double_chest_add_item(other_inv, inv, "main", stack)
		end
		-- END OF LISTRING WORKAROUND
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from chest at "..minetest.pos_to_string(pos))
	end,
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 2.5,

	on_rightclick = function(pos, node, clicker)
		local pos_other = mcl_util.get_double_container_neighbor_pos(pos, node.param2, "right")
		if minetest.registered_nodes[minetest.get_node({x = pos.x, y = pos.y + 1, z = pos.z}).name].groups.opaque == 1
			or minetest.registered_nodes[minetest.get_node({x = pos_other.x, y = pos_other.y + 1, z = pos_other.z}).name].groups.opaque == 1 then
				-- won't open if there is no space from the top
				return false
		end

		local name = minetest.get_meta(pos_other):get_string("name")
		if name == "" then
			name = minetest.get_meta(pos):get_string("name")
		end
		if name == "" then
			name = S("Large Chest")
		end

		minetest.show_formspec(clicker:get_player_name(),
		"mcl_chests:"..canonical_basename.."_"..pos.x.."_"..pos.y.."_"..pos.z,

		"size[9,11.5]"..
		"label[0,0;"..minetest.formspec_escape(minetest.colorize("#313131", name)).."]"..
		"list[nodemeta:"..pos_other.x..","..pos_other.y..","..pos_other.z..";main;0,0.5;9,3;]"..
		mcl_formspec.get_itemslot_bg(0,0.5,9,3)..
		"list[nodemeta:"..pos.x..","..pos.y..","..pos.z..";main;0,3.5;9,3;]"..
		mcl_formspec.get_itemslot_bg(0,3.5,9,3)..
		"label[0,7;"..minetest.formspec_escape(minetest.colorize("#313131", S("Inventory"))).."]"..
		"list[current_player;main;0,7.5;9,3;9]"..
		mcl_formspec.get_itemslot_bg(0,7.5,9,3)..
		"list[current_player;main;0,10.75;9,1;]"..
		mcl_formspec.get_itemslot_bg(0,10.75,9,1)..
		-- BEGIN OF LISTRING WORKAROUND
		"listring[current_player;main]"..
		"listring[nodemeta:"..pos.x..","..pos.y..","..pos.z..";input]"..
		-- END OF LISTRING WORKAROUND
		"listring[current_player;main]"..
		"listring[nodemeta:"..pos_other.x..","..pos_other.y..","..pos_other.z..";main]"..
		"listring[current_player;main]"..
		"listring[nodemeta:"..pos.x..","..pos.y..","..pos.z..";main]")

		if on_rightclick_addendum_right then
			on_rightclick_addendum_right(pos, node, clicker)
		end
	end,
	mesecons = mesecons,
	on_rotate = no_rotate,
})

if mod_doc then
	doc.add_entry_alias("nodes", "mcl_chests:"..basename, "nodes", "mcl_chests:"..basename.."_left")
	doc.add_entry_alias("nodes", "mcl_chests:"..basename, "nodes", "mcl_chests:"..basename.."_right")
end

-- END OF register_chest FUNCTION BODY
end

local chestusage = S("To access its inventory, rightclick it. When broken, the items will drop out.")

register_chest("chest",
	S("Chest"),
	S("Chests are containers which provide 27 inventory slots. Chests can be turned into large chests with double the capacity by placing two chests next to each other."),
	chestusage,
	S("27 inventory slots") .. "\n" .. S("Can be combined to a large chest"),
	{
		small = {"default_chest_top.png", "mcl_chests_chest_bottom.png",
		"mcl_chests_chest_right.png", "mcl_chests_chest_left.png",
		"mcl_chests_chest_back.png", "default_chest_front.png"},
		left = {"default_chest_top_big.png", "default_chest_top_big.png",
		"mcl_chests_chest_right.png", "mcl_chests_chest_left.png",
		"default_chest_side_big.png^[transformFX", "default_chest_front_big.png"},
		right = {"default_chest_top_big.png^[transformFX", "default_chest_top_big.png^[transformFX",
		"mcl_chests_chest_right.png", "mcl_chests_chest_left.png",
		"default_chest_side_big.png", "default_chest_front_big.png^[transformFX"},
	},
	false
)

local traptiles = {
	small = {"mcl_chests_chest_trapped_top.png", "mcl_chests_chest_trapped_bottom.png",
	"mcl_chests_chest_trapped_right.png", "mcl_chests_chest_trapped_left.png",
	"mcl_chests_chest_trapped_back.png", "mcl_chests_chest_trapped_front.png"},
	left = {"mcl_chests_chest_trapped_top_big.png", "mcl_chests_chest_trapped_top_big.png",
	"mcl_chests_chest_trapped_right.png", "mcl_chests_chest_trapped_left.png",
	"mcl_chests_chest_trapped_side_big.png^[transformFX", "mcl_chests_chest_trapped_front_big.png"},
	right = {"mcl_chests_chest_trapped_top_big.png^[transformFX", "mcl_chests_chest_trapped_top_big.png^[transformFX",
	"mcl_chests_chest_trapped_right.png", "mcl_chests_chest_trapped_left.png",
	"mcl_chests_chest_trapped_side_big.png", "mcl_chests_chest_trapped_front_big.png^[transformFX"},
}

register_chest("trapped_chest",
	S("Trapped Chest"),
	S("A trapped chest is a container which provides 27 inventory slots. When it is opened, it sends a redstone signal to its adjacent blocks as long it stays open. Trapped chests can be turned into large trapped chests with double the capacity by placing two trapped chests next to each other."),
	chestusage,
	S("27 inventory slots") .. "\n" .. S("Can be combined to a large chest") .. "\n" .. S("Emits a redstone signal when opened"),
	traptiles,
	nil,
	{receptor = {
		state = mesecon.state.off,
		rules = trapped_chest_mesecons_rules,
	}},
	function(pos, node, clicker)
		minetest.swap_node(pos, {name="mcl_chests:trapped_chest_on", param2 = node.param2})
		mesecon.receptor_on(pos, trapped_chest_mesecons_rules)
		player_chest_open(clicker, pos)
	end,
	function(pos, node, clicker)
		local meta = minetest.get_meta(pos)
		meta:set_int("players", 1)

		minetest.swap_node(pos, {name="mcl_chests:trapped_chest_on_left", param2 = node.param2})
		mesecon.receptor_on(pos, trapped_chest_mesecons_rules)

		local pos_other = mcl_util.get_double_container_neighbor_pos(pos, node.param2, "left")
		minetest.swap_node(pos_other, {name="mcl_chests:trapped_chest_on_right", param2 = node.param2})
		mesecon.receptor_on(pos_other, trapped_chest_mesecons_rules)

		player_chest_open(clicker, pos)
	end,
	function(pos, node, clicker)
		local pos_other = mcl_util.get_double_container_neighbor_pos(pos, node.param2, "right")

		minetest.swap_node(pos, {name="mcl_chests:trapped_chest_on_right", param2 = node.param2})
		mesecon.receptor_on(pos, trapped_chest_mesecons_rules)

		minetest.swap_node(pos_other, {name="mcl_chests:trapped_chest_on_left", param2 = node.param2})
		mesecon.receptor_on(pos_other, trapped_chest_mesecons_rules)

		player_chest_open(clicker, pos)
	end
)

register_chest("trapped_chest_on",
	nil, nil, nil, nil, traptiles, true,
	{receptor = {
		state = mesecon.state.on,
		rules = trapped_chest_mesecons_rules,
	}},
	function(pos, node, clicker)
		player_chest_open(clicker, pos)
	end,
	function(pos, node, clicker)
		player_chest_open(clicker, pos)
	end,
	function(pos, node, clicker)
		player_chest_open(clicker, pos)
	end,
	"trapped_chest",
	"trapped_chest"
)

local function close_if_trapped_chest(pos, player)
	local node = minetest.get_node(pos)

	if node.name == "mcl_chests:trapped_chest_on" then
		minetest.swap_node(pos, {name="mcl_chests:trapped_chest", param2 = node.param2})
		mesecon.receptor_off(pos, trapped_chest_mesecons_rules)

		player_chest_close(player)
	elseif node.name == "mcl_chests:trapped_chest_on_left" then
		minetest.swap_node(pos, {name="mcl_chests:trapped_chest_left", param2 = node.param2})
		mesecon.receptor_off(pos, trapped_chest_mesecons_rules)

		local pos_other = mcl_util.get_double_container_neighbor_pos(pos, node.param2, "left")
		minetest.swap_node(pos_other, {name="mcl_chests:trapped_chest_right", param2 = node.param2})
		mesecon.receptor_off(pos_other, trapped_chest_mesecons_rules)

		player_chest_close(player)
	elseif node.name == "mcl_chests:trapped_chest_on_right" then
		minetest.swap_node(pos, {name="mcl_chests:trapped_chest_right", param2 = node.param2})
		mesecon.receptor_off(pos, trapped_chest_mesecons_rules)

		local pos_other = mcl_util.get_double_container_neighbor_pos(pos, node.param2, "right")
		minetest.swap_node(pos_other, {name="mcl_chests:trapped_chest_left", param2 = node.param2})
		mesecon.receptor_off(pos_other, trapped_chest_mesecons_rules)

		player_chest_close(player)
	end
end

-- Disable trapped chest when it has been closed
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname:find("mcl_chests:trapped_chest_") == 1 then
		if fields.quit then
			player_chest_close(player)
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	player_chest_close(player)
end)

minetest.register_craft({
	output = 'mcl_chests:chest',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'group:wood', '', 'group:wood'},
		{'group:wood', 'group:wood', 'group:wood'},
	}
})

minetest.register_craft({
	type = 'fuel',
	recipe = 'mcl_chests:chest',
	burntime = 15
})

minetest.register_craft({
	type = 'fuel',
	recipe = 'mcl_chests:trapped_chest',
	burntime = 15
})

local formspec_ender_chest = "size[9,8.75]"..
	"label[0,0;"..minetest.formspec_escape(minetest.colorize("#313131", S("Ender Chest"))).."]"..
	"list[current_player;enderchest;0,0.5;9,3;]"..
	mcl_formspec.get_itemslot_bg(0,0.5,9,3)..
	"label[0,4.0;"..minetest.formspec_escape(minetest.colorize("#313131", S("Inventory"))).."]"..
	"list[current_player;main;0,4.5;9,3;9]"..
	mcl_formspec.get_itemslot_bg(0,4.5,9,3)..
	"list[current_player;main;0,7.74;9,1;]"..
	mcl_formspec.get_itemslot_bg(0,7.74,9,1)..
	"listring[current_player;enderchest]"..
	"listring[current_player;main]"


minetest.register_node("mcl_chests:ender_chest", {
	description = S("Ender Chest"),
	_tt_help = S("27 interdimensional inventory slots") .. "\n" .. S("Put items inside, retrieve them from any ender chest"),
	_doc_items_longdesc = S("Ender chests grant you access to a single personal interdimensional inventory with 27 slots. This inventory is the same no matter from which ender chest you access it from. If you put one item into one ender chest, you will find it in all other ender chests. Each player will only see their own items, but not the items of other players."),
	_doc_items_usagehelp = S("Rightclick the ender chest to access your personal interdimensional inventory."),
	tiles = {"mcl_chests_ender_chest_top.png", "mcl_chests_ender_chest_bottom.png",
		"mcl_chests_ender_chest_right.png", "mcl_chests_ender_chest_left.png",
		"mcl_chests_ender_chest_back.png", "mcl_chests_ender_chest_front.png"},
	-- Note: The “container” group is missing here because the ender chest does not
	-- have an inventory on its own
	groups = {pickaxey=1, deco_block=1, material_stone=1},
	is_ground_content = false,
	paramtype = "light",
	light_source = 7,
	paramtype2 = "facedir",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	drop = "mcl_core:obsidian 8",
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", formspec_ender_chest)
	end,
	_mcl_blast_resistance = 3000,
	_mcl_hardness = 22.5,
	on_rotate = simple_rotate,
})

minetest.register_lbm({
	label = "Update ender chest + shulker box formspecs (0.51.0)",
	name = "mcl_chests:update_formspecs_0_51_0",
	nodenames = { "mcl_chests:ender_chest", "group:shulker_box" },
	action = function(pos, node)
		minetest.registered_nodes[node.name].on_construct(pos)
		minetest.log("action", "[mcl_chests] Node formspec updated at "..minetest.pos_to_string(pos))
	end,
})

minetest.register_on_joinplayer(function(player)
	local inv = player:get_inventory()
	inv:set_size("enderchest", 9*3)
end)

minetest.register_craft({
	output = 'mcl_chests:ender_chest',
	recipe = {
		{'mcl_core:obsidian', 'mcl_core:obsidian', 'mcl_core:obsidian'},
		{'mcl_core:obsidian', 'mcl_end:ender_eye', 'mcl_core:obsidian'},
		{'mcl_core:obsidian', 'mcl_core:obsidian', 'mcl_core:obsidian'},
	}
})

-- Shulker boxes
local boxtypes = {
	white = S("White Shulker Box"),
	grey = S("Light Grey Shulker Box"),
	orange = S("Orange Shulker Box"),
	cyan = S("Cyan Shulker Box"),
	magenta = S("Magenta Shulker Box"),
	violet = S("Purple Shulker Box"),
	lightblue = S("Light Blue Shulker Box"),
	blue = S("Blue Shulker Box"),
	yellow = S("Yellow Shulker Box"),
	brown = S("Brown Shulker Box"),
	green = S("Lime Shulker Box"),
	dark_green = S("Green Shulker Box"),
	pink = S("Pink Shulker Box"),
	red = S("Red Shulker Box"),
	dark_grey = S("Grey Shulker Box"),
	black = S("Black Shulker Box"),
}

local shulker_mob_textures = {
	white = "mobs_mc_shulker_white.png",
	grey = "mobs_mc_shulker_silver.png",
	orange = "mobs_mc_shulker_orange.png",
	cyan = "mobs_mc_shulker_cyan.png",
	magenta = "mobs_mc_shulker_magenta.png",
	violet = "mobs_mc_shulker_purple.png",
	lightblue = "mobs_mc_shulker_light_blue.png",
	blue = "mobs_mc_shulker_blue.png",
	yellow = "mobs_mc_shulker_yellow.png",
	brown = "mobs_mc_shulker_brown.png",
	green = "mobs_mc_shulker_lime.png",
	dark_green = "mobs_mc_shulker_green.png",
	pink = "mobs_mc_shulker_pink.png",
	red = "mobs_mc_shulker_red.png",
	dark_grey = "mobs_mc_shulker_gray.png",
	black = "mobs_mc_shulker_black.png",
}
local canonical_shulker_color = "violet"

local function formspec_shulker_box(name)
	if name == "" then
		name = S("Shulker Box")
	end
	return "size[9,8.75]"..
	"label[0,0;"..minetest.formspec_escape(minetest.colorize("#313131", name)).."]"..
	"list[current_name;main;0,0.5;9,3;]"..
	mcl_formspec.get_itemslot_bg(0,0.5,9,3)..
	"label[0,4.0;"..minetest.formspec_escape(minetest.colorize("#313131", S("Inventory"))).."]"..
	"list[current_player;main;0,4.5;9,3;9]"..
	mcl_formspec.get_itemslot_bg(0,4.5,9,3)..
	"list[current_player;main;0,7.74;9,1;]"..
	mcl_formspec.get_itemslot_bg(0,7.74,9,1)..
	"listring[current_name;main]"..
	"listring[current_player;main]"
end

local function set_shulkerbox_meta(nmeta, imeta)
	local name = imeta:get_string("name")
	nmeta:set_string("description", imeta:get_string("description"))
	nmeta:set_string("name", name)
	nmeta:set_string("formspec", formspec_shulker_box(name))
end

for color, desc in pairs(boxtypes) do
	local mob_texture = shulker_mob_textures[color]
	local is_canonical = color == canonical_shulker_color
	local longdesc, usagehelp, create_entry, entry_name
	if mod_doc then
		if is_canonical then
			longdesc = S("A shulker box is a portable container which provides 27 inventory slots for any item except shulker boxes. Shulker boxes keep their inventory when broken, so shulker boxes as well as their contents can be taken as a single item. Shulker boxes come in many different colors.")
			usagehelp = S("To access the inventory of a shulker box, place and right-click it. To take a shulker box and its contents with you, just break and collect it, the items will not fall out.")
			entry_name = S("Shulker Box")
		else
			create_entry = false
		end
	end

	minetest.register_node("mcl_chests:"..color.."_shulker_box", {
		description = desc,
		_tt_help = S("27 inventory slots") .. "\n" .. S("Can be carried around with its contents"),
		_doc_items_create_entry = create_entry,
		_doc_items_entry_name = entry_name,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = usagehelp,
		tiles = {
			"mcl_chests_"..color.."_shulker_box_top.png", -- top
			"[combine:16x16:-32,-28="..mob_texture, -- bottom
			"[combine:16x16:0,-36="..mob_texture..":0,-16="..mob_texture, -- side
			"[combine:16x16:-32,-36="..mob_texture..":-32,-16="..mob_texture, -- side
			"[combine:16x16:-16,-36="..mob_texture..":-16,-16="..mob_texture, -- side
			"[combine:16x16:-48,-36="..mob_texture..":-48,-16="..mob_texture, -- side
		},
		groups = {handy=1,pickaxey=1, container=3, deco_block=1, dig_by_piston=1, shulker_box=1},
		is_ground_content = false,
		sounds = mcl_sounds.node_sound_stone_defaults(),
		stack_max = 1,
		drop = "",
		paramtype = "light",
		paramtype2 = "facedir",
--		TODO: Make shulker boxes rotatable
--		This doesn't work, it just destroys the inventory:
--		on_place = minetest.rotate_node,
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec", formspec_shulker_box(nil))
			local inv = meta:get_inventory()
			inv:set_size("main", 9*3)
		end,
		_on_dispense = function(stack, pos, droppos, dropnode, dropdir)
			-- Place shulker box as node
			if minetest.registered_nodes[dropnode.name].buildable_to then
				minetest.set_node(droppos, {name = stack:get_name(), param2 = minetest.dir_to_facedir(dropdir)})
				local ninv = minetest.get_inventory({type="node", pos=droppos})
				local imetadata = stack:get_metadata()
				local iinv_main = minetest.deserialize(imetadata)
				ninv:set_list("main", iinv_main)
				ninv:set_size("main", 9*3)
				set_shulkerbox_meta(minetest.get_meta(droppos), stack:get_meta())
				stack:take_item()
			end
			return stack
		end,
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			local nmeta = minetest.get_meta(pos)
			local imetadata = itemstack:get_metadata()
			local iinv_main = minetest.deserialize(imetadata)
			local ninv = nmeta:get_inventory()
			ninv:set_list("main", iinv_main)
			ninv:set_size("main", 9*3)
			set_shulkerbox_meta(nmeta, itemstack:get_meta())

			if minetest.is_creative_enabled(placer:get_player_name()) then
				if not ninv:is_empty("main") then
					return nil
				else
					return itemstack
				end
			else
				return nil
			end
		end,
		on_destruct = function(pos)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local items = {}
			for i=1, inv:get_size("main") do
				local stack = inv:get_stack("main", i)
				items[i] = stack:to_string()
			end
			local data = minetest.serialize(items)
			local boxitem = ItemStack("mcl_chests:"..color.."_shulker_box")
			local boxitem_meta = boxitem:get_meta()
			boxitem_meta:set_string("description", meta:get_string("description"))
			boxitem_meta:set_string("name", meta:get_string("name"))
			boxitem:set_metadata(data)

			if minetest.is_creative_enabled("") then
				if not inv:is_empty("main") then
					minetest.add_item(pos, boxitem)
				end
			else
				minetest.add_item(pos, boxitem)
			end
		end,
		allow_metadata_inventory_move = protection_check_move,
		allow_metadata_inventory_take = protection_check_put_take,
		allow_metadata_inventory_put = function(pos, listname, index, stack, player)
			local name = player:get_player_name()
			if minetest.is_protected(pos, name) then
				minetest.record_protection_violation(pos, name)
				return 0
			end
			-- Do not allow to place shulker boxes into shulker boxes
			local group = minetest.get_item_group(stack:get_name(), "shulker_box")
			if group == 0 or group == nil then
				return stack:get_count()
			else
				return 0
			end
		end,
		_mcl_blast_resistance = 6,
		_mcl_hardness = 2,
	})

	if mod_doc and not is_canonical then
		doc.add_entry_alias("nodes", "mcl_chests:"..canonical_shulker_color.."_shulker_box", "nodes", "mcl_chests:"..color.."_shulker_box")
	end

	minetest.register_craft({
		type = "shapeless",
		output = 'mcl_chests:'..color..'_shulker_box',
		recipe = { 'group:shulker_box', 'mcl_dye:'..color }
	})
end

minetest.register_craft({
	output = 'mcl_chests:violet_shulker_box',
	recipe = {
		{'mcl_mobitems:shulker_shell'},
		{'mcl_chests:chest'},
		{'mcl_mobitems:shulker_shell'},
	}
})

-- Save metadata of shulker box when used in crafting
minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	local new = itemstack:get_name()
	if minetest.get_item_group(itemstack:get_name(), "shulker_box") ~= 1 then
		return
	end
	local original
	for i = 1, #old_craft_grid do
		local item = old_craft_grid[i]:get_name()
		if minetest.get_item_group(item, "shulker_box") == 1 then
			original = old_craft_grid[i]
			break
		end
	end
	if original then
		local ometa = original:get_meta():to_table()
		local nmeta = itemstack:get_meta()
		nmeta:from_table(ometa)
		return itemstack
	end
end)


minetest.register_lbm({
	-- Disable active/open trapped chests when loaded because nobody could
	-- have them open at loading time.
	-- Fixes redstone weirdness.
	label = "Disable active trapped chests",
	name = "mcl_chests:reset_trapped_chests",
	nodenames = { "mcl_chests:trapped_chest_on", "mcl_chests:trapped_chest_on_left", "mcl_chests:trapped_chest_on_right" },
	run_at_every_load = true,
	action = function(pos, node)
		minetest.log("action", "[mcl_chests] Disabled active trapped chest on load: " ..minetest.pos_to_string(pos))
		chest_update_after_close(pos)
	end,
})

-- Legacy
minetest.register_lbm({
	label = "Update ender chest formspecs (0.60.0)",
	name = "mcl_chests:update_ender_chest_formspecs_0_60_0",
	nodenames = { "mcl_chests:ender_chest" },
	run_at_every_load = false,
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", formspec_ender_chest)
	end,
})
minetest.register_lbm({
	label = "Update shulker box formspecs (0.60.0)",
	name = "mcl_chests:update_shulker_box_formspecs_0_60_0",
	nodenames = { "group:shulker_box" },
	run_at_every_load = false,
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", formspec_shulker_box)
	end,
})
