--###################
--################### AGENT
--###################

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

mobs:register_mob("mobs_mc:agent", {
	type = "npc",
	passive = true,
	stepheight = 1.2,
	hp_min = 20,
	hp_max = 20,
	armor = 100,
	collisionbox = {-0.35, -0.01, -0.35, 0.35, 1, 0.35},
	visual = "mesh",
	mesh = "mobs_mc_agent.b3d",
	textures = {
		{"mobs_mc_agent.png"},
	},
	visual_size = {x=3, y=3},
	walk_velocity = 0.6,
	run_velocity = 2,
	jump = true,
	animation = {
		stand_speed = 25,
		walk_speed = 25,
		run_speed = 50,
		stand_start = 20,
		stand_end = 60,
		walk_start = 0,
		walk_end = 20,
		run_start = 0,
		run_end = 20,
	},
})

mobs:register_egg("mobs_mc:agent", S("Agent"), "mobs_mc_spawn_icon_agent.png", 0)

if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC Agent loaded")
end
