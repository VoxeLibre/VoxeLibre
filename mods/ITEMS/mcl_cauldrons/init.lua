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
	description = "Cauldron",
	wield_image = "mcl_cauldrons_cauldron.png",
	inventory_image = "mcl_cauldrons_cauldron.png",
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	groups = {pickaxey=1, deco_block=1},
	node_box = cauldron_nodeboxes[0],
	selection_box = { type = "regular" },
	tiles = {
		"mcl_cauldrons_cauldron_inner.png^mcl_cauldrons_cauldron_top.png",
		"mcl_cauldrons_cauldron_inner.png^mcl_cauldrons_cauldron_bottom.png",
		"mcl_cauldrons_cauldron_side.png"
	},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_hardness = 2,
	_mcl_blast_resistance = 10,
})

-- Template function for cauldrons with water
local register_filled_cauldron = function(water_level, description)
	minetest.register_node("mcl_cauldrons:cauldron_"..water_level, {
		description = description,
		drawtype = "nodebox",
		paramtype = "light",
		sunlight_propagates = true,
		groups = {pickaxey=1, not_in_creative_inventory=1},
		node_box = cauldron_nodeboxes[water_level],
		collision_box = cauldron_nodeboxes[0],
		selection_box = { type = "regular" },
		tiles = {
			"default_water.png^mcl_cauldrons_cauldron_top.png",
			"mcl_cauldrons_cauldron_inner.png^mcl_cauldrons_cauldron_bottom.png",
			"mcl_cauldrons_cauldron_side.png"
		},
		sounds = mcl_sounds.node_sound_metal_defaults(),
		_mcl_hardness = 2,
		_mcl_blast_resistance = 10,
	})
end

-- Filled crauldrons (3 levels)
register_filled_cauldron(1, "Cauldron (One Third Full)")
register_filled_cauldron(2, "Cauldron (Two Thirds Full)")
register_filled_cauldron(3, "Cauldron (Full)")

minetest.register_craft({
	output = "mcl_cauldrons:cauldron",
	recipe = {
		{ "mcl_core:iron_ingot", "", "mcl_core:iron_ingot" },
		{ "mcl_core:iron_ingot", "", "mcl_core:iron_ingot" },
		{ "mcl_core:iron_ingot", "mcl_core:iron_ingot", "mcl_core:iron_ingot" },
	}
})
