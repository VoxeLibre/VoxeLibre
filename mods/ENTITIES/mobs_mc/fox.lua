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

local followitem = "mcl_farming:sweet_berry"

local fox = {
	type = "animal",
	passive = false,
	spawn_class = "hostile",
	skittish = true,
	runaway = true,
	hp_min = 10,
	hp_max = 10,
	xp_min = 1,
	xp_max = 2,
	armor = {fleshy = 90},
	attack_type = "dogfight",
	damage = 2,
	reach = 1.5,
	jump = true,
	makes_footstep_sound = true,
	walk_velocity = 3,
	run_velocity = 6,
	follow_velocity = 2,
	follow = followitem,
	pathfinding = 1,
	fear_height = 4,
	view_range = 16,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 0.84, 0.3},
	specific_attack = { "mobs_mc:chicken", "mobs_mc:cod", "mobs_mc:salmon" },
	visual = "mesh",
	mesh = "extra_mobs_fox.b3d",
	textures = { {
		"extra_mobs_fox.png",
		"extra_mobs_trans.png",
	} },
	visual_size = {x=3, y=3},
	sounds = {
	},
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
	on_spawn = function(self)
		if minetest.find_node_near(self.object:get_pos(), 4, "mcl_core:snow") ~= nil
		or minetest.find_node_near(self.object:get_pos(), 4, "mcl_core:dirt_with_grass_snow") ~= nil then
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
			if object
			and not object:is_player()
			and object:get_luaentity()
			and object:get_luaentity().name == "mobs_mc:fox"
			and self.state ~= "attack" and math.random(1, 500) == 1 then
				 self.horny = true
			end
			local lp = object:get_pos()
			local s = self.object:get_pos()
			local vec = {
				x = lp.x - s.x,
				y = lp.y - s.y,
				z = lp.z - s.z
			}
			-- scare logic
			if (object
			and object:is_player()
			and not object:get_player_control().sneak)
			or (not object:is_player()
			and object:get_luaentity()
			and object:get_luaentity().name == "mobs_mc:wolf") then
				-- don't keep setting it once it's set
				if not self.state == "runaway" then
					self.state = "runaway"
					self.object:set_rotation({x=0,y=(atan(vec.z / vec.x) + 3 * pi / 2) - self.rotate,z=0})
				end
				-- if it is within a distance of the player or wolf
				if 6 > vector.distance(self.object:get_pos(), object:get_pos()) then
					self.timer = self.timer + 1
					-- have some time before getting scared
					if self.timer > 6 then
						self.timer = 0
						-- punch the fox for the player, but don't do any damage
						self.object:punch(object, 0, {
							full_punch_interval = 0,
							damage_groups = {fleshy = 0}
						}, nil)
					end
				end
			end
		end
	end,
	do_punch = function(self)
		self.state = "runaway"
	end,
}

mcl_mobs:register_mob("mobs_mc:fox", fox)

-- spawning
mcl_mobs:spawn_setup({
	name      = "mobs_mc:fox",
	biomes    = {
		"FlowerForest",
		"Swampland",
		"Taiga",
		"ExtremeHills",
		"BirchForest",
		"MegaSpruceTaiga",
		"MegaTaiga",
		"ExtremeHills+",
		"Forest",
		"Plains",
		"ColdTaiga",
		"SunflowerPlains",
		"RoofedForest",
		"MesaPlateauFM_grasstop",
		"ExtremeHillsM",
		"BirchForestM",
	},
	interval = 30,
	chance = 6000,
	min_height = 1,
})

-- spawn eggs
mcl_mobs:register_egg("mobs_mc:fox", S("Fox"), "#FFDDCC", "#FFaa99", 0)
