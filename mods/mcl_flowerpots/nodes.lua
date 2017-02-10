
local flowers = {
	{"dandelion", "mcl_flowers:dandelion", "Dandelion Flower Pot"},
	{"poppy", "mcl_flowers:poppy", "Poppy Floer Pot"},
	{"blue_orchid", "mcl_flowers:blue_orchid", "Blue Orchid Flower Pot"},
	{"allium", "mcl_flowers:allium", "Allium Flower Pot"},
	{"azure_bluet", "mcl_flowers:azure_bluet", "Azure Bluet Flower Pot"},
	{"tulip_red", "mcl_flowers:tulip_red", "Red Tulip Flower Pot"},
	{"tulip_pink", "mcl_flowers:tulip_pink", "Pink Tulip Flower Pot"},
	{"tulip_white", "mcl_flowers:tulip_white", "White Tulip Flower Pot"},
	{"tulip_orange", "mcl_flowers:tulip_orange", "Orange Tulip Flower Pot"},
	{"oxeye_daisy", "mcl_flowers:oxeye_daisy", "Oxeye Daisy Flower Pot"},
	{"mushroom_brown", "mcl_farming:mushroom_brown", "Brown Mushroom Flower Pot"},
	{"mushroom_red", "mcl_farming:mushroom_red", "Red Mushroom Flower Pot"},
	{"dry_shrub", "mcl_core:dry_shrub", "Dead Bush Flower Pot"},
	{"sapling", "mcl_core:sapling", "Oak Sapling Flower Pot"},
	{"acaciasapling", "mcl_core:acaciasapling", "Acacia Sapling Flower Pot"},
	{"junglesapling", "mcl_core:junglesapling", "Jungle Sapling Flower Pot"},
	{"darksapling", "mcl_core:darksapling", "Dark Oak Sapling Flower Pot"},
	{"sprucesapling", "mcl_core:sprucesapling", "Spruce Sapling Flower Pot"},
	{"birchsapling", "mcl_core:birchsapling", "Birch Sapling Flower Pot"},
	{"dry_shrub", "mcl_core:dry_shrub", "Dead Bush Flower Pot"},
	{"fern", "mcl_flowers:fern", "Fern Flower Pot"},
}

local cubes = {
	{"cactus", "mcl_core:cactus", "Cactus Flower Pot"},
}

minetest.register_node("mcl_flowerpots:flower_pot", {
	description = "Flower Pot",
	drawtype = "mesh",
	mesh = "flowerpot.obj",
	tiles = {
		"mcl_flowerpots_flowerpot.png",
	},
	visual_scale = 0.5,
	wield_image = "mcl_flowerpots_flowerpot_inventory.png",
	wield_scale = {x=1.0, y=1.0, z=1.0},
	paramtype = "light",
	selection_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, -0.2, 0.2, -0.1, 0.2}
	},
	collision_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, -0.2, 0.2, -0.1, 0.2}
	},
	inventory_image = "mcl_flowerpots_flowerpot_inventory.png",
	groups = {dig_immediate=3,deco_block=1,attached_node=1},
	sounds = mcl_core.node_sound_stone_defaults(),
	on_rightclick = function(pos, node, clicker, itemstack)
		local item = clicker:get_wielded_item():get_name()
		for _, row in ipairs(flowers) do
			local flower = row[1]
			local flower_node = row[2]
			if item == flower_node then
				minetest.set_node(pos, {name="mcl_flowerpots:flower_pot_"..flower})
				itemstack:take_item()
			end
		end
		for _, row in ipairs(cubes) do
			local flower = row[1]
			local flower_node = row[2]
			if item == flower_node then
				minetest.set_node(pos, {name="mcl_flowerpots:flower_pot_"..flower})
				itemstack:take_item()
			end
		end
	end,
})

minetest.register_craft({
	output = 'mcl_flowerpots:flower_pot',
	recipe = {
		{'mcl_core:brick', '', 'mcl_core:brick'},
		{'', 'mcl_core:brick', ''},
		{'', '', ''},
	}
})

for _, row in ipairs(flowers) do
local flower = row[1]
local flower_node = row[2]
local desc = row[3]
local texture = minetest.registered_nodes[flower_node]["tiles"]
minetest.register_node("mcl_flowerpots:flower_pot_"..flower, {
	description = desc,
	drawtype = "mesh",
	mesh = "flowerpot.obj",
	tiles = {
		"[combine:64x64:0,0=mcl_flowerpots_flowerpot.png:0,0="..texture[1],
	},
	visual_scale = 0.5,
	wield_scale = {x=1.0, y=1.0, z=1.0},
	paramtype = "light",
	selection_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, -0.2, 0.2, -0.1, 0.2}
	},
	collision_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, -0.2, 0.2, -0.1, 0.2}
	},
	groups = {dig_immediate=3, attached_node=1,not_in_creative_inventory=1},
	sounds = mcl_core.node_sound_stone_defaults(),
	on_rightclick = function(pos, item, clicker)
		minetest.add_item({x=pos.x, y=pos.y+0.5, z=pos.z}, flower_node)
		minetest.set_node(pos, {name="mcl_flowerpots:flower_pot"})
	end,
	drop = {
		items = {
			{ items = { "mcl_flowerpots:flower_pot", flower_node } }
		}
	},
})
end

for _, row in ipairs(cubes) do
local flower = row[1]
local flower_node = row[2]
local desc = row[3]
minetest.register_node("mcl_flowerpots:flower_pot_"..flower, {
	description = desc,
	drawtype = "mesh",
	mesh = "flowerpot_with_long_cube.obj",
	tiles = {
		"mcl_flowerpots_"..flower..".png",
	},
	visual_scale = 0.5,
	wield_scale = {x=1.0, y=1.0, z=1.0},
	paramtype = "light",
	selection_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, -0.2, 0.2, -0.1, 0.2}
	},
	collision_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, -0.2, 0.2, -0.1, 0.2}
	},
	groups = {dig_immediate=3, attached_node=1,not_in_creative_inventory=1},
	sounds = mcl_core.node_sound_stone_defaults(),
	on_rightclick = function(pos, item, clicker)
		minetest.add_item({x=pos.x, y=pos.y+0.5, z=pos.z}, flower_node)
		minetest.set_node(pos, {name="mcl_flowerpots:flower_pot"})
	end,
	drop = {
		items = {
			{ items = { "mcl_flowerpots:flower_pot", flower_node } }
		}
	},
})
end
