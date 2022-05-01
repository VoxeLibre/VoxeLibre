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

local string = string

-- Other mods can use these for looping through available colors
mcl_dye.basecolors = {"white", "grey", "black", "red", "yellow", "green", "cyan", "blue", "magenta"}
mcl_dye.excolors = {"white", "lightgrey", "grey", "darkgrey", "black", "red", "orange", "yellow", "lime", "green", "aqua", "cyan", "sky_blue", "blue", "violet", "magenta", "red_violet"}

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
	{"white", "mcl_dye_white",	    S("Bone Meal"),     {dye=1, craftitem=1, basecolor_white=1,   excolor_white=1,     unicolor_white=1}},
	{"grey", "dye_grey",      	    S("Light Grey Dye"),      {dye=1, craftitem=1, basecolor_grey=1,    excolor_grey=1,      unicolor_grey=1}},
	{"dark_grey", "dye_dark_grey", 	    S("Grey Dye"), {dye=1, craftitem=1, basecolor_grey=1,    excolor_darkgrey=1,  unicolor_darkgrey=1}},
	{"black", "mcl_dye_black",     	    S("Ink Sac"),     {dye=1, craftitem=1, basecolor_black=1,   excolor_black=1,     unicolor_black=1}},
	{"violet", "dye_violet",    	    S("Purple Dye"),    {dye=1, craftitem=1, basecolor_magenta=1, excolor_violet=1,    unicolor_violet=1}},
	{"blue", "mcl_dye_blue",      	    S("Lapis Lazuli"),      {dye=1, craftitem=1, basecolor_blue=1,    excolor_blue=1,      unicolor_blue=1}},
	{"lightblue", "mcl_dye_light_blue", S("Light Blue Dye"),      {dye=1, craftitem=1, basecolor_blue=1,    excolor_blue=1,   unicolor_light_blue=1}},
	{"cyan", "dye_cyan",      	    S("Cyan Dye"),      {dye=1, craftitem=1, basecolor_cyan=1,    excolor_cyan=1,      unicolor_cyan=1}},
	{"dark_green", "dye_dark_green",    S("Cactus Green"),{dye=1, craftitem=1, basecolor_green=1,   excolor_green=1,     unicolor_dark_green=1}},
	{"green", "mcl_dye_lime",           S("Lime Dye"),     {dye=1, craftitem=1, basecolor_green=1,   excolor_green=1,     unicolor_green=1}},
	{"yellow", "dye_yellow",            S("Dandelion Yellow"),    {dye=1, craftitem=1, basecolor_yellow=1,  excolor_yellow=1,    unicolor_yellow=1}},
	{"brown", "mcl_dye_brown",          S("Cocoa Beans"),     {dye=1, craftitem=1, basecolor_brown=1,  excolor_orange=1,    unicolor_dark_orange=1, compostability = 65}},
	{"orange", "dye_orange",            S("Orange Dye"),    {dye=1, craftitem=1, basecolor_orange=1,  excolor_orange=1,    unicolor_orange=1}},
	{"red", "dye_red",                  S("Rose Red"),       {dye=1, craftitem=1, basecolor_red=1,     excolor_red=1,       unicolor_red=1}},
	{"magenta", "dye_magenta",          S("Magenta Dye"),   {dye=1, craftitem=1, basecolor_magenta=1, excolor_red_violet=1,unicolor_red_violet=1}},
	{"pink", "dye_pink",                S("Pink Dye"),      {dye=1, craftitem=1, basecolor_red=1,     excolor_red=1,       unicolor_light_red=1}},
}

dyelocal.unicolor_to_dye_id = {}
for d=1, #dyelocal.dyes do
	for k, _ in pairs(dyelocal.dyes[d][4]) do
		if string.sub(k, 1, 9) == "unicolor_" then
			dyelocal.unicolor_to_dye_id[k] = dyelocal.dyes[d][1]
		end
	end
end

-- Takes an unicolor group name (e.g. “unicolor_white”) and returns a corresponding dye name (if it exists), nil otherwise.
function mcl_dye.unicolor_to_dye(unicolor_group)
	local color = dyelocal.unicolor_to_dye_id[unicolor_group]
	if color then
		return "mcl_dye:" .. color
	else
		return nil
	end
end

-- Define items
for _, row in ipairs(dyelocal.dyes) do
	local name = row[1]
	-- White dye is an alias and brown dye is defined explicitly below
	if name ~= "white" and name ~= "brown" then
		local img = row[2]
		local description = row[3]
		local groups = row[4]
		local item_name = "mcl_dye:"..name
		local item_image = img..".png"
		minetest.register_craftitem(item_name, {
			inventory_image = item_image,
			description = description,
			_doc_items_longdesc = S("This item is a dye which is used for dyeing and crafting."),
			_doc_items_usagehelp = S("Rightclick on a sheep to dye its wool. Other things are dyed by crafting."),
			groups = groups,
			stack_max = 64,
		})
	end
end

-- Legacy support for things now in mcl_bone_meal.
-- These shims will at some time in the future be removed.
--
function mcl_dye.add_bone_meal_particle(pos, def)
	minetest.log("warning", "mcl_dye.add_bone_meal_particles() is deprecated.  Read mcl_bone_meal/API.md!")
	mcl_bone_meal.add_bone_meal_particle(pos, def)
end

function mcl_dye.register_on_bone_meal_apply(func)
	minetest.log("warning", "mcl_dye.register_on_bone_meal_apply() is deprecated.  Read mcl_bone_meal/API.md!")
	mcl_bone_meal.register_on_bone_meal_apply(func)
end

minetest.register_alias("mcl_dye:white", "mcl_bone_meal:bone_meal")
-- End of legacy support

minetest.register_craftitem("mcl_dye:brown", {
	inventory_image = "mcl_dye_brown.png",
	_tt_help = S("Grows at the side of jungle trees"),
	_doc_items_longdesc = S("Cocoa beans are a brown dye and can be used to plant cocoas."),
	_doc_items_usagehelp = S("Rightclick a sheep to turn its wool brown. Rightclick on the side of a jungle tree trunk (Jungle Wood) to plant a young cocoa."),
	description = S("Cocoa Beans"),
	stack_max = 64,
	groups = dyelocal.dyes[12][4],
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
