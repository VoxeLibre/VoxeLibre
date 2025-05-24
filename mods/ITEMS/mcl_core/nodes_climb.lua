-- Climbable nodes
local S = minetest.get_translator(minetest.get_current_modname())

local function rotate_climbable(pos, node, user, mode)
	if mode == screwdriver.ROTATE_FACE then
		local r = screwdriver.rotate.wallmounted(pos, node, mode)
		node.param2 = r
		minetest.swap_node(pos, node)
		return true
	end
	return false
end

---Updates the trapdoor above (if any).
---
---@param pos mt.Vector The position of the ladder.
---@param event "place" | "destruct" The place or destruct event.
function mcl_core.update_trapdoor(pos, event)
	local top_pos = vector.offset(pos, 0, 1, 0)
	local top_node = minetest.get_node_or_nil(top_pos)

	if top_node and minetest.get_item_group(top_node.name, "trapdoor") == 2 then
		local new_name = top_node.name
		if event == "place" then
			new_name = string.gsub(new_name, "open$", "ladder")
		elseif event == "destruct" then
			new_name = string.gsub(new_name, "ladder$", "open")
		end

		-- If node above is an opened trapdoor
		minetest.swap_node(top_pos, {
			name = new_name,
			param1 = top_node.param1,
			param2 = top_node.param2,
		})
	end
end

-- TODO: Move ladders into their own API.
minetest.register_node("mcl_core:ladder", {
	description = S("Ladder"),
	_doc_items_longdesc = S(
		"A piece of ladder which allows you to climb vertically. Ladders can only be placed on the side of solid blocks."),
	drawtype = "signlike",
	is_ground_content = false,
	tiles = { "default_ladder.png" },
	inventory_image = "default_ladder.png",
	wield_image = "default_ladder.png",
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "wallmounted",
	walkable = true,
	climbable = true,
	node_box = {
		type = "wallmounted",
		wall_side = { -0.5, -0.5, -0.5, -7 / 16, 0.5, 0.5 },
	},
	selection_box = {
		type = "wallmounted",
		wall_side = { -0.5, -0.5, -0.5, -7 / 16, 0.5, 0.5 },
	},
	stack_max = 64,
	groups = {
		handy = 1,
		axey = 1,
		attached_node = 1,
		deco_block = 1,
		dig_by_piston = 1,
		ladder = 1
	},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	node_placement_prediction = "",
	-- Restrict placement of ladders
	on_place = function(itemstack, placer, pointed_thing)
		local called
		itemstack, called = mcl_util.handle_node_rightclick(itemstack, placer, pointed_thing)
		if( called ) then return itemstack end

		if pointed_thing.type ~= "node" then
			-- no interaction possible with entities
			return itemstack
		end

		-- Ladders may not be placed on ceiling or floor
		local under, above = pointed_thing.under, pointed_thing.above
		if under.y ~= above.y then return itemstack end

		local node = minetest.get_node(under)
		local def = minetest.registered_nodes[node.name]
		if not def then return itemstack end
		local groups = def.groups

		-- Don't allow to place the ladder at non-solid nodes
		if (groups and (not groups.solid)) then
			return itemstack
		end

		local idef = itemstack:get_definition()
		local itemstack, pos = minetest.item_place_node(itemstack, placer, pointed_thing)

		-- A non-nil pos indicates the node was placed in a valid position.
		if pos and idef.sounds and idef.sounds.place then
			minetest.sound_play(idef.sounds.place, { pos = above, gain = 1 }, true)
		end
		return itemstack
	end,
	after_destruct = function(pos, old)
		mcl_core.update_trapdoor(pos, "destruct")
	end,
	after_place_node = function(pos)
		mcl_core.update_trapdoor(pos, "place")
	end,
	_mcl_blast_resistance = 0.4,
	_mcl_hardness = 0.4,
	on_rotate = rotate_climbable,
})


minetest.register_node("mcl_core:vine", {
	description = S("Vines"),
	_doc_items_longdesc = S(
		"Vines are climbable blocks which can be placed on the sides of solid full-cube blocks. Vines slowly grow and spread."),
	drawtype = "signlike",
	tiles = { "mcl_core_vine.png" },
	color = "#48B518",
	inventory_image = "mcl_core_vine.png",
	wield_image = "mcl_core_vine.png",
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "colorwallmounted",
	palette = "[combine:16x2:0,0=mcl_core_palette_foliage.png",
	walkable = false,
	climbable = true,
	buildable_to = true,
	selection_box = {
		type = "wallmounted",
	},
	stack_max = 64,
	groups = {
		handy = 1,
		axey = 1,
		shearsy = 1,
		swordy = 1,
		deco_block = 1,
		dig_by_piston = 1,
		destroy_by_lava_flow = 1,
		compostability = 50,
		flammable = 2,
		fire_encouragement = 15,
		fire_flammability = 100,
		foliage_palette_wallmounted = 1,
		ladder = 1
	},
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

		-- Check special rightclick action of pointed node
		if def and def.on_rightclick then
			if not placer:get_player_control().sneak then
				return def.on_rightclick(under, node, placer, itemstack,
					pointed_thing) or itemstack, false
			end
		end

		-- Only place on full cubes
		if not mcl_core.supports_vines(node.name) then
			return itemstack
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
				minetest.sound_play(idef.sounds.place, { pos = above, gain = 1 }, true)
			end
		end
		return itemstack
	end,

	on_construct = function(pos)
		local node = minetest.get_node(pos)
		local foliage_palette_index = mcl_util.get_palette_indexes_from_pos(pos).foliage_palette_index
		if node.name == "mcl_core:vine" then
			local biome_param2 = foliage_palette_index
			local rotation_param2 = node.param2
			local final_param2 = (biome_param2 * 8) + rotation_param2
			if node.param2 ~= final_param2 and rotation_param2 < 6 then
				node.param2 = final_param2
				minetest.swap_node(pos, node)
			end
		end
	end,

	-- If dug, also dig a “dependant” vine below it.
	-- A vine is dependant if it hangs from this node and has no supporting block.
	on_dig = function(pos, node, digger)
		local below = vector.offset(pos, 0, -1, 0)
		local belownode = minetest.get_node(below)
		minetest.node_dig(pos, node, digger)
		if belownode.name == node.name and (not mcl_core.check_vines_supported(below, belownode)) then
			minetest.registered_nodes[node.name].on_dig(below, node, digger)
		end
	end,
	after_destruct = function(pos, old)
		mcl_core.update_trapdoor(pos, "destruct")
	end,
	after_place_node = function(pos)
		mcl_core.update_trapdoor(pos, "place")
	end,


	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.2,
	on_rotate = false,
})
