-- Climbable nodes

minetest.register_node("mcl_core:ladder", {
	description = "Ladder",
	_doc_items_longdesc = "A piece of ladder which allows you to climb vertically. Ladders can only be placed on the side of solid blocks and not on glass, leaves, ice, slabs, glowstone, nor sea lanterns.",
	drawtype = "signlike",
	is_ground_content = false,
	tiles = {"default_ladder.png"},
	inventory_image = "default_ladder.png",
	wield_image = "default_ladder.png",
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "wallmounted",
	walkable = true,
	climbable = true,
	node_box = {
		type = "wallmounted",
		wall_side = { -0.5, -0.5, -0.5, -7/16, 0.5, 0.5 },
	},
	selection_box = {
		type = "wallmounted",
		wall_side = { -0.5, -0.5, -0.5, -7/16, 0.5, 0.5 },
	},
	stack_max = 64,
	groups = {handy=1,axey=1, attached_node=1, deco_block=1, dig_by_piston=1},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	node_placement_prediction = "",
	-- Restrict placement of ladders
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			-- no interaction possible with entities
			return itemstack
		end

		local under = pointed_thing.under
		local node = minetest.get_node(under)
		local def = minetest.registered_nodes[node.name]
		if not def then
			return itemstack
		end
		local groups = def.groups

		-- Don't allow to place the ladder at particular nodes
		if (groups and (groups.glass or groups.leaves or groups.slab)) or
				node.name == "mcl_core:ladder" or node.name == "mcl_core:ice" or node.name == "mcl_nether:glowstone" or node.name == "mcl_ocean:sea_lantern" then
			return itemstack
		end

		-- Check special rightclick action of pointed node
		if def and def.on_rightclick then
			if not placer:get_player_control().sneak then
				return def.on_rightclick(under, node, placer, itemstack,
					pointed_thing) or itemstack, false
			end
		end
		local above = pointed_thing.above

		-- Ladders may not be placed on ceiling or floor
		if under.y ~= above.y then
			return itemstack
		end
		local idef = itemstack:get_definition()
		local success = minetest.item_place_node(itemstack, placer, pointed_thing)

		if success then
			if idef.sounds and idef.sounds.place then
				minetest.sound_play(idef.sounds.place, {pos=above, gain=1})
			end
		end
		return itemstack
	end,

	_mcl_blast_resistance = 2,
	_mcl_hardness = 0.4,
})


minetest.register_node("mcl_core:vine", {
	description = "Vines",
	_doc_items_longdesc = "Vines are climbable blocks which can be placed on the sides solid full-cube blocks. Vines very slowly grow upwards and downwards.",
	drawtype = "signlike",
	tiles = {"mcl_core_vine.png"},
	inventory_image = "mcl_core_vine.png",
	wield_image = "mcl_core_vine.png",
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "wallmounted",
	walkable = false,
	climbable = true,
	buildable_to = true,
	selection_box = {
		type = "wallmounted",
	},
	stack_max = 64,
	groups = {handy=1,axey=1,shearsy=1,swordy=1, flammable=2,deco_block=1,destroy_by_lava_flow=1,dig_by_piston=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	drop = "",
	_mcl_shears_drop = true,
	node_placement_prediction = "",
	-- Restrict placement of vines
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			-- no interaction possible with entities
			return itemstack
		end

		local under = pointed_thing.under
		local node = minetest.get_node(under)
		local def = minetest.registered_nodes[node.name]
		if not def then return itemstack end
		local groups = def.groups

		-- Check special rightclick action of pointed node
		if def and def.on_rightclick then
			if not placer:get_player_control().sneak then
				return def.on_rightclick(under, node, placer, itemstack,
					pointed_thing) or itemstack, false
			end
		end

		-- Only allow placement on solid nodes
		if (not groups) or (not groups.solid) then
			return itemstack
		end

		-- Only place on full cubes
		if not mcl_core.supports_vines(node.name) then
			return
		end

		local above = pointed_thing.above

		-- Vines may not be placed on top or below another block
		if under.y ~= above.y then
			return itemstack
		end
		local idef = itemstack:get_definition()
		local itemstack, success = minetest.item_place_node(itemstack, placer, pointed_thing)

		if success then
			if idef.sounds and idef.sounds.place then
				minetest.sound_play(idef.sounds.place, {pos=above, gain=1})
			end
		end
		return itemstack
	end,

	-- If destroyed, also a “dependant” vine below it.
	-- A vine is dependant if it hangs from this node and has no supporting block.
	after_destruct = function(pos, oldnode)
		local below = {x=pos.x, y=pos.y-1, z=pos.z}
		local belownode = minetest.get_node(below)
		if belownode.name == oldnode.name and belownode.param2 == belownode.param2 then
			local dir = minetest.wallmounted_to_dir(belownode.param2)
			local support = vector.add(below, dir)
			local supportnode = minetest.get_node(support)
			if not minetest.registered_nodes[supportnode.name].walkable then
				minetest.remove_node(below)
			end
		end
	end,


	_mcl_blast_resistance = 1,
	_mcl_hardness = 0.2,
})
