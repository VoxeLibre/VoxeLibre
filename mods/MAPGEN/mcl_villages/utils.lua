-------------------------------------------------------------------------------
-- function to copy tables
-------------------------------------------------------------------------------
function mcl_villages.shallowCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		copy[key] = value
	end
	return copy
end

local function is_above_surface(name)
	return name == "air" or
		string.find(name,"grass") or
		string.find(name,"tree") or
		string.find(name,"leaves") or
		string.find(name,"snow") or
		string.find(name,"fern") or
		string.find(name,"flower") or
		string.find(name,"bush")
end
local get_node = mcl_vars.get_node
function mcl_villages.find_surface_down(pos, surface_node)
	local p6 = vector.new(pos)
	surface_node = surface_node or get_node(p6) --, true, 1000000)
	if not surface_node then return end
	for y = p6.y - 1, math.max(0,p6.y - 120), -1 do
		p6.y = y
		local top_node = surface_node
		surface_node = get_node(p6)
		if not surface_node then return nil end
		if is_above_surface(top_node.name) then
			if mcl_villages.surface_mat[surface_node.name] then
				-- minetest.log("verbose", "Found "..surface_node.name.." below "..top_node.name)
				return p6, surface_node.name
			end
		else
			local ndef = minetest.registered_nodes[surface_node.name]
			if ndef and ndef.walkable then
				return nil
			end
		end
	end
end
function mcl_villages.find_surface_up(pos, surface_node)
	local p6 = vector.new(pos)
	surface_node = surface_node or get_node(p6) --, true, 1000000)
	if not surface_node then return end
	for y = p6.y + 1, p6.y + 50 do
		p6.y = y
		local top_node = get_node(p6)
		if not top_node then return nil end
		if is_above_surface(top_node.name) then
			if mcl_villages.surface_mat[surface_node.name] then
				-- minetest.log("verbose","Found "..surface_node.name.." below "..top_node.name)
				p6.y = p6.y - 1
				return p6, surface_node.name
			end
		else
			local ndef = minetest.registered_nodes[surface_node.name]
			if ndef and ndef.walkable then
				return nil
			end
		end
		surface_node = top_node
	end
end
-------------------------------------------------------------------------------
-- function to find surface block y coordinate
-- returns surface postion
-------------------------------------------------------------------------------
function mcl_villages.find_surface(pos, wait)
	local p6 = vector.new(pos)
	if p6.y < 0 then p6.y = 0 end -- start at water level
	local surface_node
	if wait then
		surface_node = get_node(p6, true, 10000000)
	else
		surface_node = get_node(p6)
	end
	-- downward, if starting position is empty
	if is_above_surface(surface_node.name) then
		return mcl_villages.find_surface_down(p6, surface_node)
	else
		return mcl_villages.find_surface_up(p6, surface_node)
	end
end
-------------------------------------------------------------------------------
-- check distance for new building
-------------------------------------------------------------------------------
function mcl_villages.check_distance(settlement_info, building_pos, building_size)
	for i, built_house in ipairs(settlement_info) do
		local dx, dz = building_pos.x - built_house["pos"].x, building_pos.z - built_house["pos"].z
		local dsq = dx*dx+dz*dz
		if dsq < building_size^2 or dsq < built_house["hsize"]^2 then return false end
	end
	return true
end
-------------------------------------------------------------------------------
-- fill chests
-------------------------------------------------------------------------------
function mcl_villages.fill_chest(pos, pr)
	-- initialize chest (mts chests don't have meta)
	local meta = minetest.get_meta(pos)
	if meta:get_string("infotext") ~= "Chest" then
		-- For MineClone2 0.70 or before
		-- minetest.registered_nodes["mcl_chests:chest"].on_construct(pos)
		--
		-- For MineClone2 after commit 09ab1482b5 (the new entity chests)
		minetest.registered_nodes["mcl_chests:chest_small"].on_construct(pos)
	end
	-- fill chest
	local inv = minetest.get_inventory( {type="node", pos=pos} )

	local function get_treasures(prand)
		local loottable = {{
			stacks_min = 3,
			stacks_max = 8,
			items = {
				{ itemstring = "mcl_core:diamond", weight = 3, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_core:iron_ingot", weight = 10, amount_min = 1, amount_max = 5 },
				{ itemstring = "mcl_core:gold_ingot", weight = 5, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_farming:bread", weight = 15, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_core:apple", weight = 15, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_tools:pick_iron", weight = 5 },
				{ itemstring = "mcl_tools:sword_iron", weight = 5 },
				{ itemstring = "mcl_armor:chestplate_iron", weight = 5 },
				{ itemstring = "mcl_armor:helmet_iron", weight = 5 },
				{ itemstring = "mcl_armor:leggings_iron", weight = 5 },
				{ itemstring = "mcl_armor:boots_iron", weight = 5 },
				{ itemstring = "mcl_core:obsidian", weight = 5, amount_min = 3, amount_max = 7 },
				{ itemstring = "mcl_core:sapling", weight = 5, amount_min = 3, amount_max = 7 },
				{ itemstring = "mcl_mobitems:saddle", weight = 3 },
				{ itemstring = "mcl_mobitems:iron_horse_armor", weight = 1 },
				{ itemstring = "mcl_mobitems:gold_horse_armor", weight = 1 },
				{ itemstring = "mcl_mobitems:diamond_horse_armor", weight = 1 },
			}
		}}
		local items = mcl_loot.get_multi_loot(loottable, prand)
		return items
	end

	local items = get_treasures(pr)
	mcl_loot.fill_inventory(inv, "main", items, pr)
end

-------------------------------------------------------------------------------
-- initialize furnace
-------------------------------------------------------------------------------
function mcl_villages.initialize_furnace(pos)
	-- find chests within radius
	local furnacepos = minetest.find_node_near(pos,
		7, --radius
		{"mcl_furnaces:furnace"})
	-- initialize furnacepos (mts furnacepos don't have meta)
	if furnacepos then
		local meta = minetest.get_meta(furnacepos)
		if meta:get_string("infotext") ~= "furnace" then
			minetest.registered_nodes["mcl_furnaces:furnace"].on_construct(furnacepos)
		end
	end
end
-------------------------------------------------------------------------------
-- initialize anvil
-------------------------------------------------------------------------------
function mcl_villages.initialize_anvil(pos)
	-- find chests within radius
	local anvilpos = minetest.find_node_near(pos,
		7, --radius
		{"mcl_anvils:anvil"})
	-- initialize anvilpos (mts anvilpos don't have meta)
	if anvilpos then
		local meta = minetest.get_meta(anvilpos)
		if meta:get_string("infotext") ~= "anvil" then
			minetest.registered_nodes["mcl_anvils:anvil"].on_construct(anvilpos)
		end
	end
end
-------------------------------------------------------------------------------
-- randomize table
-------------------------------------------------------------------------------
function mcl_villages.shuffle(tbl, pr)
	local copy = {}
	for key, value in ipairs(tbl) do
		table.insert(copy, pr:next(1, #copy + 1), value)
	end
	return copy
end

-- Load a schema and replace nodes in it based on biome
function mcl_villages.substitute_materials(pos, schem_lua, pr)
	local modified_schem_lua = schem_lua
	local biome_data = minetest.get_biome_data(pos)
	local biome_name = minetest.get_biome_name(biome_data.biome)

	if mcl_villages.biome_map[biome_name] and mcl_villages.material_substitions[mcl_villages.biome_map[biome_name]] then
		for _, sub in pairs(mcl_villages.material_substitions[mcl_villages.biome_map[biome_name]]) do
			modified_schem_lua = modified_schem_lua:gsub(sub[1], sub[2])
		end
	end

	return modified_schem_lua
end

local villages = {}
local mod_storage = minetest.get_mod_storage()

local function lazy_load_village(name)
	if not villages[name] then
		local data = mod_storage:get("mcl_villages." .. name)
		if data then
			villages[name] = minetest.deserialize(data)
		end
	end
end

function mcl_villages.get_village(name)
	lazy_load_village(name)
	if villages[name] then
		return table.copy(villages[name])
	end
end

function mcl_villages.village_exists(name)
	lazy_load_village(name)
	return villages[name] ~= nil
end

function mcl_villages.add_village(name, data)
	lazy_load_village(name)
	if villages[name] then
		minetest.log("info","Village already exists: " .. name )
		return false
	end

	local new_village = {name = name, data = data}
	mod_storage:set_string("mcl_villages." .. name, minetest.serialize(new_village))
	return true
end
