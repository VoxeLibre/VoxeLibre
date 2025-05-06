--###################
--################### ENDERDRAGON
--###################

local S = minetest.get_translator("mobs_mc")

local BEAM_CHECK_FREQUENCY = 1
local POS_CHECK_FREQUENCY = 15
local HEAL_INTERVAL = 1
local HEAL_AMOUNT = 2

local function check_beam(self)
	for _, obj in ipairs(minetest.get_objects_inside_radius(self.object:get_pos(), 80)) do
		local luaentity = obj:get_luaentity()
		if luaentity and luaentity.name == "mcl_end:crystal" then
			if luaentity.beam then
				if luaentity.beam == self.beam then
					break
				end
			else
				if self.beam then
					self.beam:remove()
				end
				minetest.add_entity(self.object:get_pos(), "mcl_end:crystal_beam"):get_luaentity():init(self.object, obj)
				break
			end
		end
	end
end

local function check_pos(self)
	if self._portal_pos then
		-- migrate old format
		if type(self._portal_pos) == "string" then
			self._portal_pos = minetest.string_to_pos(self._portal_pos)
		end
		local portal_center = vector.add(self._portal_pos, vector.new(0, 11, 0))
		local pos = self.object:get_pos()
		if vector.distance(pos, portal_center) > 50 then
			self.object:set_pos(self._last_good_pos or portal_center)
		else
			self._last_good_pos = pos
		end
	end
end

mcl_mobs.register_mob("mobs_mc:enderdragon", {
	description = S("Ender Dragon"),
	type = "monster",
	spawn_class = "hostile",
	pathfinding = 1,
	attacks_animals = true,
	walk_chance = 100,
	initial_properties = {
		hp_max = 200,
		hp_min = 200,
		collisionbox = {-2, 3, -2, 2, 5, 2},
	},
	xp_min = 500,
	xp_max = 500,
	physical = false,
	visual = "mesh",
	mesh = "mobs_mc_dragon.b3d",
	textures = {
		{"mobs_mc_dragon.png"},
	},
	visual_size = {x=3, y=3},
	view_range = 64,
	walk_velocity = 6,
	run_velocity = 6,
	can_despawn = false,
	sounds = {
		-- TODO: more sounds
		shoot_attack = "mobs_mc_ender_dragon_shoot",
		attack = "mobs_mc_ender_dragon_attack",
		distance = 60,
	},
	physical = true,
	damage = 10,
	knock_back = false,
	jump = true,
	jump_height = 14,
	fly = true,
	makes_footstep_sound = false,
	dogshoot_switch = 1,
	dogshoot_count_max =5,
	dogshoot_count2_max = 5,
	passive = false,
	attack_animals = true,
	lava_damage = 0,
	fire_damage = 0,
	on_rightclick = nil,
	attack_type = "dogshoot",
	arrow = "mobs_mc:dragon_fireball",
	shoot_interval = 0.5,
	shoot_offset = -1.0,
	xp_min = 500,
	xp_max = 500,
	animation = {
		fly_speed = 8, stand_speed = 8,
		stand_start = 0,		stand_end = 20,
		walk_start = 0,		walk_end = 20,
		run_start = 0,		run_end = 20,
	},
	ignores_nametag = true,
	do_custom = function(self,dtime)
		if self._pos_timer == nil or self._pos_timer > POS_CHECK_FREQUENCY then
			self._pos_timer = 0
			check_pos(self)
		end
		if self._beam_timer == nil or self._beam_timer > BEAM_CHECK_FREQUENCY then
			self._beam_timer = 0
			check_beam(self)
		end

		self._beam_timer = self._beam_timer + dtime
		self._pos_timer = self._pos_timer + dtime

		if self.beam ~= nil then
			-- heal
			self._heal_timer = (self._heal_timer or 0) + dtime
			if self._heal_timer > HEAL_INTERVAL then
				self.health = math.min(self.initial_properties.hp_max,self.health + HEAL_AMOUNT)
				self._heal_timer = self._heal_timer - HEAL_INTERVAL
			end
		end

		mcl_bossbars.update_boss(self.object, "Ender Dragon", "light_purple")
	end,
	on_die = function(self, pos, cmi_cause)
		if self._portal_pos then
			mcl_portals.spawn_gateway_portal()
			mcl_structures.spawn_end_exit_portal(self._portal_pos)
			if self._initial then
				mcl_experience.throw_xp(pos, 11500) -- 500 + 11500 = 12000
				minetest.set_node(vector.add(self._portal_pos, vector.new(0, 5, 0)), {name = "mcl_end:dragon_egg"})
			end
		end

		-- Free The End Advancement
		for _,players in pairs(minetest.get_objects_inside_radius(pos,64)) do
			if players:is_player() then
				awards.unlock(players:get_player_name(), "mcl:freeTheEnd")
			end
		end
	end,
	fire_resistant = true,
	is_boss = true,
})


local mobs_griefing = minetest.settings:get_bool("mobs_griefing") ~= false

-- dragon fireball (projectile)
mcl_mobs.register_arrow("mobs_mc:dragon_fireball", {
	visual = "sprite",
	visual_size = {x = 1.25, y = 1.25},
	textures = {"mobs_mc_dragon_fireball.png"},
	velocity = 6,
	_vl_projectile = {
		damage_groups = {fleshy = 12}
	},

	hit_player = function(self, player)
	end,

	hit_mob = function(self, mob)
		core.sound_play("tnt_explode", {pos = mob:get_pos(), gain = 1.5, max_hear_distance = 2*64}, true)
	end,

	-- node hit, explode
	hit_node = function(self, pos, node)
		mcl_mobs.mob_class.boom(self,pos, 2)
	end
})

mcl_mobs.register_egg("mobs_mc:enderdragon", S("Ender Dragon"), "#252525", "#b313c9", 0, true)


mcl_wip.register_wip_item("mobs_mc:enderdragon")
mcl_mobs:non_spawn_specific("mobs_mc:enderdragon","overworld",0,minetest.LIGHT_MAX+1)
