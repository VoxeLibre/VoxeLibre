-- To make recipes that will work with any dye ever made by anybody, define
-- them based on groups.
-- You can select any group of groups, based on your need for amount of colors.
-- basecolor: 9, excolor: 17, unicolor: 89
--
-- Example of one shapeless recipe using a color group:
-- Note: As this uses basecolor_*, you'd need 9 of these.
-- minetest.register_craft({
--     type = "shapeless",
--     output = "<mod>:item_yellow",
--     recipe = {"<mod>:item_no_color", "group:basecolor_yellow"},
-- })

mcl_dye = {}

local S = minetest.get_translator(minetest.get_current_modname())

local math = math
local string = string

-- Base color groups:
-- - basecolor_white
-- - basecolor_grey
-- - basecolor_black
-- - basecolor_red
-- - basecolor_yellow
-- - basecolor_green
-- - basecolor_cyan
-- - basecolor_blue
-- - basecolor_magenta

-- Extended color groups (* = equal to a base color):
-- * excolor_white
-- - excolor_lightgrey
-- * excolor_grey
-- - excolor_darkgrey
-- * excolor_black
-- * excolor_red
-- - excolor_orange
-- * excolor_yellow
-- - excolor_lime
-- * excolor_green
-- - excolor_aqua
-- * excolor_cyan
-- - excolor_sky_blue
-- * excolor_blue
-- - excolor_violet
-- * excolor_magenta
-- - excolor_red_violet

-- The whole unifieddyes palette as groups:
-- - unicolor_<excolor>
-- For the following, no white/grey/black is allowed:
-- - unicolor_medium_<excolor>
-- - unicolor_dark_<excolor>
-- - unicolor_light_<excolor>
-- - unicolor_<excolor>_s50
-- - unicolor_medium_<excolor>_s50
-- - unicolor_dark_<excolor>_s50

-- This collection of colors is partly a historic thing, partly something else.
local dyes = {
	{"white",	S("White Dye"),		{basecolor_white=1,   excolor_white=1,     unicolor_white=1}},
	{"grey",	S("Light Grey Dye"),	{basecolor_grey=1,    excolor_grey=1,      unicolor_grey=1}},
	{"dark_grey",	S("Grey Dye"),		{basecolor_grey=1,    excolor_darkgrey=1,  unicolor_darkgrey=1}},
	{"black",	S("Black Dye"),		{basecolor_black=1,   excolor_black=1,     unicolor_black=1}},
	{"violet",	S("Purple Dye"),	{basecolor_magenta=1, excolor_violet=1,    unicolor_violet=1}},
	{"blue",	S("Blue Dye"),		{basecolor_blue=1,    excolor_blue=1,      unicolor_blue=1}},
	{"lightblue",	S("Light Blue Dye"),	{basecolor_blue=1,    excolor_blue=1,      unicolor_light_blue=1}},
	{"cyan",	S("Cyan Dye"),		{basecolor_cyan=1,    excolor_cyan=1,      unicolor_cyan=1}},
	{"dark_green",	S("Cactus Green"),	{basecolor_green=1,   excolor_green=1,     unicolor_dark_green=1}},
	{"green",	S("Lime Dye"),		{basecolor_green=1,   excolor_green=1,     unicolor_green=1}},
	{"yellow",	S("Dandelion Yellow"),	{basecolor_yellow=1,  excolor_yellow=1,    unicolor_yellow=1}},
	{"brown",	S("Brown Dye"),		{basecolor_brown=1,   excolor_orange=1,    unicolor_dark_orange=1}},
	{"orange",	S("Orange Dye"),	{basecolor_orange=1,  excolor_orange=1,    unicolor_orange=1}},
	{"red",		S("Rose Red"),		{basecolor_red=1,     excolor_red=1,       unicolor_red=1}},
	{"magenta",	S("Magenta Dye"),	{basecolor_magenta=1, excolor_red_violet=1,unicolor_red_violet=1}},
	{"pink",	S("Pink Dye"),		{basecolor_red=1,     excolor_red=1,       unicolor_light_red=1}},
}

-- Other mods can use these for looping through available colors
mcl_dye.basecolors = {"white", "grey", "black", "magenta", "blue", "cyan", "green", "yellow", "orange", "red", "brown"}
mcl_dye.excolors = {"white", "grey", "darkgrey", "black", "violet", "blue", "cyan", "green", "yellow", "orange", "red", "red_violet"}

local unicolor_to_dye_id = {}
for d = 1, #dyes do
	for k, _ in pairs(dyes[d][3]) do
		if string.sub(k, 1, 9) == "unicolor_" then
			unicolor_to_dye_id[k] = dyes[d][1]
		end
	end
end

-- Takes an unicolor group name (e.g. “unicolor_white”) and returns a
-- corresponding dye name (if it exists), nil otherwise.
function mcl_dye.unicolor_to_dye(unicolor_group)
	local color = unicolor_to_dye_id[unicolor_group]
	if color then
		return "mcl_dye:" .. color
	else
		return nil
	end
end

-- Define dye items.
--
for _, row in pairs(dyes) do
	local name, desc, grps = unpack(row)
	minetest.register_craftitem("mcl_dye:" .. name, {
		inventory_image = "mcl_dye_" .. name .. ".png",
		description = desc,
		_doc_items_longdesc = S("This item is a dye which is used for dyeing and crafting."),
		_doc_items_usagehelp = S("Rightclick on a sheep to dye its wool. Other things are dyed by crafting."),
		groups = table.update({craftitem = 1, dye = 1}, grps)
	})
end

-- Bone meal code to be moved into its own mod.
--
function mcl_dye.add_bone_meal_particle(pos, def)
	if not def then
		def = {}
	end
	minetest.add_particlespawner({
		amount = def.amount or 10,
		time = def.time or 0.1,
		minpos = def.minpos or vector.subtract(pos, 0.5),
		maxpos = def.maxpos or vector.add(pos, 0.5),
		minvel = def.minvel or vector.new(-0.01, 0.01, -0.01),
		maxvel = def.maxvel or vector.new(0.01, 0.01, 0.01),
		minacc = def.minacc or vector.new(0, 0, 0),
		maxacc = def.maxacc or vector.new(0, 0, 0),
		minexptime = def.minexptime or 1,
		maxexptime = def.maxexptime or 4,
		minsize = def.minsize or 0.7,
		maxsize = def.maxsize or 2.4,
		texture = "mcl_particles_bonemeal.png^[colorize:#00EE00:125", -- TODO: real MC color
		glow = def.glow or 1,
	})
end

mcl_dye.bone_meal_callbacks = {}

function mcl_dye.register_on_bone_meal_apply(func)
	table.insert(mcl_dye.bone_meal_callbacks, func)
end

local function apply_bone_meal(pointed_thing, user)
	-- Bone meal currently spawns all flowers found in the plains.
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
	local flowers_table_simple = {
		"mcl_flowers:dandelion",
		"mcl_flowers:poppy",
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

	local pos = pointed_thing.under
	local n = minetest.get_node(pos)
	if n.name == "" then return false end

	for _, func in pairs(mcl_dye.bone_meal_callbacks) do
		if func(pointed_thing, user) then
			return true
		end
	end

	if minetest.get_item_group(n.name, "sapling") >= 1 then
		mcl_dye.add_bone_meal_particle(pos)
		-- Saplings: 45% chance to advance growth stage
		if math.random(1, 100) <= 45 then
			return mcl_core.grow_sapling(pos, n)
		end
	elseif minetest.get_item_group(n.name, "mushroom") == 1 then
		mcl_dye.add_bone_meal_particle(pos)
		-- Try to grow huge mushroom

		-- Must be on a dirt-type block
		local below = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
		if below.name ~= "mcl_core:mycelium" and below.name ~= "mcl_core:dirt" and minetest.get_item_group(below.name, "grass_block") ~= 1 and below.name ~= "mcl_core:coarse_dirt" and below.name ~= "mcl_core:podzol" then
			return false
		end

		-- Select schematic
		local schematic, offset, height
		if n.name == "mcl_mushrooms:mushroom_brown" then
			schematic = minetest.get_modpath("mcl_mushrooms").."/schematics/mcl_mushrooms_huge_brown.mts"
			offset = { x = -3, y = -1, z = -3 }
			height = 8
		elseif n.name == "mcl_mushrooms:mushroom_red" then
			schematic = minetest.get_modpath("mcl_mushrooms").."/schematics/mcl_mushrooms_huge_red.mts"
			offset = { x = -2, y = -1, z = -2 }
			height = 8
		else
			return false
		end
		-- 40% chance
		if math.random(1, 100) <= 40 then
			-- Check space requirements
			for i=1,3 do
				local cpos = vector.add(pos, {x=0, y=i, z=0})
				if minetest.get_node(cpos).name ~= "air" then
					return false
				end
			end
			local yoff = 3
			local minp, maxp = {x=pos.x-3, y=pos.y+yoff, z=pos.z-3}, {x=pos.x+3, y=pos.y+yoff+(height-3), z=pos.z+3}
			local diff = vector.subtract(maxp, minp)
			diff = vector.add(diff, {x=1,y=1,z=1})
			local totalnodes = diff.x * diff.y * diff.z
			local goodnodes = minetest.find_nodes_in_area(minp, maxp, {"air", "group:leaves"})
			if #goodnodes < totalnodes then
				return false
			end

			-- Place the huge mushroom
			minetest.remove_node(pos)
			local place_pos = vector.add(pos, offset)
			local ok = minetest.place_schematic(place_pos, schematic, 0, nil, false)
			return ok ~= nil
		end
		return false
	-- Wheat, Potato, Carrot, Pumpkin Stem, Melon Stem: Advance by 2-5 stages
	elseif string.find(n.name, "mcl_farming:wheat_") then
		mcl_dye.add_bone_meal_particle(pos)
		local stages = math.random(2, 5)
		return mcl_farming:grow_plant("plant_wheat", pos, n, stages, true)
	elseif string.find(n.name, "mcl_farming:potato_") then
		mcl_dye.add_bone_meal_particle(pos)
		local stages = math.random(2, 5)
		return mcl_farming:grow_plant("plant_potato", pos, n, stages, true)
	elseif string.find(n.name, "mcl_farming:carrot_") then
		mcl_dye.add_bone_meal_particle(pos)
		local stages = math.random(2, 5)
		return mcl_farming:grow_plant("plant_carrot", pos, n, stages, true)
	elseif string.find(n.name, "mcl_farming:pumpkin_") then
		mcl_dye.add_bone_meal_particle(pos)
		local stages = math.random(2, 5)
		return mcl_farming:grow_plant("plant_pumpkin_stem", pos, n, stages, true)
	elseif string.find(n.name, "mcl_farming:melontige_") then
		mcl_dye.add_bone_meal_particle(pos)
		local stages = math.random(2, 5)
		return mcl_farming:grow_plant("plant_melon_stem", pos, n, stages, true)
	elseif string.find(n.name, "mcl_farming:beetroot_") then
		mcl_dye.add_bone_meal_particle(pos)
		-- Beetroot: 75% chance to advance to next stage
		if math.random(1, 100) <= 75 then
			return mcl_farming:grow_plant("plant_beetroot", pos, n, 1, true)
		end
	elseif string.find(n.name, "mcl_farming:sweet_berry_bush_") then
		mcl_dye.add_bone_meal_particle(pos)
		if n.name == "mcl_farming:sweet_berry_bush_3" then
			return minetest.add_item(vector.offset(pos,math.random()-0.5,math.random()-0.5,math.random()-0.5),"mcl_farming:sweet_berry")
		else
			return mcl_farming:grow_plant("plant_sweet_berry_bush", pos, n, 0, true)
		end
	elseif n.name == "mcl_cocoas:cocoa_1" or n.name == "mcl_cocoas:cocoa_2" then
		mcl_dye.add_bone_meal_particle(pos)
		-- Cocoa: Advance by 1 stage
		mcl_cocoas.grow(pos)
		return true
	elseif minetest.get_item_group(n.name, "grass_block") == 1 then
		-- Grass Block: Generate tall grass and random flowers all over the place
		for i = -7, 7 do
			for j = -7, 7 do
				for y = -1, 1 do
					pos = vector.offset(pointed_thing.above, i, y, j)
					n = minetest.get_node(pos)
					local n2 = minetest.get_node(vector.offset(pos, 0, -1, 0))

					if n.name ~= "" and n.name == "air" and (minetest.get_item_group(n2.name, "grass_block_no_snow") == 1) then
						-- Randomly generate flowers, tall grass or nothing
						if math.random(1, 100) <= 90 / ((math.abs(i) + math.abs(j)) / 2)then
							-- 90% tall grass, 10% flower
							mcl_dye.add_bone_meal_particle(pos, {amount = 4})
							if math.random(1,100) <= 90 then
								local col = n2.param2
								minetest.add_node(pos, {name="mcl_flowers:tallgrass", param2=col})
							else
								local flowers_table
								if mg_name == "v6" then
									flowers_table = flowers_table_plains
								else
									local biome = minetest.get_biome_name(minetest.get_biome_data(pos).biome)
									if biome == "Swampland" or biome == "Swampland_shore" or biome == "Swampland_ocean" or biome == "Swampland_deep_ocean" or biome == "Swampland_underground" then
										flowers_table = flowers_table_swampland
									elseif biome == "FlowerForest" or biome == "FlowerForest_beach" or biome == "FlowerForest_ocean" or biome == "FlowerForest_deep_ocean" or biome == "FlowerForest_underground" then
										flowers_table = flowers_table_flower_forest
									elseif biome == "Plains" or biome == "Plains_beach" or biome == "Plains_ocean" or biome == "Plains_deep_ocean" or biome == "Plains_underground" or biome == "SunflowerPlains" or biome == "SunflowerPlains_ocean" or biome == "SunflowerPlains_deep_ocean" or biome == "SunflowerPlains_underground" then
										flowers_table = flowers_table_plains
									else
										flowers_table = flowers_table_simple
									end
								end
								minetest.add_node(pos, {name=flowers_table[math.random(1, #flowers_table)]})
							end
						end
					end
				end
			end
		end
		return true

	-- Double flowers: Drop corresponding item
	elseif n.name == "mcl_flowers:rose_bush" or n.name == "mcl_flowers:rose_bush_top" then
		mcl_dye.add_bone_meal_particle(pos)
		minetest.add_item(pos, "mcl_flowers:rose_bush")
		return true
	elseif n.name == "mcl_flowers:peony" or n.name == "mcl_flowers:peony_top" then
		mcl_dye.add_bone_meal_particle(pos)
		minetest.add_item(pos, "mcl_flowers:peony")
		return true
	elseif n.name == "mcl_flowers:lilac" or n.name == "mcl_flowers:lilac_top" then
		mcl_dye.add_bone_meal_particle(pos)
		minetest.add_item(pos, "mcl_flowers:lilac")
		return true
	elseif n.name == "mcl_flowers:sunflower" or n.name == "mcl_flowers:sunflower_top" then
		mcl_dye.add_bone_meal_particle(pos)
		minetest.add_item(pos, "mcl_flowers:sunflower")
		return true

	elseif n.name == "mcl_flowers:tallgrass" then
		mcl_dye.add_bone_meal_particle(pos)
		-- Tall Grass: Grow into double tallgrass
		local toppos = { x=pos.x, y=pos.y+1, z=pos.z }
		local topnode = minetest.get_node(toppos)
		if minetest.registered_nodes[topnode.name].buildable_to then
			minetest.set_node(pos, { name = "mcl_flowers:double_grass", param2 = n.param2 })
			minetest.set_node(toppos, { name = "mcl_flowers:double_grass_top", param2 = n.param2 })
			return true
		end

--[[
	Here for when Bonemeal becomes an api, there's code if needed for handling applying to bamboo.
	-- Handle applying bonemeal to bamboo.
	elseif mcl_bamboo.is_bamboo(n.name) then
		local success = mcl_bamboo.grow_bamboo(pos, true)
		if success then
			mcl_dye.add_bone_meal_particle(pos)
		end
		return success
--]]
	elseif n.name == "mcl_flowers:fern" then
		mcl_dye.add_bone_meal_particle(pos)
		-- Fern: Grow into large fern
		local toppos = { x=pos.x, y=pos.y+1, z=pos.z }
		local topnode = minetest.get_node(toppos)
		if minetest.registered_nodes[topnode.name].buildable_to then
			minetest.set_node(pos, { name = "mcl_flowers:double_fern", param2 = n.param2 })
			minetest.set_node(toppos, { name = "mcl_flowers:double_fern_top", param2 = n.param2 })
			return true
		end
	end

	return false
end

mcl_dye.apply_bone_meal = apply_bone_meal

-- Bone meal item registration.
--
-- To be moved into its own mod.
--
minetest.register_craftitem(":mcl_bone_meal:bone_meal", {
	inventory_image = "mcl_bone_meal_bone_meal.png",
	description = S("Bone Meal"),
	_tt_help = S("Speeds up plant growth"),
	_doc_items_longdesc = S("Bone meal is a white dye and also useful as a fertilizer to speed up the growth of many plants."),
	_doc_items_usagehelp = S("Rightclick a sheep to turn its wool white. Rightclick a plant to speed up its growth. Note that not all plants can be fertilized like this. When you rightclick a grass block, tall grass and flowers will grow all over the place."),
	stack_max = 64,
	on_place = function(itemstack, user, pointed_thing)
		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
			end
		end

		-- Use the bone meal on the ground
		if (apply_bone_meal(pointed_thing, user) and (not minetest.is_creative_enabled(user:get_player_name()))) then
			itemstack:take_item()
		end
		return itemstack
	end,
	_on_dispense = function(stack, pos, droppos, dropnode, dropdir)
		-- Apply bone meal, if possible
		local pointed_thing
		if dropnode.name == "air" then
			pointed_thing = { above = droppos, under = { x=droppos.x, y=droppos.y-1, z=droppos.z } }
		else
			pointed_thing = { above = pos, under = droppos }
		end
		local success = apply_bone_meal(pointed_thing, nil)
		if success then
			stack:take_item()
		end
		return stack
	end,
	_dispense_into_walkable = true
})

minetest.register_craft({
	output = "mcl_bone_meal:bone_meal 3",
	recipe = {{"mcl_mobitems:bone"}},
})


-- Dye creation recipes.
--
minetest.register_craft({
	output = "mcl_dye:white",
	recipe = {{"mcl_bone_meal:bone_meal"}},
})

minetest.register_craft({
	output = "mcl_dye:black",
	recipe = {{"mcl_mobitems:ink_sac"}},
})

minetest.register_craft({
	output = "mcl_dye:yellow",
	recipe = {{"mcl_flowers:dandelion"}},
})

minetest.register_craft({
	output = "mcl_dye:yellow 2",
	recipe = {{"mcl_flowers:sunflower"}},
})

minetest.register_craft({
	output = "mcl_dye:blue",
	recipe = {{"mcl_core:lapis"}},
})

minetest.register_craft({
	output = "mcl_dye:lightblue",
	recipe = {{"mcl_flowers:blue_orchid"}},
})

minetest.register_craft({
	output = "mcl_dye:grey",
	recipe = {{"mcl_flowers:azure_bluet"}},
})

minetest.register_craft({
	output = "mcl_dye:grey",
	recipe = {{"mcl_flowers:oxeye_daisy"}},
})

minetest.register_craft({
	output = "mcl_dye:grey",
	recipe = {{"mcl_flowers:tulip_white"}},
})

minetest.register_craft({
	output = "mcl_dye:magenta",
	recipe = {{"mcl_flowers:allium"}},
})

minetest.register_craft({
	output = "mcl_dye:magenta 2",
	recipe = {{"mcl_flowers:lilac"}},
})

minetest.register_craft({
	output = "mcl_dye:orange",
	recipe = {{"mcl_flowers:tulip_orange"}},
})

minetest.register_craft({
	output = "mcl_dye:brown",
	recipe = {{"mcl_cocoas:cocoa_beans"}},
})

minetest.register_craft({
	output = "mcl_dye:pink",
	recipe = {{"mcl_flowers:tulip_pink"}},
})

minetest.register_craft({
	output = "mcl_dye:pink 2",
	recipe = {{"mcl_flowers:peony"}},
})

minetest.register_craft({
	output = "mcl_dye:red",
	recipe = {{"mcl_farming:beetroot_item"}},
})

minetest.register_craft({
	output = "mcl_dye:red",
	recipe = {{"mcl_flowers:poppy"}},
})

minetest.register_craft({
	output = "mcl_dye:red",
	recipe = {{"mcl_flowers:tulip_red"}},
})

minetest.register_craft({
	output = "mcl_dye:red 2",
	recipe = {{"mcl_flowers:rose_bush"}},
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_dye:dark_green",
	recipe = "mcl_core:cactus",
	cooktime = 10,
})

-- Dye mixing recipes.
--
minetest.register_craft({
	type = "shapeless",
	output = "mcl_dye:dark_grey 2",
	recipe = {"mcl_dye:black", "mcl_dye:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dye:lightblue 2",
	recipe = {"mcl_dye:blue", "mcl_dye:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dye:grey 3",
	recipe = {"mcl_dye:black", "mcl_dye:white", "mcl_dye:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dye:grey 2",
	recipe = {"mcl_dye:dark_grey", "mcl_dye:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dye:green 2",
	recipe = {"mcl_dye:dark_green", "mcl_dye:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dye:magenta 4",
	recipe = {"mcl_dye:blue", "mcl_dye:white", "mcl_dye:red", "mcl_dye:red"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dye:magenta 3",
	recipe = {"mcl_dye:pink", "mcl_dye:red", "mcl_dye:blue"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dye:magenta 2",
	recipe = {"mcl_dye:violet", "mcl_dye:pink"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dye:pink 2",
	recipe = {"mcl_dye:red", "mcl_dye:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dye:cyan 2",
	recipe = {"mcl_dye:blue", "mcl_dye:dark_green"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dye:violet 2",
	recipe = {"mcl_dye:blue", "mcl_dye:red"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dye:orange 2",
	recipe = {"mcl_dye:yellow", "mcl_dye:red"},
})

-- Legacy items grace conversion recipes.
--
-- These allow for retrieval of precious items that were converted into
-- dye items after refactoring of the dyes.  Should be removed again in
-- the near future.
minetest.register_craft({
	output = "mcl_bone_meal:bone_meal",
	recipe = {{"mcl_dye:white"}},
})

minetest.register_craft({
	output = "mcl_mobitems:ink_sac",
	recipe = {{"mcl_dye:black"}},
})

minetest.register_craft({
	output = "mcl_core:lapis",
	recipe = {{"mcl_dye:blue"}},
})

minetest.register_craft({
	output = "mcl_cocoas:cocoa_beans",
	recipe = {{"mcl_dye:brown"}},
})
