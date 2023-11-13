--
-- Lava vs water interactions
--

local modpath = minetest.get_modpath(minetest.get_current_modname())

local mg_name = minetest.get_mapgen_setting("mg_name")

local math = math
local vector = vector

local OAK_TREE_ID = 1
local DARK_OAK_TREE_ID = 2
local SPRUCE_TREE_ID = 3
local ACACIA_TREE_ID = 4
local JUNGLE_TREE_ID = 5
local BIRCH_TREE_ID = 6

minetest.register_abm({
	label = "Lava cooling",
	nodenames = {"group:lava"},
	neighbors = {"group:water"},
	interval = 1,
	chance = 1,
	min_y = mcl_vars.mg_end_min,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local water = minetest.find_nodes_in_area({x=pos.x-1, y=pos.y-1, z=pos.z-1}, {x=pos.x+1, y=pos.y+1, z=pos.z+1}, "group:water")

		local lavatype = minetest.registered_nodes[node.name].liquidtype

		for w=1, #water do
			--local waternode = minetest.get_node(water[w])
			--local watertype = minetest.registered_nodes[waternode.name].liquidtype
			-- Lava on top of water: Water turns into stone
			if water[w].y < pos.y and water[w].x == pos.x and water[w].z == pos.z then
				minetest.set_node(water[w], {name="mcl_core:stone"})
				minetest.sound_play("fire_extinguish_flame", {pos = water[w], gain = 0.25, max_hear_distance = 16}, true)
			-- Flowing lava vs water on same level: Lava turns into cobblestone
			elseif lavatype == "flowing" and water[w].y == pos.y and (water[w].x == pos.x or water[w].z == pos.z) then
				minetest.set_node(pos, {name="mcl_core:cobble"})
				minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
			-- Lava source vs flowing water above or horizontally neighbored: Lava turns into obsidian
			elseif lavatype == "source" and
					((water[w].y > pos.y and water[w].x == pos.x and water[w].z == pos.z) or
					(water[w].y == pos.y and (water[w].x == pos.x or water[w].z == pos.z))) then
				minetest.set_node(pos, {name="mcl_core:obsidian"})
				minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
			-- water above flowing lava: Lava turns into cobblestone
			elseif lavatype == "flowing" and water[w].y > pos.y and water[w].x == pos.x and water[w].z == pos.z then
				minetest.set_node(pos, {name="mcl_core:cobble"})
				minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
			end
		end
	end,
})

--
-- Papyrus and cactus growing
--

-- Functions
function mcl_core.grow_cactus(pos, node)
	pos.y = pos.y-1
	local name = minetest.get_node(pos).name
	if minetest.get_item_group(name, "sand") ~= 0 then
		pos.y = pos.y+1
		local height = 0
		while minetest.get_node(pos).name == "mcl_core:cactus" and height < 4 do
			height = height+1
			pos.y = pos.y+1
		end
		if height < 3 then
			if minetest.get_node(pos).name == "air" then
				minetest.set_node(pos, {name="mcl_core:cactus"})
			end
		end
	end
end

function mcl_core.grow_reeds(pos, node)
	pos.y = pos.y-1
	local name = minetest.get_node(pos).name
	if minetest.get_item_group(name, "soil_sugarcane") ~= 0 then
		if minetest.find_node_near(pos, 1, {"group:water"}) == nil and minetest.find_node_near(pos, 1, {"group:frosted_ice"}) == nil then
			return
		end
		pos.y = pos.y+1
		local height = 0
		while minetest.get_node(pos).name == "mcl_core:reeds" and height < 3 do
			height = height+1
			pos.y = pos.y+1
		end
		if height < 3 then
			if minetest.get_node(pos).name == "air" then
				minetest.set_node(pos, {name="mcl_core:reeds"})
			end
		end
	end
end

-- ABMs


local function drop_attached_node(p)
	local nn = minetest.get_node(p).name
	if nn == "air" or nn == "ignore" then
		return
	end
	minetest.remove_node(p)
	for _, item in pairs(minetest.get_node_drops(nn, "")) do
		local pos = {
			x = p.x + math.random()/2 - 0.25,
			y = p.y + math.random()/2 - 0.25,
			z = p.z + math.random()/2 - 0.25,
		}
		if item ~= "" then
			minetest.add_item(pos, item)
		end
	end
end

-- Helper function for node actions for liquid flow
local function liquid_flow_action(pos, group, action)
	local function check_detach(pos, xp, yp, zp)
		local p = {x=pos.x+xp, y=pos.y+yp, z=pos.z+zp}
		local n = minetest.get_node_or_nil(p)
		if not n then
			return false
		end
		local d = minetest.registered_nodes[n.name]
		if not d then
			return false
		end
		--[[ Check if we want to perform the liquid action.
		* 1: Item must be in liquid group
		* 2a: If target node is below liquid, always succeed
		* 2b: If target node is horizontal to liquid: succeed if source, otherwise check param2 for horizontal flow direction ]]
		local range = d.liquid_range or 8
		if (minetest.get_item_group(n.name, group) ~= 0) and
				((yp > 0) or
				(yp == 0 and ((d.liquidtype == "source") or (n.param2 > (8-range) and n.param2 < 9)))) then
			action(pos)
		end
	end
	local posses = {
		{ x=-1, y=0, z=0 },
		{ x=1, y=0, z=0 },
		{ x=0, y=0, z=-1 },
		{ x=0, y=0, z=1 },
		{ x=0, y=1, z=0 },
	}
	for p=1,#posses do
		check_detach(pos, posses[p].x, posses[p].y, posses[p].z)
	end
end

-- Drop some nodes next to flowing water, if it would flow into the node
minetest.register_abm({
	label = "Wash away dig_by_water nodes by water flow",
	nodenames = {"group:dig_by_water"},
	neighbors = {"group:water"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		liquid_flow_action(pos, "water", function(pos)
			drop_attached_node(pos)
			minetest.dig_node(pos)
		end)
	end,
})

-- Destroy some nodes next to flowing lava, if it would flow into the node
minetest.register_abm({
	label = "Destroy destroy_by_lava_flow nodes by lava flow",
	nodenames = {"group:destroy_by_lava_flow"},
	neighbors = {"group:lava"},
	interval = 1,
	chance = 5,
	action = function(pos, node, active_object_count, active_object_count_wider)
		liquid_flow_action(pos, "lava", function(pos)
			minetest.remove_node(pos)
			minetest.sound_play("builtin_item_lava", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
			minetest.check_for_falling(pos)
		end)
	end,
})

-- Cactus mechanisms
minetest.register_abm({
	label = "Cactus growth",
	nodenames = {"mcl_core:cactus"},
	neighbors = {"group:sand"},
	interval = 25,
	chance = 10,
	action = function(pos)
		mcl_core.grow_cactus(pos)
	end,
})

minetest.register_abm({
	label = "Cactus mechanisms",
	nodenames = {"mcl_core:cactus"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		for _, object in pairs(minetest.get_objects_inside_radius(pos, 0.9)) do
			local entity = object:get_luaentity()
			if entity and entity.name == "__builtin:item" then
				object:remove()
			end
		end
		local posses = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }
		for _, p in pairs(posses) do
			local ndef = minetest.registered_nodes[minetest.get_node(vector.new(pos.x + p[1], pos.y, pos.z + p[2])).name]
			if ndef and ndef.walkable then
				local posy = pos.y
				while minetest.get_node(vector.new(pos.x, posy, pos.z)).name == "mcl_core:cactus" do
					local pos = vector.new(pos.x, posy, pos.z)
					minetest.dig_node(pos)
					-- minetest.add_item(vector.offset(pos, math.random(-0.5, 0.5), 0, math.random(-0.5, 0.5)), "mcl_core:cactus")
					posy = posy + 1
				end
				break
			end
		end
	end,
})


minetest.register_abm({
	label = "Sugar canes growth",
	nodenames = {"mcl_core:reeds"},
	neighbors = {"group:soil_sugarcane"},
	interval = 25,
	chance = 10,
	action = function(pos)
		mcl_core.grow_reeds(pos)
	end,
})

--
-- Sugar canes drop
--

local timber_nodenames={"mcl_core:reeds"}

minetest.register_on_dignode(function(pos, node)
	local i=1
	while timber_nodenames[i]~=nil do
		local np={x=pos.x, y=pos.y+1, z=pos.z}
		while minetest.get_node(np).name==timber_nodenames[i] do
			minetest.remove_node(np)
			minetest.add_item(np, timber_nodenames[i])
			np={x=np.x, y=np.y+1, z=np.z}
		end
		i=i+1
	end
end)

local function air_leaf(leaftype)
	if math.random(0, 50) == 3 then
		return {name = "air"}
	else
		return {name = leaftype}
	end
end

-- Check if a node stops a tree from growing.  Torches, plants, wood, tree,
-- leaves and dirt does not affect tree growth.
local function node_stops_growth(node)
	if node.name == "air" then
		return false
	end

	local def = minetest.registered_nodes[node.name]
	if not def then
		return true
	end

	local groups = def.groups
	if not groups then
		return true
	end
	if groups.plant or groups.torch or groups.dirt or groups.tree
		or groups.bark or groups.leaves or groups.wood then
		return false
	end

	return true
end

-- Check if a tree can grow at position. The width is the width to check
-- around the tree. A width of 3 and height of 5 will check a 3x3 area, 5
-- nodes above the sapling. If any walkable node other than dirt, wood or
-- leaves occurs in those blocks the tree cannot grow.
local function check_growth_width(pos, width, height)
	-- Huge tree (with even width to check) will check one more node in
	-- positive x and y directions.
	local neg_space = math.min((width - 1) / 2)
	local pos_space = math.max((width - 1) / 2)
	for x = -neg_space, pos_space do
		for z = -neg_space, pos_space do
			for y = 1, height do
				local np = vector.new(
					pos.x + x,
					pos.y + y,
					pos.z + z)
				if node_stops_growth(minetest.get_node(np)) then
					return false
				end
			end
		end
	end
	return true
end
mcl_core.check_growth_width = check_growth_width

-- Check if a tree with id can grow at a position. Options is a table of flags
-- for varieties of trees. The 'two_by_two' option is used to check if there is
-- room to generate huge trees for spruce and jungle. The 'balloon' option is
-- used to check if there is room to generate a balloon tree for oak.
local function check_tree_growth(pos, tree_id, options)
	local two_by_two = options and options.two_by_two
	local balloon = options and options.balloon

	if tree_id == OAK_TREE_ID then
		if balloon then
			return check_growth_width(pos, 7, 11)
		else
			return check_growth_width(pos, 3, 5)
		end
	elseif tree_id == BIRCH_TREE_ID then
		return check_growth_width(pos, 3, 6)
	elseif tree_id == SPRUCE_TREE_ID then
		if two_by_two then
			return check_growth_width(pos, 6, 20)
		else
			return check_growth_width(pos, 5, 11)
		end
	elseif tree_id == JUNGLE_TREE_ID then
		if two_by_two then
			return check_growth_width(pos, 8, 23)
		else
			return check_growth_width(pos, 3, 8)
		end
	elseif tree_id == ACACIA_TREE_ID then
		return check_growth_width(pos, 7, 8)
	elseif tree_id == DARK_OAK_TREE_ID and two_by_two then
		return check_growth_width(pos, 4, 7)
	end

	return false
end

-- Generates a tree with a type. Options is a table of flags for varieties of
-- trees. The 'two_by_two' option is used by jungle and spruce trees to
-- generate huge trees. The 'balloon' option is used by oak to generate a balloon
-- oak tree.
function mcl_core.generate_tree(pos, tree_type, options)
	pos.y = pos.y-1
	--local nodename = minetest.get_node(pos).name

	pos.y = pos.y+1
	if not minetest.get_node_light(pos) then
		return
	end

	local two_by_two = options and options.two_by_two
	local balloon = options and options.balloon

	if tree_type == nil or tree_type == OAK_TREE_ID then
		if mg_name == "v6" then
			mcl_core.generate_v6_oak_tree(pos)
		else
			if balloon then
				mcl_core.generate_balloon_oak_tree(pos)
			else
				mcl_core.generate_oak_tree(pos)
			end
		end
	elseif tree_type == DARK_OAK_TREE_ID then
		mcl_core.generate_dark_oak_tree(pos)
	elseif tree_type == SPRUCE_TREE_ID then
		if two_by_two then
			mcl_core.generate_huge_spruce_tree(pos)
		else
			if mg_name == "v6" then
				mcl_core.generate_v6_spruce_tree(pos)
			else
				mcl_core.generate_spruce_tree(pos)
			end
		end
	elseif tree_type == ACACIA_TREE_ID then
		mcl_core.generate_acacia_tree(pos)
	elseif tree_type == JUNGLE_TREE_ID then
		if two_by_two then
			mcl_core.generate_huge_jungle_tree(pos)
		else
			if mg_name == "v6" then
				mcl_core.generate_v6_jungle_tree(pos)
			else
				mcl_core.generate_jungle_tree(pos)
			end
		end
	elseif tree_type == BIRCH_TREE_ID then
		mcl_core.generate_birch_tree(pos)
	end
	mcl_core.update_sapling_foliage_colors(pos)
end

-- Classic oak in v6 style
function mcl_core.generate_v6_oak_tree(pos)
	local trunk = "mcl_core:tree"
	local leaves = "mcl_core:leaves"
	local node
	for dy=1,4 do
		pos.y = pos.y+dy
		if minetest.get_node(pos).name ~= "air" then
			return
		end
		pos.y = pos.y-dy
	end
	node = {name = trunk}
	for dy=0,4 do
		pos.y = pos.y+dy
		if minetest.get_node(pos).name == "air" then
			minetest.add_node(pos, node)
		end
		pos.y = pos.y-dy
	end

	node = {name = leaves}
	pos.y = pos.y+3
	--[[local rarity = 0
	if math.random(0, 10) == 3 then
		rarity = 1
	end]]
	for dx=-2,2 do
		for dz=-2,2 do
			for dy=0,3 do
				pos.x = pos.x+dx
				pos.y = pos.y+dy
				pos.z = pos.z+dz

				if dx == 0 and dz == 0 and dy==3 then
					if minetest.get_node(pos).name == "air" and math.random(1, 5) <= 4 then
						minetest.add_node(pos, node)
						minetest.add_node(pos, air_leaf(leaves))
					end
				elseif dx == 0 and dz == 0 and dy==4 then
					if minetest.get_node(pos).name == "air" and math.random(1, 5) <= 4 then
						minetest.add_node(pos, node)
						minetest.add_node(pos, air_leaf(leaves))
					end
				elseif math.abs(dx) ~= 2 and math.abs(dz) ~= 2 then
					if minetest.get_node(pos).name == "air" then
						minetest.add_node(pos, node)
						minetest.add_node(pos, air_leaf(leaves))
					end
				else
					if math.abs(dx) ~= 2 or math.abs(dz) ~= 2 then
						if minetest.get_node(pos).name == "air" and math.random(1, 5) <= 4 then
							minetest.add_node(pos, node)
							minetest.add_node(pos, air_leaf(leaves))
						end
					end
				end
				pos.x = pos.x-dx
				pos.y = pos.y-dy
				pos.z = pos.z-dz
			end
		end
	end
end

-- Ballon Oak
function mcl_core.generate_balloon_oak_tree(pos)
	local path
	local offset
	local s = math.random(1, 12)
	if s == 1 then
		-- Small balloon oak
		path = modpath .. "/schematics/mcl_core_oak_balloon.mts"
		offset = { x = -2, y = -1, z = -2 }
	else
		-- Large balloon oak
		local t = math.random(1, 4)
		path = modpath .. "/schematics/mcl_core_oak_large_"..t..".mts"
		if t == 1 or t == 3 then
			offset = { x = -3, y = -1, z = -3 }
		elseif t == 2 or t == 4 then
			offset = { x = -4, y = -1, z = -4 }
		end
	end
	minetest.place_schematic(vector.add(pos, offset), path, "random", nil, false)
end

-- Oak
local path_oak_tree = modpath.."/schematics/mcl_core_oak_classic.mts"

function mcl_core.generate_oak_tree(pos)
	local offset = { x = -2, y = -1, z = -2 }
	minetest.place_schematic(vector.add(pos, offset), path_oak_tree, "random", nil, false)
end

-- Birch
function mcl_core.generate_birch_tree(pos)
	local path = modpath ..
		"/schematics/mcl_core_birch.mts"
	minetest.place_schematic({x = pos.x - 2, y = pos.y - 1, z = pos.z - 2}, path, "random", nil, false)
end

-- BEGIN of spruce tree generation functions --
-- Copied from Minetest Game 0.4.15 from the pine tree (default.generate_pine_tree)

-- Pine tree (=spruce tree in MCL2) from mg mapgen mod, design by sfan5, pointy top added by paramat
local function add_spruce_leaves(data, vi, c_air, c_ignore, c_snow, c_spruce_leaves)
	local node_id = data[vi]
	if node_id == c_air or node_id == c_ignore or node_id == c_snow then
		data[vi] = c_spruce_leaves
	end
end

function mcl_core.generate_v6_spruce_tree(pos)
	local x, y, z = pos.x, pos.y, pos.z
	local maxy = y + math.random(9, 13) -- Trunk top

	local c_air = minetest.get_content_id("air")
	local c_ignore = minetest.get_content_id("ignore")
	local c_spruce_tree = minetest.get_content_id("mcl_core:sprucetree")
	local c_spruce_leaves  = minetest.get_content_id("mcl_core:spruceleaves")
	local c_snow = minetest.get_content_id("mcl_core:snow")

	local vm = minetest.get_voxel_manip()
	local minp, maxp = vm:read_from_map(
		{x = x - 3, y = y, z = z - 3},
		{x = x + 3, y = maxy + 3, z = z + 3}
	)
	local a = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
	local data = vm:get_data()

	-- Upper branches layer
	local dev = 3
	for yy = maxy - 1, maxy + 1 do
		for zz = z - dev, z + dev do
			local vi = a:index(x - dev, yy, zz)
			local via = a:index(x - dev, yy + 1, zz)
			for xx = x - dev, x + dev do
				if math.random() < 0.95 - dev * 0.05 then
					add_spruce_leaves(data, vi, c_air, c_ignore, c_snow,
						c_spruce_leaves)
				end
				vi  = vi + 1
				via = via + 1
			end
		end
		dev = dev - 1
	end

	-- Centre top nodes
	add_spruce_leaves(data, a:index(x, maxy + 1, z), c_air, c_ignore, c_snow,
		c_spruce_leaves)
	add_spruce_leaves(data, a:index(x, maxy + 2, z), c_air, c_ignore, c_snow,
		c_spruce_leaves) -- Paramat added a pointy top node

	-- Lower branches layer
	local my = 0
	for i = 1, 20 do -- Random 2x2 squares of leaves
		local xi = x + math.random(-3, 2)
		local yy = maxy + math.random(-6, -5)
		local zi = z + math.random(-3, 2)
		if yy > my then
			my = yy
		end
		for zz = zi, zi+1 do
			local vi = a:index(xi, yy, zz)
			local via = a:index(xi, yy + 1, zz)
			for xx = xi, xi + 1 do
				add_spruce_leaves(data, vi, c_air, c_ignore, c_snow,
					c_spruce_leaves)
				vi  = vi + 1
				via = via + 1
			end
		end
	end

	dev = 2
	for yy = my + 1, my + 2 do
		for zz = z - dev, z + dev do
			local vi = a:index(x - dev, yy, zz)
			local via = a:index(x - dev, yy + 1, zz)
			for xx = x - dev, x + dev do
				if math.random() < 0.95 - dev * 0.05 then
					add_spruce_leaves(data, vi, c_air, c_ignore, c_snow,
						c_spruce_leaves)
				end
				vi  = vi + 1
				via = via + 1
			end
		end
		dev = dev - 1
	end

	-- Trunk
	-- Force-place lowest trunk node to replace sapling
	data[a:index(x, y, z)] = c_spruce_tree
	for yy = y + 1, maxy do
		local vi = a:index(x, yy, z)
		local node_id = data[vi]
		if node_id == c_air or node_id == c_ignore or
				node_id == c_spruce_leaves or node_id == c_snow then
			data[vi] = c_spruce_tree
		end
	end

	vm:set_data(data)
	vm:write_to_map()
end

function mcl_core.generate_spruce_tree(pos)
	local r = math.random(1, 3)
	local path = modpath .. "/schematics/mcl_core_spruce_"..r..".mts"
	minetest.place_schematic({ x = pos.x - 3, y = pos.y - 1, z = pos.z - 3 }, path, "0", nil, false)
end

local function find_necorner(p)
	local n=minetest.get_node_or_nil(vector.offset(p,0,1,1))
	local e=minetest.get_node_or_nil(vector.offset(p,1,1,0))
	if n and n.name == "mcl_core:sprucetree" then
		p=vector.offset(p,0,0,1)
	end
	if e and e.name == "mcl_core:sprucetree" then
		p=vector.offset(p,1,0,0)
	end
	return p
end

local function generate_spruce_podzol(ps)
	local pos=find_necorner(ps)
	local pos1=vector.offset(pos,-6,-6,-6)
	local pos2=vector.offset(pos,6,6,6)
	local nn=minetest.find_nodes_in_area_under_air(pos1, pos2, {"group:dirt"})
	for k,v in pairs(nn) do
		if math.random(vector.distance(pos,v)) < 4 and not (math.abs(pos.x-v.x) == 6 and math.abs(pos.z-v.z) == 6) then --leave out the corners
			minetest.set_node(v,{name="mcl_core:podzol"})
		end
	end
end

function mcl_core.generate_huge_spruce_tree(pos)
	local r1 = math.random(1, 2)
	local r2 = math.random(1, 4)
	local path
	local offset = { x = -4, y = -1, z = -5 }
	if r1 <= 2 then
		-- Mega Spruce Taiga (full canopy)
		path = modpath.."/schematics/mcl_core_spruce_huge_"..r2..".mts"
	else
		-- Mega Taiga (leaves only at top)
		if r2 == 1 or r2 == 3 then
			offset = { x = -3, y = -1, z = -4}
		end
		path = modpath.."/schematics/mcl_core_spruce_huge_up_"..r2..".mts"
	end
	minetest.place_schematic(vector.add(pos, offset), path, "0", nil, false)
	generate_spruce_podzol(pos)
end

-- END of spruce tree functions --

-- Acacia tree (multiple variants)
function mcl_core.generate_acacia_tree(pos)
	local r = math.random(1, 7)
	local offset = vector.new()
	if r == 2 or r == 3 then
		offset = { x = -4, y = -1, z = -4 }
	elseif r == 4 or r == 6 or r == 7 then
		offset = { x = -3, y = -1, z = -3 }
	elseif r == 1 or r == 5 then
		offset = { x = -5, y = -1, z = -5 }
	end
	local path = modpath.."/schematics/mcl_core_acacia_"..r..".mts"
	minetest.place_schematic(vector.add(pos, offset), path, "random", nil, false)
end

-- Generate dark oak tree with 2×2 trunk.
-- With pos being the lower X and the higher Z value of the trunk
function mcl_core.generate_dark_oak_tree(pos)
	local path = modpath.."/schematics/mcl_core_dark_oak.mts"
	minetest.place_schematic({x = pos.x - 3, y = pos.y - 1, z = pos.z - 4}, path, "random", nil, false)
end

-- Helper function for jungle tree, form Minetest Game 0.4.15
local function add_trunk_and_leaves(data, a, pos, tree_cid, leaves_cid,
		height, size, iters)
	local x, y, z = pos.x, pos.y, pos.z
	local c_air = minetest.CONTENT_AIR
	local c_ignore = minetest.CONTENT_IGNORE

	-- Trunk
	data[a:index(x, y, z)] = tree_cid -- Force-place lowest trunk node to replace sapling
	for yy = y + 1, y + height - 1 do
		local vi = a:index(x, yy, z)
		local node_id = data[vi]
		if node_id == c_air or node_id == c_ignore or node_id == leaves_cid then
			data[vi] = tree_cid
		end
	end

	-- Force leaves near the trunk
	for z_dist = -1, 1 do
	for y_dist = -size, 1 do
		local vi = a:index(x - 1, y + height + y_dist, z + z_dist)
		for x_dist = -1, 1 do
			if data[vi] == c_air or data[vi] == c_ignore then
				data[vi] = leaves_cid
			end
			vi = vi + 1
		end
	end
	end

	-- Randomly add leaves in 2x2x2 clusters.
	for i = 1, iters do
		local clust_x = x + math.random(-size, size - 1)
		local clust_y = y + height + math.random(-size, 0)
		local clust_z = z + math.random(-size, size - 1)

		for xi = 0, 1 do
		for yi = 0, 1 do
		for zi = 0, 1 do
			local vi = a:index(clust_x + xi, clust_y + yi, clust_z + zi)
			if data[vi] == c_air or data[vi] == c_ignore then
				data[vi] = leaves_cid
			end
		end
		end
		end
	end
end

-- Old jungle tree grow function from Minetest Game 0.4.15, imitating v6 jungle trees
function mcl_core.generate_v6_jungle_tree(pos)
	--[[
		NOTE: Jungletree-placing code is currently duplicated in the engine
		and in games that have saplings; both are deprecated but not
		replaced yet
	--]]

	local x, y, z = pos.x, pos.y, pos.z
	local height = math.random(8, 12)
	local c_air = minetest.get_content_id("air")
	local c_ignore = minetest.get_content_id("ignore")
	local c_jungletree = minetest.get_content_id("mcl_core:jungletree")
	local c_jungleleaves = minetest.get_content_id("mcl_core:jungleleaves")

	local vm = minetest.get_voxel_manip()
	local minp, maxp = vm:read_from_map(
		{x = x - 3, y = y - 1, z = z - 3},
		{x = x + 3, y = y + height + 1, z = z + 3}
	)
	local a = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
	local data = vm:get_data()

	add_trunk_and_leaves(data, a, pos, c_jungletree, c_jungleleaves, height, 3, 30)

	-- Roots
	for z_dist = -1, 1 do
		local vi_1 = a:index(x - 1, y - 1, z + z_dist)
		local vi_2 = a:index(x - 1, y, z + z_dist)
		for x_dist = -1, 1 do
			if math.random(1, 3) >= 2 then
				if data[vi_1] == c_air or data[vi_1] == c_ignore then
					data[vi_1] = c_jungletree
				elseif data[vi_2] == c_air or data[vi_2] == c_ignore then
					data[vi_2] = c_jungletree
				end
			end
			vi_1 = vi_1 + 1
			vi_2 = vi_2 + 1
		end
	end

	vm:set_data(data)
	vm:write_to_map()
end

function mcl_core.generate_jungle_tree(pos)
	local path = modpath.."/schematics/mcl_core_jungle_tree.mts"
	minetest.place_schematic({x = pos.x - 2, y = pos.y - 1, z = pos.z - 2}, path, "random", nil, false)
end

-- Generate huge jungle tree with 2×2 trunk.
-- With pos being the lower X and the higher Z value of the trunk.
function mcl_core.generate_huge_jungle_tree(pos)
	-- 2 variants
	local r = math.random(1, 2)
	local path = modpath.."/schematics/mcl_core_jungle_tree_huge_"..r..".mts"
	minetest.place_schematic({x = pos.x - 6, y = pos.y - 1, z = pos.z - 7}, path, "random", nil, false)
end


local grass_spread_randomizer = PseudoRandom(minetest.get_mapgen_setting("seed"))

-- Return appropriate grass block node for pos
function mcl_core.get_grass_block_type(pos, requested_grass_block_name)
	local grass_palette_index = mcl_util.get_palette_indexes_from_pos(pos).grass_palette_index
	local grass_block_name = requested_grass_block_name or minetest.get_node(pos).name
	return {name = grass_block_name, param2 = grass_palette_index}
end

-- Return appropriate foliage block node for pos
function mcl_core.get_foliage_block_type(pos)
	return {name = minetest.get_node(pos).name, param2 = mcl_util.get_palette_indexes_from_pos(pos).foliage_palette_index}
end

-- Return appropriate water block node for pos
function mcl_core.get_water_block_type(pos)
	return {name = minetest.get_node(pos).name, param2 = mcl_util.get_palette_indexes_from_pos(pos).water_palette_index}
end

------------------------------
-- Spread grass blocks and mycelium on neighbor dirt
------------------------------
minetest.register_abm({
	label = "Grass Block and Mycelium spread",
	nodenames = {"mcl_core:dirt"},
	neighbors = {"air", "group:grass_block_no_snow", "mcl_core:mycelium"},
	interval = 30,
	chance = 20,
	catch_up = false,
	action = function(pos)
		if pos == nil then return end

		local above = {x=pos.x, y=pos.y+1, z=pos.z}
		local abovenode = minetest.get_node(above)
		if minetest.get_item_group(abovenode.name, "liquid") ~= 0 or minetest.get_item_group(abovenode.name, "opaque") == 1 then
			-- Never grow directly below liquids or opaque blocks
			return
		end

		local light_self = minetest.get_node_light(above)
		if not light_self then return end

		--[[ Try to find a spreading dirt-type block (e.g. grass block or mycelium)
		within a 3×5×3 area, with the source block being on the 2nd-topmost layer. ]]
		local nodes = minetest.find_nodes_in_area({x=pos.x-1, y=pos.y-1, z=pos.z-1}, {x=pos.x+1, y=pos.y+3, z=pos.z+1}, "group:spreading_dirt_type")
		local p2
		-- Nothing found ? Bail out!
		if #nodes <= 0 then
			return
		else
			p2 = nodes[grass_spread_randomizer:next(1, #nodes)]
		end

		-- Found it! Now check light levels!
		local source_above = {x=p2.x, y=p2.y+1, z=p2.z}
		local light_source = minetest.get_node_light(source_above)
		if not light_source then return end

		if light_self >= 4 and light_source >= 9 then
			-- All checks passed! Let's spread the grass/mycelium!

			local n2 = minetest.get_node(p2)
			if minetest.get_item_group(n2.name, "grass_block") ~= 0 then
				n2 = mcl_core.get_grass_block_type(pos, "mcl_core:dirt_with_grass")
			end
			minetest.set_node(pos, {name=n2.name})

			-- If this was mycelium, uproot plant above
			if n2.name == "mcl_core:mycelium" then
				local tad = minetest.registered_nodes[minetest.get_node(above).name]
				if tad and tad.groups and tad.groups.non_mycelium_plant then
					minetest.dig_node(above)
				end
			end
		end
	end
})

-- Grass/mycelium death in darkness
minetest.register_abm({
	label = "Grass Block / Mycelium in darkness",
	nodenames = {"group:spreading_dirt_type"},
	interval = 8,
	chance = 50,
	catch_up = false,
	action = function(pos, node)
		local above = {x = pos.x, y = pos.y + 1, z = pos.z}
		local name = minetest.get_node(above).name
		-- Kill grass/mycelium when below opaque block or liquid
		if name ~= "ignore" and (minetest.get_item_group(name, "opaque") == 1 or minetest.get_item_group(name, "liquid") ~= 0) then
			minetest.set_node(pos, {name = "mcl_core:dirt"})
		end
	end
})

-- Turn Grass Path and similar nodes to Dirt if a solid node is placed above it
minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	if minetest.get_item_group(newnode.name, "solid") ~= 0 or
			minetest.get_item_group(newnode.name, "dirtifier") ~= 0 then
		local below = {x=pos.x, y=pos.y-1, z=pos.z}
		local belownode = minetest.get_node(below)
		if minetest.get_item_group(belownode.name, "dirtifies_below_solid") == 1 then
			minetest.set_node(below, {name="mcl_core:dirt"})
		end
	end
end)

minetest.register_abm({
	label = "Turn Grass Path below solid block into Dirt",
	nodenames = {"mcl_core:grass_path"},
	neighbors = {"group:solid"},
	interval = 8,
	chance = 50,
	action = function(pos, node)
		local above = {x = pos.x, y = pos.y + 1, z = pos.z}
		local name = minetest.get_node(above).name
		local nodedef = minetest.registered_nodes[name]
		if name ~= "ignore" and nodedef and (nodedef.groups and nodedef.groups.solid) then
			minetest.set_node(pos, {name = "mcl_core:dirt"})
		end
	end,
})

local SAVANNA_INDEX = 1
minetest.register_lbm({
	label = "Replace legacy dry grass",
	name = "mcl_core:replace_legacy_dry_grass_0_65_0",
	nodenames = {"mcl_core:dirt_with_dry_grass", "mcl_core:dirt_with_dry_grass_snow"},
	run_at_every_load = true,
	action = function(pos, node)
		if node.name == "mcl_core:dirt_with_dry_grass_snow" then
			node.name = "mcl_core:dirt_with_grass_snow"
		else
			node.name = "mcl_core:dirt_with_grass"
		end
		-- use savanna palette index to simulate dry grass.
		if not node.param2 then
			node.param2 = SAVANNA_INDEX
		end
		minetest.set_node(pos, node)
		return
	end,
})

--------------------------
-- Try generate tree   ---
--------------------------
local treelight = 9

local function sapling_grow_action(tree_id, soil_needed, one_by_one, two_by_two, sapling)
	return function(pos)
		local meta = minetest.get_meta(pos)
		if meta:get("grown") then return end
		-- Checks if the sapling at pos has enough light and the correct soil
		local light = minetest.get_node_light(pos)
		if not light then return end
		local low_light = (light < treelight)

		local delta = 1
		local current_game_time = minetest.get_day_count() + minetest.get_timeofday()

		local last_game_time = tonumber(meta:get_string("last_gametime"))
		meta:set_string("last_gametime", tostring(current_game_time))

		if last_game_time then
			delta = current_game_time - last_game_time
		elseif low_light then
			return
		end

		if low_light then
			if delta < 1.2 then return end
			if minetest.get_node_light(pos, 0.5) < treelight then return end
		end

		-- TODO: delta is [days] missed in inactive area. Currently we just add it to stage, which is far from a perfect calculation...

		local soilnode = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})
		local soiltype = minetest.get_item_group(soilnode.name, "soil_sapling")
		if soiltype < soil_needed then return end

		-- Increase and check growth stage
		local meta = minetest.get_meta(pos)
		local stage = meta:get_int("stage")
		if stage == nil then stage = 0 end
		stage = stage + math.max(1, math.floor(delta))
		if stage >= 3 then
			meta:set_string("grown", "true")
			-- This sapling grows in a special way when there are 4 saplings in a 2×2 pattern
			if two_by_two then
				-- Check 8 surrounding saplings and try to find a 2×2 pattern
				local function is_sapling(pos, sapling)
					return minetest.get_node(pos).name == sapling
				end
				local p2 = {x=pos.x+1, y=pos.y, z=pos.z}
				local p3 = {x=pos.x, y=pos.y, z=pos.z-1}
				local p4 = {x=pos.x+1, y=pos.y, z=pos.z-1}
				local p5 = {x=pos.x-1, y=pos.y, z=pos.z-1}
				local p6 = {x=pos.x-1, y=pos.y, z=pos.z}
				local p7 = {x=pos.x-1, y=pos.y, z=pos.z+1}
				local p8 = {x=pos.x, y=pos.y, z=pos.z+1}
				local p9 = {x=pos.x+1, y=pos.y, z=pos.z+1}
				local s2 = is_sapling(p2, sapling)
				local s3 = is_sapling(p3, sapling)
				local s4 = is_sapling(p4, sapling)
				local s5 = is_sapling(p5, sapling)
				local s6 = is_sapling(p6, sapling)
				local s7 = is_sapling(p7, sapling)
				local s8 = is_sapling(p8, sapling)
				local s9 = is_sapling(p9, sapling)
				-- In a 9×9 field there are 4 possible 2×2 squares. We check them all.
				if s2 and s3 and s4 and check_tree_growth(pos, tree_id, { two_by_two = true }) then
					-- Success: Remove saplings and place tree
					minetest.remove_node(pos)
					minetest.remove_node(p2)
					minetest.remove_node(p3)
					minetest.remove_node(p4)
					mcl_core.generate_tree(pos, tree_id, { two_by_two = true })
					return
				elseif s3 and s5 and s6 and check_tree_growth(p6, tree_id, { two_by_two = true }) then
					minetest.remove_node(pos)
					minetest.remove_node(p3)
					minetest.remove_node(p5)
					minetest.remove_node(p6)
					mcl_core.generate_tree(p6, tree_id, { two_by_two = true })
					return
				elseif s6 and s7 and s8 and check_tree_growth(p7, tree_id, { two_by_two = true }) then
					minetest.remove_node(pos)
					minetest.remove_node(p6)
					minetest.remove_node(p7)
					minetest.remove_node(p8)
					mcl_core.generate_tree(p7, tree_id, { two_by_two = true })
					return
				elseif s2 and s8 and s9 and check_tree_growth(p8, tree_id, { two_by_two = true }) then
					minetest.remove_node(pos)
					minetest.remove_node(p2)
					minetest.remove_node(p8)
					minetest.remove_node(p9)
					mcl_core.generate_tree(p8, tree_id, { two_by_two = true })
					return
				end
			end
				if one_by_one and tree_id == OAK_TREE_ID then
				-- There is a chance that this tree wants to grow as a balloon oak
				if math.random(1, 12) == 1 then
					-- Check if there is room for that
					if check_tree_growth(pos, tree_id, { balloon = true }) then
						minetest.set_node(pos, {name="air"})
						mcl_core.generate_tree(pos, tree_id, { balloon = true })
						return
					end
				end
			end
				-- If this sapling can grow alone
			if one_by_one and check_tree_growth(pos, tree_id) then
				-- Single sapling
				minetest.set_node(pos, {name="air"})
				--local r = math.random(1, 12)
				mcl_core.generate_tree(pos, tree_id)
				return
			end
		else
			meta:set_int("stage", stage)
		end
	end
end

local grow_oak = sapling_grow_action(OAK_TREE_ID, 1, true, false)
local grow_dark_oak = sapling_grow_action(DARK_OAK_TREE_ID, 2, false, true, "mcl_core:darksapling")
local grow_jungle_tree = sapling_grow_action(JUNGLE_TREE_ID, 1, true, true, "mcl_core:junglesapling")
local grow_acacia = sapling_grow_action(ACACIA_TREE_ID, 2, true, false)
local grow_spruce = sapling_grow_action(SPRUCE_TREE_ID, 1, true, true, "mcl_core:sprucesapling")
local grow_birch = sapling_grow_action(BIRCH_TREE_ID, 1, true, false)

function mcl_core.update_sapling_foliage_colors(pos)
	local pos1, pos2 = vector.offset(pos, -8, 0, -8), vector.offset(pos, 8, 30, 8)
	local fnode
	local foliage = minetest.find_nodes_in_area(pos1, pos2, {"group:foliage_palette", "group:foliage_palette_wallmounted"})
	for _, fpos in pairs(foliage) do
		fnode = minetest.get_node(fpos)
		minetest.set_node(fpos, fnode)
	end
end

-- Attempts to grow the sapling at the specified position
-- pos: Position
-- node: Node table of the node at this position, from minetest.get_node
-- Returns true on success and false on failure
function mcl_core.grow_sapling(pos, node)
	local grow
	if node.name == "mcl_core:sapling" then
		grow = grow_oak
	elseif node.name == "mcl_core:darksapling" then
		grow = grow_dark_oak
	elseif node.name == "mcl_core:junglesapling" then
		grow = grow_jungle_tree
	elseif node.name == "mcl_core:acaciasapling" then
		grow = grow_acacia
	elseif node.name == "mcl_core:sprucesapling" then
		grow = grow_spruce
	elseif node.name == "mcl_core:birchsapling" then
		grow = grow_birch
	end
	if grow then
		grow(pos)
		return true
	else
		return false
	end
end

-- TODO: Use better tree models for everything
-- TODO: Support 2×2 saplings

-- Oak tree
minetest.register_abm({
	label = "Oak tree growth",
	nodenames = {"mcl_core:sapling"},
	neighbors = {"group:soil_sapling"},
	interval = 25,
	chance = 2,
	action = grow_oak
})
minetest.register_lbm({
	label = "Add growth for unloaded oak tree",
	name = "mcl_core:lbm_oak",
	nodenames = {"mcl_core:sapling"},
	run_at_every_load = true,
	action = grow_oak
})

-- Dark oak tree
minetest.register_abm({
	label = "Dark oak tree growth",
	nodenames = {"mcl_core:darksapling"},
	neighbors = {"group:soil_sapling"},
	interval = 25,
	chance = 2,
	action = grow_dark_oak
})
minetest.register_lbm({
	label = "Add growth for unloaded dark oak tree",
	name = "mcl_core:lbm_dark_oak",
	nodenames = {"mcl_core:darksapling"},
	run_at_every_load = true,
	action = grow_dark_oak
})

-- Jungle Tree
minetest.register_abm({
	label = "Jungle tree growth",
	nodenames = {"mcl_core:junglesapling"},
	neighbors = {"group:soil_sapling"},
	interval = 25,
	chance = 2,
	action = grow_jungle_tree
})
minetest.register_lbm({
	label = "Add growth for unloaded jungle tree",
	name = "mcl_core:lbm_jungle_tree",
	nodenames = {"mcl_core:junglesapling"},
	run_at_every_load = true,
	action = grow_jungle_tree
})

-- Spruce tree
minetest.register_abm({
	label = "Spruce tree growth",
	nodenames = {"mcl_core:sprucesapling"},
	neighbors = {"group:soil_sapling"},
	interval = 25,
	chance = 2,
	action = grow_spruce
})
minetest.register_lbm({
	label = "Add growth for unloaded spruce tree",
	name = "mcl_core:lbm_spruce",
	nodenames = {"mcl_core:sprucesapling"},
	run_at_every_load = true,
	action = grow_spruce
})

-- Birch tree
minetest.register_abm({
	label = "Birch tree growth",
	nodenames = {"mcl_core:birchsapling"},
	neighbors = {"group:soil_sapling"},
	interval = 25,
	chance = 2,
	action = grow_birch
})
minetest.register_lbm({
	label = "Add growth for unloaded birch tree",
	name = "mcl_core:lbm_birch",
	nodenames = {"mcl_core:birchsapling"},
	run_at_every_load = true,
	action = grow_birch
})

-- Acacia tree
minetest.register_abm({
	label = "Acacia tree growth",
	nodenames = {"mcl_core:acaciasapling"},
	neighbors = {"group:soil_sapling"},
	interval = 20,
	chance = 2,
	action = grow_acacia
})
minetest.register_lbm({
	label = "Add growth for unloaded acacia tree",
	name = "mcl_core:lbm_acacia",
	nodenames = {"mcl_core:acaciasapling"},
	run_at_every_load = true,
	action = grow_acacia
})

local function leafdecay_particles(pos, node)
	minetest.add_particlespawner({
		amount = math.random(10, 20),
		time = 0.1,
		minpos = vector.add(pos, {x=-0.4, y=-0.4, z=-0.4}),
		maxpos = vector.add(pos, {x=0.4, y=0.4, z=0.4}),
		minvel = {x=-0.2, y=-0.2, z=-0.2},
		maxvel = {x=0.2, y=0.1, z=0.2},
		minacc = {x=0, y=-9.81, z=0},
		maxacc = {x=0, y=-9.81, z=0},
		minexptime = 0.1,
		maxexptime = 0.5,
		minsize = 0.5,
		maxsize = 1.5,
		collisiondetection = true,
		vertical = false,
		node = node,
	})
end

local function vinedecay_particles(pos, node)
	local dir = minetest.wallmounted_to_dir(node.param2)
	local relpos1, relpos2
	if dir.x < 0 then
		relpos1 = { x = -0.45, y = -0.4, z = -0.5 }
		relpos2 = { x = -0.4, y = 0.4, z = 0.5 }
	elseif dir.x > 0 then
		relpos1 = { x = 0.4, y = -0.4, z = -0.5 }
		relpos2 = { x = 0.45, y = 0.4, z = 0.5 }
	elseif dir.z < 0 then
		relpos1 = { x = -0.5, y = -0.4, z = -0.45 }
		relpos2 = { x = 0.5, y = 0.4, z = -0.4 }
	elseif dir.z > 0 then
		relpos1 = { x = -0.5, y = -0.4, z = 0.4 }
		relpos2 = { x = 0.5, y = 0.4, z = 0.45 }
	else
		return
	end

	minetest.add_particlespawner({
		amount = math.random(8, 16),
		time = 0.1,
		minpos = vector.add(pos, relpos1),
		maxpos = vector.add(pos, relpos2),
		minvel = {x=-0.2, y=-0.2, z=-0.2},
		maxvel = {x=0.2, y=0.1, z=0.2},
		minacc = {x=0, y=-9.81, z=0},
		maxacc = {x=0, y=-9.81, z=0},
		minexptime = 0.1,
		maxexptime = 0.5,
		minsize = 0.5,
		maxsize = 1.0,
		collisiondetection = true,
		vertical = false,
		node = node,
	})
end

---------------------
-- Vine generating --
---------------------
minetest.register_abm({
	label = "Vines growth",
	nodenames = {"mcl_core:vine"},
	interval = 47,
	chance = 4,
	action = function(pos, node, active_object_count, active_object_count_wider)

		-- First of all, check if we are even supported, otherwise, let's die!
		if not mcl_core.check_vines_supported(pos, node) then
			minetest.remove_node(pos)
			vinedecay_particles(pos, node)
			minetest.check_for_falling(pos)
			return
		end

		-- Add vines below pos (if empty)
		local function spread_down(origin, target, dir, node)
			if math.random(1, 2) == 1 then
				if minetest.get_node(target).name == "air" then
					minetest.add_node(target, {name = "mcl_core:vine", param2 = node.param2})
				end
			end
		end

		-- Add vines above pos if it is backed up
		local function spread_up(origin, target, dir, node)
			local vines_in_area = minetest.find_nodes_in_area({x=origin.x-4, y=origin.y-1, z=origin.z-4}, {x=origin.x+4, y=origin.y+1, z=origin.z+4}, "mcl_core:vine")
			-- Less then 4 vines blocks around the ticked vines block (remember the ticked block is counted by above function as well)
			if #vines_in_area < 5 then
				if math.random(1, 2) == 1 then
					if minetest.get_node(target).name == "air" then
						local backup_dir = minetest.wallmounted_to_dir(node.param2)
						local backup = vector.subtract(target, backup_dir)
						local backupnodename = minetest.get_node(backup).name

						-- Check if the block above is supported
						if mcl_core.supports_vines(backupnodename) then
							minetest.add_node(target, {name = "mcl_core:vine", param2 = node.param2})
						end
					end
				end
			end
		end

		local function spread_horizontal(origin, target, dir, node)
			local vines_in_area = minetest.find_nodes_in_area({x=origin.x-4, y=origin.y-1, z=origin.z-4}, {x=origin.x+4, y=origin.y+1, z=origin.z+4}, "mcl_core:vine")
			-- Less then 4 vines blocks around the ticked vines block (remember the ticked block is counted by above function as well)
			if #vines_in_area < 5 then
				-- Spread horizontally
				local backup_dir = minetest.wallmounted_to_dir(node.param2)
				if not vector.equals(backup_dir, dir) then
					local target_node = minetest.get_node(target)
					if target_node.name == "air" then
						local backup = vector.add(target, backup_dir)
						local backupnodename = minetest.get_node(backup).name
						if mcl_core.supports_vines(backupnodename) then
							minetest.add_node(target, {name = "mcl_core:vine", param2 = node.param2})
						end
					end
				end
			end
		end

		local directions = {
			{ { x= 1, y= 0, z= 0 }, spread_horizontal },
			{ { x=-1, y= 0, z= 0 }, spread_horizontal },
			{ { x= 0, y= 1, z= 0 }, spread_up },
			{ { x= 0, y=-1, z= 0 }, spread_down },
			{ { x= 0, y= 0, z= 1 }, spread_horizontal },
			{ { x= 0, y= 0, z=-1 }, spread_horizontal },
		}

		local d = math.random(1, #directions)
		local dir = directions[d][1]
		local spread = directions[d][2]

		spread(pos, vector.add(pos, dir), dir, node)
	end
})

-- Returns true of the node supports vines
function mcl_core.supports_vines(nodename)
	local def = minetest.registered_nodes[nodename]
	-- Rules: 1) walkable 2) full cube
	return def and def.walkable and
			(def.node_box == nil or def.node_box.type == "regular") and
			(def.collision_box == nil or def.collision_box.type == "regular")
end

-- Leaf Decay
--
-- Whenever a tree trunk node is removed, all `group:leaves` nodes in a radius
-- of 6 blocks are checked from the trunk node's `after_destruct` handler.
-- Any such nodes within that radius that has no trunk node present within a
-- distance of 6 blocks is replaced with a `group:orphan_leaves` node.
--
-- The `group:orphan_leaves` nodes are gradually decayed in this ABM.
minetest.register_abm({
	label = "Leaf decay",
	nodenames = {"group:orphan_leaves"},
	interval = 5,
	chance = 10,
		action = function(pos, node)
		-- Spawn item entities for any of the leaf's drops
		local itemstacks = minetest.get_node_drops(node.name)
		for _, itemname in pairs(itemstacks) do
			local p_drop = vector.offset(pos, math.random() - 0.5, math.random() - 0.5, math.random() - 0.5)
			minetest.add_item(p_drop, itemname)
		end
		-- Remove the decayed node
		minetest.remove_node(pos)
		leafdecay_particles(pos, node)
		minetest.check_for_falling(pos)

		-- Kill depending vines immediately to skip the vines decay delay
		local surround = {
			{ x = 0, y = 0, z = -1 },
			{ x = 0, y = 0, z = 1 },
			{ x = -1, y = 0, z = 0 },
			{ x = 1, y = 0, z = 0 },
			{ x = 0, y = -1, z = -1 },
		}
		for s=1, #surround do
			local spos = vector.add(pos, surround[s])
			local maybe_vine = minetest.get_node(spos)
			--local surround_inverse = vector.multiply(surround[s], -1)
			if maybe_vine.name == "mcl_core:vine" and (not mcl_core.check_vines_supported(spos, maybe_vine)) then
				minetest.remove_node(spos)
				vinedecay_particles(spos, maybe_vine)
				minetest.check_for_falling(spos)
			end
		end
	end
})

-- Remove vines which are not supported by anything, similar to leaf decay.
--[[ TODO: Vines are supposed to die immediately when they supporting block is destroyed.
But doing this in Minetest would be too complicated / hacky. This vines decay is a simple
way to make sure that all floating vines are destroyed eventually. ]]
minetest.register_abm({
	label = "Vines decay",
	nodenames = {"mcl_core:vine"},
	neighbors = {"air"},
	-- A low interval and a high inverse chance spreads the load
	interval = 4,
	chance = 8,
	action = function(p0, node, _, _)
		if not mcl_core.check_vines_supported(p0, node) then
			-- Vines must die!
			minetest.remove_node(p0)
			vinedecay_particles(p0, node)
			-- Just in case a falling node happens to float above vines
			minetest.check_for_falling(p0)
		end
	end
})

-- Melt snow
minetest.register_abm({
	label = "Top snow and ice melting",
	nodenames = {"mcl_core:snow", "mcl_core:ice"},
	interval = 16,
	chance = 8,
	action = function(pos, node)
		if minetest.get_node_light(pos, 0) >= 12 then
			if node.name == "mcl_core:ice" then
				mcl_core.melt_ice(pos)
			else
				minetest.remove_node(pos)
			end
		end
	end
})

-- Freeze water
minetest.register_abm({
	label = "Freeze water in cold areas",
	nodenames = {"mcl_core:water_source", "mclx_core:river_water_source"},
	interval = 32,
	chance = 8,
	action = function(pos, node)
		if mcl_weather.has_snow(pos) then
			node.name = "mcl_core:ice"
			minetest.swap_node(pos, node)
		end
	end
})

--[[ Call this for vines nodes only.
Given the pos and node of a vines node, this returns true if the vines are supported
and false if the vines are currently floating.
Vines are considered “supported” if they face a walkable+solid block or “hang” from a vines node above. ]]
function mcl_core.check_vines_supported(pos, node)
	local supported = false
	local dir = minetest.wallmounted_to_dir(node.param2)
	local pos1 = vector.add(pos, dir)
	local node_neighbor = minetest.get_node(pos1)
	-- Check if vines are attached to a solid block.
	-- If ignore, we assume its solid.
	if node_neighbor.name == "ignore" or mcl_core.supports_vines(node_neighbor.name) then
		supported = true
	elseif dir.y == 0 then
		-- Vines are not attached, now we check if the vines are “hanging” below another vines block
		-- of equal orientation.
		local pos2 = vector.add(pos, {x=0, y=1, z=0})
		local node2 = minetest.get_node(pos2)
		-- Again, ignore means we assume its supported
		if node2.name == "ignore" or (node2.name == "mcl_core:vine" and node2.param2 == node.param2) then
			supported = true
		end
	end
	return supported
end

-- Melt ice at pos. mcl_core:ice MUST be at pos if you call this!
function mcl_core.melt_ice(pos)
	-- Create a water source if ice is destroyed and there was something below it
	local below = {x=pos.x, y=pos.y-1, z=pos.z}
	local belownode = minetest.get_node(below)
	local dim = mcl_worlds.pos_to_dimension(below)
	if dim ~= "nether" and belownode.name ~= "air" and belownode.name ~= "ignore" and belownode.name ~= "mcl_core:void" then
		minetest.set_node(pos, {name="mcl_core:water_source"})
	else
		minetest.remove_node(pos)
	end
	local neighbors = {
		{x=-1, y=0, z=0},
		{x=1, y=0, z=0},
		{x=0, y=-1, z=0},
		{x=0, y=1, z=0},
		{x=0, y=0, z=-1},
		{x=0, y=0, z=1},
	}
	for n=1, #neighbors do
		minetest.check_single_for_falling(vector.add(pos, neighbors[n]))
	end
end

---- FUNCTIONS FOR SNOWED NODES ----
-- These are nodes which change their appearence when they are below a snow cover
-- and turn back into “normal” when the snow cover is removed.

-- Registers a snowed variant of a node (e.g. grass block, podzol, mycelium).
-- * itemstring_snowed: Itemstring of the snowed node to add
-- * itemstring_clear: Itemstring of the original “clear” node without snow
-- * tiles: Optional custom tiles
-- * sounds: Optional custom sounds
-- * clear_colorization: Optional. If true, will clear all paramtype2="color" related node def. fields
-- * desc: Item description
--
-- The snowable nodes also MUST have _mcl_snowed defined to contain the name
-- of the snowed node.
function mcl_core.register_snowed_node(itemstring_snowed, itemstring_clear, tiles, sounds, clear_colorization, desc, grass_palette)
	local def = table.copy(minetest.registered_nodes[itemstring_clear])
	local create_doc_alias
	if def.description then
		create_doc_alias = true
	else
		create_doc_alias = false
	end
	-- Just some group clearing
	def.description = desc
	def._doc_items_longdesc = nil
	def._doc_items_usagehelp = nil
	def._doc_items_create_entry = false
	def.groups.not_in_creative_inventory = 1
	def.groups.grass_palette = grass_palette
	if def.groups.grass_block == 1 then
		def.groups.grass_block_no_snow = nil
		def.groups.grass_block_snow = 1
	end

	-- Enderman must never take this because this block is supposed to be always buried below snow.
	def.groups.enderman_takable = nil

	-- Snowed blocks never spread
	def.groups.spreading_dirt_type = nil

	-- Add the clear node to the item definition for easy lookup
	def._mcl_snowless = itemstring_clear

	-- Note: _mcl_snowed must be added to the clear node manually!

	if not tiles then
		def.tiles = {"default_snow.png", "default_dirt.png", {name="mcl_core_grass_side_snowed.png", tileable_vertical=false}}
	else
		def.tiles = tiles
	end
	if clear_colorization then
		def.paramtype2 = nil
		def.palette = nil
		def.palette_index = nil
		def.color = nil
		def.overlay_tiles = nil
	end
	if not sounds then
		def.sounds = mcl_sounds.node_sound_dirt_defaults({
			footstep = mcl_sounds.node_sound_snow_defaults().footstep,
		})
	else
		def.sounds = sounds
	end

	def._mcl_silk_touch_drop = {itemstring_clear}

	-- Register stuff
	minetest.register_node(itemstring_snowed, def)

	if create_doc_alias and minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", itemstring_clear, "nodes", itemstring_snowed)
	end
end

-- Reverts a snowed dirtlike node at pos to its original snow-less form.
-- This function assumes there is no snow cover node above. This function
-- MUST NOT be called if there is a snow cover node above pos.
function mcl_core.clear_snow_dirt(pos, node)
	local def = minetest.registered_nodes[node.name]
	if def and def._mcl_snowless then
		minetest.swap_node(pos, {name = def._mcl_snowless, param2=node.param2})
	end
end

---- [[[[[ Functions for snowable nodes (nodes that can become snowed). ]]]]] ----
-- Always add these for snowable nodes.

-- on_construct
-- Makes constructed snowable node snowed if placed below a snow cover node.
function mcl_core.on_snowable_construct(pos)
	-- Myself
	local node = minetest.get_node(pos)

	-- Above
	local apos = {x=pos.x, y=pos.y+1, z=pos.z}
	local anode = minetest.get_node(apos)

	-- Make snowed if needed
	if minetest.get_item_group(anode.name, "snow_cover") == 1 then
		local def = minetest.registered_nodes[node.name]
		if def and def._mcl_snowed then
			minetest.swap_node(pos, {name = def._mcl_snowed, param2=node.param2})
		end
	end
end


---- [[[[[ Functions for snow cover nodes. ]]]]] ----

-- A snow cover node is a node which turns a snowed dirtlike --
-- node into its snowed form while it is placed above.
-- MCL2's snow cover nodes are Top Snow (mcl_core:snow) and Snow (mcl_core:snowblock).

-- Always add the following functions to snow cover nodes:

-- on_construct
-- Makes snowable node below snowed.
function mcl_core.on_snow_construct(pos)
	local npos = {x=pos.x, y=pos.y-1, z=pos.z}
	local node = minetest.get_node(npos)
	local def = minetest.registered_nodes[node.name]
	if def and def._mcl_snowed then
		minetest.swap_node(npos, {name = def._mcl_snowed, param2=node.param2})
	end
end
-- after_destruct
-- Clears snowed dirtlike node below.
function mcl_core.after_snow_destruct(pos)
	local nn = minetest.get_node(pos).name
	-- No-op if snow was replaced with snow
	if minetest.get_item_group(nn, "snow_cover") == 1 then
		return
	end
	local npos = {x=pos.x, y=pos.y-1, z=pos.z}
	local node = minetest.get_node(npos)
	mcl_core.clear_snow_dirt(npos, node)
end


-- Obsidian crying

local crobby_particle = {
	velocity = vector.new(0,0,0),
	size = math.random(1.3,2.5),
	texture = "mcl_core_crying_obsidian_tear.png",
	collision_removal = false,
}


minetest.register_abm({
	label = "Obsidian cries",
	nodenames = {"mcl_core:crying_obsidian"},
	interval = 5,
	chance = 10,
	action = function(pos, node)
		minetest.after(math.random(0.1,1.5),function()
			local pt = table.copy(crobby_particle)
			pt.acceleration = vector.new(0,0,0)
			pt.collisiondetection = false
			pt.expirationtime = math.random(0.5,1.5)
			pt.pos = vector.offset(pos,math.random(-0.5,0.5),-0.51,math.random(-0.5,0.5))
			minetest.add_particle(pt)
			minetest.after(pt.expirationtime,function()
				pt.acceleration = vector.new(0,-9,0)
				pt.collisiondetection = true
				pt.expirationtime = math.random(1.2,4.5)
				minetest.add_particle(pt)
			end)
		end)
	end
})
