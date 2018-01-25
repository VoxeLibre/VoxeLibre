--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

--dofile(minetest.get_modpath("mobs").."/api.lua")


--###################
--################### PARROT
--###################



mobs:register_mob("mobs_mc:parrot", {
	type = "npc",
	pathfinding = 1,
	hp_min = 6,
	hp_max = 6,
	collisionbox = {-0.25, -0.01, -0.25, 0.25, 0.89, 0.25},
	visual = "mesh",
	mesh = "mobs_mc_parrot.b3d",
	textures = {{"mobs_mc_parrot_blue.png"},{"mobs_mc_parrot_green.png"},{"mobs_mc_parrot_grey.png"},{"mobs_mc_parrot_red_blue.png"},{"mobs_mc_parrot_yellow_blue.png"}},
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
	walk_velocity = 3,
	run_velocity = 5,
	drops = {
		{name = mobs_mc.items.feather,
		chance = 1,
		min = 1,
		max = 2,},
	},
    	animation = {
		stand_speed = 50,
		walk_speed = 50,
		stand_start = 0,
		stand_end = 0,
		walk_start = 0,
		walk_end = 130,
		--run_start = 0,
		--run_end = 20,
		--fly_start = 30,
		--fly_end = 45,
	},
	walk_chance = 100,
	water_damage = 0,
	lava_damage = 4,
	light_damage = 0,
	fall_damage = 0,
	fall_speed = -2.25,
	attack_type = "dogfight",
	jump = true,
	jump_height = 4,
	floats = 1,
	physical = true,
	fly = true,
	fly_in = {"air"},
	fear_height = 4,
	view_range = 16,
	follow = mobs_mc.follow.parrot,
	on_rightclick = function(self, clicker)
		if self._doomed then return end
		local item = clicker:get_wielded_item()
		-- Kill parrot if fed with cookie
		if item:get_name() == mobs_mc.items.cookie then
			self.health = 0
			-- Doomed to die
			self._doomed = true
			if not minetest.settings:get_bool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			return
		end

		-- Feed to tame, but not breed
		if mobs:feed_tame(self, clicker, 1, false, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 0, 50, 80, false, nil) then return end
	end,

})


-- Spawn disabled because parrots are not very smart.
-- TODO: Re-enable when parrots are finished
--mobs:spawn_specific("mobs_mc:parrot", mobs_mc.spawn.jungle, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 30000, 1, mobs_mc.spawn_height.water+1, mobs_mc.spawn_height.overworld_max)

-- spawn eggs
mobs:register_egg("mobs_mc:parrot", S("Parrot"), "mobs_mc_spawn_icon_parrot.png", 0)

if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC Parrot loaded")
end
