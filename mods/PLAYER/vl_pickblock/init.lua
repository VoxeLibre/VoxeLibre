vl_pickblock = {}

function vl_pickblock.pickblock(itemstack, placer, pointed_thing)
	local pos = pointed_thing.under
	local node = minetest.get_node_or_nil(pointed_thing.under)
	if not node then return end

	local def = minetest.registered_nodes[node.name]
	if not def then return end

	if def.on_rightclick and not placer:get_player_control().sneak then
		return def.on_rightclick(pos, node, placer, itemstack, pointed_thing)
	end

	local illegal = (def.groups.not_in_creative_inventory and def.groups.not_in_creative_inventory ~= 0)

	local rnode
	if def._vl_pickblock then
		rnode = def._vl_pickblock
	elseif not illegal then
		rnode = node.name
	else
		-- node is illegal and has no _vl_pickblock, tough luck
		return
	end

	-- check if the picked node is already on the hotbar
	-- if so, remove it!
	local inv = placer:get_inventory()
	for i = 1, placer:hud_get_hotbar_itemcount() do
		local stack = inv:get_stack("main", i)
		if stack:get_name() == rnode then
			inv:set_stack("main", i, ItemStack())
			break -- only remove one
		end
	end

	return rnode
end
