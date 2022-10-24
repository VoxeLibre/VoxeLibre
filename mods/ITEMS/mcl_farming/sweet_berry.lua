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
		liquid_viscosity = 15,
		liquidtype = "source",
		liquid_alternative_flowing = node_name,
		liquid_alternative_source = node_name,
		liquid_renewable = false,
		liquid_range = 0,
		walkable = false,
		drop = (i>=2) and ("mcl_farming:sweet_berry" .. (i==3 and " 3" or "")) or "",
		selection_box = {
			type = "fixed",
			fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, (-0.30 + (i*0.25)), 6 / 16},
		},
		inventory_image = texture,
		wield_image = texture,
		groups = {sweet_berry=1, dig_immediate=3, not_in_creative_inventory=1,plant=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1, flammable=3, fire_encouragement=60, fire_flammability=20},
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

-- TODO: Find proper interval and chance values for sweet berry bushes. Current interval and chance values are copied from mcl_farming:beetroot which has similar growth stages.
mcl_farming:add_plant("plant_sweet_berry_bush", "mcl_farming:sweet_berry_bush_3", {"mcl_farming:sweet_berry_bush_0", "mcl_farming:sweet_berry_bush_1", "mcl_farming:sweet_berry_bush_2"}, 68, 3)

local function berry_damage_check(obj)
	local p = obj:get_pos()
	if not p then return end
	if not minetest.find_node_near(p,0.4,{"group:sweet_berry"},true) then return end
	local v = obj:get_velocity()
	if v.x < 0.1 and v.y < 0.1 and v.z < 0.1 then return end

	mcl_util.deal_damage(obj, 0.5, {type = "sweet_berry"})
end

local etime = 0
minetest.register_globalstep(function(dtime)
	etime = dtime + etime
	if etime < 0.5 then return end
	etime = 0
	for _,pl in pairs(minetest.get_connected_players()) do
		berry_damage_check(pl)
	end
	for _,ent in pairs(minetest.luaentities) do
		if ent.is_mob then
			berry_damage_check(ent.object)
		end
	end
end)
