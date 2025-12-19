--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local trading_items = {
	{ itemstring = "mcl_core:obsidian", amount_min = 1, amount_max = 1 },
	{ itemstring = "mcl_core:gravel", amount_min = 8, amount_max = 16 },
	{ itemstring = "mcl_mobitems:leather", amount_min = 4, amount_max = 10 },
	{ itemstring = "mcl_nether:soul_sand", amount_min = 4, amount_max = 16 },
	{ itemstring = "mcl_nether:nether_brick", amount_min = 4, amount_max = 16 },
	{ itemstring = "mcl_mobitems:string", amount_min = 3, amount_max = 9 },
	{ itemstring = "mcl_nether:quartz", amount_min = 4, amount_max = 10 },
	{ itemstring = "mcl_potions:water", amount_min = 1, amount_max = 1 },
	{ itemstring = "mcl_core:iron_nugget", amount_min = 10, amount_max = 36 },
	{ itemstring = "mcl_throwing:ender_pearl", amount_min = 2, amount_max = 6 },
	{ itemstring = "mcl_potions:fire_resistance", amount_min = 1, amount_max = 1 },
	{ itemstring = "mcl_potions:fire_resistance_splash", amount_min = 1, amount_max = 1 },
	{ itemstring = "mcl_enchanting:book_enchanted", amount_min = 1, amount_max = 1 },
	{ itemstring = "mcl_armor:boots_iron_enchanted", amount_min = 1, amount_max = 1 },
	{ itemstring = "mcl_blackstone:blackstone", amount_min = 8, amount_max = 16 },
	{ itemstring = "mcl_bows:arrow", amount_min = 6, amount_max = 12 },
	{ itemstring = "mcl_core:crying_obsidian", amount_min = 1, amount_max = 1 },
	{ itemstring = "mcl_fire:fire_charge", amount_min = 1, amount_max = 1 },
	--{ itemstring = "FIXME:spectral_arrow", amount_min = 6, amount_max = 12 },
}

local S = minetest.get_translator("mobs_mc")
local mod_bows = minetest.get_modpath("mcl_bows") ~= nil

function mobs_mc.player_wears_gold(player)
	for i=1, 6 do
		local stack = player:get_inventory():get_stack("armor", i)
		local item = stack:get_name()
		if string.find(item, "mcl_armor:chestplate_gold")
				or string.find(item, "mcl_armor:leggings_gold")
				or string.find(item, "mcl_armor:helmet_gold")
				or string.find(item, "mcl_armor:boots_gold") then
			return true
		end
	end
end

--###################
--################### piglin
--###################
local piglin = {
	description = S("Piglin"),
	type = "monster",
	passive = false,
	spawn_class = "hostile",
	group_attack = {"mobs_mc:piglin", "mobs_mc:sword_piglin", "mobs_mc:piglin_brute"},
	initial_properties = {
		hp_min = 16,
		hp_max = 16,
		collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	},
	xp_min = 9,
	xp_max = 9,
	head_eye_height = 1.55,
	armor = {fleshy = 90},
	damage = 4,
	reach = 3,
	visual = "mesh",
	mesh = "extra_mobs_piglin.b3d",
	spawn_in_group = 4,
	spawn_in_group_min = 2,
	textures = { {
		"extra_mobs_piglin.png",
		"mcl_bows_bow_2.png",
	} },
	visual_size = {x=1, y=1},
	sounds = {
		random = "mobs_mc_zombiepig_random",
		war_cry = "mobs_mc_zombiepig_war_cry",                  death = "mobs_mc_zombiepig_death",
		damage = "mobs_mc_zombiepig_hurt.2",
		death = "mobs_mc_zombiepig_death.2",
		distance = 16,
	},
	jump = true,
	makes_footstep_sound = true,
	walk_velocity = 1.4,
	run_velocity = 2.8,
	drops = {
		{name = "mcl_bows:crossbow",
		chance = 10,
		min = 1,
		max = 1,},
	},
	animation = {
		stand_speed = 30,
		walk_speed = 30,
		run_speed = 30,
		stand_start = 0,
		stand_end = 79,
		walk_start = 168,
		walk_end = 187,
		run_start = 440,
		run_end = 459,
	},
	fear_height = 4,
	view_range = 16,
	pick_up = {"mcl_core:gold_ingot"},
	on_spawn = function(self)
		self.weapon = self.base_texture[2]
		self.gold_items = 0
	end,
	do_custom = function(self)
		if self.object:get_pos().y > mcl_vars.mg_overworld_min then
			local zog = minetest.add_entity(self.object:get_pos(), "mobs_mc:zombified_piglin")
			zog:set_rotation(self.object:get_rotation())
			self.object:remove()
			return
		elseif self.trading == true then
			self.state = "trading"
			mcl_util.set_bone_position(self.object, "Arm_Right_Pitch_Control", vector.new(-3,5.785,0), vector.new(0.35,-0.35,0.315))
			mcl_util.set_bone_position(self.object, "Head", vector.new(0,6.3,0), vector.new(-0.7,0,0))
			self.base_texture[2] = "default_gold_ingot.png"
			self.object:set_properties({textures = self.base_texture})
		else
			mcl_util.set_bone_position(self.object, "Wield_Item", vector.new(.5,4.5,-1.6), vector.new(1.57,0,0.35))
			self.base_texture[2] = self.weapon
			self.object:set_properties({textures = self.base_texture})
			mcl_util.set_bone_position(self.object, "Head", vector.new(0,6.3,0), vector.new(0,0,0))
			mcl_util.set_bone_position(self.object, "Arm_Right_Pitch_Control", vector.new(-3,5.785,0), vector.new(0,0,0))
		end

		if self.state ~= "attack" then
			self._attacked_by_player = false
		elseif self.attack:is_player() and mobs_mc.player_wears_gold(self.attack) then
			if self._attacked_by_player == false then
				self.state = "stand"
			end
		end
	end,
	on_pick_up  = function(self, itementity)
		local item = itementity.itemstring:split(" ")[1]
		local it = ItemStack(itementity.itemstring)
		if item == "mcl_core:gold_ingot" and self.state ~= "attack" and self.gold_items and self.gold_items < 3 then
			it:take_item(1)
			self.state = "stand"
			self.object:set_animation({x=0,y=79})
			self.trading = true
			self.gold_items = self.gold_items + 1
			mcl_util.set_bone_position(self.object, "Wield_Item", vector.new(-1.5,4.9,1.8), vector.new(2.36,0,1.57))
			minetest.after(5, function()
				self.gold_items = self.gold_items - 1
				if self.gold_items == 0 then
					self.trading = false
					self.state = "stand"
				end
				local c_pos = self.object:get_pos()
				if c_pos then
					self.what_traded = trading_items[math.random(#trading_items)]
					local stack = ItemStack(self.what_traded.itemstring)
					stack:set_count(math.random(self.what_traded.amount_min, self.what_traded.amount_max))
					if mcl_enchanting.is_enchanted(self.what_traded.itemstring) then
						local enchantment = "soul_speed"
						mcl_enchanting.enchant(stack, enchantment, mcl_enchanting.random(nil, 1, mcl_enchanting.enchantments[enchantment].max_level))
					end
					local p = c_pos
					local nn=minetest.find_nodes_in_area_under_air(vector.offset(c_pos,-1,-1,-1),vector.offset(c_pos,1,1,1),{"group:solid"})
					if nn and #nn > 0 then
						p = vector.offset(nn[math.random(#nn)],0,1,0)
					end
					minetest.add_item(p, stack)
				end
			end)
		end
		return it
	end,
	do_punch = function(self, hitter)
		if hitter:is_player() then
			self._attacked_by_player = true
		end
	end,
	attack_type = "dogshoot",
	arrow = "mcl_bows:arrow_entity",
	shoot_arrow = function(self, pos, dir)
		if mod_bows then
			if self.attack then
				self.object:set_yaw(minetest.dir_to_yaw(vector.direction(self.object:get_pos(), self.attack:get_pos())))
			end
			-- 2-4 damage per arrow
			local dmg = math.max(4, math.random(2, 8))
			mcl_bows.shoot_arrow("mcl_bows:arrow", pos, dir, self.object:get_yaw(), self.object, nil, dmg)
		end
	end,
	shoot_interval = 2,
	shoot_offset = 1.5,
	dogshoot_switch = 1,
	dogshoot_count_max =1.8,
	attacks_monsters = true,
	attack_animals = true,
	specific_attack = { "player", "mobs_mc:hoglin" },
}

mcl_mobs.register_mob("mobs_mc:piglin", piglin)


local sword_piglin = table.copy(piglin)
sword_piglin.description = S("Sword Piglin")
sword_piglin.mesh = "extra_mobs_sword_piglin.b3d"
sword_piglin.textures = {"extra_mobs_piglin.png", "default_tool_goldsword.png"}
sword_piglin.on_spawn = function(self)
	self.gold_items = 0
	self.weapon = self.base_texture[2]
	mcl_util.set_bone_position(self.object, "Wield_Item", vector.new(0,3.9,1.3), vector.new(1.57,0,0))
end
sword_piglin.drops = {
	{name = "mcl_tools:sword_gold",
	chance = 10,
	min = 1,
	max = 1,},
}
sword_piglin.attack_type = "dogfight"
sword_piglin.animation = {
	stand_speed = 30,
	walk_speed = 30,
	punch_speed = 45,
	run_speed = 30,
	stand_start = 0,
	stand_end = 79,
	walk_start = 168,
	walk_end = 187,
	run_start = 440,
	run_end = 459,
	punch_start = 189,
	punch_end = 198,
}

mcl_mobs.register_mob("mobs_mc:sword_piglin", sword_piglin)


-- Zombified Piglin --


local function spawn_check(pos, environmental_light, artificial_light, sky_light)
	return artificial_light <= 11
end

local zombified_piglin = {
	description = S("Zombie Piglin"),
	-- type="animal", passive=false: This combination is needed for a neutral mob which becomes hostile, if attacked
	type = "animal",
	passive = false,
	spawn_class = "passive",
	initial_properties = {
		hp_min = 20,
		hp_max = 20,
		collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3}, -- same
	},
	xp_min = 6,
	xp_max = 6,
	armor = {undead = 90, fleshy = 90},
	attack_type = "dogfight",
	group_attack = {"mobs_mc:zombified_piglin", "mobs_mc:baby_zombified_piglin"},
	damage = 9,
	reach = 2,
	head_swivel = "head.control",
	head_bone_position = vector.new( 0, 2.417, 0 ), -- for minetest <= 5.8
	head_eye_height = 1.55,
	curiosity = 15,
	visual = "mesh",
	mesh = "mobs_mc_zombie_pigman.b3d",
	textures = { {
					 "blank.png", --baby
					 "default_tool_goldsword.png", --sword
					 "mobs_mc_zombie_pigman.png", --pigman
				 } },
	visual_size = {x=3, y=3},
	sounds = {
		random = "mobs_mc_zombiepig_random",
		war_cry = "mobs_mc_zombiepig_war_cry",
		death = "mobs_mc_zombiepig_death",
		damage = "mobs_mc_zombiepig_hurt",
		distance = 16,
	},
	jump = true,
	makes_footstep_sound = true,
	spawn_check = spawn_check,
	walk_velocity = .8,
	run_velocity = 2.6,
	pathfinding = 1,
	drops = {
		{name = "mcl_mobitems:rotten_flesh",
		 chance = 1,
		 min = 1,
		 max = 1,
		 looting = "common"},
		{name = "mcl_core:gold_nugget",
		 chance = 1,
		 min = 0,
		 max = 1,
		 looting = "common"},
		{name = "mcl_core:gold_ingot",
		 chance = 40, -- 2.5%
		 min = 1,
		 max = 1,
		 looting = "rare"},
		{name = "mcl_tools:sword_gold",
		 chance = 100 / 8.5,
		 min = 1,
		 max = 1,
		 looting = "rare"},
	},
	animation = {
		stand_speed = 25,
		walk_speed = 25,
		run_speed = 50,
		stand_start = 40,
		stand_end = 80,
		walk_start = 0,
		walk_end = 40,
		run_start = 0,
		run_end = 40,
		punch_start = 90,
		punch_end = 130,
	},
	lava_damage = 0,
	fire_damage = 0,
	fear_height = 4,
	view_range = 16,
	harmed_by_heal = true,
	fire_damage_resistant = true,
}

mcl_mobs.register_mob("mobs_mc:zombified_piglin", zombified_piglin)

local baby_zombified_piglin = table.copy(zombified_piglin)
baby_zombified_piglin.description = S("Baby Zombie Piglin")
baby_zombified_piglin.initial_properties.collisionbox = {-0.25, -0.01, -0.25, 0.25, 0.94, 0.25}
baby_zombified_piglin.head_eye_height = 0.8
baby_zombified_piglin.xp_min = 13
baby_zombified_piglin.xp_max = 13
baby_zombified_piglin.textures = {
	{
	 "mobs_mc_zombie_pigman.png", --baby
	 "default_tool_goldsword.png", --sword
	 "mobs_mc_zombie_pigman.png", --pigman
	}
}
baby_zombified_piglin.walk_velocity = 1.2
baby_zombified_piglin.run_velocity = 2.4
baby_zombified_piglin.light_damage = 0
baby_zombified_piglin.child = 1

mcl_mobs.register_mob("mobs_mc:baby_zombified_piglin", baby_zombified_piglin)

-- Compatibility code. These were removed, and now are called zombie piglins. They don't spawn.
-- This is only to catch old cases. Maybe could be an alias?
local pigman_unused = table.copy(zombified_piglin)
pigman_unused.unused = true
local baby_pigman_unused = table.copy(baby_zombified_piglin)
baby_pigman_unused.unused = true

mcl_mobs.register_mob("mobs_mc:pigman", pigman_unused)
mcl_mobs.register_mob("mobs_mc:baby_pigman", baby_pigman_unused)


-- Piglin Brute --

local piglin_brute = table.copy(piglin)
piglin_brute.description = S("Piglin Brute")
piglin_brute.initial_properties = table.copy(piglin.initial_properties)
piglin_brute.initial_properties.hp_min = 50
piglin_brute.initial_properties.hp_max = 50
piglin_brute.xp_min = 20
piglin_brute.xp_max = 20
piglin_brute.fire_resistant = false
piglin_brute.do_custom = function()
	return
end
piglin_brute.on_spawn = function()
	return
end
piglin_brute.on_rightclick = function()
	return
end
piglin_brute.attacks_monsters = true
piglin_brute.lava_damage = 4
piglin_brute.fire_damage = 2
piglin_brute.attack_animals = true
piglin_brute.mesh = "extra_mobs_sword_piglin.b3d"
piglin_brute.textures = {"extra_mobs_piglin_brute.png", "default_tool_goldaxe.png", "extra_mobs_trans.png"}
piglin_brute.attack_type = "dogfight"
piglin_brute.animation = {
	stand_speed = 30,
	walk_speed = 30,
	punch_speed = 45,
	run_speed = 30,
	stand_start = 0,
	stand_end = 79,
	walk_start = 168,
	walk_end = 187,
	run_start = 440,
	run_end = 459,
	punch_start = 189,
	punch_end = 198,
}
piglin_brute.can_despawn = false

piglin_brute.drops = {
	{name = "mcl_tools:axe_gold",
	chance = 8.5,
	min = 1,
	max = 1,},
}
mcl_mobs.register_mob("mobs_mc:piglin_brute", piglin_brute)

-- Regular spawning in the Nether
mcl_mobs:spawn_setup({
	name = "mobs_mc:piglin",
	dimension = "nether",
	type_of_spawning = "ground",
	biomes = {
		"Nether",
		"CrimsonForest"
	},
	min_light = 0,
	max_light = minetest.LIGHT_MAX+1,
	chance = 150,
	interval = 30,
	aoc = 3,
	min_height = mcl_vars.mg_lava_nether_max,
	max_height = mcl_vars.mg_nether_max
})

mcl_mobs:spawn_setup({
	name = "mobs_mc:sword_piglin",
	dimension = "nether",
	type_of_spawning = "ground",
	biomes = {
		"Nether",
		"CrimsonForest"
	},
	min_light = 0,
	max_light = minetest.LIGHT_MAX+1,
	chance = 150,
	interval = 30,
	aoc = 3,
	min_height = mcl_vars.mg_lava_nether_max,
	max_height = mcl_vars.mg_nether_max
})

mcl_mobs:spawn_setup({
	name = "mobs_mc:zombified_piglin",
	dimension = "nether",
	type_of_spawning = "ground",
	biomes = {
		"Nether",
		"CrimsonForest",
	},
	min_light = 0,
	max_light = minetest.LIGHT_MAX+1,
	chance = 1000,
	interval = 30,
	aoc = 3,
	min_height = mcl_vars.mg_nether_min,
	max_height = mcl_vars.mg_nether_max
})

-- Baby zombie is 20 times less likely than regular zombies
mcl_mobs:spawn_setup({
	name = "mobs_mc:baby_zombified_piglin",
	dimension = "nether",
	type_of_spawning = "ground",
	biomes = {
		"Nether",
		"CrimsonForest",
	},
	min_light = 0,
	max_light = minetest.LIGHT_MAX+1,
	chance = 50,
	interval = 30,
	aoc = 4,
	min_height = mcl_vars.mg_nether_min,
	max_height = mcl_vars.mg_nether_max
})

mcl_mobs:non_spawn_specific("mobs_mc:piglin","overworld",0,7)
mcl_mobs:non_spawn_specific("mobs_mc:sword_piglin","overworld",0,7)
mcl_mobs:non_spawn_specific("mobs_mc:piglin_brute","overworld",0,7)
mcl_mobs:non_spawn_specific("mobs_mc:zombified_piglin","overworld",0,minetest.LIGHT_MAX+1)

mcl_mobs.register_egg("mobs_mc:piglin", S("Piglin"), "#7b4a17","#d5c381", 0)
mcl_mobs.register_egg("mobs_mc:piglin_brute", S("Piglin Brute"), "#562b0c","#ddc89d", 0)
mcl_mobs.register_egg("mobs_mc:zombified_piglin", S("Zombie Piglin"), "#ea9393", "#4c7129", 0)
