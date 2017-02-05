minetest.register_craftitem("mcl_farming:pumpkin_seed", {
	description = "Pumpkin Seeds",
	stack_max = 64,
	inventory_image = "farming_pumpkin_seed.png",
	groups = { craftitem=1 },
	on_place = function(itemstack, placer, pointed_thing)
		local above = minetest.get_node(pointed_thing.above)
		if above.name == "air" then
			above.name = "mcl_farming:pumpkin_1"
			minetest.set_node(pointed_thing.above, above)
			itemstack:take_item(1)
			return itemstack
		end
	end
})

minetest.register_node("mcl_farming:pumpkin_1", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	sunlight_propagates = true,
	drop = "",
	tiles = {"farming_tige_1.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.5+6/16, 0.5}
		},
	},
	groups = {snappy=3, not_in_creative_inventory=1 ,dig_by_water=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

minetest.register_node("mcl_farming:pumpkin_2", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	sunlight_propagates = true,
	drop = "",
	tiles = {"farming_tige_2.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.5+9/16, 0.5}
		},
	},
	groups = {snappy=3, not_in_creative_inventory=1 ,dig_by_water=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
})


minetest.register_node("mcl_farming:pumpkin_face", {
	description = "Pumpkin",
	stack_max = 64,
	paramtype2 = "facedir",
	tiles = {"farming_pumpkin_top.png", "farming_pumpkin_top.png", "farming_pumpkin_side.png", "farming_pumpkin_side.png", "farming_pumpkin_side.png", "farming_pumpkin_face.png"},
	groups = {choppy=2, oddly_breakable_by_hand=2, building_block=1},
	after_dig_node = function(pos, oldnode, oldmetadata, user)
		local have_change = 0
		for x=-1,1 do
				local p = {x=pos.x+x, y=pos.y, z=pos.z}
				local n = minetest.get_node(p)
			if string.find(n.name, "pumpkintige_linked_") and have_change == 0 then
					have_change = 1
					minetest.add_node(p, {name="mcl_farming:pumpkintige_unconnect"})
			end
		end
		if have_change == 0 then
			for z=-1,1 do
				local p = {x=pos.x, y=pos.y, z=pos.z+z}
				local n = minetest.get_node(p)
				if string.find(n.name, "pumpkintige_linked_") and have_change == 0 then
						have_change = 1
						minetest.add_node(p, {name="mcl_farming:pumpkintige_unconnect"})
				end
			end
		end
	end,
	sounds = mcl_core.node_sound_wood_defaults(),
})

minetest.register_node("mcl_farming:pumpkintige_unconnect", {
	paramtype = "light",
	walkable = false,
	sunlight_propagates = true,
	drop = "",
	drawtype = "plantlike",
	tiles = {"farming_tige_end.png"},
	groups = {snappy=3, not_in_creative_inventory=1 ,dig_by_water=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
})


minetest.register_node("mcl_farming:pumpkintige_linked_r", {
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	drop = "",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "wallmounted",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0, 0.5, 0.5, 0}, -- NodeBox1
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, -0.2, 0.2, 0.2, 0.2}
	},
	tiles = {
		"farming_tige_connnect.png", --top
		"farming_tige_connnect.png", -- bottom
		"farming_tige_connnect.png", -- right
		"farming_tige_connnect.png", -- left
		"farming_tige_connnect.png", -- back
		"farming_tige_connnect.png^[transformFX90" --front
	},
	groups = {snappy=3, not_in_creative_inventory=1 ,dig_by_water=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

minetest.register_node("mcl_farming:pumpkintige_linked_l", {
	paramtype = "light",
	walkable = false,
	sunlight_propagates = true,
	drop = "",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "wallmounted",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0, 0.5, 0.5, 0}, -- NodeBox1
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, -0.2, 0.2, 0.2, 0.2}
	},
	tiles = {
		"farming_tige_connnect.png", --top
		"farming_tige_connnect.png", -- bottom
		"farming_tige_connnect.png", -- right
		"farming_tige_connnect.png", -- left
		"farming_tige_connnect.png^[transformFX90", -- back
		"farming_tige_connnect.png" --front
	},
	groups = {snappy=3, not_in_creative_inventory=1 ,dig_by_water=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

minetest.register_node("mcl_farming:pumpkintige_linked_t", {
	paramtype = "light",
	walkable = false,
	sunlight_propagates = true,
	drop = "",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "wallmounted",
	node_box = {
		type = "fixed",
		fixed = {
			{0, -0.5, -0.5, 0, 0.5, 0.5}, -- NodeBox1
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, -0.2, 0.2, 0.2, 0.2}
	},
	tiles = {
		"farming_tige_connnect.png", --top
		"farming_tige_connnect.png", -- bottom
		"farming_tige_connnect.png^[transformFX90", -- right
		"farming_tige_connnect.png", -- left
		"farming_tige_connnect.png", -- back
		"farming_tige_connnect.png" --front
	},
	groups = {snappy=3, not_in_creative_inventory=1 ,dig_by_water=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

minetest.register_node("mcl_farming:pumpkintige_linked_b", {
	paramtype = "light",
	walkable = false,
	sunlight_propagates = true,
	drop = "",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "wallmounted",
	node_box = {
		type = "fixed",
		fixed = {
			{0, -0.5, -0.5, 0, 0.5, 0.5}, -- NodeBox1
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, -0.2, 0.2, 0.2, 0.2}
	},
	tiles = {
		"farming_tige_connnect.png", --top
		"farming_tige_connnect.png", -- bottom
		"farming_tige_connnect.png", -- right
		"farming_tige_connnect.png^[transformFX90", -- left
		"farming_tige_connnect.png", -- back
		"farming_tige_connnect.png" --front
	},
	groups = {snappy=3, not_in_creative_inventory=1 ,dig_by_water=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

mcl_farming:add_plant("mcl_farming:pumpkintige_unconnect", {"mcl_farming:pumpkin_1", "mcl_farming:pumpkin_2"}, 80, 20)


minetest.register_abm({
	nodenames = {"mcl_farming:pumpkintige_unconnect"},
	neighbors = {"air"},
	interval = 30,
	chance = 15,
	action = function(pos)
	local have_change = 0
	local newpos = {x=pos.x, y=pos.y, z=pos.z}
	local light = minetest.get_node_light(pos)
	if light or light > 10 then
		for x=-1,1 do
				local p = {x=pos.x+x, y=pos.y-1, z=pos.z}
				newpos = {x=pos.x+x, y=pos.y, z=pos.z}
				local n = minetest.get_node(p)
				local nod = minetest.get_node(newpos)
			if n.name=="mcl_core:dirt_with_grass" and nod.name=="air" and have_change == 0 
			or n.name=="mcl_core:dirt" and nod.name=="air" and have_change == 0
			or string.find(n.name, "mcl_farming:soil") and nod.name=="air" and have_change == 0 then
					have_change = 1
					minetest.add_node(newpos, {name="mcl_farming:pumpkin_face"})
					if x == 1 then
						minetest.add_node(pos, {name="mcl_farming:pumpkintige_linked_r" })
					else
						minetest.add_node(pos, {name="mcl_farming:pumpkintige_linked_l"})
					end
			end
		end
		if have_change == 0 then
			for z=-1,1 do
					local p = {x=pos.x, y=pos.y-1, z=pos.z+z}
					newpos = {x=pos.x, y=pos.y, z=pos.z+z}
					local n = minetest.get_node(p)
					local nod2 = minetest.get_node(newpos)
					if n.name=="mcl_core:dirt_with_grass" and nod2.name=="air" and have_change == 0 
					or n.name=="mcl_core:dirt" and nod2.name=="air" and have_change == 0 
					or string.find(n.name, "mcl_farming:soil") and nod2.name=="air" and have_change == 0 then
						have_change = 1
						minetest.add_node(newpos, {name="mcl_farming:pumpkin_face"})
					if z == 1 then
						minetest.add_node(pos, {name="mcl_farming:pumpkintige_linked_t" })
					else
						minetest.add_node(pos, {name="mcl_farming:pumpkintige_linked_b" })
					end
					end
			end
		end
	end
	end,
})



minetest.register_node("mcl_farming:pumpkin_face_light", {
	description = "Jack o'Lantern",
	stack_max = 64,
	paramtype2 = "facedir",
	-- Real light level: 15 (Minetest caps at 14)
	light_source = 14,
	tiles = {"farming_pumpkin_top.png", "farming_pumpkin_top.png", "farming_pumpkin_side.png", "farming_pumpkin_side.png", "farming_pumpkin_side.png", "farming_pumpkin_face_light.png"},
	groups = {choppy=2, oddly_breakable_by_hand=2, building_block=1},
	sounds = mcl_core.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "mcl_farming:pumpkin_face_light",
	recipe = {{"mcl_farming:pumpkin_face"},
	{"torches:torch"}}
})

minetest.register_craft({
	output = "mcl_farming:pumpkin_seed 4",
	recipe = {{"mcl_farming:pumpkin_face"}}
})

minetest.register_craftitem("mcl_farming:pumpkin_pie", {
	description = "Pumpkin Pie",
	stack_max = 64,
	inventory_image = "mcl_farming_pumpkin_pie.png",
	wield_image = "mcl_farming_pumpkin_pie.png",
	on_use = minetest.item_eat(8),
	groups = { food = 2, eatable = 8 },
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_farming:pumpkin_pie",
	recipe = {"mcl_farming:pumpkin_face", "mcl_core:sugar", "mcl_throwing:egg"},
})
