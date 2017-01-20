-- 
-- Snowballs
--

local GRAVITY = 9.81
local snowball_VELOCITY=19
local egg_VELOCITY=19

--Shoot snowball.
local throw_function = function (entity_name, velocity)
	local func = function(item, player, pointed_thing)
		local playerpos=player:getpos()
		local obj=minetest.add_entity({x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, entity_name)
		local dir=player:get_look_dir()
		obj:setvelocity({x=dir.x*velocity, y=dir.y*velocity, z=dir.z*velocity})
		obj:setacceleration({x=dir.x*-3, y=-GRAVITY, z=dir.z*-3})
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
	lastpos={},
	collisionbox = {0,0,0,0,0,0},
}
local egg_ENTITY={
	physical = false,
	timer=0,
	textures = {"mcl_throwing_egg.png"},
	lastpos={},
	collisionbox = {0,0,0,0,0,0},
}

-- Snowball_entity.on_step()--> called when snowball is moving.
local on_step = function(self, dtime)
	self.timer=self.timer+dtime
	local pos = self.object:getpos()
	local node = minetest.get_node(pos)

	--Become item when hitting a node.
	if self.lastpos.x~=nil then --If there is no lastpos for some reason.
		if node.name ~= "air" then
			self.object:remove()
		end
	end
	self.lastpos={x=pos.x, y=pos.y, z=pos.z} -- Set lastpos-->Node will be added at last pos outside the node
end

minetest.register_entity("mcl_throwing:snowball_entity", snowball_ENTITY)
minetest.register_entity("mcl_throwing:egg_entity", egg_ENTITY)

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

minetest.register_craftitem("mcl_throwing:egg", {
	description = "Egg",
	inventory_image = "mcl_throwing_egg.png",
	stack_max = 16,
	on_use = throw_function("mcl_throwing:egg_entity", egg_VELOCITY),
	groups = { craftitem = 1 },
})
