local S = ...

local BOAT_VISUAL_SIZE = vector.new(1, 1, 1)
local PADDLING_SPEED = 22 -- speed at which the paddling animation is played
local BOAT_Y_OFFSET = 0.35
local BOAT_Y_OFFSET_GROUND = BOAT_Y_OFFSET + 0.6
local BOAT_SIDE_OFFSET = 1.001
local BOAT_MAX_HP = 4

local function is_water(pos)
	return core.get_item_group(mcl_vars.get_node_name(pos), "water") ~= 0
end

local function is_river_water(pos)
	-- TODO: river water should probably have its own group
	local name = mcl_vars.get_node_name(pos)
	if name == "mclx_core:river_water_source" or name == "mclx_core:river_water_flowing" then
		return true
	end
end

local function is_ice(pos)
	return core.get_item_group(mcl_vars.get_node_name(pos), "ice") ~= 0
end

local function is_fire(pos)
	return core.get_item_group(mcl_vars.get_node_name(pos), "set_on_fire") ~= 0
end

local function get_velocity(v, yaw, y)
	local x = -math.sin(yaw) * v
	local z =  math.cos(yaw) * v
	return vector.new(x, y, z)
end

local function get_v(v)
	return math.sqrt(v.x ^ 2 + v.z ^ 2)
end

local function check_object(obj)
	return obj and (obj:is_player() or obj:get_luaentity()) and obj
end

local function get_visual_size(obj)
	return obj:is_player() and BOAT_VISUAL_SIZE
		or obj:get_luaentity()._old_visual_size
		or obj:get_properties().visual_size
end

local function set_attach(boat)
	boat._driver:set_attach(boat.object, "", vector.new(0, 1.5, 1), vector.zero())
end

local function set_double_attach(boat)
	boat._driver:set_attach(boat.object, "", vector.new(0, 0.42, 0.8), vector.zero())
	if boat._passenger:is_player() then
		boat._passenger:set_attach(boat.object, "", vector.new(0, 0.42, -6.2), vector.zero())
	else
		boat._passenger:set_attach(boat.object, "", vector.new(0, 0.42, -4.5), vector.new(0, 270, 0))
	end
end

local function attach_object(self, obj)
	if self._driver and not self._inv_id then
		if self._driver:is_player() then
			self._passenger = obj
		else
			self._passenger = self._driver
			self._driver = obj
		end
		set_double_attach(self)
	else
		self._driver = obj
		set_attach(self)
	end

	local visual_size = get_visual_size(obj)
	local yaw = self.object:get_yaw()
	obj:set_properties({visual_size = vector.divide(visual_size, BOAT_VISUAL_SIZE)})

	if obj:is_player() then
		local name = obj:get_player_name()
		mcl_player.player_attached[name] = true
		core.after(0.2, function(name)
			local player = core.get_player_by_name(name)
			if player then
				mcl_player.player_set_animation(player, "sit", 30)
			end
		end, name)
		obj:set_look_horizontal(yaw)
		mcl_title.set(obj, "actionbar", {text=S("Sneak to dismount"), color="white", stay=60})
	else
		obj:get_luaentity()._old_visual_size = visual_size
	end
end

local function detach_object(obj, change_pos)
	if not obj or not obj:get_pos() then return end
	obj:set_detach()
	obj:set_properties({visual_size = get_visual_size(obj)})
	if obj:is_player() then
		mcl_player.player_attached[obj:get_player_name()] = false
		mcl_player.player_set_animation(obj, "stand", 30)
	else
		obj:get_luaentity()._old_visual_size = nil
	end
	if change_pos then
		 obj:set_pos(obj:get_pos() + vector.new(0, 0.2, 0))
	end
end
core.register_on_respawnplayer(detach_object)

--
-- Boat entity
--

local boat = {
	physical = true,
	pointable = true,
	-- Warning: Do not change the position of the collisionbox top surface,
	-- lowering it causes the boat to fall through the world if underwater
	collisionbox = {-0.5, -0.15, -0.5, 0.5, 0.55, 0.5},
	selectionbox = {-0.7, -0.15, -0.7, 0.7, 0.55, 0.7},
	visual = "mesh",
	mesh = "mcl_boats_boat.b3d",
	textures = {"mcl_boats_texture_oak_boat.png", "blank.png"},
	visual_size = BOAT_VISUAL_SIZE,
	hp_max = BOAT_MAX_HP,
	damage_texture_modifier = "^[colorize:white:0",

	_driver = nil, -- Attached driver (player) or nil if none
	_passenger = nil,
	_v = 0, -- Speed
	_last_v = 0, -- Temporary speed variable
	_removed = false, -- If true, boat entity is considered removed (e.g. after punch) and should be ignored
	_itemstring = "mcl_boats:boat", -- Itemstring of the boat item (implies boat type)
	_animation = 0, -- 0: not animated; 1: paddling forwards; -1: paddling backwards
	_regen_timer = 0,
	_damage_anim = 0,
}

function boat.on_rightclick(self, clicker)
	if self._passenger or not clicker
			or clicker:get_attach()
			or (self.name == "mcl_boats:chest_boat" and self._driver) then
		return
	end
	attach_object(self, clicker)
end

function boat.on_activate(self, staticdata, dtime_s)
	self.object:set_armor_groups({fleshy = 125})
	local data = core.deserialize(staticdata)
	if type(data) == "table" then
		self._v = data.v
		self._last_v = self._v
		self._itemstring = data.itemstring

		-- Fix data corruption
		if not data.textures then
			data.textures = self.textures
		end

		-- Update the texutes for existing old boat entity instances.
		-- Maybe remove this in the future.
		if #data.textures ~= 2 then
			local has_chest = self._itemstring:find("chest")
			data.textures = {
				data.textures[1]:gsub("_chest", ""),
				has_chest and "mcl_chests_normal.png" or "blank.png"
			}
		end

		self.object:set_properties({textures = data.textures})
	end
end

function boat.get_staticdata(self)
	return core.serialize({
		v = self._v,
		itemstring = self._itemstring,
		textures = self.object:get_properties().textures
	})
end

function boat.on_death(self, killer)
	mcl_burning.extinguish(self.object)

	if killer and killer:is_player() and core.is_creative_enabled(killer:get_player_name()) then
		local inv = killer:get_inventory()
		if not inv:contains_item("main", self._itemstring) then
			inv:add_item("main", self._itemstring)
		end
	else
		core.add_item(self.object:get_pos(), self._itemstring)
	end

	if self._driver then
		detach_object(self._driver)
	end
	if self._passenger then
		detach_object(self._passenger)
	end
	self._driver = nil
	self._passenger = nil
end

function boat.on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
	if damage > 0 then
		self._regen_timer = 0
	end
end

function boat.on_step(self, dtime, moveresult)
	mcl_burning.tick(self.object, dtime, self)
	-- mcl_burning.tick may remove object immediately
	if not self.object:get_pos() then return end

	self._v = get_v(self.object:get_velocity()) * math.sign(self._v)
	local v_factor = 1
	local v_slowdown = 0.02

	local pos = self.object:get_pos()

	local on_water = true
	local on_ice = false
	local in_water = is_water(vector.offset(pos, 0, -BOAT_Y_OFFSET + 1, 0))
	local in_river_water = is_river_water(vector.offset(pos, 0, -BOAT_Y_OFFSET + 1, 0))

	local waterpos = vector.offset(pos, 0, -BOAT_Y_OFFSET - 0.1, 0)
	if not is_water(waterpos) then
		on_water = false
		if not in_water and is_ice(waterpos) then
			on_ice = true
		elseif is_fire(vector.offset(pos, 0, -BOAT_Y_OFFSET, 0)) then
			boat.on_death(self, nil)
			self.object:remove()
			return
		else
			v_slowdown = 0.04
			v_factor = 0.5
		end
	elseif in_water and not in_river_water then
		on_water = false
		in_water = true
		v_factor = 0.75
		v_slowdown = 0.05
	end

	local hp = self.object:get_hp()
	local regen_timer = self._regen_timer + dtime
	if hp >= BOAT_MAX_HP then
		regen_timer = 0
	elseif regen_timer >= 0.5 then
		hp = hp + 1
		self.object:set_hp(hp)
		regen_timer = 0
	end
	self._regen_timer = regen_timer

	if moveresult and moveresult.collides then
		for _, collision in pairs(moveresult.collisions) do
			local pos = collision.node_pos
			if collision.type == "node"
					and core.get_item_group(mcl_vars.get_node_name(pos), "dig_by_boat") > 0 then
				core.dig_node(pos)
			end
		end
	end

	local had_passenger = self._passenger

	self._driver = check_object(self._driver)
	self._passenger = check_object(self._passenger)

	if self._passenger then
		if not self._driver then
			self._driver = self._passenger
			self._passenger = nil
		else
			local ctrl = self._passenger:get_player_control()
			if ctrl and ctrl.sneak then
				detach_object(self._passenger, true)
				self._passenger = nil
			end
		end
	end

	if self._driver then
		if had_passenger and not self._passenger then
			set_attach(self)
		end

		local ctrl = self._driver:get_player_control()
		if ctrl and ctrl.sneak then
			detach_object(self._driver, true)
			self._driver = nil
			return
		end

		local yaw = self.object:get_yaw()
		if ctrl and ctrl.up then
			-- Forwards
			self._v = self._v + 0.1 * v_factor

			-- Paddling animation
			if self._animation ~= 1 then
				self.object:set_animation({x=0, y=40}, PADDLING_SPEED, 0, true)
				self._animation = 1
			end
		elseif ctrl and ctrl.down then
			-- Backwards
			self._v = self._v - 0.1 * v_factor

			-- Paddling animation, reversed
			if self._animation ~= -1 then
				self.object:set_animation({x=0, y=40}, -PADDLING_SPEED, 0, true)
				self._animation = -1
			end
		else
			-- Stop paddling animation if no control pressed
			if self._animation ~= 0 then
				self.object:set_animation({x=0, y=40}, 0, 0, true)
				self._animation = 0
			end
		end

		if ctrl and ctrl.left then
			if self._v < 0 then
				self.object:set_yaw(yaw - (1 + dtime) * 0.03 * v_factor)
			else
				self.object:set_yaw(yaw + (1 + dtime) * 0.03 * v_factor)
			end
		elseif ctrl and ctrl.right then
			if self._v < 0 then
				self.object:set_yaw(yaw + (1 + dtime) * 0.03 * v_factor)
			else
				self.object:set_yaw(yaw - (1 + dtime) * 0.03 * v_factor)
			end
		end
	else
		-- Stop paddling without driver
		if self._animation ~= 0 then
			self.object:set_animation({x=0, y=40}, 0, 0, true)
			self._animation = 0
		end

		for _, obj in pairs(core.get_objects_inside_radius(self.object:get_pos(), 1.3)) do
			local entity = obj:get_luaentity()
			if entity and entity.is_mob then
				attach_object(self, obj)
				break
			end
		end
	end

	local s = math.sign(self._v)
	if not on_ice and not on_water and not in_water and math.abs(self._v) > 2.0 then
		v_slowdown = math.min(math.abs(self._v) - 2.0, v_slowdown * 5)
	elseif not on_ice and in_water and math.abs(self._v) > 1.5 then
		v_slowdown = math.min(math.abs(self._v) - 1.5, v_slowdown * 5)
	end
	self._v = self._v - v_slowdown * s
	if s ~= math.sign(self._v) then
		self._v = 0
	end

	pos.y = pos.y - BOAT_Y_OFFSET
	local new_velo
	local new_acce
	if not is_water(pos) and not on_ice then
		-- Not on water or inside water: Free fall
		new_acce = vector.new(0, -9.8, 0)
		new_velo = get_velocity(self._v, self.object:get_yaw(), self.object:get_velocity().y)
	else
		pos.y = pos.y + 1
		local sinks = self.object:get_luaentity()._sinks
		if is_river_water(pos) then
			local vy = self.object:get_velocity().y
			if vy >= 5 then
				vy = 5
			elseif vy < 0 then
				new_acce = vector.new(0, 10, 0)
			else
				new_acce = vector.new(0, 2, 0)
			end
			new_velo = get_velocity(self._v, self.object:get_yaw(), vy)
			self.object:set_pos(self.object:get_pos())
		elseif is_water(pos) or sinks then
			-- Inside water: Slowly sink
			local vy = self.object:get_velocity().y
			vy = vy - 0.01
			if vy < -0.2 then
				vy = -0.2
			end
			new_acce = vector.zero()
			new_velo = get_velocity(self._v, self.object:get_yaw(), vy)
		else
			-- On top of water
			new_acce = vector.zero()
			if math.abs(self.object:get_velocity().y) < 0 then
				new_velo = get_velocity(self._v, self.object:get_yaw(), 0)
			else
				new_velo = get_velocity(self._v, self.object:get_yaw(), self.object:get_velocity().y)
			end
		end
	end

	-- Terminal velocity: 8 m/s per axis of travel
	local terminal_velocity = on_ice and 57.1 or 8.0
	for _, axis in ipairs{"z", "y", "x"} do
		if math.abs(new_velo[axis]) > terminal_velocity then
			new_velo[axis] = terminal_velocity * math.sign(new_velo[axis])
		end
	end

	local yaw = self.object:get_yaw()
	local anim = (BOAT_MAX_HP - hp - regen_timer * 2) / BOAT_MAX_HP * math.pi / 4

	self.object:set_rotation(vector.new(anim, yaw, anim))
	self.object:set_velocity(new_velo)
	self.object:set_acceleration(new_acce)
end

-- Register one entity for all boat types
core.register_entity("mcl_boats:boat", boat)

local cboat = table.copy(boat)
cboat.textures = {"mcl_boats_texture_oak_chest_boat.png", "mcl_chests_normal.png"}
cboat._itemstring = "mcl_boats:chest_boat"
cboat.collisionbox = {-0.5, -0.15, -0.5, 0.5, 0.75, 0.5}
cboat.selectionbox = {-0.7, -0.15, -0.7, 0.7, 0.75, 0.7}
core.register_entity("mcl_boats:chest_boat", cboat)
doc.sub.identifier.register_object("mcl_boats:boat", "craftitems", "mcl_boats:boat")
mcl_entity_invs.register_inv("mcl_boats:chest_boat", "Boat", 27)

local tpl_boat = {
	description = S("Boat"),
	_tt_help = S("Water vehicle"),
	_doc_items_create_entry = false,
	_doc_items_entry_name = S("Boat"),
	_doc_items_longdesc = S("Boats are used to travel on the surface of water."),
	_doc_items_usagehelp = S("Rightclick on a water source to place the boat. Rightclick the boat to enter it. Use [Left] and [Right] to steer, [Forwards] to speed up and [Backwards] to slow down or move backwards. Use [Sneak] to leave the boat, punch the boat to make it drop as an item."),
	liquids_pointable = true,
	groups = {boat = 1, wood_boat = 1, transport = 1},
	stack_max = 1,
	_on_dispense = function(stack, pos, droppos, dropnode, dropdir)
		local below = mcl_vars.get_node_name_raw(droppos.x, droppos.y - 1, droppos.z)
		-- Place boat as entity on or in water
		if core.get_item_group(below, "water") ~= 0
				or (dropnode.name == "air" and core.get_item_group(below, "water") ~= 0) then
			core.add_entity(droppos, "mcl_boats:boat")
		else
			core.add_item(droppos, stack)
		end
	end,
}

local function register_boat_craftitem(name, def, has_chest)
	core.register_craftitem(name, table.merge_deep(tpl_boat, {
		on_place = function(itemstack, placer, pointed_thing)
			-- Call on_rightclick if the pointed node defines it
			local new_stack = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
			if new_stack then return new_stack end

			local pos = vector.copy(pointed_thing.under)
			local dir = pointed_thing.above - pointed_thing.under
			if math.abs(dir.x) > 0.9 or math.abs(dir.z) > 0.9 then
				pos = pos + vector.multiply(dir, BOAT_SIDE_OFFSET)
			elseif is_water(pos) then
				pos = pos + vector.multiply(dir, BOAT_Y_OFFSET)
			else
				pos = pos + vector.multiply(dir, BOAT_Y_OFFSET_GROUND)
			end

			local boat = core.add_entity(pos, has_chest and "mcl_boats:chest_boat" or "mcl_boats:boat")
			local le = boat:get_luaentity()
			table.update(le, {_itemstring = name}, def.entity)
			boat:set_properties({
				textures = {def.entity_texture, has_chest and "mcl_chests_normal.png" or "blank.png"}
			})
			boat:set_yaw(placer:get_look_horizontal())

			if not core.is_creative_enabled(placer:get_player_name()) then
				itemstack:take_item()
			end
			return itemstack
		end,
	}, has_chest and def.item_chest or def.item))
end

function mcl_boats.register_boat(name, def)
	local material = def.material
	register_boat_craftitem(name, def)
	core.register_craft({
		output = name,
		recipe = {
			{material, "",       material},
			{material, material, material},
		},
	})

	if not def.item_chest then return end
	local chest_name = name:gsub(":", ":chest_")
	register_boat_craftitem(chest_name, def, true)
	core.register_craft({
		output = chest_name,
		recipe = {
			{"mcl_chests:chest"},
			{name},
		},
	})
end

core.register_craft({
	type = "fuel",
	recipe = "group:wood_boat",
	burntime = 20,
})
