local function pickblock(_, placer, pointed_thing)
	local node = minetest.get_node_or_nil(pointed_thing.under)
	if not node then return end

	local def = minetest.registered_nodes[node.name]
	if not def then return end

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

local old_on_place = minetest.registered_items[""].on_place
minetest.override_item("", {
	on_place = function(itemstack, placer, pointed_thing)
		old_on_place(itemstack, placer, pointed_thing)
		if minetest.is_creative_enabled(placer:get_player_name()) then
			return pickblock(itemstack, placer, pointed_thing)
		end
	end
})
