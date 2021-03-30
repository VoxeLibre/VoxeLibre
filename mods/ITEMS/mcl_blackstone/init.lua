local S = minetest.get_translator("mcl_blackstone")
local N = function(s) return s end
local LIGHT_TORCH = 10

stairs = {}

local fire_help, eternal_fire_help
if fire_enabled then
	fire_help = S("Fire is a damaging and destructive but short-lived kind of block. It will destroy and spread towards near flammable blocks, but fire will disappear when there is nothing to burn left. It will be extinguished by nearby water and rain. Fire can be destroyed safely by punching it, but it is hurtful if you stand directly in it. If a fire is started above netherrack or a magma block, it will immediately turn into an eternal fire.")
else
	fire_help = S("Fire is a damaging but non-destructive short-lived kind of block. It will disappear when there is no flammable block around. Fire does not destroy blocks, at least not in this world. It will be extinguished by nearby water and rain. Fire can be destroyed safely by punching it, but it is hurtful if you stand directly in it. If a fire is started above netherrack or a magma block, it will immediately turn into an eternal fire.")
end

if fire_enabled then
	eternal_fire_help = S("Eternal fire is a damaging block that might create more fire. It will create fire around it when flammable blocks are nearby. Eternal fire can be extinguished by punches and nearby water blocks. Other than (normal) fire, eternal fire does not get extinguished on its own and also continues to burn under rain. Punching eternal fire is safe, but it hurts if you stand inside.")
else
	eternal_fire_help = S("Eternal fire is a damaging block. Eternal fire can be extinguished by punches and nearby water blocks. Other than (normal) fire, eternal fire does not get extinguished on its own and also continues to burn under rain. Punching eternal fire is safe, but it hurts if you stand inside.")
end


local fire_death_messages = {
	N("@1 has been cooked crisp."),
	N("@1 felt the burn."),
	N("@1 died in the flames."),
	N("@1 died in a fire."),
}

--nodes






local mod_screwdriver = minetest.get_modpath("screwdriver") ~= nil
local on_rotate
if mod_screwdriver then
	on_rotate = screwdriver.rotate_3way
end
local alldirs = {{x=0,y=0,z=1}, {x=1,y=0,z=0}, {x=0,y=0,z=-1}, {x=-1,y=0,z=0}, {x=0,y=-1,z=0}, {x=0,y=1,z=0}}

--Blocks

minetest.register_node("mcl_blackstone:blackstone", {
	description = S("Blackstone"),
	tiles = {"mcl_blackstone.png"},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=2, material_stone=1},
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})

minetest.register_node("mcl_blackstone:blackstone_gilded", {
	description = S("Gilded Blackstone"),
	tiles = {"mcl_blackstone.png^mcl_blackstone_gilded_side.png"},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=2, material_stone=1, xp=1},
	drop = {
		max_items = 1,
		items = {
			{items = {'mcl_core:gold_nugget 2'},rarity = 5},
			{items = {'mcl_core:gold_nugget 3'},rarity = 5},
			{items = {'mcl_core:gold_nugget 4'},rarity = 5},
			{items = {'mcl_core:gold_nugget 5'},rarity = 5},
			{items = {'mcl_blackstone:blackstone_gilded'}, rarity = 8},
		}
	},
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = mcl_core.fortune_drop_ore,
})

minetest.register_node("mcl_blackstone:nether_gold", {
	description = S("Nether Gold Ore"),
	tiles = {"mcl_nether_netherrack.png^mcl_blackstone_gilded_side.png"},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=2, material_stone=1, xp=1},
	drop = {
		max_items = 1,
		items = {
			{items = {'mcl_core:gold_nugget 2'},rarity = 5},
			{items = {'mcl_core:gold_nugget 3'},rarity = 5},
			{items = {'mcl_core:gold_nugget 4'},rarity = 5},
			{items = {'mcl_core:gold_nugget 5'},rarity = 5},
			{items = {'mcl_blackstone:nether_gold'}, rarity = 8},
		}
	},
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = mcl_core.fortune_drop_ore,
})

minetest.register_node("mcl_blackstone:basalt_polished", {
	description = S("Polished Basalt"),
	tiles = {"mcl_blackstone_basalt_top_polished.png", "mcl_blackstone_basalt_top_polished.png", "mcl_blackstone_basalt_side_polished.png"},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	on_rotate = on_rotate,
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=2, material_stone=1},
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})


minetest.register_node("mcl_blackstone:basalt", {
	description = S("Basalt"),
	tiles = {"mcl_blackstone_basalt_top.png", "mcl_blackstone_basalt_top.png", "mcl_blackstone_basalt_side.png"},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	on_rotate = on_rotate,
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=2, material_stone=1},
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})

--[[minetest.register_node("mcl_blackstone:basalt_smooth", {
	description = S("Smooth Basalt"),
	tiles = {"mcl_blackstone_basalt_smooth.png"},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=2, material_stone=1},
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})
]]--


minetest.register_node("mcl_blackstone:blackstone_polished", {
	description = S("Polished Blackstone"),
	tiles = {"mcl_blackstone_polished.png"},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=2, material_stone=1},
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})


minetest.register_node("mcl_blackstone:blackstone_chiseled_polished", {
	description = S("Chiseled Polished Blackstone"),
	tiles = {"mcl_blackstone_chiseled_polished.png"},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=2, material_stone=1},
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})


minetest.register_node("mcl_blackstone:blackstone_brick_polished", {
	description = S("Polished Blackstone Bricks"),
	tiles = {"mcl_blackstone_polished_bricks.png"},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=2, material_stone=1},
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})

minetest.register_node("mcl_blackstone:quartz_brick", {
	description = S("Quartz Bricks"),
	tiles = {"mcl_backstone_quartz_bricks.png"},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	groups = {cracky = 3, pickaxey=2, material_stone=1},
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})

minetest.register_node("mcl_blackstone:soul_soil", {
	description = S("Soul Soil"),
	tiles = {"mcl_blackstone_soul_soil.png"},
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_sand_defaults(),
	groups = {cracky = 3, handy=1, shovely=1},
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
})


minetest.register_node("mcl_blackstone:soul_fire", {
	description = S("Eternal Soul Fire"),
	_doc_items_longdesc = eternal_fire_help,
	drawtype = "firelike",
	tiles = {
		{
			name = "soul_fire_basic_flame_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1
			},
		},
	},
	inventory_image = "soul_fire_basic_flame.png",
	paramtype = "light",
	light_source = 10,
	walkable = false,
	buildable_to = true,
	sunlight_propagates = true,
	damage_per_second = 2,
	_mcl_node_death_message = fire_death_messages,
	groups = {fire = 1, dig_immediate = 3, not_in_creative_inventory = 1, dig_by_piston = 1, destroys_items = 1, set_on_fire=8},
	floodable = true,
	on_flood = function(pos, oldnode, newnode)
		if minetest.get_item_group(newnode.name, "water") ~= 0 then
			minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
		end
	end,
})
--[[
minetest.register_node("mcl_blackstone:chain", {
	description = S("Chain"),
	drawtype = "plantlike",
	_doc_items_longdesc = S(""),
	_doc_items_hidden = false,
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	on_rotate = on_rotate,
	tiles = {"mcl_blackstone_chain.png"},
	inventory_image = "mcl_blackstone_chain_inv.png",
	wield_image = "mcl_blackstone_chain_inv.png",
	selection_box = {
		type = "fixed",
		fixed = {{ -2/16, -8/16, -2/16, 2/16, 8/16, 2/16 }},
	},
	paramtype = "light",
	paramtype2 = "color",
	walkable = false,
	is_ground_content = true,
	groups = {pickaxey=2,deco_block=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 2,
	_mcl_hardness = 1,
})
]]--

--slabs/stairs

mcl_stairs.register_stair_and_slab_simple("blackstone", "mcl_blackstone:blackstone", "Blackstone Stair", "Blackstone Slab", "Double Blackstone Slab")


mcl_stairs.register_stair_and_slab_simple("blackstone_polished", "mcl_blackstone:blackstone_polished", "Polished Blackstone Stair", "Polished Blackstone Slab", "Polished Double Blackstone Slab")


mcl_stairs.register_stair_and_slab_simple("blackstone_chiseled_polished", "mcl_blackstone:blackstone_chiseled_polished", "Polished Chiseled Blackstone Stair", "Chiseled Polished Blackstone Slab", "Double Polished Chiseled Blackstone Slab")


mcl_stairs.register_stair_and_slab_simple("blackstone_brick_polished", "mcl_blackstone:blackstone_brick_polished", "Polished Blackstone Brick Stair", "Polished Blackstone  Brick Slab", "Double Polished Blackstone Brick Slab")

--Wall

mcl_walls.register_wall("mcl_blackstone:wall", S("Blackstone Wall"), "mcl_blackstone:blackstone")


--Redstone Things
--[[
mesecon.register_pressure_plate(
	"mcl_blackstone:pressure_plate_blackstone",
	S("Blackstone Pressure Plate"),
	{"mcl_blackstone.png"},
	{"mcl_blackstone.png"},
	"mcl_blackstone.png",
	nil,
	{{"mcl_blackstone:blackstone", "mcl_blackstone:blackstone"}},
--	mcl_sounds.node_sound_stone_defaults(),
	{pickaxey=1, material_stone=1},
	{ player = true, mob = true },
	S("A Blackstone pressure plate is a redstone component which supplies its surrounding blocks with redstone power while a player or mob stands on top of it. It is not triggered by anything else."))


mesecon.register_button(
	"stone",
	S("Blacktone Button"),
	"mcl_blackstone.png",
	"mcl_blackstone:blackstone",
--	mcl_sounds.node_sound_stone_defaults(),
	{material_stone=1,handy=1,pickaxey=1,cracky=3},
	1,
	false,
	(""),
	"mesecons_button_push")
]]--
--lavacooling


minetest.register_abm({
	label = "Lava cooling (basalt)",
	nodenames = {"group:lava"},
	neighbors = {"mcl_core:ice"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local water = minetest.find_nodes_in_area({x=pos.x-1, y=pos.y-1, z=pos.z-1}, {x=pos.x+1, y=pos.y+1, z=pos.z+1}, "mcl_core:ice")

		local lavatype = minetest.registered_nodes[node.name].liquidtype

		for w=1, #water do
			local waternode = minetest.get_node(water[w])
			local watertype = minetest.registered_nodes[waternode.name].liquidtype
			if water[w].y < pos.y and water[w].x == pos.x and water[w].z == pos.z then
				minetest.set_node(water[w], {name="mcl_blackstone:basalt"})
			elseif lavatype == "flowing" and water[w].y == pos.y and (water[w].x == pos.x or water[w].z == pos.z) then
				minetest.set_node(pos, {name="mcl_blackstone:basalt"})
			elseif lavatype == "flowing" and water[w].y > pos.y and water[w].x == pos.x and water[w].z == pos.z then
				minetest.set_node(pos, {name="mcl_blackstone:basalt"})
			end
		end
	end,
})


--[[minetest.register_abm({
	label = "Fire souling",
	nodenames = {"mcl_nether:soul_sand"},
	neighbors = {"mcl_fire:fire"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local water = minetest.find_nodes_in_area({x=pos.x-1, y=pos.y-1, z=pos.z-1}, {x=pos.x+1, y=pos.y+1, z=pos.z+1}, "mcl_fire:fire")

		local lavatype = minetest.registered_nodes[node.name].liquidtype

		for w=1, #water do
			local waternode = minetest.get_node(water[w])
			local watertype = minetest.registered_nodes[waternode.name].liquidtype
			if water[w].y < pos.y and water[w].x == pos.x and water[w].z == pos.z then
				minetest.set_node(water[w], {name="mcl_blackstone:soul_fire"})
			elseif lavatype == "flowing" and water[w].y == pos.y and (water[w].x == pos.x or water[w].z == pos.z) then
				minetest.set_node(pos, {name="mcl_blackstone:soul_fire"})
			elseif lavatype == "flowing" and water[w].y > pos.y and water[w].x == pos.x and water[w].z == pos.z then
				minetest.set_node(pos, {name="mcl_blackstone:soul_fire"})
			end
		end
	end,
})
]]--

minetest.register_abm({
	label = "Lava cooling (blackstone)",
	nodenames = {"group:lava"},
	neighbors = {"mcl_core:packed_ice"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local water = minetest.find_nodes_in_area({x=pos.x-1, y=pos.y-1, z=pos.z-1}, {x=pos.x+1, y=pos.y+1, z=pos.z+1}, "mcl_core:packed_ice")

		local lavatype = minetest.registered_nodes[node.name].liquidtype

		for w=1, #water do
			local waternode = minetest.get_node(water[w])
			local watertype = minetest.registered_nodes[waternode.name].liquidtype
			if water[w].y < pos.y and water[w].x == pos.x and water[w].z == pos.z then
				minetest.set_node(water[w], {name="mcl_blackstone:blackstone"})
			elseif lavatype == "flowing" and water[w].y == pos.y and (water[w].x == pos.x or water[w].z == pos.z) then
				minetest.set_node(pos, {name="mcl_blackstone:blackstone"})
			elseif lavatype == "flowing" and water[w].y > pos.y and water[w].x == pos.x and water[w].z == pos.z then
				minetest.set_node(pos, {name="mcl_blackstone:blackstone"})
			end
		end
	end,
})

--crafting



minetest.register_craft({
	output = 'mcl_blackstone:blackstone_polished 4',
	recipe = {
		{'mcl_blackstone:blackstone','mcl_blackstone:blackstone'},
		{'mcl_blackstone:blackstone','mcl_blackstone:blackstone'},
	}
})

minetest.register_craft({
	output = 'mcl_blackstone:basalt_polished 4',
	recipe = {
		{'mcl_blackstone:basalt','mcl_blackstone:basalt'},
		{'mcl_blackstone:basalt','mcl_blackstone:basalt'},
	}
})

minetest.register_craft({
	output = 'mcl_blackstone:blackstone_chiseled_polished 2',
	recipe = {
		{'mcl_blackstone:blackstone_polished'},
		{'mcl_blackstone:blackstone_polished'},
	}
})
minetest.register_craft({
	output = 'mcl_blackstone:blackstone_brick_polished 4',
	recipe = {
		{'mcl_blackstone:blackstone_polished','mcl_blackstone:blackstone_polished'},
		{'mcl_blackstone:blackstone_polished','mcl_blackstone:blackstone_polished'},
	}
})


minetest.register_craft({
	output = 'mcl_tools:pick_stone',
	recipe = {
		{'mcl_blackstone:blackstone', 'mcl_blackstone:blackstone', 'mcl_blackstone:blackstone'},
		{'', 'mcl_core:stick', ''},
		{'', 'mcl_core:stick', ''},
	}
})


minetest.register_craft({
	output = 'mcl_tools:axe_stone',
	recipe = {
		{'mcl_blackstone:blackstone', 'mcl_blackstone:blackstone'},
		{'mcl_blackstone:blackstone', 'mcl_core:stick'},
		{'', 'mcl_core:stick'},
	}
})


minetest.register_craft({
	output = 'mcl_tools:axe_stone',
	recipe = {
		{'mcl_blackstone:blackstone', 'mcl_blackstone:blackstone'},
		{'mcl_core:stick',  'mcl_blackstone:blackstone'},
		{'', 'mcl_core:stick'},
	}
})


minetest.register_craft({
	output = 'mcl_tools:shovel_stone',
	recipe = {
		{'mcl_blackstone:blackstone'},
		{'mcl_core:stick'},
		{'mcl_core:stick'},
	}
})


minetest.register_craft({
	output = 'mcl_tools:sword_stone',
	recipe = {
		{'mcl_blackstone:blackstone'},
		{'mcl_blackstone:blackstone'},
		{'mcl_core:stick'},
	}
})


minetest.register_craft({
	output = "mcl_farming:hoe_stone",
	recipe = {
		{"mcl_blackstone:blackstone", "mcl_blackstone:blackstone"},
		{"", "mcl_core:stick"},
		{"", "mcl_core:stick"}
	}
})
minetest.register_craft({
	output = "mcl_farming:hoe_stone",
	recipe = {
		{"mcl_blackstone:blackstone", "mcl_blackstone:blackstone"},
		{"mcl_core:stick", ""},
		{"mcl_core:stick", ""}
	}
})

minetest.register_craft({
	output = "mcl_furnaces:furnace",
	recipe = {
		{"mcl_blackstone:blackstone", "mcl_blackstone:blackstone", "mcl_blackstone:blackstone"},
		{"mcl_blackstone:blackstone", "",			   "mcl_blackstone:blackstone"},
		{"mcl_blackstone:blackstone", "mcl_blackstone:blackstone", "mcl_blackstone:blackstone"}
	}
})




minetest.register_craft({
	output = 'mcl_core:packed_ice',
	recipe = {
		{'mcl_core:ice','mcl_core:ice'},
		{'mcl_core:ice','mcl_core:ice'},
	}
})

minetest.register_craft({
	output = 'mcl_blackstone:quartz_brick 4',
	recipe = {
		{'mcl_nether:quartz_block','mcl_nether:quartz_block'},
		{'mcl_nether:quartz_block','mcl_nether:quartz_block'},
	}
})


minetest.register_craft({
	type = "cooking",
	output = 'mcl_core:gold_ingot',
	recipe = 'mcl_blackstone:nether_gold',
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = 'mcl_core:gold_ingot',
	recipe = 'mcl_blackstone:blackstone_gilded',
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = 'mcl_nether:quartz_smooth',
	recipe = 'mcl_nether:quartz_block',
	cooktime = 10,
})

--Generating


local specialstones = { "mcl_blackstone:blackstone", "mcl_blackstone:basalt", "mcl_blackstone:soul_soil" }
for s=1, #specialstones do
	local node = specialstones[s]
	minetest.register_ore({
		ore_type       = "blob",
		ore            = node,
		wherein        = {"mcl_nether:netherrack"},
		clust_scarcity = 830,
		clust_num_ores = 28,
		clust_size     = 3,
		y_min          = mcl_vars.mg_nether_min,
		y_max          = mcl_vars.mg_nether_max,
	})
	minetest.register_ore({
		ore_type       = "blob",
		ore            = node,
		wherein        = {"mcl_nether:netherrack"},
		clust_scarcity = 8*8*8,
		clust_num_ores = 40,
		clust_size     = 5,
		y_min          = mcl_vars.mg_nether_min,
		y_max          = mcl_vars.mg_nether_max,
	})
end

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_blackstone:blackstone_gilded",
		wherein        = "mcl_blackstone:blackstone",
		clust_scarcity = 4775,
		clust_num_ores = 2,
		clust_size     = 2,
		y_min          = mcl_vars.mg_nether_min,
		y_max          = mcl_vars.mg_nether_max,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_blackstone:nether_gold",
		wherein        = "mcl_nether:netherrack",
		clust_scarcity = 830,
		clust_num_ores = 5,
		clust_size     = 3,
		y_min          = mcl_vars.mg_nether_min,
		y_max          = mcl_vars.mg_nether_max,
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_blackstone:nether_gold",
		wherein        = "mcl_nether:netherrack",
		clust_scarcity = 1660,
		clust_num_ores = 4,
		clust_size     = 2,
		y_min          = mcl_vars.mg_nether_min,
		y_max          = mcl_vars.mg_nether_max,
	})



--This is in progress

--[[
local specialstones = { "mcl_blackstone:blackstone"}
for s=1, #specialstones do
	local node = specialstones[s]
	minetest.register_ore({
		ore_type       = "blob",
		ore            = node,
		wherein        = {"mcl_blackstone:basalt"},
		clust_scarcity = 8*8*8,
		clust_num_ores = 28,
		clust_size     = 3,
		y_min          = mcl_vars.mg_nether_min,
		y_max          = mcl_vars.mg_nether_max,
	})
	minetest.register_ore({
		ore_type       = "blob",
		ore            = node,
		wherein        = {"mcl_blackstone:basalt"},
		clust_scarcity = 8*8*8,
		clust_num_ores = 40,
		clust_size     = 5,
		y_min          = mcl_vars.mg_nether_min,
		y_max          = mcl_vars.mg_nether_max,
	})
end






--Biomes



	minetest.register_biome({
		name = "Basalt_Deltas",
		node_filler = "mcl_blackstone:basalt",
		node_stone = "mcl_blackstone:basalt",
		node_water = "air",
		node_river_water = "air",
		y_min = mcl_vars.mg_nether_min,
		node_riverbed = "mcl_core:lava_source",
		depth_riverbed = 2,
		y_max = mcl_vars.mg_nether_max,
		humidity_point = 36,
		heat_point = 100,
		spread = {x = 1, y = 1, z = 1},
		humidity_point = 0,
		_mcl_biome_type = "hot",
		_mcl_palette_index = 12,
	})



	-- Magma blocks
	minetest.register_ore({
		ore_type       = "blob",
		ore            = "mcl_nether:magma",
		wherein         = {"mcl_blackstone:basalt", "mcl_core:stone"},
		clust_scarcity = 8*8*8,
		clust_num_ores = 45,
		clust_size     = 6,
		y_min          = mcl_worlds.layer_to_y(23, "nether"),
		y_max          = mcl_worlds.layer_to_y(37, "nether"),
	})
	minetest.register_ore({
		ore_type       = "blob",
		ore            = "mcl_nether:magma",
		wherein        = {"mcl_blackstone:basalt"},
		clust_scarcity = 10*10*10,
		clust_num_ores = 65,
		clust_size     = 8,
		y_min          = mcl_worlds.layer_to_y(23, "nether"),
		y_max          = mcl_worlds.layer_to_y(37, "nether"),
	})

	-- Glowstone
	minetest.register_ore({
		ore_type        = "blob",
		ore             = "mcl_nether:glowstone",
		wherein         = {"mcl_blackstone:basalt", "mcl_core:stone"},
		clust_scarcity  = 26 * 26 * 26,
		clust_size      = 5,
		y_min           = mcl_vars.mg_lava_nether_max + 10,
		y_max           = mcl_vars.mg_nether_max,
		noise_threshold = 0.0,
		noise_params    = {
			offset = 0.5,
			scale = 0.1,
			spread = {x = 5, y = 5, z = 5},
			seed = 17676,
			octaves = 1,
			persist = 0.0
		},
	})

	-- Gravel (Nether)
	minetest.register_ore({
		ore_type        = "sheet",
		ore             = "mcl_core:gravel",
		wherein         = {"mcl_blackstone:basalt", "mcl_core:stone"},
		column_height_min = 1,
		column_height_max = 1,
		column_midpoint_factor = 0,
		y_min           = mcl_worlds.layer_to_y(63, "nether"),
		-- This should be 65, but for some reason with this setting, the sheet ore really stops at 65. o_O
		y_max           = mcl_worlds.layer_to_y(65+2, "nether"),
		noise_threshold = 0.2,
		noise_params    = {
			offset = 0.0,
			scale = 0.5,
			spread = {x = 20, y = 20, z = 20},
			seed = 766,
			octaves = 3,
			persist = 0.6,
		},
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_nether:nether_lava_source",
		wherein         = {"mcl_blackstone:basalt", "mcl_core:stone"},
		clust_scarcity = 500,
		clust_num_ores = 1,
		clust_size     = 1,
		y_min           = mcl_vars.mg_nether_min,
		y_max           = mcl_vars.mg_lava_nether_max + 1,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_nether:nether_lava_source",
		wherein         = {"mcl_blackstone:basalt", "mcl_core:stone"},
		clust_scarcity = 1000,
		clust_num_ores = 1,
		clust_size     = 1,
		y_min           = mcl_vars.mg_lava_nether_max + 2,
		y_max           = mcl_vars.mg_lava_nether_max + 12,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_nether:nether_lava_source",
		wherein         = {"mcl_blackstone:basalt", "mcl_core:stone"},
		clust_scarcity = 2000,
		clust_num_ores = 1,
		clust_size     = 1,
		y_min           = mcl_vars.mg_lava_nether_max + 13,
		y_max           = mcl_vars.mg_lava_nether_max + 48,
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_nether:nether_lava_source",
		wherein         = {"mcl_blackstone:basalt", "mcl_core:stone"},
		clust_scarcity = 3500,
		clust_num_ores = 1,
		clust_size     = 1,
		y_min           = mcl_vars.mg_lava_nether_max + 49,
		y_max           = mcl_vars.mg_nether_max,
	})


local specialstones = { "mcl_nether:netherrack"}
for s=1, #specialstones do
	local node = specialstones[s]
	minetest.register_ore({
		ore_type       = "blob",
		ore            = node,
		wherein        = {"mcl_blackstone:basalt"},
		clust_scarcity = 8*8*8,
		clust_num_ores = 28,
		clust_size     = 3,
		y_min          = mcl_vars.mg_nether_min,
		y_max          = mcl_vars.mg_nether_max,
	})
	minetest.register_ore({
		ore_type       = "blob",
		ore            = node,
		wherein        = {"mcl_blackstone:basalt"},
		clust_scarcity = 8*8*8,
		clust_num_ores = 40,
		clust_size     = 5,
		y_min          = mcl_vars.mg_nether_min,
		y_max          = mcl_vars.mg_nether_max,
	})
end
]]--





--torches
local spawn_flames_floor = function(pos)
	-- Flames
	mcl_particles.add_node_particlespawner(pos, {
		amount = 8,
		time = 0,
		minpos = vector.add(pos, { x = -0.1, y = 0.05, z = -0.1 }),
		maxpos = vector.add(pos, { x = 0.1, y = 0.15, z = 0.1 }),
		minvel = { x = -0.01, y = 0, z = -0.01 },
		maxvel = { x = 0.01, y = 0.1, z = 0.01 },
		minexptime = 0.3,
		maxexptime = 0.6,
		minsize = 0.7,
		maxsize = 2,
		texture = "mcl_particles_flame.png",
		glow = 10,
	}, "low")
	-- Smoke
	mcl_particles.add_node_particlespawner(pos, {
		amount = 0.5,
		time = 0,
		minpos = vector.add(pos, { x = -1/16, y = 0.04, z = -1/16 }),
		maxpos = vector.add(pos, { x = -1/16, y = 0.06, z = -1/16 }),
		minvel = { x = 0, y = 0.5, z = 0 },
		maxvel = { x = 0, y = 0.6, z = 0 },
		minexptime = 2.0,
		maxexptime = 2.0,
		minsize = 1.5,
		maxsize = 1.5,
		texture = "mcl_particles_smoke_anim.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 8,
			aspect_h = 8,
			length = 2.05,
		},
	}, "medium")
end

local spawn_flames_wall = function(pos, param2)
	local minrelpos, maxrelpos
	local dir = minetest.wallmounted_to_dir(param2)
	if dir.x < 0 then
		minrelpos = { x = -0.38, y = 0.04, z = -0.1 }
		maxrelpos = { x = -0.2, y = 0.14, z = 0.1 }
	elseif dir.x > 0 then
		minrelpos = { x = 0.2, y = 0.04, z = -0.1 }
		maxrelpos = { x = 0.38, y = 0.14, z = 0.1 }
	elseif dir.z < 0 then
		minrelpos = { x = -0.1, y = 0.04, z = -0.38 }
		maxrelpos = { x = 0.1, y = 0.14, z = -0.2 }
	elseif dir.z > 0 then
		minrelpos = { x = -0.1, y = 0.04, z = 0.2 }
		maxrelpos = { x = 0.1, y = 0.14, z = 0.38 }
	else
		return
	end
	-- Flames
	mcl_particles.add_node_particlespawner(pos, {
		amount = 8,
		time = 0,
		minpos = vector.add(pos, minrelpos),
		maxpos = vector.add(pos, maxrelpos),
		minvel = { x = -0.01, y = 0, z = -0.01 },
		maxvel = { x = 0.01, y = 0.1, z = 0.01 },
		minexptime = 0.3,
		maxexptime = 0.6,
		minsize = 0.7,
		maxsize = 2,
		texture = "mcl_particles_flame.png",
		glow = 10,
	}, "low")
	-- Smoke
	mcl_particles.add_node_particlespawner(pos, {
		amount = 0.5,
		time = 0,
		minpos = vector.add(pos, minrelpos),
		maxpos = vector.add(pos, maxrelpos),
		minvel = { x = 0, y = 0.5, z = 0 },
		maxvel = { x = 0, y = 0.6, z = 0 },
		minexptime = 2.0,
		maxexptime = 2.0,
		minsize = 1.5,
		maxsize = 1.5,
		texture = "mcl_particles_smoke_anim.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 8,
			aspect_h = 8,
			length = 2.05,
		},
	}, "medium")
end

local remove_flames = function(pos)
	mcl_particles.delete_node_particlespawners(pos)
end

--
-- 3d torch part
--

-- Check if placement at given node is allowed
local function check_placement_allowed(node, wdir)
	-- Torch placement rules: Disallow placement on some nodes. General rule: Solid, opaque, full cube collision box nodes are allowed.
	-- Special allowed nodes:
	-- * soul sand
	-- * mob spawner
	-- * chorus flower
	-- * glass, barrier, ice
	-- * Fence, wall, end portal frame with ender eye: Only on top
	-- * Slab, stairs: Only on top if upside down

	-- Special forbidden nodes:
	-- * Piston, sticky piston
	local def = minetest.registered_nodes[node.name]
	if not def then
		return false
	-- No ceiling torches
	elseif wdir == 0 then
		return false
	elseif not def.buildable_to then
		if node.name ~= "mcl_core:ice" and node.name ~= "mcl_nether:soul_sand" and node.name ~= "mcl_mobspawners:spawner" and node.name ~= "mcl_core:barrier" and node.name ~= "mcl_end:chorus_flower" and node.name ~= "mcl_end:chorus_flower_dead" and (not def.groups.glass) and
				((not def.groups.solid) or (not def.groups.opaque)) then
			-- Only allow top placement on these nodes
			if node.name == "mcl_end:dragon_egg" or node.name == "mcl_portals:end_portal_frame_eye" or def.groups.fence == 1 or def.groups.wall or def.groups.slab_top == 1 or def.groups.anvil or def.groups.pane or (def.groups.stair == 1 and minetest.facedir_to_dir(node.param2).y ~= 0) then
				if wdir ~= 1 then
					return false
				end
			else
				return false
			end
		elseif minetest.get_item_group(node.name, "piston") >= 1 then
			return false
		end
	end
	return true
end

mcl_torches = {}

mcl_torches.register_torch = function(substring, description, doc_items_longdesc, doc_items_usagehelp, icon, mesh_floor, mesh_wall, tiles, light, groups, sounds, moredef, moredef_floor, moredef_wall)
	local itemstring = minetest.get_current_modname()..":"..substring
	local itemstring_wall = minetest.get_current_modname()..":"..substring.."_wall"

	if light == nil then light = minetest.LIGHT_MAX end
	if mesh_floor == nil then mesh_floor = "mcl_torches_torch_floor.obj" end
	if mesh_wall == nil then mesh_wall = "mcl_torches_torch_wall.obj" end
	if groups == nil then groups = {} end

	groups.attached_node = 1
	groups.torch = 1
	groups.dig_by_water = 1
	groups.destroy_by_lava_flow = 1
	groups.dig_by_piston = 1

	local floordef = {
		description = description,
		_doc_items_longdesc = doc_items_longdesc,
		_doc_items_usagehelp = doc_items_usagehelp,
		drawtype = "mesh",
		mesh = mesh_floor,
		inventory_image = icon,
		wield_image = icon,
		tiles = tiles,
		paramtype = "light",
		paramtype2 = "wallmounted",
		sunlight_propagates = true,
		is_ground_content = false,
		walkable = false,
		liquids_pointable = false,
		light_source = light,
		groups = groups,
		drop = itemstring,
		selection_box = {
			type = "wallmounted",
			wall_top = {-1/16, -1/16, -1/16, 1/16, 0.5, 1/16},
			wall_bottom = {-1/16, -0.5, -1/16, 1/16, 1/16, 1/16},
		},
		sounds = sounds,
		node_placement_prediction = "",
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				-- no interaction possible with entities, for now.
				return itemstack
			end

			local under = pointed_thing.under
			local node = minetest.get_node(under)
			local def = minetest.registered_nodes[node.name]
			if not def then return itemstack end

			-- Call on_rightclick if the pointed node defines it
			if placer and not placer:get_player_control().sneak then
				if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
					return minetest.registered_nodes[node.name].on_rightclick(under, node, placer, itemstack) or itemstack
				end
			end

			local above = pointed_thing.above
			local wdir = minetest.dir_to_wallmounted({x = under.x - above.x, y = under.y - above.y, z = under.z - above.z})

			if check_placement_allowed(node, wdir) == false then
				return itemstack
			end

			local itemstring = itemstack:get_name()
			local fakestack = ItemStack(itemstack)
			local idef = fakestack:get_definition()
			local retval

			if wdir == 1 then
				retval = fakestack:set_name(itemstring)
			else
				retval = fakestack:set_name(itemstring_wall)
			end
			if not retval then
				return itemstack
			end

			local success
			itemstack, success = minetest.item_place(fakestack, placer, pointed_thing, wdir)
			itemstack:set_name(itemstring)

			if success and idef.sounds and idef.sounds.place then
				minetest.sound_play(idef.sounds.place, {pos=under, gain=1}, true)
			end
			return itemstack
		end,
		on_rotate = false,
	}
	if moredef ~= nil then
		for k,v in pairs(moredef) do
			floordef[k] = v
		end
	end
	if moredef_floor ~= nil then
		for k,v in pairs(moredef_floor) do
			floordef[k] = v
		end
	end
	minetest.register_node(itemstring, floordef)

	local groups_wall = table.copy(groups)
	groups_wall.torch = 2

	local walldef = {
		drawtype = "mesh",
		mesh = mesh_wall,
		tiles = tiles,
		paramtype = "light",
		paramtype2 = "wallmounted",
		sunlight_propagates = true,
		is_ground_content = false,
		walkable = false,
		light_source = light,
		groups = groups_wall,
		drop = itemstring,
		selection_box = {
			type = "wallmounted",
			wall_top = {-0.1, -0.1, -0.1, 0.1, 0.5, 0.1},
			wall_bottom = {-0.1, -0.5, -0.1, 0.1, 0.1, 0.1},
			wall_side = {-0.5, -0.5, -0.1, -0.2, 0.1, 0.1},
		},
		sounds = sounds,
		on_rotate = false,
	}
	if moredef ~= nil then
		for k,v in pairs(moredef) do
			walldef[k] = v
		end
	end
	if moredef_wall ~= nil then
		for k,v in pairs(moredef_wall) do
			walldef[k] = v
		end
	end
	minetest.register_node(itemstring_wall, walldef)


	-- Add entry alias for the Help
	if minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", itemstring, "nodes", itemstring_wall)
	end

end

mcl_torches.register_torch("soul_torch",
	S("Soul Torch"),
	S("Torches are light sources which can be placed at the side or on the top of most blocks."),
	nil,
	"soul_torch_on_floor.png",
	"mcl_torches_torch_floor.obj", "mcl_torches_torch_wall.obj",
	{{
		name = "soul_torch_on_floor_animated.png",
		animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
	}},
	LIGHT_TORCH,
	{dig_immediate=3, torch=1, deco_block=1},
	mcl_sounds.node_sound_wood_defaults(),
	{_doc_items_hidden = false,
	on_destruct = function(pos)
		remove_flames(pos)
	end},
	{on_construct = function(pos)
		spawn_flames_floor(pos)
	end},
	{on_construct = function(pos)
		local node = minetest.get_node(pos)
		spawn_flames_wall(pos, node.param2)
	end})

minetest.register_craft({
	output = "mcl_blackstone:soul_torch 4",
	recipe = {
		{ "mcl_nether:soul_sand" },
		{ "mcl_core:stick" },
	}
})

minetest.register_lbm({
	label = "Torch flame particles",
	name = "mcl_blackstone:flames",
	nodenames = {"mcl_blackstone:soul_torch", "mcl_blackstone:soul_torch_wall"},
	run_at_every_load = true,
	action = function(pos, node)
		if node.name == "mcl_blackstone:soul_torch" then
			spawn_flames_floor(pos)
		elseif node.name == "mcl_blackstone:soul_torch" then
			spawn_flames_wall(pos, node.param2)
		end
	end,
})


minetest.register_node("mcl_blackstone:soul_lantern", { 
		tiles = {
				"lantern_top.png",
				"lantern_bottom.png", 
				"lantern.png", 
				"lantern.png", 
				"lantern.png", 
				"lantern.png",
		},
		groups = {pickaxey=3},
		inventory_image = "lantern.png",
		light_source = 10,
		description = S("Soul Lantern"),
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		_mcl_hardness = 1,
    node_box = {
      type = "fixed",
	    fixed = {
				{-0.1875, -0.5000, -0.1875, 0.1875, -0.06250, 0.1875},
				{-0.1250, -0.06250, -0.1250, 0.1250, 0.06250, 0.1250},
				{-0.06250, 0.1250, -0.006250, 0.06250, 0.1875, 0.006250},
				{-0.06250, 0.06250, -0.006250, -0.03125, 0.1250, 0.006250},
				{0.03125, 0.06250, -0.006250, 0.06250, 0.1250, 0.006250},
	    }
    },
		stack_max = 64,
})



minetest.register_craft({
    type = "shaped",
    output = "mcl_blackstone:soul_lantern",
    recipe = {
        {"mcl_core:iron_nugget", "mcl_core:iron_nugget","mcl_core:iron_nugget"},
        {"mcl_core:iron_nugget", "mcl_blackstone:soul_torch",  "mcl_core:iron_nugget"},
        {"mcl_core:iron_nugget", "mcl_core:iron_nugget",  "mcl_core:iron_nugget"}
    }
})
