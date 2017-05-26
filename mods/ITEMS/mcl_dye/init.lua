-- minetest/dye/init.lua

-- To make recipes that will work with any dye ever made by anybody, define
-- them based on groups.
-- You can select any group of groups, based on your need for amount of colors.
-- basecolor: 9, excolor: 17, unicolor: 89
--
-- Example of one shapeless recipe using a color group:
-- Note: As this uses basecolor_*, you'd need 9 of these.
-- minetest.register_craft({
--     type = "shapeless",
--     output = '<mod>:item_yellow',
--     recipe = {'<mod>:item_no_color', 'group:basecolor_yellow'},
-- })

-- Other mods can use these for looping through available colors
mcl_dye = {}
local dye = {}
dye.basecolors = {"white", "grey", "black", "red", "yellow", "green", "cyan", "blue", "magenta"}
dye.excolors = {"white", "lightgrey", "grey", "darkgrey", "black", "red", "orange", "yellow", "lime", "green", "aqua", "cyan", "sky_blue", "blue", "violet", "magenta", "red_violet"}

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

-- Local stuff
local dyelocal = {}

-- This collection of colors is partly a historic thing, partly something else.
dyelocal.dyes = {
	{"white",      "Bone Meal",     {dye=1, craftitem=1, basecolor_white=1,   excolor_white=1,     unicolor_white=1}},
	{"grey",       "Light Grey Dye",      {dye=1, craftitem=1, basecolor_grey=1,    excolor_grey=1,      unicolor_grey=1}},
	{"dark_grey",  "Grey Dye", {dye=1, craftitem=1, basecolor_grey=1,    excolor_darkgrey=1,  unicolor_darkgrey=1}},
	{"black",      "Ink Sac",     {dye=1, craftitem=1, basecolor_black=1,   excolor_black=1,     unicolor_black=1}},
	{"violet",     "Purple Dye",    {dye=1, craftitem=1, basecolor_magenta=1, excolor_violet=1,    unicolor_violet=1}},
	{"blue",       "Lapis Lazuli",      {dye=1, craftitem=1, basecolor_blue=1,    excolor_blue=1,      unicolor_blue=1}},
	{"lightblue",  "Light Blue Dye",      {dye=1, craftitem=1, basecolor_blue=1,    excolor_blue=1,   unicolor_light_blue=1}},
	{"cyan",       "Cyan Dye",      {dye=1, craftitem=1, basecolor_cyan=1,    excolor_cyan=1,      unicolor_cyan=1}},
	{"dark_green", "Cactus Green",{dye=1, craftitem=1, basecolor_green=1,   excolor_green=1,     unicolor_dark_green=1}},
	{"green",      "Lime Dye",     {dye=1, craftitem=1, basecolor_green=1,   excolor_green=1,     unicolor_green=1}},
	{"yellow",     "Dandelion Yellow",    {dye=1, craftitem=1, basecolor_yellow=1,  excolor_yellow=1,    unicolor_yellow=1}},
	{"brown",      "Cocoa Beans",     {dye=1, craftitem=1, basecolor_yellow=1,  excolor_orange=1,    unicolor_dark_orange=1}},
	{"orange",     "Orange Dye",    {dye=1, craftitem=1, basecolor_orange=1,  excolor_orange=1,    unicolor_orange=1}},
	{"red",        "Rose Red",       {dye=1, craftitem=1, basecolor_red=1,     excolor_red=1,       unicolor_red=1}},
	{"magenta",    "Magenta Dye",   {dye=1, craftitem=1, basecolor_magenta=1, excolor_red_violet=1,unicolor_red_violet=1}},
	{"pink",       "Pink Dye",      {dye=1, craftitem=1, basecolor_red=1,     excolor_red=1,       unicolor_light_red=1}},
}

-- Define items
for _, row in ipairs(dyelocal.dyes) do
	local name = row[1]
	-- White and brown dyes are defined explicitly below
	if name ~= "white" and name ~= "brown" then
		local description = row[2]
		local groups = row[3]
		local item_name = "mcl_dye:"..name
		local item_image = "dye_"..name..".png"
		minetest.register_craftitem(item_name, {
			inventory_image = item_image,
			description = description,
			_doc_items_longdesc = "This item is a dye which is used for dyeing and crafting.",
			_doc_items_usagehelp = "Rightclick on a sheep to dye its wool. Other things are dyed by crafting.",
			groups = groups,
			stack_max = 64,
		})
	end
end

-- Bone Meal

mcl_dye.apply_bone_meal = function(pointed_thing)
	local plant_tab = {
		"air",
		"mcl_flowers:tallgrass",
		"mcl_flowers:tallgrass",
		"mcl_flowers:tallgrass",
		"mcl_flowers:tallgrass",
		"mcl_flowers:tallgrass",
		"mcl_flowers:dandelion",
		"mcl_flowers:blue_orchid",
		"mcl_flowers:oxeye_daisy",
		"mcl_flowers:tulip_orange",
		"mcl_flowers:tulip_red",
		"mcl_flowers:tulip_white",
		"mcl_flowers:tulip_pink",
		"mcl_flowers:allium",
		"mcl_flowers:poppy",
		"mcl_flowers:azure_bluet",
	}

	pos = pointed_thing.under
	n = minetest.get_node(pos)
	if n.name == "" then return false end
	if minetest.get_item_group(n.name, "sapling") >= 1 then
		-- Saplings: 45% chance to advance growth stage
		if math.random(1,100) <= 45 then
			return mcl_core.grow_sapling(pos, n)
		end
	-- Wheat, Potato, Carrot, Pumpkin Stem, Melon Stem: Advance by 2-5 stages
	elseif string.find(n.name, "mcl_farming:wheat_") ~= nil then
		local stages = math.random(2, 5)
		return mcl_farming:grow_plant("plant_wheat", pos, n, stages)
	elseif string.find(n.name, "mcl_farming:potato_") ~= nil then
		local stages = math.random(2, 5)
		return mcl_farming:grow_plant("plant_potato", pos, n, stages)
	elseif string.find(n.name, "mcl_farming:carrot_") ~= nil then
		local stages = math.random(2, 5)
		return mcl_farming:grow_plant("plant_carrot", pos, n, stages)
	elseif string.find(n.name, "mcl_farming:pumpkin_") ~= nil then
		local stages = math.random(2, 5)
		return mcl_farming:grow_plant("plant_pumpkin_stem", pos, n, stages)
	elseif string.find(n.name, "mcl_farming:melontige_") ~= nil then
		local stages = math.random(2, 5)
		return mcl_farming:grow_plant("plant_melon_stem", pos, n, stages)

	elseif string.find(n.name, "mcl_farming:beetroot_") ~= nil then
		-- Beetroot: 75% chance to advance to next stage
		if math.random(1,100) <= 75 then
			return mcl_farming:grow_plant("plant_beetroot", pos, n)
		end
	elseif n.name == "mcl_cocoas:cocoa_1" or n.name == "mcl_cocoas:cocoa_2" then
		-- Cocoa: Advance by 1 stage
		mcl_cocoas.grow(pos)
		return true
	elseif n.name == "mcl_core:dirt_with_grass" or n.name == "mcl_core:dirt_with_grass_snow" then
		-- Grass Block: Generate tall grass and random flowers all over the place
		for i = -2, 2 do
			for j = -2, 2 do
				pos = pointed_thing.above
				pos = {x=pos.x+i, y=pos.y, z=pos.z+j}
				n = minetest.get_node(pos)
				n2 = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})

				if n.name ~= "" and n.name == "air" and (n2.name == "mcl_core:dirt_with_grass" or n2.name == "mcl_core:dirt_with_grass_snow") then
					if math.random(0,5) > 3 then
						minetest.add_node(pos, {name=plant_tab[math.random(1, #plant_tab)]})
					else
						minetest.add_node(pos, {name=plant_tab[math.random(1, 6)]})
					end

				end
			end
		end
		return true

	-- Double flowers: Drop corresponding item
	elseif n.name == "mcl_flowers:rose_bush" or n.name == "mcl_flowers:rose_bush_top" then
		minetest.add_item(pos, "mcl_flowers:rose_bush")
		return true
	elseif n.name == "mcl_flowers:peony" or n.name == "mcl_flowers:peony_top" then
		minetest.add_item(pos, "mcl_flowers:peony")
		return true
	elseif n.name == "mcl_flowers:lilac" or n.name == "mcl_flowers:lilac_top" then
		minetest.add_item(pos, "mcl_flowers:lilac")
		return true
	elseif n.name == "mcl_flowers:sunflower" or n.name == "mcl_flowers:sunflower_top" then
		minetest.add_item(pos, "mcl_flowers:sunflower")
		return true

	elseif n.name == "mcl_flowers:tallgrass" then
		-- Tall Grass: Grow into double tallgrass
		local toppos = { x=pos.x, y=pos.y+1, z=pos.z }
		local topnode = minetest.get_node(toppos)
		if minetest.registered_nodes[topnode.name].buildable_to then
			minetest.set_node(pos, { name = "mcl_flowers:double_grass" })
			minetest.set_node(toppos, { name = "mcl_flowers:double_grass_top" })
			return true
		end

	elseif n.name == "mcl_flowers:fern" then
		-- Fern: Grow into large fern
		local toppos = { x=pos.x, y=pos.y+1, z=pos.z }
		local topnode = minetest.get_node(toppos)
		if minetest.registered_nodes[topnode.name].buildable_to then
			minetest.set_node(pos, { name = "mcl_flowers:double_fern" })
			minetest.set_node(toppos, { name = "mcl_flowers:double_fern_top" })
			return true
		end
	end

	return false
end

minetest.register_craftitem("mcl_dye:white", {
	inventory_image = "dye_white.png",
	description = "Bone Meal",
	_doc_items_longdesc = "Bone meal is a white dye and also useful as a fertilizer to speed up the growth of many plants.",
	_doc_items_usagehelp = "Rightclick a sheep to turn its wool white. Rightclick a plant to speed up its growth. Note that not all plants can be fertilized like this. When you rightclick a grass block, tall grass and flowers will grow all over the place.",
	stack_max = 64,
	groups = dyelocal.dyes[1][3],
	on_place = function(itemstack, user, pointed_thing) 
		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
			end
		end

		-- Use the bone meal on the ground
		if(mcl_dye.apply_bone_meal(pointed_thing) and not minetest.setting_getbool("creative_mode")) then
			itemstack:take_item()
		end
		return itemstack
	end,
})

minetest.register_craftitem("mcl_dye:brown", {
	inventory_image = "dye_brown.png",
	_doc_items_longdesc = "Cocoa beans are a brown dye and can be used to plant cocoas.",
	_doc_items_usagehelp = "Rightclick a sheep to turn its wool brown. Rightclick on the side of a jungle tree trunk (Jungle Wood) to plant a young cocoa.",
	description = "Cocoa Beans",
	stack_max = 64,
	groups = dyelocal.dyes[4][3],
	on_place = function(itemstack, placer, pointed_thing)
		return mcl_cocoas.place(itemstack, placer, pointed_thing, "mcl_cocoas:cocoa_1")
	end,
})

-- Dye mixing
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

-- Dye creation
minetest.register_craft({
	output = "mcl_dye:yellow",
	recipe = {{"mcl_flowers:dandelion"}},
})
minetest.register_craft({
	output = "mcl_dye:yellow 2",
	recipe = {{"mcl_flowers:sunflower"}},
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
minetest.register_craft({
	output = "mcl_dye:white 3",
	recipe = {{"mcl_mobitems:bone"}},
})


