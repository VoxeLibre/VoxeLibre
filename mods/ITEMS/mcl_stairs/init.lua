-- Minetest 0.4 mod: mcl_stairs
-- See README.txt for licensing and other information.


-- Global namespace for functions

mcl_stairs = {}

local function place_slab_normal(itemstack, placer, pointed_thing)
	local p0 = pointed_thing.under
	local p1 = pointed_thing.above

	local placer_pos = placer:getpos()

	local finepos = minetest.pointed_thing_to_face_pos(placer, pointed_thing)
	local fpos = finepos.y % 1

	local place = ItemStack(itemstack)
	local origname = itemstack:get_name()
	if p0.y - 1 == p1.y or (fpos > 0 and fpos < 0.5)
			or (fpos < -0.5 and fpos > -0.999999999) then
		place:set_name(origname .. "_top")
	end
	local ret = minetest.item_place(place, placer, pointed_thing, 0)
	ret:set_name(origname)
	return ret
end

local function place_stair(itemstack, placer, pointed_thing)
	local p0 = pointed_thing.under
	local p1 = pointed_thing.above
	local param2 = 0

	local placer_pos = placer:getpos()
	if placer_pos then
		param2 = minetest.dir_to_facedir(vector.subtract(p1, placer_pos))
	end

	local finepos = minetest.pointed_thing_to_face_pos(placer, pointed_thing)
	local fpos = finepos.y % 1

	if p0.y - 1 == p1.y or (fpos > 0 and fpos < 0.5)
			or (fpos < -0.5 and fpos > -0.999999999) then
		param2 = param2 + 20
		if param2 == 21 then
			param2 = 23
		elseif param2 == 23 then
			param2 = 21
		end
	end
	return minetest.item_place(itemstack, placer, pointed_thing, param2)
end

-- Register mcl_stairs.
-- Node will be called mcl_stairs:stair_<subname>

function mcl_stairs.register_stair(subname, recipeitem, groups, images, description, sounds, hardness)
	groups.stair = 1
	groups.building_block = 1
	minetest.register_node(":mcl_stairs:stair_" .. subname, {
		description = description,
		_doc_items_longdesc = "Stairs are useful to reach higher places by walking over them; jumping is not required. Placing stairs in a corner pattern will create corner stairs. Stairs placed on the bottom or at the upper half of the side of a block will be placed upside down.",
		drawtype = "mesh",
		mesh = "stairs_stair.obj",
		tiles = images,
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = false,
		is_ground_content = false,
		groups = groups,
		sounds = sounds,
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
			},
		},
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return itemstack
			end

			return place_stair(itemstack, placer, pointed_thing)
		end,
		_mcl_hardness = hardness,
	})

	if recipeitem then
		minetest.register_craft({
			output = 'mcl_stairs:stair_' .. subname .. ' 4',
			recipe = {
				{recipeitem, "", ""},
				{recipeitem, recipeitem, ""},
				{recipeitem, recipeitem, recipeitem},
			},
		})

		-- Flipped recipe
		minetest.register_craft({
			output = 'mcl_stairs:stair_' .. subname .. ' 4',
			recipe = {
				{"", "", recipeitem},
				{"", recipeitem, recipeitem},
				{recipeitem, recipeitem, recipeitem},
			},
		})
	end
end


-- Slab facedir to placement 6d matching table
local slab_trans_dir = {[0] = 8, 0, 2, 1, 3, 4}

-- Register slabs.
-- Node will be called mcl_stairs:slab_<subname>

-- double_description: NEW argument, not supported in Minetest Game
-- double_description: Description of double slab
function mcl_stairs.register_slab(subname, recipeitem, groups, images, description, sounds, hardness, double_description)
	local lower_slab = "mcl_stairs:slab_"..subname
	local upper_slab = lower_slab.."_top"
	local double_slab = lower_slab.."_double"

	-- Automatically generate double slab description
	if not double_description then
		double_description = string.format("Double %s", description)
		minetest.log("warning", "[stairs] No explicit description for double slab '"..double_slab.."' added. Using auto-generated description.")
	end

	groups.slab = 1
	groups.building_block = 1
	local longdesc = "Slabs are half as high as their full block counterparts and occupy either the lower or upper part of a block, depending on how it was placed. Slabs can be easily stepped on without needing to jump. When a slab is placed on another slab of the same type, a double slab is created."

	local slabdef = {
		description = description,
		_doc_items_longdesc = longdesc,
		drawtype = "nodebox",
		tiles = images,
		paramtype = "light",
		-- Facedir intentionally left out (see below)
		sunlight_propagates = false,
		is_ground_content = false,
		groups = groups,
		sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
		},
		on_place = function(itemstack, placer, pointed_thing)
			local under = minetest.get_node(pointed_thing.under)
			local wield_item = itemstack:get_name()
			local creative_enabled = minetest.setting_getbool("creative_mode")

			-- place slab using under node orientation
			local dir = vector.subtract(pointed_thing.above, pointed_thing.under)

			local p2 = under.param2

			-- combine two slabs if possible
			-- Requirements: Same slab material, must be placed on top of lower slab, or on bottom of upper slab
			if (wield_item == under.name or wield_item == minetest.registered_nodes[under.name]._mcl_other_slab_half) and
					not ((dir.y >= 0 and minetest.get_item_group(under.name, "slab_top") == 1) or
					(dir.y <= 0 and minetest.get_item_group(under.name, "slab_top") == 0)) then

				if not recipeitem then
					return itemstack
				end
				local player_name = placer:get_player_name()
				if minetest.is_protected(pointed_thing.under, player_name) and not
						minetest.check_player_privs(placer, "protection_bypass") then
					minetest.record_protection_violation(pointed_thing.under,
						player_name)
					return
				end
				local newnode = double_slab
				minetest.set_node(pointed_thing.under, {name = newnode, param2 = p2})
				if not creative_enabled then
					itemstack:take_item()
				end
				return itemstack
			-- No combination possible: Place slab normally
			else
				return place_slab_normal(itemstack, placer, pointed_thing)
			end
		end,
		_mcl_hardness = hardness,
		_mcl_other_slab_half = upper_slab,
	}

	minetest.register_node(":"..lower_slab, slabdef)

	-- Register the upper slab.
	-- Using facedir is not an option, as this would rotate the textures as well and would make
	-- e.g. upper sandstone slabs look completely wrong.
	local topdef = table.copy(slabdef)
	topdef.groups.slab = 1
	topdef.groups.slab_top = 1
	topdef.groups.not_in_creative_inventory = 1
	topdef.groups.not_in_craft_guide = 1
	topdef.description = string.format("Upper %s", description)
	topdef._doc_items_create_entry = false
	topdef._doc_items_longdesc = nil
	topdef._doc_items_usagehelp = nil
	topdef.drop = lower_slab
	topdef._mcl_other_slab_half = lower_slab
	topdef.node_box = {
		type = "fixed",
		fixed = {-0.5, 0, -0.5, 0.5, 0.5, 0.5},
	}
	topdef.selection_box = {
		type = "fixed",
		fixed = {-0.5, 0, -0.5, 0.5, 0.5, 0.5},
	}
	minetest.register_node(":"..upper_slab, topdef)


	-- Double slab node
	local dgroups = table.copy(groups)
	dgroups.not_in_creative_inventory = 1
	dgroups.not_in_craft_guide = 1
	dgroups.slab = nil
	dgroups.double_slab = 1
	minetest.register_node(":"..double_slab, {
		description = double_description,
		_doc_items_longdesc = "Double slabs are full blocks which are created by placing two slabs of the same kind on each other.",
		tiles = images,
		is_ground_content = false,
		groups = dgroups,
		sounds = sounds,
		drop = lower_slab .. " 2",
		_mcl_hardness = hardness,
	})

	if recipeitem then
		minetest.register_craft({
			output = lower_slab .. " 6",
			recipe = {
				{recipeitem, recipeitem, recipeitem},
			},
		})

	end

	-- Help alias for the upper slab
	if minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", lower_slab, "nodes", upper_slab)
	end
end


-- Stair/slab registration function.
-- Nodes will be called mcl_stairs:{stair,slab}_<subname>

function mcl_stairs.register_stair_and_slab(subname, recipeitem,
		groups, images, desc_stair, desc_slab, sounds, hardness,
		double_description)
	mcl_stairs.register_stair(subname, recipeitem, groups, images, desc_stair, sounds, hardness)
	mcl_stairs.register_slab(subname, recipeitem, groups, images, desc_slab, sounds, hardness, double_description)
end

-- Very simple registration function
-- Makes stair and slab out of a source node
function mcl_stairs.register_stair_and_slab_simple(subname, sourcenode, desc_stair, desc_slab, desc_double_slab)
	local def = minetest.registered_nodes[sourcenode]
	local groups = {}
	-- Only allow a strict set of groups to be added to stairs and slabs for more predictable results
	local allowed_groups = { "dig_immediate", "handy", "pickaxey", "axey", "shovely", "shearsy", "shearsy_wool", "swordy", "swordy_wool" }
	for a=1, #allowed_groups do
		if def.groups[allowed_groups[a]] then
			groups[allowed_groups[a]] = def.groups[allowed_groups[a]]
		end
	end
	mcl_stairs.register_stair_and_slab(subname, sourcenode, groups, def.tiles, desc_stair, desc_slab, def.sounds, def._mcl_hardness, desc_double_slab)
end

-- Register all Minecraft stairs and slabs
-- Note about hardness: For some reason, the hardness of slabs and stairs don't always match nicely, so that some
-- slabs actually take slightly longer to be dug than their stair counterparts.
-- Note sure if it is a good idea to preserve this oddity.

mcl_stairs.register_stair("wood", "mcl_core:wood",
		{handy=1,axey=1, flammable=3,wood_stairs=1, material_wood=1},
		{"default_wood.png"},
		"Oak Wood Stairs",
		mcl_sounds.node_sound_wood_defaults(),
		2)
mcl_stairs.register_slab("wood", "mcl_core:wood",
		{handy=1,axey=1, flammable=3,wood_slab=1, material_wood=1},
		{"default_wood.png"},
		"Oak Wood Slab",
		mcl_sounds.node_sound_wood_defaults(),
		2,
		"Double Oak Wood Slab")

mcl_stairs.register_stair("junglewood", "mcl_core:junglewood",
		{handy=1,axey=1, flammable=3,wood_stairs=1, material_wood=1},
		{"default_junglewood.png"},
		"Jungle Wood Stairs",
		mcl_sounds.node_sound_wood_defaults(),
		2)
mcl_stairs.register_slab("junglewood", "mcl_core:junglewood",
		{handy=1,axey=1, flammable=3,wood_slab=1, material_wood=1},
		{"default_junglewood.png"},
		"Jungle Wood Slab",
		mcl_sounds.node_sound_wood_defaults(),
		2,
		"Double Jungle Wood Slab")

mcl_stairs.register_stair("acaciawood", "mcl_core:acaciawood",
		{handy=1,axey=1, flammable=3,wood_stairs=1, material_wood=1},
		{"default_acacia_wood.png"},
		"Acacia Wood Stairs",
		mcl_sounds.node_sound_wood_defaults(),
		2)

mcl_stairs.register_slab("acaciawood", "mcl_core:acaciawood",
		{handy=1,axey=1, flammable=3,wood_slab=1, material_wood=1},
		{"default_acacia_wood.png"},
		"Acacia Wood Slab",
		mcl_sounds.node_sound_wood_defaults(),
		2,
		"Double Acacia Wood Slab")

mcl_stairs.register_stair("sprucewood", "mcl_core:sprucewood",
		{handy=1,axey=1, flammable=3,wood_stairs=1, material_wood=1},
		{"mcl_core_planks_spruce.png"},
		"Spruce Wood Stairs",
		mcl_sounds.node_sound_wood_defaults(),
		2)
mcl_stairs.register_slab("sprucewood", "mcl_core:sprucewood",
		{handy=1,axey=1, flammable=3,wood_slab=1, material_wood=1},
		{"mcl_core_planks_spruce.png"},
		"Spruce Wood Slab",
		mcl_sounds.node_sound_wood_defaults(),
		2,
		"Double Spruce Wood Slab")

mcl_stairs.register_stair("birchwood", "mcl_core:birchwood",
		{handy=1,axey=1, flammable=3,wood_stairs=1, material_wood=1},
		{"mcl_core_planks_birch.png"},
		"Birch Wood Stairs",
		mcl_sounds.node_sound_wood_defaults(),
		2)
mcl_stairs.register_slab("birchwood", "mcl_core:birchwood",
		{handy=1,axey=1, flammable=3,wood_slab=1, material_wood=1},
		{"mcl_core_planks_birch.png"},
		"Birch Wood Slab",
		mcl_sounds.node_sound_wood_defaults(),
		2,
		"Double Birch Wood Slab")

mcl_stairs.register_stair("darkwood", "mcl_core:darkwood",
		{handy=1,axey=1, flammable=3,wood_stairs=1, material_wood=1},
		{"mcl_core_planks_big_oak.png"},
		"Dark Oak Wood Stairs",
		mcl_sounds.node_sound_wood_defaults(),
		2)
mcl_stairs.register_slab("darkwood", "mcl_core:darkwood",
		{handy=1,axey=1, flammable=3,wood_slab=1, material_wood=1},
		{"mcl_core_planks_big_oak.png"},
		"Dark Oak Wood Slab",
		mcl_sounds.node_sound_wood_defaults(),
		2,
		"Double Dark Oak Wood Slab")

mcl_stairs.register_slab("stone", "mcl_core:stone",
		{pickaxey=1, material_stone=1},
		{"mcl_stairs_stone_slab_top.png", "mcl_stairs_stone_slab_top.png", "mcl_stairs_stone_slab_side.png"},
		"Stone Slab",
		mcl_sounds.node_sound_stone_defaults(), 2, "Double Stone Slab")

mcl_stairs.register_stair_and_slab_simple("cobble", "mcl_core:cobble", "Cobblestone Stairs", "Cobblestone Slab", nil, nil, "Double Cobblestone Slab")

mcl_stairs.register_stair_and_slab_simple("brick_block", "mcl_core:brick_block", "Brick Stairs", "Brick Slab", nil, nil, "Double Brick Slab")


mcl_stairs.register_stair("sandstone", "group:sandstone",
		{pickaxey=1, material_stone=1},
		{"mcl_core_sandstone_top.png", "mcl_core_sandstone_bottom.png", "mcl_core_sandstone_normal.png"},
		"Sandstone Stairs",
		mcl_sounds.node_sound_stone_defaults(), 0.8, nil, "mcl_core:sandstone")
mcl_stairs.register_slab("sandstone", "group:sandstone",
		{pickaxey=1, material_stone=1},
		{"mcl_core_sandstone_top.png", "mcl_core_sandstone_bottom.png", "mcl_core_sandstone_normal.png"},
		"Sandstone Slab",
		mcl_sounds.node_sound_stone_defaults(), 2, "Double Sandstone Slab", "mcl_core:sandstone")

mcl_stairs.register_stair("redsandstone", "group:redsandstone",
		{pickaxey=1, material_stone=1},
		{"mcl_core_red_sandstone_top.png", "mcl_core_red_sandstone_bottom.png", "mcl_core_red_sandstone_normal.png"},
		"Red Sandstone Stairs",
		mcl_sounds.node_sound_stone_defaults(), 0.8, nil, "mcl_core:redsandstone")
mcl_stairs.register_slab("redsandstone", "group:redsandstone",
		{pickaxey=1, material_stone=1},
		{"mcl_core_red_sandstone_top.png", "mcl_core_red_sandstone_bottom.png", "mcl_core_red_sandstone_normal.png"},
		"Red Sandstone Slab",
		mcl_sounds.node_sound_stone_defaults(), 2, "Double Red Sandstone Slab", "mcl_core:redsandstone")

mcl_stairs.register_stair("stonebrick", "group:stonebrick",
		{pickaxey=1, material_stone=1},
		{"default_stone_brick.png"},
		"Stone Bricks Stairs",
		mcl_sounds.node_sound_stone_defaults(), 1.5, nil, "mcl_core:stonebrick")
mcl_stairs.register_slab("stonebrick", "group:stonebrick",
		{pickaxey=1, material_stone=1},
		{"default_stone_brick.png"},
		"Stone Bricks Slab",
		mcl_sounds.node_sound_stone_defaults(), 2, "Double Stone Bricks Slab", "mcl_core:stonebrick")

mcl_stairs.register_stair("quartzblock", "group:quartz_block",
		{pickaxey=1, material_stone=1},
		{"mcl_nether_quartz_block_top.png", "mcl_nether_quartz_block_bottom.png", "mcl_nether_quartz_block_side.png"},
		"Quartz Stairs",
		mcl_sounds.node_sound_stone_defaults(), 0.8, nil, "mcl_nether:quartz_block")
mcl_stairs.register_slab("quartzblock", "group:quartz_block",
		{pickaxey=1, material_stone=1},
		{"mcl_nether_quartz_block_top.png", "mcl_nether_quartz_block_bottom.png", "mcl_nether_quartz_block_side.png"},
		"Quartz Slab",
		mcl_sounds.node_sound_stone_defaults(), 2, "Double Quarzt Slab", "mcl_nether:quartz_block")

mcl_stairs.register_stair_and_slab("nether_brick", "mcl_nether:nether_brick",
		{pickaxey=1, material_stone=1},
		{"mcl_nether_nether_brick.png"},
		"Nether Brick Stairs",
		"Nether Brick Slab",
		mcl_sounds.node_sound_stone_defaults(),
		2,
		"Double Nether Brick Slab")

mcl_stairs.register_stair("purpur_block", "mcl_end:purpur_block",
		{pickaxey=1, material_stone=1},
		{"mcl_end_purpur_block.png"},
		"Purpur Stairs",
		mcl_sounds.node_sound_stone_defaults(),
		1.5)
mcl_stairs.register_slab("purpur_block", "mcl_end:purpur_block",
		{pickaxey=1, material_stone=1},
		{"mcl_end_purpur_block.png"},
		"Purpur Slab",
		mcl_sounds.node_sound_stone_defaults(),
		2,
		"Double Purpur Slab")

minetest.register_craft({
	output = 'mcl_core:sandstonecarved',
	recipe = {
		{'mcl_stairs:slab_sandstone'},
		{'mcl_stairs:slab_sandstone'}
	}
})

minetest.register_craft({
	output = 'mcl_core:redsandstonecarved',
	recipe = {
		{'mcl_stairs:slab_redsandstone'},
		{'mcl_stairs:slab_redsandstone'}
	}
})

minetest.register_craft({
	output = 'mcl_core:stonebrickcarved',
	recipe = {
		{'mcl_stairs:slab_stonebrick'},
		{'mcl_stairs:slab_stonebrick'}
	}
})

minetest.register_craft({
	output = 'mcl_end:purpur_pillar',
	recipe = {
		{'mcl_stairs:slab_purpur_block'},
		{'mcl_stairs:slab_purpur_block'}
	}
})

minetest.register_craft({
	output = 'mcl_nether:quartz_chiseled 2',
	recipe = {
		{'mcl_stairs:slab_quartzblock'},
		{'mcl_stairs:slab_quartzblock'},
	}
})

-- Fuel
minetest.register_craft({
	type = "fuel",
	recipe = "group:wood_stairs",
	burntime = 15,
})
minetest.register_craft({
	type = "fuel",
	recipe = "group:wood_slab",
	-- Original burn time: 7.5 (PC edition)
	burntime = 8,
})


