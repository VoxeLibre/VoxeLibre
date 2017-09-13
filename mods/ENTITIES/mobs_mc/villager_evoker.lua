--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

--dofile(minetest.get_modpath("mobs").."/api.lua")
--###################
--################### EVOKER
--###################

local pr = PseudoRandom(os.time()*666)

mobs:register_mob("mobs_mc:evoker", {
	type = "monster",
	physical = true,
	pathfinding = 1,
	hp_min = 24,
	hp_max = 24,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1.95, 0.4},
	visual = "mesh",
	mesh = "mobs_mc_villager.b3d",
	textures = { {
		"mobs_mc_evoker_base.png",
		"blank.png", --no hat
		-- TODO: Attack glow
	} },
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
	damage = 6,
	walk_velocity = 0.2,
	run_velocity = 1.4,
	group_attack = true,
	attack_type = "dogfight",
	-- Summon vexes
	custom_attack = function(self, to_attack)
		local r = pr:next(2,4)
		local basepos = self.object:getpos()
		basepos.y = basepos.y + 1
		for i=1, r do
			local spawnpos = vector.add(basepos, minetest.yaw_to_dir(pr:next(0,360)))
			local vex = minetest.add_entity(spawnpos, "mobs_mc:vex")
			local ent = vex:get_luaentity()
			-- Mark vexes as summoned and start their life clock (they take damage it reaches 0)
			ent._summoned = true
			ent._lifetimer = pr:next(33, 108)
		end
	end,
	shoot_interval = 15,
	passive = false,
	drops = {
		{name = mobs_mc.items.emerald,
		chance = 1,
		min = 0,
		max = 1,},
		{name = mobs_mc.items.totem,
		chance = 1,
		min = 1,
		max = 1,},
	},
	sounds = {
		random = "Villagerdead",
		death = "Villagerdead",
		damage = "mese_dragon",
		attack = "zombiedeath",
		distance = 16,
	},
	animation = {
		walk_speed = 25,
		run_speed = 25,
		stand_start = 40,
		stand_end = 59,
		stand_speed = 5,
		walk_start = 0,
		walk_end = 40,
		shoot_start = 120,
		shoot_end = 140,
		-- TODO: Implement and fix death animation
		--die_start = 190,
		--die_end = 200,
	        --die_speed = 15,
		--die_loop = false,
	},
	water_damage = 0,
	lava_damage = 4,
	light_damage = 0,
	view_range = 16,
	fear_height = 4,
})

-- spawn eggs
mobs:register_egg("mobs_mc:evoker", S("Evoker"), "mobs_mc_spawn_icon_evoker.png", 0)


if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC Evoker loaded")
end
