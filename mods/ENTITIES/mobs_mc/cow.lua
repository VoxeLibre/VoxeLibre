--MCmobs v0.2
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

mobs:register_mob("mobs_mc:cow", {
	type = "animal",
	hp_min = 10,
	hp_max = 10,
	collisionbox = {-0.6, -0.01, -0.6, 0.6, 1.8, 0.6},
	
	visual = "mesh",
	mesh = "mobs_mc_cow.x",
	textures = {
	{"mobs_mc_cow.png"}
	},
	makes_footstep_sound = true,
	walk_velocity = 1,
	armor = 100,
	drops = {
		{name = "mcl_mobitems:beef",
		chance = 1,
		min = 1,
		max = 3,},
		{name = "mcl_mobitems:leather",
		chance = 1,
		min = 0,
		max = 2,},
	},
	drawtype = "front",
	water_damage = 1,
	lava_damage = 5,
	light_damage = 0,
	fear_height = 3,
	sounds = {
		random = "mobs_mc_cow",
		death = "Cowhurt1",
		damage = "Cowhurt1",
	},
	animation = {
		speed_normal = 24,
		stand_start = 0,
		stand_end = 23,
		walk_start = 24,
		walk_end = 49,
		hurt_start = 118,
		hurt_end = 154,
		death_start = 154,
		death_end = 179,
		eat_start = 49,
		eat_end = 78,
		look_start = 78,
		look_end = 108,
	},
	--from mobs_animals
	follow = "mcl_farming:wheat_item",
	view_range = 10,
	fear_height = 2,
	on_rightclick = function(self, clicker)

		-- feed or tame
		if mobs:feed_tame(self, clicker, 8, true, true) then
			return
		end

		local tool = clicker:get_wielded_item()

		-- milk cow with empty bucket
		if tool:get_name() == "bucket:bucket_empty" then

			if self.child == true then
				return
			end

			local inv = clicker:get_inventory()

			inv:remove_item("main", "bucket:bucket_empty")

			if inv:room_for_item("main", {name = "mcl_mobitems:milk_bucket"}) then
				clicker:get_inventory():add_item("main", "mcl_mobitems:milk_bucket")
			else
				local pos = self.object:getpos()
				pos.y = pos.y + 0.5
				minetest.add_item(pos, {name = "mcl_mobitems:milk_bucket"})
			end

			return
		end
	end,	
})

mobs:register_spawn("mobs_mc:cow", {"group:solid"}, 20, 9, 7000, 1, 31000)


-- compatibility
mobs:alias_mob("mobs:cow", "mobs_mc:cow")

-- spawn egg
mobs:register_egg("mobs_mc:cow", "Spawn Cow", "spawn_egg_cow.png")


if minetest.setting_get("log_mods") then
	minetest.log("action", "MC Cow loaded")
end
