-- Register stoppers for pistons
mesecon.mvps_stoppers={}

-- Register nodes which drop as item when pushed or pulled
mesecon.mvps_droppers={}

function mesecon:is_mvps_stopper(node, pushdir, stack, stackid)
	local get_stopper = mesecon.mvps_stoppers[node.name]
	if type (get_stopper) == "function" then
		get_stopper = get_stopper(node, pushdir, stack, stackid)
	end
	return get_stopper
end

function mesecon:register_mvps_stopper(nodename, get_stopper)
	if get_stopper == nil then
			get_stopper = true
	end
	mesecon.mvps_stoppers[nodename] = get_stopper
end

function mesecon:is_mvps_dropper(node, pushdir, stack, stackid)
	local get_dropper = mesecon.mvps_droppers[node.name]
	if type (get_dropper) == "function" then
		get_dropper = get_dropper(node, pushdir, stack, stackid)
	end
	if not get_dropper then
		get_dropper = minetest.get_item_group(node.name, "dig_by_piston") == 1
	end
	return get_dropper
end

function mesecon:register_mvps_dropper(nodename, get_dropper)
	if get_dropper == nil then
		get_dropper = true
	end
	mesecon.mvps_droppers[nodename] = get_dropper
end

function mesecon:mvps_process_stack(stack)
	-- update mesecons for placed nodes ( has to be done after all nodes have been added )
	for _, n in ipairs(stack) do
		core.check_for_falling(n.pos)
		mesecon.on_placenode(n.pos, minetest.get_node(n.pos))
		mesecon:update_autoconnect(n.pos)
	end
end

function mesecon:mvps_push(pos, dir, maximum) -- pos: pos of mvps; dir: direction of push; maximum: maximum nodes to be pushed
	np = {x = pos.x, y = pos.y, z = pos.z}

	-- determine the number of nodes to be pushed
	local nodes = {}
	while true do
		nn = minetest.get_node_or_nil(np)
		if not nn or #nodes > maximum then
			-- don't push at all, something is in the way (unloaded map or too many nodes)
			return
		end

		if nn.name == "air"
		or minetest.registered_nodes[nn.name].liquidtype ~= "none" then --is liquid
			break
		end

		table.insert (nodes, {node = nn, pos = np})

		np = mesecon:addPosRule(np, dir)
	end

	-- determine if one of the nodes blocks the push
	for id, n in ipairs(nodes) do
		if mesecon:is_mvps_stopper(n.node, dir, nodes, id) then
			return
		end
	end

	local first_dropper = nil
	-- remove all nodes
	for id, n in ipairs(nodes) do
		n.meta = minetest.get_meta(n.pos):to_table()
		local is_dropper = mesecon:is_mvps_dropper(n.node, dir, nodes, id)
		if is_dropper then
			local drops = minetest.get_node_drops(n.node.name, "")
			local droppos = vector.add(n.pos, dir)
			minetest.handle_node_drops(droppos, drops, nil)
		end
		minetest.remove_node(n.pos)
		if is_dropper then
			first_dropper = id
			break
		end
	end

	-- update mesecons for removed nodes ( has to be done after all nodes have been removed )
	for id, n in ipairs(nodes) do
		if first_dropper and id >= first_dropper then
			break
		end
		mesecon.on_dignode(n.pos, n.node)
		mesecon:update_autoconnect(n.pos)
	end

	-- add nodes
	for id, n in ipairs(nodes) do
		if first_dropper and id >= first_dropper then
			break
		end
		np = mesecon:addPosRule(n.pos, dir)
		minetest.add_node(np, n.node)
		minetest.get_meta(np):from_table(n.meta)
	end

	for i in ipairs(nodes) do
		if first_dropper and i >= first_dropper then
			break
		end
		nodes[i].pos = mesecon:addPosRule(nodes[i].pos, dir)
	end

	return true, nodes
end

function mesecon:mvps_pull_single(pos, dir) -- pos: pos of mvps; direction: direction of pull (matches push direction for sticky pistons)
	np = mesecon:addPosRule(pos, dir)
	nn = minetest.get_node(np)

	if minetest.registered_nodes[nn.name].liquidtype == "none"
	and not mesecon:is_mvps_stopper(nn, {x = -dir.x, y = -dir.y, z = -dir.z}, {{pos = np, node = nn}}, 1)
	and not mesecon:is_mvps_dropper(nn, {x = -dir.x, y = -dir.y, z = -dir.z}, {{pos = np, node = nn}}, 1) then
		local meta = minetest.get_meta(np):to_table()
		minetest.remove_node(np)
		minetest.add_node(pos, nn)
		minetest.get_meta(pos):from_table(meta)

		core.check_for_falling(np)
		core.check_for_falling(pos)
		mesecon.on_dignode(np, nn)
		mesecon:update_autoconnect(np)
	end
	return {{pos = np, node = {param2 = 0, name = "air"}}, {pos = pos, node = nn}}
end

function mesecon:mvps_pull_all(pos, direction) -- pos: pos of mvps; direction: direction of pull
		local lpos = {x=pos.x-direction.x, y=pos.y-direction.y, z=pos.z-direction.z} -- 1 away
		local lnode = minetest.get_node(lpos)
		local lpos2 = {x=pos.x-direction.x*2, y=pos.y-direction.y*2, z=pos.z-direction.z*2} -- 2 away
		local lnode2 = minetest.get_node(lpos2)

		if lnode.name ~= "ignore" and lnode.name ~= "air" and minetest.registered_nodes[lnode.name].liquidtype == "none" then return end
		if lnode2.name == "ignore" or lnode2.name == "air" or not(minetest.registered_nodes[lnode2.name].liquidtype == "none") then return end

		local oldpos = {x=lpos2.x+direction.x, y=lpos2.y+direction.y, z=lpos2.z+direction.z}
		repeat
			lnode2 = minetest.get_node(lpos2)
			minetest.add_node(oldpos, {name=lnode2.name})
			core.check_for_falling(oldpos)
			oldpos = {x=lpos2.x, y=lpos2.y, z=lpos2.z}
			lpos2.x = lpos2.x-direction.x
			lpos2.y = lpos2.y-direction.y
			lpos2.z = lpos2.z-direction.z
			lnode = minetest.get_node(lpos2)
		until lnode.name=="air" or lnode.name=="ignore" or not(minetest.registered_nodes[lnode2.name].liquidtype == "none")
		minetest.remove_node(oldpos)
end

mesecon:register_mvps_stopper("mcl_core:obsidian")
mesecon:register_mvps_stopper("mcl_core:bedrock")
mesecon:register_mvps_stopper("mcl_core:barrier")
mesecon:register_mvps_stopper("mcl_core:void")
mesecon:register_mvps_stopper("mcl_chests:chest")
mesecon:register_mvps_stopper("mcl_chests:chest_left")
mesecon:register_mvps_stopper("mcl_chests:chest_right")
mesecon:register_mvps_stopper("mcl_chests:trapped_chest")
mesecon:register_mvps_stopper("mcl_chests:trapped_chest_left")
mesecon:register_mvps_stopper("mcl_chests:trapped_chest_right")
mesecon:register_mvps_stopper("mcl_chests:ender_chest")
mesecon:register_mvps_stopper("mcl_furnaces:furnace")
mesecon:register_mvps_stopper("mcl_furnaces:furnace_active")
mesecon:register_mvps_stopper("mcl_hoppers:hopper")
mesecon:register_mvps_stopper("mcl_hoppers:hopper_side")
mesecon:register_mvps_stopper("mcl_droppers:dropper")
mesecon:register_mvps_stopper("mcl_droppers:dropper_up")
mesecon:register_mvps_stopper("mcl_droppers:dropper_down")
mesecon:register_mvps_stopper("mcl_anvils:anvil")
mesecon:register_mvps_stopper("mcl_anvils:anvil_damage_1")
mesecon:register_mvps_stopper("mcl_anvils:anvil_damage_2")
mesecon:register_mvps_stopper("mcl_jukebox:jukebox")
mesecon:register_mvps_stopper("mobs:spawner")
mesecon:register_mvps_stopper("signs:sign_yard")
mesecon:register_mvps_stopper("signs:sign_wall")
mesecon:register_mvps_stopper("mesecons_commandblock:commandblock_off")
mesecon:register_mvps_stopper("mesecons_commandblock:commandblock_on")
mesecon:register_mvps_stopper("mesecons_solarpanel:solar_panel_off")
mesecon:register_mvps_stopper("mesecons_solarpanel:solar_panel_on")
mesecon:register_mvps_stopper("mesecons_solarpanel:solar_panel_inverted_off")
mesecon:register_mvps_stopper("mesecons_solarpanel:solar_panel_inverted_on")
mesecon:register_mvps_stopper("mesecons_noteblock:noteblock")
