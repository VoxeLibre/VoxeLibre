local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local mod = mcl_minecarts
local S = minetest.get_translator(modname)

local mcl_log = mcl_util.make_mcl_logger("mcl_logging_minecarts", "Minecarts")

-- Imports
local table_merge = mcl_util.table_merge
local get_cart_data = mod.get_cart_data
local save_cart_data = mod.save_cart_data
local update_cart_data = mod.update_cart_data
local destroy_cart_data = mod.destroy_cart_data
local do_movement,do_detached_movement,handle_cart_enter = dofile(modpath.."/movement.lua")
assert(do_movement)
assert(do_detached_movement)
assert(handle_cart_enter)

-- Constants
local max_step_distance = 0.5
local MINECART_MAX_HP = 4
local PASSENGER_ATTACH_POSITION = vector.new(0, -1.75, 0)

local function detach_driver(self)
	if not self._driver then
		return
	end
	mcl_player.player_attached[self._driver] = nil
	local player = minetest.get_player_by_name(self._driver)
	self._driver = nil
	self._start_pos = nil
	if player then
		player:set_detach()
		player:set_eye_offset(vector.new(0,0,0),vector.new(0,0,0))
		mcl_player.player_set_animation(player, "stand" , 30)
	end
end

-- Table for item-to-entity mapping. Keys: itemstring, Values: Corresponding entity ID
local entity_mapping = {}

local function make_staticdata( railtype, connected_at, dir )
	return {
		railtype = railtype,
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
		data.uuid  = mcl_util.get_uuid(self.object)
	end
	self._seq = data.seq or 1

	local cd = get_cart_data(data.uuid)
	if not cd then
		update_cart_data(data)
	else
		if not cd.seq then cd.seq = 1 end
		data = cd
	end

	-- Initialize
	if type(data) == "table" then
		-- Migrate old data
		if data._railtype then
			data.railtype = data._railtype
			data._railtype = nil
		end

		-- Fix up types
		data.dir = vector.new(data.dir)

		-- Fix mass
		data.mass = data.mass or 1

		-- Make sure all carts have an ID to isolate them
		self._uuid = data.uuid
		data.uuid = mcl_util.get_uuid(self.object)

		self._staticdata = data
	end

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

	if self._seq ~= staticdata.seq then
		print("TODO: remove cart #"..staticdata.uuid.." with sequence number mismatch")
		print("self.seq="..tostring(self._seq)..", staticdata.seq="..tostring(staticdata.seq))
	end

	-- Regen
	local hp = self.object:get_hp()
	if hp < MINECART_MAX_HP then
		if (staticdata.regen_timer or 0) > 0.5 then
			hp = hp + 1
			staticdata.regen_timer = staticdata.regen_timer - 1
		end
		staticdata.regen_timer = (staticdata.regen_timer or 0) + dtime
		self.object:set_hp(hp)
	else
		staticdata.regen_timer = nil
	end

	-- Fix railtype field
	local pos = self.object:get_pos()
	if staticdata.connected_at and not staticdata.railtype then
		local node = minetest.get_node(vector.floor(pos)).name
		staticdata.railtype = minetest.get_item_group(node, "connect_to_raillike")
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
			self._go_forward = ctrl.up
			self._brake = ctrl.down
		end

		-- Give achievement when player reached a distance of 1000 nodes from the start position
		if vector.distance(self._start_pos, pos) >= 1000 then
			awards.unlock(self._driver, "mcl:onARail")
		end
	end

	if staticdata.connected_at then
		do_movement(self, dtime)
	else
		do_detached_movement(self, dtime)
	end

	-- TODO: move this into mcl_core:cactus _mcl_minecarts_on_enter_side
	-- Drop minecart if it collides with a cactus node
	local r = 0.6
	for _, node_pos in pairs({{r, 0}, {0, r}, {-r, 0}, {0, -r}}) do
		if minetest.get_node(vector.offset(pos, node_pos[1], 0, node_pos[2])).name == "mcl_core:cactus" then
			self:on_death()
			self.object:remove()
			return
		end
	end
end
function DEFAULT_CART_DEF:on_death(killer)
	local staticdata = self._staticdata
	minetest.log("action", "cart #"..staticdata.uuid.." was killed")

	detach_driver(self)

	-- Detach passenger
	if self._passenger then
		local mob = self._passenger.object
		mob:set_detach()
	end

	-- Leave nodes
	if staticdata.attached_at then
		handle_cart_leave(self, staticdata.attached_at, staticdata.dir )
	else
		mcl_log("TODO: handle detatched minecart death")
	end

	-- Remove data
	destroy_cart_data(staticdata.uuid)

	-- Drop items
	local drop = self.drop
	if not killer or not minetest.is_creative_enabled(killer:get_player_name()) then
		for d=1, #drop do
			minetest.add_item(self.object:get_pos(), drop[d])
		end
	elseif killer and killer:is_player() then
		local inv = killer:get_inventory()
		for d=1, #drop do
			if not inv:contains_item("main", drop[d]) then
				inv:add_item("main", drop[d])
			end
		end
	end
end

-- Place a minecart at pointed_thing
function mcl_minecarts.place_minecart(itemstack, pointed_thing, placer)
	if not pointed_thing.type == "node" then
		return
	end

	local spawn_pos = pointed_thing.above
	local cart_dir = vector.new(1,0,0)

	local railtype, railpos, node
	if mcl_minecarts:is_rail(pointed_thing.under) then
		railpos = pointed_thing.under
	elseif mcl_minecarts:is_rail(pointed_thing.above) then
		railpos = pointed_thing.above
	end
	if railpos then
		spawn_pos = railpos
		node = minetest.get_node(railpos)
		railtype = minetest.get_item_group(node.name, "connect_to_raillike")
		cart_dir = mcl_minecarts:get_rail_direction(railpos, vector.new(1,0,0), nil, nil, railtype)
	end

	local entity_id = entity_mapping[itemstack:get_name()]
	local cart = minetest.add_entity(spawn_pos, entity_id)

	cart:set_yaw(minetest.dir_to_yaw(cart_dir))

	-- Update static data
	local le = cart:get_luaentity()
	if le then
		local uuid = mcl_util.get_uuid(cart)
		data = make_staticdata( railtype, railpos, cart_dir )
		data.uuid = uuid
		update_cart_data(data)
		le._staticdata = data
		save_cart_data(le._staticdata.uuid)
	end

	-- Call placer
	if le._mcl_minecarts_on_place then
		le._mcl_minecarts_on_place(le, placer)
	end

	if railpos then
		handle_cart_enter(le, railpos)
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

	mcl_minecarts.place_minecart(dropitem, {
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

			return mcl_minecarts.place_minecart(itemstack, pointed_thing, placer)
		end,
		_on_dispense = function(stack, pos, droppos, dropnode, dropdir)
			-- Place minecart as entity on rail. If there's no rail, just drop it.
			local placed
			if minetest.get_item_group(dropnode.name, "rail") ~= 0 then
				-- FIXME: This places minecarts even if the spot is already occupied
				local pointed_thing = { under = droppos, above = vector.new( droppos.x, droppos.y+1, droppos.z ) }
				placed = mcl_minecarts.place_minecart(stack, pointed_thing)
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
function mcl_minecarts.register_minecart(def)
	assert( def.drop, "def.drop is required parameter" )
	assert( def.itemstring, "def.itemstring is required parameter" )

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
local register_minecart = mcl_minecarts.register_minecart

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

minetest.register_globalstep(function(dtime)
	-- TODO: handle periodically updating out-of-range carts
end)

