local S = core.get_translator("mcl_mangrove")
local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

vl_trees.register_wood("mangrove", {
	schematic = function()
		local t = math.random(1, 5)
		return {
			spec = modpath .. "/schematics/mcl_mangrove_tree_"..t..".mts",
			size = {w = 5, h = (t > 3 and 18 or 10)},
		}
	end,
	trunk = {
		description = S("Mangrove Log"),
		_doc_items_longdesc = S("The trunk of a mangrove tree."),
		tiles = {"mcl_mangrove_log_top.png", "mcl_mangrove_log_top.png", "mcl_mangrove_log.png"},
	},
	stripped_trunk = {
		description = S("Stripped Mangrove Log"),
		_doc_items_longdesc = S("The stripped trunk of a mangrove tree."),
		tiles = {"mcl_stripped_mangrove_log_top.png", "mcl_stripped_mangrove_log_top.png", "mcl_stripped_mangrove_log_side.png"},
	},
	bark = {
		description = S("Mangrove Bark"),
		_doc_items_longdesc = S("The wood of a mangrove tree."),
		tiles = {"mcl_mangrove_log.png"},
	},
	_bark_stairs = S("Mangrove Bark Stairs"),
	_bark_slab = S("Mangrove Bark Slab"),
	_bark_double_slab = S("Double Mangrove Bark Slab"),
	stripped_bark = {
		description = S("Stripped Mangrove Bark"),
		_doc_items_longdesc = S("The stripped wood of a mangrove tree."),
		tiles = {"mcl_stripped_mangrove_log_side.png"},
	},
	planks = {
		description = S("Mangrove Wood Planks"),
		tiles = {"mcl_mangrove_planks.png"},
	},
	_planks_stairs = S("Mangrove Wood Stairs"),
	_planks_slab = S("Mangrove Wood Slab"),
	_planks_double_slab = S("Double Mangrove Wood Slab"),
	leaves = {
		description = S("Mangrove Leaves"),
		_doc_items_longdesc = S("Mangrove leaves are grown from mangrove trees."),
		tiles = {"mcl_mangrove_leaves.png"},
		color = "#48B518",
		_on_bone_meal = function(_, _, pointed_thing)
			local pos = pointed_thing.under
			local below = vector.offset(pos, 0, -1, 0)
			return core.get_node(below).name == "air"
				and core.set_node(below, {name = "mcl_mangrove:propagule"})
		end,
	},
	sapling = "mcl_mangrove:propagule",
	_door = {
		description = S("Mangrove Door"),
		inventory_image = "mcl_mangrove_doors.png",
		tiles_bottom = "mcl_mangrove_door_bottom.png",
		tiles_top = "mcl_mangrove_door_top.png",
	},
	_trapdoor = {
		description = S("Mangrove Trapdoor"),
		wield_image = "mcl_mangrove_trapdoor.png",
		tile_front = "mcl_mangrove_trapdoor.png",
		tile_side = "mcl_mangrove_trapdoor_side.png",
	},
})

local function alias(old, new)
	core.register_alias("mcl_mangrove:"..old, "mcl_mangrove:"..new)
end

alias("mangrove_tree", "tree_mangrove")
alias("mangroveleaves", "leaves_mangrove")
alias("mangrove_wood", "wood_mangrove")

local propagule_allowed_nodes = {
	"mcl_core:dirt",
	"mcl_core:coarse_dirt",
	"mcl_core:dirt_with_grass",
	"mcl_core:podzol",
	"mcl_core:mycelium",
	"mcl_lush_caves:rooted_dirt",
	"mcl_lush_caves:moss",
	"mcl_farming:soil",
	"mcl_farming:soil_wet",
	"mcl_core:clay",
	"mcl_mud:mud",
}
local propagule_water_nodes = {"mcl_mud:mud","mcl_core:dirt","mcl_core:coarse_dirt","mcl_core:clay"}
 --"mcl_lush_caves:moss","mcl_lush_caves:rooted_dirt

core.register_alias("mcl_mangrove:mangrove_stripped_trunk", "mcl_mangrove:mangrove_stripped")

core.register_node("mcl_mangrove:mangrove_roots", {
	description = S("Mangrove Roots"),
	_doc_items_longdesc = S("Mangrove roots are decorative blocks that form as part of mangrove trees."),
	_doc_items_hidden = false,
	waving = 0,
	place_param2 = 1, -- Prevent leafdecay for placed nodes
	tiles = {
		"mcl_mangrove_roots_top.png",
		"mcl_mangrove_roots_side.png",
		"mcl_mangrove_roots_side.png",
	},
	paramtype = "light",
	drawtype = "allfaces_optional",
	groups = {
		handy = 1, hoey = 1, shearsy = 1, axey = 1, swordy = 1, dig_by_piston = 0,
		flammable = 10, fire_encouragement = 30, fire_flammability = 60,
		deco_block = 1, compostability = 30
	},
	drop = "mcl_mangrove:mangrove_roots",
	_mcl_shears_drop = true,
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0.7,
	_mcl_hardness = 0.7,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = { "mcl_mangrove:mangrove_roots 1", "mcl_mangrove:mangrove_roots 2", "mcl_mangrove:mangrove_roots 3", "mcl_mangrove:mangrove_roots 4" },
})

core.register_node("mcl_mangrove:propagule", {
	description = S("Mangrove Propagule"),
	_tt_help = S("Needs soil and light to grow"),
	_doc_items_longdesc = S("When placed on soil (such as dirt) and exposed to light, an propagule will grow into an mangrove after some time."),
	_doc_items_hidden = false,
	drawtype = "plantlike",
	waving = 1,
	visual_scale = 1.0,
	tiles = {"mcl_mangrove_propagule_item.png"},
	inventory_image = "mcl_mangrove_propagule_item.png",
	wield_image = "mcl_mangrove_propagule_item.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-5/16, -0.5, -5/16, 5/16, 0.5, 5/16}
	},
	groups = {
		plant = 1, propagule = 1, non_mycelium_plant = 1, attached_node = 1,
		deco_block = 1, dig_immediate = 3, dig_by_water = 0, dig_by_piston = 1,
		destroy_by_lava_flow = 1, compostability = 30
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	on_construct = function(pos)
		local meta = core.get_meta(pos)
		meta:set_int("stage", 0)
	end,
	node_placement_prediction = "",
	_mcl_blast_resistance = 0,
	_mcl_hardness = 0,
	on_place = mcl_util.generate_on_place_plant_function(function(place_pos, place_node,stack)
		local under = vector.offset(place_pos,0,-1,0)
		local snn = core.get_node_or_nil(under).name
		if not snn then return false end
		if table.indexof(propagule_allowed_nodes,snn) ~= -1 then
			local n = core.get_node(place_pos)
			if core.get_item_group(n.name,"water") > 0 and table.indexof(propagule_water_nodes,snn) ~= -1 then
				core.set_node(under,{name="mcl_mangrove:propagule_"..snn:split(":")[2]})
				stack:take_item()
				return stack
			end
			return true
		end
	end),
	_on_bone_meal = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.under
		local node = core.get_node(pos)
		-- Saplings: 45% chance to advance growth stage
		if math.random(1, 100) <= 45 then
			return vl_trees.grow_tree(pos, node, vl_trees.registered_woods["mangrove"])
		end
	end,
})

core.register_node("mcl_mangrove:hanging_propagule_1", {
	description = S("Hanging Propagule"),
	_tt_help = S("Grows on Mangrove leaves"),
	_doc_items_longdesc = "",
	_doc_items_usagehelp = "",
	groups = {
		plant = 1, not_in_creative_inventory=1, non_mycelium_plant = 1,
		deco_block = 1, dig_immediate = 3, dig_by_water = 0, dig_by_piston = 1,
		destroy_by_lava_flow = 1, compostability = 30
	},
	paramtype = "light",
	paramtype2 = "",
	on_rotate = false,
	walkable = false,
	drop = "mcl_mangrove:propagule",
	use_texture_alpha = "clip",
	drawtype = 'mesh',
	mesh = 'propagule_hanging.obj',
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}, -- Base
		},
	},
	tiles = {"mcl_mangrove_propagule_hanging.png"},
	inventory_image = "mcl_mangrove_propagule.png",
	wield_image = "mcl_mangrove_propagule.png",
})
local propagule_rooted_nodes = {}
for _,root in pairs(propagule_water_nodes) do
	local r = root:split(":")[2]
	local def = core.registered_nodes[root]
	local tx = def.tiles
	local n = "mcl_mangrove:propagule_"..r
	table.insert(propagule_rooted_nodes,n)
	core.register_node(n, {
		drawtype = "plantlike_rooted",
		paramtype = "light",
		place_param2 = 1,
		tiles = tx,
		special_tiles = { { name = "mcl_mangrove_propagule_item.png" } },
		inventory_image = "mcl_mangrove_propagule_item.png",
		wield_image = "mcl_mangrove_propagule.png",
		selection_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
				{ -0.5, 0.5, -0.5, 0.5, 1.0, 0.5 },
			}
		},
		groups = {
			plant = 1, propagule = 1, non_mycelium_plant = 1, attached_node = 1,not_in_creative_inventory=1,
			deco_block = 1, dig_immediate = 3, dig_by_piston = 1,
			destroy_by_lava_flow = 1, compostability = 30
		},
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		drop = "mcl_mangrove:propagule",
		node_placement_prediction = "",
		node_dig_prediction = "",
		after_dig_node = function(pos)
			core.set_node(pos, {name=root})
		end,
		_mcl_hardness = 0,
		_mcl_blast_resistance = 0,
		_mcl_silk_touch_drop = true,
	})

end

mcl_flowerpots.register_potted_flower("mcl_mangrove:propagule", {
	name = "propagule",
	desc = S("Mangrove Propagule"),
	image = "mcl_mangrove_propagule.png",
})

local water_tex = "mcl_core_water_source_animation.png^[verticalframe:16:0^[multiply:#3F76E4"

local wlroots = {
	description = S("water logged mangrove roots"),
	_doc_items_entry_name = S("water logged mangrove roots"),
	_doc_items_longdesc =
		S("Mangrove roots are decorative blocks that form as part of mangrove trees.").."\n\n"..
		S("Mangrove roots, despite being a full block, can be waterlogged and do not flow water out").."\n\n"..
		S("These cannot be crafted yet only occure when get in contact of water."),
	_doc_items_hidden = false,
	tiles = {
		{name="mcl_core_water_source_animation.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=5.0}}
	},
	special_tiles = {
		-- New-style water source material (mostly unused)
		{
			name="mcl_core_water_source_animation.png",
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=5.0},
			backface_culling = false,
		}
	},
	overlay_tiles = {
		"mcl_mangrove_roots_top.png",
		"mcl_mangrove_roots_side.png",
		"mcl_mangrove_roots_side.png",
	},
	sounds = mcl_sounds.node_sound_water_defaults(),
	drawtype = "allfaces_optional",
	use_texture_alpha = "blend",
	is_ground_content = false,
	paramtype = "light",
	walkable = true,
	pointable = true,
	diggable = true,
	buildable_to = false,
	liquids_pointable = true,
	drop = "mcl_mangrove:mangrove_roots",
	groups = {
		handy = 1, hoey = 1, water=4, liquid=3, puts_out_fire=1, dig_by_piston = 1, deco_block = 1,  not_in_creative_inventory=1 },
	_mcl_blast_resistance = 100,
	_mcl_hardness = -1, -- Hardness intentionally set to infinite instead of 100 (Minecraft value) to avoid problems in creative mode
	on_construct = function(pos)
		local dim = mcl_worlds.pos_to_dimension(pos)
		if dim == "nether" then
			core.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
			core.set_node(pos, {name="mcl_mangrove:mangrove_roots"})
		end
	end,
	after_dig_node = function(pos)
		local node = core.get_node(pos)
		local dim = mcl_worlds.pos_to_dimension(pos)
		if core.get_item_group(node.name, "water") == 0 and dim ~= "nether" then
			core.set_node(pos, {name="mcl_core:water_source"})
		else
			core.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
		end
	end,
}
local rwlroots = table.copy(wlroots)
-- FIXME luacheck complains that this is a repeated definition of water_tex.
-- Maybe the tiles definition below should be replaced with the animated tile
-- definition as per above?
water_tex = "mcl_core_water_source_animation.png^[verticalframe:16:0^[multiply:#0084FF"
rwlroots.tiles = {
	"("..water_tex..")^mcl_mangrove_roots_top.png",
	"("..water_tex..")^mcl_mangrove_roots_side.png",
	"("..water_tex..")^mcl_mangrove_roots_side.png",
}
rwlroots.after_dig_node = function(pos)
	local node = core.get_node(pos)
	local dim = mcl_worlds.pos_to_dimension(pos)
	if core.get_item_group(node.name, "water") == 0 and dim ~= "nether" then
		core.set_node(pos, {name="mclx_core:river_water_source"})
	else
		core.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
	end
end

core.register_node("mcl_mangrove:water_logged_roots", wlroots)
core.register_node("mcl_mangrove:river_water_logged_roots",rwlroots)

core.register_node("mcl_mangrove:mangrove_mud_roots", {
	description = S("Muddy Mangrove Roots"),
	_tt_help = S("Crafted with Mud and Mangrove roots"),
	_doc_items_longdesc = S("Muddy Mangrove Roots is a block from mangrove swamp.It drowns player a bit inside it."),
	tiles = {
		"mcl_mud.png^mcl_mangrove_roots_top.png",
		"mcl_mud.png^mcl_mangrove_roots_side.png",
		"mcl_mud.png^mcl_mangrove_roots_side.png",
	},
	is_ground_content = true,
	groups = {handy = 1, shovely = 1, axey = 1, building_block = 1},
	sounds = mcl_sounds.node_sound_sand_defaults(),
	_mcl_blast_resistance = 0.7,
	_mcl_hardness = 0.7,
})

core.register_craft({
	output = "mcl_mangrove:mangrove_mud_roots",
	recipe = {
		{"mcl_mangrove:mangrove_roots", "mcl_mud:mud",},
	}
})

core.register_craft({
	type = "fuel",
	recipe = "mcl_mangrove:mangrove_roots",
	burntime = 15,
})

local adjacents = {
	vector.new(1,0,0),
	vector.new(-1,0,0),
	vector.new(0,0,1),
	vector.new(0,0,-1),
}

core.register_abm({
	label = "Waterlog mangrove roots",
	nodenames = {"mcl_mangrove:mangrove_roots"},
	neighbors = {"group:water"},
	interval = 5,
	chance = 5,
	action = function(pos,value)
		for _,v in pairs(adjacents) do
			local n = core.get_node(vector.add(pos,v)).name
			if core.get_item_group(n,"water") > 0 then
				if n:find("river") then
					core.swap_node(pos,{name="mcl_mangrove:river_water_logged_roots"})
					return
				else
					core.swap_node(pos,{name="mcl_mangrove:water_logged_roots"})
					return
				end
			end
		end
	end
})

local abm_nodes = table.copy(propagule_rooted_nodes)
table.insert(abm_nodes, "mcl_mangrove:propagule")
core.register_abm({
	label = "Mangrove_tree_growth",
	nodenames = abm_nodes,
	interval = 1,
	chance = 1,
	action = function(pos,node)
		local pr = PseudoRandom(pos.x+pos.y+pos.z)
		local r = pr:next(1,5)
		local path = modpath .."/schematics/mcl_mangrove_tree_"..tostring(r)..".mts"
		local w = 5
		local h = 10
		pos.y = pos.y - 1
	--[[	if table.indexof(propagule_rooted_nodes,node.name) ~= -1 then
			local nn = core.find_nodes_in_area(vector.offset(pos,0,-1,0),vector.offset(pos,0,h,0),{"group:water","air"})
			if #nn >= h then
				vl_trees.place_schem(pos, path, function()
					mcl_core.update_sapling_foliage_colors(pos)
					local nnv = core.find_nodes_in_area(vector.offset(pos, -5, -1,-5),vector.offset(pos,5,h/2,5),{"mcl_core:vine"})
					core.bulk_set_node(nnv,{"air"})
				end)
			end
			return
		end]]
		if r > 3 then h = 18 end
		if vl_trees.check_tree_growth(pos, w, h) then
			vl_trees.grow_tree(pos, core.get_node(pos), vl_trees.registered_woods["mangrove"])
			--mcl_core.update_sapling_foliage_colors(pos)
		end
	end,
})
