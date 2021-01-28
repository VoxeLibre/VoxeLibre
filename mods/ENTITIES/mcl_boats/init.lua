local S = minetest.get_translator("mcl_boats")
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
local paddling_speed = 22
local boat_y_offset = 0.35
local boat_y_offset_ground = boat_y_offset + 0.6
local boat_side_offset = 1.001

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
	hp_max = 4,

	_driver = nil, -- Attached driver (player) or nil if none
	_v = 0, -- Speed
	_last_v = 0, -- Temporary speed variable
	_removed = false, -- If true, boat entity is considered removed (e.g. after punch) and should be ignored
	_itemstring = "mcl_boats:boat", -- Itemstring of the boat item (implies boat type)
	_animation = 0, -- 0: not animated; 1: paddling forwards; -1: paddling forwards
}

local function detach_player(player)
	player:set_detach()
	player:set_properties({visual_size = {x=1, y=1}})
	mcl_player.player_attached[player:get_player_name()] = false
	mcl_player.player_set_animation(player, "stand" , 30)
end

minetest.register_on_respawnplayer(detach_player)

function boat.on_rightclick(self, clicker)
	if self._driver or not clicker or not clicker:is_player() or clicker:get_attach() then
		return
	end
	local name = clicker:get_player_name()
	--[[if attach and attach:get_luaentity() then
		local luaentity = attach:get_luaentity()
		if luaentity._driver then
			luaentity._driver = nil
		end
		clicker:set_detach()
		clicker:set_properties({visual_size = {x=1, y=1}})
	end--]]
	self._driver = clicker
	clicker:set_attach(self.object, "",
		{x = 0, y = 0.42, z = -1}, {x = 0, y = 0, z = 0})
	clicker:set_properties({ visual_size = driver_visual_size })
	mcl_player.player_attached[name] = true
	minetest.after(0.2, function(name)
		local player = minetest.get_player_by_name(name)
		if player then
			mcl_player.player_set_animation(player, "sit" , 30)
		end
	end, name)
	clicker:set_look_horizontal(self.object:get_yaw())
	mcl_tmp_message.message(clicker, S("Sneak to dismount"))
end


function boat.on_activate(self, staticdata, dtime_s)
	--self.object:set_armor_groups({immortal = 1})
	local data = minetest.deserialize(staticdata)
	if type(data) == "table" then
		self._v = data.v
		self._last_v = self._v
		self._itemstring = data.itemstring
		self.object:set_properties({textures = data.textures, damage_texture_modifier = ""})
	end
end


function boat.get_staticdata(self)
	return minetest.serialize({
		v = self._v,
		itemstring = self._itemstring,
		textures = self.object:get_properties().textures
	})
end


function boat.on_death(self, killer)
	if killer and killer:is_player() and minetest.is_creative_enabled(killer:get_player_name()) then
		local inv = killer:get_inventory()
		if not inv:contains_item("main", self._itemstring) then
			inv:add_item("main", self._itemstring)
		end
	else
		minetest.add_item(self.object:get_pos(), self._itemstring)
	end
	if self._driver then
		detach_player(self._driver)
	end
	self._driver = nil
end

function boat.on_step(self, dtime, moveresult)
	self._v = get_v(self.object:get_velocity()) * get_sign(self._v)
	local on_water = true
	local in_water = false
	local v_factor = 1
	local v_slowdown = 0.02
	local p = self.object:get_pos()
	if (not is_water({x=p.x, y=p.y-boat_y_offset, z=p.z})) then
		on_water = false
		v_factor = 0.5
		v_slowdown = 0.04
	elseif (is_water({x=p.x, y=p.y-boat_y_offset+1, z=p.z})) then
		on_water = false
		in_water = true
		v_factor = 0.75
		v_slowdown = 0.05
	end

	if moveresult and moveresult.collides then
		for _, collision in ipairs(moveresult.collisions) do
			local pos = collision.node_pos
			if collision.type == "node" and minetest.get_node_group(minetest.get_node(pos).name, "dig_by_boat") > 0 then
				minetest.dig_node(pos)
			end
		end
	end

	if self._driver then
		local ctrl = self._driver:get_player_control()
		if ctrl.sneak then
			detach_player(self._driver)
			local pos = self._driver:get_pos()
			pos = {x = pos.x, y = pos.y + 0.2, z = pos.z}
			self._driver:set_pos(pos)
			self._driver = nil
			return
		end
		local yaw = self.object:get_yaw()
		if ctrl.up then
			-- Forwards
			self._v = self._v + 0.1 * v_factor

			-- Paddling animation
			if self._animation ~= 1 then
				self.object:set_animation({x=0, y=40}, paddling_speed, 0, true)
				self._animation = 1
			end
		elseif ctrl.down then
			-- Backwards
			self._v = self._v - 0.1 * v_factor

			-- Paddling animation, reversed
			if self._animation ~= -1 then
				self.object:set_animation({x=0, y=40}, -paddling_speed, 0, true)
				self._animation = -1
			end
		else
			-- Stop paddling animation if no control pressed
			if self._animation ~= 0 then
				self.object:set_animation({x=0, y=40}, 0, 0, true)
				self._animation = 0
			end
		end
		if ctrl.left then
			if self._v < 0 then
				self.object:set_yaw(yaw - (1 + dtime) * 0.03 * v_factor)
			else
				self.object:set_yaw(yaw + (1 + dtime) * 0.03 * v_factor)
			end
		elseif ctrl.right then
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
	end
	local s = get_sign(self._v)
	if not on_water and not in_water and math.abs(self._v) > 1.0 then
		v_slowdown = math.min(math.abs(self._v) - 1.0, v_slowdown * 5)
	elseif in_water and math.abs(self._v) > 1.5 then
		v_slowdown = math.min(math.abs(self._v) - 1.5, v_slowdown * 5)
	end
	self._v = self._v - v_slowdown * s
	if s ~= get_sign(self._v) then
		self._v = 0
	end

	p.y = p.y - boat_y_offset
	local new_velo
	local new_acce = {x = 0, y = 0, z = 0}
	if not is_water(p) then
		-- Not on water or inside water: Free fall
		local nodedef = minetest.registered_nodes[minetest.get_node(p).name]
		new_acce = {x = 0, y = -9.8, z = 0}
		new_velo = get_velocity(self._v, self.object:get_yaw(),
			self.object:get_velocity().y)
	else
		p.y = p.y + 1
		if is_water(p) then
			-- Inside water: Slowly sink
			local y = self.object:get_velocity().y
			y = y - 0.01
			if y < -0.2 then
				y = -0.2
			end
			new_acce = {x = 0, y = 0, z = 0}
			new_velo = get_velocity(self._v, self.object:get_yaw(), y)
		else
			-- On top of water
			new_acce = {x = 0, y = 0, z = 0}
			if math.abs(self.object:get_velocity().y) < 0 then
				new_velo = get_velocity(self._v, self.object:get_yaw(), 0)
			else
				new_velo = get_velocity(self._v, self.object:get_yaw(),
					self.object:get_velocity().y)
			end
		end
	end

	-- Terminal velocity: 8 m/s per axis of travel
	for _,axis in pairs({"z","y","x"}) do
		if math.abs(new_velo[axis]) > 8 then
			new_velo[axis] = 8 * get_sign(new_velo[axis])
		end
	end

	self.object:set_velocity(new_velo)
	self.object:set_acceleration(new_acce)
end

-- Register one entity for all boat types
minetest.register_entity("mcl_boats:boat", boat)

local boat_ids = { "boat", "boat_spruce", "boat_birch", "boat_jungle", "boat_acacia", "boat_dark_oak" }
local names = { S("Oak Boat"), S("Spruce Boat"), S("Birch Boat"), S("Jungle Boat"), S("Acacia Boat"), S("Dark Oak Boat") }
local craftstuffs = {}
if minetest.get_modpath("mcl_core") then
	craftstuffs = { "mcl_core:wood", "mcl_core:sprucewood", "mcl_core:birchwood", "mcl_core:junglewood", "mcl_core:acaciawood", "mcl_core:darkwood" }
end
local images = { "oak", "spruce", "birch", "jungle", "acacia", "dark_oak" }

for b=1, #boat_ids do
	local itemstring = "mcl_boats:"..boat_ids[b]

	local longdesc, usagehelp, tt_help, help, helpname
	help = false
	-- Only create one help entry for all boats
	if b == 1 then
		help = true
		longdesc = S("Boats are used to travel on the surface of water.")
		usagehelp = S("Rightclick on a water source to place the boat. Rightclick the boat to enter it. Use [Left] and [Right] to steer, [Forwards] to speed up and [Backwards] to slow down or move backwards. Rightclick the boat again to leave it, punch the boat to make it drop as an item.")
		helpname = S("Boat")
	end
	tt_help = S("Water vehicle")

	minetest.register_craftitem(itemstring, {
		description = names[b],
		_tt_help = tt_help,
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
				return itemstack
			end

			-- Call on_rightclick if the pointed node defines it
			local node = minetest.get_node(pointed_thing.under)
			if placer and not placer:get_player_control().sneak then
				if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
					return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
				end
			end

			local pos = table.copy(pointed_thing.under)
			local dir = vector.subtract(pointed_thing.above, pointed_thing.under)

			if math.abs(dir.x) > 0.9 or math.abs(dir.z) > 0.9 then
				pos = vector.add(pos, vector.multiply(dir, boat_side_offset))
			elseif is_water(pos) then
				pos = vector.add(pos, vector.multiply(dir, boat_y_offset))
			else
				pos = vector.add(pos, vector.multiply(dir, boat_y_offset_ground))
			end
			local boat = minetest.add_entity(pos, "mcl_boats:boat")
			boat:get_luaentity()._itemstring = itemstring
			boat:set_properties({textures = { "mcl_boats_texture_"..images[b].."_boat.png" }})
			boat:set_yaw(placer:get_look_horizontal())
			if not minetest.is_creative_enabled(placer:get_player_name()) then
				itemstack:take_item()
			end
			return itemstack
		end,
		_on_dispense = function(stack, pos, droppos, dropnode, dropdir)
			local below = {x=droppos.x, y=droppos.y-1, z=droppos.z}
			local belownode = minetest.get_node(below)
			-- Place boat as entity on or in water
			if minetest.get_item_group(dropnode.name, "water") ~= 0 or (dropnode.name == "air" and minetest.get_item_group(belownode.name, "water") ~= 0) then
				minetest.add_entity(droppos, "mcl_boats:boat")
			else
				minetest.add_item(droppos, stack)
			end
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
