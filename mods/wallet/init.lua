local function rshift(x, by)
	return math.floor(x / 2 ^ by)
end

local directions = {
	{x = 1, y = 0, z = 0},
	{x = 0, y = 0, z = 1},
	{x = -1, y = 0, z = 0},
	{x = 0, y = 0, z = -1},
	{x = 0, y = -1, z = 0},
}

local function update_wall(pos)
	local thisnode = minetest.get_node(pos)

	if thisnode.name:find("wallet:wall") ~= 1 and
		thisnode.name:find("wallet:wallmossy") ~= 1 then
		-- Not a wall
		return
	end

	-- Get the node's base name, including the underscore since we will need it
	local basename = thisnode.name:find("_")
	if basename == nil then -- New wall
		basename = thisnode.name .. "_"
	else -- Already placed wall
		basename = thisnode.name:sub(1, basename)
	end

	local sum = 0

	-- Neighbouring walkable nodes
	for i = 1, 4 do
		local dir = directions[i]
		local node = minetest.get_node({x = pos.x + dir.x, y = pos.y + dir.y, z = pos.z + dir.z})
		if minetest.registered_nodes[node.name].walkable then
			sum = sum + 2 ^ (i - 1)
		end
	end

	-- Torches or walkable nodes above the wall
	local upnode = minetest.get_node({x = pos.x, y = pos.y+1, z = pos.z})
	if sum == 5 or sum == 10 then
		if minetest.registered_nodes[upnode.name].walkable or upnode.name == "torches:floor" then
			sum = sum + 11
		end
	end

	--[[if sum == 0 then
		sum = 15
	end]]

	minetest.add_node(pos, {name = basename..sum})
end

function update_wall_global(pos)
	for i = 1,5 do
		local dir = directions[i]
		update_wall({x = pos.x + dir.x, y = pos.y + dir.y, z = pos.z + dir.z})
	end
end

local half_blocks = {
    {4/16, -0.5, -3/16, 0.5, 5/16, 3/16},
    {-3/16, -0.5, 4/16, 3/16, 5/16, 0.5},
    {-0.5, -0.5, -3/16, -4/16, 5/16, 3/16},
    {-3/16, -0.5, -0.5, 3/16, 5/16, -4/16}
}

local pillar = {-4/16, -0.5, -4/16, 4/16, 0.5, 4/16}

local full_blocks = {
    {-0.5, -0.5, -3/16, 0.5, 5/16, 3/16},
    {-3/16, -0.5, -0.5, 3/16, 5/16, 0.5}
}

local function register_wall(nodename, name, texture, invtex)
	for i = 0, 15 do
		local need = {}
		local need_pillar = false
		for j = 1, 4 do
			if rshift(i, j - 1) % 2 == 1 then
				need[j] = true
			end
		end

		local take = {}
		if need[1] == true and need[3] == true then
			need[1] = nil
			need[3] = nil
			table.insert(take, full_blocks[1])
		end
		if need[2] == true and need[4] == true then
			need[2] = nil
			need[4] = nil
			table.insert(take, full_blocks[2])
		end
		for k in pairs(need) do
			table.insert(take, half_blocks[k])
			need_pillar = true
		end
		if i == 15 or i == 0 then need_pillar = true end
		if need_pillar then table.insert(take, pillar) end

		minetest.register_node(nodename.."_"..i, {
			collision_box = {
				type = 'fixed', 
				fixed = {-4/16, -1, -4/16, 4/16, 1, 4/16}
			},
			drawtype = "nodebox",
			is_ground_content = false,
			tiles = {texture},
			paramtype = "light",
			groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3,wall=1},
			drop = nodename,
			node_box = {
				type = "fixed",
				fixed = take
			},
			sounds = default.node_sound_stone_defaults(), 
		})
	end

	minetest.register_node(nodename.."_16", {
		drawtype = "nodebox",
		collision_box = {
				type = 'fixed', 
				fixed = {-4/16, -1, -4/16, 4/16, 1, 4/16}
		},
		tiles = {texture},
		paramtype = "light",
		is_ground_content = false,
		groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3,wall=1},
		drop = nodename,
		node_box = {
			type = "fixed",
			fixed = {pillar, full_blocks[1]}
		},
		sounds = default.node_sound_stone_defaults(), 
	})

	minetest.register_node(nodename.."_21", {
		drawtype = "nodebox",
		collision_box = {
				type = 'fixed', 
				fixed = {-4/16, -1, -4/16, 4/16, 1, 4/16}
		},
		tiles = {texture},
		paramtype = "light",
		is_ground_content = false,
		groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3,wall=1},
		drop = nodename,
		node_box = {
			type = "fixed",
			fixed = {pillar, full_blocks[2]}
		},
		sounds = default.node_sound_stone_defaults(), 
	})

	-- Inventory item
	minetest.register_node(nodename, {
		description = name,
		paramtype = "light",
		is_ground_content = false,
		tiles = {texture},
		inventory_image = invtex,
		stack_max = 64,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = pillar
		},
		collision_box = {
				type = 'fixed', 
				fixed = {-4/16, -1, -4/16, 4/16, 1, 4/16}
		},
		collisionbox = {-0.2, 0, -0.2, 0.2, 1.4, 0.2},
		on_construct = update_wall,
		sounds = default.node_sound_stone_defaults(), 
	})
end

-- Cobblestone wall

register_wall("wallet:wall", "Cobblestone Wall", "default_cobble.png", "cobblestone_wallet.png")
minetest.register_craft({
	output = 'wallet:wall 6',
	recipe = {
		{'default:cobble', 'default:cobble', 'default:cobble'},
		{'default:cobble', 'default:cobble', 'default:cobble'}
	}
})

-- Mossy wall

register_wall("wallet:wallmossy", "Mossy Cobblestone Wall", "default_mossycobble.png", "cobblestonemossy_wallet.png")
minetest.register_craft({
	output = 'wallet:wallmossy 6',
	recipe = {
		{'default:mossycobble', 'default:mossycobble', 'default:mossycobble'},
        {'default:mossycobble', 'default:mossycobble', 'default:mossycobble'}
	}
})

minetest.register_on_placenode(update_wall_global)
minetest.register_on_dignode(update_wall_global)
