local mp = minetest.get_modpath(minetest.get_current_modname())

local S = minetest.get_translator(mp)

mcl_archaeology = {}
mcl_archaeology.pottery_sherds = {
	-- name,                         description
	{"angler",         S("Angler Pottery Sherd")},
	{"archer",         S("Archer Pottery Sherd")},
	{"arms_up",       S("Arms Up Pottery Sherd")},
	{"blade",           S("Blade Pottery Sherd")},
	{"brewer",         S("Brewer Pottery Sherd")},
	{"burn",             S("Burn Pottery Sherd")},
	{"danger",         S("Danger Pottery Sherd")},
	{"explorer",     S("Explorer Pottery Sherd")},
	{"friend",         S("Friend Pottery Sherd")},
	{"heart",           S("Heart Pottery Sherd")},
	{"heartbreak", S("Heartbreak Pottery Sherd")},
	{"howl",             S("Howl Pottery Sherd")},
	{"miner",           S("Miner Pottery Sherd")},
	{"mourner",       S("Mourner Pottery Sherd")},
	{"plenty",         S("Plenty Pottery Sherd")},
	{"prize",           S("Prize Pottery Sherd")},
	{"sheaf",           S("Sheaf Pottery Sherd")},
	{"shelter",       S("Shelter Pottery Sherd")},
	{"skull",           S("Skull Pottery Sherd")},
	{"snort",           S("Snort Pottery Sherd")}
}

dofile(mp.."/items.lua")
dofile(mp.."/nodes.lua")
