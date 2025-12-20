--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### OCELOT AND CAT
--###################

local pr = PseudoRandom(os.time()*12)

local default_walk_chance = 70

local follow = {
	"mcl_fishing:fish_raw",
	"mcl_fishing:salmon_raw",
	"mcl_fishing:clownfish_raw",
	"mcl_fishing:pufferfish_raw",
}

local function is_food(itemstring)
	return table.indexof(follow, itemstring) ~= -1
end

-- Ocelot
local ocelot = {
	description = S("Ocelot"),
	type = "animal",
	spawn_class = "passive",
	can_despawn = true,
	spawn_in_group = 3,
	spawn_in_group_min = 1,
	initial_properties = {
		hp_min = 10,
		hp_max = 10,
		collisionbox = {-0.3, -0.01, -0.3, 0.3, 0.69, 0.3},
	},
	xp_min = 1,
	xp_max = 3,
	head_swivel = "head.control",
	head_eye_height = 0.4,
	head_bone_position = vector.new( 0, 6.44, -0.42 ), -- for minetest <= 5.8
	head_yaw="z",
	curiosity = 4,
	visual = "mesh",
	mesh = "mobs_mc_cat.b3d",
	textures = {"mobs_mc_cat_ocelot.png"},
	makes_footstep_sound = true,
	walk_chance = default_walk_chance,
	walk_velocity = 1,
	run_velocity = 3,
	follow_velocity = 1,
	floats = 1,
	runaway = true,
	fall_damage = 0,
	fear_height = 4,
	sounds = {
		damage = "mobs_mc_ocelot_hurt",
		death = "mobs_mc_ocelot_hurt",
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	animation = {
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 40, walk_speed = 40,
		run_start = 0, run_end = 40, run_speed = 50,
		sit_start = 50, sit_end = 50,
	},
	child_animations = {
		stand_start = 51, stand_end = 51,
		walk_start = 51, walk_end = 91, walk_speed = 60,
		run_start = 51, run_end = 91, run_speed = 75,
		sit_start = 101, sit_end = 101,
	},
	follow = follow,
	view_range = 12,
	passive = true,
	attack_type = "dogfight",
	pathfinding = 1,
	damage = 2,
	reach = 1,
	attack_animals = true,
	specific_attack = { "mobs_mc:chicken" },
	on_rightclick = function(self, clicker)
		if self.child then return end
		-- Try to tame ocelot (mobs:feed_tame is intentionally NOT used)
		local item = clicker:get_wielded_item()
		if is_food(item:get_name()) then
			if not minetest.is_creative_enabled(clicker:get_player_name()) then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			-- 1/3 chance of getting tamed
			if pr:next(1, 3) == 1 then
				local yaw = self.object:get_yaw()
				local cat = minetest.add_entity(self.object:get_pos(), "mobs_mc:cat")
				cat:set_yaw(yaw)
				local ent = cat:get_luaentity()
				ent.owner = clicker:get_player_name()
				ent.tamed = true
				self.object:remove()
				return
			end
		end

	end,
}

mcl_mobs.register_mob("mobs_mc:ocelot", ocelot)

-- Cat
local cat = table.copy(ocelot)
cat.description = S("Cat")
cat.textures = {{"mobs_mc_cat_black.png"}, {"mobs_mc_cat_red.png"}, {"mobs_mc_cat_siamese.png"}}
cat.can_despawn = false
cat.owner = ""
cat.order = "roam" -- "sit" or "roam"
cat.owner_loyal = true
cat.tamed = true
cat.runaway = false
cat.follow_velocity = 2.4
-- Automatically teleport cat to owner
cat.do_custom = mobs_mc.make_owner_teleport_function(12)
cat.sounds = {
	random = "mobs_mc_cat_idle",
	damage = "mobs_mc_cat_hiss",
	death = "mobs_mc_ocelot_hurt",
	eat = "mobs_mc_animal_eat_generic",
	distance = 16,
}
cat.on_rightclick = function(self, clicker)
	if self:feed_tame(clicker, 1, true, false) then return end
	if mcl_mobs:capture_mob(self, clicker, 0, 60, 5, false, nil) then return end
	if mcl_mobs:protect(self, clicker) then return end

	if self.child then return end

	-- Toggle sitting order

	if not self.owner or self.owner == "" then
		-- Huh? This cat has no owner? Let's fix this! This should never happen.
		self.owner = clicker:get_player_name()
	end

	if not self.order or self.order == "" or self.order == "sit" then
		self.order = "roam"
		self.walk_chance = default_walk_chance
		self.jump = true
	else
		-- “Sit!”
		-- TODO: Add sitting model
		self.order = "sit"
		self.walk_chance = 0
		self.jump = false
	end

end

cat.on_spawn  = function(self)
	if self.owner == "!witch!" then
		self._texture = {"mobs_mc_cat_black.png"}
	end
	if not self._texture then
		self._texture = cat.textures[math.random(#cat.textures)]
	end
	self.object:set_properties({textures = self._texture})
end

mcl_mobs.register_mob("mobs_mc:cat", cat)

local base_spawn_chance = 5000

-- Spawn ocelot
--they get the same as the llama because I'm trying to rework so much of this code right now -j4i
mcl_mobs:spawn_setup({
	name = "mobs_mc:ocelot",
	dimension = "overworld",
	type_of_spawning = "ground",
	biomes = {
		"Jungle",
		"JungleEdgeM",
		"JungleM",
		"JungleEdge",
		"BambooJungle",
		"BambooJungleM",
		"BambooJungleEdge",
		"BambooJungleEdgeM",
	},
	min_light = 0,
	max_light = minetest.LIGHT_MAX+1,
	interval = 30,
	chance = 300,
	aoc = 5,
	min_height = mobs_mc.water_level+15,
	max_height = mcl_vars.mg_overworld_max
})
--[[
mobs:spawn({
	name = "mobs_mc:ocelot",
	nodes = { "mcl_core:jungletree", "mcl_core:jungleleaves", "mcl_flowers:fern", "mcl_core:vine" },
	neighbors = {"air"},
	light_max = minetest.LIGHT_MAX+1,
	light_min = 0,
	chance = math.ceil(base_spawn_chance * 1.5), -- emulates 1/3 spawn failure rate
	active_object_count = 12,
	min_height = mobs_mc.water_level+1, -- Right above ocean level
	max_height = mcl_vars.mg_overworld_max,
	on_spawn = function(self, pos)
		 Note: Minecraft has a 1/3 spawn failure rate.
		In this mod it is emulated by reducing the spawn rate accordingly (see above).

		-- 1/7 chance to spawn 2 ocelot kittens
		if pr:next(1,7) == 1 then
			-- Turn object into a child
			local make_child = function(object)
				local ent = object:get_luaentity()
				object:set_properties({
					visual_size = { x = ent.base_size.x/2, y = ent.base_size.y/2 },
					collisionbox = {
						ent.base_colbox[1]/2,
						ent.base_colbox[2]/2,
						ent.base_colbox[3]/2,
						ent.base_colbox[4]/2,
						ent.base_colbox[5]/2,
						ent.base_colbox[6]/2,
					}
				})
				ent.child = true
			end

			-- Possible spawn offsets, two of these will get selected
			local k = 0.7
			local offsets = {
				{ x=k, y=0, z=0 },
				{ x=-k, y=0, z=0 },
				{ x=0, y=0, z=k },
				{ x=0, y=0, z=-k },
				{ x=k, y=0, z=k },
				{ x=k, y=0, z=-k },
				{ x=-k, y=0, z=k },
				{ x=-k, y=0, z=-k },
			}
			for i=1, 2 do
				local o = pr:next(1, #offsets)
				local offset = offsets[o]
				local child_pos = vector.add(pos, offsets[o])
				table.remove(offsets, o)
				make_child(minetest.add_entity(child_pos, "mobs_mc:ocelot"))
			end
		end
	end,
})
]]--

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:ocelot", S("Ocelot"), "#efde7d", "#564434", 0)
