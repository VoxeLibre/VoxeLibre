local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
--local S = minetest.get_translator(modname)

local mgp = minetest.get_mapgen_params()
local pr = PseudoRandom(mgp.seed)

--schematics by chmodsayshello 
local schems = {
	"shipwreck_full_damaged",
	"shipwreck_full_normal",
	"shipwreck_full_back_damaged",
	"shipwreck_half_front",
	"shipwreck_half_back",
}

local loottable_supply = {
	stacks_min = 3,
	stacks_max = 10,
	items = {
		--{ itemstring = "TODO:sus_stew", weight = 10, amount_min = 1, amount_max = 1 },
		{ itemstring = "mcl_core:paper", weight = 8, amount_min = 1, amount_max = 12 },
		{ itemstring = "mcl_farming:wheat_item", weight = 7, amount_min = 8, amount_max = 21 },
		{ itemstring = "mcl_farming:carrot_item", weight = 7, amount_min = 4, amount_max = 8 },
		{ itemstring = "mcl_farming:potato_item_poison", weight = 7, amount_min = 2, amount_max = 6 },
		{ itemstring = "mcl_farming:potato_item", weight = 7, amount_min = 2, amount_max = 6 },
		--{ itemstring = "TODO:moss_block", weight = 7, amount_min = 1, amount_max = 4 },
		{ itemstring = "mcl_core:coal_lump", weight = 6, amount_min = 2, amount_max = 8 },
		{ itemstring = "mcl_mobitems:rotten_flesh", weight = 5, amount_min = 5, amount_max = 24 },
		{ itemstring = "mcl_farming:potato_item", weight = 3, amount_min = 1, amount_max = 5 },
		{ itemstring = "mcl_armor:helmet_leather_enchanted", weight = 3 },
		{ itemstring = "mcl_armor:chestplate_leather_enchanted", weight = 3 },
		{ itemstring = "mcl_armor:leggings_leather_enchanted", weight = 3 },
		{ itemstring = "mcl_armor:boots_leather_enchanted", weight = 3 },
		--{ itemstring = "TODO:bamboo", weight = 2, amount_min = 1, amount_max = 3 },
		{ itemstring = "mcl_farming:pumpkin", weight = 2, amount_min = 1, amount_max = 3 },
		{ itemstring = "mcl_tnt:tnt", weight = 1, amount_min = 1, amount_max = 2 },
		
	}
}

local loottable_treasure = {
	stacks_min = 3,
	stacks_max = 10,
	items = {
		{ itemstring = "mcl_core:iron_ingot", weight = 8, amount_min = 1, amount_max = 5 },
		{ itemstring = "mcl_core:iron_nugget", weight = 8, amount_min = 1, amount_max = 10 },
		{ itemstring = "mcl_core:emerald", weight = 8, amount_min = 1, amount_max = 12 },
		{ itemstring = "mcl_dye:blue", weight = 8, amount_min = 1, amount_max = 12 },
		{ itemstring = "mcl_core:gold_ingot", weight = 8, amount_min = 1, amount_max = 5 },
		{ itemstring = "mcl_core:gold_nugget", weight = 8, amount_min = 1, amount_max = 10 },
		{ itemstring = "mcl_experience:bottle", weight = 8, amount_min = 1, amount_max = 10 },
		{ itemstring = "mcl_core:diamond", weight = 8, amount_min = 1, amount_max = 10 },
	}
}

local function fill_chests(p1,p2)
	for _,p in pairs(minetest.find_nodes_in_area(p1,p2,{"mcl_chests:chest_small"})) do
		if minetest.get_meta(p):get_string("infotext") ~= "Chest" then
			minetest.registered_nodes["mcl_chests:chest_small"].on_construct(p)
		end
		local inv = minetest.get_inventory( {type="node", pos=p} )
		local loot = loottable_supply
		if pr:next(1,10) == 1 then loot = loottable_treasure end
		mcl_loot.fill_inventory(inv, "main", mcl_loot.get_multi_loot({loot}, pr), pr)
	end
end

local function get_ocean_biomes()
	local r = {}
	for k,_ in pairs(minetest.registered_biomes) do
		if k:find("_ocean") then table.insert(r,k) end
	end
	return r
end

minetest.register_node("mcl_shipwrecks:structblock", {drawtype="airlike",groups = {structblock=1,not_in_creative_inventory=1},})

minetest.register_decoration({
	decoration = "mcl_shipwrecks:structblock",
	deco_type = "simple",
	place_on = {"group:sand","mcl_core:gravel"},
	spawn_by = {"group:water"},
	num_spawn_by = 4,
	sidelen = 80,
	fill_ratio = 0.00002,
	flags = "place_center_x, place_center_z, force_placement",
	biomes = get_ocean_biomes(),
	y_max=mgp.water_level-4,
})

minetest.register_lbm({
	name = "mcl_shipwrecks:struct_lbm",
	run_at_every_load = true,
	nodenames = {"mcl_shipwrecks:structblock"},
	action = function(pos, node)
		minetest.set_node(pos,{name="air"})
		local file = modpath.."/schematics/"..schems[pr:next(1,#schems)]..".mts"
		local pp = vector.offset(pos,0,pr:next(-4,-2),0)
		mcl_structures.place_schematic(pp, file, "random", nil, true, "place_center_x,place_center_z", function()
			fill_chests(vector.offset(pos,-20,-5,-20),vector.offset(pos,20,15,20))
		end)-- pr, callback_param
	end
})
