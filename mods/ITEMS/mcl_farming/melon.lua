-- Seeds
minetest.register_craftitem("mcl_farming:melon_seeds", {
	description = "Melon Seeds",
	_doc_items_longdesc = "Grows into a melon. Chickens like melon seeds.",
	_doc_items_usagehelp = "Place the melon seeds on farmland (which can be created with a hoe) to plant a melon stem. Melons grow in sunlight and grow faster on hydrated farmland. Rightclick an animal to feed it melon seeds.",
	stack_max = 64,
	groups = { craftitem=1 },
	inventory_image = "farming_melon_seed.png",
	on_place = function(itemstack, placer, pointed_thing)
		return mcl_farming:place_seed(itemstack, placer, pointed_thing, "mcl_farming:melontige_1")
	end,
})

-- Melon template (will be fed into mcl_farming.register_gourd

local melon_base_def = {
	description = "Melon",
	_doc_items_longdesc = "A melon is a block which can be grown from melon stems, which in turn are grown from melon seeds. It can be harvested for melon slices.",
	stack_max = 64,
	tiles = {"farming_melon_top.png", "farming_melon_top.png", "farming_melon_side.png", "farming_melon_side.png", "farming_melon_side.png", "farming_melon_side.png"},
	groups = {handy=1,axey=1, building_block=1},
	drop = {
		max_items = 1,
		items = {
			{ items = {'mcl_farming:melon_item 7'}, rarity = 14 },
			{ items = {'mcl_farming:melon_item 6'}, rarity = 10 },
			{ items = {'mcl_farming:melon_item 5'}, rarity = 5 },
			{ items = {'mcl_farming:melon_item 4'}, rarity = 2 },
			{ items = {'mcl_farming:melon_item 3'} },
		}
	},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 5,
	_mcl_hardness = 1,
}

-- Drop proabilities for melon stem
local stem_drop = {
	max_items = 1,
	-- FIXME: The probabilities are slightly off from the original.
	-- Update this drop list when the Minetest drop probability system
	-- is more powerful.
	items = {
		-- 1 seed: Approximation to 20/125 chance
		-- 20/125 = 0.16
		-- Approximation: 1/6 = ca. 0.166666666666667
		{ items = {"mcl_farming:melon_seeds 1"}, rarity = 6 },

		-- 2 seeds: Approximation to 4/125 chance
		-- 4/125 = 0.032
		-- Approximation: 1/31 = ca. 0.032258064516129
		{ items = {"mcl_farming:melon_seeds 2"}, rarity = 31 },

		-- 3 seeds: 1/125 chance
		{ items = {"mcl_farming:melon_seeds 3"}, rarity = 125 },
	},
}

-- Growing unconnected stems


for s=1,7 do
	local h = s / 8
	local doc = s == 1
	local longdesc, entry_name
	if doc then
		entry_name = "Premature Melon Stem"
		longdesc = "Melon stems grow on farmland in 8 stages. On hydrated farmland, the growth is a bit quicker. Mature melon stems are able to grow melons."
	end
	minetest.register_node("mcl_farming:melontige_"..s, {
		description = string.format("Premature Melon Stem (Stage %d)", s),
		_doc_items_create_entry = doc,
		_doc_items_entry_name = entry_name,
		_doc_items_longdesc = longdesc,
		paramtype = "light",
		walkable = false,
		drawtype = "plantlike",
		sunlight_propagates = true,
		drop = stem_drop,
		tiles = {"mcl_farming_melontige_"..s..".png"},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.15, -0.5, -0.15, 0.15, -0.5+h, 0.15}
			},
		},
		groups = {dig_immediate=3, not_in_creative_inventory=1, attached_node=1, dig_by_water=1},
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		_mcl_blast_resistance = 0,
	})
end

-- Full melon stem, able to spawn melons
local stem_def = {
	description = "Mature Melon Stem",
	_doc_items_create_entry = true,
	_doc_items_longdesc = "A mature melon stem attempts to grow a melon at one of its four adjacent blocks. A melon can only grow on top of farmland, dirt, or a grass block. When a melon is next to a melon stem, the melon stem immediately bends and connects to the melon. While connected, a melon stem can't grow another melon. As soon all melons around the stem have been removed, it loses the connection and is ready to grow another melon.",
	tiles = {"mcl_farming_melontige_8.png"},
}

-- Register stem growth
mcl_farming:add_plant("mcl_farming:melontige_unconnect", {"mcl_farming:melontige_1", "mcl_farming:melontige_2", "mcl_farming:melontige_3", "mcl_farming:melontige_4", "mcl_farming:melontige_5", "mcl_farming:melontige_6", "mcl_farming:melontige_7"}, 50, 20)

-- Register actual melon, connected stems and stem-to-melon growth
mcl_farming:add_gourd("mcl_farming:melontige_unconnect", "mcl_farming:melontige_linked", "mcl_farming:melontige_unconnect", stem_def, stem_drop, "mcl_farming:melon", melon_base_def, 25, 15)

-- Items and crafting
minetest.register_craftitem("mcl_farming:melon_item", {
	-- Original name: “Melon”
	description = "Melon Slice",
	_doc_items_longdesc = "This is a food item which can be eaten for 2 hunger points.",
	stack_max = 64,
	inventory_image = "farming_melon.png",
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
	groups = { food = 2, eatable = 2 },
})

minetest.register_craft({
	output = "mcl_farming:melon_seeds",
	recipe = {{"mcl_farming:melon_item"}}
})

minetest.register_craft({
	output = 'mcl_farming:melon',
	recipe = {
		{'mcl_farming:melon_item', 'mcl_farming:melon_item', 'mcl_farming:melon_item'},
		{'mcl_farming:melon_item', 'mcl_farming:melon_item', 'mcl_farming:melon_item'},
		{'mcl_farming:melon_item', 'mcl_farming:melon_item', 'mcl_farming:melon_item'},
	}
})

if minetest.get_modpath("doc") then
	for i=2,8 do
		doc.add_entry_alias("nodes", "mcl_farming:melontige_1", "nodes", "mcl_farming:melontige_"..i)
	end
end
