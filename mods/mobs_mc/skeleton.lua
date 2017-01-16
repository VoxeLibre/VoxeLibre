--MCmobs v0.2
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes


--dofile(minetest.get_modpath("mobs").."/api.lua")

mobs:register_mob("mobs_mc:skeleton", {
	type = "monster",
	hp_max = 30,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1.9, 0.4},
	pathfinding = true,
	group_attack = true,
	visual = "mesh",
	mesh = "mobs_skeleton.x",
	textures = {
	{"mobs_skeleton.png"}
	},
	makes_footstep_sound = true,
	sounds = {
		random = "skeleton1",
		death = "skeletondeath",
		damage = "skeletonhurt1",
	},
	walk_velocity = 1.2,
	run_velocity = 2.4,
	damage = 1,
	armor = 200,
	drops = {
		{name = "throwing:arrow",
		chance = 1,
		min = 0,
		max = 2,},
		{name = "throwing:bow",
		chance = 11,
		min = 1,
		max = 1,},
		{name = "bonemeal:bone",
		chance = 1,
		min = 0,
		max = 2,},
	},
	animation = {
		speed_normal = 30,
		speed_run = 60,
		stand_start = 0,
		stand_end = 23,
		walk_start = 24,
		walk_end = 49,
		run_start = 24,
		run_end = 49,
		hurt_start = 85,
		hurt_end = 115,
		death_start = 117,
		death_end = 145,
		shoot_start = 50,
		shoot_end = 82,
	},
	drawtype = "front",
	water_damage = 1,
	lava_damage = 5,
	light_damage = 1,
	view_range = 16,
	attack_type = "dogshoot",
	arrow = "mobs:arrow_entity",
	shoot_interval = 2.5,
	shoot_offset = 1,
	--'dogshoot_switch' allows switching between shoot and dogfight modes inside dogshoot using timer (1 = shoot, 2 = dogfight)
	--'dogshoot_count_max' number of seconds before switching above modes.
	dogshoot_switch = 1,
	dogshoot_count_max =3,
})
mobs:register_spawn("mobs_mc:skeleton", {"group:crumbly", "group:cracky", "group:choppy", "group:snappy"}, 7, -1, 5000, 4, 31000)


mobs:register_mob("mobs_mc:skeleton2", {
	type = "monster",
	hp_max = 60,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1.9, 0.4},
	pathfinding = true,
	group_attack = true,
	visual = "mesh",
	mesh = "mobs_skeleton.x",
	textures = {
	{"mobs_skeleton2.png"}
	},
	makes_footstep_sound = true,
	sounds = {
		random = "skeleton1",
		death = "skeletondeath",
		damage = "skeletonhurt1",
	},
	walk_velocity = 1.2,
	run_velocity = 2.4,
	damage = 3,
	armor = 200,
	drops = {
		{name = "throwing:arrow",
		chance = 1,
		min = 0,
		max = 2,},
		{name = "throwing:bow",
		chance = 11,
		min = 1,
		max = 1,},
		{name = "bonemeal:bone",
		chance = 1,
		min = 0,
		max = 2,},
	},
	animation = {
		speed_normal = 30,
		speed_run = 60,
		stand_start = 0,
		stand_end = 23,
		walk_start = 24,
		walk_end = 49,
		run_start = 24,
		run_end = 49,
		hurt_start = 85,
		hurt_end = 115,
		death_start = 117,
		death_end = 145,
		shoot_start = 50,
		shoot_end = 82,
	},
	drawtype = "front",
	water_damage = 1,
	lava_damage = 0,
	light_damage = 0,
	view_range = 16,
	attack_type = "dogshoot",
	arrow = "mobs:arrow_entity",
	shoot_interval = 0.5,
	shoot_offset = 1,
	--'dogshoot_switch' allows switching between shoot and dogfight modes inside dogshoot using timer (1 = shoot, 2 = dogfight)
	--'dogshoot_count_max' number of seconds before switching above modes.
	dogshoot_switch = 1,
	dogshoot_count_max =6,
})
mobs:register_spawn("mobs_mc:skeleton2", {"group:crumbly", "group:cracky", "group:choppy", "group:snappy"}, 7, -1, 5000, 4, -3000)


local THROWING_ARROW_ENTITY={
	physical = false,
	timer=0,
	visual = "wielditem",
	visual_size = {x=0.1, y=0.1},
	textures = {"mobs:arrow_box"},
	--textures = {"esmobs:arrow.png"},
	velocity = 10,
	lastpos={},
	collisionbox = {0,0,0,0,0,0},
}


--ARROW CODE
THROWING_ARROW_ENTITY.on_step = function(self, dtime)
	self.timer=self.timer+dtime
	local pos = self.object:getpos()
	local node = minetest.get_node(pos)

minetest.add_particle({
    pos = pos,
    vel = {x=0, y=0, z=0},
    acc = {x=0, y=0, z=0},
    expirationtime = .3,
    size = 1,
    collisiondetection = false,
    vertical = false,
    texture = "arrow_particle.png",
})

	if self.timer>0.2 then
		local objs = minetest.get_objects_inside_radius({x=pos.x,y=pos.y,z=pos.z}, 1.5)
		for k, obj in pairs(objs) do
			if obj:get_luaentity() ~= nil then
				if obj:get_luaentity().name ~= "mobs:arrow_entity" and obj:get_luaentity().name ~= "__builtin:item" then
					local damage = 3
					minetest.sound_play("damage", {pos = pos})
					obj:punch(self.object, 1.0, {
						full_punch_interval=1.0,
						damage_groups={fleshy=damage},
					}, nil)
					self.object:remove()
				end
			else
				local damage = 3
				minetest.sound_play("damage", {pos = pos})
				obj:punch(self.object, 1.0, {
					full_punch_interval=1.0,
					damage_groups={fleshy=damage},
				}, nil)
				self.object:remove()
			end
		end
	end

	if self.lastpos.x~=nil then
		if node.name ~= "air" then
			minetest.sound_play("bowhit1", {pos = pos})
			--minetest.punch_node(pos)  --this crash game when bones for mobs used
			minetest.add_item(self.lastpos, 'mobs:arrow')
			self.object:remove()
		end
	end
	self.lastpos={x=pos.x, y=pos.y, z=pos.z}
end


arrows = {
	{"throwing:arrow", "throwing:arrow_entity" },
}

-- compatibility
mobs:alias_mob("mobs:skeleton", "mobs_mc:skeleton")

-- spawn eggs
mobs:register_egg("mobs_mc:skeleton", "Skeleton", "spawn_egg_skeleton.png")


if minetest.setting_get("log_mods") then
	minetest.log("action", "MC Skeleton loaded")
end
