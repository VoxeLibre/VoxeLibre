mcl_util = {}

local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
dofile(modpath.."/roman_numerals.lua")
dofile(modpath.."/nodes.lua")
dofile(modpath.."/table.lua")
dofile(modpath.."/hashing.lua")

local LOGGING_ON = minetest.settings:get_bool("mcl_logging_default", false)
local LOG_MODULE = "[MCL2]"
function mcl_util.mcl_log(message, module, bypass_default_logger)
	local selected_module = LOG_MODULE
	if module then
		selected_module = module
	end
	if (bypass_default_logger or LOGGING_ON) and message then
		minetest.log(selected_module .. " " .. message)
	end
end
function mcl_util.make_mcl_logger(label, option)
	-- Return dummy function if debug option isn't set
	if not minetest.settings:get_bool(option,false) then return function() end, false end

	local label_text = "["..tostring(label).."]"
	return function(message)
		mcl_util.mcl_log(message, label_text, true)
	end, true
end

local player_timers = {}

-- This is a dtime timer than can be used in on_step functions so it works every x seconds
-- self - Object you want to store timer data on. E.g. mob or a minecart, or player_name
-- dtime - The time since last run of on_step, should be passed in to function
-- timer_name - This is the name of the timer and also the key to store the data. No spaces + lowercase.
-- threshold - The time before it returns successful. 0.2 if you want to run it 5 times a second.
function mcl_util.check_dtime_timer(self, dtime, timer_name, threshold)
	if not self or not threshold or not dtime then return end
	if not timer_name or timer_name == "" then return end

	if type(self) == "string" then
		local player_name = self
		if not player_timers[player_name] then
			player_timers[player_name] = {}
		end
		self = player_timers[player_name]
	end

	if not self._timers then
		self._timers = {}
	end

	if not self._timers[timer_name] then
		self._timers[timer_name] = 0
	else
		self._timers[timer_name] = self._timers[timer_name] + dtime
		--minetest.log("dtime: " .. tostring(self._timers[timer_name]))
	end

	if self._timers[timer_name] > threshold then
		--minetest.log("Over threshold")
		self._timers[timer_name] = 0
		return true
		--else
		--minetest.log("Not over threshold")
	end
	return false
end

-- While we should always favour the new minetest vector functions such as vector.new or vector.offset which validate on
-- creation. There may be cases where state gets corrupted and we may have to check the vector is valid if created the
-- old way. This allows us to do this as a tactical solution until old style vectors are completely removed.
function mcl_util.validate_vector (vect)
	if vect then
		if tonumber(vect.x) and tonumber(vect.y) and tonumber(vect.z) then
			return true
		end
	end
	return false
end

function mcl_util.file_exists(name)
	if type(name) ~= "string" then return end
	local f = io.open(name)
	if not f then
		return false
	end
	f:close()
	return true
end

--- Selects item stack to transfer from
---@param src_inventory InvRef Source innentory to pull from
---@param src_list string Name of source inventory list to pull from
---@param dst_inventory InvRef Destination inventory to push to
---@param dst_list string Name of destination inventory list to push to
---@param condition? fun(stack: ItemStack) Condition which items are allowed to be transfered.
---@param count? integer Number of items to try to transfer at once
---@return integer Item stack number to be transfered
function mcl_util.select_stack(src_inventory, src_list, dst_inventory, dst_list, condition, count)
	local src_size = src_inventory:get_size(src_list)
	local stack
	for i = 1, src_size do
		stack = src_inventory:get_stack(src_list, i)

		-- Allow for partial stack movement
		if count and stack:get_count() >= count then
			local new_stack = ItemStack(stack)
			new_stack:set_count(count)
			stack = new_stack
		end

		if not stack:is_empty() and dst_inventory:room_for_item(dst_list, stack) and ((condition == nil or condition(stack))) then
			return i
		end
	end
	return nil
end

-- Moves a single item from one inventory to another.
--- source_inventory: Inventory to take the item from
--- source_list: List name of the source inventory from which to take the item
--- source_stack_id: The inventory position ID of the source inventory to take the item from (-1 for first occupied slot)
--- destination_inventory: Put item into this inventory
--- destination_list: List name of the destination inventory to which to put the item into

-- Returns true on success and false on failure
-- Possible failures: No item in source slot, destination inventory full
function mcl_util.move_item(source_inventory, source_list, source_stack_id, destination_inventory, destination_list)
	-- Can't move items we don't have
	if source_inventory:is_empty(source_list) then return false end

	-- Can't move from an empty stack
	local stack = source_inventory:get_stack(source_list, source_stack_id)
	if stack:is_empty() then return false end

	local new_stack = ItemStack(stack)
	new_stack:set_count(1)
	if not destination_inventory:room_for_item(destination_list, new_stack) then
		return false
	end
	stack:take_item()
	source_inventory:set_stack(source_list, source_stack_id, stack)
	destination_inventory:add_item(destination_list, new_stack)
	return true, new_stack
end

--- Try pushing item from hopper inventory to destination inventory
---@param pos Vector
---@param dst_pos Vector
function mcl_util.hopper_push(pos, dst_pos)
	local hop_inv = minetest.get_meta(pos):get_inventory()
	local hop_list = 'main'

	-- Get node pos' for item transfer
	local dst = minetest.get_node(dst_pos)
	if not minetest.registered_nodes[dst.name] then return end
	local dst_type = minetest.get_item_group(dst.name, "container")
	if dst_type ~= 2 then return end
	local dst_def = minetest.registered_nodes[dst.name]

	local dst_list = 'main'
	local dst_inv, stack_id

	-- Find a inventory stack in the destination
	if dst_def._mcl_hoppers_on_try_push then
		dst_inv, dst_list, stack_id = dst_def._mcl_hoppers_on_try_push(dst_pos, pos, hop_inv, hop_list)
	else
		local dst_meta = minetest.get_meta(dst_pos)
		dst_inv = dst_meta:get_inventory()
		stack_id = mcl_util.select_stack(hop_inv, hop_list, dst_inv, dst_list, nil, 1)
	end
	if not stack_id then return false end

	-- Move the item
	local ok, stack = mcl_util.move_item(hop_inv, hop_list, stack_id, dst_inv, dst_list)
	if ok and dst_def._mcl_hoppers_on_after_push then
		dst_def._mcl_hoppers_on_after_push(dst_pos, dst_list, stack)
	end

	return ok
end

function mcl_util.hopper_pull_to_inventory(hop_inv, hop_list, src_pos, pos)
	-- Get node pos' for item transfer
	local src = minetest.get_node(src_pos)
	if not minetest.registered_nodes[src.name] then return end
	local src_type = minetest.get_item_group(src.name, "container")
	if src_type ~= 2 then return end
	local src_def = minetest.registered_nodes[src.name]

	local src_list = 'main'
	local src_inv, stack_id

	if src_def._mcl_hoppers_on_try_pull then
		src_inv, src_list, stack_id = src_def._mcl_hoppers_on_try_pull(src_pos, pos, hop_inv, hop_list)
	else
		local src_meta = minetest.get_meta(src_pos)
		src_inv = src_meta:get_inventory()
		stack_id = mcl_util.select_stack(src_inv, src_list, hop_inv, hop_list)
	end

	if stack_id ~= nil then
		local ok = mcl_util.move_item(src_inv, src_list, stack_id, hop_inv, hop_list)
		if src_def._mcl_hoppers_on_after_pull then
			src_def._mcl_hoppers_on_after_pull(src_pos)
		end
	end
end
-- Try pulling from source inventory to hopper inventory
---@param pos Vector
---@param src_pos Vector
function mcl_util.hopper_pull(pos, src_pos)
	return mcl_util.hopper_pull_to_inventory(minetest.get_meta(pos):get_inventory(), "main", src_pos, pos)
end

local function drop_item_stack(pos, stack)
	if not stack or stack:is_empty() then return end
	local drop_offset = vector.new(math.random() - 0.5, 0, math.random() - 0.5)
	minetest.add_item(vector.add(pos, drop_offset), stack)
end

function mcl_util.drop_items_from_meta_container(listname)
	return function(pos, _, oldmeta)
		if oldmeta and oldmeta.inventory then
			local main = oldmeta.inventory[listname]
			if not main then
				return
			end
			for _, stack in pairs(main) do
				drop_item_stack(pos, stack)
			end
			return
		end
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		for i = 1, inv:get_size("main") do
			drop_item_stack(pos, inv:get_stack("main", i))
		end
	end
end

-- Returns true if item (itemstring or ItemStack) can be used as a furnace fuel.
-- Returns false otherwise
function mcl_util.is_fuel(item)
	return minetest.get_craft_result({method = "fuel", width = 1, items = {item}}).time ~= 0
end

-- adjust the y level of an object to the center of its collisionbox
-- used to get the origin position of entity explosions
function mcl_util.get_object_center(obj)
	local collisionbox = obj:get_properties().collisionbox
	local pos = obj:get_pos()
	local ymin = collisionbox[2]
	local ymax = collisionbox[5]
	pos.y = pos.y + (ymax - ymin) / 2.0
	return pos
end

function mcl_util.get_color(colorstr)
	local mc_color = mcl_colors[colorstr:upper()]
	if mc_color then
		colorstr = mc_color
	elseif #colorstr ~= 7 or colorstr:sub(1, 1) ~= "#" then
		return
	end
	local hex = tonumber(colorstr:sub(2, 7), 16)
	if hex then
		return colorstr, hex
	end
end

function mcl_util.call_on_rightclick(itemstack, player, pointed_thing)
	-- Call on_rightclick if the pointed node defines it
	if pointed_thing and pointed_thing.type == "node" then
		local pos = pointed_thing.under
		local node = minetest.get_node(pos)
		if player and not player:get_player_control().sneak then
			local nodedef = minetest.registered_nodes[node.name]
			local on_rightclick = nodedef and nodedef.on_rightclick
			if on_rightclick then
				return on_rightclick(pos, node, player, itemstack, pointed_thing) or itemstack
			end
		end
	end
end

--- TODO: replace with global right-click handler patched in with core.on_register_mods_loaded()
function mcl_util.handle_node_rightclick(itemstack, player, pointed_thing)
	-- Call on_rightclick if the pointed node defines it
	if pointed_thing and pointed_thing.type == "node" then
		local pos = pointed_thing.under
		local node = minetest.get_node(pos)
		if player and not player:get_player_control().sneak then
			local nodedef = minetest.registered_nodes[node.name]
			local on_rightclick = nodedef and nodedef.on_rightclick
			if on_rightclick then
				return on_rightclick(pos, node, player, itemstack, pointed_thing) or itemstack, true
			end
		end
	end
	return itemstack, false
end

function mcl_util.calculate_durability(itemstack)
	local unbreaking_level = mcl_enchanting.get_enchantment(itemstack, "unbreaking")
	local armor_uses = minetest.get_item_group(itemstack:get_name(), "mcl_armor_uses")

	local uses

	if armor_uses > 0 then
		uses = armor_uses
		if unbreaking_level > 0 then
			uses = uses / (0.6 + 0.4 / (unbreaking_level + 1))
		end
	else
		local def = itemstack:get_definition()
		if def then
			local fixed_uses = def._mcl_uses
			if fixed_uses then
				uses = fixed_uses
				if unbreaking_level > 0 then
					uses = uses * (unbreaking_level + 1)
				end
			end
		end

		local _, groupcap = next(itemstack:get_tool_capabilities().groupcaps)
		uses = uses or (groupcap or {}).uses
	end

	return uses or 0
end

function mcl_util.use_item_durability(itemstack, n)
	local uses = mcl_util.calculate_durability(itemstack)
	itemstack:add_wear(65535 / uses * n)
	tt.reload_itemstack_description(itemstack) -- update tooltip
end

local function find_attacker_name(mcl_reason)
	if not mcl_reason then
		return nil
	end
	local e = mcl_reason.direct and mcl_reason.direct:get_luaentity()
	if e and e.name then
		return e.name
	end
	e = mcl_reason.source and mcl_reason.source:get_luaentity()
	if e and e.name then
		return e.name
	end
	return nil
end

---
--- @param target core.ObjectRef
--- @param damage number
--- @param mcl_reason {type: string, direct: any?, source: any?}?
function mcl_util.deal_damage(target, damage, mcl_reason)
	local luaentity = target:get_luaentity()
	local hp        = target:get_hp()

	if luaentity then
		if luaentity.deal_damage then
			luaentity:deal_damage(damage, mcl_reason or {type = "generic"})
			return
		elseif luaentity.is_mob then
			local reason        = (mcl_reason and mcl_reason.type) or "generic"
			local attacker_name = find_attacker_name(mcl_reason)
			luaentity:damage_mob(reason, damage, { attacker_name = attacker_name })
			return
		end
	elseif not target:is_player() then
		return
	end

	local is_immortal = target:get_armor_groups().immortal or 0
	if is_immortal>0 then
		return
	end

	if hp > 0 then
		target:set_hp(hp - damage, {_mcl_reason = mcl_reason})
	end
end

function mcl_util.get_hp(obj)
	local luaentity = obj:get_luaentity()

	if luaentity and luaentity.is_mob then
		return luaentity.health
	else
		return obj:get_hp()
	end
end

function mcl_util.get_inventory(object, create)
	if object:is_player() then
		return object:get_inventory()
	else
		local luaentity = object:get_luaentity()
		local inventory = luaentity.inventory

		if create and not inventory and luaentity.create_inventory then
			inventory = luaentity:create_inventory()
		end

		return inventory
	end
end

function mcl_util.get_wielded_item(object)
	if object:is_player() then
		return object:get_wielded_item()
	else
		-- ToDo: implement getting wielditems from mobs as soon as mobs have wielditems
		return ItemStack()
	end
end

function mcl_util.get_object_name(object)
	if object:is_player() then
		return object:get_player_name()
	else
		local luaentity = object:get_luaentity()

		if not luaentity then
			return tostring(object)
		end

		return luaentity.nametag and luaentity.nametag ~= "" and luaentity.nametag or luaentity.description or luaentity.name
	end
end

function mcl_util.replace_mob(obj, mob)
	if not obj then return end
	local rot = obj:get_yaw()
	local pos = obj:get_pos()
	obj:remove()
	obj = minetest.add_entity(pos, mob)
	if not obj then return end
	obj:set_yaw(rot)
	return obj
end

function mcl_util.get_pointed_thing(player, liquid)
	local pos = vector.offset(player:get_pos(), 0, player:get_properties().eye_height, 0)
	local look_dir = vector.multiply(player:get_look_dir(), 5)
	local pos2 = vector.add(pos, look_dir)
	local ray = minetest.raycast(pos, pos2, false, liquid)

	if ray then
		for pointed_thing in ray do
			return pointed_thing
		end
	end
end

-- This following part is 2 wrapper functions + helpers for
-- object:set_bones
-- and player:set_properties preventing them from being resent on
-- every globalstep when they have not changed.

local function roundN(n, d)
	if type(n) ~= "number" then return n end
	local m = 10 ^ d
	return math.floor(n * m + 0.5) / m
end

local function close_enough(a, b)
	local rt = true
	if type(a) == "table" and type(b) == "table" then
		for k, v in pairs(a) do
			if roundN(v, 2) ~= roundN(b[k], 2) then
				rt = false
				break
			end
		end
	else
		rt = roundN(a, 2) == roundN(b, 2)
	end
	return rt
end

local function props_changed(props, oldprops)
	local changed = false
	local p = {}
	for k, v in pairs(props) do
		if not close_enough(v, oldprops[k]) then
			p[k] = v
			changed = true
		end
	end
	return changed, p
end

if core.get_modpath("vl_unit_testing") then
	mcl_util.roundN = roundN
	mcl_util.close_enough = close_enough
	mcl_util.props_changed = props_changed
end

function mcl_util.set_properties(obj, props)
	local changed, p = props_changed(props, obj:get_properties())
	if changed then
		obj:set_properties(p)
	end
end

local vector_distance, vector_zero = vector.distance, vector.zero

-- Update bones, but only when changed
function mcl_util.set_bone_position(obj, bone, pos, rot, scale)
	local current_pos, current_rot
	if obj.set_bone_override then -- Luanti >= 5.9
		do
			local ov = obj:get_bone_override(bone)
			current_pos, current_rot = ov.position.vec, ov.rotation.vec
		end

		-- Only apply when the values aren't the same:
		-- Compare the distance between new and old vectors against an epsilon.
		local pos_equal = vector_distance(current_pos, pos or vector_zero()) < 1
		-- The epsilon is 0.1 as the new API uses radians and more precision is neccesary.
		local rot_equal = vector_distance(current_rot, rot or vector_zero()) < 0.1
		if not pos_equal or not rot_equal then
			obj:set_bone_override(bone, {
				position = pos and {vec = pos, absolute = true, interpolation = 0.1} or nil,
				rotation = rot and {vec = rot, absolute = true, interpolation = 0.1} or nil,
				scale = scale and {vec = scale, absolute = true, interpolation = 0.1} or nil,
			})
		end
	else -- Luanti <= 5.8
		rot = rot and rot:apply(math.deg)
		current_pos, current_rot = obj:get_bone_position(bone)

		local pos_equal = vector_distance(current_pos, pos or current_pos) < 1
		local rot_equal = vector_distance(current_rot, rot or current_rot) < 1
		if not pos_equal or not rot_equal then
			obj:set_bone_position(bone, pos or current_pos, rot or current_rot)
		end
	end
end

--[[Check for a protection violation in a given area.
--
-- Applies is_protected() to a 3D lattice of points in the defined volume. The points are spaced
-- evenly throughout the volume and have a spacing similar to, but no larger than, "interval".
--
-- @param pos1          A position table of the area volume's first edge.
-- @param pos2          A position table of the area volume's second edge.
-- @param player        The player performing the action.
-- @param interval	    Optional. Max spacing between checked points at the volume.
--      Default: Same as minetest.is_area_protected.
--
-- @return	true on protection violation detection. false otherwise.
--
-- @notes   *All corners and edges of the defined volume are checked.
]]
function mcl_util.check_area_protection(pos1, pos2, player, interval)
	local name = player and player:get_player_name() or ""

	local protected_pos = minetest.is_area_protected(pos1, pos2, name, interval)
	if protected_pos then
		minetest.record_protection_violation(protected_pos, name)
		return true
	end

	return false
end

--[[Check for a protection violation on a single position.
--
-- @param position      A position table to check for protection violation.
-- @param player        The player performing the action.
--
-- @return	true on protection violation detection. false otherwise.
]]
function mcl_util.check_position_protection(position, player)
	local name = player and player:get_player_name() or ""

	if minetest.is_protected(position, name) then
		minetest.record_protection_violation(position, name)
		return true
	end

	return false
end

---Move items from one inventory list to another, drop items that do not fit in provided pos and direction.
---@param src_inv mt.InvRef
---@param src_listname string
---@param out_inv mt.InvRef
---@param out_listname string
---@param pos mt.Vector Position to throw items at
---@param dir? mt.Vector Direction to throw items in
---@param insta_collect? boolean Enable instant collection, let players collect dropped items instantly. Default `false`
function mcl_util.move_list(src_inv, src_listname, out_inv, out_listname, pos, dir, insta_collect)
	local src_list = src_inv:get_list(src_listname)

	if not src_list then return end
	for i, stack in ipairs(src_list) do
		if out_inv:room_for_item(out_listname, stack) then
			out_inv:add_item(out_listname, stack)
		else
			local p = vector.copy(pos)
			p.x = p.x + (math.random(1, 3) * 0.2)
			p.z = p.z + (math.random(1, 3) * 0.2)

			local obj = minetest.add_item(p, stack)
			if obj then
				if dir then
					local v = vector.copy(dir)
					v.x = v.x * 4
					v.y = v.y * 4 + 2
					v.z = v.z * 4
					obj:set_velocity(v)
					mcl_util.mcl_log("item velocity calculated "..vector.to_string(v), "[mcl_util]")
				end
				if not insta_collect then
					obj:get_luaentity()._insta_collect = false
				end
			end
		end

		stack:clear()
		src_inv:set_stack(src_listname, i, stack)
	end
end

---Move items from a player's inventory list to its main inventory list, drop items that do not fit in front of him.
---@param player mt.PlayerObjectRef
---@param src_listname string
function mcl_util.move_player_list(player, src_listname)
	mcl_util.move_list(player:get_inventory(), src_listname, player:get_inventory(), "main",
		vector.offset(player:get_pos(), 0, 1.2, 0),
		player:get_look_dir(), false)
end

local christmas_deco = minetest.settings:get("vl_christmas_decorations") or "Calendar"

function mcl_util.is_it_christmas()
	local date = os.date("*t")
	local date_is_christmas = (date.month == 12 and date.day >= 24 or date.month == 1 and date.day <= 7)

	return christmas_deco == "Always"
		or (christmas_deco == "Calendar" and date_is_christmas)
		or false
end

function mcl_util.to_bool(val)
	if not val then return false end
	return true
end

if not vector.in_area then
	-- backport from minetest 5.8, can be removed when the minimum version is 5.8
	vector.in_area = function(pos, min, max)
		return (pos.x >= min.x) and (pos.x <= max.x) and
		       (pos.y >= min.y) and (pos.y <= max.y) and
		       (pos.z >= min.z) and (pos.z <= max.z)
	end
end
if not core.bulk_swap_node then
	function core.bulk_swap_node(positions, node)
		for _,pos in ipairs(positions) do
			core.swap_node(pos, node)
		end
	end
end

-- Traces along a line of nodes vertically to find the next possition that isn't an allowed node
---@param pos The position to start tracing from
---@param dir The direction to trace in. 1 is up, -1 is down, all other values are not allowed.
---@param allowed_nodes A set of node names to trace along.
---@param limit The maximum number of steps to make. Defaults to 16 if nil or missing
---@return Three return values:
---   the position of the next node that isn't allowed or nil if no such node was found,
---   the distance from the start where that node was found,
---   the node table if a node was found
function mcl_util.trace_nodes(pos, dir, allowed_nodes, limit)
	if (dir ~= -1) and (dir ~= 1) then return nil, 0, nil end
	limit = limit or 16

	for i = 1,limit do
		pos = vector.offset(pos, 0, dir, 0)
		local node = minetest.get_node(pos)
		if not allowed_nodes[node.name] then return pos, i, node end
	end

	return nil, limit, nil
end

-- Make a local random to guard against someone misusing math.randomseed
local uuid_rng = PcgRandom(bit.bxor(math.floor(math.random() * 0xFFFFFFFF), os.time()))
--- Generate a random 128-bit ID that can be assumed to be unique
--- To have a 1% chance of a collision, there would have to be 1.6x10^76 IDs generated
--- https://en.wikipedia.org/wiki/Birthday_problem#Probability_table
--- @param len32 integer: length in 32-bit units, optional, default 4 (128 bit)
--- @return string: UUID string, 8xlen32 characters, default 32
function mcl_util.gen_uuid(len32)
	len32 = (len32 and len32 > 0) and len32 or 4 -- len32 might be nil
	local u = {}
	for i = 1,len32 do
		u[#u + 1] = bit.tohex(uuid_rng:next()) -- 32 bit at a time
	end
	return table.concat(u)
end
function mcl_util.get_entity_id(entity)
	if entity.object then entity = entity.object end

	if entity:is_player() then
		return entity:get_player_name()
	else
		local le = entity:get_luaentity()
		local id = le._uuid
		if not id then
			id = mcl_util.gen_uuid()
			le._uuid = id
		end
		return id
	end
end
function mcl_util.remove_entity(luaentity)
	if luaentity._removed then return end
	luaentity._removed = true

	local hook = luaentity._on_remove
	if hook then hook(luaentity) end

	luaentity.object:remove()
end
local function table_merge(base, overlay)
	for k,v in pairs(overlay) do
		if type(base[k]) == "table" and type(v) == "table" then
			table_merge(base[k], v)
		else
			base[k] = v
		end
	end
	return base
end
mcl_util.table_merge = table_merge

function mcl_util.table_keys(t)
	local keys = {}
	for k,_ in pairs(t) do
		keys[#keys + 1] = k
	end
	return keys
end

local uuid_to_aoid_cache = {}
local function scan_active_objects()
	-- Update active object ids for all active objects
	for active_object_id,o in pairs(minetest.luaentities) do
		o._active_object_id = active_object_id
		if o._uuid then
			uuid_to_aoid_cache[o._uuid] = active_object_id
		end
	end
end
function mcl_util.get_active_object_id(obj)
	local le = obj:get_luaentity()

	-- If the active object id in the lua entity is correct, return that
	if le._active_object_id and minetest.luaentities[le._active_object_id] == le then
		return le._active_object_id
	end

	scan_active_objects()

	return le._active_object_id
end
function mcl_util.get_active_object_id_from_uuid(uuid)
	return uuid_to_aoid_cache[uuid] or scan_active_objects() or uuid_to_aoid_cache[uuid]
end
function mcl_util.get_luaentity_from_uuid(uuid)
	return minetest.luaentities[ mcl_util.get_active_object_id_from_uuid(uuid) ]
end
function mcl_util.assign_uuid(obj)
	assert(obj)

	local le = obj:get_luaentity()
	if not le._uuid then
		le._uuid = mcl_util.gen_uuid()
	end

	-- Update the cache with this new id
	local aoid = mcl_util.get_active_object_id(obj)
	uuid_to_aoid_cache[le._uuid] = aoid

	return le._uuid
end
function mcl_util.metadata_last_act(meta, name, delay)
	local last_act = meta:get_float(name)
	local now = minetest.get_us_time() * 1e-6
	if last_act > now + 0.5 then
		-- Last action was in the future, clock went backwards, so reset
	elseif last_act >= now - delay then
		return false
	end

	meta:set_float(name, now)
	return true
end

-- Functions for comparing versions. These better fit mcl_util, but are used early
mcl_util.parse_version = mcl_vars.parse_version
mcl_util.minimum_version = mcl_vars.minimum_version
mcl_util.format_version = mcl_vars.format_version

