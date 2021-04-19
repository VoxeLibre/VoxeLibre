--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

local default_walk_chance = 50

local pr = PseudoRandom(os.time()*10)

local is_food = function(itemstring)
	for f=1, #mobs_mc.follow.dog do
		if itemstring == mobs_mc.follow.dog[f] then
			return true
		elseif string.sub(itemstring, 1, 6) == "group:" and minetest.get_item_group(itemstring, string.sub(itemstring, 7, -1)) ~= 0 then
			return true
		end
	end
	return false
end

-- Wolf
local wolf = {
	type = "animal",
	spawn_class = "passive",
	can_despawn = true,
	hp_min = 8,
	hp_max = 8,
	xp_min = 1,
	xp_max = 3,
	passive = false,
	group_attack = true,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 0.84, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_wolf.b3d",
	textures = {
		{"mobs_mc_wolf.png"},
	},
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
	sounds = {
		attack = "mobs_mc_wolf_bark",
		war_cry = "mobs_mc_wolf_growl",
		damage = {name = "mobs_mc_wolf_hurt", gain=0.6},
		death = {name = "mobs_mc_wolf_death", gain=0.6},
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	pathfinding = 1,
	floats = 1,
	view_range = 16,
	walk_chance = default_walk_chance,
	walk_velocity = 2,
	run_velocity = 3,
	damage = 4,
	reach = 2,
	attack_type = "dogfight",
	fear_height = 4,
	follow = mobs_mc.follow.wolf,
	on_rightclick = function(self, clicker)
		-- Try to tame wolf (intentionally does NOT use mobs:feed_tame)
		local tool = clicker:get_wielded_item()

		local dog, ent
		if tool:get_name() == mobs_mc.items.bone then

			minetest.sound_play("mobs_mc_wolf_take_bone", {object=self.object, max_hear_distance=16}, true)
			if not minetest.is_creative_enabled(clicker:get_player_name()) then
				tool:take_item()
				clicker:set_wielded_item(tool)
			end
			-- 1/3 chance of getting tamed
			if pr:next(1, 3) == 1 then
				local yaw = self.object:get_yaw()
				dog = minetest.add_entity(self.object:get_pos(), "mobs_mc:dog")
				dog:set_yaw(yaw)
				ent = dog:get_luaentity()
				ent.owner = clicker:get_player_name()
				-- cornfirm taming
				minetest.sound_play("mobs_mc_wolf_bark", {object=dog, max_hear_distance=16}, true)
				-- Replace wolf
				self.object:remove()
			end
		end
	end,
	animation = {
		speed_normal = 50,		speed_run = 100,
		stand_start = 40,		stand_end = 45,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},
	jump = true,
	attacks_monsters = true,
	attack_animals = true,
	specific_attack = { "player", "mobs_mc:sheep" },
}

mobs:register_mob("mobs_mc:wolf", wolf)

-- Tamed wolf

-- Collar colors
local colors = {
	["unicolor_black"] = "#000000",
	["unicolor_blue"] = "#0000BB",
	["unicolor_dark_orange"] = "#663300", -- brown
	["unicolor_cyan"] = "#01FFD8",
	["unicolor_dark_green"] = "#005B00",
	["unicolor_grey"] = "#C0C0C0",
	["unicolor_darkgrey"] = "#303030",
	["unicolor_green"] = "#00FF01",
	["unicolor_red_violet"] = "#FF05BB", -- magenta
	["unicolor_orange"] = "#FF8401",
	["unicolor_light_red"] = "#FF65B5", -- pink
	["unicolor_red"] = "#FF0000",
	["unicolor_violet"] = "#5000CC",
	["unicolor_white"] = "#FFFFFF",
	["unicolor_yellow"] = "#FFFF00",

	["unicolor_light_blue"] = "#B0B0FF",
}

local get_dog_textures = function(color)
	if colors[color] then
		return {"mobs_mc_wolf_tame.png^(mobs_mc_wolf_collar.png^[colorize:"..colors[color]..":192)"}
	else
		return nil
	end
end

-- Tamed wolf (aka “dog”)
local dog = table.copy(wolf)
dog.can_despawn = false
dog.passive = true
dog.hp_min = 20
dog.hp_max = 20
-- Tamed wolf texture + red collar
dog.textures = get_dog_textures("unicolor_red")
dog.owner = ""
-- TODO: Start sitting by default
dog.order = "roam"
dog.owner_loyal = true
dog.follow_velocity = 3.2 
-- Automatically teleport dog to owner
dog.do_custom = mobs_mc.make_owner_teleport_function(12)
dog.follow = mobs_mc.follow.dog
dog.attack_animals = nil
dog.specific_attack = nil
dog.on_rightclick = function(self, clicker)
	local item = clicker:get_wielded_item()

	if is_food(item:get_name()) then
		-- Feed to increase health
		local hp = self.health
		local hp_add = 0
		-- Use eatable group to determine health boost
		local eatable = minetest.get_item_group(item, "eatable")
		if eatable > 0 then
			hp_add = eatable
		elseif item:get_name() == mobs_mc.items.rotten_flesh then
			hp_add = 4
		else
			hp_add = 4
		end
		local new_hp = hp + hp_add
		if new_hp > self.hp_max then
			new_hp = self.hp_max
		end
		if not minetest.is_creative_enabled(clicker:get_player_name()) then
			item:take_item()
			clicker:set_wielded_item(item)
		end
		self.health = new_hp
		return
	elseif minetest.get_item_group(item:get_name(), "dye") == 1 then
		-- Dye (if possible)
		for group, _ in pairs(colors) do
			-- Check if color is supported
			if minetest.get_item_group(item:get_name(), group) == 1 then
				-- Dye collar
				local tex = get_dog_textures(group)
				if tex then
					self.base_texture = tex
					self.object:set_properties({
						textures = self.base_texture
					})
					if not minetest.is_creative_enabled(clicker:get_player_name()) then
						item:take_item()
						clicker:set_wielded_item(item)
					end
					break
				end
			end
		end
	else
		-- Toggle sitting order

		if not self.owner or self.owner == "" then
			-- Huh? This wolf has no owner? Let's fix this! This should never happen.
			self.owner = clicker:get_player_name()
		end

		local pos = self.object:get_pos()
		local particle
		if not self.order or self.order == "" or self.order == "sit" then
			particle = "mobs_mc_wolf_icon_roam.png"
			self.order = "roam"
			self.walk_chance = default_walk_chance
			self.jump = true
			-- TODO: Add sitting model
		else
			particle = "mobs_mc_wolf_icon_sit.png"
			self.order = "sit"
			self.walk_chance = 0
			self.jump = false
		end
		-- Display icon to show current order (sit or roam)
		minetest.add_particle({
			pos = vector.add(pos, {x=0,y=1,z=0}),
			velocity = {x=0,y=0.2,z=0},
			expirationtime = 1,
			size = 4,
			texture = particle,
			playername = self.owner,
			glow = minetest.LIGHT_MAX,
		})
	end
end

mobs:register_mob("mobs_mc:dog", dog)

-- Spawn
mobs:spawn_specific(
"mobs_mc:wolf",
"overworld",
"ground",
{
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
0, 
minetest.LIGHT_MAX+1, 
30, 
9000, 
7, 
mobs_mc.spawn_height.water+3, 
mobs_mc.spawn_height.overworld_max)

mobs:register_egg("mobs_mc:wolf", S("Wolf"), "mobs_mc_spawn_icon_wolf.png", 0)
