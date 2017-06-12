local function get_chest_neighborpos(pos, param2, side)
	if side == "right" then
		if param2 == 0 then
			return {x=pos.x-1, y=pos.y, z=pos.z}
		elseif param2 == 1 then
			return {x=pos.x, y=pos.y, z=pos.z+1}
		elseif param2 == 2 then
			return {x=pos.x+1, y=pos.y, z=pos.z}
		elseif param2 == 3 then
			return {x=pos.x, y=pos.y, z=pos.z-1}
		end
	else
		if param2 == 0 then
			return {x=pos.x+1, y=pos.y, z=pos.z}
		elseif param2 == 1 then
			return {x=pos.x, y=pos.y, z=pos.z-1}
		elseif param2 == 2 then
			return {x=pos.x-1, y=pos.y, z=pos.z}
		elseif param2 == 3 then
			return {x=pos.x, y=pos.y, z=pos.z+1}
		end
	end
end

-- This is a helper function to register both chests and trapped chests. Trapped chests will make use of the additional parameters
local register_chest = function(basename, desc, longdesc, usagehelp, hidden, mesecons, on_rightclick_addendum, on_rightclick_addendum_left, on_rightclick_addendum_right, drop)

if not drop then
	drop = "mcl_chests:"..basename
else
	drop = "mcl_chests:"..drop
end

minetest.register_node("mcl_chests:"..basename, {
	description = desc,
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usagehelp,
	_doc_items_hidden = hidden,
	tiles = {"default_chest_top.png", "default_chest_top.png", "default_chest_side.png",
		"default_chest_side.png", "default_chest_side.png", "default_chest_front.png"},
	paramtype2 = "facedir",
	stack_max = 64,
	drop = drop,
	groups = {handy=1,axey=1, container=2, deco_block=1, material_wood=1},
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_construct = function(pos)
		local param2 = minetest.get_node(pos).param2
		local meta = minetest.get_meta(pos)
		--[[ This is a workaround for Minetest issue 5894
		<https://github.com/minetest/minetest/issues/5894>.
		Apparently if we don't do this, double chests initially don't work when
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
		if minetest.get_node(get_chest_neighborpos(pos, param2, "right")).name == "mcl_chests:"..basename then
			minetest.swap_node(pos, {name="mcl_chests:"..basename.."_right",param2=param2})
			local p = get_chest_neighborpos(pos, param2, "right")
			minetest.swap_node(p, { name = "mcl_chests:"..basename.."_left", param2 = param2 })
		elseif minetest.get_node(get_chest_neighborpos(pos, param2, "left")).name == "mcl_chests:"..basename then
			minetest.swap_node(pos, {name="mcl_chests:"..basename.."_left",param2=param2})
			local p = get_chest_neighborpos(pos, param2, "left")
			minetest.swap_node(p, { name = "mcl_chests:"..basename.."_right", param2 = param2 })
		end
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest.get_meta(pos)
		local meta2 = meta
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		for i=1,inv:get_size("main") do
			local stack = inv:get_stack("main", i)
			if not stack:is_empty() then
				local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
				minetest.add_item(p, stack)
			end
		end
		meta:from_table(meta2:to_table())
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
		minetest.show_formspec(clicker:get_player_name(),
		"mcl_chests:"..basename.."_"..pos.x.."_"..pos.y.."_"..pos.z,
		"size[9,8.75]"..
		mcl_vars.inventory_header..
		"background[-0.19,-0.25;9.41,10.48;crafting_inventory_chest.png]"..
		"image[0,-0.2;5,0.75;fnt_chest.png]"..
		"list[nodemeta:"..pos.x..","..pos.y..","..pos.z..";main;0,0.5;9,3;]"..
		"list[current_player;main;0,4.5;9,3;9]"..
		"list[current_player;main;0,7.74;9,1;]"..
		"listring[nodemeta:"..pos.x..","..pos.y..","..pos.z..";main]"..
		"listring[current_player;main]")

		if on_rightclick_addendum then
			on_rightclick_addendum(pos, node, clicker)
		end
	end,
	mesecons = mesecons,
})

minetest.register_node("mcl_chests:"..basename.."_left", {
	tiles = {"default_chest_top_big.png", "default_chest_top_big.png", "default_chest_side.png",
		"default_chest_side.png", "default_chest_side_big.png^[transformFX", "default_chest_front_big.png"},
	paramtype2 = "facedir",
	groups = {handy=1,axey=1, container=2,not_in_creative_inventory=1, material_wood=1},
	drop = drop,
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_destruct = function(pos)
		local n = minetest.get_node(pos)
		if n.name == "mcl_chests:"..basename then
			return
		end
		local param2 = n.param2
		local p = get_chest_neighborpos(pos, param2, "left")
		if not p or minetest.get_node(p).name ~= "mcl_chests:"..basename.."_right" then
			return
		end
		minetest.swap_node(p, { name = "mcl_chests:"..basename, param2 = param2 })
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest.get_meta(pos)
		local meta2 = meta
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		for i=1,inv:get_size("main") do
			local stack = inv:get_stack("main", i)
			if not stack:is_empty() then
				local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
				minetest.add_item(p, stack)
			end
		end
		meta:from_table(meta2:to_table())
	end,
	-- BEGIN OF LISTRING WORKAROUND
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "input" then
			local inv = minetest.get_inventory({type="node", pos=pos})
			if inv:room_for_item("main", stack) then
				return -1
			else
				local other_pos = get_chest_neighborpos(pos, minetest.get_node(pos).param2, "left")
				local other_inv = minetest.get_inventory({type="node", pos=other_pos})
				if other_inv:room_for_item("main", stack) then
					return -1
				else
					return 0
				end
			end
		else
			return stack:get_count()
		end
	end,
	-- END OF LISTRING WORKAROUND
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
			local leftover = inv:add_item("main", stack)
			if not leftover:is_empty() then
				local other_pos = get_chest_neighborpos(pos, minetest.get_node(pos).param2, "left")
				local other_inv = minetest.get_inventory({type="node", pos=other_pos})
				other_inv:add_item("main", leftover)
			end
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
		local pos_other = get_chest_neighborpos(pos, node.param2, "left")

		minetest.show_formspec(clicker:get_player_name(),
		"mcl_chests:"..basename.."_"..pos.x.."_"..pos.y.."_"..pos.z,
		"size[9,11.5]"..
		"background[-0.19,-0.25;9.41,12.5;crafting_inventory_chest_large.png]"..
		mcl_vars.inventory_header..
		"list[nodemeta:"..pos.x..","..pos.y..","..pos.z..";main;0,0.5;9,3;]"..
		"list[nodemeta:"..pos_other.x..","..pos_other.y..","..pos_other.z..";main;0,3.5;9,3;]"..
		"list[current_player;main;0,7.5;9,3;9]"..
		"list[current_player;main;0,10.75;9,1;]"..
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
})

minetest.register_node("mcl_chests:"..basename.."_right", {
	tiles = {"default_chest_top_big.png^[transformFX", "default_chest_top_big.png^[transformFX", "default_chest_side.png",
		"default_chest_side.png", "default_chest_side_big.png", "default_chest_front_big.png^[transformFX"},
	paramtype2 = "facedir",
	groups = {handy=1,axey=1, container=2,not_in_creative_inventory=1, material_wood=1},
	drop = drop,
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_destruct = function(pos)
		local n = minetest.get_node(pos)
		if n.name == "mcl_chests:"..basename then
			return
		end
		local param2 = n.param2
		local p = get_chest_neighborpos(pos, param2, "right")
		if not p or minetest.get_node(p).name ~= "mcl_chests:"..basename.."_left" then
			return
		end
		minetest.swap_node(p, { name = "mcl_chests:"..basename, param2 = param2 })
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest.get_meta(pos)
		local meta2 = meta
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		for i=1,inv:get_size("main") do
			local stack = inv:get_stack("main", i)
			if not stack:is_empty() then
				local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
				minetest.add_item(p, stack)
			end
		end
		meta:from_table(meta2:to_table())
	end,
	-- BEGIN OF LISTRING WORKAROUND
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "input" then
			local other_pos = get_chest_neighborpos(pos, minetest.get_node(pos).param2, "right")
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
		else
			return stack:get_count()
		end
	end,
	-- END OF LISTRING WORKAROUND
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in chest at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to chest at "..minetest.pos_to_string(pos))
		-- BEGIN OF LISTRING WORKAROUND
		local other_pos = get_chest_neighborpos(pos, minetest.get_node(pos).param2, "right")
		local other_inv = minetest.get_inventory({type="node", pos=other_pos})
		local leftover = other_inv:add_item("main", stack)
		if not leftover:is_empty() then
			local inv = minetest.get_inventory({type="node", pos=pos})
			inv:add_item("main", leftover)
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
		local pos_other = get_chest_neighborpos(pos, node.param2, "right")

		minetest.show_formspec(clicker:get_player_name(),
		"mcl_chests:"..basename.."_"..pos.x.."_"..pos.y.."_"..pos.z,

		"size[9,11.5]"..
		"background[-0.19,-0.25;9.41,12.5;crafting_inventory_chest_large.png]"..
		mcl_vars.inventory_header..
		"list[nodemeta:"..pos_other.x..","..pos_other.y..","..pos_other.z..";main;0,0.5;9,3;]"..
		"list[nodemeta:"..pos.x..","..pos.y..","..pos.z..";main;0,3.5;9,3;]"..
		"list[current_player;main;0,7.5;9,3;9]"..
		"list[current_player;main;0,10.75;9,1;]"..
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
})

if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mcl_chests:"..basename, "nodes", "mcl_chests:"..basename.."_left")
	doc.add_entry_alias("nodes", "mcl_chests:"..basename, "nodes", "mcl_chests:"..basename.."_right")
end

end

register_chest("chest",
	"Chest",
	"Chests are containers which provide 27 inventory slots. Chests can be turned into large chests with double the capacity by placing two chests next to each other.",
	"To acccess the inventory of a chest or large chest, rightclick it. When broken, the items of the chest will drop out.",
	false
)

local trapped_chest_mesecons_rules = {
	{x = 1,  y = 0, z = 0},
	{x = -1,  y = 0, z = 0},
	{x = 0,  y = 0, z = 1},
	{x = 0,  y = 0, z =-1},
	{x = 0,  y =-1, z = 0}
}

register_chest("trapped_chest",
	"Trapped Chest",
	"A trapped chest is a container which provides 27 inventory slots. It looks identical to a regular chest, but when it is opened, it sends a redstone signal to its adjacent blocks. Trapped chests can be turned into large trapped chests with double the capacity by placing two trapped chests next to each other.",
	"To acccess the inventory of a trapped chest or a large trapped chest, rightclick it. When broken, the items will drop out.",
	nil,
	{receptor = {
		state = mesecon.state.off,
		rules = trapped_chest_mesecons_rules,
	}},
	function(pos, node, clicker)
		local meta = minetest.get_meta(pos)
		meta:set_int("players", 1)
		minetest.swap_node(pos, {name="mcl_chests:trapped_chest_on", param2 = node.param2})
		mesecon:receptor_on(pos, trapped_chest_mesecons_rules)
	end,
	function(pos, node, clicker)
		local meta = minetest.get_meta(pos)
		meta:set_int("players", 1)

		minetest.swap_node(pos, {name="mcl_chests:trapped_chest_on_left", param2 = node.param2})
		mesecon:receptor_on(pos, trapped_chest_mesecons_rules)

		local pos_other = get_chest_neighborpos(pos, node.param2, "left")
		minetest.swap_node(pos_other, {name="mcl_chests:trapped_chest_on_right", param2 = node.param2})
		mesecon:receptor_on(pos_other, trapped_chest_mesecons_rules)
	end,
	function(pos, node, clicker)
		local pos_other = get_chest_neighborpos(pos, node.param2, "right")

		-- Save number of players in left part of the chest only
		local meta = minetest.get_meta(pos_other)
		meta:set_int("players", 1)

		minetest.swap_node(pos, {name="mcl_chests:trapped_chest_on_right", param2 = node.param2})
		mesecon:receptor_on(pos, trapped_chest_mesecons_rules)

		minetest.swap_node(pos_other, {name="mcl_chests:trapped_chest_on_left", param2 = node.param2})
		mesecon:receptor_on(pos_other, trapped_chest_mesecons_rules)
	end
)

register_chest("trapped_chest_on",
	nil, nil, nil, true,
	{receptor = {
		state = mesecon.state.on,
		rules = trapped_chest_mesecons_rules,
	}},
	function(pos, node, clicker)
		local meta = minetest.get_meta(pos)
		local players = meta:get_int("players")
		players = players + 1
		meta:set_int("players", players)
	end,
	function(pos, node, clicker)
		local meta = minetest.get_meta(pos)
		local players = meta:get_int("players")
		players = players + 1
		meta:set_int("players", players)
	end,
	function(pos, node, clicker)
		local pos_other = get_chest_neighborpos(pos, node.param2, "right")
		local meta = minetest.get_meta(pos_other)
		local players = meta:get_int("players")
		players = players + 1
		meta:set_int("players", players)
	end,
	"trapped_chest"
)

-- Disable trapped chest when it has been closed
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname:find("mcl_chests:trapped_chest_") == 1 then
		if fields.quit then
			local x, y, z = formname:match("mcl_chests:trapped_chest_(.-)_(.-)_(.*)")
			local pos = {x=tonumber(x), y=tonumber(y), z=tonumber(z)}
			if not pos or not pos.x or not pos.y or not pos.z then return end
			local node = minetest.get_node(pos)
			local meta, players, pos_other
			if node.name == "mcl_chests:trapped_chest_on" or node.name == "mcl_chests:trapped_chest_on_left" then
				meta = minetest.get_meta(pos)
				players = meta:get_int("players")
				players = players - 1
			elseif node.name == "mcl_chests:trapped_chest_on_right" then
				pos_other = get_chest_neighborpos(pos, node.param2, "right")
				meta = minetest.get_meta(pos_other)
				players = meta:get_int("players")
				players = players - 1
			end

			if node.name == "mcl_chests:trapped_chest_on" then
				if players <= 0 then
					meta:set_int("players", 0)
					minetest.swap_node(pos, {name="mcl_chests:trapped_chest", param2 = node.param2})
					mesecon:receptor_off(pos, trapped_chest_mesecons_rules)
				else
					meta:set_int("players", players)
				end
			elseif node.name == "mcl_chests:trapped_chest_on_left" then
				if players <= 0 then
					meta:set_int("players", 0)
					minetest.swap_node(pos, {name="mcl_chests:trapped_chest_left", param2 = node.param2})
					mesecon:receptor_off(pos, trapped_chest_mesecons_rules)

					pos_other = get_chest_neighborpos(pos, node.param2, "left")
					minetest.swap_node(pos_other, {name="mcl_chests:trapped_chest_right", param2 = node.param2})
					mesecon:receptor_off(pos_other, trapped_chest_mesecons_rules)
				else
					meta:set_int("players", players)
				end
			elseif node.name == "mcl_chests:trapped_chest_on_right" then
				if players <= 0 then
					meta:set_int("players", 0)
					minetest.swap_node(pos, {name="mcl_chests:trapped_chest_right", param2 = node.param2})
					mesecon:receptor_off(pos, trapped_chest_mesecons_rules)

					minetest.swap_node(pos_other, {name="mcl_chests:trapped_chest_left", param2 = node.param2})
					mesecon:receptor_off(pos_other, trapped_chest_mesecons_rules)
				else
					meta:set_int("players", players)
				end
			end
		end
	end
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

minetest.register_node("mcl_chests:ender_chest", {
	description = "Ender Chest",
	_doc_items_longdesc = "Ender chests grant you access to a single personal interdimensional inventory with 27 slots. This inventory is the same no matter from which ender chest you access it from. If you put one item into one ender chest, you will find it in all other ender chests worldwide. Each player will only see their own items, but not the items of other players.",
	_doc_items_usagehelp = "Rightclick the ender chest to access your personal interdimensional inventory.",
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
		meta:set_string("formspec", 
				"size[9,8.75]"..
				mcl_vars.inventory_header..
				"background[-0.19,-0.25;9.41,10.48;crafting_inventory_chest.png]"..
				"image[0,-0.2;5,0.75;fnt_ender_chest.png]"..
				"list[current_player;enderchest;0,0.5;9,3;]"..
				"list[current_player;main;0,4.5;9,3;9]"..
				"list[current_player;main;0,7.74;9,1;]"..
				"listring[current_player;enderchest]"..
				"listring[current_player;main]")
	end,
	_mcl_blast_resistance = 3000,
	_mcl_hardness = 22.5,
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
	white = "White Shulker Box",
	grey = "Light Grey Shulker Box",
	orange = "Orange Shulker Box",
	cyan = "Cyan Shulker Box",
	magenta = "Magenta Shulker Box",
	violet = "Purple Shulker Box",
	lightblue = "Light Blue Shulker Box",
	blue = "Blue Shulker Box",
	yellow = "Yellow Shulker Box",
	brown = "Brown Shulker Box",
	green = "Lime Shulker Box",
	dark_green = "Green Shulker Box",
	pink = "Pink Shulker Box",
	red = "Red Shulker Box",
	dark_grey = "Grey Shulker Box",
	black = "Black Shulker Box",
}

for color, desc in pairs(boxtypes) do
	minetest.register_node("mcl_chests:"..color.."_shulker_box", {
		description = desc,
		_doc_items_longdesc = "A shulker box is a portable container which provides 27 inventory slots for any item except shulker boxes. Shulker boxes keep their inventory when broken, so shulker boxes as well as their contents can be taken as a single item. Shulker boxes come in many different colors.",
		_doc_items_usagehelp = "To access the inventory of a shulker box, place and right-click it. To take a shulker box and its contents with you, just break and collect it, the items will not fall out. Place the shulker box again to be able to retrieve its contents.",
		tiles = {"mcl_chests_"..color.."_shulker_box_top.png", "mcl_chests_"..color.."_shulker_box_bottom.png",
			"mcl_chests_"..color.."_shulker_box_side.png", "mcl_chests_"..color.."_shulker_box_side.png",
			"mcl_chests_"..color.."_shulker_box_side.png", "mcl_chests_"..color.."_shulker_box_side.png"},
		groups = {handy=1,pickaxey=1, container=3, deco_block=1, dig_by_piston=1, shulker_box=1},
		is_ground_content = false,
		sounds = mcl_sounds.node_sound_stone_defaults(),
		stack_max = 1,
		drop = "",
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec",
					"size[9,8.75]"..
					mcl_vars.inventory_header..
					"background[-0.19,-0.25;9.41,10.48;crafting_inventory_chest.png]"..
					"image[0,-0.2;5,0.75;fnt_shulker_box.png]"..
					"list[current_name;main;0,0.5;9,3;]"..
					"list[current_player;main;0,4.5;9,3;9]"..
					"list[current_player;main;0,7.74;9,1;]"..
					"listring[current_name;main]"..
					"listring[current_player;main]")
			local inv = meta:get_inventory()
			inv:set_size("main", 9*3)
		end,
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			local nmeta = minetest.get_meta(pos)
			local ninv = nmeta:get_inventory()
			local imeta = itemstack:get_metadata()
			local iinv_main = minetest.deserialize(imeta)
			ninv:set_list("main", iinv_main)
			ninv:set_size("main", 9*3)
			if minetest.setting_getbool("creative_mode") then
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
			boxitem:set_metadata(data)

			if minetest.setting_getbool("creative_mode") then
				if not inv:is_empty("main") then
					minetest.add_item(pos, boxitem)
				end
			else
				minetest.add_item(pos, boxitem)
			end
		end,
		allow_metadata_inventory_put = function(pos, listname, index, stack, player)
			-- Do not allow to place shulker boxes into shulker boxes
			local group = minetest.get_item_group(stack:get_name(), "shulker_box")
			if group == 0 or group == nil then
				return stack:get_count()
			else
				return 0
			end
		end,
		_mcl_blast_resistance = 30,
		_mcl_hardness = 6,
	})

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

