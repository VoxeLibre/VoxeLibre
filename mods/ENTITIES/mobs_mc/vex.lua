--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")


--dofile(minetest.get_modpath("mobs").."/api.lua")
--###################
--################### VEX
--###################



mobs:register_mob("mobs_mc:vex", {
	type = "monster",
	pathfinding = 1,
	passive = false,
	attack_type = "dogfight",
	physical = false,
	hp_min = 14,
	hp_max = 14,
	collisionbox = {-0.2, 0.2, -0.2, 0.2, 1.0, 0.2},  --bat
	visual = "mesh",
	mesh = "mobs_mc_vex.b3d",
	textures = {
		{"mobs_mc_vex.png^mobs_mc_vex_sword.png"},
	},
	visual_size = {x=1.25, y=1.25},
	damage = 9,
	reach = 2,
	view_range = 16,
	walk_velocity = 3.2,
	run_velocity = 5.9,
	attack_type = "dogfight",
	sounds = {
		random = "mobs_rat",
		death = "green_slime_death",
		distance = 16,
	},
	animation = {
		stand_speed = 25, walk_speed = 25, run_speed = 50,
		stand_start = 40,		stand_end = 80,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},
	do_custom = function(self, dtime)
		-- Glow red while attacking
		if self.state == "attack" then
			if self.base_texture[1] ~= "mobs_mc_vex_charging.png^mobs_mc_vex_sword.png" then
				self.base_texture = {"mobs_mc_vex_charging.png^mobs_mc_vex_sword.png"}
				self.object:set_properties({textures=self.base_texture})
			end
		else
			if self.base_texture[1] ~= "mobs_mc_vex.png^mobs_mc_vex_sword.png" then
				self.base_texture = {"mobs_mc_vex.png^mobs_mc_vex_sword.png"}
				self.object:set_properties({textures=self.base_texture})
			end
		end

		-- Take constant damage if the vex' life clock ran out
		-- (only for vexes summoned by evokers)
		if self._summoned then
			if not self._lifetimer then
				self._lifetimer = 33
			end
			self._lifetimer = self._lifetimer - dtime
			if self._lifetimer <= 0 then
				if self._damagetimer then
					self._damagetimer = self._damagetimer - 1
				end
				self.object:punch(self.object, 1.0, {
					full_punch_interval = 1.0,
					damage_groups = {fleshy = 2},
				}, nil)
				self._damagetimer = 1
			end
		end
	end,
	water_damage = 0,
	lava_damage = 4,
	light_damage = 0,
	fly = true,
	fly_in = {"air"},
})


-- spawn eggs
mobs:register_egg("mobs_mc:vex", S("Vex"), "mobs_mc_spawn_icon_vex.png", 0)


if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC Vex loaded")
end
