--register stoppers for movestones/pistons

mesecon.mvps_stoppers = {}
mesecon.mvps_unsticky = {}
mesecon.mvps_droppers = {}
mesecon.on_mvps_move = {}
mesecon.mvps_unmov = {}

local is_protected = minetest.is_protected

--- Objects (entities) that cannot be moved
function mesecon.register_mvps_unmov(objectname)
	mesecon.mvps_unmov[objectname] = true;
end

function mesecon.is_mvps_unmov(objectname)
	return mesecon.mvps_unmov[objectname]
end

function mesecon.is_mvps_dropper(node, pushdir, stack, stackid)
	local get_dropper = mesecon.mvps_droppers[node.name]
	if type (get_dropper) == "function" then
		get_dropper = get_dropper(node, pushdir, stack, stackid)
	end
	if not get_dropper then
		get_dropper = minetest.get_item_group(node.name, "dig_by_piston") == 1
	end
	return get_dropper
end

function mesecon.register_mvps_dropper(nodename, get_dropper)
	if get_dropper == nil then
		get_dropper = true
	end
	mesecon.mvps_droppers[nodename] = get_dropper
end

-- Nodes that cannot be pushed / pulled by movestones, pistons
function mesecon.is_mvps_stopper(node)
	-- unknown nodes are always stoppers
	return mesecon.mvps_stoppers[node.name] or not minetest.registered_nodes[node.name]
end

function mesecon.register_mvps_stopper(nodename)
	mesecon.mvps_stoppers[nodename] = true
end

-- For nodes which ignore sticky sides.
-- They can't be pulled by sticky pistons and don't interact with slime blocks.
-- TODO: This has NOT any actual effect so far. The actual functionality
-- still needs to be implemented.
function mesecon.register_mvps_unsticky(nodename, get_unsticky)
	if get_unsticky == nil then
		get_unsticky = true
	end
	mesecon.mvps_unsticky[nodename] = get_unsticky
end

function mesecon.is_mvps_unsticky(node, pulldir, stack, stackid)
	-- unknown nodes are always unsticky
	if not minetest.registered_nodes[node.name] then
		return true
	end

	local get_unsticky = mesecon.mvps_unsticky[node.name]
	if type(get_unsticky) == "function" then
		get_unsticky = get_unsticky(node, pulldir, stack, stackid)
	end
	if get_unsticky == nil then
		get_unsticky = false
	end

	return get_unsticky
end

-- Functions to be called on mvps movement
function mesecon.register_on_mvps_move(callback)
	mesecon.on_mvps_move[#mesecon.on_mvps_move+1] = callback
end

local function on_mvps_move(moved_nodes)
	for _, callback in ipairs(mesecon.on_mvps_move) do
		callback(moved_nodes)
	end
end

function mesecon.mvps_process_stack(stack)
	-- update mesecons for placed nodes ( has to be done after all nodes have been added )
	for _, n in ipairs(stack) do
		mesecon.on_placenode(n.pos, minetest.get_node(n.pos))
	end
end

-- tests if the node can be pushed into, e.g. air, water, grass
local function node_replaceable(name)
	if name == "ignore" then return true end

	if minetest.registered_nodes[name] then
		return minetest.registered_nodes[name].buildable_to or false
	end

	return false
end

local function is_available(pos)
	local n = minetest.get_node(pos)
	if not n then
		return false, n
	end
	local name = n.name
	if name == "ignore" then
		minetest.get_voxel_manip():read_from_map(pos, pos)
		n = minetest.get_node(pos)
		if not n then
			return false, n
		end
		name = n.name
	end
	if name == "ignore" then
		return false, n
	end
	if minetest.registered_nodes[name] then
		return minetest.registered_nodes[name].buildable_to, n or false, n
	end
	return false, n
end


function mesecon.mvps_get_stack(pos, dir, maximum, piston_pos)
	-- determine the number of nodes to be pushed
	local nodes = {}
	local frontiers = {pos}

	while #frontiers > 0 do
		local np = frontiers[1]
		local nn = minetest.get_node(np)
		if nn.name == "ignore" then
			minetest.get_voxel_manip():read_from_map(np, np)
			nn = minetest.get_node(np)
		end

		if mesecon.is_mvps_stopper(nn) then
			return
		end

		if not node_replaceable(nn.name) then
			if #nodes >= maximum then return nil, false end
			table.insert(nodes, {node = nn, pos = {x=np.x, y=np.y, z=np.z}})

			-- add connected nodes to frontiers, connected is a vector list
			-- the vectors must be absolute positions
			local connected = {}
			if minetest.registered_nodes[nn.name]
			and minetest.registered_nodes[nn.name].mvps_sticky then
				connected, has_loop = minetest.registered_nodes[nn.name].mvps_sticky(np, nn, piston_pos)
				if has_loop then
					return {}, true
				end
			end

			table.insert(connected, vector.add(np, dir))

			-- Make sure there are no duplicates in frontiers / nodes before
			-- adding nodes in "connected" to frontiers
			for _, cp in ipairs(connected) do
				local duplicate = false
				for _, rp in ipairs(nodes) do
					if vector.equals(cp, rp.pos) then
						duplicate = true
					end
				end
				for _, fp in ipairs(frontiers) do
					if vector.equals(cp, fp) then
						duplicate = true
					end
				end
				if not duplicate and not mesecon.is_mvps_stopper(minetest.get_node(cp)) then
					table.insert(frontiers, cp)
				end
			end
		end
		table.remove(frontiers, 1)
	end

	return nodes, false
end

function mesecon.mvps_set_owner(pos, placer)
	local meta = minetest.get_meta(pos)
	local owner = placer and placer.get_player_name and placer:get_player_name()
	if owner and owner ~= "" then
		meta:set_string("owner", owner)
	else
		meta:set_string("owner", "$unknown") -- to distinguish from older pistons
	end
end

local function are_protected(nodes, player_name)
	for _, node in pairs(nodes) do
		if minetest.is_protected(node.pos, player_name) then
			return true
		end
	end
	return false
end

function mesecon.mvps_push(pos, dir, maximum, player_name, piston_pos)
	return mesecon.mvps_push_or_pull(pos, dir, dir, maximum, player_name, piston_pos)
end

function mesecon.mvps_pull_single(pos, dir, maximum, player_name, piston_pos)
	return mesecon.mvps_push_or_pull(pos, vector.multiply(dir, -1), dir, maximum, player_name, piston_pos)
end

-- pos: pos of mvps; stackdir: direction of building the stack
-- movedir: direction of actual movement
-- maximum: maximum nodes to be pushed
function mesecon.mvps_push_or_pull(pos, stackdir, movedir, maximum, player_name, piston_pos)
	local nodes, has_loop = mesecon.mvps_get_stack(pos, movedir, maximum, piston_pos)

	if has_loop then
		return false
	end

	if not nodes then return end

	local newpos={}
	-- check node availability to push/pull into, and fill newpos[i]
	for i in ipairs(nodes) do
		newpos[i] = vector.add(nodes[i].pos, movedir)
		if (newpos[i].x == piston_pos.x) and (newpos[i].y == piston_pos.y) and (newpos[i].z == piston_pos.z) then
			return
		end
		if not is_available(newpos[i]) then
			local available = false
			for j in ipairs(nodes) do
				if i ~= j then
					if (newpos[i].x == nodes[j].pos.x) and (newpos[i].y == nodes[j].pos.y) and (newpos[i].z == nodes[j].pos.z) then
						available = true
						break
					end
				end
			end
			if not available then
				return
			end
		end
	end

	if are_protected(nodes, player_name) then
		return
	end

	local first_dropper = nil
	-- remove all nodes
	for id, n in ipairs(nodes) do
		n.meta = minetest.get_meta(n.pos):to_table()
		local is_dropper = mesecon.is_mvps_dropper(n.node, movedir, nodes, id)
		if is_dropper then
			local drops = minetest.get_node_drops(n.node.name, "")
			minetest.dig_node(n.pos)
		else
			minetest.remove_node(n.pos)
			local node_timer = minetest.get_node_timer(n.pos)
			if node_timer:is_started() then
				n.node_timer = {node_timer:get_timeout(), node_timer:get_elapsed()}
			end
		end
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
	end

	-- add nodes
	for id, n in ipairs(nodes) do
		if first_dropper and id >= first_dropper then
			break
		end
		local np = newpos[id]
		minetest.add_node(np, n.node)
		minetest.get_meta(np):from_table(n.meta)
		if n.node_timer then
			minetest.get_node_timer(np):set(unpack(n.node_timer))
		end
		if string.find(n.node.name, "mcl_observers:observer") then
			-- It also counts as a block update when the observer itself is moved by a piston (Wiki):
			mcl_observers.observer_activate(np)
		end
	end

	local moved_nodes = {}
	local oldstack = mesecon.tablecopy(nodes)
	for i in ipairs(nodes) do
		if first_dropper and i >= first_dropper then
			break
		end
		moved_nodes[i] = {}
		moved_nodes[i].oldpos = nodes[i].pos
		nodes[i].pos = newpos[i]
		moved_nodes[i].pos = nodes[i].pos
		moved_nodes[i].node = nodes[i].node
		moved_nodes[i].meta = nodes[i].meta
		moved_nodes[i].node_timer = nodes[i].node_timer
	end

	on_mvps_move(moved_nodes)

	return true, nodes, oldstack
end

function mesecon.mvps_move_objects(pos, dir, nodestack)
	local objects_to_move = {}

	-- Move object at tip of stack, pushpos is position at tip of stack
	local pushpos = vector.add(pos, vector.multiply(dir, #nodestack))

	local objects = minetest.get_objects_inside_radius(pushpos, 1)
	for _, obj in ipairs(objects) do
		table.insert(objects_to_move, obj)
	end

	-- Move objects lying/standing on the stack (before it was pushed - oldstack)
	if tonumber(minetest.settings:get("movement_gravity")) > 0 and dir.y == 0 then
		-- If gravity positive and dir horizontal, push players standing on the stack
		for _, n in ipairs(nodestack) do
			local p_above = vector.add(n.pos, {x=0, y=1, z=0})
			local objects = minetest.get_objects_inside_radius(p_above, 1)
			for _, obj in ipairs(objects) do
				table.insert(objects_to_move, obj)
			end
		end
	end

	for _, obj in ipairs(objects_to_move) do
		local entity = obj:get_luaentity()
		if not entity or not mesecon.is_mvps_unmov(entity.name) then
			local np = vector.add(obj:get_pos(), dir)

			--move only if destination is not solid
			local nn = minetest.get_node(np)
			if not ((not minetest.registered_nodes[nn.name])
			or minetest.registered_nodes[nn.name].walkable) then
				obj:set_pos(np)
			end
		end
	end
end

-- Unmovable by design
mesecon.register_mvps_stopper("mcl_core:barrier")
mesecon.register_mvps_stopper("mcl_core:realm_barrier")
mesecon.register_mvps_stopper("mcl_core:void")
mesecon.register_mvps_stopper("mcl_core:bedrock")
mesecon.register_mvps_stopper("mcl_core:obsidian")
mesecon.register_mvps_stopper("mcl_chests:ender_chest")
mesecon.register_mvps_stopper("mcl_mobspawners:spawner")
mesecon.register_mvps_stopper("mesecons_commandblock:commandblock_off")
mesecon.register_mvps_stopper("mesecons_commandblock:commandblock_on")
mesecon.register_mvps_stopper("mcl_portals:portal")
mesecon.register_mvps_stopper("mcl_portals:portal_end")
mesecon.register_mvps_stopper("mcl_portals:end_portal_frame")
mesecon.register_mvps_stopper("mcl_portals:end_portal_frame_eye")

-- Unmovable by technical restrictions.
-- Open formspec would screw up if node is destroyed (minor problem)
mesecon.register_mvps_stopper("mcl_furnaces:furnace")
mesecon.register_mvps_stopper("mcl_furnaces:furnace_active")
mesecon.register_mvps_stopper("mcl_hoppers:hopper")
mesecon.register_mvps_stopper("mcl_hoppers:hopper_side")
mesecon.register_mvps_stopper("mcl_droppers:dropper")
mesecon.register_mvps_stopper("mcl_droppers:dropper_up")
mesecon.register_mvps_stopper("mcl_droppers:dropper_down")
mesecon.register_mvps_stopper("mcl_dispensers:dispenser")
mesecon.register_mvps_stopper("mcl_dispensers:dispenser_up")
mesecon.register_mvps_stopper("mcl_dispensers:dispenser_down")
mesecon.register_mvps_stopper("mcl_anvils:anvil")
mesecon.register_mvps_stopper("mcl_anvils:anvil_damage_1")
mesecon.register_mvps_stopper("mcl_anvils:anvil_damage_2")
-- Would screw up on/off state of trapped chest (big problem)

-- Glazed terracotta: unpullable
mesecon.register_mvps_unsticky("mcl_colorblocks:glazed_terracotta_red")
mesecon.register_mvps_unsticky("mcl_colorblocks:glazed_terracotta_orange")
mesecon.register_mvps_unsticky("mcl_colorblocks:glazed_terracotta_yellow")
mesecon.register_mvps_unsticky("mcl_colorblocks:glazed_terracotta_green")
mesecon.register_mvps_unsticky("mcl_colorblocks:glazed_terracotta_lime")
mesecon.register_mvps_unsticky("mcl_colorblocks:glazed_terracotta_purple")
mesecon.register_mvps_unsticky("mcl_colorblocks:glazed_terracotta_magenta")
mesecon.register_mvps_unsticky("mcl_colorblocks:glazed_terracotta_blue")
mesecon.register_mvps_unsticky("mcl_colorblocks:glazed_terracotta_cyan")
mesecon.register_mvps_unsticky("mcl_colorblocks:glazed_terracotta_white")
mesecon.register_mvps_unsticky("mcl_colorblocks:glazed_terracotta_grey")
mesecon.register_mvps_unsticky("mcl_colorblocks:glazed_terracotta_silver")
mesecon.register_mvps_unsticky("mcl_colorblocks:glazed_terracotta_black")
mesecon.register_mvps_unsticky("mcl_colorblocks:glazed_terracotta_brown")
mesecon.register_mvps_unsticky("mcl_colorblocks:glazed_terracotta_light_blue")
mesecon.register_mvps_unsticky("mcl_colorblocks:glazed_terracotta_pink")

mesecon.register_on_mvps_move(mesecon.move_hot_nodes)

-- Check for falling after moving node
mesecon.register_on_mvps_move(function(moved_nodes)
	for i = 1, #moved_nodes do
		local moved_node = moved_nodes[i]
		mesecon.on_placenode(moved_node.pos, moved_node.node)
		minetest.after(0, function()
			minetest.check_for_falling(moved_node.oldpos)
			minetest.check_for_falling(moved_node.pos)
		end)
		local node_def = minetest.registered_nodes[moved_node.node.name]
		if node_def and node_def.mesecon and node_def.mesecon.on_mvps_move then
			node_def.mesecon.on_mvps_move(moved_node.pos, moved_node.node,
					moved_node.oldpos, moved_node.meta)
		end
	end
end)
