--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

mobs:register_mob("mobs_mc:bat", {
	type = "animal",
	passive = true,
	hp_min = 6,
	hp_max = 6,
	collisionbox = {-0.25, -0.01, -0.25, 0.25, 0.89, 0.25},
	visual = "mesh",
	mesh = "mobs_mc_bat.b3d",
	textures = {
		{"mobs_mc_bat.png"},
	},
	visual_size = {x=1, y=1},
	sounds = {
		random = "mobs_rat", -- TODO: This sound is supposed to be very high-pitched and scary
		distance = 16,
	},
	walk_velocity = 4.5,
	run_velocity = 6.0,
	-- TODO: Hang upside down
	animation = {
		walk_speed = 80, stand_speed = 80, run_speed = 80,
		stand_start = 0,		stand_end = 40,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},

	water_damage = 1,
	lava_damage = 4,
	light_damage = 0,
	fall_damage = 0,
	view_range = 16,

	fly = true,
	fly_in = "air",
})


-- Spawning

--[[ If the game has been launched between the 20th of October and the 3rd of November system time,
-- the maximum spawn light level is increased. ]]
local date = os.date("*t")
local maxlight
if (date.month == 10 and date.day >= 20) or (date.month == 11 and date.day <= 3) then
	maxlight = 6
else
	maxlight = 3
end

-- Spawn on solid blocks at or below Sea level and the selected light level
mobs:spawn_specific("mobs_mc:bat", mobs_mc.spawn.solid, {"air"}, 0, maxlight, 20, 5000, 2, mobs_mc.spawn_height.overworld_min, mobs_mc.spawn_height.water-1)


-- spawn eggs
mobs:register_egg("mobs_mc:bat", S("Bat"), "mobs_mc_spawn_icon_bat.png", 0)


if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC Bat loaded")
end
