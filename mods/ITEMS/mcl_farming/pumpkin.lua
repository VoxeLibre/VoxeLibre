-- Seeds
minetest.register_craftitem("mcl_farming:pumpkin_seeds", {
	description = "Pumpkin Seeds",
	_doc_items_longdesc = "Grows into a pumpkin. Chickens like pumpkin seeds.",
	_doc_items_usagehelp = "Place the pumpkin seeds on farmland (which can be created with a hoe) to plant a pumpkin stem. Pumpkins grow in sunlight and grow faster on hydrated farmland. Rightclick an animal to feed it pumpkin seeds.",
	stack_max = 64,
	inventory_image = "farming_pumpkin_seed.png",
	groups = { craftitem=1 },
	on_place = function(itemstack, placer, pointed_thing)
		return mcl_farming:place_seed(itemstack, placer, pointed_thing, "mcl_farming:pumpkin_1")
	end
})

local stem_drop = {
	max_items = 1,
	-- FIXME: The probabilities are slightly off from the original.
	-- Update this drop list when the Minetest drop probability system
	-- is more powerful.
	items = {
		-- 1 seed: Approximation to 20/125 chance
		-- 20/125 = 0.16
		-- Approximation: 1/6 = ca. 0.166666666666667
		{ items = {"mcl_farming:pumpkin_seeds 1"}, rarity = 6 },

		-- 2 seeds: Approximation to 4/125 chance
		-- 4/125 = 0.032
		-- Approximation: 1/31 = ca. 0.032258064516129
		{ items = {"mcl_farming:pumpkin_seeds 2"}, rarity = 31 },

		-- 3 seeds: 1/125 chance
		{ items = {"mcl_farming:pumkin_seeds 3"}, rarity = 125 },
	},
}

-- Unconnected immature stem

for s=1,7 do
	local h = s / 8
	local doc = s == 1
	local longdesc, entry_name
	if doc then
		entry_name = "Premature Pumpkin Stem"
		longdesc = "Pumpkin stems grow on farmland in 8 stages. On hydrated farmland, the growth is a bit quicker. Mature pumpkin stems are able to grow pumpkins."
	end
	minetest.register_node("mcl_farming:pumpkin_"..s, {
		description = string.format("Premature Pumpkin Stem (Stage %d)", s),
		_doc_items_entry_name = entry_name,
		_doc_items_create_entry = doc,
		_doc_items_longdesc = longdesc,
		paramtype = "light",
		walkable = false,
		drawtype = "plantlike",
		sunlight_propagates = true,
		drop = stem_drop,
		tiles = {"mcl_farming_pumpkintige_"..s..".png"},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.15, -0.5, -0.15, 0.15, -0.5+h, 0.15}
			},
		},
		groups = {dig_immediate=3, not_in_creative_inventory=1, plant=1,attached_node=1, dig_by_water=1,destroy_by_lava_flow=1,},
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		_mcl_blast_resistance = 0,
	})
end

-- Full stem (not connected)
local stem_def = {
	description = "Mature Pumpkin Stem",
	_doc_items_longdesc = "A mature pumpkin stem attempts to grow a pumpkin at one of its four adjacent blocks. A pumpkin can only grow on top of farmland, dirt or a grass block. When a pumpkin is next to a pumpkin stem, the pumpkin stem immediately bends and connects to the pumpkin. A connected pumpkin stem can't grow another pumpkin. As soon all pumpkins around the stem have been removed, it loses the connection and is ready to grow another pumpkin.",
	tiles = {"mcl_farming_pumpkintige_8.png"},
}

-- Template for pumpkin
local pumpkin_base_def = {
	description = "Pumpkin",
	_doc_items_longdesc = "A pumpkin is a naturally occouring block from the grasslands and is remarkable for its strange face-like cavity, which is developed naturally. Pumpkins are grown from pumpkin stems, which in turn are grown from pumpkin seeds.",
	stack_max = 64,
	paramtype2 = "facedir",
	tiles = {"farming_pumpkin_top.png", "farming_pumpkin_top.png", "farming_pumpkin_side.png", "farming_pumpkin_side.png", "farming_pumpkin_side.png", "farming_pumpkin_face.png"},
	groups = {handy=1,axey=1, plant=1,building_block=1, dig_by_piston=1},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 5,
	_mcl_hardness = 1,
}

-- Register stem growth
mcl_farming:add_plant("plant_pumpkin_stem", "mcl_farming:pumpkintige_unconnect", {"mcl_farming:pumpkin_1", "mcl_farming:pumpkin_2", "mcl_farming:pumpkin_3", "mcl_farming:pumpkin_4", "mcl_farming:pumpkin_5", "mcl_farming:pumpkin_6", "mcl_farming:pumpkin_7"}, 30, 5)

-- Register actual pumpkin, connected stems and stem-to-pumpkin growth
mcl_farming:add_gourd("mcl_farming:pumpkintige_unconnect", "mcl_farming:pumpkintige_linked", "mcl_farming:pumpkintige_unconnect", stem_def, stem_drop, "mcl_farming:pumpkin_face", pumpkin_base_def, 30, 15)



-- Jack o'Lantern
minetest.register_node("mcl_farming:pumpkin_face_light", {
	description = "Jack o'Lantern",
	_doc_items_longdesc = "A jack o'lantern is a traditional Halloween decoration made from a pumpkin. It glows brightly.",
	is_ground_content = false,
	stack_max = 64,
	paramtype2 = "facedir",
	-- Real light level: 15 (Minetest caps at 14)
	light_source = 14,
	tiles = {"farming_pumpkin_top.png", "farming_pumpkin_top.png", "farming_pumpkin_side.png", "farming_pumpkin_side.png", "farming_pumpkin_side.png", "farming_pumpkin_face_light.png"},
	groups = {handy=1,axey=1, building_block=1, dig_by_piston=1 },
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 5,
	_mcl_hardness = 1,
})

-- Crafting

minetest.register_craft({
	output = "mcl_farming:pumpkin_face_light",
	recipe = {{"mcl_farming:pumpkin_face"},
	{"mcl_torches:torch"}}
})

minetest.register_craft({
	output = "mcl_farming:pumpkin_seeds 4",
	recipe = {{"mcl_farming:pumpkin_face"}}
})

minetest.register_craftitem("mcl_farming:pumpkin_pie", {
	description = "Pumpkin Pie",
	_doc_items_longdesc = "A pumpkin pie is very filling and can be eaten for 8 hunger points.",
	stack_max = 64,
	inventory_image = "mcl_farming_pumpkin_pie.png",
	wield_image = "mcl_farming_pumpkin_pie.png",
	on_place = minetest.item_eat(8),
	on_secondary_use = minetest.item_eat(8),
	groups = { food = 2, eatable = 8 },
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_farming:pumpkin_pie",
	recipe = {"mcl_farming:pumpkin_face", "mcl_core:sugar", "mcl_throwing:egg"},
})

if minetest.get_modpath("doc") then
	for i=2,8 do
		doc.add_entry_alias("nodes", "mcl_farming:pumpkin_1", "nodes", "mcl_farming:pumpkin_"..i)
	end
end
