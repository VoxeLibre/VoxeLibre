-- Tree nodes: Wood, Wooden Planks, Sapling, Leaves

local register_tree_trunk = function(subname, description, longdesc, tiles, after_dig_node)
	minetest.register_node("mcl_core:"..subname, {
		description = description,
		_doc_items_longdesc = longdesc,
		_doc_items_hidden = false,
		tiles = tiles,
		paramtype2 = "facedir",
		on_place = mcl_util.rotate_axis,
		stack_max = 64,
		groups = {handy=1,axey=1, tree=1, flammable=2, building_block=1, material_wood=1},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		_mcl_blast_resistance = 10,
		_mcl_hardness = 2,

		after_dig_node = after_dig_node,
	})
end

local register_wooden_planks = function(subname, description, tiles)
	minetest.register_node("mcl_core:"..subname, {
		description = description,
		_doc_items_longdesc = doc.sub.items.temp.build,
		_doc_items_hidden = false,
		tiles = tiles,
		stack_max = 64,
		is_ground_content = false,
		groups = {handy=1,axey=1, flammable=3,wood=1,building_block=1, material_wood=1},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		_mcl_blast_resistance = 15,
		_mcl_hardness = 2,
	})
end

local register_leaves = function(subname, description, longdesc, tiles, drop1, drop1_rarity, drop2, drop2_rarity, leafdecay_distance)
	local drop
	if leafdecay_distance == nil then
		leafdecay_distance = 4
	end
	if drop2 then
		drop = {
			max_items = 1,
			items = {
				{
					items = {drop1},
					rarity = drop1_rarity,
				},
				{
					items = {drop2},
					rarity = drop2_rarity,
				},
			}
		 }
	else
		drop = {
			max_items = 1,
			items = {
				{
					items = {drop1},
					rarity = drop1_rarity,
				},
			}
		 }
	end

	minetest.register_node("mcl_core:"..subname, {
		description = description,
		_doc_items_longdesc = longdesc,
		_doc_items_hidden = false,
		drawtype = "allfaces_optional",
		place_param2 = 1, -- Prevent leafdecay for placed nodes
		tiles = tiles,
		paramtype = "light",
		stack_max = 64,
		groups = {handy=1,shearsy=1,swordy=1, leafdecay=leafdecay_distance, flammable=2, leaves=1, deco_block=1, dig_by_piston=1},
		drop = drop,
		_mcl_shears_drop = true,
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		_mcl_blast_resistance = 1,
		_mcl_hardness = 0.2,
	})
end

local register_sapling = function(subname, description, longdesc, texture, selbox)
	minetest.register_node("mcl_core:"..subname, {
		description = description,
		_doc_items_longdesc = longdesc,
		_doc_items_hidden = false,
		drawtype = "plantlike",
		visual_scale = 1.0,
		tiles = {texture},
		inventory_image = texture,
		wield_image = texture,
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		selection_box = {
			type = "fixed",
			fixed = selbox
		},
		stack_max = 64,
		groups = {dig_immediate=3, plant=1,sapling=1,non_mycelium_plant=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,deco_block=1},
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_int("stage", 0)
		end,
		on_place = mcl_util.generate_on_place_plant_function(function(pos, node)
			local node_below = minetest.get_node_or_nil({x=pos.x,y=pos.y-1,z=pos.z})
			if not node_below then return false end
			local nn = node_below.name
			return (nn=="mcl_core:dirt_with_grass" or nn=="mcl_core:dirt_with_grass_snow" or
					nn=="mcl_core:podzol" or nn=="mcl_core:podzol_snow" or
					nn=="mcl_core:dirt")
		end),
		node_placement_prediction = "",
		_mcl_blast_resistance = 0,
		_mcl_hardness = 0,
	})
end

---------------------

-- This is a bad bad workaround which is only done because cocoas are not wallmounted (but should)
-- As long cocoas only EVER stick to jungle trees, and nothing else, this is probably a lesser sin.
local jungle_tree_after_dig_node = function(pos, oldnode, oldmetadata, digger)
	-- Drop attached cocoas
	local posses = {
		{ x = pos.x + 1, y = pos.y, z = pos.z },
		{ x = pos.x - 1, y = pos.y, z = pos.z },
		{ x = pos.x, y = pos.y, z = pos.z + 1 },
		{ x = pos.x, y = pos.y, z = pos.z - 1 },
	}
	for p=1, #posses do
		local node = minetest.get_node(posses[p])
		local g = minetest.get_item_group(node.name, "cocoa")
		if g and g >= 1 then
			minetest.remove_node(posses[p])
			local drops = minetest.get_node_drops(node.name, "")
			for d=1, #drops do
				minetest.add_item(posses[p], drops[d])
			end
		end
	end
end

register_tree_trunk("tree", "Oak Wood", "The trunk of an oak tree.", {"default_tree_top.png", "default_tree_top.png", "default_tree.png"})
register_tree_trunk("darktree", "Dark Oak Wood", "The trunk of a dark oak tree.", {"mcl_core_log_big_oak_top.png", "mcl_core_log_big_oak_top.png", "mcl_core_log_big_oak.png"})
register_tree_trunk("acaciatree", "Acacia Wood", "The trunk of an acacia.", {"default_acacia_tree_top.png", "default_acacia_tree_top.png", "default_acacia_tree.png"})
register_tree_trunk("darktree", "Dark Oak Wood", "The trunk of a dark oak tree.", {"mcl_core_log_big_oak_top.png", "mcl_core_log_big_oak_top.png", "mcl_core_log_big_oak.png"})
register_tree_trunk("sprucetree", "Spruce Wood", "The trunk of a spruce tree.", {"mcl_core_log_spruce_top.png", "mcl_core_log_spruce_top.png", "mcl_core_log_spruce.png"})
register_tree_trunk("birchtree", "Birch Wood", "The trunk of a birch tree.", {"mcl_core_log_birch_top.png", "mcl_core_log_birch_top.png", "mcl_core_log_birch.png"})

register_tree_trunk("jungletree", "Jungle Wood", "The trunk of a jungle tree.", {"default_jungletree_top.png", "default_jungletree_top.png", "default_jungletree.png"}, jungle_tree_after_dig_node)


register_wooden_planks("wood", "Oak Wood Planks", {"default_wood.png"})
register_wooden_planks("darkwood", "Dark Oak Wood Planks", {"mcl_core_planks_big_oak.png"})
register_wooden_planks("junglewood", "Jungle Wood Planks", {"default_junglewood.png"})
register_wooden_planks("sprucewood", "Spruce Wood Planks", {"mcl_core_planks_spruce.png"})
register_wooden_planks("acaciawood", "Acacia Wood Planks", {"default_acacia_wood.png"})
register_wooden_planks("birchwood", "Birch Wood Planks", {"mcl_core_planks_birch.png"})


register_sapling("sapling", "Oak Sapling", "When placed on soil (such as dirt) and exposed to light, an oak sapling will grow into an oak tree after some time. If the tree can't grow because of darkness, the sapling will uproot.", "default_sapling.png", {-6/16, -0.5, -6/16, 6/16, 0.5, 6/16})
register_sapling("darksapling", "Dark Oak Sapling", "When placed on soil (such as dirt) and exposed to light, a dark oak sapling will grow into a dark oak tree after some time. If the tree can't grow because of darkness, the sapling will uproot.", "mcl_core_sapling_big_oak.png", {-5.5/16, -0.5, -5.5/16, 5.5/16, 0.5, 5.5/16})
register_sapling("junglesapling", "Jungle Sapling", "When placed on soil (such as dirt) and exposed to light, a jungle sapling will grow into a jungle tree after some time. If the tree can't grow because of darkness, the sapling will uproot.", "default_junglesapling.png", {-4/16, -0.5, -4/16, 4/16, 0.5, 4/16})
register_sapling("acaciasapling", "Acacia Sapling", "When placed on soil (such as dirt) and exposed to light, an acacia sapling will grow into an acacia tree after some time. If the tree can't grow because of darkness, the sapling will uproot.", "default_acacia_sapling.png", {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3})
register_sapling("sprucesapling", "Spruce Sapling", "When placed on soil (such as dirt) and exposed to light, a spruce sapling will grow into a spruce tree after some time. If the tree can't grow because of darkness, the sapling will uproot.", "mcl_core_sapling_spruce.png", {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3})
register_sapling("birchsapling", "Birch Sapling", "When placed on soil (such as dirt) and exposed to light, a birch sapling will grow into a birch tree after some time. If the tree can't grow because of darkness, the sapling will uproot.", "mcl_core_sapling_birch.png", {-6/16, -0.5, -6/16, 6/16, 0.5, 6/16})


register_leaves("leaves", "Oak Leaves", "Oak leaves are grown from oak trees.", {"default_leaves.png"}, "mcl_core:sapling", 20, "mcl_core:apple", 200)
register_leaves("darkleaves", "Dark Oak Leaves", "Dark oak leaves are grown from dark oak trees.", {"mcl_core_leaves_big_oak.png"}, "mcl_core:darksapling", 20, "mcl_core:apple", 200)
-- FIXME: Jungle leaves decay distance should be default, not 6. Distance of 6 was chosen to make the huge jungle tree work.
register_leaves("jungleleaves", "Jungle Leaves", "Jungle leaves are grown from jungle trees.", {"default_jungleleaves.png"}, "mcl_core:junglesapling", 40, nil, nil, 6)
register_leaves("acacialeaves", "Acacia Leaves", "Acacia leaves are grown from acacia trees.", {"default_acacia_leaves.png"}, "mcl_core:acaciasapling", 20)
register_leaves("spruceleaves", "Spruce Leaves", "Spruce leaves are grown from spruce trees.", {"mcl_core_leaves_spruce.png"}, "mcl_core:sprucesapling", 20)
register_leaves("birchleaves", "Birch Leaves", "Birch leaves are grown from birch trees.", {"mcl_core_leaves_birch.png"}, "mcl_core:birchsapling", 20)


-- Node aliases

minetest.register_alias("default:acacia_tree", "mcl_core:acaciatree")
minetest.register_alias("default:acacia_leaves", "mcl_core:acacialeaves")
