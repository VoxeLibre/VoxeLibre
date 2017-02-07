-- Minetest 0.4 mod: stairs
-- See README.txt for licensing and other information.


-- Global namespace for functions

stairs = {}

-- Register stairs.
-- Node will be called stairs:stair_<subname>

function stairs.register_stair(subname, recipeitem, groups, images, description, sounds)
	groups.stair = 1
	groups.building_block = 1
	minetest.register_node(":stairs:stair_" .. subname, {
		description = description,
		drawtype = "mesh",
		mesh = "stairs_stair.obj",
		tiles = images,
		paramtype = "light",
		paramtype2 = "facedir",
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

			local p0 = pointed_thing.under
			local p1 = pointed_thing.above
			local param2 = 0

			local placer_pos = placer:getpos()
			if placer_pos then
				local dir = {
					x = p1.x - placer_pos.x,
					y = p1.y - placer_pos.y,
					z = p1.z - placer_pos.z
				}
				param2 = minetest.dir_to_facedir(dir)
			end

			if p0.y - 1 == p1.y then
				param2 = param2 + 20
				if param2 == 21 then
					param2 = 23
				elseif param2 == 23 then
					param2 = 21
				end
			end

			return minetest.item_place(itemstack, placer, pointed_thing, param2)
		end,
	})

	if recipeitem then
		minetest.register_craft({
			output = 'stairs:stair_' .. subname .. ' 4',
			recipe = {
				{recipeitem, "", ""},
				{recipeitem, recipeitem, ""},
				{recipeitem, recipeitem, recipeitem},
			},
		})

		-- Flipped recipe
		minetest.register_craft({
			output = 'stairs:stair_' .. subname .. ' 4',
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
-- Slab facedir when placing initial slab against other surface
local slab_trans_dir_place = {[0] = 0, 20, 12, 16, 4, 8}

-- Register slabs.
-- Node will be called stairs:slab_<subname>

-- double_description, full_node: NEW arguments, not supported in Minetest Game
-- double_description: If set, add a separate “double slab” node. The description is the name of this new node
-- full_node: If set, this node is used when two nodes are placed on top of each other. Use this if recipeitem is a group
function stairs.register_slab(subname, recipeitem, groups, images, description, sounds, double_description, full_node)
	groups.slab = 1
	groups.building_block = 1
	minetest.register_node(":stairs:slab_" .. subname, {
		description = description,
		drawtype = "nodebox",
		tiles = images,
		paramtype = "light",
		paramtype2 = "facedir",
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

			if under and wield_item == under.name then
				-- place slab using under node orientation
				local dir = minetest.dir_to_facedir(vector.subtract(
					pointed_thing.above, pointed_thing.under), true)

				local p2 = under.param2

				-- combine two slabs if possible
				if slab_trans_dir[math.floor(p2 / 4)] == dir then
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
					local newnode
					if full_node then
						newnode = full_node
					elseif double_description then
						newnode = "stairs:slab_"..subname.."_double"
					else
						newnode = recipeitem
					end
					minetest.set_node(pointed_thing.under, {name = newnode, param2 = p2})
					if not minetest.setting_getbool("creative_mode") then
						itemstack:take_item()
					end
					return itemstack
				end

				-- Placing a slab on an upside down slab should make it right-side up.
				if p2 >= 20 and dir == 8 then
					p2 = p2 - 20
				-- same for the opposite case: slab below normal slab
				elseif p2 <= 3 and dir == 4 then
					p2 = p2 + 20
				end

				-- else attempt to place node with proper param2
				minetest.item_place_node(ItemStack(wield_item), placer, pointed_thing, p2)
				if not minetest.setting_getbool("creative_mode") then
					itemstack:take_item()
				end
				return itemstack
			else
				-- place slab using look direction of player
				local dir = minetest.dir_to_wallmounted(vector.subtract(
					pointed_thing.above, pointed_thing.under), true)

				local rot = slab_trans_dir_place[dir]
				if rot == 0 or rot == 20 then
					rot = rot + minetest.dir_to_facedir(placer:get_look_dir())
				end

				return minetest.item_place(itemstack, placer, pointed_thing, rot)
			end
		end,
	})

	-- Double slab node
	local dgroups = table.copy(groups)
	dgroups.not_in_creative_inventory = 1
	if double_description then
		minetest.register_node(":stairs:slab_" .. subname .. "_double",  {
			description = double_description,
			paramtype2 = "facedir",
			tiles = images,
			is_ground_content = false,
			groups = dgroups,
			sounds = sounds,
			drop = "stairs:slab_"..subname.." 2",
		})
	end

	if recipeitem then
		minetest.register_craft({
			output = 'stairs:slab_' .. subname .. ' 6',
			recipe = {
				{recipeitem, recipeitem, recipeitem},
			},
		})

	end
end


-- Stair/slab registration function.
-- Nodes will be called stairs:{stair,slab}_<subname>

function stairs.register_stair_and_slab(subname, recipeitem,
		groups, images, desc_stair, desc_slab, sounds,
		double_description, full_node)
	stairs.register_stair(subname, recipeitem, groups, images, desc_stair, sounds)
	stairs.register_slab(subname, recipeitem, groups, images, desc_slab, sounds, double_description, full_node)
end


stairs.register_stair("wood", "mcl_core:wood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3,wood_stairs=1},
		{"default_wood.png"},
		"Oak Wood Stairs",
		mcl_core.node_sound_wood_defaults())
stairs.register_slab("wood", "mcl_core:wood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3,wood_slab=1},
		{"default_wood.png"},
		"Oak Wood Slab",
		mcl_core.node_sound_wood_defaults())

stairs.register_stair("junglewood", "mcl_core:junglewood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3,wood_stairs=1},
		{"default_junglewood.png"},
		"Jungle Wood Stairs",
		mcl_core.node_sound_wood_defaults())
stairs.register_slab("junglewood", "mcl_core:junglewood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3,wood_slab=1},
		{"default_junglewood.png"},
		"Jungle Wood Slab",
		mcl_core.node_sound_wood_defaults())
	
stairs.register_stair("acaciawood", "mcl_core:acaciawood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3,wood_stairs=1},
		{"default_acaciawood.png"},
		"Acacia Wood Stairs",
		mcl_core.node_sound_wood_defaults())

stairs.register_slab("acaciawood", "mcl_core:acaciawood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3,wood_slab=1},
		{"default_acaciawood.png"},
		"Acacia Wood Slab",
		mcl_core.node_sound_wood_defaults())
	
stairs.register_stair("sprucewood", "mcl_core:sprucewood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3,wood_stairs=1},
		{"default_sprucewood.png"},
		"Spruce Wood Stairs",
		mcl_core.node_sound_wood_defaults())
stairs.register_slab("sprucewood", "mcl_core:sprucewood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3,wood_slab=1},
		{"default_sprucewood.png"},
		"Spruce Wood Slab",
		mcl_core.node_sound_wood_defaults())

stairs.register_stair("birchwood", "mcl_core:birchwood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3,wood_stairs=1},
		{"default_planks_birch.png"},
		"Birch Wood Stairs",
		mcl_core.node_sound_wood_defaults())
stairs.register_slab("birchwood", "mcl_core:birchwood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3,wood_slab=1},
		{"default_planks_birch.png"},
		"Birch Wood Slab",
		mcl_core.node_sound_wood_defaults())

stairs.register_stair("darkwood", "mcl_core:darkwood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3,wood_stairs=1},
		{"default_planks_big_oak.png"},
		"Dark Oak Wood Stairs",
		mcl_core.node_sound_wood_defaults())
stairs.register_slab("oakwood", "mcl_core:darkwood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3,wood_slab=1},
		{"default_planks_big_oak.png"},
		"Dark Oak Wood Slab",
		mcl_core.node_sound_wood_defaults())

stairs.register_slab("stone", "mcl_core:stone",
		{cracky=3},
		{"stairs_stone_slab_top.png", "stairs_stone_slab_top.png", "stairs_stone_slab_side.png"},
		"Stone Slab",
		mcl_core.node_sound_stone_defaults(), "Double Stone Slab")

stairs.register_stair_and_slab("cobble", "mcl_core:cobble",
		{cracky=3},
		{"default_cobble.png"},
		"Cobblestone Stairs",
		"Cobblestone Slab",
		mcl_core.node_sound_stone_defaults())

stairs.register_stair_and_slab("brick_block", "mcl_core:brick_block",
		{cracky=3},
		{"default_brick.png"},
		-- Original name: Bricks Stairs
		"Brick Block Stairs",
		-- Original name: Bricks Slab
		"Brick Block Slab",
		mcl_core.node_sound_stone_defaults())

stairs.register_stair_and_slab("sandstone", "group:sandstone",
		{crumbly=2,cracky=2},
		{"default_sandstone_top.png", "default_sandstone_bottom.png", "default_sandstone_normal.png"},
		"Sandstone Stairs",
		"Sandstone Slab",
		mcl_core.node_sound_stone_defaults(), "mcl_core:sandstone")

stairs.register_stair_and_slab("redsandstone", "group:redsandstone",
		{crumbly=2,cracky=2},
		{"default_redsandstone_top.png", "default_redsandstone_bottom.png", "default_redsandstone_normal.png"},
		"Red Sandstone Stairs",
		"Red Sandstone Slab",
		mcl_core.node_sound_stone_defaults(), nil, "mcl_core:redsandstone")

stairs.register_stair_and_slab("stonebrick", "group:stonebrick",
		{cracky=3},
		{"default_stone_brick.png"},
		"Stone Bricks Stairs",
		"Stone Bricks Slab",
		mcl_core.node_sound_stone_defaults(), nil, "mcl_core:stonebrick"
)

stairs.register_stair_and_slab("quartzblock", "group:quartz_block",
	{snappy=1,cracky=1,level=2},
	{"default_quartz_block_top.png", "default_quartz_block_bottom.png", "default_quartz_block_side.png"},
	"Quartz Stairs",
	"Quartz Slab",
	mcl_core.node_sound_stone_defaults(), nil, "mcl_core:quartz_block"
)

stairs.register_stair_and_slab("purpur_block", "mcl_end:purpur_block",
		{cracky=3},
		{"mcl_end_purpur_block.png"},
		"Purpur Stairs",
		"Purpur Slab",
		mcl_core.node_sound_stone_defaults()
)

minetest.register_craft({
	output = 'mcl_core:sandstonecarved',
	recipe = {
		{'stairs:slab_sandstone'},
		{'stairs:slab_sandstone'}
	}
})

minetest.register_craft({
	output = 'mcl_core:redsandstonecarved',
	recipe = {
		{'stairs:slab_redsandstone'},
		{'stairs:slab_redsandstone'}
	}
})

minetest.register_craft({
	output = 'mcl_core:stonebrickcarved',
	recipe = {
		{'stairs:slab_stonebrick'},
		{'stairs:slab_stonebrick'}
	}
})

minetest.register_craft({
	output = 'mcl_end:purpur_pillar',
	recipe = {
		{'stairs:slab_purpur_block'},
		{'stairs:slab_purpur_block'}
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
	burntime = 15,
})
