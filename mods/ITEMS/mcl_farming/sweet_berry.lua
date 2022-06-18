local S = minetest.get_translator(minetest.get_current_modname())

for i=0, 3 do
	local texture = "mcl_farming_sweet_berry_bush_" .. i .. ".png"
	local node_name = "mcl_farming:sweet_berry_bush_" .. i
	minetest.register_node(node_name, {
		drawtype = "plantlike",
		tiles = {texture},
		description = S("Sweet Berry Bush (Stage @1)", i),
		paramtype = "light",
		sunlight_propagates = true,
		paramtype2 = "meshoptions",
		place_param2 = 3,
		walkable = false,
		drop = (i>=2) and ("mcl_farming:sweet_berry" .. (i==3 and " 3" or "")) or "",
		selection_box = {
			type = "fixed",
			fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, 0.5, 6 / 16},
		},
		inventory_image = texture,
		wield_image = texture,
		groups = {dig_immediate=3, not_in_creative_inventory=1,plant=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1},
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		_mcl_blast_resistance = 0,
	})
	minetest.register_alias("mcl_sweet_berry:sweet_berry_bush_" .. i, node_name)
end

minetest.register_craftitem("mcl_farming:sweet_berry", {
	description = S("Sweet Berry"),
	inventory_image = "mcl_farming_sweet_berry.png",
	_mcl_saturation = 0.2,
	stack_max = 64,
	groups = { food = 2, eatable = 1, compostability=30 },
	on_secondary_use = minetest.item_eat(1),
	on_place = function(itemstack, placer, pointed_thing)
		local new = mcl_farming:place_seed(itemstack, placer, pointed_thing, "mcl_sweet_berry:sweet_berry_bush_0")
		if new then
			return new
		else
			return minetest.do_item_eat(1, nil, itemstack, placer, pointed_thing)
		end
	end,
})
minetest.register_alias("mcl_sweet_berry:sweet_berry", "mcl_farming:sweet_berry")

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_core:dirt_with_grass"},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.001,
		spread = {x = 100, y = 100, z = 100},
		seed = 354,
		octaves = 1,
		persist = 0.5,
		lacunarity = 1.0,
		flags = "absvalue"
	},
	biomes = {"Taiga","Forest"},
	y_max = mcl_vars.mg_overworld_max,
	y_min = 2,
	decoration = "mcl_sweet_berry:sweet_berry_bush_3"
})

-- TODO: Find proper interval and chance values for sweet berry bushes. Current interval and chance values are copied from mcl_farming:beetroot which has similar growth stages.
mcl_farming:add_plant("plant_sweet_berry_bush", "mcl_farming:sweet_berry_bush_3", {"mcl_farming:sweet_berry_bush_0", "mcl_farming:sweet_berry_bush_1", "mcl_farming:sweet_berry_bush_2"}, 68, 3)