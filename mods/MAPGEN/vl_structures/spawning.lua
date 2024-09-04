-- TODO: move this to the mcl_mobs module?
local mob_cap_player = tonumber(minetest.settings:get("mcl_mob_cap_player")) or 75
local mob_cap_animal = tonumber(minetest.settings:get("mcl_mob_cap_animal")) or 10
local peaceful = minetest.settings:get_bool("only_peaceful_mobs", false)
local mg_name = minetest.get_mapgen_setting("mg_name")
local vector_offset = vector.offset

-- check if a node is an air node
local function is_air(node)
	return node == "air"
	-- todo: or: not walkable and not liquid?
end
-- check if a node is a water node
local function is_water(node)
	return minetest.get_item_group(node.name, "water") ~= 0
	-- return node.name == "mcl_core:water_source" or node.name ~= "mclx_core:river_water_source"
end

--- Spawn mobs for a structure
-- @param mob string: mob to spawn
-- @param spawnon string or table: nodes to spawn on
-- @param p1 vector: Lowest coordinates of range
-- @param p2 vector: Highest coordinates of range
-- @param pr PseudoRandom: random generator
-- @param n number: Number of mobs to spawn
-- @param water boolean: Spawn water mobs
function vl_structures.spawn_mobs(mob,spawnon,p1,p2,pr,n,water)
	n = n or 1
	local sp = {}
	if water then
		local nn = minetest.find_nodes_in_area(p1,p2,spawnon)
		for k,v in pairs(nn) do
			if is_water(minetest.get_node(vector_offset(v,0,1,0))) then
				table.insert(sp,v)
			end
		end
	else
		sp = minetest.find_nodes_in_area_under_air(p1,p2,spawnon)
	end
	table.shuffle(sp)
	local count = 0
	local mob_def = minetest.registered_entities[mob]
	local enabled = (not peaceful) or (mob_def and mob_spawn_class ~= "hostile")
	for _, node in pairs(sp) do
		if enabled and count < n and minetest.add_entity(vector_offset(node, 0, 0.5, 0), mob) then
			count = count + 1
		end
		minetest.get_meta(node):set_string("spawnblock", "yes") -- note: also in peaceful mode!
	end
end

local structure_spawns = {}
--- Structure spawns via ABM
-- @param def table: containing
--   @param name string: Name
--   @param y_min number: minimum height
--   @param y_max number: maximum height
--   @param spawnon table: Node types to spawn on, can also use group:names
--   @param biomes table: Biomes to spawn in
--   @param chance number: Spawn chance, default 5, will trigger 1/chance per-node per-interval
--   @param interval number: Spawn check interval in seconds, default 60.0
--   @param limit number: Local mob cap, default 7
function vl_structures.register_structure_spawn(def)
	minetest.register_abm({
		label = "Spawn "..def.name,
		nodenames = def.spawnon,
		min_y = def.y_min or -31000,
		max_y = def.y_max or 31000,
		interval = def.interval or 60,
		chance = def.chance or 5,
		action = function(pos, node, active_object_count, active_object_count_wider)
			-- FIXME: review this logic, legacy code
			local limit = def.limit or 7
			if active_object_count_wider > limit + mob_cap_animal then return end
			if active_object_count_wider > mob_cap_player then return end
			local p = vector_offset(pos, 0, 1, 0)
			local pnode = minetest.get_node(p)
			if not (def.type_of_spawning == "water" and is_water or is_air)(pnode) then return end
			if minetest.get_meta(pos):get_string("spawnblock") == "" then return end
			if mg_name ~= "v6" and mg_name ~= "singlenode" and def.biomes then
				if table.indexof(def.biomes, minetest.get_biome_name(minetest.get_biome_data(p).biome)) == -1 then
					return
				end
			end
			local mobdef = minetest.registered_entities[def.name]
			if mobdef.can_spawn and not mobdef.can_spawn(p) then return end
			minetest.add_entity(vector_offset(p, 0, -0.5, 0), def.name)
		end,
	})
end

