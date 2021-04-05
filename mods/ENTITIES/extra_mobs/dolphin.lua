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

local dir_to_pitch = function(dir)
	local dir2 = vector.normalize(dir)
	local xz = math.abs(dir.x) + math.abs(dir.z)
	return -math.atan2(-dir.y, xz)
end

local function degrees(rad)
	return rad * 180.0 / math.pi
end

local S = minetest.get_translator("extra_mobs")

--###################
--################### dolphin
--###################

local dolphin = {
    type = "monster",
    spawn_class = "water",
    can_despawn = true,
    passive = true,
    hp_min = 10,
    hp_max = 10,
    xp_min = 1,
    xp_max = 3,
    armor = 100,
		walk_chance = 100,
		breath_max = 120,
    collisionbox = {-0.3, 0.0, -0.3, 0.3, 0.79, 0.3},
    visual = "mesh",
    mesh = "extra_mobs_dolphin.b3d",
    textures = {
        {"extra_mobs_dolphin.png"}
    },
    sounds = {
    },
    animation = {
		stand_start = 20,
		stand_end = 20,
		walk_start = 0,
		walk_end = 15,
		run_start = 30,
		run_end = 45,
		},
		drops = {
			{name = "mcl_fishing:fish_raw",
			chance = 1,
			min = 0,
			max = 1,},
		},
    visual_size = {x=3, y=3},
    makes_footstep_sound = false,
    fly = true,
    fly_in = { mobs_mc.items.water_source, mobs_mc.items.river_water_source },
    breathes_in_water = true,
    jump = false,
    view_range = 16,
    fear_height = 4,
		walk_velocity = 3,
		run_velocity = 6,
		reach = 2,
		damage = 2.5,
		attack_type = "dogfight",
		do_custom = function(self)
      self.object:set_bone_position("body", vector.new(0,1,0), vector.new(degrees(dir_to_pitch(self.object:get_velocity())) * -1 + 90,0,0))
      if minetest.get_item_group(self.standing_in, "water") ~= 0 then
				if self.object:get_velocity().y < 5 then
        	self.object:add_velocity({ x = 0 , y = math.random(-.007, .007), z = 0 })
				end
      end
    end,
}

mobs:register_mob("extra_mobs:dolphin", dolphin)


--spawning TODO: in schools
local water = mobs_mc.spawn_height.water
mobs:spawn_specific("extra_mobs:dolphin", mobs_mc.spawn.water, {mobs_mc.items.water_source}, 0, minetest.LIGHT_MAX+1, 30, 4000, 3, water-16, water)

--spawn egg
mobs:register_egg("extra_mobs:dolphin", S("dolphin"), "extra_mobs_spawn_icon_dolphin.png", 0)
