local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

local plane_adjacents = {
	vector.new(1,0,0),
	vector.new(-1,0,0),
	vector.new(0,0,1),
	vector.new(0,0,-1)
}

local function get_height(pos,node)
	local p = pos
	local i = 0
	repeat
		i = i + 1
		p = vector.offset(p,0,-1,0)
	until minetest.get_node(p).name  ~= node.name
	return i - 1
end

function mcl_lush_caves.dripleaf_grow(pos, node)
	local t =  mcl_util.traverse_tower(pos,1) -- find_top(pos,node)
	local h = get_height(t,node)
	local target = vector.offset(t,0,1,0)
	if minetest.get_node(target).name ~= "air" then return end
	if h >= 5 then return end
	minetest.set_node(t,node)
	minetest.set_node(target,{name = "mcl_lush_caves:dripleaf_big"})
	return true
end

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
			fixed = {{ -3/16, -8/16, -3/16, 3/16, 8/16, 3/16 }},
		},
		groups = { handy = 1, dig_immediate = 3, not_in_creative_inventory = 1 },
		drop = "",
		node_placement_prediction = "",
		_mcl_hardness = 0,
		_mcl_blast_resistance = 0,
		_mcl_silk_touch_drop = true,
		_on_bone_meal = function(itemstack,placer, pointed_thing, pos, node)
			if not pos then return end
			return mcl_lush_caves.dripleaf_grow(pos,node)
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
		fixed = {{ -3/16, -8/16, -3/16, 3/16, 8/16, 3/16 }},
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
	_on_bone_meal = function(itemstack, clicker, pointed_thing, pos, node)
		return mcl_lush_caves.dripleaf_grow(pos,node)
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
		mcl_lush_caves.dripleaf_grow(vector.offset(pos,0,-1,0),{name = "mcl_lush_caves:dripleaf_big_stem" })
	end
}
local dripleaf_tipped = table.merge(dripleaf, {
	walkable = false,
	tiles = {"mcl_lush_caves_big_dripleaf_tip.png"},
	on_timer = function(p,e)
		minetest.swap_node(p,{name="mcl_lush_caves:dripleaf_big"})
	end,
})

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
