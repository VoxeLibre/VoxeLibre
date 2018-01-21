-- TODO: Move all textures to mcl_paintings when finished

-- Intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP .. "/intllib.lua")

minetest.register_craftitem("mcl_paintings:painting", {
	description = S("Painting"),
	_doc_items_longdesc = S("Paintings are decorations which can be placed on walls. THIS ITEM IS INCOMPLETE."),
	wield_image = "gemalde_node.png",
	inventory_image = "gemalde_node.png",
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end

		local under = pointed_thing.under
		local above = pointed_thing.above

		-- Use pointed node's on_rightclick function first, if present
		local node_under = minetest.get_node(under)
		if placer and not placer:get_player_control().sneak then
			if minetest.registered_nodes[node_under.name] and minetest.registered_nodes[node_under.name].on_rightclick then
				return minetest.registered_nodes[node_under.name].on_rightclick(under, node_under, placer, itemstack) or itemstack
			end
		end

		-- Can only be placed on side
		if under.y ~= above.y then
			return itemstack
		end
		-- Can only be placed on solid nodes
		if minetest.get_item_group(node_under.name, "solid") == 0 then
			return itemstack
		end

		-- Spawn painting and rotate
		local painting = minetest.add_entity(above, "mcl_paintings:painting")
		local yaw = minetest.dir_to_yaw(vector.direction(under, above))
		painting:set_yaw(yaw)

		if not minetest.settings:get_bool("creative_mode") then
			itemstack:take_item()
		end
		return itemstack
	end,
})

-- List of painting IDs, indexed by size.
-- Outer index: Width in node lengths
-- Inner index: Height in node lengths
local paintings = {
	[1] = {
		[1] = { 1, 2, 3, 4, 5, 6, 7 }, -- 1×1
		[2] = { 8, 9, 10, 11, 12 }, -- 1×2
	},
	[2] = {
		[1] = { 13, 14}, -- 2×1
		[2] = { 15, 16, 17, 18, 19, 20 }, -- 2×2
	},
	[3] = {
		[4] = { 25, 26 }, -- 3×4
	},
	[4] = {
		[2] = { 21 }, -- 4×2
		[4] = { 22, 23, 24 }, -- 4×4
	},
}

-- Returns a random painting ID for the given size.
-- x: Width in node lenghts
-- y: Height in node lengths
local function select_painting(x, y)
	if paintings[x] then
		local pool = paintings[x][y]
		if paintings[x][y] then
			local p = math.random(1, #pool)
			return p
		end
	end
	return nil
end

-- Returns the texture table for the given painting ID
local get_textures = function(painting_id)
	return {
		"gemalde_bg.png",
		"gemalde_bg.png",
		"gemalde_bg.png",
		"gemalde_bg.png",
		"gemalde_"..tostring(painting_id)..".png",
		"gemalde_bg.png"
	}
end

-- Painting entitty.
-- Can be killed.
-- Breaks and drops as item if punched.
-- 
minetest.register_entity("mcl_paintings:painting", {
	physical = false,
	collide_with_objects = true,
	hp_max = 1,
	-- TODO: Fix visual
	visual = "cube",
	visual_size = { x=1, y=1 },
	textures = get_textures(1),

	_painting = nil, -- Holds the current painting ID. Initially nil for random painting

	get_staticdata = function(self)
		local out = { _painting = self._painting }
		return minetest.serialize(out)
	end,
	on_activate = function(self, staticdata)
		if staticdata and staticdata ~= "" then
			local inp = minetest.deserialize(staticdata)
			self._painting = inp._painting
		end
		-- Initial spawn. Select random painting
		if not self._painting then
			self._painting = select_painting(1, 1)
		end
		self.object:set_properties({textures = get_textures(self._painting)})
	end,
	on_punch = function(self, puncher)
		if not puncher or not puncher:is_player() or self._removed then
			return
		end
		-- Drop painting as item on ground
		if not minetest.settings:get_bool("creative_mode") then
			minetest.add_item(self.object:getpos(), "mcl_paintings:painting")
		end
		self._removed = true
		self.object:remove()
	end
})

--[[
-- TODO: Add crafting when this mod works better
if minetest.get_modpath("mcl_core") then
	minetest.register_craft({
		output = "mcl_paintings:painting",
		recipe = {
			{"mcl_core:stick", "mcl_core:stick", "mcl_core:stick"},
			{"mcl_core:stick", "group:wool", "mcl_core:stick"},
			{"mcl_core:stick", "mcl_core:stick", "mcl_core:stick"},
		}
	})
end
]]
