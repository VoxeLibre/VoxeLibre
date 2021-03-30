--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes
local pi = math.pi
local atann = math.atan
local atan = function(x)
	if not x or x ~= x then
		return 0
	else
		return atann(x)
	end
end

local S = minetest.get_translator("extra_mobs")

--###################
--################### fox
--###################

local fox = {
	type = "monster",
	passive = false,
	spawn_class = "hostile",
	hp_min = 10,
	hp_max = 10,
	xp_min = 1,
	xp_max = 2,
	armor = {fleshy = 90},
	attack_type = "dogfight",
	damage = 2,
	reach = 1.5,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 0.84, 0.3},
	visual = "mesh",
	mesh = "extra_mobs_fox.b3d",
	textures = { {
		"extra_mobs_fox.png",
		"extra_mobs_trans.png",
	} },
	visual_size = {x=3, y=3},
	sounds = {
	},
	jump = true,
	makes_footstep_sound = true,
	walk_velocity = 3,
	run_velocity = 6,
	drops = {
	},
	animation = {
		stand_speed = 7,
		walk_speed = 7,
		run_speed = 15,
		stand_start = 11,
		stand_end = 11,
		walk_start = 0,
		walk_end = 10,
		run_start = 0,
		run_end = 10,
		pounce_start = 11,
		pounce_end = 31,
		lay_start = 34,
		lay_end = 34,
	},
	runaway = true,
	on_spawn = function(self)
		if minetest.find_node_near(self.object:get_pos(), 4, "mcl_core:snow") ~= nil or minetest.find_node_near(self.object:get_pos(), 4, "mcl_core:dirt_with_grass_snow") ~= nil then
			minetest.chat_send_all("true")
			self.object:set_properties({textures={"extra_mobs_artic_fox.png", "extra_mobs_trans.png"}})
		end
	end,
	do_custom = function(self)
		if self.child == true then
			self.object:set_properties({textures={self.base_texture[1], self.base_texture[1]}})
		end
		if self.state ~= "attack" and math.random(1, 5000) == 1 then
			self.state = "lay"
			self.object:set_animation({x= 12, y=16})
			minetest.after(math.random(10, 500), function()
				if self.state == "lay" then
					self.state = "stand"
				end
			end)
		end
		for _,object in pairs(minetest.get_objects_inside_radius(self.object:get_pos(), 8)) do
			if not object:is_player() and object:get_luaentity().name == "extra_mobs:fox" and self.state ~= "attack" and math.random(1, 500) == 1 then
				 self.horny = true
			end
			local lp = object:get_pos()
			local s = self.object:get_pos()
			local vec = {
				x = lp.x - s.x,
				y = lp.y - s.y,
				z = lp.z - s.z
			}
			if object:is_player() and not object:get_player_control().sneak or not object:is_player() and object:get_luaentity().name == "mobs_mc:wolf" then
				self.state = "runaway"
				self.object:set_rotation({x=0,y=(atan(vec.z / vec.x) + 3 * pi / 2) - self.rotate,z=0})
				if self.reach > vector.distance(self.object:get_pos(), object:get_pos()) and self.timer > .9 then
					self.timer = 0
					object:punch(self.object, 1.0, {
						full_punch_interval = 1.0,
						damage_groups = {fleshy = self.damage}
					}, nil)
				end
			end
		end
	end,
	do_punch = function(self)
		self.state = "runaway"
	end,
	fear_height = 4,
	view_range = 16,
	specific_attack = { "mobs_mc:cow", "mobs_mc:sheep", "mobs_mc:chicken" },
}

mobs:register_mob("extra_mobs:fox", fox)

-- spawning
mobs:spawn_specific("extra_mobs:fox", {"mcl_core:dirt_with_grass"}, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 6000, 3, 0, 500)

mobs:spawn_specific("extra_mobs:fox", {"mcl_core:dirt_with_grass_snow"}, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 6000, 3, 0, 500)
mobs:spawn_specific("extra_mobs:artic_fox", {"mcl_core:snow"}, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 6000, 3, 0, 500)

-- spawn eggs
mobs:register_egg("extra_mobs:fox", S("Fox"), "extra_mobs_spawn_icon_fox.png", 0)
