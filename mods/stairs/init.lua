-- Minetest 0.4 mod: stairs
-- See README.txt for licensing and other information.
local init = os.clock()
stairs = {}

-- Node will be called stairs:stair_<subname>
function stairs.register_stair(subname, recipeitem, groups, images, description, sounds)
	minetest.register_node(":stairs:stair_" .. subname, {
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
			if p0.y-1 == p1.y then
				local fakestack = ItemStack("stairs:stair_" .. subname.."upside_down")
				local ret = minetest.item_place(fakestack, placer, pointed_thing)
				if ret:is_empty() then
					itemstack:take_item()
					return itemstack
				end
			end
			local futurpos = pointed_thing.under
			local frontstair = {x=futurpos.x-1, y=futurpos.y+1, z=futurpos.z} 
			local leftstair = {x=futurpos.x, y=futurpos.y+1, z=futurpos.z+1} 
			print( minetest.get_node(frontstair).name)
			if minetest.get_node(frontstair).name == "stairs:stair_"..subname.."" and minetest.get_node(leftstair).name == "stairs:stair_"..subname.."" then
				local fakestack = ItemStack("stairs:stair_" .. subname.."_corner_1")
				local ret = minetest.item_place(fakestack, placer, pointed_thing)
				if ret:is_empty() then
					itemstack:take_item()
					return itemstack
				end
			end 
			
			-- Otherwise place regularly
			return minetest.item_place(itemstack, placer, pointed_thing)
		end,
	})
	
	minetest.register_node(":stairs:stair_" .. subname.."upside_down", {
		drop = "stairs:stair_" .. subname,
		drawtype = "nodebox",
		tiles = images,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = groups,
		sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, 0, -0.5, 0.5, 0.5, 0.5},
				{-0.5, -0.5, 0, 0.5, 0, 0.5},
			},
		},
	})

	minetest.register_node(":stairs:stair_" .. subname.."_corner_1", {
		drop = "stairs:stair_" .. subname,
		drawtype = "nodebox",
		tiles = images,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = groups,
		sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, 
				{-0.5, -0, -0, 0, 0.5, 0.5}, 
			},
		},
	})

	minetest.register_craft({
		output = 'stairs:stair_' .. subname .. ' 4',
		recipe = {
			{recipeitem, "", ""},
			{recipeitem, recipeitem, ""},
			{recipeitem, recipeitem, recipeitem},
		},
	})

	-- Flipped recipe for the silly minecrafters
	minetest.register_craft({
		output = 'stairs:stair_' .. subname .. ' 4',
		recipe = {
			{"", "", recipeitem},
			{"", recipeitem, recipeitem},
			{recipeitem, recipeitem, recipeitem},
		},
	})
end

-- Node will be called stairs:slab_<subname>
function stairs.register_slab(subname, recipeitem, groups, images, description, sounds)
	minetest.register_node(":stairs:slab_" .. subname, {
		description = description,
		drawtype = "nodebox",
		tiles = images,
		paramtype = "light",
		is_ground_content = false,
		groups = groups,
		sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
		},
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return itemstack
			end

			-- If it's being placed on an another similar one, replace it with
			-- a full block
			local slabpos = nil
			local slabnode = nil
			local p0 = pointed_thing.under
			local p1 = pointed_thing.above
			local n0 = minetest.get_node(p0)
			if n0.name == "stairs:slab_" .. subname and
					p0.y+1 == p1.y then
				slabpos = p0
				slabnode = n0
			end
			if slabpos then
				-- Remove the slab at slabpos
				minetest.remove_node(slabpos)
				-- Make a fake stack of a single item and try to place it
				local fakestack = ItemStack(recipeitem)
				pointed_thing.above = slabpos
				fakestack = minetest.item_place(fakestack, placer, pointed_thing)
				-- If the item was taken from the fake stack, decrement original
				if not fakestack or fakestack:is_empty() then
					itemstack:take_item(1)
				-- Else put old node back
				else
					minetest.set_node(slabpos, slabnode)
				end
				return itemstack
			end
			
			-- Upside down slabs
			if p0.y-1 == p1.y then
				-- Turn into full block if pointing at a existing slab
				if n0.name == "stairs:slab_" .. subname.."upside_down" then
					-- Remove the slab at the position of the slab
					minetest.remove_node(p0)
					-- Make a fake stack of a single item and try to place it
					local fakestack = ItemStack(recipeitem)
					pointed_thing.above = p0
					fakestack = minetest.item_place(fakestack, placer, pointed_thing)
					-- If the item was taken from the fake stack, decrement original
					if not fakestack or fakestack:is_empty() then
						itemstack:take_item(1)
					-- Else put old node back
					else
						minetest.set_node(p0, n0)
					end
					return itemstack
				end
				
				-- Place upside down slab
				local fakestack = ItemStack("stairs:slab_" .. subname.."upside_down")
				local ret = minetest.item_place(fakestack, placer, pointed_thing)
				if ret:is_empty() then
					itemstack:take_item()
					return itemstack
				end
			end
			
			-- If pointing at the side of a upside down slab
			if n0.name == "stairs:slab_" .. subname.."upside_down" and
					p0.y+1 ~= p1.y then
				-- Place upside down slab
				local fakestack = ItemStack("stairs:slab_" .. subname.."upside_down")
				local ret = minetest.item_place(fakestack, placer, pointed_thing)
				if ret:is_empty() then
					itemstack:take_item()
					return itemstack
				end
			end
			
			-- Otherwise place regularly
			return minetest.item_place(itemstack, placer, pointed_thing)
		end,
	})
	
	minetest.register_node(":stairs:slab_" .. subname.."upside_down", {
		drop = "stairs:slab_"..subname,
		drawtype = "nodebox",
		tiles = images,
		paramtype = "light",
		stack_max = 64,
		paramtype2 = "facedir",
		on_place = minetest.rotate_node,
		is_ground_content = false,
		groups = groups,
		sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {-0.5, 0, -0.5, 0.5, 0.5, 0.5},
		},
	})

	minetest.register_craft({
		output = 'stairs:slab_' .. subname .. ' 6',
		recipe = {
			{recipeitem, recipeitem, recipeitem},
		},
	})
end

-- Nodes will be called stairs:{stair,slab}_<subname>
function stairs.register_stair_and_slab(subname, recipeitem, groups, images, desc_stair, desc_slab, sounds)
	stairs.register_stair(subname, recipeitem, groups, images, desc_stair, sounds)
	stairs.register_slab(subname, recipeitem, groups, images, desc_slab, sounds)
end

stairs.register_stair("wood", "default:wood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3,wood_stairs=1},
		{"default_wood.png"},
		"Oak Wood Stairs",
		default.node_sound_wood_defaults())
stairs.register_slab("wood", "default:wood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3,wood_slab=1},
		{"default_wood.png"},
		"Oak Wood Slab",
		default.node_sound_wood_defaults())

stairs.register_stair("junglewood", "default:junglewood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3,wood_stairs=1},
		{"default_junglewood.png"},
		"Jungle Wood Stairs",
		default.node_sound_wood_defaults())
stairs.register_slab("junglewood", "default:junglewood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3,wood_slab=1},
		{"default_junglewood.png"},
		"Jungle Wood Slab",
		default.node_sound_wood_defaults())
	
stairs.register_stair("acaciawood", "default:acaciawood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3,wood_stairs=1},
		{"default_acaciawood.png"},
		"Acacia Wood Stairs",
		default.node_sound_wood_defaults())

stairs.register_slab("acaciawood", "default:acaciawood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3,wood_slab=1},
		{"default_acaciawood.png"},
		"Acacia Wood Slab",
		default.node_sound_wood_defaults())
	
stairs.register_stair("sprucewood", "default:sprucewood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3,wood_stairs=1},
		{"default_sprucewood.png"},
		"Spruce Wood Stairs",
		default.node_sound_wood_defaults())
stairs.register_slab("sprucewood", "default:sprucewood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3,wood_slab=1},
		{"default_sprucewood.png"},
		"Spruce Wood Slab",
		default.node_sound_wood_defaults())

stairs.register_stair("birchwood", "default:birchwood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3,wood_stairs=1},
		{"default_planks_birch.png"},
		"Birch Wood Stairs",
		default.node_sound_wood_defaults())
stairs.register_slab("birchwood", "default:birchwood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3,wood_slab=1},
		{"default_planks_birch.png"},
		"Birch Wood Slab",
		default.node_sound_wood_defaults())

stairs.register_stair("darkwood", "default:darkwood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3,wood_stairs=1},
		{"default_planks_big_oak.png"},
		"Dark Oak Wood Stairs",
		default.node_sound_wood_defaults())
stairs.register_slab("oakwood", "default:darkwood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3,wood_slab=1},
		{"default_planks_big_oak.png"},
		"Dark Oak Wood Slab",
		default.node_sound_wood_defaults())

stairs.register_stair_and_slab("stone", "default:stone",
		{cracky=3},
		{"default_stone.png"},
		"Stone Stairs",
		"Stone Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("cobble", "default:cobble",
		{cracky=3},
		{"default_cobble.png"},
		"Cobblestone Stairs",
		"Cobblestone Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("brick", "default:brick",
		{cracky=3},
		{"default_brick.png"},
		"Bricks Stairs",
		"Bricks Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("sandstone", "group:sandstone",
		{crumbly=2,cracky=2},
		{"default_sandstone_top.png", "default_sandstone_bottom.png", "default_sandstone_normal.png"},
		"Sandstone Stairs",
		"Sandstone Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("redsandstone", "group:redsandstone",
		{crumbly=2,cracky=2},
		{"default_redsandstone_top.png", "default_redsandstone_bottom.png", "default_redsandstone_normal.png"},
		"Red Sandstone Stairs",
		"Red Sandstone Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("stonebrick", "group:stonebrick",
		{cracky=3},
		{"default_stone_brick.png"},
		"Stone Bricks Stairs",
		"Stone Bricks Slab",
		default.node_sound_stone_defaults()
)

stairs.register_stair_and_slab("quartzblock", "group:quartz_block",
	{snappy=1,cracky=1,level=2},
	{"default_quartz_block_top.png", "default_quartz_block_bottom.png", "default_quartz_block_side.png"},
	"Quartz Stairs",
	"Quartz Slab",
	default.node_sound_stone_defaults()
)

stairs.register_stair_and_slab("purpur_block", "mcl_end:purpur_block",
		{cracky=3},
		{"mcl_end_purpur_block.png"},
		"Purpur Stairs",
		"Purpur Slab",
		default.node_sound_stone_defaults()
)

minetest.register_craft({
	output = 'default:sandstonecarved',
	recipe = {
		{'stairs:slab_sandstone'},
		{'stairs:slab_sandstone'}
	}
})

minetest.register_craft({
	output = 'default:redsandstonecarved',
	recipe = {
		{'stairs:slab_redsandstone'},
		{'stairs:slab_redsandstone'}
	}
})

minetest.register_craft({
	output = 'default:stonebrickcarved',
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

local time_to_load= os.clock() - init
print(string.format("[MOD] "..minetest.get_current_modname().." loaded in %.4f s", time_to_load))
