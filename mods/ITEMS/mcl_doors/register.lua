local S = minetest.get_translator(minetest.get_current_modname())

local function table_merge(tbl, ...)
	local t = table.copy(tbl)
	for _, to in ipairs{...} do
		for k,v in pairs(to) do
			if type(t[k]) == "table" and type(v) == "table" then
				t[k] = table_merge(t[k], v)
			else
				t[k] = v
			end
		end
	end
	return t
end

local tpl_wdoor = {
	_doc_items_longdesc = S("Wooden doors are 2-block high barriers which can be opened or closed by hand and by a redstone signal."),
	_doc_items_usagehelp = S("To open or close a wooden door, rightclick it or supply its lower half with a redstone signal."),
	_mcl_hardness = 3,
	_mcl_blast_resistance = 3,
}

local tpl_wtrapdoor = {
	_doc_items_longdesc = S("Wooden trapdoors are horizontal barriers which can be opened and closed by hand or a redstone signal. They occupy the upper or lower part of a block, depending on how they have been placed. When open, they can be climbed like a ladder."),
	_doc_items_usagehelp = S("To open or close the trapdoor, rightclick it or send a redstone signal to it."),
	_mcl_hardness = 3,
	_mcl_blast_resistance = 3,
}

local woods = {
	oak = {
		_door = {
			description = S("Oak Door"),
			inventory_image = "doors_item_wood.png",
			tiles_bottom = "mcl_doors_door_wood_lower.png",
			tiles_top = "mcl_doors_door_wood_upper.png",
		},
		_trapdoor = {
			description = S("Oak Trapdoor"),
			wield_image = "doors_trapdoor.png",
			tile_front = "doors_trapdoor.png",
			tile_side = "doors_trapdoor_side.png",
		},
	},
	dark_oak = {
		_door = {
			description = S("Dark Oak Door"),
			inventory_image = "mcl_doors_door_dark_oak.png",
			tiles_bottom = "mcl_doors_door_dark_oak_lower.png",
			tiles_top = "mcl_doors_door_dark_oak_upper.png",
		},
		_trapdoor = {
			description = S("Dark Oak Trapdoor"),
			wield_image = "mcl_doors_trapdoor_dark_oak.png",
			tile_front = "mcl_doors_trapdoor_dark_oak.png",
			tile_side = "mcl_doors_trapdoor_dark_oak_side.png",
		},
	},
	acacia = {
		_door = {
			description = S("Acacia Door"),
			inventory_image = "mcl_doors_door_acacia.png",
			tiles_bottom = "mcl_doors_door_acacia_lower.png",
			tiles_top = "mcl_doors_door_acacia_upper.png",
		},
		_trapdoor = {
			description = S("Acacia Trapdoor"),
			wield_image = "mcl_doors_trapdoor_acacia.png",
			tile_front = "mcl_doors_trapdoor_acacia.png",
			tile_side = "mcl_doors_trapdoor_acacia_side.png",
		},
	},
	birch = {
		_door = {
			description = S("Birch Door"),
			inventory_image = "mcl_doors_door_birch.png",
			tiles_bottom = "mcl_doors_door_birch_lower.png",
			tiles_top = "mcl_doors_door_birch_upper.png",
		},
		_trapdoor = {
			description = S("Birch Trapdoor"),
			wield_image = "mcl_doors_trapdoor_birch.png",
			tile_front = "mcl_doors_trapdoor_birch.png",
			tile_side = "mcl_doors_trapdoor_birch_side.png",
		},
	},
	jungle = {
		_door = {
			description = S("Jungle Door"),
			inventory_image = "mcl_doors_door_jungle.png",
			tiles_bottom = "mcl_doors_door_jungle_lower.png",
			tiles_top = "mcl_doors_door_jungle_upper.png",
		},
		_trapdoor = {
			description = S("Jungle Trapdoor"),
			wield_image = "mcl_doors_trapdoor_jungle.png",
			tile_front = "mcl_doors_trapdoor_jungle.png",
			tile_side = "mcl_doors_trapdoor_jungle_side.png",
		},
	},
	spruce = {
		_door = {
			description = S("Spruce Door"),
			inventory_image = "mcl_doors_door_spruce.png",
			tiles_bottom = "mcl_doors_door_spruce_lower.png",
			tiles_top = "mcl_doors_door_spruce_upper.png",
		},
		_trapdoor = {
			description = S("Spruce Trapdoor"),
			wield_image = "mcl_doors_trapdoor_spruce.png",
			tile_front = "mcl_doors_trapdoor_spruce.png",
			tile_side = "mcl_doors_trapdoor_spruce_side.png",
		},
	},
}

vl_trees.register_on_woods_added(function(name, def)
	local pname = def.planks
	local pdef = core.registered_nodes[pname]
	local groups = table.copy(pdef.groups)
	groups.wood = nil
	groups.building_block = nil
	groups.flammable = -1

	local stub = def.__modname .. ":"

	if def._door then
		local dname = stub .. "door_" .. name

		mcl_doors:register_door(dname, table_merge(tpl_wdoor, {
			groups = groups,
			sounds = pdef.sounds,
		}, def._door))

		core.register_craft({
			output = dname .. " 3",
			recipe = {
				{pname, pname},
				{pname, pname},
				{pname, pname}
			}
		})

		core.register_craft({
			type = "fuel",
			recipe = dname,
			burntime = 10,
		})
	end

	if def._trapdoor then
		local tname = stub .. "trapdoor_" .. name

		mcl_doors:register_trapdoor(tname, table_merge(tpl_wtrapdoor, {
			groups = table_merge(groups, {mesecon_effector = 1}),
			sounds = pdef.sounds,
		}, def._trapdoor))

		core.register_craft({
			output = tname,
			recipe = {
				{pname, pname, pname},
				{pname, pname, pname},
			}
		})

		core.register_craft({
			type = "fuel",
			recipe = tname,
			burntime = 15,
		})
	end
end, woods)

--- Iron Door ---
mcl_doors:register_door("mcl_doors:iron_door", {
	description = S("Iron Door"),
	_doc_items_longdesc = S("Iron doors are 2-block high barriers which can only be opened or closed by a redstone signal, but not by hand."),
	_doc_items_usagehelp = S("To open or close an iron door, supply its lower half with a redstone signal."),
	inventory_image = "doors_item_steel.png",
	groups = {pickaxey=1, mesecon_effector_on=1},
	_mcl_hardness = 5,
	_mcl_blast_resistance = 5,
	tiles_bottom = "mcl_doors_door_iron_lower.png",
	tiles_top = "mcl_doors_door_iron_upper.png",
	sounds = mcl_sounds.node_sound_metal_defaults(),
	sound_open = "doors_steel_door_open",
	sound_close = "doors_steel_door_close",

	only_redstone_can_open = true,
})

minetest.register_craft({
	output = "mcl_doors:iron_door 3",
	recipe = {
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"}
	}
})

mcl_doors:register_trapdoor("mcl_doors:iron_trapdoor", {
	description = S("Iron Trapdoor"),
	_doc_items_longdesc = S("Iron trapdoors are horizontal barriers which can only be opened and closed by redstone signals, but not by hand. They occupy the upper or lower part of a block, depending on how they have been placed. When open, they can be climbed like a ladder."),
	tile_front = "doors_trapdoor_steel.png",
	tile_side = "doors_trapdoor_steel_side.png",
	wield_image = "doors_trapdoor_steel.png",
	groups = {pickaxey=1, mesecon_effector_on=1},
	_mcl_hardness = 5,
	_mcl_blast_resistance = 5,
	sounds = mcl_sounds.node_sound_metal_defaults(),
	sound_open = "doors_steel_door_open",
	sound_close = "doors_steel_door_close",

	only_redstone_can_open = true,
})

minetest.register_craft({
	output = "mcl_doors:iron_trapdoor",
	recipe = {
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"},
	}
})
