local S = ...

local woods = {
	["oak"] = {
		item = {
			description = S("Oak Boat"),
			inventory_image = "mcl_boats_oak_boat.png",
			_doc_items_create_entry = true,
		},
		item_chest = {
			description = S("Oak Chest Boat"),
			inventory_image = "mcl_boats_oak_chest_boat.png",
		},
		entity_texture = "mcl_boats_texture_oak_boat.png",
		material = "mcl_core:wood",
	},
	["acacia"] = {
		item = {
			description = S("Acacia Boat"),
			inventory_image = "mcl_boats_acacia_boat.png",
		},
		item_chest = {
			description = S("Acacia Chest Boat"),
			inventory_image = "mcl_boats_acacia_chest_boat.png",
		},
		entity_texture = "mcl_boats_texture_acacia_boat.png",
		material = "mcl_core:acaciawood",
	},
	["birch"] = {
		item = {
			description = S("Birch Boat"),
			inventory_image = "mcl_boats_birch_boat.png",
		},
		item_chest = {
			description = S("Birch Chest Boat"),
			inventory_image = "mcl_boats_birch_chest_boat.png",
		},
		entity_texture = "mcl_boats_texture_birch_boat.png",
		material = "mcl_core:birchwood",
	},
	["dark_oak"] = {
		item = {
			description = S("Dark Oak Boat"),
			inventory_image = "mcl_boats_dark_oak_boat.png",
		},
		item_chest = {
			description = S("Dark Oak Chest Boat"),
			inventory_image = "mcl_boats_dark_oak_chest_boat.png",
		},
		entity_texture = "mcl_boats_texture_dark_oak_boat.png",
		material = "mcl_core:darkwood",
	},
	["jungle"] = {
		item = {
			description = S("Jungle Boat"),
			inventory_image = "mcl_boats_jungle_boat.png",
		},
		item_chest = {
			description = S("Jungle Chest Boat"),
			inventory_image = "mcl_boats_jungle_chest_boat.png",
		},
		entity_texture = "mcl_boats_texture_jungle_boat.png",
		material = "mcl_core:junglewood",
	},
	["mangrove"] = {
		item = {
			description = S("Mangrove Boat"),
			inventory_image = "mcl_boats_mangrove_boat.png",
		},
		item_chest = {
			description = S("Mangrove Chest Boat"),
			inventory_image = "mcl_boats_mangrove_chest_boat.png",
		},
		entity_texture = "mcl_boats_texture_mangrove_boat.png",
		material = "mcl_mangrove:mangrove_wood",
	},
	["cherry"] = {
		item = {
			description = S("Cherry Boat"),
			inventory_image = "mcl_boats_cherry_boat.png",
		},
		item_chest = {
			description = S("Cherry Chest Boat"),
			inventory_image = "mcl_boats_cherry_chest_boat.png",
		},
		entity_texture = "mcl_boats_texture_cherry_boat.png",
		material = "mcl_cherry_blossom:cherrywood",
	},
	["obsidian"] = {
		item = {
			description = S("Obsidian Boat"),
			inventory_image = "mcl_boats_obsidian_boat.png",
			groups = {wood_boat = 0},
		},
		entity = {_sinks = true},
		entity_texture = "mcl_boats_texture_obsidian_boat.png",
		material = "mcl_core:obsidian",
	},
}
for name, def in pairs(woods) do mcl_boats.register_boat("mcl_boats:boat_" .. name, def) end
