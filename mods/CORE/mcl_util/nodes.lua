-- Functions related to nodes and node definitions

-- Luanti 5.3.0 or less can only measure the light level. This came in at 5.4
-- This function has been known to fail in multiple places so the error handling is added increase safety and improve
-- debugging. See:
-- https://git.minetest.land/VoxeLibre/VoxeLibre/issues/1392
function mcl_util.get_natural_light (pos, time)
	local status, retVal = pcall(core.get_natural_light, pos, time)
	if status then
		return retVal
	else
		core.log("warning", "Failed to get natural light at pos: " .. dump(pos) .. ", time: " .. dump(time))
		if (pos) then
			local node = core.get_node(pos)
			core.log("warning", "Node at pos: " .. dump(node.name))
		end
	end
	return 0
end

-- Based on core.rotate_and_place

--[[
Attempt to predict the desired orientation of the pillar-like node
defined by `itemstack`, and place it accordingly in one of 3 possible
orientations (X, Y or Z).

Stacks are handled normally if the `infinitestacks`
field is false or omitted (else, the itemstack is not changed).
* `invert_wall`: if `true`, place wall-orientation on the ground and ground-
  orientation on wall

This function is a simplified version of core.rotate_and_place.
The Luanti function is seen as inappropriate because this includes mirror
images of possible orientations, causing problems with pillar shadings.
]]
function mcl_util.rotate_axis_and_place(itemstack, placer, pointed_thing, infinitestacks, invert_wall)
	local unode = core.get_node_or_nil(pointed_thing.under)
	if not unode then return end

	local new_itemstack, called = mcl_util.handle_node_rightclick(itemstack, placer, pointed_thing)
	if called then return new_itemstack end

	local wield_name = itemstack:get_name()

	local above = pointed_thing.above
	local under = pointed_thing.under

	local anode = core.get_node_or_nil(above)
	if not anode then
		return
	end
	local pos = pointed_thing.above
	local node = anode

	local undef = core.registered_nodes[unode.name]
	if undef and undef.buildable_to then
		pos = pointed_thing.under
		node = unode
	end

	if core.is_protected(pos, placer:get_player_name()) then
		core.record_protection_violation(pos, placer:get_player_name())
		return
	end

	local ndef = core.registered_nodes[node.name]
	if not ndef or not ndef.buildable_to then
		return
	end

	local p2
	if above.y ~= under.y then
		p2 = 0
	elseif above.x ~= under.x then
		p2 = 12
	elseif above.z ~= under.z then
		p2 = 6
	end
	core.set_node(pos, {name = wield_name, param2 = p2})

	if not infinitestacks then
		itemstack:take_item()
		return itemstack
	end
end

-- Wrapper of above function for use as `on_place` callback (Recommended).
-- Similar to core.rotate_node.
function mcl_util.rotate_axis(itemstack, placer, pointed_thing)
	return mcl_util.rotate_axis_and_place(itemstack, placer, pointed_thing,
		core.is_creative_enabled(placer:get_player_name()),
		placer:get_player_control().sneak)
end

-- Returns position of the neighbor of a double chest node
-- or nil if node is invalid.
-- This function assumes that the large chest is actually intact
-- * pos: Position of the node to investigate
-- * param2: param2 of that node
-- * side: Which "half" the investigated node is. "left" or "right"
function mcl_util.get_double_container_neighbor_pos(pos, param2, side)
	local sign = (side == "right" and 1 or -1)

	if param2 == 0 then
		return vector.offset(pos, -sign, 0, 0)
	elseif param2 == 1 then
		return vector.offset(pos,  0, 0,  sign)
	elseif param2 == 2 then
		return vector.offset(pos,  sign, 0,  0)
	elseif param2 == 3 then
		return vector.offset(pos,  0, 0, -sign)
	end
end

-- Returns a on_place function for plants
-- * condition: function(pos, node, itemstack)
--    * A function which is called by the on_place function to check if the node can be placed
--    * Must return true, if placement is allowed, false otherwise.
--    * If it returns a string, placement is allowed, but will place this itemstring as a node instead
--    * pos, node: Position and node table of plant node
--    * itemstack: Itemstack to place
function mcl_util.generate_on_place_plant_function(condition)
	return function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			-- no interaction possible with entities
			return itemstack
		end

		-- Call on_rightclick if the pointed node defines it
		local node = core.get_node(pointed_thing.under)
		local node_def = core.registered_nodes[node.name]

		if placer and not placer:get_player_control().sneak then
			if node_def and node_def.on_rightclick then
				return node_def.on_rightclick(pointed_thing.under, node, placer, itemstack, pointed_thing) or itemstack
			end
		end

		local place_pos
		local def_under = core.registered_nodes[core.get_node(pointed_thing.under).name]
		local def_above = core.registered_nodes[core.get_node(pointed_thing.above).name]
		if not def_under or not def_above then
			return itemstack
		end
		if def_under.buildable_to and def_under.name ~= itemstack:get_name() then
			place_pos = pointed_thing.under
		elseif def_above.buildable_to and def_above.name ~= itemstack:get_name() then
			place_pos = pointed_thing.above
			pointed_thing.under = pointed_thing.above
		else
			return itemstack
		end

		-- Check placement rules
		local result, param2 = condition(place_pos, node, itemstack)
		if result == true then
			local idef = itemstack:get_definition()
			local new_itemstack, success = core.item_place_node(itemstack, placer, pointed_thing, param2)

			if success then
				if idef.sounds and idef.sounds.place then
					core.sound_play(idef.sounds.place, {pos = pointed_thing.above, gain = 1}, true)
				end
			end
			itemstack = new_itemstack
		end

		return itemstack
	end
end

---Return a function to use in `on_place`.
---
---Allow to bypass the `buildable_to` node field in a `on_place` callback.
---
---You have to make sure that the nodes you return true for have `buildable_to = true`.
---@param func fun(node_name: string): boolean Return `true` if node must not replace the buildable_to node
---                                            which have `node_name`
---@return fun(itemstack: core.ItemStack, placer: core.ObjectRef, pointed_thing: core.PointedThing, param2: integer): core.ItemStack?
function mcl_util.bypass_buildable_to(func)
	-- Copied from minetest builtin
	-- https://github.com/minetest/minetest/blob/526a2f7b8c45504088e194a83d54a19045227bbd/builtin/game/item.lua#L5-L12
	local function copy_pointed_thing(pointed_thing)
		return {
			type  = pointed_thing.type,
			above = pointed_thing.above and vector.copy(pointed_thing.above),
			under = pointed_thing.under and vector.copy(pointed_thing.under),
			ref   = pointed_thing.ref,
		}
	end

	-- Copied from minetest builtin
	-- https://github.com/minetest/minetest/blob/526a2f7b8c45504088e194a83d54a19045227bbd/builtin/game/item.lua#L137-L139
	local function user_name(user)
		return user and user:get_player_name() or ""
	end

	-- Returns a logging function. For empty names, does not log. Copied from minetest builtin
	-- https://github.com/minetest/minetest/blob/526a2f7b8c45504088e194a83d54a19045227bbd/builtin/game/item.lua#L142-L144
	local function make_log(name)
		return name ~= "" and core.log or function() end
	end

	-- Copied from minetest builtin
	-- https://github.com/minetest/minetest/blob/526a2f7b8c45504088e194a83d54a19045227bbd/builtin/game/falling.lua#L503-L547
	local function check_attached_node(p, n, group_rating)
		local def = core.registered_nodes[n.name]
		local d = vector.zero()
		if group_rating == 3 then
			-- always attach to floor
			d.y = -1
		elseif group_rating == 4 then
			-- always attach to ceiling
			d.y = 1
		elseif group_rating == 2 then
			-- attach to facedir or 4dir direction
			if (def.paramtype2 == "facedir" or
				def.paramtype2 == "colorfacedir") then
				-- Attach to whatever facedir is "mounted to".
				-- For facedir, this is where tile no. 5 point at.

				-- The fallback vector here is in case 'facedir to dir' is nil due
				-- to voxelmanip placing a wallmounted node without resetting a
				-- pre-existing param2 value that is out-of-range for facedir.
				-- The fallback vector corresponds to param2 = 0.
				d = core.facedir_to_dir(n.param2) or vector.new(0, 0, 1)
			elseif (def.paramtype2 == "4dir" or
				def.paramtype2 == "color4dir") then
				-- Similar to facedir handling
				d = core.fourdir_to_dir(n.param2) or vector.new(0, 0, 1)
			end
		elseif def.paramtype2 == "wallmounted" or
			def.paramtype2 == "colorwallmounted" then
			-- Attach to whatever this node is "mounted to".
			-- This where tile no. 2 points at.

			-- The fallback vector here is used for the same reason as
			-- for facedir nodes.
			d = core.wallmounted_to_dir(n.param2) or vector.new(0, 1, 0)
		else
			d.y = -1
		end
		local p2 = vector.add(p, d)
		local nn = core.get_node(p2).name
		local def2 = core.registered_nodes[nn]

		return not def2 or def2.walkable
	end

	-- Copied from minetest builtin
	-- https://github.com/minetest/minetest/blob/e7dd9737bd5deb573c9fef7b3ff2ead29b2cfe31/builtin/game/item.lua#L146-L294
	return function(itemstack, placer, pointed_thing, param2)
		local def = itemstack:get_definition()
		if def.type ~= "node" or pointed_thing.type ~= "node" then
			return itemstack
		end
		---@cast def core.NodeDef

		local under = pointed_thing.under
		local oldnode_under = core.get_node_or_nil(under)
		local above = pointed_thing.above
		local oldnode_above = core.get_node_or_nil(above)
		local playername = user_name(placer)
		local log = make_log(playername)

		if not oldnode_under or not oldnode_above then
			log("info", playername .. " tried to place"
				.. " node in unloaded position " .. core.pos_to_string(above))
			return itemstack
		end

		local olddef_under = core.registered_nodes[oldnode_under.name] or core.nodedef_default
		local olddef_above = core.registered_nodes[oldnode_above.name] or core.nodedef_default

		if not olddef_above.buildable_to and not olddef_under.buildable_to then
			log("info", playername .. " tried to place"
				.. " node in invalid position " .. core.pos_to_string(above)
				.. ", replacing " .. oldnode_above.name)
			return itemstack
		end

		-- Place above pointed node
		local place_to = above

		-- If node under is buildable_to, check for callback result and place into it instead
		-- This line was modified from minetest code to allow overriding builtable_to
		if olddef_under.buildable_to and not func(oldnode_under.name) then
			log("info", "node under is buildable to")
			place_to = under
		end

		if core.is_protected(place_to, playername) then
			log("action", playername
				.. " tried to place " .. def.name
				.. " at protected position "
				.. core.pos_to_string(place_to))
			core.record_protection_violation(place_to, playername)
			return itemstack
		end

		local oldnode = core.get_node(place_to)
		local newnode = {name = def.name, param1 = 0, param2 = param2 or 0}

		-- Calculate direction for wall mounted stuff like torches and signs
		if def.place_param2 ~= nil then
			newnode.param2 = def.place_param2
		elseif (def.paramtype2 == "wallmounted" or
			def.paramtype2 == "colorwallmounted") and not param2 then
			newnode.param2 = core.dir_to_wallmounted(vector.subtract(under, above))
			-- Calculate the direction for furnaces and chests and stuff
		elseif (def.paramtype2 == "facedir" or
			def.paramtype2 == "colorfacedir" or
			def.paramtype2 == "4dir" or
			def.paramtype2 == "color4dir") and not param2 then
			local placer_pos = placer and placer:get_pos()
			if placer_pos then
				newnode.param2 = core.dir_to_facedir(vector.subtract(above, placer_pos))
				log("info", "facedir: " .. newnode.param2)
			end
		end

		local metatable = itemstack:get_meta():to_table().fields

		-- Transfer color information
		if metatable.palette_index and not def.place_param2 then
			local color_divisor = nil
			if def.paramtype2 == "color" then
				color_divisor = 1
			elseif def.paramtype2 == "colorwallmounted" then
				color_divisor = 8
			elseif def.paramtype2 == "colorfacedir" then
				color_divisor = 32
			elseif def.paramtype2 == "color4dir" then
				color_divisor = 4
			elseif def.paramtype2 == "colordegrotate" then
				color_divisor = 32
			end
			if color_divisor then
				local color = math.floor(metatable.palette_index / color_divisor)
				local other = newnode.param2 % color_divisor
				newnode.param2 = color * color_divisor + other
			end
		end

		-- Check if the node is attached and if it can be placed there
		local an = core.get_item_group(def.name, "attached_node")
		if an ~= 0 and
			not check_attached_node(place_to, newnode, an) then
			log("action", "attached node " .. def.name ..
				" cannot be placed at " .. core.pos_to_string(place_to))
			return itemstack
		end

		log("action", playername .. " places node "
			.. def.name .. " at " .. core.pos_to_string(place_to))

		-- Add node and update
		core.add_node(place_to, newnode)

		-- Play sound if it was done by a player
		if playername ~= "" and def.sounds and def.sounds.place then
			core.sound_play(def.sounds.place, {
				pos = place_to,
				exclude_player = playername,
			}, true)
		end

		local take_item = true

		-- Run callback
		if def.after_place_node then
			-- Deepcopy place_to and pointed_thing because callback can modify it
			local place_to_copy = vector.copy(place_to)
			local pointed_thing_copy = copy_pointed_thing(pointed_thing)
			if def.after_place_node(place_to_copy, placer, itemstack,
				pointed_thing_copy) then
				take_item = false
			end
		end

		-- Run script hook
		for _, callback in ipairs(core.registered_on_placenodes) do
			-- Deepcopy pos, node and pointed_thing because callback can modify them
			local place_to_copy = vector.copy(place_to)
			local newnode_copy = {name = newnode.name, param1 = newnode.param1, param2 = newnode.param2}
			local oldnode_copy = {name = oldnode.name, param1 = oldnode.param1, param2 = oldnode.param2}
			local pointed_thing_copy = copy_pointed_thing(pointed_thing)
			if callback(place_to_copy, newnode_copy, placer, oldnode_copy, itemstack, pointed_thing_copy) then
				take_item = false
			end
		end

		if take_item then
			itemstack:take_item()
		end
		return itemstack
	end
end

---@class mcl_util.PaletteIndices
---@field grass_palette_index integer
---@field foliage_palette_index integer
---@field water_palette_index integer

---@type mcl_util.PaletteIndices
local DEFAULT_PALETTE_INDEXES = {
	grass_palette_index = 0,
	foliage_palette_index = 0,
	water_palette_index = 0
}

---@param pos Vector
---@return mcl_util.PaletteIndices
function mcl_util.get_palette_indexes_from_pos(pos)
	local biome_data = core.get_biome_data(pos)
	if not biome_data then
		return DEFAULT_PALETTE_INDEXES
	end
	local biome = biome_data.biome
	local biome_name = core.get_biome_name(biome)
	local reg_biome = core.registered_biomes[biome_name]
	if reg_biome
		and reg_biome._mcl_grass_palette_index 
		and reg_biome._mcl_foliage_palette_index
		and reg_biome._mcl_water_palette_index
	then
		return {
			grass_palette_index = reg_biome._mcl_grass_palette_index,
			foliage_palette_index = reg_biome._mcl_foliage_palette_index,
			water_palette_index = reg_biome._mcl_water_palette_index,
		}
	else
		return DEFAULT_PALETTE_INDEXES
	end
end

---@param pos Vector
function mcl_util.get_colorwallmounted_rotation(pos)
	local colorwallmounted_node = core.get_node(pos)
	for i = 0, 32, 1 do
		local colorwallmounted_rotation = colorwallmounted_node.param2 - (i * 8)
		if colorwallmounted_rotation < 6 then
			return colorwallmounted_rotation
		end
	end
end

function mcl_util.match_node_to_filter(node_name, filters)
	for i = 1,#filters do
		local filter = filters[i]
		if node_name == filter then return true end

		if string.sub(filter,1,6) == "group:" and core.get_item_group(node_name, string.sub(filter,7)) ~= 0 then
			return true
		end
	end

	return false
end

