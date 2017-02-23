--MCmobs v0.2
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes


--dofile(minetest.get_modpath("mobs").."/api.lua")


mobs:register_mob("mobs_mc:chicken", {
	type = "animal",
	hp_min = 4,
	hp_max = 4,
	-- The x/z size is slightly bigger than in Minecraft (MC: 0.4×0.4; MCL2: 0.5×0.5)
	collisionbox = {-0.25, -0.01, -0.25, 0.25, 0.69, 0.25},
	
	visual = "mesh",
	visual_size = {x=0.7, y=0.7},
	mesh = "mobs_mc_chicken.x",
	textures = {
	{"mobs_mc_chicken.png"}
	},
	makes_footstep_sound = true,
	walk_velocity = 1,
	armor = 100,
	drops = {
		{name = "mcl_mobitems:chicken",
		chance = 1,
		min = 1,
		max = 1,},
		{name = "mcl_mobitems:feather",
		chance = 1,
		min = 0,
		max = 2,},
	},
	drawtype = "front",
	lava_damage = minetest.registered_nodes["mcl_core:lava_source"].damage_per_second,
	light_damage = 0,
	fall_damage = false,
	fear_height = 4,
	jump_height = 4.5,
	floats = true,
	sounds = {
		random = "mobs_chicken",
		death = "Chickenhurt1",
		hurt = "Chickenhurt1",
	},
	animation = {
		speed_normal = 24,
		stand_start = 0,
		stand_end = 23,
		walk_start = 24,
		walk_end = 49,
		hurt_start = 118,
		hurt_end = 154,
		death_start = 154,
		death_end = 179,
		eat_start = 49,
		eat_end = 78,
		look_start = 78,
		look_end = 108,
		fly_start = 181,
		fly_end = 187,
	},
	--from mobs_animals
	follow = {"mcl_farming:wheat_seeds", "mcl_farming:beetroot_seeds", "mcl_farming:pumpkin_seeds", "mcl_farming:melon_seeds"},
	view_range = 5,

	on_rightclick = function(self, clicker)

		if mobs:feed_tame(self, clicker, 1, true, true) then
			return
		end
	end,

	do_custom = function(self)

		if self.child
		or math.random(1, 5000) > 1 then
			return
		end

		local pos = self.object:getpos()

		minetest.add_item(pos, "mcl_throwing:egg")

		minetest.sound_play("mobs_mc_chicken_lay_egg", {
			pos = pos,
			gain = 1.0,
			max_hear_distance = 5,
		})
	end,	
	
})

mobs:register_spawn("mobs_mc:chicken", {"mcl_core:dirt_with_grass"}, 20, 9, 7000, 1, 31000)


-- compatibility
mobs:alias_mob("mobs:chicken", "mobs_mc:chicken")

-- spawn eggs
mobs:register_egg("mobs_mc:chicken", "Spawn Chicken", "spawn_egg_chicken.png")


if minetest.setting_get("log_mods") then
	minetest.log("action", "MC chicken loaded")
end
