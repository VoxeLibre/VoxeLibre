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

local S = minetest.get_translator(minetest.get_current_modname())

--###################
--################### axolotl
--###################

local axolotl = {
	type = "animal",
	spawn_class = "water",
	can_despawn = true,
	passive = true,
	hp_min = 14,
	hp_max = 14,
	xp_min = 1,
    xp_max = 7,

    --  Random look at player works, but it looks away instead of towards.
    head_swivel = "head.control",
    bone_eye_height = -1,
    head_eye_height = -0.5,
    horrizonatal_head_height = 0,
    curiosity = 10,
    head_yaw="z",

	armor = 100,
	spawn_in_group_min = 1,
	spawn_in_group = 4,
	tilt_swim = true,
	collisionbox = {-0.5, 0.0, -0.5, 0.5, 0.8, 0.5},
	visual = "mesh",
	mesh = "mobs_mc_axolotl.b3d",
	textures = {
		{"mobs_mc_axolotl_brown.png"},
		{"mobs_mc_axolotl_yellow.png"},
		{"mobs_mc_axolotl_green.png"},
		{"mobs_mc_axolotl_pink.png"},
		{"mobs_mc_axolotl_black.png"},
		{"mobs_mc_axolotl_purple.png"},
		{"mobs_mc_axolotl_white.png"}		
	},
    sounds = {
		random = "mobs_mc_axolotl",
		damage = "mobs_mc_axolotl_hurt",
		distance = 16,
    },
	animation = {-- Stand: 1-20; Walk: 20-60; Swim: 61-81
		stand_start = 61, stand_end = 81, stand_speed = 15,
		walk_start = 61, walk_end = 81, walk_speed = 15,
		run_start = 61, run_end = 81, run_speed = 20,
	},

	--	Somewhere in here is where hostility toward aquatic creatures should go.
	--	There is no flag for that yet though.

	--	This should should make axolotls breedable, but it doesn't.
	follow = {
		"mcl_fishing:clownfish_raw"
	},

	view_range = 16,
	fear_height = 4,

	on_rightclick = function(self, clicker)
		if mcl_mobs:feed_tame(self, clicker, 1, true, false) then return end
		if mcl_mobs:protect(self, clicker) then return end
		if mcl_mobs:capture_mob(self, clicker, 0, 60, 5, false, nil) then return end
	end,

	makes_footstep_sound = false,
	fly = true,
	fly_in = { "mcl_core:water_source", "mclx_core:river_water_source" },
	breathes_in_water = true,
	jump = true,
	attack_animals = true,
	specific_attack = { "extra_mobs_cod",
"mobs_mc:sheep",
"extra_mobs_glow_squid",
"extra_mobs_salmon",
"extra_mobs_tropical_fish",
"mobs_mc_squid" },
	runaway = true,
	do_custom = function(self)
		--[[ this is supposed to make them jump out the water but doesn't appear to work very well
		self.object:set_bone_position("body", vector.new(0,1,0), vector.new(degrees(dir_to_pitch(self.object:get_velocity())) * -1 + 90,0,0))
		if minetest.get_item_group(self.standing_in, "water") ~= 0 then
			if self.object:get_velocity().y < 5 then
				self.object:add_velocity({ x = 0 , y = math.random(-.007, .007), z = 0 })
			end
		end
--]]
		for _,object in pairs(minetest.get_objects_inside_radius(self.object:get_pos(), 10)) do
			local lp = object:get_pos()
			local s = self.object:get_pos()
			local vec = {
				x = lp.x - s.x,
				y = lp.y - s.y,
				z = lp.z - s.z
			}
			if object and not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "extra_mobs_tropical_fish" then
				self.state = "runaway"
				self.object:set_rotation({x=0,y=(atan(vec.z / vec.x) + 3 * pi / 2) - self.rotate,z=0})
			end
		end
	end,
	on_rightclick = function(self, clicker)
		if clicker:get_wielded_item():get_name() == "mcl_buckets:bucket_water" then
			self.object:remove()
			clicker:set_wielded_item("mcl_buckets:bucket_axolotl")
			awards.unlock(clicker:get_player_name(), "mcl:cutestPredator")
		end
	end
}

mcl_mobs:register_mob("mobs_mc:axolotl", axolotl)


local water = 0

mcl_mobs:spawn_specific(
"mobs_mc:axolotl",
"overworld",
"water",
{
"Swampland",
"MushroomIsland",
"RoofedForest",
"FlowerForest_beach",
"Forest_beach",
"StoneBeach",
"Taiga_beach",
"Savanna_beach",
"Plains_beach",
"ExtremeHills_beach",
"Swampland_shore",
"MushroomIslandShore",
"JungleM_shore",
"Jungle_shore",
"RoofedForest_ocean",
"JungleEdgeM_ocean",
"BirchForestM_ocean",
"BirchForest_ocean",
"IcePlains_deep_ocean",
"Jungle_deep_ocean",
"Savanna_ocean",
"MesaPlateauF_ocean",
"SunflowerPlains_ocean",
"Swampland_ocean",
"ExtremeHillsM_ocean",
"Mesa_ocean",
"StoneBeach_ocean",
"Plains_ocean",
"MesaPlateauFM_ocean",
"MushroomIsland_ocean",
"MegaTaiga_ocean",
"StoneBeach_deep_ocean",
"SavannaM_ocean",
"ExtremeHills_ocean",
"Forest_ocean",
"JungleEdge_ocean",
"MesaBryce_ocean",
"MegaSpruceTaiga_ocean",
"ExtremeHills+_ocean",
"Jungle_ocean",
"FlowerForest_ocean",
"Desert_ocean",
"Taiga_ocean",
"JungleM_ocean",
"FlowerForest_underground",
"JungleEdge_underground",
"StoneBeach_underground",
"MesaBryce_underground",
"Mesa_underground",
"RoofedForest_underground",
"Jungle_underground",
"Swampland_underground",
"MushroomIsland_underground",
"BirchForest_underground",
"Plains_underground",
"MesaPlateauF_underground",
"ExtremeHills_underground",
"MegaSpruceTaiga_underground",
"BirchForestM_underground",
"SavannaM_underground",
"MesaPlateauFM_underground",
"Desert_underground",
"Savanna_underground",
"Forest_underground",
"SunflowerPlains_underground",
"MegaTaiga_underground",
"Taiga_underground",
"ExtremeHills+_underground",
"JungleM_underground",
"ExtremeHillsM_underground",
"JungleEdgeM_underground",
"LushCaves",
},
0,
minetest.LIGHT_MAX+1,
30,
4000,
3,
water-16,
water+1)

-- spawn eggs
mcl_mobs:register_egg("mobs_mc:axolotl", S("Axolotl"), "#e890bf", "#b83D7e", 0)
