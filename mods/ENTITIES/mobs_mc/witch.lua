--MCmobs v0.2
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### WITCH
--###################




mcl_mobs.register_mob("mobs_mc:witch", {
	description = S("Witch"),
	type = "monster",
	spawn_class = "hostile",
	can_despawn = false,
	initial_properties = {
		hp_min = 26,
		hp_max = 26,
		collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	},
	xp_min = 5,
	xp_max = 5,
	head_eye_height = 1.5,
	visual = "mesh",
	mesh = "vl_witch.b3d",
	textures = {
		{"vl_witch.png"},
	},
	visual_size = {x=2.2, y=2.2},
	makes_footstep_sound = true,
	damage = 2,
	reach = 2,
	walk_velocity = 1.2,
	run_velocity = 2.4,
	pathfinding = 1,
	group_attack = true,
	attack_type = "dogshoot",
	arrow = "mobs_mc:potion_arrow",
	shoot_interval = 2.5,
	shoot_offset = 1,
	dogshoot_switch = 1,
	dogshoot_count_max =1.8,
	max_drops = 3,
	drops = {
		{name = "mcl_potions:glass_bottle", chance = 8, min = 0, max = 2, looting = "common",},
		{name = "mcl_nether:glowstone_dust", chance = 8, min = 0, max = 2, looting = "common",},
		{name = "mcl_mobitems:gunpowder", chance = 8, min = 0, max = 2, looting = "common",},
		{name = "mesecons:redstone", chance = 8, min = 0, max = 2, looting = "common",},
		{name = "mcl_mobitems:spider_eye", chance = 8, min = 0, max = 2, looting = "common",},
		{name = "mcl_core:sugar", chance = 8, min = 0, max = 2, looting = "common",},
		{name = "mcl_core:stick", chance = 4, min = 0, max = 2, looting = "common",},
	},
	-- TODO: sounds
	animation = {
		stand_start = 60,
		stand_end = 70,
		stand_speed = 5,
		walk_start = 10,
		walk_end = 50,
		walk_speed = 30,
		run_start = 10,
		run_end = 50,
		run_speed = 60,
		drink_start = 70,
		drink_end = 90,
		drink_speed = 30,
		throw_start = 90,
		throw_end = 100,
		throw_speed = 30,
		cast_start = 100,
		cast_end = 115,
		cast_speed = 30,
	},
	view_range = 16,
	fear_height = 4,
	deal_damage = function(self, damage, mcl_reason)
		local factor = 1
		if mcl_reason.type == "magic" then factor = 0.15 end
		self.health = self.health - factor*damage
	end,
})

mcl_mobs.register_arrow("mobs_mc:potion_arrow", {
	visual = "sprite",
	visual_size = {x = 0.5, y = 0.5},
	textures = {"mcl_potions_dragon_breath.png"},
	velocity = 9,

	hit_player = function(self, player)
		mcl_util.deal_damage(player, 2, {type = "magic"})
	end,

	hit_mob = function(self, mob)
		mcl_util.deal_damage(mob, 2, {type = "magic"})
	end,

	hit_node = function(self, pos, node)
		mcl_mobs.mob_class.boom(self, pos, 1, {griefing=false})
		mcl_mobs.effect(pos, 32, "mcl_particles_flame.png", 5, 10, 2, 1, 10)
	end
})

-- TODO: Spawn when witch works properly <- eventually -j4i
--mcl_mobs:spawn_specific("mobs_mc:witch", { "mcl_core:jungletree", "mcl_core:jungleleaves", "mcl_flowers:fern", "mcl_core:vine" }, {"air"}, 0, minetest.LIGHT_MAX-6, 12, 20000, 2, mobs_mc.water_level-6, mcl_vars.mg_overworld_max)

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:witch", S("Witch"), "#340000", "#51a03e", 0, true)
mcl_mobs:non_spawn_specific("mobs_mc:witch","overworld",0,7)
mcl_wip.register_wip_item("mobs_mc:witch")
