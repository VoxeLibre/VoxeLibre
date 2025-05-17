-- AXE FUNCTIONS

-- make_stripped_trunk is used by axes to strip wood logs and strip waxed nodes (oxidation related) on right click.
local function make_stripped_trunk(itemstack, placer, pointed_thing)
    if pointed_thing.type ~= "node" then return end

    local node = minetest.get_node(pointed_thing.under)
    local node_name = minetest.get_node(pointed_thing.under).name

    local noddef = minetest.registered_nodes[node_name]

    if not noddef then
        minetest.log("warning", "Trying to right click with an axe the unregistered node: " .. tostring(node_name))
        return
    end

    if not placer:get_player_control().sneak and noddef.on_rightclick then
        return minetest.item_place(itemstack, placer, pointed_thing)
    end
    if minetest.is_protected(pointed_thing.under, placer:get_player_name()) then
        minetest.record_protection_violation(pointed_thing.under, placer:get_player_name())
        return itemstack
    end

    if noddef._mcl_stripped_variant == nil then
		return itemstack
	else
		minetest.swap_node(pointed_thing.under, {name=noddef._mcl_stripped_variant, param2=node.param2})
		if minetest.get_item_group(node_name, "waxed") ~= 0 then
			awards.unlock(placer:get_player_name(), "mcl:wax_off")
		end
		if not minetest.is_creative_enabled(placer:get_player_name()) then
			-- Add wear (as if digging a axey node)
			local toolname = itemstack:get_name()
			local wear = mcl_autogroup.get_wear(toolname, "axey")
			if wear then
				itemstack:add_wear(wear)
				tt.reload_itemstack_description(itemstack) -- update tooltip
			end
		end
	end
    return itemstack
end


