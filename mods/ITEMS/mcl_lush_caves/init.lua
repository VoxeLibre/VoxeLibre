local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

local adjacents = {
	vector.new(1,0,0),
	vector.new(-1,0,0),
	vector.new(0,0,1),
	vector.new(0,0,-1),
	vector.new(0,-1,0)
}
local plane_adjacents = {
	vector.new(1,0,0),
	vector.new(-1,0,0),
	vector.new(0,0,1),
	vector.new(0,0,-1)
}
local function vector_distance_xz(a, b)
	return vector.distance(
		{ x=a.x, y=0, z=a.z },
		{ x=b.x, y=0, z=b.z }
	)
end
mcl_lush_caves = {}

local function find_top(pos,node)
	local p = pos
	repeat
		p = vector.offset(p,0,1,0)
	until minetest.get_node(p).name ~= node.name
	return p
end

local function get_height(pos,node)
	local p = pos
	local i = 0
	repeat
		i = i + 1
		p = vector.offset(p,0,-1,0)
	until minetest.get_node(p).name  ~= node.name
	return i - 1
end

local function dripleaf_grow(pos, node)
	local t = find_top(pos,node)
	local h = get_height(t,node)
	local target = vector.offset(t,0,1,0)
	if minetest.get_node(target).name ~= "air" then return end
	if h >= 5 then return end
	minetest.set_node(t,node)
	minetest.set_node(target,{name = "mcl_lush_caves:dripleaf_big"})
end

function mcl_lush_caves.makelake(pos,def,pr)
	local p1 = vector.offset(pos,-5,-2,-5)
	local p2 = vector.offset(pos,5,1,5)
	local nn = minetest.find_nodes_in_area_under_air(p1,p2,{"group:material_stone","mcl_core:clay","mcl_lush_caves:moss"})
	table.sort(nn,function(a, b)
		   return vector_distance_xz(pos, a) < vector_distance_xz(pos, b)
	end)
	if not nn[1] then return end
	local dripleaves = {}
	for i=1,pr:next(1,#nn) do
		minetest.set_node(nn[i],{name="mcl_core:water_source"})
		if pr:next(1,20) == 1 then
			table.insert(dripleaves,nn[i])
		end
	end
	local nnn = minetest.find_nodes_in_area_under_air(p1,p2,{"mcl_core:water_source","group:water"})
	for k,v in pairs(nnn) do
		for kk,vv in pairs(adjacents) do
			local pp = vector.add(v,vv)
			local an = minetest.get_node(pp)
			if an.name ~= "mcl_core:water_source" then
				minetest.set_node(pp,{name="mcl_core:clay"})
				if pr:next(1,20) == 1 then
					minetest.set_node(vector.offset(pp,0,1,0),{name="mcl_lush_caves:moss_carpet"})
				end
			end
		end
	end
	for _,d in pairs(dripleaves) do
		if minetest.get_item_group(minetest.get_node(d).name,"water") > 0 then
			minetest.set_node(vector.offset(d,0,-1,0),{name="mcl_lush_caves:dripleaf_big_waterroot"})
			minetest.registered_nodes["mcl_lush_caves:dripleaf_big_stem"].on_construct(d)
			for ii = 1, pr:next(1,4) do
				dripleaf_grow(d,{name = "mcl_lush_caves:dripleaf_big_stem"})
			end
		end
	end
	return true
end

function mcl_lush_caves.makeazalea(pos,def,pr)
	local airup = minetest.find_nodes_in_area_under_air(vector.offset(pos,0,40,0),pos,{"mcl_core:dirt_with_grass"})
	if #airup == 0 then
		return end
	local surface_pos = airup[1]
	local nn = minetest.find_nodes_in_area(vector.offset(pos,-4,0,-4),vector.offset(pos,4,40,4),{"group:material_stone","mcl_core:dirt","mcl_core:coarse_dirt"})
	table.sort(nn,function(a, b) return vector_distance_xz(surface_pos, a) < vector_distance_xz(surface_pos, b) end)
	minetest.set_node(pos,{name="mcl_lush_caves:rooted_dirt"})
	for i=1,math.random(1,#nn) do
		local below = vector.offset(nn[i],0,-1,0)
		minetest.set_node(nn[i],{name="mcl_lush_caves:rooted_dirt"})
		if minetest.get_node(below).name == "air" then
			minetest.set_node(below,{name = "mcl_lush_caves:hanging_roots"})
		end
	end
	for _,v in pairs(nn) do
		for _,a in pairs(adjacents) do
			local p = vector.add(v,a)
			if minetest.get_item_group(minetest.get_node(p).name,"material_stone") > 0 then
				if math.random(2) == 1 then minetest.set_node(p,{name="mcl_core:stone"}) end
			end
		end
	end
	minetest.place_schematic(vector.offset(surface_pos,-2,0,-2),modpath.."/schematics/azalea1.mts","random",nil,nil,"place_center_x place_center_z")
	minetest.log("action","[mcl_lush_caves] Azalea generated at "..minetest.pos_to_string(surface_pos))
	return true
end

minetest.register_node("mcl_lush_caves:lake_structblock", {drawtype="airlike",walkable = false,pointable=false,groups = {structblock=1,not_in_creative_inventory=1},})
minetest.register_node("mcl_lush_caves:azalea_structblock", {drawtype="airlike",walkable = false,pointable=false,groups = {structblock=1,not_in_creative_inventory=1},})

minetest.register_node("mcl_lush_caves:moss", {
	description = S("Moss"),
	_doc_items_longdesc = S("Moss is a green block found in lush caves"),
	_doc_items_entry_name = "moss",
	_doc_items_hidden = false,
	tiles = {"mcl_lush_caves_moss_block.png"},
	is_ground_content = false,
	groups = {handy=1, hoey=2, dirt=1, soil=1, soil_sapling=2, enderman_takable=1, building_block=1,flammable=1,fire_encouragement=60, fire_flammability=20, grass_block_no_snow = 1 },
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 0.1,
	_mcl_hardness = 0.1,
})

minetest.register_node("mcl_lush_caves:moss_carpet", {
	description = S("Moss carpet"),
	_doc_items_longdesc = S("Moss carpet"),
	_doc_items_entry_name = "moss_carpet",

	is_ground_content = false,
	tiles = {"mcl_lush_caves_moss_carpet.png"},
	wield_image ="mcl_lush_caves_moss_carpet.png",
	wield_scale = { x=1, y=1, z=0.5 },
	groups = {handy=1, carpet=1,supported_node=1,flammable=1,fire_encouragement=60, fire_flammability=20, deco_block=1, dig_by_water=1 },
	sounds = mcl_sounds.node_sound_wool_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16, 8/16, -7/16, 8/16},
		},
	},
	_mcl_hardness = 0.1,
	_mcl_blast_resistance = 0.1,
})

minetest.register_node("mcl_lush_caves:hanging_roots", {
	description = S("Hanging roots"),
	_doc_items_create_entry = S("Hanging roots"),
	_doc_items_entry_name = S("Hanging roots"),
	_doc_items_longdesc = S("Hanging roots"),
	paramtype = "light",
	--paramtype2 = "meshoptions",
	place_param2 = 3,
	sunlight_propagates = true,
	walkable = false,
	drawtype = "plantlike",
	--drop = "mcl_farming:wheat_seeds",
	tiles = {"mcl_lush_caves_hanging_roots.png"},
	inventory_image = "mcl_lush_caves_hanging_roots.png",
	wield_image = "mcl_lush_caves_hanging_roots.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
		},
	},
	groups = { shearsy = 1, dig_immediate=3, plant=1, supported_node=0,	dig_by_water=1,destroy_by_lava_flow=1, dig_by_piston=1, cultivatable=1 },
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
	_mcl_blast_hardness = 0,
})

minetest.register_node("mcl_lush_caves:cave_vines", {
	description = S("Cave vines"),
	_doc_items_create_entry = S("Cave vines"),
	_doc_items_entry_name = S("Cave vines"),
	_doc_items_longdesc = S("Cave vines"),
	paramtype = "light",
	--paramtype2 = "meshoptions",
	place_param2 = 3,
	sunlight_propagates = true,
	walkable = false,
	drawtype = "plantlike",
	--drop = "mcl_farming:wheat_seeds",
	tiles = {"mcl_lush_caves_cave_vines.png"},
	inventory_image = "mcl_lush_caves_cave_vines.png",
	wield_image = "mcl_lush_caves_cave_vines.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
		},
	},
	groups = { shearsy = 1, dig_immediate=3, plant=1, supported_node=0,	dig_by_water=1,destroy_by_lava_flow=1, dig_by_piston=1, cultivatable=1 },
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
	_mcl_blast_hardness = 0,
})

minetest.register_node("mcl_lush_caves:cave_vines_lit", {
	description = S("Cave vines"),
	_doc_items_create_entry = S("Cave vines"),
	_doc_items_entry_name = S("Cave vines"),
	_doc_items_longdesc = S("Cave vines"),
	paramtype = "light",
	--paramtype2 = "meshoptions",
	place_param2 = 3,
	sunlight_propagates = true,
	walkable = false,
	drawtype = "plantlike",
	--drop = "mcl_farming:wheat_seeds",
	light_source = 9,
	tiles = {"mcl_lush_caves_cave_vines_lit.png"},
	inventory_image = "mcl_lush_caves_cave_vines_lit.png",
	wield_image = "mcl_lush_caves_cave_vines_lit.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
		},
	},
	groups = { shearsy = 1, handy = 1, plant=1, supported_node=0, dig_by_water=1,destroy_by_lava_flow=1, dig_by_piston=1 },
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
	_mcl_blast_hardness = 1,
	drop = "mcl_lush_caves:glow_berry",
	on_dig = function(pos)
		minetest.add_item(pos,"mcl_lush_caves:glow_berry")
		minetest.set_node(pos,{name="mcl_lush_caves:cave_vines"})
	end,
})

minetest.register_node("mcl_lush_caves:dripleaf_big_waterroot", {
		drawtype = "plantlike_rooted",
		paramtype = "light",
		paramtype2 = "leveled",
		place_param2 = 16,
		tiles = { "default_clay.png" },
		special_tiles = {
			{ name = "mcl_lush_caves_big_dripleaf_stem.png",
				animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0},
				tileable_vertical = true,
			}
		},
		inventory_image = "mcl_lush_caves_big_dripleaf_stem.png",
		selection_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
				{ -0.5, 0.5, -0.5, 0.5, 1.0, 0.5 },
			}
		},
		groups = { handy = 1, dig_immediate = 3, not_in_creative_inventory = 1 },
		drop = "",
		node_placement_prediction = "",
		_mcl_hardness = 0,
		_mcl_blast_resistance = 0,
		_mcl_silk_touch_drop = true,
		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			if itemstack:get_name() ~= "mcl_dye:white" then return itemstack end
			itemstack:take_item(1)
			--dripleaf_grow(pos,node)
		end
})
minetest.register_node("mcl_lush_caves:dripleaf_big_stem", {
	description = S("Dripleaf stem"),
	_doc_items_create_entry = S("Dripleaf stem"),
	_doc_items_entry_name = S("Dripleaf stem"),
	_doc_items_longdesc = S("Dripleaf stem"),
	paramtype = "light",
	place_param2 = 3,
	sunlight_propagates = true,
	walkable = false,
	drawtype = "plantlike",
	tiles = {"mcl_lush_caves_big_dripleaf_stem.png"},
	inventory_image = "mcl_lush_caves_big_dripleaf_stem.png",
	wield_image = "mcl_lush_caves_big_dripleaf_stem.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
		},
	},
	drop = "",
	groups = { shearsy = 1, handy = 1, plant=1, supported_node=0, destroy_by_lava_flow=1, dig_by_piston=1 },
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
	_mcl_blast_hardness = 0,
	on_construct = function(pos)
		local p = pos
		local l = 0
		local in_water = false
		for _,a in pairs(plane_adjacents) do
			if minetest.get_item_group(minetest.get_node(vector.add(pos,a)).name,"water") > 0 then
				in_water = true
			end
		end
		if not in_water then return end
		repeat
			l = l + 1
			p = vector.offset(p,0,1,0)
		until minetest.get_item_group(minetest.get_node(p).name,"water") <= 0
		minetest.set_node(p,{name = "mcl_lush_caves:dripleaf_big"})
		minetest.set_node(vector.offset(pos,0,-1,0),{ name = "mcl_lush_caves:dripleaf_big_waterroot", param2 = l * 16})
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if itemstack:get_name() ~= "mcl_dye:white" then return itemstack end
		itemstack:take_item(1)
		dripleaf_grow(pos,node)
	end
})
local dripleaf = {
	description = S("Dripleaf"),
	_doc_items_create_entry = S("Dripleaf"),
	_doc_items_entry_name = S("Dripleaf"),
	_doc_items_longdesc = S("Dripleaf"),
	paramtype = "light",
	place_param2 = 0,
	sunlight_propagates = true,
	walkable = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16, 8/16, -7/16, 8/16},
		},
	},
	tiles = {"mcl_lush_caves_big_dripleaf_top.png"},
	inventory_image = "mcl_lush_caves_big_dripleaf_top.png",
	wield_image = "mcl_lush_caves_big_dripleaf_top.png",
	use_texture_alpha = "clip",
	selection_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16, 8/16, -7/16, 8/16},
		},
	},
	groups = { shearsy = 1, handy = 1, plant=1, supported_node=0, dig_by_water=1,destroy_by_lava_flow=1, dig_by_piston=1 },
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
	_mcl_blast_hardness = 0,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if itemstack:get_name() ~= "mcl_dye:white" then return itemstack end
		itemstack:take_item(1)
		dripleaf_grow(vector.offset(pos,0,-1,0),{name = "mcl_lush_caves:dripleaf_big_stem" })
	end
}
local dripleaf_tipped = table.copy(dripleaf)
dripleaf_tipped.walkable = false
dripleaf_tipped.tiles = {"mcl_lush_caves_big_dripleaf_tip.png"}
dripleaf_tipped.on_timer = function(p,e)
	minetest.swap_node(p,{name="mcl_lush_caves:dripleaf_big"})
end

dripleaf.mesecons = {effector = {
	action_on = function(pos, node)
		node.param2 = 1
		minetest.swap_node(pos, node)
	end,
	action_off = function(pos, node)
		node.param2 = 0
		minetest.swap_node(pos, node)
	end,
	rules = mesecon.rules.alldirs,
}}


minetest.register_node("mcl_lush_caves:dripleaf_big",dripleaf)
minetest.register_node("mcl_lush_caves:dripleaf_big_tipped",dripleaf_tipped)

minetest.register_node("mcl_lush_caves:dripleaf_small_stem", {
	description = S("Small dripleaf stem"),
	_doc_items_create_entry = S("Small dripleaf stem"),
	_doc_items_entry_name = S("Small dripleaf stem"),
	_doc_items_longdesc = S("Small dripleaf stem"),
	paramtype = "light",
	place_param2 = 3,
	sunlight_propagates = true,
	walkable = false,
	drawtype = "plantlike",
	tiles = {"mcl_lush_caves_small_dripleaf_stem_top.png"},
	inventory_image = "mcl_lush_caves_small_dripleaf_stem_top.png",
	wield_image = "mcl_lush_caves_small_dripleaf_stem_top.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
		},
	},
	groups = { shearsy = 1, handy = 1, plant=1, supported_node=0, dig_by_water=1,destroy_by_lava_flow=1, dig_by_piston=1 },
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
	_mcl_blast_hardness = 0,
})

minetest.register_node("mcl_lush_caves:dripleaf_small", {
	description = S("Dripleaf"),
	_doc_items_create_entry = S("Dripleaf"),
	_doc_items_entry_name = S("Dripleaf"),
	_doc_items_longdesc = S("Dripleaf"),
	paramtype = "light",
	place_param2 = 3,
	sunlight_propagates = true,
	walkable = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16, 8/16, -7/16, 8/16},
		},
	},
	tiles = {"mcl_lush_caves_small_dripleaf_top.png"},
	inventory_image = "mcl_lush_caves_small_dripleaf_top.png",
	wield_image = "mcl_lush_caves_small_dripleaf_top.png",
	use_texture_alpha = "clip",
	selection_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16, 8/16, -7/16, 8/16},
		},
	},
	groups = { shearsy = 1, handy = 1, plant=1, supported_node=0, dig_by_water=1,destroy_by_lava_flow=1, dig_by_piston=1 },
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
	_mcl_blast_hardness = 0,
})

minetest.register_node("mcl_lush_caves:rooted_dirt", {
	description = S("Rooted dirt"),
	_doc_items_longdesc = S("Rooted dirt"),
	_doc_items_hidden = false,
	tiles = {"mcl_lush_caves_rooted_dirt.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=1, dirt=1, building_block=1, path_creation_possible=1},
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
})

minetest.register_craftitem("mcl_lush_caves:glow_berry", {
	description = S("Glow berry"),
	_doc_items_longdesc = S("This is a food item which can be eaten."),
	stack_max = 64,
	inventory_image = "mcl_lush_caves_glow_berries.png",
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
	groups = {food = 2, eatable = 2, compostability = 50},
	_mcl_saturation = 1.2,
})

minetest.register_node("mcl_lush_caves:azalea_leaves", {
	description = description,
	_doc_items_longdesc = longdesc,
	_doc_items_hidden = false,
	drawtype = "allfaces_optional",
	waving = 2,
	place_param2 = 1, -- Prevent leafdecay for placed nodes
	tiles = { "mcl_lush_caves_azalea_leaves.png" },
	paramtype = "light",
	groups = {
		hoey = 1, shearsy = 1, dig_by_piston = 1,
		leaves = 1, leafdecay = 5, deco_block = 1,
		flammable = 2, fire_encouragement = 30, fire_flammability = 60,
		compostability = 30
	},
	drop = {
			max_items = 1,
			items = {
				--{
				--	items = {sapling},
				--	rarity = 10
				--},
				{
					items = {"mcl_core:stick 1"},
					rarity = 3
				},
				{
					items = {"mcl_core:stick 2"},
					rarity = 6
				},
			}
		},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.2,
	_mcl_shears_drop = true,
	_mcl_silk_touch_drop = true,
})

minetest.register_node("mcl_lush_caves:azalea_leaves_flowering", {
	description = description,
	_doc_items_longdesc = longdesc,
	_doc_items_hidden = false,
	drawtype = "allfaces_optional",
	waving = 2,
	place_param2 = 1, -- Prevent leafdecay for placed nodes
	tiles = { "mcl_lush_caves_azalea_leaves_flowering.png" },
	paramtype = "light",
	groups = {
		hoey = 1, shearsy = 1, dig_by_piston = 1,
		leaves = 1, leafdecay = 5, deco_block = 1,
		flammable = 2, fire_encouragement = 30, fire_flammability = 60,
		compostability = 30
	},
	drop = {
			max_items = 1,
			items = {
				--{
				--	items = {sapling},
				--	rarity = 10
				--},
				{
					items = {"mcl_core:stick 1"},
					rarity = 3
				},
				{
					items = {"mcl_core:stick 2"},
					rarity = 6
				},
			}
		},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.2,
	_mcl_shears_drop = true,
	_mcl_silk_touch_drop = true,
})

--[[
minetest.register_node("mcl_lush_caves:spore_blossom", {
	description = S("Spore blossom"),
	_doc_items_longdesc = S("Spore blossom"),
	_doc_items_hidden = false,
	tiles = {"mcl_lush_caves_spore_blossom.png"},
	drawtype = "plantlike",
	param2type = "light",
	is_ground_content = true,
	stack_max = 64,
	groups = {handy = 1, plant = 1},
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
})


minetest.register_node("mcl_lush_caves:azalea", {
	description = S("Azalea"),
	inventory_image = "mcl_lush_caves_azalea_plant.png",
	drawtype = "allfaces_optional",
--	drawtype = "nodebox",
--	node_box = {
--		type = "fixed",
--		fixed = {
--			{ -16/16, -0/16, -16/16,  16/16, 16/16,  16/16 },
--			{ -2/16, -16/16, -2/16,  2/16,  0/16,  2/16 },
--		}
--	},
	--tiles = { "blank.png" },
	tiles = {
		"mcl_lush_caves_azalea_top.png",
		"mcl_lush_caves_azalea_top.png",
		"mcl_lush_caves_azalea_side.png",
		"mcl_lush_caves_azalea_side.png",
		"mcl_lush_caves_azalea_side.png",
		"mcl_lush_caves_azalea_side.png",
	},
	is_ground_content = false,
	groups = { handy=1 },
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 0,
	_mcl_hardness = 0,
	use_texture_alpha = "clip",
})

minetest.register_node("mcl_lush_caves:azalea_flowering", {
	description = S("Flowering azalea"),
	inventory_image = "mcl_lush_caves_azalea_flowering_top.png",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -16/16, -4/16, -16/16,  16/16, 16/16,  16/16 },
			{ -2/16, -16/16, -2/16,  2/16,  -4/16,  2/16 },
		}
	},
	--tiles = { "blank.png" },
	tiles = {
		"mcl_lush_caves_azalea_flowering_top.png",
		"mcl_lush_caves_azalea_flowering_top.png",
		"mcl_lush_caves_azalea_flowering_side.png",
		"mcl_lush_caves_azalea_flowering_side.png",
		"mcl_lush_caves_azalea_flowering_side.png",
		"mcl_lush_caves_azalea_flowering_side.png",
	},
	is_ground_content = false,
	groups = { handy=1 },
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 0,
	_mcl_hardness = 0,
	use_texture_alpha = "clip",
})
--]]

local lushcaves = { "LushCaves", "LushCaves_underground", "LushCaves_ocean", "LushCaves_deep_ocean"}
minetest.register_abm({
	label = "Cave vines grow",
	nodenames = {"mcl_lush_caves:cave_vines_lit","mcl_lush_caves:cave_vines"},
	interval = 180,
	chance = 5,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local pu = vector.offset(pos,0,1,0)
		local pun = minetest.get_node(pu).name
		local pd = vector.offset(pos,0,-1,0)
		local pd2 = minetest.get_node(vector.offset(pos,0,-2,0)).name
		if pun ~= "mcl_lush_caves:cave_vines_lit" and pun ~= "mcl_lush_caves:cave_vines"  and pun ~= "mcl_lush_caves:moss" then
			minetest.set_node(pos,{name="air"})
			return
		end
		node.name = "mcl_lush_caves:cave_vines"
		if  math.random(5) == 1 then
			node.name="mcl_lush_caves:cave_vines_lit"
		end
		if minetest.get_node(pd).name == "air" and pd2 == "air" then
			minetest.swap_node(pd,node)
		else
			minetest.swap_node(pos,{name="mcl_lush_caves:cave_vines_lit"})
		end
	end
})

local player_dripleaf = {}
minetest.register_globalstep(function(dtime)
	for _,p in pairs(minetest.get_connected_players()) do
		local pos = p:get_pos()
		local n = minetest.get_node(pos)
		if n.name == "mcl_lush_caves:dripleaf_big" and n.param2 == 0 then
			if not player_dripleaf[p] then player_dripleaf[p] = 0 end
			player_dripleaf[p] = player_dripleaf[p] + dtime
			if player_dripleaf[p] > 1 then
				minetest.swap_node(pos,{name = "mcl_lush_caves:dripleaf_big_tipped"})
				player_dripleaf[p] = nil
				local t = minetest.get_node_timer(pos)
				t:start(3)
			end
		end
	end
end)

mcl_structures.register_structure("clay_pool",{
	place_on = {"group:material_stone","mcl_core:gravel","mcl_lush_caves:moss","mcl_core:clay"},
	spawn_by = {"air"},
	num_spawn_by = 1,
	noise_params = {
		offset = 0,
		scale = 0.01,
		spread = {x = 250, y = 250, z = 250},
		seed = 78375213,
		octaves = 5,
		persist = 0.1,
		flags = "absvalue",
	},
	flags = "all_floors",
	y_max = -10,
	biomes = lushcaves,
	place_func = mcl_lush_caves.makelake,
})

local azaleas = {}
local az_limit = 500
mcl_structures.register_structure("azalea_tree",{
	place_on = {"group:material_stone","mcl_core:gravel","mcl_lush_caves:moss","mcl_core:clay"},
	spawn_by = {"air"},
	num_spawn_by = 1,
	fill_ratio = 0.15,
	flags = "all_ceilings",
	terrain_feature = true,
	y_max =0,
	y_min = mcl_vars.mg_overworld_min + 15,
	biomes = lushcaves,
	place_func = function(pos,def,pr)
		for _,a in pairs(azaleas) do
			if vector.distance(pos,a) < az_limit then
				return true
			end
		end
		if mcl_lush_caves.makeazalea(pos,def,pr) then
			table.insert(azaleas,pos)
			return true
		end
	end
})
--[[
minetest.set_gen_notify({cave_begin = true})
minetest.set_gen_notify({large_cave_begin = true})

mcl_mapgen_core.register_generator("lush_caves",nil, function(minp, maxp, blockseed)
	local gennotify = minetest.get_mapgen_object("gennotify")
	for _, pos in pairs(gennotify["large_cave_begin"] or {}) do
		--minetest.log("large cave at "..minetest.pos_to_string(pos))
	end
	for _, pos in pairs(gennotify["cave_begin"] or {}) do
		minetest.log("cave at "..minetest.pos_to_string(pos))
	end
end, 99999, true)
--]]
