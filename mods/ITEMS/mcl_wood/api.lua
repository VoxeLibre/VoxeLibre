mcl_wood = {}
-- Tree nodes: Wood, Wooden Planks, Sapling, Leaves, Stripped Wood
local S = minetest.get_translator(minetest.get_current_modname())

local mod_screwdriver = minetest.get_modpath("screwdriver")

local on_rotate
if mod_screwdriver then
	on_rotate = screwdriver.rotate_3way
end

-- Register tree trunk (wood) and bark
local function register_tree_trunk(subname, description_trunk, description_bark, longdesc, tile_inner, tile_bark, stripped_variant)
	minetest.register_node(":mcl_wood:"..subname, {
		description = description_trunk,
		_doc_items_longdesc = longdesc,
		_doc_items_hidden = false,
		tiles = {tile_inner, tile_inner, tile_bark},
		paramtype2 = "facedir",
		on_place = mcl_util.rotate_axis,
		stack_max = 64,
		groups = {handy=1,axey=1, tree=1, flammable=2, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=5},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		on_rotate = on_rotate,
		_mcl_blast_resistance = 2,
		_mcl_hardness = 2,
		_mcl_stripped_variant = stripped_variant,
	})

	minetest.register_node(":mcl_wood:"..subname.."_bark", {
		description = description_bark,
		_doc_items_longdesc = S("This is a decorative block surrounded by the bark of a tree trunk."),
		tiles = {tile_bark},
		paramtype2 = "facedir",
		on_place = mcl_util.rotate_axis,
		stack_max = 64,
		groups = {handy=1,axey=1, bark=1, flammable=2, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=5},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		is_ground_content = false,
		on_rotate = on_rotate,
		_mcl_blast_resistance = 2,
		_mcl_hardness = 2,
		_mcl_stripped_variant = stripped_variant.."_bark",
	})

	minetest.register_craft({
		output = "mcl_wood:"..subname.."_bark 3",
		recipe = {
			{ "mcl_wood:"..subname, "mcl_wood:"..subname },
			{ "mcl_wood:"..subname, "mcl_wood:"..subname },
		}
	})
end

-- Register stripped trunk and stripped wood
local function register_stripped_trunk(subname, description_stripped_trunk, description_stripped_bark, longdesc, longdesc_wood, tile_stripped_inner, tile_stripped_bark)
	minetest.register_node(":mcl_wood:"..subname, {
		description = description_stripped_trunk,
		_doc_items_longdesc = longdesc,
		_doc_items_hidden = false,
		tiles = {tile_stripped_inner, tile_stripped_inner, tile_stripped_bark},
		paramtype2 = "facedir",
		on_place = mcl_util.rotate_axis,
		stack_max = 64,
		groups = {handy=1, axey=1, tree=1, flammable=2, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=5},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		on_rotate = on_rotate,
		_mcl_blast_resistance = 2,
		_mcl_hardness = 2,
	})

	minetest.register_node(":mcl_wood:"..subname.."_bark", {
		description = description_stripped_bark,
		_doc_items_longdesc = longdesc_wood,
		tiles = {tile_stripped_bark},
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

	minetest.register_craft({
		output = "mcl_wood:"..subname.."_bark 3",
		recipe = {
			{ "mcl_wood:"..subname, "mcl_wood:"..subname },
			{ "mcl_wood:"..subname, "mcl_wood:"..subname },
		}
	})
end

local function register_wooden_planks(subname, description, tiles)
	minetest.register_node(":mcl_wood:"..subname, {
		description = description,
		_doc_items_longdesc = doc.sub.items.temp.build,
		_doc_items_hidden = false,
		tiles = tiles,
		stack_max = 64,
		is_ground_content = false,
		groups = {handy=1,axey=1, flammable=3,wood=1,building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=20},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		_mcl_blast_resistance = 3,
		_mcl_hardness = 2,
	})
end

local function register_leaves(subname, description, longdesc, tiles, sapling, drop_apples, sapling_chances, leafdecay_distance)
	if leafdecay_distance == nil then
		leafdecay_distance = 4
	end
	local apple_chances = {200, 180, 160, 120, 40}
	local stick_chances = {50, 45, 30, 35, 10}

	local function get_drops(fortune_level)
		local drop = {
			max_items = 1,
			items = {
				{
					items = {sapling},
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
		if drop_apples then
			table.insert(drop.items, {
				items = {"mcl_core:apple"},
				rarity = apple_chances[fortune_level + 1]
			})
		end
		return drop
	end

	minetest.register_node(":mcl_wood:"..subname, {
		description = description,
		_doc_items_longdesc = longdesc,
		_doc_items_hidden = false,
		drawtype = "allfaces_optional",
		waving = 2,
		place_param2 = 1, -- Prevent leafdecay for placed nodes
		tiles = tiles,
		paramtype = "light",
		stack_max = 64,
		groups = {
			handy = 1, hoey = 1, shearsy = 1, swordy = 1, dig_by_piston = 1,
			leaves = 1, leafdecay = leafdecay_distance, deco_block = 1,
			flammable = 2, fire_encouragement = 30, fire_flammability = 60,
			compostability = 30
		},
		drop = get_drops(0),
		_mcl_shears_drop = true,
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		_mcl_blast_resistance = 0.2,
		_mcl_hardness = 0.2,
		_mcl_silk_touch_drop = true,
		_mcl_fortune_drop = { get_drops(1), get_drops(2), get_drops(3), get_drops(4) },
	})
end

local function register_sapling(subname, description, longdesc, tt_help, texture, selbox)
	minetest.register_node(":mcl_wood:"..subname, {
		description = description,
		_tt_help = tt_help,
		_doc_items_longdesc = longdesc,
		_doc_items_hidden = false,
		drawtype = "plantlike",
		waving = 1,
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
		groups = {
			plant = 1, sapling = 1, non_mycelium_plant = 1, attached_node = 1,
			deco_block = 1, dig_immediate = 3, dig_by_water = 1, dig_by_piston = 1,
			destroy_by_lava_flow = 1, compostability = 30
		},
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_int("stage", 0)
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
end

function readable_name(str)
	str = str:gsub("_", " ")
    return (str:gsub("^%l", string.upper))
end


function mcl_wood.register_wood(name,nether,nosap)
	local rname = readable_name(name)
	register_tree_trunk("tree_"..name, S(rname.." Wood"), S(rname.." Bark"), S("The trunk of an "..name.." tree."), "mcl_wood_tree_"..name.."_top.png", "mcl_wood_tree_"..name..".png", "mcl_wood:stripped_"..name)

	register_stripped_trunk("tree_stripped_"..name, S("Stripped "..rname.." Log"), S("Stripped "..rname.." Wood"), S("The stripped trunk of an "..name.." tree."), S("The stripped wood of an "..name.." tree."), "mcl_wood_stripped_"..name.."_top.png", "mcl_wood_stripped_"..name..".png")

	register_wooden_planks("wood_"..name, S(rname.." Wood Planks"), {"mcl_wood_planks_"..name..".png"})

	if not nosap then
		register_sapling("sapling_"..name, S(rname.." Sapling"),S("When placed on soil (such as dirt) and exposed to light, an "..name.." sapling will grow into an "..name.." after some time."),S("Needs soil and light to grow"),"mcl_wood_sapling_"..name..".png", {-5/16, -0.5, -5/16, 5/16, 0.5, 5/16})
	end

	register_leaves("leaves_"..name, S(rname.." Leaves"), S(rname.." leaves are grown from "..name.." trees."), {"mcl_wood_leaves_"..name..".png"}, "mcl_wood:sapling_"..name, true, {20, 16, 12, 10})

	mcl_stairs.register_stair(name, "mcl_wood:"..name,
			{handy=1,axey=1, flammable=3,wood_stairs=1, material_wood=1, fire_encouragement=5, fire_flammability=20},
			{"mcl_wood_planks_"..name..".png"},
			S("Oak Wood Stairs"),
			mcl_sounds.node_sound_wood_defaults(), 3, 2,
			"woodlike")
	mcl_stairs.register_slab(name, "mcl_wood:"..name,
			{handy=1,axey=1, flammable=3,wood_slab=1, material_wood=1, fire_encouragement=5, fire_flammability=20},
			{"mcl_wood_planks_"..name..".png"},
			S(rname.." Wood Slab"),
			mcl_sounds.node_sound_wood_defaults(), 3, 2,
			S("Double "..rname.." Wood Slab"))
end
