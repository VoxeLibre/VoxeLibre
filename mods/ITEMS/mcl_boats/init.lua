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

local boat_visual_size = {x = 3, y = 3}
-- Note: This mod assumes the default player visual_size is {x=1, y=1}
local driver_visual_size = { x = 1/boat_visual_size.x, y = 1/boat_visual_size.y }

--
-- Boat entity
--

local boat = {
	physical = true,
	-- Warning: Do not change the position of the collisionbox top surface,
	-- lowering it causes the boat to fall through the world if underwater
	collisionbox = {-0.5, -0.35, -0.5, 0.5, 0.3, 0.5},
	visual = "mesh",
	mesh = "mcl_boats_boat.b3d",
	textures = {"mcl_boats_texture_oak_boat.png"},
	visual_size = boat_visual_size,
	  rotate = -180,
		animation = {
		speed_normal = 25,		speed_run = 50,
		stand_start = 0,		stand_end = 0,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},

	_driver = nil, -- Attached driver (player) or nil if none
	_v = 0, -- Speed
	_last_v = 0, -- Temporary speed variable
	_removed = false, -- If true, boat entity is considered removed (e.g. after punch) and should be ignored
	_itemstring = "mcl_boats:boat", -- Itemstring of the boat item (implies boat type)
}

function boat.on_rightclick(self, clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	local name = clicker:get_player_name()
	if self._driver and clicker == self._driver then
		self._driver = nil
		clicker:set_detach()
		clicker:set_properties({visual_size = {x=1, y=1}})
		mcl_player.player_attached[name] = false
		mcl_player.player_set_animation(clicker, "stand" , 30)
		local pos = clicker:getpos()
		pos = {x = pos.x, y = pos.y + 0.2, z = pos.z}
		clicker:setpos(pos)
	elseif not self._driver then
		local attach = clicker:get_attach()
		if attach and attach:get_luaentity() then
			local luaentity = attach:get_luaentity()
			if luaentity._driver then
				luaentity._driver = nil
			end
			clicker:set_detach()
			clicker:set_properties({visual_size = {x=1, y=1}})
		end
		self._driver = clicker
		clicker:set_attach(self.object, "",
			{x = 0, y = 3.75, z = -1}, {x = 0, y = 0, z = 0})
		clicker:set_properties({ visual_size = driver_visual_size })
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
	local data = minetest.deserialize(staticdata)
	if type(data) == "table" then
		self._v = data.v
		self._last_v = self._v
		self._itemstring = data.itemstring
		self.object:set_properties({textures=data.textures})
	end
end


function boat.get_staticdata(self)
	return minetest.serialize({
		v = self._v,
		itemstring = self._itemstring,
		textures = self.object:get_properties().textures
	})
end


function boat.on_punch(self, puncher)
	if not puncher or not puncher:is_player() or self._removed then
		return
	end
	if self._driver and puncher == self._driver then
		self._driver = nil
		puncher:set_detach()
		puncher:set_properties({visual_size = {x=1, y=1}})
		mcl_player.player_attached[puncher:get_player_name()] = false
	end
	if not self._driver then
		self._removed = true
		-- Drop boat as item on the ground after punching
		if not minetest.setting_getbool("creative_mode") then
			minetest.add_item(self.object:getpos(), self._itemstring)
		end
		self.object:remove()
	end
end


function boat.on_step(self, dtime)
	self._v = get_v(self.object:getvelocity()) * get_sign(self._v)
	if self._driver then
		local ctrl = self._driver:get_player_control()
		local yaw = self.object:getyaw()
		if ctrl.up then
			self._v = self._v + 0.1
		elseif ctrl.down then
			self._v = self._v - 0.1
		end
		if ctrl.left then
			if self._v < 0 then
				self.object:setyaw(yaw - (1 + dtime) * 0.03)
			else
				self.object:setyaw(yaw + (1 + dtime) * 0.03)
			end
		elseif ctrl.right then
			if self._v < 0 then
				self.object:setyaw(yaw + (1 + dtime) * 0.03)
			else
				self.object:setyaw(yaw - (1 + dtime) * 0.03)
			end
		end
	end
	local velo = self.object:getvelocity()
	if self._v == 0 and velo.x == 0 and velo.y == 0 and velo.z == 0 then
		self.object:setpos(self.object:getpos())
		return
	end
	local s = get_sign(self._v)
	self._v = self._v - 0.02 * s
	if s ~= get_sign(self._v) then
		self.object:setvelocity({x = 0, y = 0, z = 0})
		self._v = 0
		return
	end
	if math.abs(self._v) > 5 then
		self._v = 5 * get_sign(self._v)
	end

	local p = self.object:getpos()
	p.y = p.y - 0.5
	local new_velo
	local new_acce = {x = 0, y = 0, z = 0}
	if not is_water(p) then
		local nodedef = minetest.registered_nodes[minetest.get_node(p).name]
		if (not nodedef) or nodedef.walkable then
			self._v = 0
			new_acce = {x = 0, y = 1, z = 0}
		else
			new_acce = {x = 0, y = -9.8, z = 0}
		end
		new_velo = get_velocity(self._v, self.object:getyaw(),
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
			new_velo = get_velocity(self._v, self.object:getyaw(), y)
			self.object:setpos(self.object:getpos())
		else
			new_acce = {x = 0, y = 0, z = 0}
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y) + 0.5
				self.object:setpos(pos)
				new_velo = get_velocity(self._v, self.object:getyaw(), 0)
			else
				new_velo = get_velocity(self._v, self.object:getyaw(),
					self.object:getvelocity().y)
				self.object:setpos(self.object:getpos())
			end
		end
	end
	self.object:setvelocity(new_velo)
	self.object:setacceleration(new_acce)
end

-- Register one entity for all boat types
minetest.register_entity("mcl_boats:boat", boat)

local boat_ids = { "boat", "boat_spruce", "boat_birch", "boat_jungle", "boat_acacia", "boat_dark_oak" }
local names = { "Oak Boat", "Spruce Boat", "Birch Boat", "Jungle Boat", "Acacia Boat", "Dark Oak Boat" }
local craftstuffs = { "mcl_core:wood", "mcl_core:sprucewood", "mcl_core:birchwood", "mcl_core:junglewood", "mcl_core:acaciawood", "mcl_core:darkwood" }
local images = { "oak", "spruce", "birch", "jungle", "acacia", "dark_oak" }

for b=1, #boat_ids do
	local itemstring = "mcl_boats:"..boat_ids[b]

	local longdesc, usagehelp, help, helpname
	help = false
	-- Only create one help entry for all boats
	if b == 1 then
		help = true
		longdesc = "Boats are used to travel on the surface of water."
		usagehelp = "Rightclick on a water source to place the boat. Rightclick the boat to enter it. Use [Left] and [Right] to steer, [Forwards] to speed up and [Backwards] to slow down or move backwards. Rightclick the boat again to leave it, punch the boat to make it drop as an item."
		helpname = "Boat"
	end

	minetest.register_craftitem(itemstring, {
		description = names[b],
		_doc_items_create_entry = help,
		_doc_items_entry_name = helpname,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = usagehelp,
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
			local boat = minetest.add_entity(pointed_thing.under, "mcl_boats:boat")
			boat:get_luaentity()._itemstring = itemstring
			boat:set_properties({textures = { "mcl_boats_texture_"..images[b].."_boat.png" }})
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

if minetest.get_modpath("doc_identifier") ~= nil then
	doc.sub.identifier.register_object("mcl_boats:boat", "craftitems", "mcl_boats:boat")
end
