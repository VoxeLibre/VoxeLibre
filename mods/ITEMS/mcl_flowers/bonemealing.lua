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
-- and the _mcl_on_bonemealing callback in "mcl_core:dirt_with_grass" node
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
	if math.random(1,100) <= 90 then
		minetest.add_node(pos, {name="mcl_flowers:tallgrass", param2=color})
	else
		local flowers_table
		if mg_name == "v6" then
			flowers_table = flowers_table_plains
		else
			local biome = minetest.get_biome_name(minetest.get_biome_data(pos).biome)
			flowers_table = biome_flowers_tables[biome] or flowers_table_simple
		end
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
			end
		end
	end end end
	return true
end

-- Overwrite "mcl_core:dirt_with_grass" bonemealing handler.
local nodename = "mcl_core:dirt_with_grass"
local olddef = minetest.registered_nodes[nodename]
if not olddef then
	minetest.log("warning", "'mcl_core:dirt_with_grass' not registered, cannot add override!")
else
	local oldhandler = olddef._mcl_on_bonemealing
	local newdef = table.copy(olddef)
	newdef._mcl_on_bonemealing = function (pointed_thing, placer)
		bonemeal_grass(pointed_thing, placer)
		if oldhandler then
			oldhandler(pointed_thing, placer)
		end
	end
	minetest.register_node(":" .. nodename, newdef)
end
