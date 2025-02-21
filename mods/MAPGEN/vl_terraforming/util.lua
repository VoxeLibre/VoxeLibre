local get_node_name = mcl_vars.get_node_name
local swap_node = core.swap_node

--- node that is used to place air
vl_terraforming._AIR = {name = "air"}

--- immutable nodes where we have to stop
-- @param node string or Node: node or node name
-- @return true if this must never be changed
function vl_terraforming._immutable(node)
	local name = node.name or node
	return name == "ignore" or name == "mcl_core:bedrock"
end

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
	if name == "mcl_nether:soul_sand" then return true end -- not "walkable". Other exceptions we need?
	if name == "mcl_crimson:crimson_hyphae" then return false end -- crimson forest, treat as tree
	if name == "mcl_nether:nether_wart_block" then return false end -- crimson forest, treat as leaves
	if name == "mcl_crimson:warped_hyphae" then return false end -- warped forest, treat as tree
	if name == "mcl_crimson:warped_wart_block" then return false end -- warped forest, treat as leaves
	if name == "mcl_crimson:shroomlight" then return false end -- crimson forest, treat as tree
	if name == "mcl_core:snow" then return false end
	-- is walkable if name == "mcl_core:snowblock" then return true end
	local meta = core.registered_items[name]
	local groups = meta and meta.groups
	return groups and meta.walkable and not ((groups.tree or 0) > 0 or (groups.leaves or 0) > 0 or (groups.plant or 0) > 0 or (groups.huge_mushroom or 0) > 0)
end
local is_solid_not_tree = vl_terraforming._is_solid_not_tree

--- check if a node is tree or leaves
-- @param node string or Node: node or node name
-- @return true for tree or leaves, also other compostable things
function vl_terraforming._is_tree_or_leaves(node)
	local name = node.name or node
	if name == "mcl_crimson:crimson_hyphae" then return true end -- crimson forest, treat as tree
	if name == "mcl_nether:nether_wart_block" then return true end -- crimson forest, treat as leaves
	if name == "mcl_crimson:warped_hyphae" then return true end -- warped forest, treat as tree
	if name == "mcl_crimson:warped_wart_block" then return true end -- warped forest, treat as leaves
	if name == "mcl_crimson:shroomlight" then return true end -- crimson forest, treat as tree
	if name == "mcl_core:snow" then return true end -- snow cover on tree, remove also
	local meta = core.registered_items[node]
	local groups = meta and meta.groups
	return groups and ((groups.tree or 0) > 0 or (groups.leaves or 0) > 0 or (groups.plant or 0) > 0 or (groups.huge_mushroom or 0) > 0)
end

--- check if a node is tree trunk
-- @param node string or Node: node or node name
-- @return true for tree, but not leaves
function vl_terraforming._is_tree_not_leaves(node)
	local name = node.name or node
	if name == "air" or name == "ignore" or name == "mcl_villages:no_paths" then return false end
	if name == "mcl_crimson:crimson_hyphae" then return true end -- crimson forest, treat as tree
	if name == "mcl_crimson:warped_hyphae" then return true end -- warped forest, treat as tree
	local meta = core.registered_items[name]
	local groups = meta and meta.groups
	return groups and ((groups.tree or 0) > 0 or (groups.huge_mushroom_stem or 0) > 0)
end

--- check if a node is liquid
-- @param node string or Node: node or node name
-- @return true for water, lava
function vl_terraforming._is_liquid(node)
	local name = node.name or node
	if name == "air" or name == "ignore" or name == "mcl_villages:no_paths" then return false end
	local meta = core.registered_items[name]
	local groups = meta and meta.groups
	return groups and (groups.liquid or 0) > 0
end

--- replace a non-solid node, optionally also "additional"
-- @param pos position
-- @param with replacement Lua node (not just name)
-- @param always additional node to awlays replace even when solid
function vl_terraforming._make_solid(pos, with, always)
	local cur = get_node_name(pos)
	if cur == "ignore" or cur == "mcl_core:bedrock" then return end
	if cur == always or not is_solid_not_tree(cur) then
		swap_node(pos, with)
		return true
	end
end
