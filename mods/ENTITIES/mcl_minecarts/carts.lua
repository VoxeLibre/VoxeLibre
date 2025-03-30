local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local mod = mcl_minecarts

local mcl_log,DEBUG = mcl_util.make_mcl_logger("mcl_logging_minecarts", "Minecarts")

-- Imports
local CART_BLOCK_SIZE = mod.CART_BLOCK_SIZE
local table_merge = mcl_util.table_merge
local get_cart_data = mod.get_cart_data
local save_cart_data = mod.save_cart_data
local update_cart_data = mod.update_cart_data
local destroy_cart_data = mod.destroy_cart_data
local find_carts_by_block_map = mod.find_carts_by_block_map
local movement = dofile(modpath..DIR_DELIM.."movement.lua")
assert(movement.do_movement)
assert(movement.do_detached_movement)
assert(movement.handle_cart_enter)
assert(movement.handle_cart_leave)

-- Constants
local MINECART_MAX_HP = 4
local TWO_OVER_PI = 2 / math.pi

---@class vl.MinecartStaticData
---@field inventory table
---@field node_watches vector.Vector[]
---@field seq integer
---@field uuid string
---@field connected_at vector.Vector
---@field dir vector.Vector
---@field distance number
---@field velocity number
---@field controls table
---@field last_regen number
---@field cart_type string
---@field hopper_delay? number

---@class vl.MinecartEntityDef : core.EntityDef
---@field _staticdata nil
---@field _mcl_minecarts_on_place? fun(self : vl.MinecartLuaEntity, placer : core.Player)
---@field _mcl_entity_invs_load_items? fun(self : vl.MinecartLuaEntity) : table
---@field _mcl_entity_invs_save_items? fun(self : vl.MinecartLuaEntity, items : table)
---@field add_node_watch? fun(self : vl.MinecartLuaEntity, pos : vector.Vector)
---@field remove_node_watch? fun(self : vl.MinecartLuaEntity, pos : vector.Vector)
---@field on_activate_by_rail? fun()
---@field get_cart_position? fun(self : vl.MinecartLuaEntity) : vector.Vector
---@field drop table

---@class vl.MinecartLuaEntity : core.LuaEntity
---@field name string
---@field object core.LuaEntityRef
---@field drop string
---@field _mcl_minecarts_on_place? fun(self : vl.MinecartLuaEntity, placer : core.Player)
---@field _mcl_minecarts_on_step? fun(self : vl.MinecartLuaEntity, dtime : number)
---@field on_activate_by_rail? fun(self : vl.MinecartLuaEntity)
---@field _staticdata vl.MinecartStaticData
---@field _passenger core.LuaEntity
---@field _seq integer
---@field _uuid string
---@field _driver string
---@field _items nil
---@field _start_pos vector.Vector

local function delayed_player_move(driver_name, new_pos)
	local player = core.get_player_by_name(driver_name)
	if not player then return end
	player:move_to(new_pos, false)
end

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

	core.log("action", driver_name.." left a minecart")

	-- Update cart information
	self._driver = nil
	self._start_pos = nil
	local player_meta = mcl_playerinfo.get_mod_meta(driver_name, modname)
	player_meta.attached_to = nil

	-- Detatch the player object from the minecart
	local player = core.get_player_by_name(driver_name)
	if player then
		local dir = staticdata.dir or vector.new(1,0,0)
		local cart_pos = mod.get_cart_position(staticdata) or self.object:get_pos()
		local new_pos = cart_pos - dir
		player:set_detach()
		--print("placing player at "..tostring(new_pos).." from cart at "..tostring(cart_pos)..", old_pos="..tostring(player:get_pos()).."dir="..tostring(dir))

		-- There needs to be a delay here or the player's position won't update
		core.after(0.1, delayed_player_move, driver_name, new_pos)

		player:set_eye_offset(vector.zero(),vector.zero())
		mcl_player.player_set_animation(player, "stand" , 30)
	end
end
mod.detach_driver = detach_driver

function mod.kill_cart(staticdata, killer)
	local pos
	if DEBUG then
		mcl_log("cart #"..staticdata.uuid.." was killed")
	end

	-- Leave nodes
	if staticdata.attached_at then
		movement.handle_cart_leave(staticdata, staticdata.attached_at, staticdata.dir )
	--elseif DEBUG
		--mcl_log("TODO: handle detatched minecart death")
	end

	-- Handle entity-related items
	local le = mcl_util.get_luaentity_from_uuid(staticdata.uuid)
	---@cast le vl.MinecartLuaEntity
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
		-- Try to drop the cart
		local entity_def = core.registered_entities[staticdata.cart_type]
		---@cast entity_def vl.MinecartEntityDef
		if entity_def then
			local drop_cart = true
			if killer and core.is_creative_enabled(killer:get_player_name()) then
				drop_cart = false
			end

			if drop_cart then
				local drop = entity_def.drop
				for d=1, #drop do
					core.add_item(pos, drop[d])
				end
			end
		end

		-- Drop any items in the inventory
		local inventory = staticdata.inventory
		if inventory then
			for i=1,#inventory do
				core.add_item(pos, inventory[i])
			end
		end

		-- Prevent item duplication
		staticdata.dropped = true
	end

	-- Remove data
	destroy_cart_data(staticdata.uuid)
end
local kill_cart = mod.kill_cart


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

---@type vl.MinecartEntityDef
local DEFAULT_CART_DEF = {
	initial_properties = {
		physical = true,
		collisionbox = {-10/16., -0.5, -10/16, 10/16, 0.25, 10/16},
		visual = "mesh",
		visual_size = {x=1, y=1},
		hp_max = MINECART_MAX_HP,
	},

	groups = {
		minecart = 1,
	},

	drop = {},

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

---@param self vl.MinecartLuaEntity
function DEFAULT_CART_DEF:on_activate(staticdata, _)
	-- Transfer older data
	local data = core.deserialize(staticdata) or {}
	if not data.uuid then
		data.uuid  = mcl_util.assign_uuid(self.object)
		core.log("warning", "assigned uuid "..data.uuid.." to cart without uuid at"..vector.to_string(self.object:get_pos()))

		if data._items then
			data.inventory = data._items
			data._items = nil
			data._inv_id = nil
			data._inv_size = nil
		end
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
	local pos = self.object:get_pos()
	if self.on_activate_by_rail then
		local node = core.get_node(vector.floor(pos))
		if node.name == "mcl_minecarts:activator_rail_on" then
			self:on_activate_by_rail()
		end
	end

	--core.log("activated "..self._uuid.." at "..vector.to_string(pos))
end

---@param self vl.MinecartLuaEntity
function DEFAULT_CART_DEF:get_staticdata()
	save_cart_data(self._staticdata.uuid)
	local data = core.serialize({uuid = self._staticdata.uuid, seq=self._seq})
	--core.log("Got staticdata: "..data.." for "..self.name.." at "..vector.to_string(self.object:get_pos()))
	return data
end

---@param self vl.MinecartLuaEntity
function DEFAULT_CART_DEF:_mcl_entity_invs_load_items()
	local staticdata = self._staticdata
	return staticdata.inventory or {}
end

---@param self vl.MinecartLuaEntity
function DEFAULT_CART_DEF:_mcl_entity_invs_save_items(items)
	local staticdata = self._staticdata
	staticdata.inventory = table.copy(items)
	mod.save_cart_data(self._uuid)
end

---@param self vl.MinecartLuaEntity
---@param pos vector.Vector
function DEFAULT_CART_DEF:add_node_watch(pos)
	local staticdata = self._staticdata
	local watches = staticdata.node_watches or {}

	for i=1,#watches do
		if watches[i] == pos then return end
	end

	watches[#watches+1] = pos
	staticdata.node_watches = watches
end

---@param self vl.MinecartLuaEntity
---@param pos vector.Vector
function DEFAULT_CART_DEF:remove_node_watch(pos)
	local staticdata = self._staticdata
	local watches = staticdata.node_watches or {}

	local new_watches = {}
	for i=1,#watches do
		local node_pos = watches[i]
		if node_pos ~= pos then
			new_watches[#new_watches + 1] = node_pos
		end
	end
	staticdata.node_watches = new_watches
end

---@param self vl.MinecartLuaEntity
function DEFAULT_CART_DEF:get_cart_position()
	local staticdata = self._staticdata

	if staticdata.connected_at then
		return staticdata.connected_at + staticdata.dir * staticdata.distance
	else
		return self.object:get_pos()
	end
end

---@param self vl.MinecartLuaEntity
function DEFAULT_CART_DEF:on_punch(puncher, _, _, dir, damage)
	if puncher == self._driver then return end

	local staticdata = self._staticdata
	--core.log("punched "..staticdata.uuid)

	if puncher:get_player_control().sneak then
		mod.kill_cart(staticdata, puncher)
		return
	end

	local controls = staticdata.controls or {}
	dir.y = 0
	dir = vector.normalize(dir)
	local impulse = vector.dot(staticdata.dir, vector.multiply(dir, damage * 4))
	if impulse < 0 and staticdata.velocity == 0 then
		mod.reverse_direction(staticdata)
		impulse = -impulse
	end

	controls.impulse = impulse
	staticdata.controls = controls
end

---@param self vl.MinecartLuaEntity
function DEFAULT_CART_DEF:on_step(dtime)
	local staticdata = self._staticdata
	if not staticdata then
		staticdata = make_staticdata()
		self._staticdata = staticdata
	end
	if self._items then
		self._items = nil
	end

	-- Update entity position
	local pos = mod.get_cart_position(staticdata)
	if pos then self.object:move_to(pos) end

	-- Repair cart_type
	if not staticdata.cart_type then
		staticdata.cart_type = self.name
	end

	-- Remove superceded entities
	if staticdata.seq and (self._seq or -1) < staticdata.seq then
		if not self._seq then
			core.log("warning", "Removing minecart entity missing sequence number")
		end
		--core.log("removing cart #"..staticdata.uuid.." with sequence number mismatch at "..(pos and vector.to_string(pos) or "nil"))
		mcl_util.remove_entity(self)
		return
	end

	-- Regen
	local hp = self.object:get_hp()
	local time_now = core.get_gametime() ---@cast time_now number
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
	if self._driver then
		local player = core.get_player_by_name(self._driver)
		if player then
			local ctrl = player:get_player_control()
			-- player detach
			if ctrl.sneak then
				detach_driver(self)
				return
			end

			-- Experimental controls
			local now_time = core.get_gametime()
			local controls = {}
			if ctrl.up then controls.forward = now_time end
			if ctrl.down then controls.brake = now_time end
			controls.look = math.round(player:get_look_horizontal() * TWO_OVER_PI) % 4
			staticdata.controls = controls
		end

		-- Give achievement when player reached a distance of 1000 nodes from the start position
		if pos and vector.distance(self._start_pos, pos) >= 1000 then
			awards.unlock(self._driver, "mcl:onARail")
		end
	end

	if not staticdata.connected_at then
		movement.do_detached_movement(self, dtime)
	else
		mod.update_cart_orientation(self)
	end
end
function DEFAULT_CART_DEF:on_death(killer)
	kill_cart(self._staticdata, killer)
end

-- Create a minecart
function mod.create_minecart(entity_id, pos, dir)
	-- Setup cart data
	local uuid = mcl_util.gen_uuid()
	local data = make_staticdata( nil, pos, dir )
	data.uuid = uuid
	data.cart_type = entity_id
	update_cart_data(data)
	save_cart_data(uuid)

	return uuid
end
local create_minecart = mod.create_minecart

-- Place a minecart at pointed_thing
function mod.place_minecart(itemstack, pointed_thing, placer)
	if pointed_thing.type ~= "node" then return end

	local look_4dir = math.round(placer:get_look_horizontal() * TWO_OVER_PI) % 4
	local look_dir = core.fourdir_to_dir(look_4dir)
	look_dir = vector.new(-look_dir.x,0,look_dir.z)

	local spawn_pos = pointed_thing.above
	local cart_dir = look_dir

	local railpos
	if mcl_minecarts.is_rail(pointed_thing.under) then
		railpos = pointed_thing.under
	elseif mcl_minecarts.is_rail(pointed_thing.above) then
		railpos = pointed_thing.above
	end
	if railpos then
		spawn_pos = railpos

		-- Try two orientations, and select the second if the first is at an angle
		local cart_dir1 = mcl_minecarts.get_rail_direction(railpos,  look_dir)
		local cart_dir2 = mcl_minecarts.get_rail_direction(railpos, -look_dir)
		if vector.length(cart_dir1) <= 1 then
			cart_dir = cart_dir1
		else
			cart_dir = cart_dir2
		end
	end

	-- Make sure to always go down slopes
	if cart_dir.y > 0 then cart_dir = -cart_dir end

	local entity_id = entity_mapping[itemstack:get_name()]

	local uuid = create_minecart(entity_id, railpos, cart_dir)

	-- Create the entity with the staticdata already setup
	local sd = core.serialize({ uuid=uuid, seq=1 })
	local cart = core.add_entity(spawn_pos, entity_id, sd)
	if not cart then return end
	local staticdata = get_cart_data(uuid)

	cart:set_yaw(core.dir_to_yaw(cart_dir))

	-- Call placer
	local le = cart:get_luaentity()
	---@cast le vl.MinecartLuaEntity
	if le._mcl_minecarts_on_place then
		le._mcl_minecarts_on_place(le, placer)
	end

	if railpos then
		movement.handle_cart_enter(staticdata, railpos)
	end

	local pname = placer and placer:get_player_name() or ""
	if not core.is_creative_enabled(pname) then
		itemstack:take_item()
	end
	return itemstack
end

local function dropper_place_minecart(dropitem, pos)
	-- Don't try to place the minecart if pos isn't a rail
	local node = core.get_node(pos)
	if core.get_item_group(node.name, "rail") == 0 then return false end

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
			if pointed_thing.type ~= "node" then
				return
			end

			-- Call on_rightclick if the pointed node defines it
			local called
			itemstack, called = mcl_util.handle_node_rightclick(itemstack, placer, pointed_thing)
			if called then return itemstack end

			-- Don't place minecarts over air
			local below = core.get_node(vector.offset(pointed_thing.above,0,-1,0))
			if below.name == "air" then return itemstack end

			return mod.place_minecart(itemstack, pointed_thing, placer)
		end,
		_on_dispense = function(stack, _, droppos, dropnode, _)
			-- Place minecart as entity on rail. If there's no rail, just drop it.
			local placed
			if core.get_item_group(dropnode.name, "rail") ~= 0 then
				-- FIXME: This places minecarts even if the spot is already occupied
				local pointed_thing = { under = droppos, above = vector.new( droppos.x, droppos.y+1, droppos.z ) }
				placed = mod.place_minecart(stack, pointed_thing)
			end
			if placed == nil then
				-- Drop item
				core.add_item(droppos, stack)
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
	core.register_craftitem(itemstring, item_def)
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
	core.register_entity(entity_id, cart)

	-- Register item to entity mapping
	entity_mapping[itemstring] = entity_id

	register_minecart_craftitem(itemstring, def)
	if core.get_modpath("doc_identifier") then
		doc.sub.identifier.register_object(entity_id, "craftitems", itemstring)
	end

	if craft then
		core.register_craft(craft)
	end
end

local CART_PATH = modpath..DIR_DELIM.."carts"..DIR_DELIM
dofile(CART_PATH.."minecart.lua")
dofile(CART_PATH.."with_chest.lua")
dofile(CART_PATH.."with_commandblock.lua")
dofile(CART_PATH.."with_hopper.lua")
dofile(CART_PATH.."with_furnace.lua")
dofile(CART_PATH.."with_tnt.lua")

if core.get_modpath("mcl_wip") then
	mcl_wip.register_wip_item("mcl_minecarts:chest_minecart")
	mcl_wip.register_wip_item("mcl_minecarts:furnace_minecart")
	mcl_wip.register_wip_item("mcl_minecarts:command_block_minecart")
end

local function respawn_cart(cart)
	local cart_type = cart.cart_type or "mcl_minecarts:minecart"
	local pos = mod.get_cart_position(cart)

	local players = core.get_connected_players()
	local distance = nil
	for _,player in pairs(players) do
		local d = vector.distance(player:get_pos(), pos)
		if not distance or d < distance then distance = d end
	end
	if not distance or distance > 90 then return end

	--core.log("Respawning cart #"..cart.uuid.." at "..tostring(pos)..",distance="..distance..",node="..core.get_node(pos).name)

	-- Update sequence so that old cart entities get removed
	cart.seq = (cart.seq or 1) + 1
	save_cart_data(cart.uuid)

	-- Create the new entity and refresh caches
	local sd = core.serialize({ uuid=cart.uuid, seq=cart.seq })
	local entity = core.add_entity(pos, cart_type, sd)
	if not entity then
		core.log("warning", "Unable to recreate cart "..cart.uuid.." at "..vector.to_string(pos))
		return
	end
	local le = entity:get_luaentity()
	---@cast le vl.MinecartLuaEntity
	le._staticdata = cart
	mcl_util.assign_uuid(entity)

	-- We intentionally don't call the normal hooks because this minecart was already there
end

-- Try to respawn cart entities for carts that have moved into range of a player
local function try_respawn_carts()
	-- Build a map of blocks near players
	local block_map = {}
	local players = core.get_connected_players()
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
core.register_globalstep(function(dtime)
	-- Periodically respawn carts that come into range of a player
	-- TODO: move to fixed timestep scheduler after https://git.minetest.land/VoxeLibre/VoxeLibre/pulls/4716 is merged
	timer = timer - dtime
	if timer <= 0 then
		local start_time = core.get_us_time()
		try_respawn_carts()
		local stop_time = core.get_us_time()
		local duration = (stop_time - start_time) / 1e6
		timer = duration / 250e-6 -- Schedule 50us per second
		if timer > 5 then timer = 5 end
	end

	-- Handle periodically updating out-of-range carts
	-- TODO: change how often cart positions are updated based on velocity
	local start_time
	if DEBUG then start_time = core.get_us_time() end

	for _,staticdata in mod.carts() do
		--[[
		local pos = mod.get_cart_position(staticdata)
		local le = mcl_util.get_luaentity_from_uuid(staticdata.uuid)
		print("cart# "..staticdata.uuid..
			",velocity="..tostring(staticdata.velocity)..
			",pos="..tostring(pos)..
			",le="..tostring(le)..
			",connected_at="..tostring(staticdata.connected_at)
		)]]

		--- Non-entity code
		if staticdata.connected_at then
			movement.do_movement(staticdata, dtime)
		end
	end

	if DEBUG then
		local stop_time = core.get_us_time()
		print("Update took "..((stop_time-start_time)*1e-6).." seconds")
	end
end)

local function reattach_player(player_name, cart_uuid)
	local player = core.get_player_by_name(player_name)
	if not player then
		return
	end

	local cart = mcl_util.get_luaentity_from_uuid(cart_uuid)
	if not cart then
		return
	end

	mod.attach_driver(cart, player)
end

core.register_on_joinplayer(function(player)
	-- Try cart reattachment
	local player_name = player:get_player_name()
	local player_meta = mcl_playerinfo.get_mod_meta(player_name, modname)
	local cart_uuid = player_meta.attached_to
	if cart_uuid then
		local cartdata = get_cart_data(cart_uuid)

		-- Can't get into a cart that was destroyed
		if not cartdata then
			return
		end

		-- Don't reattach players if someone else got in the cart
		if cartdata.last_player ~= player_name then
			return
		end

		core.after(0.2, reattach_player, player_name, cart_uuid)
	end
end)
