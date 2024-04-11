local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local mod = mcl_minecarts
local S = minetest.get_translator(modname)

local mcl_log = mcl_util.make_mcl_logger("mcl_logging_minecarts", "Minecarts")

-- Imports
local CART_BLOCK_SIZE = mod.CART_BLOCK_SIZE
local table_merge = mcl_util.table_merge
local get_cart_data = mod.get_cart_data
local save_cart_data = mod.save_cart_data
local update_cart_data = mod.update_cart_data
local destroy_cart_data = mod.destroy_cart_data
local find_carts_by_block_map = mod.find_carts_by_block_map
local do_movement,do_detached_movement,handle_cart_enter = dofile(modpath.."/movement.lua")
assert(do_movement)
assert(do_detached_movement)
assert(handle_cart_enter)

-- Constants
local max_step_distance = 0.5
local MINECART_MAX_HP = 4

local function detach_driver(self)
	local staticdata = self._staticdata

	if not self._driver then
		return
	end

	-- Update player infomation
	local driver_name = self._driver
	local playerinfo = mcl_playerinfo[driver_name]
	if playerinfo then
		playerinfo.attached_to = nil
	end
	mcl_player.player_attached[driver_name] = nil

	minetest.log("action", driver_name.." left a minecart")

	-- Update cart informatino
	self._driver = nil
	self._start_pos = nil

	-- Detatch the player object from the minecart
	local player = minetest.get_player_by_name(driver_name)
	if player then
		local dir = staticdata.dir or vector.new(1,0,0)
		local cart_pos = mod.get_cart_position(staticdata) or self.object:get_pos()
		local new_pos = vector.offset(cart_pos, -dir.z, 0, dir.x)
		player:set_detach()
		print("placing player at "..tostring(new_pos).." from cart at "..tostring(cart_pos)..", old_pos="..tostring(player:get_pos()).."dir="..tostring(dir))

		-- There needs to be a delay here or the player's position won't update
		minetest.after(0.1,function(driver_name,new_pos)
			local player = minetest.get_player_by_name(driver_name)
			player:moveto(new_pos, false)
		end, driver_name, new_pos)

		player:set_eye_offset(vector.new(0,0,0),vector.new(0,0,0))
		mcl_player.player_set_animation(player, "stand" , 30)
	else
		print("No player object found for "..driver_name)
	end
end

-- Table for item-to-entity mapping. Keys: itemstring, Values: Corresponding entity ID
local entity_mapping = {}

local function make_staticdata( _, connected_at, dir )
	return {
		connected_at = connected_at,
		distance = 0,
		velocity = 0,
		dir = vector.new(dir),
		mass = 1,
		seq = 1,
	}
end

local DEFAULT_CART_DEF = {
	initial_properties = {
		physical = true,
		collisionbox = {-10/16., -0.5, -10/16, 10/16, 0.25, 10/16},
		visual = "mesh",
		visual_size = {x=1, y=1},
	},

	hp_max = MINECART_MAX_HP,

	groups = {
		minecart = 1,
	},

	_driver = nil, -- player who sits in and controls the minecart (only for minecart!)
	_passenger = nil, -- for mobs
	_start_pos = nil, -- Used to calculate distance for “On A Rail” achievement
	_last_float_check = nil, -- timestamp of last time the cart was checked to be still on a rail
	_boomtimer = nil, -- how many seconds are left before exploding
	_blinktimer = nil, -- how many seconds are left before TNT blinking
	_blink = false, -- is TNT blink texture active?
	_old_pos = nil,
	_staticdata = nil,
}
function DEFAULT_CART_DEF:on_activate(staticdata, dtime_s)
	-- Transfer older data
	local data = minetest.deserialize(staticdata) or {}
	if not data.uuid then
		data.uuid  = mcl_util.assign_uuid(self.object)
	end
	self._seq = data.seq or 1

	local cd = get_cart_data(data.uuid)
	if not cd then
		update_cart_data(data)
	else
		if not cd.seq then cd.seq = 1 end
		data = cd
	end

	-- Fix up types
	data.dir = vector.new(data.dir)

	-- Fix mass
	data.mass = data.mass or 1

	-- Make sure all carts have an ID to isolate them
	self._uuid = data.uuid
	self._staticdata = data

	-- Activate cart if on powered activator rail
	if self.on_activate_by_rail then
		local pos = self.object:get_pos()
		local node = minetest.get_node(vector.floor(pos))
		if node.name == "mcl_minecarts:activator_rail_on" then
			self:on_activate_by_rail()
		end
	end
end
function DEFAULT_CART_DEF:get_staticdata()
	save_cart_data(self._staticdata.uuid)
	return minetest.serialize({uuid = self._staticdata.uuid, seq=self._seq})
end

function DEFAULT_CART_DEF:add_node_watch(pos)
	local staticdata = self._staticdata
	local watches = staticdata.node_watches or {}

	for _,watch in ipairs(watches) do
		if watch == pos then return end
	end

	watches[#watches+1] = pos
	staticdata.node_watches = watches
end
function DEFAULT_CART_DEF:remove_node_watch(pos)
	local staticdata = self._staticdata
	local watches = staticdata.node_watches or {}

	local new_watches = {}
	for _,node_pos in ipairs(watches) do
		if node_pos ~= pos then
			new_watches[#new_watches] = node_pos
		end
	end
	staticdata.node_watches = new_watches
end
function DEFAULT_CART_DEF:get_cart_position()
	local staticdata = self._staticdata

	if staticdata.connected_at then
		return staticdata.connected_at + staticdata.dir * staticdata.distance
	else
		return self.object:get_pos()
	end
end
function DEFAULT_CART_DEF:on_step(dtime)
	local staticdata = self._staticdata
	if not staticdata then
		staticdata = make_staticdata()
		self._staticdata = staticdata
	end

	-- Update entity position
	local pos = mod.get_cart_position(staticdata)
	if pos then self.object:move_to(pos) end

	-- Repair cart_type
	if not staticdata.cart_type then
		staticdata.cart_type = self.name
	end

	-- Remove superceded entities
	if self._seq ~= staticdata.seq then
		print("removing cart #"..staticdata.uuid.." with sequence number mismatch")
		self.object:remove()
		return
	end

	-- Regen
	local hp = self.object:get_hp()
	local time_now = minetest.get_gametime()
	if hp < MINECART_MAX_HP and (staticdata.last_regen or 0) <= time_now - 1 then
		staticdata.last_regen = time_now
		hp = hp + 1
		self.object:set_hp(hp)
	end

	-- Cart specific behaviors
	local hook = self._mcl_minecarts_on_step
	if hook then hook(self,dtime) end

	if (staticdata.hopper_delay or 0) > 0 then
		staticdata.hopper_delay = staticdata.hopper_delay - dtime
	end

	-- Controls
	local ctrl, player = nil, nil
	if self._driver then
		player = minetest.get_player_by_name(self._driver)
		if player then
			ctrl = player:get_player_control()
			-- player detach
			if ctrl.sneak then
				detach_driver(self)
				return
			end

			-- Experimental controls
			local now_time = minetest.get_gametime()
			local controls = {}
			if ctrl.up then controls.forward = now_time end
			if ctrl.down then controls.brake = now_time end
			staticdata.controls = controls
		end

		-- Give achievement when player reached a distance of 1000 nodes from the start position
		if vector.distance(self._start_pos, pos) >= 1000 then
			awards.unlock(self._driver, "mcl:onARail")
		end
	end

	if not staticdata.connected_at then
		do_detached_movement(self, dtime)
	end

	mod.update_cart_orientation(self)

end
function mod.kill_cart(staticdata)
	local pos
	minetest.log("action", "cart #"..staticdata.uuid.." was killed")

	-- Leave nodes
	if staticdata.attached_at then
		handle_cart_leave(self, staticdata.attached_at, staticdata.dir )
	else
		mcl_log("TODO: handle detatched minecart death")
	end

	-- Handle entity-related items
	local le = mcl_util.get_luaentity_from_uuid(staticdata.uuid)
	if le then
		pos = le.object:get_pos()

		detach_driver(le)

		-- Detach passenger
		if le._passenger then
			local mob = le._passenger.object
			mob:set_detach()
		end

		-- Remove the entity
		le.object:remove()
	else
		pos = mod.get_cart_position(staticdata)
	end

	-- Drop items
	if not staticdata.dropped then
		local entity_def = minetest.registered_entities[staticdata.cart_type]
		if entity_def then
			local drop = entity_def.drop
			for d=1, #drop do
				minetest.add_item(pos, drop[d])
			end

			-- Prevent item duplication
			staticdata.dropped = true
		end
	end

	-- Remove data
	destroy_cart_data(staticdata.uuid)
end
local kill_cart = mod.kill_cart

function DEFAULT_CART_DEF:on_death(killer)
	kill_cart(self._staticdata)
end

-- Place a minecart at pointed_thing
function mod.place_minecart(itemstack, pointed_thing, placer)
	if not pointed_thing.type == "node" then
		return
	end

	local spawn_pos = pointed_thing.above
	local cart_dir = vector.new(1,0,0)

	local railpos, node
	if mcl_minecarts:is_rail(pointed_thing.under) then
		railpos = pointed_thing.under
	elseif mcl_minecarts:is_rail(pointed_thing.above) then
		railpos = pointed_thing.above
	end
	if railpos then
		spawn_pos = railpos
		node = minetest.get_node(railpos)
		cart_dir = mcl_minecarts:get_rail_direction(railpos, vector.new(1,0,0))
	end

	local entity_id = entity_mapping[itemstack:get_name()]

	-- Setup cart data
	local uuid = mcl_util.gen_uuid()
	data = make_staticdata( nil, railpos, cart_dir )
	data.uuid = uuid
	data.cart_type = entity_id
	update_cart_data(data)
	save_cart_data(uuid)

	-- Create the entity with the staticdata already setup
	local sd = minetest.serialize({ uuid=uuid, seq=1 })
	local cart = minetest.add_entity(spawn_pos, entity_id, sd)

	cart:set_yaw(minetest.dir_to_yaw(cart_dir))

	-- Update static data
	local le = cart:get_luaentity()
	if le then
		le._staticdata = data
	end

	-- Call placer
	if le._mcl_minecarts_on_place then
		le._mcl_minecarts_on_place(le, placer)
	end

	if railpos then
		handle_cart_enter(data, railpos)
	end

	local pname = ""
	if placer then
		pname = placer:get_player_name()
	end
	if not minetest.is_creative_enabled(pname) then
		itemstack:take_item()
	end
	return itemstack
end

local function dropper_place_minecart(dropitem, pos)
	-- Don't try to place the minecart if pos isn't a rail
	local node = minetest.get_node(pos)
	if minetest.get_item_group(node.name, "rail") == 0 then return false end

	mod.place_minecart(dropitem, {
		above = pos,
		under = vector.offset(pos,0,-1,0)
	})
	return true
end

local function register_minecart_craftitem(itemstring, def)
	local groups = { minecart = 1, transport = 1 }
	if def.creative == false then
		groups.not_in_creative_inventory = 1
	end
	local item_def = {
		stack_max = 1,
		_mcl_dropper_on_drop = dropper_place_minecart,
		on_place = function(itemstack, placer, pointed_thing)
			if not pointed_thing.type == "node" then
				return
			end

			-- Call on_rightclick if the pointed node defines it
			local node = minetest.get_node(pointed_thing.under)
			if placer and not placer:get_player_control().sneak then
				if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
					return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
				end
			end

			return mod.place_minecart(itemstack, pointed_thing, placer)
		end,
		_on_dispense = function(stack, pos, droppos, dropnode, dropdir)
			-- Place minecart as entity on rail. If there's no rail, just drop it.
			local placed
			if minetest.get_item_group(dropnode.name, "rail") ~= 0 then
				-- FIXME: This places minecarts even if the spot is already occupied
				local pointed_thing = { under = droppos, above = vector.new( droppos.x, droppos.y+1, droppos.z ) }
				placed = mod.place_minecart(stack, pointed_thing)
			end
			if placed == nil then
				-- Drop item
				minetest.add_item(droppos, stack)
			end
		end,
		groups = groups,
	}
	item_def.description = def.description
	item_def._tt_help = def.tt_help
	item_def._doc_items_longdesc = def.longdesc
	item_def._doc_items_usagehelp = def.usagehelp
	item_def.inventory_image = def.icon
	item_def.wield_image = def.icon
	minetest.register_craftitem(itemstring, item_def)
end

--[[
Register a minecart
* itemstring: Itemstring of minecart item
* entity_id: ID of minecart entity
* description: Item name / description
* longdesc: Long help text
* usagehelp: Usage help text
* mesh: Minecart mesh
* textures: Minecart textures table
* icon: Item icon
* drop: Dropped items after destroying minecart
* on_rightclick: Called after rightclick
* on_activate_by_rail: Called when above activator rail
* creative: If false, don't show in Creative Inventory
]]
function mod.register_minecart(def)
	-- Make sure all required parameters are present
	for _,name in pairs({"drop","itemstring","entity_id"}) do
		assert( def[name], "def."..name..", a required parameter, is missing")
	end

	local entity_id = def.entity_id; def.entity_id = nil
	local craft = def.craft; def.craft = nil
	local itemstring = def.itemstring; def.itemstring = nil

	-- Build cart definition
	local cart = table.copy(DEFAULT_CART_DEF)
	table_merge(cart, def)
	minetest.register_entity(entity_id, cart)

	-- Register item to entity mapping
	entity_mapping[itemstring] = entity_id

	register_minecart_craftitem(itemstring, def)
	if minetest.get_modpath("doc_identifier") then
		doc.sub.identifier.register_object(entity_id, "craftitems", itemstring)
	end

	if craft then
		minetest.register_craft(craft)
	end
end
local register_minecart = mod.register_minecart

dofile(modpath.."/carts/minecart.lua")
dofile(modpath.."/carts/with_chest.lua")
dofile(modpath.."/carts/with_commandblock.lua")
dofile(modpath.."/carts/with_hopper.lua")
dofile(modpath.."/carts/with_furnace.lua")
dofile(modpath.."/carts/with_tnt.lua")

if minetest.get_modpath("mcl_wip") then
	mcl_wip.register_wip_item("mcl_minecarts:chest_minecart")
	mcl_wip.register_wip_item("mcl_minecarts:furnace_minecart")
	mcl_wip.register_wip_item("mcl_minecarts:command_block_minecart")
end

local function respawn_cart(cart)
	local cart_type = cart.cart_type or "mcl_minecarts:minecart"
	local pos = mod.get_cart_position(cart)

	local players = minetest.get_connected_players()
	local distance = nil
	for _,player in pairs(players) do
		local d = vector.distance(player:get_pos(), pos)
		if not distance or d < distance then distance = d end
	end
	if not distance or distance > 90 then return end

	print("Respawning cart #"..cart.uuid.." at "..tostring(pos)..",distance="..distance..",node="..minetest.get_node(pos).name)

	-- Update sequence so that old cart entities get removed
	cart.seq = (cart.seq or 1) + 1
	save_cart_data(cart.uuid)

	-- Create the new entity and refresh caches
	local sd = minetest.serialize({ uuid=cart.uuid, seq=cart.seq })
	local entity = minetest.add_entity(pos, cart_type, sd)
	local le = entity:get_luaentity()
	le._staticdata = cart
	mcl_util.assign_uuid(entity)

	-- We intentionally don't call the normal hooks because this minecart was already there
end

-- Try to respawn cart entities for carts that have moved into range of a player
local function try_respawn_carts()
	-- Build a map of blocks near players
	local block_map = {}
	local players = minetest.get_connected_players()
	for _,player in pairs(players) do
		local pos = player:get_pos()
		mod.add_blocks_to_map(
			block_map,
			vector.offset(pos,-CART_BLOCK_SIZE,-CART_BLOCK_SIZE,-CART_BLOCK_SIZE),
			vector.offset(pos, CART_BLOCK_SIZE, CART_BLOCK_SIZE, CART_BLOCK_SIZE)
		)
	end

	-- Find all cart data that are in these blocks
	local carts = find_carts_by_block_map(block_map)

	-- Check to see if any of these don't have an entity
	for _,cart in pairs(carts) do
		local le = mcl_util.get_luaentity_from_uuid(cart.uuid)
		if not le then
			respawn_cart(cart)
		end
	end
end

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer - dtime
	if timer <= 0 then
		local start_time = minetest.get_us_time()
		try_respawn_carts()
		local stop_time = minetest.get_us_time()
		local duration = (stop_time - start_time) / 1e6
		timer = duration / 250e-6 -- Schedule 50us per second
		if timer > 5 then timer = 5 end
		--print("Took "..tostring(duration).." seconds, rescheduling for "..tostring(timer).." seconds in the future")
	end

	-- Handle periodically updating out-of-range carts
	-- TODO: change how often cart positions are updated based on velocity
	for uuid,staticdata in mod.carts() do
		local pos = mod.get_cart_position(staticdata)
		--[[
		local le = mcl_util.get_luaentity_from_uuid(staticdata.uuid)
		print("cart# "..uuid..
			",velocity="..tostring(staticdata.velocity)..
			",pos="..tostring(pos)..
			",le="..tostring(le)..
			",connected_at="..tostring(staticdata.connected_at)
		)]]

		--- Non-entity code
		if staticdata.connected_at then
			do_movement(staticdata, dtime)
		end
	end
end)

