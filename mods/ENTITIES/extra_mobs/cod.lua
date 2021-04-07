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
--################### cod
--###################

local cod = {
    type = "animal",
    spawn_class = "water",
    can_despawn = true,
    passive = true,
    hp_min = 3,
    hp_max = 3,
    xp_min = 1,
    xp_max = 3,
    armor = 100,
    collisionbox = {-0.3, 0.0, -0.3, 0.3, 0.79, 0.3},
    visual = "mesh",
    mesh = "extra_mobs_cod.b3d",
    textures = {
        {"extra_mobs_cod.png"}
    },
    sounds = {
    },
    animation = {
		stand_start = 1,
		stand_end = 20,
		walk_start = 1,
		walk_end = 20,
		run_start = 1,
		run_end = 20,
	},
    drops = {
		{name = "mcl_fishing:fish_raw",
		chance = 1,
		min = 1,
		max = 1,},
        {name = "mcl_dye:white",
		chance = 20,
		min = 1,
		max = 1,},
	},
    visual_size = {x=3, y=3},
    makes_footstep_sound = false,
    fly = true,
    fly_in = { mobs_mc.items.water_source, mobs_mc.items.river_water_source },
    breathes_in_water = true,
    jump = false,
    view_range = 16,
    runaway = true,
    fear_height = 4,
    do_custom = function(self)
      self.object:set_bone_position("body", vector.new(0,1,0), vector.new(degrees(dir_to_pitch(self.object:get_velocity())) * -1 + 90,0,0))
      if minetest.get_item_group(self.standing_in, "water") ~= 0 then
				if self.object:get_velocity().y < 2.5 then
        	self.object:add_velocity({ x = 0 , y = math.random(-.002, .002) , z = 0 })
				end
      end
      for _,object in pairs(minetest.get_objects_inside_radius(self.object:get_pos(), 10)) do
  			local lp = object:get_pos()
  			local s = self.object:get_pos()
  			local vec = {
  				x = lp.x - s.x,
  				y = lp.y - s.y,
  				z = lp.z - s.z
  			}
  			if not object:is_player() and object:get_luaentity().name == "extra_mobs:cod" then
  				self.state = "runaway"
  				self.object:set_rotation({x=0,y=(atan(vec.z / vec.x) + 3 * pi / 2) - self.rotate,z=0})
  			end
  		end
    end
}

mobs:register_mob("extra_mobs:cod", cod)


--spawning TODO: in schools
local water = mobs_mc.spawn_height.water
mobs:spawn_specific("extra_mobs:cod", "overworld", "water", 0, minetest.LIGHT_MAX+1, 30, 4000, 3, water-16, water)

--spawn egg
mobs:register_egg("extra_mobs:cod", S("Cod"), "extra_mobs_spawn_icon_cod.png", 0)
