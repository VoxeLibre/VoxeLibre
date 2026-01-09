--MCmobs v0.2
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### WITCH
--###################

local UP = vector.new(0, 1, 0)

local witch_potions = {
	"mcl_potions:slowness_splash",
	"mcl_potions:poison_splash",
	"mcl_potions:weakness_splash",
	"mcl_potions:harming_splash",
}

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
	arrow = "mcl_potions:harming_splash_flying",
	shoot_interval = 2.5,
	shoot_offset = 1,
	dogshoot_switch = 1,
	dogshoot_count_max = 1.8,
	shoot_arrow = function(self, pos, dir)
		local target_pos
		if self.attack and self.attack:get_pos() then
			target_pos = self.attack:get_pos()
			target_pos.y = target_pos.y + 1
		else
			-- Throw in the direction we're facing
			target_pos = vector.add(pos, vector.multiply(dir, 10))
		end

		local pos = self.object:get_pos()

		if not pos or not target_pos then return end

		local potion_item = witch_potions[math.random(#witch_potions)] -- TODO chances, levels, etc.

		-- Throw from witch's hand area
		local throw_pos = vector.offset(pos + 0.4*vector.normalize(vector.cross(vector.direction(pos, target_pos), UP)), 0, .2, 0)

		-- Calculate direction to target with arc compensation
		local dir = vector.direction(throw_pos, target_pos)
		local dist = vector.distance(throw_pos, target_pos)

		-- Add upward arc for the throw
		local arc_factor = math.min(dist / 20, 0.5)
		dir.y = dir.y + arc_factor
		dir = vector.normalize(dir)

		self:set_animation("throw")
		self.anim_locked = true
		core.after(0.2, function(pi, o, tp, d)
			mcl_potions.throw_splash(pi, o, tp, d, 10)
		end, potion_item, self.object, throw_pos, dir)
		core.after(0.4, function(self)
			self.anim_locked = false
		end, self)
	end,
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
		drink_loop = false,
		throw_start = 90,
		throw_end = 100,
		throw_speed = 20,
		throw_loop = false,
		cast_start = 100,
		cast_end = 115,
		cast_speed = 30,
		cast_loop = false,
	},
	view_range = 16,
	fear_height = 4,
	deal_damage = function(self, damage, mcl_reason)
		local factor = 1
		if mcl_reason.type == "magic" then factor = 0.15 end
		self.health = self.health - factor*damage
	end,
})

-- TODO: Spawn when witch works properly <- eventually -j4i
--mcl_mobs:spawn_specific("mobs_mc:witch", { "mcl_core:jungletree", "mcl_core:jungleleaves", "mcl_flowers:fern", "mcl_core:vine" }, {"air"}, 0, minetest.LIGHT_MAX-6, 12, 20000, 2, mobs_mc.water_level-6, mcl_vars.mg_overworld_max)

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:witch", S("Witch"), "#340000", "#51a03e", 0, true)
mcl_mobs:non_spawn_specific("mobs_mc:witch","overworld",0,7)
mcl_wip.register_wip_item("mobs_mc:witch")
