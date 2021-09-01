mcl_mobs = {
	registered_mobs = {},
	mob_defititions = {},
	mob = {},
	util = {},
	eastereggs = {
		rainbow = "kay27",
		upside_down = "Fleckenstein",
		spin = "Wuzzy",
	},
	const = {
		 -- print debug messages
		debug = minetest.settings:get_bool("mcl_mobs_debug"),

		-- misc
		breath_max = 6,					-- default maximum breath
		grow_up_boost = 0.1,			-- how much grow up boost a baby mob will recieve when feed

		-- limits
		max_entity_cramming = 24, 		-- max amount of crammed entities before they take damage
		despawn_radius = 64,			-- radius outside of which mobs may despawn

		-- timers
		life_timer = 30, 				-- how long it takes before the next despawn check is done
		calm_down_timer = 6, 			-- how long it takes for mobs to calm down again after being angered when they don't see the attack target anymore
		stun_timer = 0.4,				-- how long it a mob will be stunned after taking damage
		death_timer = 1.25,				-- duration of the death animation
		breed_giveup_timer = 15,		-- how long a mob will search for a mate before giving up
		run_timer = 5, 					-- how long a skittish mob runs after being damage: arbitrary 5 seconds

		-- movement
		gravity = 9.81, 				-- gravity: this is actually incorrect but MCL2 uses this value elsewhere too
		water_sink_speed = -0.5,		-- how fast mobs sink in water													ToDo: research
		water_slowdown_factor = 0.5,	-- how much horizontal movement is slown down in water							ToDo: research
		lava_sink_speed = -0.2,			-- how fast mobs sink in lava													ToDo: research
		lava_slowdown_factor = 0.2,		-- how much horizontal movement is slown down in lava							ToDo: research
		cobweb_sink_speed = -0.1,		-- how fast mobs sink in cobwebs												ToDo: research
		cobweb_slowdown_factor = 0.1,	-- how much horizontal movement is slown down in cobwebs						ToDo: research
		float_in_air = -0.5,			-- default float speed for mobs that float in air								ToDo: research
		float_in_water = 0.5,			-- default float speed for mobs that float in water								ToDo: research
		float_in_lava = 0.5,			-- default float speed for mobs that float in lava								ToDo: research
		knockback = 0.75,				-- base knockback multiplier
		knockback_up = 3,				-- base vertical knockback
		stepheight = 0.6,				-- default step height
	},
}

local path = minetest.get_modpath("mcl_mobs")
local api_files = io.open(path .. "/api_files.txt", "r") -- update with: $ find api -name "*.lua" > api_files.txt

for file in api_files:lines() do
	dofile(path .. "/" .. file)
end

api_files:close()
