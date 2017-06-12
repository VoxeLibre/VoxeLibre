--
-- Helper functions
--

local function is_water(pos)
	local nn = minetest.get_node(pos).name
	return minetest.get_item_group(nn, "water") ~= 0
end


local function get_sign(i)
	if i == 0 then
		return 0
	else
		return i / math.abs(i)
	end
end


local function get_velocity(v, yaw, y)
	local x = -math.sin(yaw) * v
	local z =  math.cos(yaw) * v
	return {x = x, y = y, z = z}
end


local function get_v(v)
	return math.sqrt(v.x ^ 2 + v.z ^ 2)
end

--
-- Boat entity
--

local boat = {
	physical = true,
	-- Warning: Do not change the position of the collisionbox top surface,
	-- lowering it causes the boat to fall through the world if underwater
	collisionbox = {-0.5, -0.35, -0.5, 0.5, 0.3, 0.5},
	visual = "mesh",
	mesh = "boat.b3d",
	textures = {"boat.png"},
	visual_size = {x=3, y=3},
	  rotate = -180,
		animation = {
		speed_normal = 25,		speed_run = 50,
		stand_start = 0,		stand_end = 0,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},
	driver = nil,
	v = 0,
	last_v = 0,
	removed = false
}

--[[
--###################
--################### BOAT
--###################

mobs:register_mob("amc:81boat", {
	type = "animal",
	passive = true,
    runaway = true,
    stepheight = 1.2,
	hp_min = 30,
	hp_max = 60,
	armor = 150,
    collisionbox = {-0.35, -0.01, -0.35, 0.35, 2, 0.35},
    rotate = -180,
	visual = "mesh",
	mesh = "boat.b3d",
    textures = {{"boat.png"},{"boat1.png"},{"boat2.png"},{"boat3.png"},{"boat4.png"},{"boat5.png"},{"boat6.png"},},
	visual_size = {x=3, y=3},
	walk_velocity = 0.6,
	run_velocity = 2,
	jump = true,
	animation = {
		speed_normal = 25,		speed_run = 50,
		stand_start = 0,		stand_end = 0,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},
})
]]
function boat.on_rightclick(self, clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	local name = clicker:get_player_name()
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
		mcl_player.player_attached[name] = false
		mcl_player.player_set_animation(clicker, "stand" , 30)
		local pos = clicker:getpos()
		pos = {x = pos.x, y = pos.y + 0.2, z = pos.z}
		minetest.after(0.1, function()
			clicker:setpos(pos)
		end)
	elseif not self.driver then
		local attach = clicker:get_attach()
		if attach and attach:get_luaentity() then
			local luaentity = attach:get_luaentity()
			if luaentity.driver then
				luaentity.driver = nil
			end
			clicker:set_detach()
		end
		self.driver = clicker
		clicker:set_attach(self.object, "",
			{x = 0, y = 11, z = -3}, {x = 0, y = 0, z = 0})
		mcl_player.player_attached[name] = true
		minetest.after(0.2, function(clicker)
			if clicker:is_player() then
				mcl_player.player_set_animation(clicker, "sit" , 30)
			end
		end, clicker)
		clicker:set_look_horizontal(self.object:getyaw())
	end
end


function boat.on_activate(self, staticdata, dtime_s)
	self.object:set_armor_groups({immortal = 1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
	self.last_v = self.v
end


function boat.get_staticdata(self)
	return tostring(self.v)
end


function boat.on_punch(self, puncher)
	if not puncher or not puncher:is_player() or self.removed then
		return
	end
	if self.driver and puncher == self.driver then
		self.driver = nil
		puncher:set_detach()
		mcl_player.player_attached[puncher:get_player_name()] = false
	end
	if not self.driver then
		self.removed = true
		local inv = puncher:get_inventory()
		if not (creative and creative.is_enabled_for
				and creative.is_enabled_for(puncher:get_player_name()))
				or not inv:contains_item("main", "mcl_boats:boat") then
			local leftover = inv:add_item("main", "mcl_boats:boat")
			-- if no room in inventory add a replacement boat to the world
			if not leftover:is_empty() then
				minetest.add_item(self.object:getpos(), leftover)
			end
		end
		-- delay remove to ensure player is detached
		minetest.after(0.1, function()
			self.object:remove()
		end)
	end
end


function boat.on_step(self, dtime)
	self.v = get_v(self.object:getvelocity()) * get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		local yaw = self.object:getyaw()
		if ctrl.up then
			self.v = self.v + 0.1
		elseif ctrl.down then
			self.v = self.v - 0.1
		end
		if ctrl.left then
			if self.v < 0 then
				self.object:setyaw(yaw - (1 + dtime) * 0.03)
			else
				self.object:setyaw(yaw + (1 + dtime) * 0.03)
			end
		elseif ctrl.right then
			if self.v < 0 then
				self.object:setyaw(yaw + (1 + dtime) * 0.03)
			else
				self.object:setyaw(yaw - (1 + dtime) * 0.03)
			end
		end
	end
	local velo = self.object:getvelocity()
	if self.v == 0 and velo.x == 0 and velo.y == 0 and velo.z == 0 then
		self.object:setpos(self.object:getpos())
		return
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02 * s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x = 0, y = 0, z = 0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 5 then
		self.v = 5 * get_sign(self.v)
	end

	local p = self.object:getpos()
	p.y = p.y - 0.5
	local new_velo
	local new_acce = {x = 0, y = 0, z = 0}
	if not is_water(p) then
		local nodedef = minetest.registered_nodes[minetest.get_node(p).name]
		if (not nodedef) or nodedef.walkable then
			self.v = 0
			new_acce = {x = 0, y = 1, z = 0}
		else
			new_acce = {x = 0, y = -9.8, z = 0}
		end
		new_velo = get_velocity(self.v, self.object:getyaw(),
			self.object:getvelocity().y)
		self.object:setpos(self.object:getpos())
	else
		p.y = p.y + 1
		if is_water(p) then
			local y = self.object:getvelocity().y
			if y >= 5 then
				y = 5
			elseif y < 0 then
				new_acce = {x = 0, y = 20, z = 0}
			else
				new_acce = {x = 0, y = 5, z = 0}
			end
			new_velo = get_velocity(self.v, self.object:getyaw(), y)
			self.object:setpos(self.object:getpos())
		else
			new_acce = {x = 0, y = 0, z = 0}
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y) + 0.5
				self.object:setpos(pos)
				new_velo = get_velocity(self.v, self.object:getyaw(), 0)
			else
				new_velo = get_velocity(self.v, self.object:getyaw(),
					self.object:getvelocity().y)
				self.object:setpos(self.object:getpos())
			end
		end
	end
	self.object:setvelocity(new_velo)
	self.object:setacceleration(new_acce)
end






--mc2code
--[[
--
-- Helper functions
--
local init = os.clock()

local function is_water(pos)
	local nn = minetest.get_node(pos).name
	return minetest.get_item_group(nn, "water") ~= 0
end

local function get_velocity(v, yaw, y)
	local x = -math.sin(yaw)*v
	local z = math.cos(yaw)*v
	return {x=x, y=y, z=z}
end

--
-- boat entity
--
local boat = {
	physical = true,
	--collisionbox = {-1,-0.5,-1, 1,0.5,1},
	collisionbox = {-0.5, -0.35, -0.5, 0.5, 0.3, 0.5},
	visual = "mesh",
	--mesh = "mcl_boats_base.x",
	mesh = "boats_boat.obj",
	--textures = {"mcl_boats_texture.png"},
	textures = {"default_wood.png"},
	_driver = nil,
	_v = 0,
	_stepcount = 0,
	_unattended = 0
}

function boat.on_rightclick(self, clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self._driver and clicker == self._driver then
		self._driver = nil
		clicker:set_detach()
	elseif not self._driver then
		self._driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function boat.on_activate(self, staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self._v = tonumber(staticdata)
	end
end

function boat.get_staticdata(self)
	return tostring(self._v)
end

function boat.on_punch(self, puncher, time_from_last_punch, tool_capabilities, direction)

	 if self._driver then
		self._driver:set_detach()
		self._driver = nil
		if puncher and puncher:is_player() and (not minetest.setting_getbool("creative_mode")) then
			puncher:get_inventory():add_item("main", "mcl_boats:boat")
		end
		self.object:remove()
	else

		if puncher and puncher:is_player() and (not minetest.setting_getbool("creative_mode")) then
			puncher:get_inventory():add_item("main", "mcl_boats:boat")
		end
		self.object:remove()
	
	end
end

function boat.on_step(self, dtime)

	self._stepcount=self._stepcount+1
	if self._stepcount>9 then
	
		self._stepcount=0
		
		if self._driver then
			local ctrl = self._driver:get_player_control()

			self._unattended=0
		
			local yaw = self.object:getyaw()

			if ctrl.up and self._v<6 then  --was3
				self._v = self._v + 1
			end
			
			if ctrl.down and self._v>=-1 then
				self._v = self._v - 1
			end	
			
			if ctrl.left then
				if ctrl.down then
					self.object:setyaw(yaw-math.pi/12-dtime*math.pi/12)
				else
					self.object:setyaw(yaw+math.pi/12+dtime*math.pi/12)
				end
			end
			if ctrl.right then
				if ctrl.down then
					self.object:setyaw(yaw+math.pi/12+dtime*math.pi/12)
				else
					self.object:setyaw(yaw-math.pi/12-dtime*math.pi/12)
				end
			end
		end

		local tmp_velocity = get_velocity(self._v, self.object:getyaw(), 0)

		local tmp_pos = self.object:getpos()

		tmp_velocity.y=0

		if is_water(tmp_pos) then
			tmp_velocity.y=2
		end

		tmp_pos.y=tmp_pos.y-0.5

		if minetest.get_node(tmp_pos).name=="air" then
			tmp_velocity.y=-2
		end

		self.object:setvelocity(tmp_velocity)

	end
	
end
]]
local boat_ids = { "boat", "boat_spruce", "boat_birch", "boat_jungle", "boat_acacia", "boat_dark_oak" }
local names = { "Oak Boat", "Spruce Boat", "Birch Boat", "Jungle Boat", "Acacia Boat", "Dark Oak Boat" }
local craftstuffs = { "mcl_core:wood", "mcl_core:sprucewood", "mcl_core:birchwood", "mcl_core:junglewood", "mcl_core:acaciawood", "mcl_core:darkwood" }
local images = { "oak", "spruce", "birch", "jungle", "acacia", "dark_oak" }

for b=1, #boat_ids do
	local itemstring = "mcl_boats:"..boat_ids[b]
	minetest.register_entity(itemstring, boat)

	minetest.register_craftitem(itemstring, {
		description = names[b],
		inventory_image = "mcl_boats_"..images[b].."_boat.png",
		liquids_pointable = true,
		groups = { boat = 1, transport = 1},
		stack_max = 1,
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return
			end

			-- Call on_rightclick if the pointed node defines it
			local node = minetest.get_node(pointed_thing.under)
			if placer and not placer:get_player_control().sneak then
				if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
					return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
				end
			end

			if not is_water(pointed_thing.under) then
				return
			end
			pointed_thing.under.y = pointed_thing.under.y+0.5
			minetest.add_entity(pointed_thing.under, itemstring)
			if not minetest.setting_getbool("creative_mode") then
				itemstack:take_item()
			end
			return itemstack
		end,
	})

	local c = craftstuffs[b]
	minetest.register_craft({
		output = itemstring,
		recipe = {
			{c, "", c},
			{c, c, c},
		},
	})
end

minetest.register_craft({
	type = "fuel",
	recipe = "group:boat",
	burntime = 20,
})

