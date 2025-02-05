-- bonemealing grass nodes
--
-- When bonemealing "mcl_core:dirt_with_grass", it spawns grass and flowers
-- over a 7x7 patch of adjacent grassy nodes.
--
-- Because of potential dependency complications it is not advisable to add
-- callbacks to mcl_core that create dependencies on mods that depend on
-- mcl_core, such as mcl_flowers.
--
-- To work around this restriction, the bonemealing callback is defined here
-- and the _on_bone_meal callback in "mcl_core:dirt_with_grass" node
-- definition is overwritten with it.

local mg_name = minetest.get_mapgen_setting("mg_name")

local flowers_table_simple = {
	"mcl_flowers:dandelion",
	"mcl_flowers:poppy",
}
local flowers_table_plains = {
	"mcl_flowers:dandelion",
	"mcl_flowers:dandelion",
	"mcl_flowers:poppy",
	"mcl_flowers:oxeye_daisy",
	"mcl_flowers:tulip_orange",
	"mcl_flowers:tulip_red",
	"mcl_flowers:tulip_white",
	"mcl_flowers:tulip_pink",
	"mcl_flowers:azure_bluet",
}
local flowers_table_swampland = {
	"mcl_flowers:blue_orchid",
}
local flowers_table_flower_forest = {
	"mcl_flowers:dandelion",
	"mcl_flowers:poppy",
	"mcl_flowers:oxeye_daisy",
	"mcl_flowers:tulip_orange",
	"mcl_flowers:tulip_red",
	"mcl_flowers:tulip_white",
	"mcl_flowers:tulip_pink",
	"mcl_flowers:azure_bluet",
	"mcl_flowers:allium",
}

local biome_flowers_tables = {
	["Plains"] = flowers_table_plains,
	["Plains_beach"] = flowers_table_plains,
	["Plains_ocean"] = flowers_table_plains,
	["Plains_deep_ocean"] = flowers_table_plains,
	["Plains_underground"] = flowers_table_plains,
	["SunflowerPlains"] = flowers_table_plains,
	["SunflowerPlains_ocean"] = flowers_table_plains,
	["SunflowerPlains_deep_ocean"] = flowers_table_plains,
	["SunflowerPlains_underground"] = flowers_table_plains,
	["Swampland"] = flowers_table_swampland,
	["Swampland_shore"] = flowers_table_swampland,
	["Swampland_ocean"] = flowers_table_swampland,
	["Swampland_deep_ocean"] = flowers_table_swampland,
	["Swampland_underground"] = flowers_table_swampland,
	["FlowerForest"] = flowers_table_flower_forest,
	["FlowerForest_beach"] = flowers_table_flower_forest,
	["FlowerForest_ocean"] = flowers_table_flower_forest,
	["FlowerForest_deep_ocean"] = flowers_table_flower_forest,
	["FlowerForest_underground"] = flowers_table_flower_forest,
}

-- Randomly generate flowers, tall grass or nothing
-- pos: node to place into
-- color: param2 value for tall grass
--
local function add_random_flower(pos, color)
	-- 90% tall grass, 10% flower
	local rnd = math.random(1,100)
	if rnd <= 60 then
		minetest.add_node(pos, {name="mcl_flowers:tallgrass", param2=color})
	elseif rnd <= 80 then
		-- double tallgrass
		local toppos = vector.offset(pos, 0, 1, 0)
		local topnode = minetest.get_node(toppos)
		if minetest.registered_nodes[topnode.name].buildable_to then
			minetest.set_node(pos, { name = "mcl_flowers:double_grass", param2 = color })
			minetest.set_node(toppos, { name = "mcl_flowers:double_grass_top", param2 = color })
			return true
		end
	else
		local biome = minetest.get_biome_name(minetest.get_biome_data(pos).biome)
		local flowers_table = biome_flowers_tables[biome] or flowers_table_simple
		minetest.add_node(pos, {name=flowers_table[math.random(1, #flowers_table)]})
	end
end

--- Generate tall grass and random flowers in a 7x7 area
-- Bonemealing callback handler for "mcl_core:dirt_with_grass"
--
local function bonemeal_grass(pointed_thing, placer)
	local pos, below, r, color
	for i = -7, 7 do for j = -7, 7 do for y = -1, 1 do
		pos = vector.offset(pointed_thing.above, i, y, j)
		if minetest.get_node(pos).name == "air" then
			below = minetest.get_node(vector.offset(pos, 0, -1, 0))
			r = ((math.abs(i) + math.abs(j)) / 2)
			if (minetest.get_item_group(below.name, "grass_block_no_snow") == 1) and
					math.random(1, 100) <= 90 / r then
				color = below.param2
				add_random_flower(pos, color)
				if math.random(1,5) == 1 then
					mcl_bone_meal.add_bone_meal_particle(pos)
				end
			end
		end
	end end end
	return true
end

-- Override "mcl_core:dirt_with_grass" bonemealing handler.
local nodename = "mcl_core:dirt_with_grass"
local olddef = minetest.registered_nodes[nodename]
if not olddef then
	minetest.log("warning", "'mcl_core:dirt_with_grass' not registered, cannot add override!")
else
	local oldhandler = olddef._on_bone_meal
	local newhandler = function(itemstack, placer, pointed_thing)
		local res = bonemeal_grass(pointed_thing, placer)
		if oldhandler then
			res = oldhandler(itemstack, placer, pointed_thing) or res
		end
		return res
	end
	minetest.override_item(nodename, {_on_bone_meal = newhandler})
end
