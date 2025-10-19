-- To make recipes that will work with any dye ever made by anybody, define
-- them based on groups.
-- You can select any group of groups, based on your need for amount of colors.
-- basecolor: 9, excolor: 17, unicolor: 89
--
-- Example of one shapeless recipe using a color group:
-- Note: As this uses basecolor_*, you'd need 9 of these.
-- core.register_craft({
--     type = "shapeless",
--     output = "<mod>:item_yellow",
--     recipe = {"<mod>:item_no_color", "group:basecolor_yellow"},
-- })

mcl_dye = {}

local S = core.get_translator(core.get_current_modname())

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
	{"dark_green",	S("Green Dye"),		{basecolor_green=1,   excolor_green=1,     unicolor_dark_green=1}},
	{"green",	S("Lime Dye"),		{basecolor_green=1,   excolor_green=1,     unicolor_green=1}},
	{"yellow",	S("Yellow Dye"),	{basecolor_yellow=1,  excolor_yellow=1,    unicolor_yellow=1}},
	{"brown",	S("Brown Dye"),		{basecolor_brown=1,   excolor_orange=1,    unicolor_dark_orange=1}},
	{"orange",	S("Orange Dye"),	{basecolor_orange=1,  excolor_orange=1,    unicolor_orange=1}},
	{"red",		S("Red Dye"),		{basecolor_red=1,     excolor_red=1,       unicolor_red=1}},
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
	core.register_craftitem("mcl_dye:" .. name, {
		inventory_image = "mcl_dye_" .. name .. ".png",
		description = desc,
		_doc_items_longdesc = S("This item is a dye which is used for dyeing and crafting."),
		_doc_items_usagehelp = S("Rightclick on a sheep to dye its wool. Other things are dyed by crafting."),
		groups = table.update({craftitem = 1, dye = 1}, grps)
	})
end

-- Legacy support for things now in mcl_bone_meal.
-- These shims will at some time in the future be removed.
--
function mcl_dye.add_bone_meal_particle(pos, def)
	core.log("warning", "mcl_dye.add_bone_meal_particles() is deprecated.  Read mcl_bone_meal/API.md!")
	local lines = string.split(debug.traceback(),"\n")
	for _,line in ipairs(lines) do
		core.log("warning",line)
	end
	mcl_bone_meal.add_bone_meal_particle(pos, def)
end

function mcl_dye.register_on_bone_meal_apply(func)
	core.log("warning", "mcl_dye.register_on_bone_meal_apply() is deprecated.  Read mcl_bone_meal/API.md!")
	mcl_bone_meal.register_on_bone_meal_apply(func)
end

-- Dye creation recipes.
--
core.register_craft({
	output = "mcl_dye:white",
	recipe = {{"mcl_bone_meal:bone_meal"}},
})

core.register_craft({
	output = "mcl_dye:black",
	recipe = {{"mcl_mobitems:ink_sac"}},
})

core.register_craft({
	output = "mcl_dye:yellow",
	recipe = {{"mcl_flowers:dandelion"}},
})

core.register_craft({
	output = "mcl_dye:yellow 2",
	recipe = {{"mcl_flowers:sunflower"}},
})

core.register_craft({
	output = "mcl_dye:blue",
	recipe = {{"mcl_core:lapis"}},
})

core.register_craft({
	output = "mcl_dye:blue",
	recipe = {{"mcl_flowers:cornflower"}},
})

core.register_craft({
	output = "mcl_dye:lightblue",
	recipe = {{"mcl_flowers:blue_orchid"}},
})

core.register_craft({
	output = "mcl_dye:grey",
	recipe = {{"mcl_flowers:azure_bluet"}},
})

core.register_craft({
	output = "mcl_dye:grey",
	recipe = {{"mcl_flowers:oxeye_daisy"}},
})

core.register_craft({
	output = "mcl_dye:grey",
	recipe = {{"mcl_flowers:tulip_white"}},
})

core.register_craft({
	output = "mcl_dye:magenta",
	recipe = {{"mcl_flowers:allium"}},
})

core.register_craft({
	output = "mcl_dye:magenta 2",
	recipe = {{"mcl_flowers:lilac"}},
})

core.register_craft({
	output = "mcl_dye:orange",
	recipe = {{"mcl_flowers:tulip_orange"}},
})

core.register_craft({
	output = "mcl_dye:brown",
	recipe = {{"mcl_cocoas:cocoa_beans"}},
})

core.register_craft({
	output = "mcl_dye:pink",
	recipe = {{"mcl_flowers:tulip_pink"}},
})

core.register_craft({
	output = "mcl_dye:pink 2",
	recipe = {{"mcl_flowers:peony"}},
})

core.register_craft({
	output = "mcl_dye:red",
	recipe = {{"mcl_farming:beetroot_item"}},
})

core.register_craft({
	output = "mcl_dye:red",
	recipe = {{"mcl_flowers:poppy"}},
})

core.register_craft({
	output = "mcl_dye:red",
	recipe = {{"mcl_flowers:tulip_red"}},
})

core.register_craft({
	output = "mcl_dye:red 2",
	recipe = {{"mcl_flowers:rose_bush"}},
})

core.register_craft({
	output = "mcl_dye:white",
	recipe = {{"mcl_flowers:lily_of_the_valley"}},
})

core.register_craft({
	type = "cooking",
	output = "mcl_dye:dark_green",
	recipe = "mcl_core:cactus",
	cooktime = 10,
})

core.register_craft({
	type = "cooking",
	output = "mcl_dye:green",
	recipe = "group:sea_pickle",
	cooktime = 10,
})

-- Dye mixing recipes.
--
core.register_craft({
	type = "shapeless",
	output = "mcl_dye:dark_grey 2",
	recipe = {"mcl_dye:black", "mcl_dye:white"},
})

core.register_craft({
	type = "shapeless",
	output = "mcl_dye:lightblue 2",
	recipe = {"mcl_dye:blue", "mcl_dye:white"},
})

core.register_craft({
	type = "shapeless",
	output = "mcl_dye:grey 3",
	recipe = {"mcl_dye:black", "mcl_dye:white", "mcl_dye:white"},
})

core.register_craft({
	type = "shapeless",
	output = "mcl_dye:grey 2",
	recipe = {"mcl_dye:dark_grey", "mcl_dye:white"},
})

core.register_craft({
	type = "shapeless",
	output = "mcl_dye:green 2",
	recipe = {"mcl_dye:dark_green", "mcl_dye:white"},
})

core.register_craft({
	type = "shapeless",
	output = "mcl_dye:magenta 4",
	recipe = {"mcl_dye:blue", "mcl_dye:white", "mcl_dye:red", "mcl_dye:red"},
})

core.register_craft({
	type = "shapeless",
	output = "mcl_dye:magenta 3",
	recipe = {"mcl_dye:pink", "mcl_dye:red", "mcl_dye:blue"},
})

core.register_craft({
	type = "shapeless",
	output = "mcl_dye:magenta 2",
	recipe = {"mcl_dye:violet", "mcl_dye:pink"},
})
core.register_craft({
	type = "shapeless",
	output = "mcl_dye:pink 2",
	recipe = {"mcl_dye:red", "mcl_dye:white"},
})
core.register_craft({
	type = "shapeless",
	output = "mcl_dye:cyan 2",
	recipe = {"mcl_dye:blue", "mcl_dye:dark_green"},
})
core.register_craft({
	type = "shapeless",
	output = "mcl_dye:violet 2",
	recipe = {"mcl_dye:blue", "mcl_dye:red"},
})

core.register_craft({
	type = "shapeless",
	output = "mcl_dye:orange 2",
	recipe = {"mcl_dye:yellow", "mcl_dye:red"},
})

-- Wool dyeing recipes
--

for d = 1, #dyes do
	core.register_craft({
		type = "shapeless",
		output = "mcl_wool:" .. dyes[d][1],
		recipe = {"group:wool", "mcl_dye:" .. dyes[d][1]},
	})
end
