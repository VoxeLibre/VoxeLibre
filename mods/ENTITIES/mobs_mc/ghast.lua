--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### GHAST
--###################


mcl_mobs.register_mob("mobs_mc:ghast", {
	description = S("Ghast"),
	type = "monster",
	spawn_class = "hostile",
	pathfinding = 1,
	group_attack = true,
	initial_properties = {
		hp_min = 10,
		hp_max = 10,
		collisionbox = {-2, 0, -2, 2, 4, 2, rotate=true},
	},
	armor = { fleshy = 50, ghost = 100 },
	xp_min = 5,
	xp_max = 5,
	visual = "mesh",
	mesh = "mobs_mc_ghast.b3d",
	spawn_in_group = 1,
	textures = {
		{"mobs_mc_ghast.png"},
	},
	visual_size = {x=8, y=8},
	sounds = {
		shoot_attack = "mobs_fireball",
		death = "mobs_mc_zombie_death",
		attack = "mobs_fireball",
		random = "mobs_eerie",
		distance = 80,
		-- TODO: damage
		-- TODO: better death
	},
	walk_velocity = 1.6,
	run_velocity = 3.2,
	drops = {
		{name = "mcl_mobitems:gunpowder", chance = 1, min = 0, max = 2, looting = "common"},
		{name = "mcl_mobitems:ghast_tear", chance = 10/6, min = 0, max = 1, looting = "common", looting_ignore_chance = true},
	},
	animation = {
		stand_speed = 50,
		stand_start = 1,		stand_end = 40,
	},
	glow = 3,
	fall_damage = 0,
	view_range = 64,
	attack_type = "dogshoot",
	arrow = "mobs_mc:fireball",
	shoot_interval = 5,
	shoot_offset = 0.5,
	shoot_pos = {x = 2, y = -1},
	dogshoot_switch = 1,
	dogshoot_count_max = 1,
	shooter_avoid_enemy = true,
	avoid_distance = 24,
	passive = false,
	jump = true,
	jump_height = 4,
	floats=1,
	fly = true,
	makes_footstep_sound = false,
	instant_death = true,
	fire_resistant = true,
	can_spawn = function(pos)
		if not minetest.get_item_group(minetest.get_node(pos).name,"solid") then return false end
		local p1=vector.offset(pos,-2,1,-2)
		local p2=vector.offset(pos,2,5,2)
		local nn = minetest.find_nodes_in_area(p1,p2,{"air"})
		if #nn< 41 then return false end
		return true
	end,
	do_custom = function(self)
		if self.firing == true then
			self.base_texture = {"mobs_mc_ghast_firing.png"}
			self.object:set_properties({textures=self.base_texture})
		else
			self.base_texture = {"mobs_mc_ghast.png"}
			self.object:set_properties({textures=self.base_texture})
		end
	end,
	do_punch = function(self, hitter)
		local le = hitter:get_luaentity()
		self._last_hit = {
			fireball = le and le.name == "mobs_mc:fireball",
			owner = le and le._owner,
		}

		return true -- Force punch to continue with default behavior
	end,
	on_die = function(self)
		local last_hit = self._last_hit or {}
		if last_hit.fireball and last_hit.owner and core.get_player_by_name(last_hit.owner) then
			awards.unlock(last_hit.owner, "mcl:fireball_redir_serv")
		end
	end,
})


mcl_mobs:spawn_setup({
	name = "mobs_mc:ghast",
	dimension = "nether",
	type_of_spawning = "ground",
	biomes = {
		"Nether",
		"SoulsandValley",
		"BasaltDelta",
	},
	min_light = 0,
	max_light = 7,
	chance = 400,
	interval = 30,
	aoc = 2,
	min_height = mcl_vars.mg_nether_min,
	max_height = mcl_vars.mg_nether_max
})

-- fireball (projectile)
mcl_mobs.register_arrow("mobs_mc:fireball", {
	visual = "sprite",
	visual_size = {x = 2, y = 2},
	textures = {"vl_mobs_soulfire_charge.png"},
	velocity = 15,
	collisionbox = {-1, -1, -1, 1, 1, 1},
	glow = 10,
	_lifetime = 10,
	_is_fireball = true,
	_vl_projectile = {
		damage_groups = {fleshy = 6, ghost = 20}
	},

	hit_player = function(self, player)
		local p = self.object:get_pos()
		if p then
			mcl_mobs.mob_class.boom(self,p, 1, true)
		else
			mcl_mobs.mob_class.boom(self,player:get_pos(), 1, true)
		end
	end,

	hit_mob = function(self, mob)
		local name = mob:get_luaentity().name
		mcl_mobs.mob_class.boom(self,self.object:get_pos(), 1, true)
	end,

	hit_node = function(self, pos, node)
		mcl_mobs.mob_class.boom(self,pos, 1, true)
	end
})

mcl_mobs:non_spawn_specific("mobs_mc:ghast","overworld","0","7")
-- spawn eggs
mcl_mobs.register_egg("mobs_mc:ghast", S("Ghast"), "#f9f9f9", "#bcbcbc", 0)
