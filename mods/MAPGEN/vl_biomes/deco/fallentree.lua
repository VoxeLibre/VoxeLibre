-- TODO: allow longer logs in MegaTaiga?
local mg_name = minetest.get_mapgen_setting("mg_name")

local mushrooms = {"mcl_mushrooms:mushroom_brown","mcl_mushrooms:mushroom_red"}

vl_structures.register_structure("fallen_tree",{
	rank = 1100, -- after regular trees
	place_on = {"group:grass_block"},
	terrain_feature = true,
	noise_params = {
		offset = 0.00018,
		scale = 0.01011,
		spread = {x = 250, y = 250, z = 250},
		seed = 24533,
		octaves = 3,
		persist = 0.66
	},
	flags = "place_center_x, place_center_z",
	solid_ground = true,
	y_max = mcl_vars.mg_overworld_max,
	y_min = minetest.get_mapgen_setting("water_level"),
	place_func = function(pos,def,pr)
		local tree = minetest.find_node_near(pos,15,{"group:tree"})
		if not tree then return end
		tree = minetest.get_node(tree).name
		local minlen, maxlen = 3, 9
		local vrate, mrate = 120, 160
		local len = pr:next(minlen,maxlen)
		local dir = pr:next(0,3)
		local dx, dy, dz, param2, w1, w2
		if dir == 0 then
			dx, dy, dz, param2, w1, w2 = 1, 0, 0, 12, 5, 4
		elseif dir == 1 then
			dx, dy, dz, param2, w1, w2 = -1, 0, 0, 12, 4, 5
		elseif dir == 2 then
			dx, dy, dz, param2, w1, w2 = 0, 0, 1, 6, 3, 2
		else -- if dir == 3 then
			dx, dy, dz, param2, w1, w2 = 0, 0, -1, 6, 2, 3
		end
		-- ensure we have room for the tree
		local minsupport, maxsupport = 99, 1
		for i = 1,len do
			-- check below
			local n = minetest.get_node(vector.offset(pos, dx * i, -1, dz * i)).name
			local nd = minetest.registered_nodes[n]
			if n ~= "air" and nd.groups and nd.groups.solid and i > 2 then
				if i < minsupport then minsupport = i end
				maxsupport = i
			end
			-- check space
			local n = minetest.get_node(vector.offset(pos, dx * i, 0, dz * i)).name
			local nd = minetest.registered_nodes[n]
			if n ~= "air" and nd.groups and not nd.groups.plant then
				if i < minlen or pr:next(1, maxsupport) == 1 then return end
				len = i
				break
			end
		end
		if maxsupport - minsupport < minlen then return end
		-- get the foliage palette for vines:
		local biome = mg_name ~= "v6" and minetest.registered_biomes[minetest.get_biome_name(minetest.get_biome_data(pos).biome)]
		if biome and biome._mcl_foliage_palette_index then
			w1 = biome._mcl_foliage_palette_index * 8 + w1
			w2 = biome._mcl_foliage_palette_index * 8 + w2
		end
		len = math.min(len, maxsupport - 1)
		if len < minlen then return end
		-- place the upright tree trunk
		minetest.swap_node(pos, { name = tree, param2 = 0 })
		-- some are hollow:
		if vl_hollow_logs.logs and pr:next(1,20) == 1 then
			local nam = string.sub(tree, string.find(tree, ":") + 1)
			nam = "vl_hollow_logs:"..nam.."_hollow"
			if minetest.registered_nodes[nam] then tree = nam end
		end
		for i = 2,len do
			minetest.swap_node(vector.offset(pos, dx * i, 0, dz * i), { name = tree, param2 = param2 })
			-- add some vines
			if pr:next(0,255) < vrate then
				local side = vector.offset(pos, dx * i + dz, 0, dz * i + dx)
				if minetest.get_node(side).name == "air" then
					minetest.swap_node(side, { name = "mcl_core:vine", param2 = w1 })
				end
			end
			if pr:next(0,255) < vrate then
				local side = vector.offset(pos, dx * i - dz, 0, dz * i - dx)
				if minetest.get_node(side).name == "air" then
					minetest.swap_node(side, { name = "mcl_core:vine", param2 = w2 })
				end
			end
			-- add some mushrooms
			if pr:next(0,255) < mrate then
				local top = vector.offset(pos, dx * i, 1, dz * i)
				if minetest.get_node(top).name == "air" then
					minetest.swap_node(top, { name = mushrooms[pr:next(1,#mushrooms)], param2 = 12 })
				end
			end
		end
	end
})
