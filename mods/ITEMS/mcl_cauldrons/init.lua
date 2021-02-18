local S = minetest.get_translator("mcl_cauldron")

-- Cauldron mod, adds cauldrons.

-- TODO: Extinguish fire of burning entities

-- Convenience function because the cauldron nodeboxes are very similar
local create_cauldron_nodebox = function(water_level)
	local floor_y
	if water_level == 0 then	-- empty
		floor_y = -0.1875
	elseif water_level == 1 then	-- 1/3 filled
		floor_y = 1/16
	elseif water_level == 2 then	-- 2/3 filled
		floor_y = 4/16
	elseif water_level == 3 then	-- full
		floor_y = 7/16
	end
	return {
		type = "fixed",
		fixed = {
			{-0.5, -0.1875, -0.5, -0.375, 0.5, 0.5}, -- Left wall
			{0.375, -0.1875, -0.5, 0.5, 0.5, 0.5}, -- Right wall
			{-0.375, -0.1875, 0.375, 0.375, 0.5, 0.5}, -- Back wall
			{-0.375, -0.1875, -0.5, 0.375, 0.5, -0.375}, -- Front wall
			{-0.5, -0.3125, -0.5, 0.5, floor_y, 0.5}, -- Floor
			{-0.5, -0.5, -0.5, -0.375, -0.3125, -0.25}, -- Left front foot, part 1
			{-0.375, -0.5, -0.5, -0.25, -0.3125, -0.375}, -- Left front foot, part 2
			{-0.5, -0.5, 0.25, -0.375, -0.3125, 0.5}, -- Left back foot, part 1
			{-0.375, -0.5, 0.375, -0.25, -0.3125, 0.5}, -- Left back foot, part 2
			{0.375, -0.5, 0.25, 0.5, -0.3125, 0.5}, -- Right back foot, part 1
			{0.25, -0.5, 0.375, 0.375, -0.3125, 0.5}, -- Right back foot, part 2
			{0.375, -0.5, -0.5, 0.5, -0.3125, -0.25}, -- Right front foot, part 1
			{0.25, -0.5, -0.5, 0.375, -0.3125, -0.375}, -- Right front foot, part 2
		}
	}
end

local cauldron_nodeboxes = {}
for w=0,3 do
	cauldron_nodeboxes[w] = create_cauldron_nodebox(w)
end


-- Empty cauldron
minetest.register_node("mcl_cauldrons:cauldron", {
	description = S("Cauldron"),
	_tt_help = S("Stores water"),
	_doc_items_longdesc = S("Cauldrons are used to store water and slowly fill up under rain."),
	_doc_items_usagehelp = S("Place a water pucket into the cauldron to fill it with water. Place an empty bucket on a full cauldron to retrieve the water. Place a water bottle into the cauldron to fill the cauldron to one third with water. Place a glass bottle in a cauldron with water to retrieve one third of the water."),
	wield_image = "mcl_cauldrons_cauldron.png",
	inventory_image = "mcl_cauldrons_cauldron.png",
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	groups = {pickaxey=1, deco_block=1, cauldron=1},
	node_box = cauldron_nodeboxes[0],
	selection_box = { type = "regular" },
	tiles = {
		"mcl_cauldrons_cauldron_inner.png^mcl_cauldrons_cauldron_top.png",
		"mcl_cauldrons_cauldron_inner.png^mcl_cauldrons_cauldron_bottom.png",
		"mcl_cauldrons_cauldron_side.png"
	},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_hardness = 2,
	_mcl_blast_resistance = 2,
})

-- Template function for cauldrons with water
local register_filled_cauldron = function(water_level, description, river_water)
	local id = "mcl_cauldrons:cauldron_"..water_level
	local water_tex
	if river_water then
		id = id .. "r"
		water_tex = "default_river_water_source_animated.png^[verticalframe:16:0"
	else
		water_tex = "default_water_source_animated.png^[verticalframe:16:0"
	end
	minetest.register_node(id, {
		description = description,
		_doc_items_create_entry = false,
		use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
		drawtype = "nodebox",
		paramtype = "light",
		is_ground_content = false,
		groups = {pickaxey=1, not_in_creative_inventory=1, cauldron=(1+water_level), cauldron_filled=water_level, comparator_signal=water_level},
		node_box = cauldron_nodeboxes[water_level],
		collision_box = cauldron_nodeboxes[0],
		selection_box = { type = "regular" },
		tiles = {
			"("..water_tex..")^mcl_cauldrons_cauldron_top.png",
			"mcl_cauldrons_cauldron_inner.png^mcl_cauldrons_cauldron_bottom.png",
			"mcl_cauldrons_cauldron_side.png"
		},
		sounds = mcl_sounds.node_sound_metal_defaults(),
		drop = "mcl_cauldrons:cauldron",
		_mcl_hardness = 2,
		_mcl_blast_resistance = 2,
	})

	-- Add entry aliases for the Help
	if minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", "mcl_cauldrons:cauldron", "nodes", id)
	end
end

-- Filled cauldrons (3 levels)
register_filled_cauldron(1, S("Cauldron (1/3 Water)"))
register_filled_cauldron(2, S("Cauldron (2/3 Water)"))
register_filled_cauldron(3, S("Cauldron (3/3 Water)"))

if minetest.get_modpath("mclx_core") then
	register_filled_cauldron(1, S("Cauldron (1/3 River Water)"), true)
	register_filled_cauldron(2, S("Cauldron (2/3 River Water)"), true)
	register_filled_cauldron(3, S("Cauldron (3/3 River Water)"), true)
end

minetest.register_craft({
	output = "mcl_cauldrons:cauldron",
	recipe = {
		{ "mcl_core:iron_ingot", "", "mcl_core:iron_ingot" },
		{ "mcl_core:iron_ingot", "", "mcl_core:iron_ingot" },
		{ "mcl_core:iron_ingot", "mcl_core:iron_ingot", "mcl_core:iron_ingot" },
	}
})

minetest.register_abm({
	label = "cauldrons",
	nodenames = {"group:cauldron_filled"},
	interval = 0.5,
	chance = 1,
	action = function(pos, node)
		for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 0.4)) do
			if mcl_burning.is_burning(obj) then
				mcl_burning.extinguish(obj)
				local new_group = minetest.get_item_group(node.name, "cauldron_filled") - 1
				minetest.swap_node(pos, {name = "mcl_cauldrons:cauldron" .. (new_group == 0 and "" or "_" .. new_group)})
				break
			end
		end
	end
})
