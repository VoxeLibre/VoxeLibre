--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("extra_mobs")

--###################
--################### hoglin
--###################

local hoglin = {
	type = "monster",
	passive = false,
	spawn_class = "hostile",
	hp_min = 40,
	hp_max = 40,
	xp_min = 9,
	xp_max = 9,
	armor = {fleshy = 90},
	attack_type = "dogfight",
	damage = 4,
	reach = 3,
	collisionbox = {-.6, -0.01, -.6, .6, 1.4, .6},
	visual = "mesh",
	mesh = "extra_mobs_hoglin.b3d",
	textures = { {
		"extra_mobs_hoglin.png",
	} },
	visual_size = {x=3, y=3},
	sounds = {
		random = "extra_mobs_hoglin",
		damage = "extra_mobs_hoglin_hurt",
		distance = 16,
	},
	jump = true,
	makes_footstep_sound = true,
	walk_velocity = 1,
	run_velocity = 4,
	drops = {
		{name = "mcl_mobsitems:leather",
		chance = 1,
		min = 0,
		max = 1,},
	},
	drops = {
		{name = "mcl_mobitems:porkchop",
		chance = 1,
		min = 2,
		max = 4,},
	},
	animation = {
		stand_speed = 7,
		walk_speed = 7,
		run_speed = 15,
		stand_start = 24,
		stand_end = 24,
		walk_start = 11,
		walk_end = 21,
		run_start = 1,
		run_end = 10,
		punch_start = 22,
		punch_end = 32,
	},
	fear_height = 4,
	view_range = 32,
	floats = 0,
	custom_attack = function(self)
		if self.state == "attack" and self.reach > vector.distance(self.object:get_pos(), self.attack:get_pos()) then
			self.attack:add_velocity({x=0,y=13,z=0})
			self.attack:punch(self.object, 1.0, {
				full_punch_interval = 1.0,
				damage_groups = {fleshy = self.damage}
			}, nil)
		end
	end,
	do_custom = function(self)
		if self.object:get_pos().y > -100 then
			local zog = minetest.add_entity(self.object:get_pos(), "extra_mobs:zoglin")
			zog:set_rotation(self.object:get_rotation())
			self.object:remove()
		end
	end,
	attack_animals = true,
}

mobs:register_mob("extra_mobs:hoglin", hoglin)

local zoglin = table.copy(hoglin)
zoglin.fire_resistant = 1
zoglin.textures = {"extra_mobs_zoglin.png"}
zoglin.do_custom = function()
	return
end
zoglin.attacks_monsters = true
zoglin.lava_damage = 0
zoglin.fire_damage = 0
mobs:register_mob("extra_mobs:zoglin", zoglin)

-- Baby hoglin.
--[[
local baby_hoglin = table.copy(hoglin)
baby_hoglin.collisionbox = {-.3, -0.01, -.3, .3, 0.94, .3}
baby_hoglin.xp_min = 20
baby_hoglin.xp_max = 20
baby_hoglin.visual_size = {x=hoglin.visual_size.x/2, y=hoglin.visual_size.y/2}
textures = { {
	"extra_mobs_hoglin.png",
	"extra_mobs_trans.png",
} }
baby_hoglin.walk_velocity = 1.2
baby_hoglin.run_velocity = 2.4
baby_hoglin.child = 1

mobs:register_mob("extra_mobs:baby_hoglin", baby_hoglin)]]

-- Regular spawning in the Nether
mobs:spawn_specific("extra_mobs:hoglin", "nether", "ground", 0, minetest.LIGHT_MAX+1, 30, 6000, 3, mcl_vars.mg_nether_min, mcl_vars.mg_nether_max)

-- spawn eggs
mobs:register_egg("extra_mobs:hoglin", S("Hoglin"), "extra_mobs_spawn_icon_hoglin.png", 0)
