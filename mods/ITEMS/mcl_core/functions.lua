--
-- Lava vs water interactions
--

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

local mg_name = minetest.get_mapgen_setting("mg_name")

local random = math.random
local sqrt = math.sqrt
local floor = math.floor
local ceil = math.ceil
local abs = math.abs
local max = math.max

local vector_new = vector.new
local vector_zero = vector.zero
local vector_offset = vector.offset
local vector_copy = vector.copy
local vector_add = vector.add
local vector_subtract = vector.subtract
local vector_distance = vector.distance

local OAK_TREE_ID = 1
local DARK_OAK_TREE_ID = 2
local SPRUCE_TREE_ID = 3
local ACACIA_TREE_ID = 4
local JUNGLE_TREE_ID = 5
local BIRCH_TREE_ID = 6
local CHERRY_TREE_ID = 7

minetest.register_abm({
	label = "Lava cooling",
	nodenames = {"group:lava"},
	neighbors = {"group:water"},
	interval = 1,
	chance = 1,
	min_y = mcl_vars.mg_end_min,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local water = minetest.find_nodes_in_area(vector_offset(pos, -1, -1, -1), vector_offset(pos, 1, 1, 1), "group:water")

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
function grow_cactus(pos, node)
	pos.y = pos.y - 1 -- below
	if minetest.get_item_group(minetest.get_node(pos).name, "sand") == 0 then return end
	pos.y = pos.y + 2 -- above
	local above = minetest.get_node(pos).name
	if above == "air" then
		minetest.set_node(pos, {name="mcl_core:cactus"})
		return
	end
	if above ~= "mcl_core:cactus" then return end
	pos.y = pos.y + 1 -- at max height 3
	if minetest.get_node(pos).name == "air" then
		minetest.set_node(pos, {name="mcl_core:cactus"})
	end
end

function grow_reeds(pos, node)
	pos.y = pos.y - 1 -- below
	if minetest.get_item_group(minetest.get_node(pos).name, "soil_sugarcane") == 0 then return end
	pos.y = pos.y + 2 -- above
	local above = minetest.get_node(pos).name
	if above == "air" then
		pos.y = pos.y - 1 -- original position, check for water
		if minetest.find_node_near(pos, 1, {"group:water", "group:frosted_ice"}) == nil then return end
		pos.y = pos.y + 1 -- above
		minetest.set_node(pos, {name="mcl_core:reeds"})
		return
	end
	if above ~= "mcl_core:reeds" then return end
	pos.y = pos.y + 1 -- at max height 3
	if minetest.get_node(pos).name == "air" then
		pos.y = pos.y - 2 -- original position, check for water
		if minetest.find_node_near(pos, 1, {"group:water", "group:frosted_ice"}) == nil then return end
		pos.y = pos.y + 2 -- above
		minetest.set_node(pos, {name="mcl_core:reeds"})
	end
end

-- ABMs


local function drop_attached_node(p)
	local nn = minetest.get_node(p).name
	if nn == "air" or nn == "ignore" then return end
	minetest.remove_node(p)
	for _, item in pairs(minetest.get_node_drops(nn, "")) do
		if item ~= "" then
			minetest.add_item(vector_offset(p, random() * 0.5 - 0.25, random() * 0.5 - 0.25, random() * 0.5 - 0.25), item)
		end
	end
end

-- Helper function for node actions for liquid flow
local function liquid_flow_action(pos, group, action)
	local function check_detach(pos, xp, yp, zp)
		local n = minetest.get_node_or_nil(vector_offset(pos, xp, yp, zp))
		local d = n and minetest.registered_nodes[n.name]
		if not d then return false end
		--[[ Check if we want to perform the liquid action.
		* 1: Item must be in liquid group
		* 2a: If target node is below liquid, always succeed
		* 2b: If target node is horizontal to liquid: succeed if source, otherwise check param2 for horizontal flow direction ]]
		local range = d.liquid_range or 8
		if minetest.get_item_group(n.name, group) ~= 0 and
				(yp > 0 or
				(yp == 0 and (d.liquidtype == "source" or (n.param2 > 8-range and n.param2 < 9)))) then
			action(pos)
		end
	end
	check_detach(pos, -1, 0,  0)
	check_detach(pos,  1, 0,  0)
	check_detach(pos,  0, 0, -1)
	check_detach(pos,  0, 0,  1)
	check_detach(pos,  0, 1,  0)
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
			minetest.remove_node(pos)
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
	chance = 40,
	action = grow_cactus
})

local function is_walkable(pos)
	local ndef = minetest.registered_nodes[minetest.get_node(pos).name]
	return ndef and ndef.walkable
end
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
		if is_walkable(vector_offset(pos,  1, 0,  0))
		or is_walkable(vector_offset(pos, -1, 0,  0))
		or is_walkable(vector_offset(pos,  0, 0,  1))
		or is_walkable(vector_offset(pos,  0, 0, -1)) then
			local lpos = vector_copy(pos)
			local dx, dy
			while true do
				local node = minetest.get_node(lpos)
				if not node or node.name ~= "mcl_core:cactus" then break end
				-- minetest.dig_node ignores protected nodes and causes infinite drop (#4628)
				minetest.remove_node(lpos)
				dx = dx or ((random(0,1)-0.5) * sqrt(random())) * 1.5
				dy = dy or ((random(0,1)-0.5) * sqrt(random())) * 1.5
				local obj = minetest.add_item(vector_offset(lpos, dx, 0.25, dy), "mcl_core:cactus")
				obj:set_velocity(vector_new(dx, 1, dy))
				lpos.y = lpos.y + 1
			end
		end
	end,
})


minetest.register_abm({
	label = "Sugar canes growth",
	nodenames = {"mcl_core:reeds"},
	neighbors = {"group:soil_sugarcane"},
	interval = 25,
	chance = 40,
	action = grow_reeds
})

--
-- Sugar canes drop
--
minetest.register_on_dignode(function(pos, node)
	local name = "mcl_core:reeds"
	local np = vector_offset(pos, 0, 1, 0)
	while minetest.get_node(np).name == name do
		minetest.remove_node(np)
		minetest.add_item(np, name)
		np.y = np.y + 1
	end
end)

-- Check if a node stops a tree from growing. Torches, plants, wood, tree,
-- leaves, dirt and buildable nodes do not affect tree growth.
local function node_stops_growth(node)
	if node.name == "air" then return false end
	local def = minetest.registered_nodes[node.name]
	local groups = def and def.groups
	if not groups then return true end

	return not (groups.leaves or groups.wood or groups.tree or groups.plant or groups.dirt or
	            groups.torch or groups.bark or def.buildable_to)
end

-- Check if a tree can grow at position. The width is the width to check
-- around the tree. A width of 3 and height of 5 will check a 3x3 area, 5
-- nodes above the sapling. If any walkable node other than dirt, wood or
-- leaves occurs in those blocks the tree cannot grow.
local function check_growth_width(pos, width, height)
	-- Huge tree (with even width to check) will check one more node in
	-- positive x and y directions.
	local neg_space, pos_space = floor((width - 1) * 0.5), ceil((width - 1) * 0.5)
	for x = -neg_space, pos_space do
		for z = -neg_space, pos_space do
			for y = 1, height do
				if node_stops_growth(minetest.get_node(vector_offset(pos, x, y, z))) then
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
	elseif tree_id == CHERRY_TREE_ID then
		return check_growth_width(pos, 7, 8)
	end

	return false
end

-- Generates a tree with a type. Options is a table of flags for varieties of
-- trees. The 'two_by_two' option is used by jungle and spruce trees to
-- generate huge trees. The 'balloon' option is used by oak to generate a balloon
-- oak tree.
function mcl_core.generate_tree(pos, tree_type, options)
	if not minetest.get_node_light(pos) then return end

	local two_by_two = options and options.two_by_two
	local balloon = options and options.balloon

	if tree_type == nil or tree_type == OAK_TREE_ID then
		if balloon then
			mcl_core.generate_balloon_oak_tree(pos)
		else
			mcl_core.generate_oak_tree(pos)
		end
	elseif tree_type == DARK_OAK_TREE_ID then
		mcl_core.generate_dark_oak_tree(pos)
	elseif tree_type == SPRUCE_TREE_ID then
		if two_by_two then
			mcl_core.generate_huge_spruce_tree(pos)
		else
			mcl_core.generate_spruce_tree(pos)
		end
	elseif tree_type == ACACIA_TREE_ID then
		mcl_core.generate_acacia_tree(pos)
	elseif tree_type == JUNGLE_TREE_ID then
		if two_by_two then
			mcl_core.generate_huge_jungle_tree(pos)
		else
			mcl_core.generate_jungle_tree(pos)
		end
	elseif tree_type == BIRCH_TREE_ID then
		mcl_core.generate_birch_tree(pos)
	elseif tree_type == CHERRY_TREE_ID and mcl_cherry_blossom then
		mcl_cherry_blossom.generate_cherry_tree(pos)
	end
	mcl_core.update_sapling_foliage_colors(pos)
end

-- Ballon Oak
function mcl_core.generate_balloon_oak_tree(pos)
	if random(1, 12) == 1 then
		-- Small balloon oak
		minetest.place_schematic(vector_offset(pos, -2, -1, -2),
			modpath .. "/schematics/mcl_core_oak_balloon.mts",
			"random", nil, false)
		return
	end
	-- Large balloon oak
	local t = random(1, 4)
	local path = modpath .. "/schematics/mcl_core_oak_large_"..t..".mts"
	if t == 1 or t == 3 then
		minetest.place_schematic(vector_offset(pos, -3, -1, -3), path, "random", nil, false)
	elseif t == 2 or t == 4 then
		minetest.place_schematic(vector_offset(pos, -4, -1, -4), path, "random", nil, false)
	end
end

-- Oak
local path_oak_tree = modpath.."/schematics/mcl_core_oak_classic.mts"
function mcl_core.generate_oak_tree(pos)
	minetest.place_schematic(vector_offset(pos, -2, -1, -2 ), path_oak_tree, "random", nil, false)
end

-- Birch
function mcl_core.generate_birch_tree(pos)
	minetest.place_schematic(vector_offset(pos, -2, -1, -2), modpath ..  "/schematics/mcl_core_birch.mts", "random", nil, false)
end

-- BEGIN of spruce tree generation functions --
-- Copied from Minetest Game 0.4.15 from the pine tree (default.generate_pine_tree)

function mcl_core.generate_spruce_tree(pos)
	minetest.place_schematic(vector_offset(pos, -3, -1, -3),
		modpath .. "/schematics/mcl_core_spruce_"..random(1, 3)..".mts", "0", nil, false)
end

local function find_necorner(p)
	local n = minetest.get_node_or_nil(vector_offset(p, 0, 1, 1))
	local e = minetest.get_node_or_nil(vector_offset(p, 1, 1, 0))
	if n and n.name == "mcl_core:sprucetree" then
		p = vector_offset(p, 0, 0, 1)
	end
	if e and e.name == "mcl_core:sprucetree" then
		p = vector_offset(p, 1, 0, 0)
	end
	return p
end

local function generate_spruce_podzol(ps)
	local pos = find_necorner(ps)
	local pos1, pos2 = vector_offset(pos, -6, -6, -6), vector_offset(pos, 6, 6, 6)
	local nn = minetest.find_nodes_in_area_under_air(pos1, pos2, {"group:dirt"})
	for k,v in pairs(nn) do
		if not (abs(pos.x - v.x) == 6 and abs(pos.z - v.z) == 6) and random(vector_distance(pos,v)) < 4 then --leave out the corners
			minetest.set_node(v, {name="mcl_core:podzol"})
		end
	end
end

function mcl_core.generate_huge_spruce_tree(pos)
	local r1, r2 = random(1, 2), random(1, 4)
	local path, offset
	if r1 <= 2 then
		-- Mega Spruce Taiga (full canopy)
		path = modpath.."/schematics/mcl_core_spruce_huge_"..r2..".mts"
		offset = vector_offset(pos, -4, -1, -5)
	else
		-- Mega Taiga (leaves only at top)
		if r2 == 1 or r2 == 3 then
			offset = vector_offset(pos, -3, -1, -4)
		else
			offset = vector_offset(pos, -4, -1, -5)
		end
		path = modpath.."/schematics/mcl_core_spruce_huge_up_"..r2..".mts"
	end
	minetest.place_schematic(offset, path, "0", nil, false)
	generate_spruce_podzol(pos)
end

-- END of spruce tree functions --

-- Acacia tree (multiple variants)
function mcl_core.generate_acacia_tree(pos)
	local r = random(1, 7)
	local path, offset = modpath.."/schematics/mcl_core_acacia_"..r..".mts", nil
	if r == 1 or r == 5 then
		offset = vector_offset(pos, -5, -1, -5)
	elseif r == 2 or r == 3 then
		offset = vector_offset(pos, -4, -1, -4)
	elseif r == 4 or r == 6 or r == 7 then
		offset = vector_offset(pos, -3, -1, -3)
	end
	minetest.place_schematic(offset, path, "random", nil, false)
end

-- Generate dark oak tree with 2x2 trunk.
-- With pos being the lower X and the higher Z value of the trunk
function mcl_core.generate_dark_oak_tree(pos)
	minetest.place_schematic(vector_offset(pos, -3, -1, -4), modpath.."/schematics/mcl_core_dark_oak.mts", "random", nil, false)
end

-- Helper function for jungle tree, from Minetest Game 0.4.15
local function add_trunk_and_leaves(data, a, pos, tree_cid, leaves_cid, height, size, iters)
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
		local clust_x = x + random(-size, size - 1)
		local clust_y = y + height + random(-size, 0)
		local clust_z = z + random(-size, size - 1)

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

function mcl_core.generate_jungle_tree(pos)
	minetest.place_schematic(vector_offset(pos, -2, -1, -2), modpath.."/schematics/mcl_core_jungle_tree.mts", "random", nil, false)
end

-- Generate huge jungle tree with 2x2 trunk.
-- With pos being the lower X and the higher Z value of the trunk.
function mcl_core.generate_huge_jungle_tree(pos)
	minetest.place_schematic(vector_offset(pos, -6, -1, -7),
		modpath.."/schematics/mcl_core_jungle_tree_huge_"..random(1, 2)..".mts",
		"random", nil, false)
end


local grass_spread_randomizer = PseudoRandom(minetest.get_mapgen_setting("seed"))

-- TODO REMOVE
-- The following 3 functions are deprecated
-- kept for API compatibility for now
-- evaluate impact and remove soon™
function mcl_core.get_grass_block_type(pos, requested_grass_block_name)
	return {name = requested_grass_block_name or minetest.get_node(pos).name, param2 = mcl_util.get_palette_indexes_from_pos(pos).grass_palette_index}
end
function mcl_core.get_foliage_block_type(pos)
	return {name = minetest.get_node(pos).name, param2 = mcl_util.get_palette_indexes_from_pos(pos).foliage_palette_index}
end
function mcl_core.get_water_block_type(pos)
	return {name = minetest.get_node(pos).name, param2 = mcl_util.get_palette_indexes_from_pos(pos).water_palette_index}
end
-- end of deprecated block

------------------------------
-- Spread grass blocks and mycelium on neighbor dirt
------------------------------
minetest.register_abm({
	label = "Grass block and mycelium spread",
	nodenames = {"mcl_core:dirt"},
	neighbors = {"air", "group:grass_block_no_snow", "mcl_core:mycelium"},
	interval = 30,
	chance = 20,
	catch_up = false,
	action = function(pos)
		if pos == nil then return end

		local above = vector_offset(pos, 0, 1, 0)
		local abovenode = minetest.get_node(above)
		if minetest.get_item_group(abovenode.name, "liquid") ~= 0 or minetest.get_item_group(abovenode.name, "opaque") == 1 then
			-- Never grow directly below liquids or opaque blocks
			return
		end

		local light_self = minetest.get_node_light(above)
		if not light_self then return end

		--[[ Try to find a spreading dirt-type block (e.g. grass block or mycelium)
		within a 3x5x3 area, with the source block being on the 2nd-topmost layer. ]]
		local nodes = minetest.find_nodes_in_area(vector_offset(pos, -1, -1, -1), vector_offset(pos, 1, 3, 1), "group:spreading_dirt_type")
		-- Nothing found ? Bail out!
		if #nodes <= 0 then return end
		local p2 = nodes[grass_spread_randomizer:next(1, #nodes)]

		-- Found it! Now check light levels!
		local source_above = vector_offset(p2, 0, 1, 0)
		local light_source = minetest.get_node_light(source_above)
		if not light_source then return end

		if light_self >= 4 and light_source >= 9 then
			-- All checks passed! Let's spread the grass/mycelium!

			local n2 = minetest.get_node(p2)
			if minetest.get_item_group(n2.name, "grass_block") ~= 0 then
				n2 = {
					name = "mcl_core:dirt_with_grass",
					param2 = mcl_util.get_palette_indexes_from_pos(pos).grass_palette_index
				}
			end
			minetest.set_node(pos, n2)

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
	label = "Grass block / mycelium in darkness",
	nodenames = {"group:spreading_dirt_type"},
	interval = 8,
	chance = 50,
	catch_up = false,
	action = function(pos, node)
		local above = minetest.get_node(vector_offset(pos, 0, 1, 0)).name
		-- Kill grass/mycelium when below opaque block or liquid
		if above ~= "ignore" and (minetest.get_item_group(above, "opaque") == 1 or minetest.get_item_group(above, "liquid") ~= 0) then
			minetest.set_node(pos, {name = "mcl_core:dirt"})
		end
	end
})

-- Turn Grass Path and similar nodes to Dirt if a solid node is placed above it
minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	if minetest.get_item_group(newnode.name, "solid") ~= 0 or minetest.get_item_group(newnode.name, "dirtifier") ~= 0 then
		local below = vector_offset(pos, 0, -1, 0)
		local belownode = minetest.get_node(below)
		if minetest.get_item_group(belownode.name, "dirtifies_below_solid") == 1 then
			minetest.set_node(below, {name="mcl_core:dirt"})
		end
	end
end)

minetest.register_abm({
	label = "Turn grass path below solid block into dirt",
	nodenames = {"mcl_core:grass_path"},
	neighbors = {"group:solid"},
	interval = 8,
	chance = 50,
	action = function(pos, node)
		local above = minetest.get_node(vector_offset(pos, 0, 1, 0)).name
		if above == "ignore" then return end
		local nodedef = minetest.registered_nodes[above]
		if nodedef and (nodedef.groups and nodedef.groups.solid) then
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
		node.name = node.name == "mcl_core:dirt_with_dry_grass_snow" and "mcl_core:dirt_with_grass_snow" or "mcl_core:dirt_with_grass"
		-- use savanna palette index to simulate dry grass.
		node.param2 = node.param2 or SAVANNA_INDEX
		minetest.set_node(pos, node)
	end,
})

--------------------------
-- Try generate tree   ---
--------------------------
local TREE_MINIMUM_LIGHT = 9

local function sapling_grow_action(tree_id, soil_needed, one_by_one, two_by_two, sapling)
	return function(pos, node, grow_by)
		local meta = minetest.get_meta(pos)
		-- Checks if the sapling at pos has enough light and the correct soil
		local light = minetest.get_node_light(pos)
		if not light or light < TREE_MINIMUM_LIGHT then return end

		local soilnode = minetest.get_node(vector_offset(pos, 0, -1, 0))
		local soiltype = minetest.get_item_group(soilnode.name, "soil_sapling")
		if soiltype < soil_needed then return end

		-- Increase and check growth stage
		local meta = minetest.get_meta(pos)
		local stage = (meta:get_int("stage") or 0) + (grow_by or 1)
		if stage < 3 then
			meta:set_int("stage", stage)
			return
		end
		-- This sapling grows in a special way when there are 4 saplings in a 2x2 pattern
		if two_by_two then
			-- Check 8 surrounding saplings and try to find a 2x2 pattern
			-- clockwise from x+1, coded right/bottom/left/top
			local prr = vector_offset(pos,  1, 0,  0) -- right
			local prb = vector_offset(pos,  1, 0, -1) -- right bottom
			local pbb = vector_offset(pos,  0, 0, -1) -- bottom
			local pbl = vector_offset(pos, -1, 0, -1) -- bottom left
			local pll = vector_offset(pos, -1, 0,  0) -- left
			local plt = vector_offset(pos, -1, 0,  1) -- left top
			local ptt = vector_offset(pos,  0, 0,  1) -- top
			local ptr = vector_offset(pos,  1, 0,  1) -- top right
			local srr = minetest.get_node(prr).name == sapling
			local srb = minetest.get_node(prb).name == sapling
			local sbb = minetest.get_node(pbb).name == sapling
			local sbl = minetest.get_node(pbl).name == sapling
			local sll = minetest.get_node(pll).name == sapling
			local slt = minetest.get_node(plt).name == sapling
			local stt = minetest.get_node(ptt).name == sapling
			local str = minetest.get_node(ptr).name == sapling
			-- In a 3x3 field there are 4 possible 2x2 squares. We check them all.
			if srr and srb and sbb and check_tree_growth(pos, tree_id, { two_by_two = true }) then
				-- Success: Remove saplings and place tree
				minetest.remove_node(pos)
				minetest.remove_node(prr)
				minetest.remove_node(prb)
				minetest.remove_node(pbb)
				mcl_core.generate_tree(pos, tree_id, { two_by_two = true }) -- center is top-left of 2x2
				return
			elseif sbb and sbl and sll and check_tree_growth(pll, tree_id, { two_by_two = true }) then
				minetest.remove_node(pos)
				minetest.remove_node(pbb)
				minetest.remove_node(pbl)
				minetest.remove_node(pll)
				mcl_core.generate_tree(pll, tree_id, { two_by_two = true }) -- ll is top-left of 2x2
				return
			elseif sll and slt and stt and check_tree_growth(plt, tree_id, { two_by_two = true }) then
				minetest.remove_node(pos)
				minetest.remove_node(pll)
				minetest.remove_node(plt)
				minetest.remove_node(ptt)
				mcl_core.generate_tree(plt, tree_id, { two_by_two = true }) -- lt is top-left of 2x2
				return
			elseif stt and str and srr and check_tree_growth(ptt, tree_id, { two_by_two = true }) then
				minetest.remove_node(pos)
				minetest.remove_node(ptt)
				minetest.remove_node(ptr)
				minetest.remove_node(prr)
				mcl_core.generate_tree(ptt, tree_id, { two_by_two = true }) -- tt is top-left of 2x2
				return
			end
		end
			if one_by_one and tree_id == OAK_TREE_ID then
			-- There is a chance that this tree wants to grow as a balloon oak
			if random(1, 12) == 1 then
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
			mcl_core.generate_tree(pos, tree_id)
			return
		end
	end
end

local grow_oak = sapling_grow_action(OAK_TREE_ID, 1, true, false)
local grow_dark_oak = sapling_grow_action(DARK_OAK_TREE_ID, 2, false, true, "mcl_core:darksapling")
local grow_jungle_tree = sapling_grow_action(JUNGLE_TREE_ID, 1, true, true, "mcl_core:junglesapling")
local grow_acacia = sapling_grow_action(ACACIA_TREE_ID, 2, true, false)
local grow_spruce = sapling_grow_action(SPRUCE_TREE_ID, 1, true, true, "mcl_core:sprucesapling")
local grow_birch = sapling_grow_action(BIRCH_TREE_ID, 1, true, false)
local grow_cherry = sapling_grow_action(CHERRY_TREE_ID, 1, true, false)
-- export for cherry tree module
mcl_core.grow_cherry = grow_cherry

function mcl_core.update_sapling_foliage_colors(pos)
	local foliage = minetest.find_nodes_in_area(
		vector_offset(pos, -8, 0, -8), vector_offset(pos, 8, 30, 8),
		{"group:foliage_palette", "group:foliage_palette_wallmounted"})
	for _, fpos in pairs(foliage) do
		minetest.set_node(fpos, minetest.get_node(fpos))
	end
end

--- Attempts to grow the sapling at the specified position
-- pos: Position
-- node: Node table of the node at this position, from minetest.get_node
-- Returns true on success and false on failure
-- TODO: replace this with a proper tree API
function mcl_core.grow_sapling(pos, node, stages)
	if node.name == "mcl_core:sapling" then
		grow_oak(pos, node, nil, nil, stages)
	elseif node.name == "mcl_core:darksapling" then
		grow_dark_oak(pos, node, nil, nil, stages)
	elseif node.name == "mcl_core:junglesapling" then
		grow_jungle_tree(pos, node, nil, nil, stages)
	elseif node.name == "mcl_core:acaciasapling" then
		grow_acacia(pos, node, nil, nil, stages)
	elseif node.name == "mcl_core:sprucesapling" then
		grow_spruce(pos, node, nil, nil, stages)
	elseif node.name == "mcl_core:birchsapling" then
		grow_birch(pos, node, nil, nil, stages)
	elseif node.name == "mcl_cherry_blossom:cherrysapling" then
		grow_cherry(pos, node, nil, nil, stages)
	else
		return false
	end
	return true
end

-- Oak tree
minetest.register_abm({
	label = "Oak tree growth",
	nodenames = {"mcl_core:sapling"},
	neighbors = {"group:soil_sapling"},
	interval = 30,
	chance = 3,
	action = function(pos, node)
		grow_oak(pos, node, 1)
	end
})

-- Dark oak tree
minetest.register_abm({
	label = "Dark oak tree growth",
	nodenames = {"mcl_core:darksapling"},
	neighbors = {"group:soil_sapling"},
	interval = 30,
	chance = 3,
	action = function(pos, node)
		grow_dark_oak(pos, node, 1)
	end
})

-- Jungle Tree
minetest.register_abm({
	label = "Jungle tree growth",
	nodenames = {"mcl_core:junglesapling"},
	neighbors = {"group:soil_sapling"},
	interval = 30,
	chance = 3,
	action = function(pos, node)
		grow_jungle_tree(pos, node, 1)
	end
})

-- Spruce tree
minetest.register_abm({
	label = "Spruce tree growth",
	nodenames = {"mcl_core:sprucesapling"},
	neighbors = {"group:soil_sapling"},
	interval = 30,
	chance = 3,
	action = function(pos, node)
		grow_spruce(pos, node, 1)
	end
})

-- Birch tree
minetest.register_abm({
	label = "Birch tree growth",
	nodenames = {"mcl_core:birchsapling"},
	neighbors = {"group:soil_sapling"},
	interval = 30,
	chance = 3,
	action = function(pos, node)
		grow_birch(pos, node, 1)
	end
})

-- Acacia tree
minetest.register_abm({
	label = "Acacia tree growth",
	nodenames = {"mcl_core:acaciasapling"},
	neighbors = {"group:soil_sapling"},
	interval = 30,
	chance = 3,
	action = function(pos, node)
		grow_acacia(pos, node, 1)
	end
})

minetest.register_lbm({
	label = "Add growth for trees in unloaded blocks",
	name = "mcl_core:tree_sapling_growth",
	nodenames = { "group:sapling" },
	neighbors = {"group:soil_sapling"},
	run_at_every_load = true,
	action = function(pos, node, dtime_s)
		-- right now, all trees have 1/(30*3) chance
		-- TODO: make this an API similar to farming
		local interval, chance = 30, 3
		local rolls = floor(dtime_s / interval)
		if rolls <= 0 then return end
		-- simulate how often the block will be ticked
		local stages = 0
		for i = 1,rolls do
			if random(1, chance) == 1 then stages = stages + 1 end
		end
		if stages > 0 then
			mcl_core.grow_sapling(pos, node, stages)
		end
	end,
})


local function leafdecay_particles(pos, node)
	minetest.add_particlespawner({
		amount = random(10, 20),
		time = 0.1,
		minpos = vector_offset(pos, -0.4, -0.4, -0.4),
		maxpos = vector_offset(pos, 0.4, 0.4, 0.4),
		minvel = vector_new(-0.2, -0.2, -0.2),
		maxvel = vector_new(0.2, 0.1, 0.2),
		minacc = vector_new(0, -9.81, 0),
		maxacc = vector_new(0, -9.81, 0),
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
	if not dir then return end -- Don't crash if the map data got corrupted somehow
	local minpos, maxpos
	if dir.x < 0 then
		minpos = vector_offset(pos, -0.45, -0.4, -0.5)
		maxpos = vector_offset(pos, -0.4,   0.4,  0.5)
	elseif dir.x > 0 then
		minpos = vector_offset(pos,  0.4,  -0.4, -0.5)
		maxpos = vector_offset(pos,  0.45,  0.4,  0.5)
	elseif dir.z < 0 then
		minpos = vector_offset(pos, -0.5,  -0.4, -0.45)
		maxpos = vector_offset(pos,  0.5,   0.4, -0.4)
	elseif dir.z > 0 then
		minpos = vector_offset(pos, -0.5,  -0.4,  0.4)
		maxpos = vector_offset(pos,  0.5,   0.4,  0.45)
	else
		return
	end

	minetest.add_particlespawner({
		amount = random(8, 16),
		time = 0.1,
		minpos = minpos,
		maxpos = maxpos,
		minvel = vector_new(-0.2, -0.2, -0.2),
		maxvel = vector_new( 0.2,  0.1,  0.2),
		minacc = vector_new(0, -9.81, 0),
		maxacc = vector_new(0, -9.81, 0),
		minexptime = 0.1,
		maxexptime = 0.5,
		minsize = 0.5,
		maxsize = 1.0,
		collisiondetection = true,
		vertical = false,
		node = node,
	})
end

-----------------
-- Vine growth --
-----------------
-- Add vines below pos (if empty)
local function vine_spread_down(origin, node)
	if random(1, 2) == 1 then return end
	local target = vector_offset(origin, 0, -1, 0)
	if minetest.get_node(target).name == "air" then
		minetest.add_node(target, {name = "mcl_core:vine", param2 = node.param2})
	end
end

-- Add vines above pos if it is backed up
local function vine_spread_up(origin, node)
	if random(1, 2) == 1 then return end
	local vines_in_area = minetest.find_nodes_in_area(vector_offset(origin, -4, -1, -4), vector_offset(origin, 4, 1, 4), "mcl_core:vine")
	-- Less than 4 other vines blocks around the ticked vines block (remember the ticked block is counted by above function as well)
	if #vines_in_area >= 5 then return end
	local target = vector_offset(origin, 0, 1, 0)
	if minetest.get_node(target).name ~= "air" then return end
	local backupnodename = minetest.get_node(vector_subtract(target, minetest.wallmounted_to_dir(node.param2))).name

	-- Check if the block above is supported
	if mcl_core.supports_vines(backupnodename) then
		minetest.add_node(target, {name = "mcl_core:vine", param2 = node.param2})
	end
end

local function vine_spread_horizontal(origin, dir, node)
	local vines_in_area = minetest.find_nodes_in_area(vector_offset(origin, -4, -1, -4), vector_offset(origin, 4, 1, 4), "mcl_core:vine")
	if #vines_in_area >= 5 then return end
	-- Less than 4 other vines blocks around the ticked vines block (remember the ticked block is counted by above function as well)
	local target = vector_add(origin, dir)
	-- Spread horizontally, but not into support direction
	local backup_dir = minetest.wallmounted_to_dir(node.param2)
	if backup_dir.x == dir.x and backup_dir.y == dir.y then return end
	local target_node = minetest.get_node(target)
	if target_node.name ~= "air" then return end
	local backupnodename = minetest.get_node(vector_add(target, backup_dir)).name
	if mcl_core.supports_vines(backupnodename) then
		minetest.add_node(target, {name = "mcl_core:vine", param2 = node.param2})
	end
end

---------------------
-- Vine generating --
---------------------
local do_vines_spread = vl_tuning.setting("gamerule:doVinesSpread", "bool", {
	description = S("Whether vines can spread to other blocks. Cave vines, weeping vines, and twisting vines are not affected."),
	default = true,
})
minetest.register_abm({
	label = "Vine growth",
	nodenames = {"mcl_core:vine"},
	interval = 47,
	chance = 4,
	action = function(pos, node, active_object_count, active_object_count_wider)
		-- First of all, check if we are even supported, otherwise, decay.
		if not do_vines_spread[1] then return end

		-- First of all, check if we are even supported, otherwise, let's die!
		if not mcl_core.check_vines_supported(pos, node) then
			minetest.remove_node(pos)
			vinedecay_particles(pos, node)
			minetest.check_for_falling(pos)
			return
		end

		local d = random(1, 6)
		if d == 1 then
			vine_spread_horizontal(pos, vector_new( 1,  0,  0), node)
		elseif d == 2 then
			vine_spread_horizontal(pos, vector_new(-1,  0,  0), node)
		elseif d == 3 then
			vine_spread_horizontal(pos, vector_new( 0,  0,  1), node)
		elseif d == 4 then
			vine_spread_horizontal(pos, vector_new( 0,  0, -1), node)
		elseif d == 5 then
			vine_spread_up(pos, node)
		else
			vine_spread_down(pos, node)
		end
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
			minetest.add_item(vector_offset(pos, random() - 0.5, random() - 0.5, random() - 0.5), itemname)
		end
		-- Remove the decayed node
		minetest.remove_node(pos)
		leafdecay_particles(pos, node)
		minetest.check_for_falling(pos)

		-- Kill depending vines immediately to skip the vines decay delay
		local function clean_vines(spos)
			local maybe_vine = minetest.get_node(spos)
			if maybe_vine.name == "mcl_core:vine" and (not mcl_core.check_vines_supported(spos, maybe_vine)) then
				minetest.remove_node(spos)
				vinedecay_particles(spos, maybe_vine)
				minetest.check_for_falling(spos)
			end
		end
		clean_vines(vector_offset(pos,  0,  0, -1))
		clean_vines(vector_offset(pos,  0,  0,  1))
		clean_vines(vector_offset(pos, -1,  0,  0))
		clean_vines(vector_offset(pos,  1,  0,  0))
		clean_vines(vector_offset(pos,  0, -1,  0))
	end
})

-- Remove vines which are not supported by anything, similar to leaf decay.
--[[ TODO: Vines are supposed to die immediately when they supporting block is destroyed.
But doing this in Luanti would be too complicated / hacky. This vines decay is a simple
way to make sure that all floating vines are destroyed eventually. ]]
minetest.register_abm({
	label = "Vines decay",
	nodenames = {"mcl_core:vine"},
	neighbors = {"air"},
	-- A low interval and a high inverse chance spreads the load
	interval = 4,
	chance = 8,
	action = function(pos, node)
		if not mcl_core.check_vines_supported(pos, node) then
			minetest.remove_node(pos)
			vinedecay_particles(pos, node)
			minetest.check_for_falling(pos)
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
		if mcl_weather.has_snow(pos)
				and minetest.get_natural_light(vector_offset(pos, 0, 1, 0), 0.5) == minetest.LIGHT_MAX + 1
				and minetest.get_artificial_light(minetest.get_node(pos).param1) < 10 then
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
	local dir = minetest.wallmounted_to_dir(node.param2)
	if not dir then return end -- Don't crash if the map data got corrupted somehow
	local node_neighbor = minetest.get_node(vector_add(pos, dir))
	-- Check if vines are attached to a solid block, assume "ignore" is good.
	if node_neighbor.name == "ignore" or mcl_core.supports_vines(node_neighbor.name) then return true end
	if dir.y == 0 then
		-- Vines are not attached, now we check if the vines are “hanging” below another vines block
		-- of equal orientation.
		local node2 = minetest.get_node(vector_offset(pos, 0, 1, 0))
		if node2.name == "ignore" or (node2.name == "mcl_core:vine" and node2.param2 == node.param2) then
			return true
		end
	end
	return false
end

-- Melt ice at pos. mcl_core:ice MUST be at pos if you call this!
function mcl_core.melt_ice(pos)
	-- Create a water source if ice is destroyed and there was something below it
	local below = vector_offset(pos, 0, -1, 0)
	local dim = mcl_worlds.pos_to_dimension(below)
	local belownode = minetest.get_node(below)
	if dim == "nether" or belownode.name == "air" or belownode.name == "ignore" or belownode.name == "mcl_core:void" then
		minetest.remove_node(pos)
	else
		minetest.set_node(pos, {name="mcl_core:water_source"})
	end
	minetest.check_single_for_falling(vector_offset(pos, -1,  0,  0))
	minetest.check_single_for_falling(vector_offset(pos,  1,  0,  0))
	minetest.check_single_for_falling(vector_offset(pos,  0, -1,  0))
	minetest.check_single_for_falling(vector_offset(pos,  0,  1,  0))
	minetest.check_single_for_falling(vector_offset(pos,  0,  0, -1))
	minetest.check_single_for_falling(vector_offset(pos,  0,  0,  1))
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

	def.tiles = tiles or {"default_snow.png", "default_dirt.png", {name="mcl_core_grass_side_snowed.png", tileable_vertical=false}}
	if clear_colorization then
		def.paramtype2 = nil
		def.palette = nil
		def.palette_index = nil
		def.color = nil
		def.overlay_tiles = nil
	end
	def.sounds = sounds or mcl_sounds.node_sound_dirt_defaults({footstep = mcl_sounds.node_sound_snow_defaults().footstep})

	def._mcl_silk_touch_drop = {itemstring_clear}

	-- Register stuff
	minetest.register_node(itemstring_snowed, def)

	if def.description and minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", itemstring_clear, "nodes", itemstring_snowed)
	end
end

-- Reverts a snowed dirtlike node at pos to its original snow-less form.
-- This function assumes there is no snow cover node above. This function
-- MUST NOT be called if there is a snow cover node above pos.
function mcl_core.clear_snow_dirt(pos, node)
	local def = minetest.registered_nodes[node.name]
	if def and def._mcl_snowless then
		minetest.swap_node(pos, {name = def._mcl_snowless, param2 = node.param2})
	end
end

---- [[[[[ Functions for snowable nodes (nodes that can become snowed). ]]]]] ----
-- Always add these for snowable nodes.

-- on_construct
-- Makes constructed snowable node snowed if placed below a snow cover node.
function mcl_core.on_snowable_construct(pos)
	local above = minetest.get_node(vector_offset(pos, 0, 1, 0)).name
	-- Make snowed if needed
	if minetest.get_item_group(above.name, "snow_cover") == 1 then
		local node = minetest.get_node(pos)
		local def = minetest.registered_nodes[node.name]
		if def and def._mcl_snowed then
			minetest.swap_node(pos, {name = def._mcl_snowed, param2 = node.param2})
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
	local below = vector_offset(pos, 0, -1, 0)
	local node = minetest.get_node(below)
	local def = minetest.registered_nodes[node.name]
	if def and def._mcl_snowed then
		minetest.swap_node(below, {name = def._mcl_snowed, param2 = node.param2})
	end
end
-- after_destruct
-- Clears snowed dirtlike node below.
function mcl_core.after_snow_destruct(pos)
	if minetest.get_item_group(minetest.get_node(pos).name, "snow_cover") == 1 then return end
	local below = vector_offset(pos, 0, -1, 0)
	mcl_core.clear_snow_dirt(below, minetest.get_node(below))
end


-- Obsidian crying
local crobby_particle = {
	velocity = vector_zero(),
	acceleration = vector_zero(),
	texture = "mcl_core_crying_obsidian_tear.png",
	collisiondetection = false,
	collision_removal = false,
}

minetest.register_abm({
	label = "Obsidian cries",
	nodenames = {"mcl_core:crying_obsidian"},
	interval = 5,
	chance = 10,
	action = function(pos, node)
		local below = minetest.get_node(vector.offset(pos, 0, -1, 0))
		local ndef = minetest.registered_nodes[below.name]
		if not ndef then return end -- ignore, most likely not loaded
		if ndef.walkable and (ndef.node_box == nil or ndef.node_box.type == "regular")
			         and (ndef.collision_box == nil or ndef.collision_box.type == "regular") then
			return -- completely solid block
		end
		minetest.after(0.1 + random() * 1.4, function()
			local pt = table.copy(crobby_particle)
			pt.size = 1.3 + random() * 1.2
			pt.expirationtime = 0.5 + random()
			pt.pos = vector_offset(pos, random() - 0.5, -0.51, random() - 0.5)
			minetest.add_particle(pt)
			minetest.after(pt.expirationtime, function()
				pt.acceleration = vector_new(0, -9, 0)
				pt.collisiondetection = true
				pt.expirationtime = 1.2 + random() * 3.3
				minetest.add_particle(pt)
			end)
		end)
	end
})
