local S = core.get_translator(core.get_current_modname())

local planton = {"mcl_core:dirt_with_grass", "mcl_core:dirt", "mcl_core:podzol", "mcl_core:coarse_dirt", "mcl_farming:soil", "mcl_farming:soil_wet", "mcl_moss:moss"}

for i=0, 3 do
	local texture = "mcl_farming_sweet_berry_bush_" .. i .. ".png"
	local node_name = "mcl_farming:sweet_berry_bush_" .. i
	local groups = {sweet_berry=1, dig_immediate=3, not_in_creative_inventory=1,plant=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1, flammable=3, fire_encouragement=60, fire_flammability=20, compostability=30}
	if i > 0 then
		groups.sweet_berry_thorny = 1
	end
	local berries_to_drop = (i >= 2) and {i - 1, i} or nil
	local function do_berry_drop(pos)
		if not berries_to_drop then return false end

		for _=1, berries_to_drop[math.random(2)] do
			core.add_item(pos, "mcl_farming:sweet_berry")
		end
		core.swap_node(pos, {name = "mcl_farming:sweet_berry_bush_1"})
		return true
	end

	local on_bonemealing = nil
	if i ~= 3 then
		on_bonemealing = function(_, _, pointed_thing)
			local pos = pointed_thing.under
			local node = core.get_node(pos)
			return mcl_farming:grow_plant("plant_sweet_berry_bush", pos, node, 1, true)
		end
	else
		on_bonemealing = function(_, _, pointed_thing)
			do_berry_drop(pointed_thing.under)
		end
	end

	core.register_node(node_name, {
		drawtype = "plantlike",
		tiles = {texture},
		description = S("Sweet Berry Bush (Stage @1)", i),
		paramtype = "light",
		sunlight_propagates = true,
		paramtype2 = "meshoptions",
		place_param2 = 3,
		liquid_viscosity = 7,
		liquidtype = "source",
		liquid_alternative_flowing = node_name,
		liquid_alternative_source = node_name,
		liquid_renewable = false,
		liquid_range = 0,
		walkable = false,
		-- Dont even create a table if no berries are dropped.
		drop = berries_to_drop and {
			max_items = 1,
			items = {
				{ items = {"mcl_farming:sweet_berry " .. berries_to_drop[1] }, rarity = 2 },
				{ items = {"mcl_farming:sweet_berry " .. berries_to_drop[2] } }
			}
		} or "",
		selection_box = {
			type = "fixed",
			fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, (-0.30 + (i*0.25)), 6 / 16},
		},
		inventory_image = texture,
		wield_image = texture,
		groups = groups,
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		_mcl_blast_resistance = 0,
		_mcl_hardness = 0,
		_on_bone_meal = on_bonemealing,
		on_rightclick = function(pos, _, clicker, itemstack, pointed_thing)
			local pn = clicker:get_player_name()
			if clicker:is_player() and core.is_protected(pos, pn) then
				core.record_protection_violation(pos, pn)
				return itemstack
			end

			if do_berry_drop(pos) then return itemstack end

			-- Use bonemeal
			if mcl_bone_meal and clicker:get_wielded_item():get_name() == "mcl_bone_meal:bone_meal" then
				return mcl_bone_meal.use_bone_meal(itemstack, clicker, pointed_thing)
			end
			return itemstack
		end,
	})
	core.register_alias("mcl_sweet_berry:sweet_berry_bush_" .. i, node_name)
end

core.register_craftitem("mcl_farming:sweet_berry", {
	description = S("Sweet Berry"),
	inventory_image = "mcl_farming_sweet_berry.png",
	_mcl_saturation = 0.4,
	groups = { food = 2, eatable = 2, compostability=30 },
	on_secondary_use = core.item_eat(2),
	on_place = function(itemstack, placer, pointed_thing)
		local pn = placer:get_player_name()
		if placer:is_player() and core.is_protected(pointed_thing.above, pn or "") then
			core.record_protection_violation(pointed_thing.above, pn)
			return itemstack
		end
		if pointed_thing.type == "node" and
				table.indexof(planton, core.get_node(pointed_thing.under).name) ~= -1 and
				pointed_thing.above.y > pointed_thing.under.y and
				core.get_node(pointed_thing.above).name == "air" then
			core.set_node(pointed_thing.above, {name="mcl_farming:sweet_berry_bush_0"})
			if not core.is_creative_enabled(placer:get_player_name()) then
				itemstack:take_item()
			end
			return itemstack
		end
		return core.do_item_eat(2, nil, itemstack, placer, pointed_thing)
	end,
})
core.register_alias("mcl_sweet_berry:sweet_berry", "mcl_farming:sweet_berry")

-- TODO: Find proper interval and chance values for sweet berry bushes. Current interval and chance values are copied from mcl_farming:beetroot which has similar growth stages, 2/3rd of the default.
mcl_farming:add_plant("plant_sweet_berry_bush", "mcl_farming:sweet_berry_bush_3", {"mcl_farming:sweet_berry_bush_0", "mcl_farming:sweet_berry_bush_1", "mcl_farming:sweet_berry_bush_2"}, 8.7019, 35)

local function berry_damage_check(obj)
	local p = obj:get_pos()
	if not p then return end
	if not core.find_node_near(p,0.4,{"group:sweet_berry_thorny"},true) then return end
	local v = obj:get_velocity()
	if math.abs(v.x) < 0.1 and math.abs(v.y) < 0.1 and math.abs(v.z) < 0.1 then return end

	mcl_util.deal_damage(obj, 0.5, {type = "sweet_berry"})
end

local etime = 0
core.register_globalstep(function(dtime)
	etime = dtime + etime
	if etime < 0.5 then return end
	etime = 0
	for _,pl in pairs(core.get_connected_players()) do
		berry_damage_check(pl)
	end
	for _,ent in pairs(core.luaentities) do
		if ent.is_mob then
			berry_damage_check(ent.object)
		end
	end
end)
