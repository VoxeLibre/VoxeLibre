-- ||||||||||||||||||||||||||||||||
-- ||||||||||| CAMPFIRES ||||||||||
-- ||||||||||||||||||||||||||||||||

-- TO-DO:
-- * Add Smoke Particles
-- * Add Spark Particles
-- * Add Cooking Meat
-- * Add Working Sounds

local S = minetest.get_translator(minetest.get_current_modname())

local campfires = {
	{ name = "Campfire", lightlevel = 14, techname = "campfire", damage = 1, drops = "mcl_core:charcoal_lump 2" },
	{ name = "Soul Campfire", lightlevel = 10, techname = "soul_campfire", damage = 2, drops = "mcl_blackstone:soul_soil" },
}

for _, campfire in pairs(campfires) do
-- Define Campfire
	minetest.register_node("mcl_campfires:" .. campfire.techname, {
		description = S(campfire.name),
		_tt_help = S("Cooks food and keeps bees happy."),
		_doc_items_longdesc = S("Campfires have multiple uses, including keeping bees happy, cooking raw meat and fish, and as a trap."),
		inventory_image = "mcl_campfires_" .. campfire.techname .. "_inv.png",
		drawtype = "mesh",
		mesh = "mcl_campfires_campfire.obj",
		tiles = {{name="mcl_campfires_log.png"},},
		use_texture_alpha = "clip",
		groups = { handy=1, axey=1, material_wood=1, not_in_creative_inventory=1, campfire=1, },
		paramtype = "light",
		paramtype2 = "facedir",
		on_rightclick = function (pos, node, player, itemstack, pointed_thing)
			if player:get_wielded_item():get_name() == "mcl_fire:flint_and_steel" then
				node.name = "mcl_campfires:" .. campfire.techname .. "_lit"
				minetest.set_node(pos, node)
			end
		end,
		drop = campfire.drops,
		_mcl_silk_touch_drop = {"mcl_campfires:" .. campfire.techname},
		mcl_sounds.node_sound_wood_defaults(),
		selection_box = {
			type = 'fixed',
			fixed = {-.5, -.5, -.5, .5, -.05, .5}, --left, bottom, front, right, top
		},
		collision_box = {
			type = 'fixed',
			fixed = {-.5, -.5, -.5, .5, -.05, .5},
		},
		_mcl_blast_resistance = 2,
		_mcl_hardness = 2,
	})

	--Define Lit Campfire
	minetest.register_node("mcl_campfires:" .. campfire.techname .. "_lit", {
		description = S(campfire.name),
		_tt_help = S("Cooks food and keeps bees happy."),
		_doc_items_longdesc = S("Campfires have multiple uses, including keeping bees happy, cooking raw meat and fish, and as a trap."),
		inventory_image = "mcl_campfires_" .. campfire.techname .. "_inv.png",
		drawtype = "mesh",
		mesh = "mcl_campfires_campfire_lit.obj",
		tiles = {{
			name="mcl_campfires_" .. campfire.techname .. "_fire.png",
			animation={
				type="vertical_frames",
				aspect_w=16,
				aspect_h=16,
				length=2.0
			}},
			{name="mcl_campfires_" .. campfire.techname .. "_log_lit.png",
			animation={
				type="vertical_frames",
				aspect_w=16,
				aspect_h=16,
				length=2.0
			}}
		},
		use_texture_alpha = "clip",
		groups = { handy=1, axey=1, material_wood=1, campfire=1, lit_campfire=1 },
		paramtype = "light",
		paramtype2 = "facedir",
		on_rightclick = function (pos, node, player, itemstack, pointed_thing)
			if player:get_wielded_item():get_name():find("shovel") then
				node.name = "mcl_campfires:" .. campfire.techname
				minetest.set_node(pos, node)
				minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
			end
		end,
		drop = campfire.drops,
		_mcl_silk_touch_drop = {"mcl_campfires:" .. campfire.techname .. "_lit"},
		light_source = campfire.lightlevel,
		mcl_sounds.node_sound_wood_defaults(),
		selection_box = {
			type = "fixed",
			fixed = {-.5, -.5, -.5, .5, -.05, .5}, --left, bottom, front, right, top
		},
		collision_box = {
			type = "fixed",
			fixed = {-.5, -.5, -.5, .5, -.05, .5},
		},
		_mcl_blast_resistance = 2,
		_mcl_hardness = 2,
		damage_per_second = campfire.damage,
	})
end

minetest.register_craft({
	output = "mcl_campfires:campfire_lit",
	recipe = {
		{ "", "mcl_core:stick", "" },
		{ "mcl_core:stick", "group:coal", "mcl_core:stick" },
		{ "group:tree", "group:tree", "group:tree" },
	}
})

minetest.register_craft({
	output = "mcl_campfires:soul_campfire_lit",
	recipe = {
		{ "", "mcl_core:stick", "" },
		{ "mcl_core:stick", "group:soul_block", "mcl_core:stick" },
		{ "group:tree", "group:tree", "group:tree" },
	}
})

local function burn_in_campfire(obj)
	local p = obj:get_pos()
	if p then
		local n = minetest.find_node_near(p,0.4,{"group:lit_campfire"},true)
		if n then
			mcl_burning.set_on_fire(obj, 5)
		end
	end
end

local etime = 0
minetest.register_globalstep(function(dtime)
	etime = dtime + etime
	if etime < 0.5 then return end
	etime = 0
	for _,pl in pairs(minetest.get_connected_players()) do
		burn_in_campfire(pl)
	end
	for _,ent in pairs(minetest.luaentities) do
		if ent.is_mob then
			burn_in_campfire(ent.object)
		end
	end
end)
