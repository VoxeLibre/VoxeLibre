-- Overrides the builtin minetest.check_single_for_falling.
-- We need to do this in order to handle nodes in VoxeLibre specific groups
-- "supported_node" and "attached_node_facedir".
--
-- Nodes in group "supported_node" can be placed on any node that does not
-- have the "airlike" drawtype.  Carpets are an example of this type.

local pairs = pairs
local math = math
local vector = vector

local facedir_to_dir = minetest.facedir_to_dir
local wallmounted_to_dir = minetest.wallmounted_to_dir
local get_item_group = minetest.get_item_group
local remove_node = minetest.remove_node
local get_node = minetest.get_node
local get_meta = minetest.get_meta
local registered_nodes = minetest.registered_nodes
local get_node_drops = minetest.get_node_drops
local add_item = minetest.add_item

-- drop_attached_node(p)
--
-- This function is copied verbatim from minetest/builtin/game/falling.lua
-- We need this to do the exact same dropping node handling in our override
-- minetest.check_single_for_falling() function as in the builtin function.
--
---@param p Vector
local function drop_attached_node(p)
	local n = get_node(p)
	local drops = get_node_drops(n, "")
	local def = registered_nodes[n.name]

	if def and def.preserve_metadata then
		local oldmeta = get_meta(p):to_table().fields
		-- Copy pos and node because the callback can modify them.
		local pos_copy = vector.copy(p)
		local node_copy = { name = n.name, param1 = n.param1, param2 = n.param2 }
		local drop_stacks = {}
		for k, v in pairs(drops) do
			drop_stacks[k] = ItemStack(v)
		end
		drops = drop_stacks
		def.preserve_metadata(pos_copy, node_copy, oldmeta, drops)
	end

	if def and def.sounds and def.sounds.fall then
		minetest.sound_play(def.sounds.fall, { pos = p }, true)
	end

	remove_node(p)
	for _, item in pairs(drops) do
		local pos = vector.offset(p,
			math.random() / 2 - 0.25,
			math.random() / 2 - 0.25,
			math.random() / 2 - 0.25
		)
		add_item(pos, item)
	end
end

-- minetest.check_single_for_falling(pos)
--
-- * causes an unsupported `group:falling_node` node to fall and causes an
--   unattached `group:attached_node` or `group:attached_node_facedir` node
--   or unsupported `group:supported_node` node to drop.
-- * does not spread these updates to neighbours.
--
-- Returns true if the node at <pos> has spawned a falling node or has been
-- dropped as item(s).
--
local original_function = minetest.check_single_for_falling

function minetest.check_single_for_falling(pos)
	if original_function(pos) then
		return true
	end

	local node = get_node(pos)
	if get_item_group(node.name, "attached_node_facedir") ~= 0 then
		local dir = facedir_to_dir(node.param2)
		if dir then
			if get_item_group(get_node(vector.add(pos, dir)).name, "solid") == 0 then
				drop_attached_node(pos)
				return true
			end
		end
	end

	if get_item_group(node.name, "attached_node_wallmounted") ~= 0 then
		local dir = wallmounted_to_dir(node.param2)
		if dir then
			if get_item_group(get_node(vector.add(pos, dir)).name, "solid") == 0 then
				drop_attached_node(pos)
				return true
			end
		end
	end

	if get_item_group(node.name, "supported_node") ~= 0 then
		local def = registered_nodes[get_node(vector.offset(pos, 0, -1, 0)).name]
		if def and def.drawtype == "airlike" then
			drop_attached_node(pos)
			return true
		end
	end

	if get_item_group(node.name, "supported_node_facedir") ~= 0 then
		local dir = facedir_to_dir(node.param2)
		if dir then
			local def = registered_nodes[get_node(vector.add(pos, dir)).name]
			if def and def.drawtype == "airlike" then
				drop_attached_node(pos)
				return true
			end
		end
	end

	if get_item_group(node.name, "supported_node_wallmounted") ~= 0 then
		local dir = wallmounted_to_dir(node.param2)
		if dir then
			local def = registered_nodes[get_node(vector.add(pos, dir)).name]
			if def and def.drawtype == "airlike" then
				drop_attached_node(pos)
				return true
			end
		end
	end

	return false
end
