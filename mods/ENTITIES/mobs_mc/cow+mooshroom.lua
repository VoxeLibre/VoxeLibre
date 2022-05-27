--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

local cow_def = {
	description = S("Cow"),
	type = "animal",
	spawn_class = "passive",
	hp_min = 10,
	hp_max = 10,
	xp_min = 1,
	xp_max = 3,
	collisionbox = {-0.45, -0.01, -0.45, 0.45, 1.39, 0.45},
	visual = "mesh",
	mesh = "mobs_mc_cow.b3d",
	textures = { {
		"mobs_mc_cow.png",
		"blank.png",
	}, },
	visual_size = {x=2.8, y=2.8},
	makes_footstep_sound = true,
	walk_velocity = 1,
	drops = {
		{name = "mcl_mobitems:beef",
		chance = 1,
		min = 1,
		max = 3,
		looting = "common",},
		{name = "mcl_mobitems:leather",
		chance = 1,
		min = 0,
		max = 2,
		looting = "common",},
	},
	runaway = true,
	sounds = {
		random = "mobs_mc_cow",
		damage = "mobs_mc_cow_hurt",
		death = "mobs_mc_cow_hurt",
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	animation = {
		stand_speed = 25, 	walk_speed = 40,
		run_speed = 60,     stand_start = 0,
		stand_end = 0,      walk_start = 0,
		walk_end = 40,      run_start = 0,
		run_end = 40,
	},
	on_rightclick = function(self, clicker)
		if mcl_mobs:feed_tame(self, clicker, 1, true, true) then return end
		if mcl_mobs:protect(self, clicker) then return end

		if self.child then
			return
		end

		local item = clicker:get_wielded_item()
		if item:get_name() == "mcl_buckets:bucket_empty" and clicker:get_inventory() then
			local inv = clicker:get_inventory()
			inv:remove_item("main", "mcl_buckets:bucket_empty")
			minetest.sound_play("mobs_mc_cow_milk", {pos=self.object:get_pos(), gain=0.6})
			-- if room add bucket of milk to inventory, otherwise drop as item
			if inv:room_for_item("main", {name = "mcl_mobitems:milk_bucket"}) then
				clicker:get_inventory():add_item("main", "mcl_mobitems:milk_bucket")
			else
				local pos = self.object:get_pos()
				pos.y = pos.y + 0.5
				minetest.add_item(pos, {name = "mcl_mobitems:milk_bucket"})
			end
			return
		end
		mcl_mobs:capture_mob(self, clicker, 0, 5, 60, false, nil)
	end,
	follow = "mcl_farming:wheat_item",
	view_range = 10,
	fear_height = 4,
}

mcl_mobs:register_mob("mobs_mc:cow", cow_def)

-- Mooshroom
local mooshroom_def = table.copy(cow_def)
mooshroom_def.description = S("Mooshroom")
mooshroom_def.mesh = "mobs_mc_cow.b3d"
mooshroom_def.textures = { {"mobs_mc_mooshroom.png", "mobs_mc_mushroom_red.png"}, {"mobs_mc_mooshroom_brown.png", "mobs_mc_mushroom_brown.png" } }
mooshroom_def.on_rightclick = function(self, clicker)
	if mcl_mobs:feed_tame(self, clicker, 1, true, true) then return end
	if mcl_mobs:protect(self, clicker) then return end

	if self.child then
		return
	end
	local item = clicker:get_wielded_item()
	-- Use shears to get mushrooms and turn mooshroom into cow
	if item:get_name() == "mcl_tools:shears" then
		local pos = self.object:get_pos()
		minetest.sound_play("mcl_tools_shears_cut", {pos = pos}, true)

		if self.base_texture[1] == "mobs_mc_mooshroom_brown.png" then
			minetest.add_item({x=pos.x, y=pos.y+1.4, z=pos.z}, "mcl_mushrooms:mushroom_brown 5")
		else
			minetest.add_item({x=pos.x, y=pos.y+1.4, z=pos.z}, "mcl_mushrooms:mushroom_red 5")
		end

		local oldyaw = self.object:get_yaw()
		self.object:remove()
		local cow = minetest.add_entity(pos, "mobs_mc:cow")
		cow:set_yaw(oldyaw)

		if not minetest.is_creative_enabled(clicker:get_player_name()) then
			item:add_wear(mobs_mc.shears_wear)
			clicker:get_inventory():set_stack("main", clicker:get_wield_index(), item)
		end
	-- Use bucket to milk
	elseif item:get_name() == "mcl_buckets:bucket_empty" and clicker:get_inventory() then
		local inv = clicker:get_inventory()
		inv:remove_item("main", "mcl_buckets:bucket_empty")
		minetest.sound_play("mobs_mc_cow_milk", {pos=self.object:get_pos(), gain=0.6})
		-- If room, add milk to inventory, otherwise drop as item
		if inv:room_for_item("main", {name="mcl_mobitems:milk_bucket"}) then
			clicker:get_inventory():add_item("main", "mcl_mobitems:milk_bucket")
		else
			local pos = self.object:get_pos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = "mcl_mobitems:milk_bucket"})
		end
	-- Use bowl to get mushroom stew
	elseif item:get_name() == "mcl_core:bowl" and clicker:get_inventory() then
		local inv = clicker:get_inventory()
		inv:remove_item("main", "mcl_core:bowl")
		minetest.sound_play("mobs_mc_cow_mushroom_stew", {pos=self.object:get_pos(), gain=0.6})
		-- If room, add mushroom stew to inventory, otherwise drop as item
		if inv:room_for_item("main", {name="mcl_mushrooms:mushroom_stew"}) then
			clicker:get_inventory():add_item("main", "mcl_mushrooms:mushroom_stew")
		else
			local pos = self.object:get_pos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = "mcl_mushrooms:mushroom_stew"})
		end
	end
	mcl_mobs:capture_mob(self, clicker, 0, 5, 60, false, nil)
end
mcl_mobs:register_mob("mobs_mc:mooshroom", mooshroom_def)


-- Spawning
mcl_mobs:spawn_specific(
"mobs_mc:cow",
"overworld",
"ground",
{
	"flat",
	"IcePlainsSpikes",
	"ColdTaiga",
	"ColdTaiga_beach",
	"ColdTaiga_beach_water",
	"MegaTaiga",
	"MegaSpruceTaiga",
	"ExtremeHills",
	"ExtremeHills_beach",
	"ExtremeHillsM",
	"ExtremeHills+",
	"ExtremeHills+_snowtop",
	"StoneBeach",
	"Plains",
	"Plains_beach",
	"SunflowerPlains",
	"Taiga",
	"Taiga_beach",
	"Forest",
	"Forest_beach",
	"FlowerForest",
	"FlowerForest_beach",
	"BirchForest",
	"BirchForestM",
	"RoofedForest",
	"Savanna",
	"Savanna_beach",
	"SavannaM",
	"Jungle",
	"Jungle_shore",
	"JungleM",
	"JungleM_shore",
	"JungleEdge",
	"JungleEdgeM",
	"Swampland",
	"Swampland_shore"
},
9,
minetest.LIGHT_MAX+1,
30,
17000,
10,
mobs_mc.water_level,
mcl_vars.mg_overworld_max)



mcl_mobs:spawn_specific(
"mobs_mc:mooshroom",
"overworld",
"ground",
{
"MushroomIslandShore",
"MushroomIsland"
},
9,
minetest.LIGHT_MAX+1,
30,
17000,
5,
mcl_vars.mg_overworld_min,
mcl_vars.mg_overworld_max)

-- spawn egg
mcl_mobs:register_egg("mobs_mc:cow", S("Cow"), "mobs_mc_spawn_icon_cow.png", 0)
mcl_mobs:register_egg("mobs_mc:mooshroom", S("Mooshroom"), "mobs_mc_spawn_icon_mooshroom.png", 0)
