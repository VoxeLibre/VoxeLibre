-- 
-- Snowballs and other throwable items
--

local GRAVITY = tonumber(minetest.setting_get("movement_gravity"))
local snowball_VELOCITY=19
local egg_VELOCITY=19
local pearl_VELOCITY=19

--Shoot item
local throw_function = function (entity_name, velocity)
	local func = function(item, player, pointed_thing)
		local playerpos=player:getpos()
		local obj=minetest.add_entity({x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, entity_name)
		local dir=player:get_look_dir()
		obj:setvelocity({x=dir.x*velocity, y=dir.y*velocity, z=dir.z*velocity})
		obj:setacceleration({x=dir.x*-3, y=-GRAVITY, z=dir.z*-3})
		obj:get_luaentity()._thrower = player:get_player_name()
		item:take_item()
		return item
	end
	return func
end

-- The snowball entity
local snowball_ENTITY={
	physical = false,
	timer=0,
	textures = {"mcl_throwing_snowball.png"},
	_lastpos={},
	collisionbox = {0,0,0,0,0,0},
}
local egg_ENTITY={
	physical = false,
	timer=0,
	textures = {"mcl_throwing_egg.png"},
	_lastpos={},
	collisionbox = {0,0,0,0,0,0},
}
-- Ender pearl entity
local pearl_ENTITY={
	physical = false,
	timer=0,
	textures = {"mcl_throwing_ender_pearl.png"},
	_lastpos={},
	collisionbox = {0,0,0,0,0,0},
	_thrower = nil,		-- Player ObjectRef of the player who threw the ender pearl
}

-- Snowball and egg entity on_step()--> called when snowball is moving.
local on_step = function(self, dtime)
	self.timer=self.timer+dtime
	local pos = self.object:getpos()
	local node = minetest.get_node(pos)

	-- Remove when hitting a node.
	if self._lastpos.x~=nil then
		if node.name ~= "air" then
			self.object:remove()
			return
		end
	end
	self._lastpos={x=pos.x, y=pos.y, z=pos.z} -- Set _lastpos-->Node will be added at last pos outside the node
end

-- Movement function of ender pearl
local pearl_on_step = function(self, dtime)
	self.timer=self.timer+dtime
	local pos = self.object:getpos()
	local node = minetest.get_node(pos)

	--Become item when hitting a node.
	if self._lastpos.x~=nil then
		if node.name ~= "air" then
			local player = minetest.get_player_by_name(self._thrower)
			if player then
				-- Teleport and hurt player
				player:setpos(pos)
				player:set_hp(player:get_hp() - 5)
			end
			self.object:remove()
			return
		end
	end
	self._lastpos={x=pos.x, y=pos.y, z=pos.z} -- Set lastpos-->Node will be added at last pos outside the node
end

snowball_ENTITY.on_step = on_step
egg_ENTITY.on_step = on_step
pearl_ENTITY.on_step = pearl_on_step

minetest.register_entity("mcl_throwing:snowball_entity", snowball_ENTITY)
minetest.register_entity("mcl_throwing:egg_entity", egg_ENTITY)
minetest.register_entity("mcl_throwing:ender_pearl_entity", pearl_ENTITY)

-- Snowball
minetest.register_craftitem("mcl_throwing:snowball", {
	description = "Snowball",
	inventory_image = "mcl_throwing_snowball.png",
	stack_max = 16,
	on_use = throw_function("mcl_throwing:snowball_entity", snowball_VELOCITY),
	on_construct = function(pos)
	pos.y = pos.y - 1
		if minetest.get_node(pos).name == "default:dirt_with_grass" then
			minetest.set_node(pos, {name="default:dirt_with_snow"})
		end
	end,
})

-- Egg
minetest.register_craftitem("mcl_throwing:egg", {
	description = "Egg",
	inventory_image = "mcl_throwing_egg.png",
	stack_max = 16,
	on_use = throw_function("mcl_throwing:egg_entity", egg_VELOCITY),
	groups = { craftitem = 1 },
})

-- Ender Pearl
minetest.register_craftitem("mcl_throwing:ender_pearl", {
	description = "Ender Pearl",
	wield_image = "mcl_throwing_ender_pearl.png",
	inventory_image = "mcl_throwing_ender_pearl.png",
	stack_max = 16,
	on_use = throw_function("mcl_throwing:ender_pearl_entity", pearl_VELOCITY),
})

