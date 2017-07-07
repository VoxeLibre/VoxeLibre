minetest.register_node("mcl_core:bone_block", {
	description = "Bone Block",
	_doc_items_longdesc = "Bone blocks are decorational blocks and a compact storage of bone meal.",
	tiles = {"mcl_core_bone_block_top.png", "mcl_core_bone_block_top.png", "mcl_core_bone_block_side.png"},
	is_ground_content = false,
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	groups = {pickaxey=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 10,
	_mcl_hardness = 2,
})

minetest.register_node("mcl_core:slimeblock", {
	description = "Slime Block",
	_doc_items_longdesc = "Slime blocks are very bouncy and prevent fall damage.",
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.25, -0.25, -0.25, 0.25, 0.25, 0.25}, 
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		}
	},
	tiles = {"mcl_core_slime.png"},
	paramtype = "light",
	use_texture_alpha = true,
	sunlight_propagates = true,
	stack_max = 64,
	-- According to Minecraft Wiki, bouncing off a slime block from a height off 255 blocks should result in a bounce height of 50 blocks
	-- bouncy=44 makes the player bounce up to 49.6. This value was chosen by experiment.
	-- bouncy=80 was chosen because it is higher than 66 (bounciness of bed)
	groups = {dig_immediate=3, bouncy=80,fall_damage_add_percent=-100,deco_block=1},
	sounds = {
		dug = {name="slimenodes_dug", gain=0.6},
		place = {name="slimenodes_place", gain=0.6},
		footstep = {name="slimenodes_step", gain=0.3},
	},
	_mcl_blast_resistance = 0,
	_mcl_hardness = 0,
})

minetest.register_node("mcl_core:cobweb", {
	description = "Cobweb",
	_doc_items_longdesc = "Cobwebs can be walked through, but significantly slow you down.",
	drawtype = "plantlike",
	paramtype2 = "degrotate",
	visual_scale = 1.1,
	stack_max = 64,
	tiles = {"mcl_core_web.png"},
	inventory_image = "mcl_core_web.png",
	paramtype = "light",
	sunlight_propagates = true,
	liquid_viscosity = 14,
	liquidtype = "source",
	liquid_alternative_flowing = "mcl_core:cobweb",
	liquid_alternative_source = "mcl_core:cobweb",
	liquid_renewable = false,
	liquid_range = 0,
	walkable = false,
	groups = {swordy_cobweb=1,shearsy=1, deco_block=1, dig_by_piston=1, dig_by_water=1,destroy_by_lava_flow=1,},
	drop = "mcl_mobitems:string",
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 20,
	_mcl_hardness = 4,
})

minetest.register_node("mcl_core:barrier", {
	description = "Barrier",
	_doc_items_longdesc = "Barriers are invisble walkable blocks. They are used to create boundaries of adventure maps and the like. Monsters and animals won't appear on barriers, and fences do not connect to barriers. Other blocks can be built on barriers like on any other block.",
	_doc_items_usagehelp = "When you hold a barrier in hand, you reveal all placed barriers in a short distance around you.",
	drawtype = "airlike",
	paramtype = "light",
	inventory_image = "mcl_core_barrier.png",
	wield_image = "mcl_core_barrier.png",
	tiles = { "blank.png" },
	stack_max = 64,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {creative_breakable=1, not_in_creative_inventory = 1, not_solid = 1 },
	on_blast = function() end,
	drop = "",
	_mcl_blast_resistance = 18000003,
	_mcl_hardness = -1,
	after_place_node = function (pos, placer, itemstack, pointed_thing)
		if placer == nil then
			return
		end
		minetest.add_particle({
			pos = pos,
			expirationtime = 1,
			size = 8,
			texture = "mcl_core_barrier.png",
			playername = placer:get_player_name()
		})
	end,
})
