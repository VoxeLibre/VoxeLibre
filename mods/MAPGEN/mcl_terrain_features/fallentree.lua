-- TODO: allow longer logs in MegaTaiga?
local mg_name = core.get_mapgen_setting("mg_name")

local mushrooms = {"mcl_mushrooms:mushroom_brown","mcl_mushrooms:mushroom_red"}
local vprob, mprob = 0.4, 0.25 -- probability of vines, probability of mushrooms

local get_node_name = mcl_vars.get_node_name
local get_node_name_raw = mcl_vars.get_node_name_raw

local overworld = vl_worlds.dimension_by_name("overworld")
assert(overworld)

mcl_structures.register_structure("fallen_tree",{
	rank = 1100, -- after regular trees, but we run in gennotify anyway
	place_on = {"group:grass_block", "group:dirt"}, -- dirt, podzol in mega taiga
	terrain_feature = true,
	noise_params = {
		offset = 0.002,
		scale = 0.003,
		spread = {x = 150, y = 150, z = 150},
		seed = 24533,
		octaves = 3,
		persist = 0.66
	},
	spawn_by = "air",
	num_spawn_by = 2, -- increases success chances below, at low cost
	y_max = overworld.start + overworld.height,
	y_min = core.get_mapgen_setting("water_level"),
	place_func = function(pos,def,pr)
		--currently we have y+1 in mcl_structures API again. pos.y = pos.y + 1 -- structures receive the *ground* position, like schematics
		local tree = core.find_node_near(pos,15,{"group:tree"})
		if not tree then return end
		tree = get_node_name(tree)
		local minlen, maxlen, overlen = 4, 8, 2 -- len is starting at trunk node
		local biome = mg_name ~= "v6" and core.registered_biomes[core.get_biome_name(core.get_biome_data(pos).biome)]
		-- TODO: in the new biomes API, add something like (biome.group.mega_trees or 0) ~= 0
		if biome and (biome.name == "MegaTaiga" or biome.name == "MegaSpruceTaiga" or biome.name == "BirchForestM" or biome.name == "Jungle" or biome.name == "JungleEdge" or biome.name == "JungleM" or biome.name == "JungleEdgeM") then
			minlen, maxlen = 6, 12
		end
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

		---- Ensure we have room for the tree, but allow (A) bridges, (B) overhang
		-- minsupport: first i with solid underneath
		-- maxsupport: last i with solid underneath
		-- minend/maxend: valid interval for end of trunk
		local minsupport, maxsupport, minend, maxend = nil, 1, nil, maxlen
		local targetlen = maxlen -- or pr:next(math.floor((maxlen+minlen)/2), maxlen) -- preferred length
		for i = 0,maxlen do -- zero to also ensure the trunk is not occupied in the meantime
			-- check space
			local n = get_node_name_raw(pos.x + dx * i, pos.y, pos.z + dz * i)
			local nd = core.registered_nodes[n]
			if n ~= "air" and (nd and nd.groups.plant or 0) == 0 then
				if i < minlen then return end
				break
			end
			maxend = i
			-- check if supported from below to find interval of good end values
			local n = get_node_name_raw(pos.x + dx * i, pos.y - 1, pos.z + dz * i)
			local nd = core.registered_nodes[n]
			if n ~= "air" and (nd and (nd.groups.solid or 0) > 0 and (nd.groups.leaves or 0) == 0) and i > 1 then
				if not minsupport then
					if i > overlen + 2 then return end
					minsupport = i
				end
				if not minend and i >= minlen then minend = i end
				maxsupport = i
			else
				-- stop scanning if we are at the desired random length interval
				if minend and i >= maxsupport + overlen then
					if i >= targetlen then break end
					minend = nil
				end
			end
		end
		if not minend then return end
		if minlen > maxend then return end
		minend = math.max(minend, minlen)
		maxend = math.min(maxend, maxsupport + overlen)
		if minend > maxend then return end
		local len = pr:next(minend, maxend)

		---- We can begin placing the tree now:

		-- get the foliage palette for vines:
		if biome and biome._mcl_foliage_palette_index then
			w1 = biome._mcl_foliage_palette_index * 8 + w1
			w2 = biome._mcl_foliage_palette_index * 8 + w2
		end
		-- place the upright tree trunk
		core.swap_node(pos, { name = tree, param2 = 0 })
		-- some are hollow:
		if vl_hollow_logs.logs and pr:next(1,20) == 1 then
			local nam = string.sub(tree, string.find(tree, ":") + 1)
			nam = "vl_hollow_logs:"..nam.."_hollow"
			if core.registered_nodes[nam] then tree = nam end
		end
		local start = 2
		-- for short trees, no gap
		if len <= 4 then
			local n = get_node_name_raw(pos.x + dx, pos.y, pos.z + dz)
			local nd = core.registered_nodes[n]
			if n == "air" or (nd and nd.groups.plant or 0) ~= 0 then
				start = 1
			end
		end
		for i = start,len do
			core.swap_node(vector.offset(pos, dx * i, 0, dz * i), { name = tree, param2 = param2 })
			-- add some vines
			if pr:next(0,1e9)*1e-9 < vprob then
				local side = vector.offset(pos, dx * i + dz, 0, dz * i + dx)
				if get_node_name(side) == "air" then
					core.swap_node(side, { name = "mcl_core:vine", param2 = w1 })
				end
			end
			if pr:next(0,1e9)*1e-9 < vprob then
				local side = vector.offset(pos, dx * i - dz, 0, dz * i - dx)
				if get_node_name(side) == "air" then
					core.swap_node(side, { name = "mcl_core:vine", param2 = w2 })
				end
			end
			local top = vector.offset(pos, dx * i, 1, dz * i)
			local n = get_node_name(top)
			if n ~= "air" then
				local nd = core.registered_nodes[n]
				-- remove leftover double plant tops
				if nd.groups and (nd.groups.double_plant or 0) == 2 then
					core.swap_node(top, {name = "air"})
					n = "air"
				end
			end
			-- add some mushrooms
			if n == "air" and pr:next(0,1e9)*1e-9 < mprob then
				core.swap_node(top, { name = mushrooms[pr:next(1,#mushrooms)], param2 = 12 })
			end
		end
	end
})
