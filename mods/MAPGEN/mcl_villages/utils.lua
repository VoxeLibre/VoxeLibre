-- check the minimum distance of two squares, on axes
-- TODO: make local in village planning code only?
function mcl_villages.check_distance(settlement, cpos, sizex, sizez, limit)
	for i, building in ipairs(settlement) do
		local opos, osizex, osizez = building.pos, building.size.x, building.size.z
		local dx = math.abs(cpos.x - opos.x) - (sizex + osizex) * 0.5
		local dz = math.abs(cpos.z - opos.z) - (sizez + osizez) * 0.5
		if math.max(dx, dz) < limit then return false end
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
		minetest.registered_nodes["mcl_chests:chest"].on_construct(pos)
		-- For MineClone2 after commit 09ab1482b5 (the new entity chests)
		minetest.registered_nodes["mcl_chests:chest_small"].on_construct(pos)
	end
	-- fill chest
	local inv = minetest.get_inventory( {type="node", pos=pos} )
	local function get_treasures(pr)
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
		return mcl_loot.get_multi_loot(loottable, pr)
	end
	mcl_loot.fill_inventory(inv, "main", get_treasures(pr), pr)
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
	local biome_name = minetest.get_biome_name(minetest.get_biome_data(pos).biome)

	-- for now, map to MCLA, later back, so we can keep their rules unchanged
	for _, sub in pairs(mcl_villages.vl_to_mcla) do
		schem_lua = schem_lua:gsub(sub[1], sub[2])
	end

	if mcl_villages.biome_map[biome_name] and mcl_villages.material_substitions[mcl_villages.biome_map[biome_name]] then
		for _, sub in pairs(mcl_villages.material_substitions[mcl_villages.biome_map[biome_name]]) do
			schem_lua = schem_lua:gsub(sub[1], sub[2])
		end
	end

	-- MCLA node names back to VL
	for _, sub in pairs(mcl_villages.mcla_to_vl) do
		schem_lua = schem_lua:gsub(sub[1], sub[2])
	end

	-- Farming: place crops
	if string.find(schem_lua, "mcl_villages:crop_") then
		local map_name = mcl_villages.biome_map[biome_name] or "plains"
		for _, crop in ipairs(mcl_villages.get_crop_types()) do
			if string.find(schem_lua, "mcl_villages:crop_" .. crop) then
				for count = 1, 8 do
					local name = "mcl_villages:crop_" .. crop .. "_" .. count
					local replacement = mcl_villages.get_weighted_crop(map_name, crop, pr)
					schem_lua = schem_lua:gsub(name, replacement or mcl_villages.default_crop)
				end
			end
		end
	end
	return schem_lua
end

-- Persistent registry for villages
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
		minetest.log("info", "Village already exists: " .. name )
		return false
	end
	mod_storage:set_string("mcl_villages." .. name, minetest.serialize({ name = name, data = data }))
	return true
end

