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
	armor = 100,
	rotate = 180,
	spawn_in_group_min = 3,
	spawn_in_group = 5,
	tilt_swim = true,
	collisionbox = {-0.3, 0.0, -0.3, 0.3, 0.79, 0.3},
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
	animation = {
		stand_start = 40,
		stand_end = 80,
		walk_start = 140,
		walk_end = 190,
		run_start = 140,
		run_end = 190,
	},

	--	Somewhere in here is where hostility toward aquatic creatures should go.
	--	There is no flag for that yet though.

	--	Placeholder until someone fixes breeding.
	follow = {
		"mcl_fishing:clownfish_raw"
	},

--	Yes, the axolotl is huge. Blame Mojang, not me.
--	Due to a quirk, axolotls can fly in air as well as water. But they still die to it.
	visual_size = {x=3, y=3},
	makes_footstep_sound = false,
	fly = true,
	fly_in = { "mcl_core:water_source", "mclx_core:river_water_source" },
	breathes_in_water = true,
	jump = false,
	view_range = 16,
	runaway = true,
	fear_height = 4,
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
			if object and not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "mobs_mc:axolotl" then
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


--spawning TODO: in schools of 1-5

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

--spawn egg
mcl_mobs:register_egg("mobs_mc:axolotl", S("Axolotl"), "mobs_mc_spawn_icon_axolotl.png", 0)
