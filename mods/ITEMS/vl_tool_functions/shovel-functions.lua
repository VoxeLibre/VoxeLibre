--SHOVEL FUNCTIONS

-- Making Grass Paths
-- make_grass_path is used by shovels for turning grass to paths on right_click and reverting paths to dirt on shift+right_click.
local make_grass_path = function(itemstack, placer, pointed_thing)
	-- Use pointed node's on_rightclick function first, if present
	local node = minetest.get_node(pointed_thing.under)
	if placer and not placer:get_player_control().sneak then
		if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
			return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
		end
	end

	-- Only make or remove grass path if tool used on side or top of target node
	if pointed_thing.above.y < pointed_thing.under.y then
		return itemstack
	end

-- Remove grass paths
	if (minetest.get_item_group(node.name, "path_remove_possible") == 1) and placer:get_player_control().sneak then
		local above = table.copy(pointed_thing.under)
		above.y = above.y + 1
		if minetest.get_node(above).name == "air" then
			if minetest.is_protected(pointed_thing.under, placer:get_player_name()) then
				minetest.record_protection_violation(pointed_thing.under, placer:get_player_name())
				return itemstack
			end

			if not minetest.is_creative_enabled(placer:get_player_name()) then
				-- Add wear (as if digging a shovely node)
				local toolname = itemstack:get_name()
				local wear = mcl_autogroup.get_wear(toolname, "shovely")
				if wear then
					itemstack:add_wear(wear)
					tt.reload_itemstack_description(itemstack) -- update tooltip
				end
			end
			minetest.sound_play({name="default_grass_footstep", gain=1}, {pos = above, max_hear_distance = 16}, true)
			minetest.swap_node(pointed_thing.under, {name="mcl_core:dirt"})
		end
	end

-- Make grass paths
	if (minetest.get_item_group(node.name, "path_creation_possible") == 1) and not placer:get_player_control().sneak then
		local above = table.copy(pointed_thing.under)
		above.y = above.y + 1
		if minetest.get_node(above).name == "air" then
			if minetest.is_protected(pointed_thing.under, placer:get_player_name()) then
				minetest.record_protection_violation(pointed_thing.under, placer:get_player_name())
				return itemstack
			end

			if not minetest.is_creative_enabled(placer:get_player_name()) then
				-- Add wear (as if digging a shovely node)
				local toolname = itemstack:get_name()
				local wear = mcl_autogroup.get_wear(toolname, "shovely")
				if wear then
					itemstack:add_wear(wear)
					tt.reload_itemstack_description(itemstack) -- update tooltip
				end
			end
			minetest.sound_play({name="default_grass_footstep", gain=1}, {pos = above, max_hear_distance = 16}, true)
			minetest.swap_node(pointed_thing.under, {name="mcl_core:grass_path"})
		end
	end
	return itemstack
end
