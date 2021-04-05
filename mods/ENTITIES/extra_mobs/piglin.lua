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
}

local S = minetest.get_translator("extra_mobs")
local mod_bows = minetest.get_modpath("mcl_bows") ~= nil

--###################
--################### piglin
--###################
local piglin = {
	type = "monster",
	passive = false,
	spawn_class = "hostile",
	hp_min = 16,
	hp_max = 16,
	xp_min = 9,
	xp_max = 9,
	armor = {fleshy = 90},
	damage = 4,
	reach = 3,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	visual = "mesh",
	mesh = "extra_mobs_piglin.b3d",
	textures = { {
		"extra_mobs_piglin.png",
		"mcl_bows_bow_2.png",
	} },
	visual_size = {x=1, y=1},
	sounds = {
		random = "extra_mobs_piglin",
		damage = "extra_mobs_piglin_hurt",
		distance = 16,
	},
	jump = true,
	makes_footstep_sound = true,
	walk_velocity = 4.317,
	run_velocity = 5.6121,
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
	on_spawn = function(self)
		self.weapon = self.base_texture[2]
		self.gold_items = 0
	end,
  do_custom = function(self)
		if self.object:get_pos().y > -100 then
			--local zog = minetest.add_entity(self.object:get_pos(), "extra_mobs:zombified_piglin")
			--zog:set_rotation(self.object:get_rotation())
			--self.object:remove()
		end
		if self.trading == true then
			self.state = "trading"
			self.object:set_bone_position("Arm_Right_Pitch_Control", vector.new(-3,5.785,0), vector.new(20,-20,18))
			self.object:set_bone_position("Head", vector.new(0,6.3,0), vector.new(-40,0,0))
			self.base_texture[2] = "default_gold_ingot.png"
			self.object:set_properties({textures = self.base_texture})
		else
			self.object:set_bone_position("Wield_Item", vector.new(.5,4.5,-1.6), vector.new(90,0,20))
			self.base_texture[2] = self.weapon
			self.object:set_properties({textures = self.base_texture})
			self.object:set_bone_position("Head", vector.new(0,6.3,0), vector.new(0,0,0))
			self.object:set_bone_position("Arm_Right_Pitch_Control", vector.new(-3,5.785,0), vector.new(0,0,0))
		end

		if self.state ~= "attack" then
			self._attacked_by_player = false
		end
    if self.state == "attack" and self.attack:is_player() then
			for i=1, 6 do
				local stack = self.attack:get_inventory():get_stack("armor", i)
				local item = stack:get_name()
				if item == "mcl_armor:chestplate_gold" or item == "mcl_armor:leggings_gold" or item == "mcl_armor:helmet_gold" or item == "mcl_armor:boots_gold" then
					if self._attacked_by_player == false then
						self.state = "stand"
					end
				end
    	end
    end
  end,
	on_rightclick = function(self, clicker)
		if clicker:is_player() and clicker:get_wielded_item():get_name() == "mcl_core:gold_ingot" and self.state ~= "attack" and self.gold_items < 3 then
			local item_gold = clicker:get_wielded_item()
			item_gold:take_item(1)
			clicker:set_wielded_item(item_gold)
			self.state = "stand"
			self.object:set_animation({x=0,y=79})
			self.trading = true
			self.gold_items = self.gold_items + 1
			self.object:set_bone_position("Wield_Item", vector.new(-1.5,4.9,1.8), vector.new(135,0,90))
			minetest.after(5, function()
				self.gold_items = self.gold_items - 1
				if self.gold_items == 0 then
					self.trading = false
					self.state = "stand"
				end
				local c_pos = self.object:get_pos()
				self.what_traded = trading_items[math.random(#trading_items)]
				for x = 1, math.random(self.what_traded.amount_min, self.what_traded.amount_max) do
					minetest.add_item({x=math.random(c_pos.x - 1, c_pos.x + 1), y=math.random(c_pos.y - 1, c_pos.y + 1), z= math.random(c_pos.z - 1, c_pos.z + 1)}, self.what_traded.itemstring)
				end
			end)
		end
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
			-- 2-4 damage per arrow
			local dmg = math.max(4, math.random(2, 8))
			mcl_bows.shoot_arrow("mcl_bows:arrow", pos, dir, self.object:get_yaw(), self.object, nil, dmg)
		end
	end,
	shoot_interval = 1.2,
	shoot_offset = 1.5,
	dogshoot_switch = 1,
	dogshoot_count_max =1.8,
}

mobs:register_mob("extra_mobs:piglin", piglin)


local sword_piglin = table.copy(piglin)
sword_piglin.mesh = "extra_mobs_sword_piglin.b3d"
sword_piglin.textures = {"extra_mobs_piglin.png", "default_tool_goldsword.png"}
sword_piglin.on_spawn = function(self)
	self.gold_items = 0
	self.weapon = self.base_texture[2]
	self.object:set_bone_position("Wield_Item", vector.new(0,3.9,1.3), vector.new(90,0,0))
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
mobs:register_mob("extra_mobs:sword_piglin", sword_piglin)

local zombified_piglin = table.copy(piglin)
zombified_piglin.fire_resistant = 1
zombified_piglin.do_custom = function()
	return
end
zombified_piglin.on_spawn = function()
	return
end
zombified_piglin.on_rightclick = function()
	return
end
zombified_piglin.lava_damage = 0
zombified_piglin.fire_damage = 0
zombified_piglin.attack_animals = true
zombified_piglin.mesh = "extra_mobs_sword_piglin.b3d"
zombified_piglin.textures = {"extra_mobs_zombified_piglin.png", "default_tool_goldsword.png", "extra_mobs_trans.png"}
zombified_piglin.attack_type = "dogfight"
zombified_piglin.animation = {
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
mobs:register_mob("extra_mobs:zombified_piglin", zombified_piglin)


local piglin_brute = table.copy(piglin)
piglin_brute.xp_min = 20
piglin_brute.xp_max = 20
piglin_brute.hp_min = 50
piglin_brute.hp_max = 50
piglin_brute.fire_resistant = 1
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
piglin_brute.lava_damage = 0
piglin_brute.fire_damage = 0
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
piglin_brute.group_attack = { "extra_mobs:piglin", "extra_mobs:piglin_brute" }
mobs:register_mob("extra_mobs:piglin_brute", piglin_brute)


-- Regular spawning in the Nether
mobs:spawn_specific("extra_mobs:piglin", {"mcl_nether:netherrack"}, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 6000, 3, mcl_vars.mg_nether_min, mcl_vars.mg_nether_max)
mobs:spawn_specific("extra_mobs:sword_piglin", {"mcl_nether:netherrack"}, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 6000, 3, mcl_vars.mg_nether_min, mcl_vars.mg_nether_max)
-- spawn eggs
mobs:register_egg("extra_mobs:piglin", S("piglin"), "extra_mobs_spawn_icon_piglin.png", 0)
mobs:register_egg("extra_mobs:piglin_brute", S("piglin Brute"), "extra_mobs_spawn_icon_piglin.png", 0)
