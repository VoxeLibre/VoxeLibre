local S = minetest.get_translator(minetest.get_current_modname())

-- Logs
minetest.register_node("mcl_cherry_blossom:cherrytree", {
	description = S("Cherry Log"),
	_doc_items_longdesc = S("The trunk of an cherry blossom tree."),
	_doc_items_hidden = false,
	tiles = {"mcl_cherry_blossom_log_top.png", "mcl_cherry_blossom_log_top.png", "mcl_cherry_blossom_log.png"},
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	after_destruct = mcl_core.update_leaves,
	stack_max = 64,
	groups = {handy=1,axey=1, tree=1, flammable=2, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=5},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_rotate = on_rotate,
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
	_mcl_stripped_variant = "mcl_cherry_blossom:stripped_cherrytree",
})

minetest.register_node("mcl_cherry_blossom:stripped_cherrytree", {
	description = S("Stripped Cherry Log"),
	_doc_items_longdesc = S("The stripped trunk of an cherry blossom tree."),
	_doc_items_hidden = false,
	tiles = {"mcl_cherry_blossom_log_top_stripped.png", "mcl_cherry_blossom_log_top_stripped.png", "mcl_cherry_blossom_log_stripped.png"},
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	stack_max = 64,
	groups = {handy=1, axey=1, tree=1, flammable=2, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=5},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_rotate = on_rotate,
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})

-- Bark
minetest.register_node("mcl_cherry_blossom:cherrytree_bark", {
	description = S("Cherry Bark"),
	_doc_items_longdesc = S("This is a decorative block surrounded by the bark of a tree trunk."),
	tiles = {"mcl_cherry_blossom_log.png"},
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	stack_max = 64,
	groups = {handy=1,axey=1, bark=1, flammable=2, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=5},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	is_ground_content = false,
	on_rotate = on_rotate,
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
	_mcl_stripped_variant = "mcl_cherry_blossom:stripped_cherrytree_bark",
})

minetest.register_node("mcl_cherry_blossom:stripped_cherrytree_bark", {
	description = S("Stripped Cherry Wood"),
	_doc_items_longdesc = S("The stripped wood of an cherry blossom tree."),
	tiles = {"mcl_cherry_blossom_log_stripped.png"},
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	stack_max = 64,
	groups = {handy=1, axey=1, bark=1, flammable=2, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=5},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	is_ground_content = false,
	on_rotate = on_rotate,
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})

--Planks
minetest.register_node("mcl_cherry_blossom:cherrywood", {
	description = S("Cherry Wood Planks"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	_doc_items_hidden = false,
	tiles = {"mcl_cherry_blossom_planks.png"},
	stack_max = 64,
	is_ground_content = false,
	groups = {handy=1,axey=1, flammable=3,wood=1,building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=20},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 2,
})

-- Leaves
local stick_chances = {50, 45, 30, 35, 10}
local sapling_chances = {20, 16, 12, 10}

local function get_drops(fortune_level)
	local drop = {
		max_items = 1,
		items = {
			{
				items = {"mcl_cherry_blossom:cherrysapling"},
				rarity = sapling_chances[fortune_level + 1] or sapling_chances[fortune_level]
			},
			{
				items = {"mcl_core:stick 1"},
				rarity = stick_chances[fortune_level + 1]
			},
			{
				items = {"mcl_core:stick 2"},
				rarity = stick_chances[fortune_level + 1]
			},
		}
	}
	return drop
end

local l_def = {
	description = S("Cherry Leaves"),
	_doc_items_longdesc = S("Cherry blossom leaves are grown from cherry blossom trees."),
	_doc_items_hidden = false,
	drawtype = "allfaces_optional",
	waving = 2,
	tiles = {"mcl_cherry_blossom_leaves.png"},
	color = color,
	paramtype = "light",
	stack_max = 64,
	groups = {
		handy = 1, hoey = 1, shearsy = 1, swordy = 1, dig_by_piston = 1,
		flammable = 2, fire_encouragement = 30, fire_flammability = 60,
		leaves = 1, deco_block = 1, compostability = 30
	},
	drop = get_drops(0),
	_mcl_shears_drop = true,
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.2,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = { get_drops(1), get_drops(2), get_drops(3), get_drops(4) },
	after_place_node = function(pos)
		mcl_core.make_player_leaves(pos) -- Leaves placed by the player should always be player leaves.
	end,
	}

minetest.register_node("mcl_cherry_blossom:cherryleaves", l_def)

local o_def = table.copy(l_def)
o_def._doc_items_create_entry = false
o_def.groups.not_in_creative_inventory = 1
o_def.groups.orphan_leaves = 1
o_def._mcl_shears_drop = {"mcl_cherry_blossom:cherryleaves"}
o_def._mcl_silk_touch_drop = {"mcl_cherry_blossom:cherryleaves"}

minetest.register_node("mcl_cherry_blossom:cherryleaves" .. "_orphan", o_def)

-- Sapling
minetest.register_node("mcl_cherry_blossom:cherrysapling", {
	description = S("Cherry Sapling"),
	_tt_help = tt_help,
	_doc_items_longdesc = S("Cherry blossom sapling can be planted to grow cherry trees"),
	_doc_items_hidden = false,
	drawtype = "plantlike",
	waving = 1,
	visual_scale = 1.0,
	tiles = {"mcl_cherry_blossom_sapling.png"},
	inventory_image = "mcl_cherry_blossom_sapling.png",
	wield_image = "mcl_cherry_blossom_sapling.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-4/16, -0.5, -4/16, 4/16, 0.25, 4/16}
	},
	stack_max = 64,
	groups = {
		plant = 1, sapling = 1, attached_node = 1,
		deco_block = 1, dig_immediate = 3, dig_by_water = 1, dig_by_piston = 1,
		destroy_by_lava_flow = 1, compostability = 30
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	on_construct = function(pos)
		--local meta = minetest.get_meta(pos)
		--meta:set_int("stage", 0)
		-- TODO Uncomment above when wood api is implemented with the current mcl_core tree growth code.
	end,
	on_place = mcl_util.generate_on_place_plant_function(function(pos, node)
		local node_below = minetest.get_node_or_nil({x=pos.x,y=pos.y-1,z=pos.z})
		if not node_below then return false end
		local nn = node_below.name
		return minetest.get_item_group(nn, "grass_block") == 1 or
				nn == "mcl_core:podzol" or nn == "mcl_core:podzol_snow" or
				nn == "mcl_core:dirt" or nn == "mcl_core:mycelium" or nn == "mcl_core:coarse_dirt"
	end),
	node_placement_prediction = "",
	_mcl_blast_resistance = 0,
	_mcl_hardness = 0,
})

-- Door and Trapdoor
mcl_doors:register_door("mcl_cherry_blossom:cherrydoor", {
	description = S("Cherry Door"),
	_doc_items_longdesc = S("Wooden doors are 2-block high barriers which can be opened or closed by hand and by a redstone signal."),
	_doc_items_usagehelp = S("To open or close a wooden door, rightclick it or supply its lower half with a redstone signal."),
	inventory_image = "mcl_cherry_blossom_door_inv.png",
	groups = {handy=1,axey=1, material_wood=1, flammable=-1},
	_mcl_hardness = 3,
	_mcl_blast_resistance = 3,
	tiles_bottom = {"mcl_cherry_blossom_door_bottom.png", "mcl_cherry_blossom_door_side_bottom.png"},
	tiles_top = {"mcl_cherry_blossom_door_top.png", "mcl_cherry_blossom_door_side_top.png"},
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

mcl_doors:register_trapdoor("mcl_cherry_blossom:cherrytrapdoor", {
	description = S("Cherry Trapdoor"),
	_doc_items_longdesc = S("Wooden trapdoors are horizontal barriers which can be opened and closed by hand or a redstone signal. They occupy the upper or lower part of a block, depending on how they have been placed. When open, they can be climbed like a ladder."),
	_doc_items_usagehelp = S("To open or close the trapdoor, rightclick it or send a redstone signal to it."),
	tile_front = "mcl_cherry_blossom_trapdoor.png",
	tile_side = "mcl_cherry_blossom_trapdoor_side.png",
	wield_image = "mcl_cherry_blossom_trapdoor.png",
	groups = {handy=1,axey=1, mesecon_effector_on=1, material_wood=1, flammable=-1},
	_mcl_hardness = 3,
	_mcl_blast_resistance = 3,
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

-- Stairs and Slabs
mcl_stairs.register_stair("cherrywood", "mcl_cherry_blossom:cherrywood",
		{handy=1,axey=1, flammable=3,wood_stairs=1, material_wood=1, fire_encouragement=5, fire_flammability=20},
		{"mcl_cherry_blossom_planks.png"},
		S("Cherry Stairs"),
		mcl_sounds.node_sound_wood_defaults(), 3, 2,
		"woodlike")
mcl_stairs.register_slab("cherrywood", "mcl_cherry_blossom:cherrywood",
		{handy=1,axey=1, flammable=3,wood_slab=1, material_wood=1, fire_encouragement=5, fire_flammability=20},
		{"mcl_cherry_blossom_planks.png"},
		S("Cherry Slab"),
		mcl_sounds.node_sound_wood_defaults(), 3, 2,
		S("Double Cherry Slab"))

-- Signs
mcl_signs.register_sign_custom("mcl_cherry_blossom", "cherrywood",
		"mcl_cherry_blossom_sign.png", "#000000",
		"mcl_cherry_blossom_sign_inv.png", "mcl_cherry_blossom_sign_inv.png", "Cherry Sign")

-- Fences & Gates
mcl_fences.register_fence_and_fence_gate("cherry_fence", S("Cherry Fence"), S("Cherry Gate"),
		"mcl_cherry_blossom_planks.png", {handy=1, axey=1, flammable=2, fence_wood=1, fire_encouragement=5, fire_flammability=20}, 2, 15,
		{"group:fence_wood"}, mcl_sounds.node_sound_wood_defaults())

-- Redstone
mesecon.register_pressure_plate(
	"mcl_cherry_blossom:pressure_plate_cherrywood",
	S("Cherry Pressure Plate"),
	{"mcl_cherry_blossom_planks.png"},
	{"mcl_cherry_blossom_planks.png"},
	"mcl_cherry_blossom_planks.png",
	nil,
	{{"mcl_cherry_blossom:cherrywood", "mcl_cherry_blossom:cherrywood"}},
	mcl_sounds.node_sound_wood_defaults(),
	{axey=1, material_wood=1},
	nil,
	S("A wooden pressure plate is a redstone component which supplies its surrounding blocks with redstone power while any movable object (including dropped items, players and mobs) rests on top of it."))

mesecon.register_button(
	"cherrywood",
	S("Cherry Button"),
	"mcl_cherry_blossom_planks.png",
	"mcl_cherry_blossom:cherrywood",
	mcl_sounds.node_sound_wood_defaults(),
	{material_wood=1,handy=1,axey=1},
	1.5,
	true,
	S("A wooden button is a redstone component made out of wood which can be pushed to provide redstone power. When pushed, it powers adjacent redstone components for 1.5 seconds. Wooden buttons may also be pushed by arrows."),
	"mesecons_button_push_wood")
