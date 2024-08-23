--- fairly strict: air, ignore, or no_paths marker
-- @param node string or Node: node or node name
-- @return true for air and ignore nodes
function vl_terraforming._is_air(node)
	local name = node.name or node
	return name == "air" or name == "ignore" or name == "mcl_villages:no_paths"
end

--- check if a node is walkable (solid), but not tree/leaves/fungi/bamboo/vines/etc.
-- @param node LUA node or node name
-- @return truthy when solid but not tree/decoration/fungi
function vl_terraforming._is_solid_not_tree(node)
	local name = node.name or node
	if name == "air" or name == "ignore" or name == "mcl_villages:no_paths" or name == "mcl_core:bedrock" then return false end
	if name == "mcl_nether:soul_sand" then return true end -- not "solid". Other exceptions we need?
	if name == "mcl_nether:nether_wart_block" then return false end -- crimson forest, treat as tree
	-- is deco_block if name == "mcl_crimson:warped_wart_block" then return false end -- warped forest, treat as tree
	-- is deco_block if name == "mcl_crimson:shroomlight" then return false end -- crimson forest, treat as tree
	-- is deco_block if name == "mcl_core:snow" then return false end
	-- is walkable if name == "mcl_core:snowblock" then return true end
	local meta = minetest.registered_items[name]
	local groups = meta and meta.groups
	return meta and meta.walkable and not (groups and (groups.deco_block or groups.tree or groups.leaves or groups.plant))
end
local is_solid_not_tree = vl_terraforming._is_solid_not_tree

--- check if a node is tree
-- @param node string or Node: node or node name
-- @return true for tree, leaves
function vl_terraforming._is_tree_not_leaves(node)
	local name = node.name or node
	if name == "air" or name == "ignore" or name == "mcl_villages:no_paths" then return false end
	-- if name == "mcl_nether:nether_wart_block" then return true end -- crimson forest, treat as tree
	-- if name == "mcl_crimson:warped_wart_block" then return true end -- warped forest, treat as tree
	-- if name == "mcl_crimson:shroomlight" then return true end -- crimson forest, treat as tree
	local meta = minetest.registered_items[name]
	return meta and meta.groups and meta.groups.tree
end

--- check if a node is liquid
-- @param node string or Node: node or node name
-- @return true for water, lava
function vl_terraforming._is_liquid(node)
	local name = node.name or node
	if name == "air" or name == "ignore" or name == "mcl_villages:no_paths" then return false end
	local meta = minetest.registered_items[name]
	local groups = meta and meta.groups
	return groups and groups.liquid
end

--- replace a non-solid node, optionally also "additional"
-- @param vm voxelmanip
-- @param pos position
-- @param with replacement Lua node (not just name)
-- @param always additional node to awlays replace even when solid
function vl_terraforming._make_solid_vm(vm, pos, with, always)
	local cur = vm:get_node_at(pos)
	if cur.name == "ignore" or cur.name == "mcl_core:bedrock" then return end
	if cur.name == always or not is_solid_not_tree(cur) then
		vm:set_node_at(pos, with)
		return true
	end
end
