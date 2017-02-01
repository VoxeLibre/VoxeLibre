mcl_minecarts = {}
mcl_minecarts.modpath = minetest.get_modpath("mcl_minecarts")
mcl_minecarts.speed_max = 10

local vector_floor = function(v)
	return {
		x = math.floor(v.x),
		y = math.floor(v.y),
		z = math.floor(v.z)
	}
end

dofile(mcl_minecarts.modpath.."/functions.lua")
dofile(mcl_minecarts.modpath.."/rails.lua")

mcl_minecarts.cart = {
	physical = false,
	collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	visual = "mesh",
	mesh = "cart.x",
	visual_size = {x=1, y=1},
	textures = {"cart.png"},
	
	_driver = nil,
	_punched = false, -- used to re-send _velocity and position
	_velocity = {x=0, y=0, z=0}, -- only used on punch
	_old_dir = {x=0, y=0, z=0},
	_old_pos = nil,
	_old_switch = 0,
	_railtype = nil,
}

function mcl_minecarts.cart:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	local player_name = clicker:get_player_name()
	if self._driver and player_name == self._driver then
		self._driver = nil
		clicker:set_detach()
	elseif not self._driver then
		self._driver = player_name
		mcl_core.player_attached[player_name] = true
		clicker:set_attach(self.object, "", {x=0, y=3, z=0}, {x=0, y=0, z=0})
	end
end

function mcl_minecarts.cart:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
end

function mcl_minecarts.cart:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	local pos = self.object:getpos()
	if not self._railtype then
		local node = minetest.get_node(vector_floor(pos)).name
		self._railtype = minetest.get_item_group(node, "connect_to_raillike")
	end
	
	if not puncher or not puncher:is_player() then
		local cart_dir = mcl_minecarts:get_rail_direction(pos, {x=1, y=0, z=0}, nil, nil, self._railtype)
		if vector.equals(cart_dir, {x=0, y=0, z=0}) then
			return
		end
		self._velocity = vector.multiply(cart_dir, 3)
		self._old_pos = nil
		self._punched = true
		return
	end

	if puncher:get_player_control().sneak then
		if self._driver then
			if self._old_pos then
				self.object:setpos(self._old_pos)
			end
			mcl_core.player_attached[self._driver] = nil
			local player = minetest.get_player_by_name(self._driver)
			if player then
				player:set_detach()
			end
		end
		
		self.object:remove()
		puncher:get_inventory():add_item("main", "mcl_minecarts:minecart")
		return
	end
	
	local vel = self.object:getvelocity()
	if puncher:get_player_name() == self._driver then
		if math.abs(vel.x + vel.z) > 7 then
			return
		end
	end
	
	local punch_dir = mcl_minecarts:velocity_to_dir(puncher:get_look_dir())
	punch_dir.y = 0
	local cart_dir = mcl_minecarts:get_rail_direction(pos, punch_dir, nil, nil, self._railtype)
	if vector.equals(cart_dir, {x=0, y=0, z=0}) then
		return
	end
	
	time_from_last_punch = math.min(time_from_last_punch, tool_capabilities.full_punch_interval)
	local f = 3 * (time_from_last_punch / tool_capabilities.full_punch_interval)
	
	self._velocity = vector.multiply(cart_dir, f)
	self._old_pos = nil
	self._punched = true
end

function mcl_minecarts.cart:on_step(dtime)
	local vel = self.object:getvelocity()
	local update = {}
	if self._punched then
		vel = vector.add(vel, self._velocity)
		self.object:setvelocity(vel)
		self._old_dir.y = 0
	elseif vector.equals(vel, {x=0, y=0, z=0}) then
		return
	end
	
	local dir, last_switch = nil, nil
	local pos = self.object:getpos()
	if self._old_pos and not self._punched then
		local flo_pos = vector_floor(pos)
		local flo_old = vector_floor(self._old_pos)
		if vector.equals(flo_pos, flo_old) then
			return
		end
	end
	
	local ctrl, player = nil, nil
	if self._driver then
		player = minetest.get_player_by_name(self._driver)
		if player then
			ctrl = player:get_player_control()
		end
	end
	if self._old_pos then
		local diff = vector.subtract(self._old_pos, pos)
		for _,v in ipairs({"x","y","z"}) do
			if math.abs(diff[v]) > 1.1 then
				local expected_pos = vector.add(self._old_pos, self._old_dir)
				dir, last_switch = mcl_minecarts:get_rail_direction(pos, self._old_dir, ctrl, self._old_switch, self._railtype)
				if vector.equals(dir, {x=0, y=0, z=0}) then
					dir = false
					pos = vector.new(expected_pos)
					update.pos = true
				end
				break
			end
		end
	end
	
	if vel.y == 0 then
		for _,v in ipairs({"x", "z"}) do
			if vel[v] ~= 0 and math.abs(vel[v]) < 0.9 then
				vel[v] = 0
				update.vel = true
			end
		end
	end
	
	local cart_dir = mcl_minecarts:velocity_to_dir(vel)
	local max_vel = mcl_minecarts.speed_max
	if not dir then
		dir, last_switch = mcl_minecarts:get_rail_direction(pos, cart_dir, ctrl, self._old_switch, self._railtype)
	end
	
	local new_acc = {x=0, y=0, z=0}
	if vector.equals(dir, {x=0, y=0, z=0}) then
		vel = {x=0, y=0, z=0}
		update.vel = true
	else
		-- If the direction changed
		if dir.x ~= 0 and self._old_dir.z ~= 0 then
			vel.x = dir.x * math.abs(vel.z)
			vel.z = 0
			pos.z = math.floor(pos.z + 0.5)
			update.pos = true
		end
		if dir.z ~= 0 and self._old_dir.x ~= 0 then
			vel.z = dir.z * math.abs(vel.x)
			vel.x = 0
			pos.x = math.floor(pos.x + 0.5)
			update.pos = true
		end
		-- Up, down?
		if dir.y ~= self._old_dir.y then
			vel.y = dir.y * math.abs(vel.x + vel.z)
			pos = vector.round(pos)
			update.pos = true
		end
		
		-- Slow down or speed up..
		local acc = dir.y * -1.8
		
		local speed_mod = tonumber(minetest.get_meta(pos):get_string("cart_acceleration"))
		if speed_mod and speed_mod ~= 0 then
			if speed_mod > 0 then
				for _,v in ipairs({"x","y","z"}) do
					if math.abs(vel[v]) >= max_vel then
						speed_mod = 0
						break
					end
				end
			end
			acc = acc + (speed_mod * 8)
		else
			acc = acc - 0.4
		end
		
		new_acc = vector.multiply(dir, acc)
	end
	
	self.object:setacceleration(new_acc)
	self._old_pos = vector.new(pos)
	self._old_dir = vector.new(dir)
	self._old_switch = last_switch
	
	-- Limits
	for _,v in ipairs({"x","y","z"}) do
		if math.abs(vel[v]) > max_vel then
			vel[v] = mcl_minecarts:get_sign(vel[v]) * max_vel
			update.vel = true
		end
	end

	if self._punched then
		self._punched = false
	end
	
	if not (update.vel or update.pos) then
		return
	end
	
	local yaw = 0
	if dir.x < 0 then
		yaw = 0.5
	elseif dir.x > 0 then
		yaw = 1.5
	elseif dir.z < 0 then
		yaw = 1
	end
	self.object:setyaw(yaw * math.pi)
	
	local anim = {x=0, y=0}
	if dir.y == -1 then
		anim = {x=1, y=1}
	elseif dir.y == 1 then
		anim = {x=2, y=2}
	end
	self.object:set_animation(anim, 1, 0)
	
	self.object:setvelocity(vel)
	if update.pos then
		self.object:setpos(pos)
	end
	update = nil
end

minetest.register_entity("mcl_minecarts:minecart", mcl_minecarts.cart)
minetest.register_craftitem("mcl_minecarts:minecart", {
	description = "Minecart",
	inventory_image = minetest.inventorycube("cart_top.png", "cart_side.png", "cart_side.png"),
	wield_image = "cart_side.png",
	stack_max = 1,
	on_place = function(itemstack, placer, pointed_thing)
		if not pointed_thing.type == "node" then
			return
		end
		if mcl_minecarts:is_rail(pointed_thing.under) then
			minetest.add_entity(pointed_thing.under, "mcl_minecarts:minecart")
		elseif mcl_minecarts:is_rail(pointed_thing.above) then
			minetest.add_entity(pointed_thing.above, "mcl_minecarts:minecart")
		else return end
		
		itemstack:take_item()
		return itemstack
	end,
	groups = { minecart = 1, transport = 1},
})

minetest.register_craft({
	output = "mcl_minecarts:minecart",
	recipe = {
		{"mcl_core:steel_ingot", "", "mcl_core:steel_ingot"},
		{"mcl_core:steel_ingot", "mcl_core:steel_ingot", "mcl_core:steel_ingot"},
	},
})
