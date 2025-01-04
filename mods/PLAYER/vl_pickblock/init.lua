vl_pickblock = {}

-- The main Pickblock handler function.
-- To be called in hand's `on_place`
-- (assumes that pointed_thing.type == "node")
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

-- Pickblock handler for mobs.
-- To be called in hand's `on_secondary_use`
-- (assumes that pointed_thing.type ~= "node")
function vl_pickblock.pickmob(itemstack, clicker, pointed_thing)
	if pointed_thing.type ~= "object"
			-- only pick mobs when crouching
			or (not clicker:get_player_control().sneak) then
		return
	end

	local le = pointed_thing.ref:get_luaentity()
	if not (le and le.is_mob) then return end

	local def = minetest.registered_craftitems[le.name]
	if not def then return end

	-- check if the picked mob egg is already on the hotbar
	-- if so, remove it!
	local inv = clicker:get_inventory()
	for i = 1, clicker:hud_get_hotbar_itemcount() do
		local stack = inv:get_stack("main", i)
		if stack:get_name() == le.name then
			inv:set_stack("main", i, ItemStack())
			break -- only remove one
		end
	end

	return le.name
end
