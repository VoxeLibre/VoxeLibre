local S = minetest.get_translator("mcl_lanterns")
local modpath = minetest.get_modpath("mcl_lanterns")

mcl_lanterns = {}

--[[
TODO:
- add lantern specific sounds
]]

local lantern_contract = {
	faces = {
		top = {{-2/16, -2/16, 2/16, 2/16}},
		bottom = {{-1/16, -1/16, 1/16, 1/16}},
	},
}

function mcl_lanterns.register_lantern(name, def)
	local itemstring_floor = "mcl_lanterns:"..name.."_floor"
	local itemstring_ceiling = "mcl_lanterns:"..name.."_ceiling"

	local sounds = mcl_sounds.node_sound_metal_defaults()
	local function make_placed_node_lantern(placed_node, _, _, _)
		if placed_node.param2 == 0 then
			placed_node.name = itemstring_ceiling
		elseif placed_node.param2 == 1 then
			placed_node.name = itemstring_floor
		else
			return
		end
		return placed_node
	end

	minetest.register_node(":"..itemstring_floor, {
		description = def.description,
		_doc_items_longdesc = def.longdesc,
		drawtype = "mesh",
		mesh = "mcl_lanterns_lantern_floor.obj",
		inventory_image = def.texture_inv,
		wield_image = def.texture_inv,
		tiles = {
			{
				name = def.texture,
				animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
			}
		},
		use_texture_alpha = "clip",
		paramtype = "light",
		paramtype2 = "wallmounted",
		place_param2 = 1,
		node_placement_prediction = "",
		sunlight_propagates = true,
		light_source = def.light_level,
		groups = {pickaxey = 1, attached_node = 1, deco_block = 1, lantern = 1, dig_by_piston=1, vl_attach=1},
		_vl_attach_contract = lantern_contract,
		_vl_attach_make_placed_node = make_placed_node_lantern,
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.1875, -0.5, -0.1875, 0.1875, -0.0625, 0.1875},
				{-0.125, -0.0625, -0.125, 0.125, 0.0625, 0.125},
				{-0.0625, -0.5, -0.0625, 0.0625, 0.1875, 0.0625},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.1875, -0.5, -0.1875, 0.1875, -0.0625, 0.1875},
				{-0.125, -0.0625, -0.125, 0.125, 0.0625, 0.125},
				{-0.0625, -0.5, -0.0625, 0.0625, 0.1875, 0.0625},
			},
		},
		sounds = sounds,
		on_place = vl_attach.place_attached,
		on_rotate = false,
		_mcl_hardness = 3.5,
		_mcl_blast_resistance = 3.5,
	})

	minetest.register_node(":"..itemstring_ceiling, {
		description = def.description,
		_doc_items_create_entry = false,
		drawtype = "mesh",
		mesh = "mcl_lanterns_lantern_ceiling.obj",
		tiles = {
			{
				name = def.texture,
				animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
			}
		},
		use_texture_alpha = "clip",
		paramtype = "light",
		paramtype2 = "wallmounted",
		place_param2 = 0,
		node_placement_prediction = "",
		sunlight_propagates = true,
		light_source = def.light_level,
		groups = {pickaxey = 1, attached_node = 1, deco_block = 1, lantern = 1, not_in_creative_inventory = 1, vl_attach=1},
		_vl_attach_contract = lantern_contract,
		_vl_attach_make_placed_node = make_placed_node_lantern,
		drop = itemstring_floor,
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.1875, 0, -0.1875, 0.1875, 0.4375, 0.1875},
				{-0.125, -0.125, -0.125, 0.125, 0, 0.125},
				{-0.0625, -0.5, -0.0625, 0.0625, -0.125, 0.0625},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.1875, 0, -0.1875, 0.1875, 0.4375, 0.1875},
				{-0.125, -0.125, -0.125, 0.125, 0, 0.125},
				{-0.0625, -0.5, -0.0625, 0.0625, -0.125, 0.0625},
			},
		},
		sounds = sounds,
		on_rotate = false,
		_mcl_hardness = 3.5,
		_mcl_blast_resistance = 3.5,
	})
end

local function place_chain(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" then
		return itemstack
	end

	local p0 = pointed_thing.under
	local p1 = pointed_thing.above
	local param2 = 0

	local placer_pos = placer:get_pos()
	if placer_pos then
		local dir = {
			x = p1.x - placer_pos.x,
			y = p1.y - placer_pos.y,
			z = p1.z - placer_pos.z
		}
		param2 = core.dir_to_facedir(dir)
	end

	if p0.y - 1 == p1.y then
		param2 = 20
	elseif p0.x - 1 == p1.x then
		param2 = 16
	elseif p0.x + 1 == p1.x then
		param2 = 12
	elseif p0.z - 1 == p1.z then
		param2 = 8
	elseif p0.z + 1 == p1.z then
		param2 = 4
	end

	return core.item_place(itemstack, placer, pointed_thing, param2)
end

local chain_attach_surfaces = {
	faces = {
		top = {{-2/16, -2/16, 2/16, 2/16}},
		bottom = {{-2/16, -2/16, 2/16, 2/16}},
	},
}

minetest.register_node("mcl_lanterns:chain", {
	description = S("Chain"),
	_doc_items_longdesc = S("Chains are metallic decoration blocks."),
	inventory_image = "mcl_lanterns_chain_inv.png",
	tiles = {"mcl_lanterns_chain.png"},
	drawtype = "mesh",
	paramtype = "light",
	paramtype2 = "facedir",
	use_texture_alpha = "clip",
	mesh = "mcl_lanterns_chain.obj",
	is_ground_content = false,
	sunlight_propagates = true,
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625},
		}
	},
	groups = {pickaxey = 1, deco_block = 1},
	_vl_attach_surfaces = chain_attach_surfaces,
	sounds = mcl_sounds.node_sound_metal_defaults(),
	on_place = place_chain,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
})

minetest.register_node("mcl_lanterns:gold_chain", {
	description = S("Gold Chain"),
	_doc_items_longdesc = S("Gold Chains are metallic decoration blocks."),
	inventory_image = "mcl_lanterns_gold_chain_inv.png",
	tiles = {"mcl_lanterns_gold_chain.png"},
	drawtype = "mesh",
	paramtype = "light",
	paramtype2 = "facedir",
	use_texture_alpha = "clip",
	mesh = "mcl_lanterns_chain.obj",
	is_ground_content = false,
	sunlight_propagates = true,
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625},
		}
	},
	groups = {pickaxey = 1, deco_block = 1},
	_vl_attach_surfaces = chain_attach_surfaces,
	sounds = mcl_sounds.node_sound_metal_defaults(),
	on_place = place_chain,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
})


minetest.register_craft({
	output = "mcl_lanterns:chain 2",
	recipe = {
		{"mcl_core:iron_nugget"},
		{"mcl_core:iron_ingot"},
		{"mcl_core:iron_nugget"},
	},
})

minetest.register_craft({
	output = "mcl_lanterns:gold_chain 2",
	recipe = {
		{"mcl_core:gold_nugget"},
		{"mcl_core:gold_ingot"},
		{"mcl_core:gold_nugget"},
	},
})

dofile(modpath.."/register.lua")
