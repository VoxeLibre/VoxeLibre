-- NOTE: As of Luanti 5.9 and 5.10, the function `core.get_node_raw` is NOT exposed.
-- However, via `secure.trusted_mods=vl_trusted` it is possible to expose and use it.
-- If <https://github.com/minetest/minetest/issues/15317> is merged, it may become public API.
-- For more details, see the vl_trusted module.
-- We do not call into vl_trusted directly, but it set `core.get_node_raw` if loaded first.
-- Load order hence is important, and this mod should depend on vl_trusted.

local core_get_node = core.get_node
local core_get_node_raw = core.get_node_raw
local core_get_name_from_content_id = core.get_name_from_content_id
local core_get_content_id = core.get_content_id

--- Get the node name, param and param2 using `core.get_node_raw` if available, fall back to regular get_node otherwise.
---
--- @param pos vector: position
--- @return string, number, number: node name, param1 and param2
function mcl_vars.get_node_name(pos) -- Fallback version
	local node = core_get_node(pos)
	return node.name, node.param1, node.param2
end
-- optimized version
if core_get_node_raw then
	---@param pos vector.Vector
	mcl_vars.get_node_name = function(pos)
		local content, param1, param2, pos_ok = core_get_node_raw(pos.x, pos.y, pos.z)
		if not pos_ok then return "ignore", 0, 0 end
		return core_get_name_from_content_id(content), param1, param2
	end
end

--- Get the node name, param and param2 using `core.get_node_raw` if available fall back to regular get_node otherwise.
--- Note: up to Luanti 5.10 at least, this will create a new vector. If you already have a vector, prefer `get_node_name`.
---
--- @param x number: coordinate
--- @param y number: coordinate
--- @param z number: coordinate
--- @return string, number, number: node name, param1, param2
function mcl_vars.get_node_name_raw(x, y, z) -- Fallback version
	local node = core_get_node({x=x,y=y,z=z}) -- raw table, not need for vector
	return node.name, node.param1, node.param2
end
-- optimized version
if core_get_node_raw then
	mcl_vars.get_node_name_raw = function(x, y, z)
		local content, param1, param2, pos_ok = core_get_node_raw(x, y, z)
		if not pos_ok then return "ignore", 0, 0 end
		return core_get_name_from_content_id(content), param1, param2
	end
end

--- Get the node name, param and param2 using `core.get_node_raw` if available, fall back to regular get_node otherwise.
--- Note: up to Luanti 5.10 at least, this involves an unnecessary roundtrip via the node name.
--- If you use the node name anyway, prefer `get_node_name_raw` or `get_node_name`.
---
--- @param x number: coordinate
--- @param y number: coordinate
--- @param z number: coordinate
--- @return number, number, number, boolean: node content id, param1, param2, pos_ok
function mcl_vars.get_node_raw(x, y, z) -- Fallback
	local node = core_get_node({x=x,y=y,z=z}) -- raw table, not need for vector
	return core_get_content_id(node.name), node.param1, node.param2, node.name ~= "ignore"
end
-- optimized version
if core_get_node_raw then
	mcl_vars.get_node_raw = core_get_node_raw
end

