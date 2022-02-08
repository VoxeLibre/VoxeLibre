local S = minetest.get_translator("mcl_lanterns")
local modpath = minetest.get_modpath("mcl_lanterns")

mcl_lanterns = {}


function mcl_lanterns.register_lantern(name, def)
	local itemstring_floor = "mcl_lanterns:"..name.."_floor"
	local itemstring_ceiling = "mcl_lanterns:"..name.."_ceiling"

	minetest.register_node(itemstring_floor, {
		description = def.description,
		drawtype = "mesh",
		mesh = "mcl_lanterns_lantern_floor.obj",
		inventory_image = def.texture_inv,
		wield_image = def.texture_inv,
		tiles = {{
				name = def.texture,
				animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
		}},
		use_texture_alpha = "clip",
		paramtype = "light",
		paramtype2 = "wallmounted",
		sunlight_propagates = true,
		light_source = def.light_level,
		groups = {choppy=2, dig_immediate=3, flammable=1, attached_node=1, torch=1},
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
		--sounds = default.node_sound_wood_defaults(),
		on_place = function(itemstack, placer, pointed_thing)
			local under = pointed_thing.under
			local node = minetest.get_node(under)
			local def = minetest.registered_nodes[node.name]
			if def and def.on_rightclick and
				not (placer and placer:is_player() and
				placer:get_player_control().sneak) then
				return def.on_rightclick(under, node, placer, itemstack,
					pointed_thing) or itemstack
			end

			local above = pointed_thing.above
			local wdir = minetest.dir_to_wallmounted(vector.subtract(under, above))
			local fakestack = itemstack
			if wdir == 0 then
				fakestack:set_name(itemstring_ceiling)
			elseif wdir == 1 then
				fakestack:set_name(itemstring_floor)
			end

			itemstack = minetest.item_place(fakestack, placer, pointed_thing, wdir)
			itemstack:set_name(itemstring_floor)

			return itemstack
		end,
		--floodable = true,
		--on_flood = on_flood,
		on_rotate = false
	})

	minetest.register_node(itemstring_ceiling, {
		drawtype = "mesh",
		mesh = "mcl_lanterns_lantern_floor.obj",
		tiles = {{
				name = def.texture,
				animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
		}},
		use_texture_alpha = "clip",
		paramtype = "light",
		paramtype2 = "wallmounted",
		sunlight_propagates = true,
		light_source = def.light_level,
		groups = {dig_immediate=3, not_in_creative_inventory=1},
		drop = itemstring_floor,
		selection_box = {
			type = "wallmounted",
			wall_top = {-1/8, -1/16, -5/16, 1/8, 1/2, 1/8},
		},
		--sounds = default.node_sound_wood_defaults(),
		--floodable = true,
		--on_flood = on_flood,
		on_rotate = false
	})
end

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
	on_place = function(itemstack, placer, pointed_thing)
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
			param2 = minetest.dir_to_facedir(dir)
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

		return minetest.item_place(itemstack, placer, pointed_thing, param2)
	end,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
})

dofile(modpath.."/register.lua")