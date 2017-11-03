--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

--###################
--################### OCELOT AND CAT
--###################

local pr = PseudoRandom(os.time()*12)

local default_walk_chance = 70

-- Returns true if the item is food (taming) for the cat/ocelot
local is_food = function(itemstring)
	for f=1, #mobs_mc.follow.ocelot do
		if itemstring == mobs_mc.follow.ocelot[f] then
			return true
		elseif string.sub(itemstring, 1, 6) == "group:" and minetest.get_item_group(itemstring, string.sub(itemstring, 7, -1)) ~= 0 then
			return true
		end
	end
	return false
end

-- Ocelot
local ocelot = {
	type = "animal",
	hp_min = 10,
	hp_max = 10,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 0.69, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_cat.b3d",
	textures = {"mobs_mc_cat_ocelot.png"},
	visual_size = {x=2.0, y=2.0},
	makes_footstep_sound = true,
	walk_chance = default_walk_chance,
	walk_velocity = 1,
	run_velocity = 3,
	floats = 1,
	runaway = true,
	water_damage = 0,
	lava_damage = 4,
	light_damage = 0,
	fall_damage = 0,
	fear_height = 4,
	sounds = {
		random = "mobs_kitten",
		distance = 16,
	},
	animation = {
		speed_normal = 25,		speed_run = 50,
		stand_start = 0,		stand_end = 0,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},
	follow = mobs_mc.follow.ocelot,
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
			if not minetest.settings:get_bool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			-- 1/3 chance of getting tamed
			if pr:next(1, 3) == 1 then
				local yaw = self.object:get_yaw()
				local cat = minetest.add_entity(self.object:getpos(), "mobs_mc:cat")
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

mobs:register_mob("mobs_mc:ocelot", ocelot)

-- Cat
local cat = table.copy(ocelot)
cat.textures = {{"mobs_mc_cat_black.png"}, {"mobs_mc_cat_red.png"}, {"mobs_mc_cat_siamese.png"}}
cat.owner = ""
cat.order = "roam" -- "sit" or "roam"
cat.owner_loyal = true
cat.tamed = true
cat.runaway = false
-- Automatically teleport cat to owner
cat.do_custom = mobs_mc.make_owner_teleport_function(12)
cat.on_rightclick = function(self, clicker)
	if mobs:feed_tame(self, clicker, 1, true, false) then return end
	if mobs:capture_mob(self, clicker, 0, 60, 5, false, nil) then return end
	if mobs:protect(self, clicker) then return end

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

mobs:register_mob("mobs_mc:cat", cat)

local base_spawn_chance = 5000

-- Spawn ocelot
mobs:spawn({
	name = "mobs_mc:ocelot",
	nodes = mobs_mc.spawn.jungle,
	neighbors = {"air"},
	light_max = minetest.LIGHT_MAX+1,
	light_min = 0,
	chance = math.ceil(base_spawn_chance * 1.5), -- emulates 1/3 spawn failure rate
	active_object_count = 12,
	min_height = mobs_mc.spawn_height.water+1, -- Right above ocean level
	max_height = mobs_mc.spawn_height.overworld_max,
	on_spawn = function(self, pos)
		--[[ Note: Minecraft has a 1/3 spawn failure rate.
		In this mod it is emulated by reducing the spawn rate accordingly (see above). ]]

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

-- compatibility
mobs:alias_mob("mobs:kitten", "mobs_mc:ocelot")

-- spawn eggs
-- FIXME: The spawn icon shows a cat texture, not an ocelot texture
mobs:register_egg("mobs_mc:ocelot", S("Ocelot"), "mobs_mc_spawn_icon_cat.png", 0)

if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC Ocelot loaded")
end
