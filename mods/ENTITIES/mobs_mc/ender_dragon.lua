--###################
--################### ENDERDRAGON
--###################

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

--[[
mobs:register_mob("mobs_mc:12enderdragon", {
	type = "animal",
	passive = true,
    runaway = true,
    stepheight = 1.2,
	hp_min = 30,
	hp_max = 60,
	armor = 150,
    collisionbox = {-0.35, -0.01, -0.35, 0.35, 2, 0.35},
	visual = "mesh",
	mesh = "enderdragon.b3d",
	textures = {
		{"enderdragon.png"},
	},
	visual_size = {x=1, y=1},
	walk_velocity = 0.6,
	run_velocity = 2,
	jump = true,
	animation = {
		speed_normal = 25,		speed_run = 50,
		stand_start = 0,		stand_end = 20,
		walk_start = 0,		walk_end = 20,
		run_start = 0,		run_end = 20,
	},
})

mobs:register_egg("mobs_mc:12enderdragon", "Enderdragon", "enderdragon_inv.png", 0)	
]]
mobs:register_mob("mobs_mc:enderdragon", {
	type = "monster",
	pathfinding = 1,
	attacks_animals = true,
	walk_chance = 100,
	hp_max = 200,
	hp_min = 200,
	collisionbox = {-2, 3, -2, 2, 5, 2},
	physical = false,
	visual = "mesh",
	mesh = "mobs_mc_dragon.b3d",
	textures = {
		{"mobs_mc_dragon.png"},
	},
	visual_size = {x=3, y=3},
	view_range = 35,
	walk_velocity = 6,
	run_velocity = 6,
	sounds = {
		shoot_attack = "mobs_mc_ender_dragon_shoot",
		attack = "mobs_mc_ender_dragon_attack",
		distance = 60,
	},
	physical = true,
	damage = 10,
	jump = true,
	jump_height = 14,
	stepheight = 1.2,
	jump_chance = 100,
	fear_height = 120,	
	fly = true,
	fly_in = {"air"},
	dogshoot_switch = 1,
	dogshoot_count_max =5,
	dogshoot_count2_max = 5,
	passive = false,
	attack_animals = true,
	drops = {
		{name = mobs_mc.items.dragon_egg,
		chance = 1,
		min = 1,
		max = 1},
	},
	water_damage = 0,
	lava_damage = 0,
	light_damage = 0,
	on_rightclick = nil,
	attack_type = "dogshoot",
	arrow = "mobs_mc:fireball2",
	shoot_interval = 0.5,
	shoot_offset = -1,
	animation = {
		fly_speed = 8, stand_speed = 8,
		stand_start = 0,		stand_end = 20,
		walk_start = 0,		walk_end = 20,
		run_start = 0,		run_end = 20,
	},
	blood_amount = 0,
})


local mobs_griefing = minetest.settings:get_bool("mobs_griefing") ~= false

mobs:register_arrow("mobs_mc:roar_of_the_dragon2", {
	visual = "sprite",
	visual_size = {x = 1, y = 1},
	--textures = {"transparent.png"},
	textures = {"mese_egg.png"},
	velocity = 10,

	on_step = function(self, dtime)

		local pos = self.object:getpos()

		local n = minetest.get_node(pos).name

		if self.timer == 0 then
			self.timer = os.time()
		end

		if os.time() - self.timer > 8 or minetest.is_protected(pos, "") then
			self.object:remove()
		end

		local objects = minetest.get_objects_inside_radius(pos, 1)
	    for _,obj in ipairs(objects) do
			local name = self.name
			if name~="mobs_mc:roar_of_the_dragon2" and name ~= "mobs_mc:enderdragon" then
		        obj:set_hp(obj:get_hp()-0.05)
		        if (obj:get_hp() <= 0) then
		            if (not obj:is_player()) and name ~= self.object:get_luaentity().name then
		                obj:remove()
		            end
		        end
			end
	    end

		if mobs_griefing then
			minetest.set_node(pos, {name="air"})
			if math.random(1,2)==1 then
				local dx = math.random(-1,1)
				local dy = math.random(-1,1)
				local dz = math.random(-1,1)
				local p = {x=pos.x+dx, y=pos.y+dy, z=pos.z+dz}
				minetest.set_node(p, {name="air"})
			end
		end
	end
})
--GOOD LUCK LOL!
-- fireball (weapon)
mobs:register_arrow(":mobs_mc:fireball2", {
	visual = "sprite",
	visual_size = {x = 1.5, y = 1.5},
	textures = {"mobs_mc_dragon_fireball.png"},
	--textures = {"mobs_skeleton2_front.png^[makealpha:255,255,255 "},
	velocity = 6,

	-- direct hit, no fire... just plenty of pain
	hit_player = function(self, player)
		minetest.sound_play("tnt_explode", {pos = player:getpos(), gain = 1.5, max_hear_distance = 2*64})
		player:punch(self.object, 1.0, {
			full_punch_interval = 0.5,
			damage_groups = {fleshy = 6},
		}, nil)

	end,

	hit_mob = function(self, mob)
		minetest.sound_play("tnt_explode", {pos = mob:getpos(), gain = 1.5, max_hear_distance = 2*64})
		mob:punch(self.object, 1.0, {
			full_punch_interval = 0.5,
			damage_groups = {fleshy = 12},
		}, nil)
		
	end,

	-- node hit, bursts into flame
	hit_node = function(self, pos, node)
		mobs:explosion(pos, 3, 0, 1)
		--from tnt
		minetest.sound_play("tnt_explode", {pos = pos, gain = 1.5, max_hear_distance = 2*64})
		
	end
})

mobs:register_egg("mobs_mc:enderdragon", S("Ender Dragon"), "mobs_mc_spawn_icon_dragon.png", 0)
