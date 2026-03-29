local S = minetest.get_translator("mobs_mc")

local default_walk_chance = 50

local pr = PseudoRandom(os.time()*10)

local update_tail = function(self)
	if not self.object or not self.object:get_pos() then return end
	local max_hp = self.initial_properties and self.initial_properties.hp_max or 1
	if max_hp <= 0 then max_hp = 1 end
	local health = self.health or max_hp
	local ratio = math.min(1, math.max(0, health / max_hp))
	-- Tail angle: -0.7 radians (up, healthy) to 0.7 radians (down, hurt)
	local pitch = 0.7 - (ratio * 1.4)
	mcl_util.set_bone_position(self.object, "tail", nil, vector.new(pitch, 0, 0))
end

-- Wolf
local wolf = {
	description = S("Wolf"),
	type = "animal",
	spawn_class = "passive",
	can_despawn = true,
	initial_properties = {
		hp_min = 8,
		hp_max = 8,
		collisionbox = {-0.3, -0.01, -0.3, 0.3, 0.84, 0.3},
	},
	xp_min = 1,
	xp_max = 3,
	passive = false,
	group_attack = true,
	spawn_in_group = 8,
	visual = "mesh",
	mesh = "mobs_mc_wolf.b3d",
	textures = {
		{"mobs_mc_wolf.png"},
	},
	makes_footstep_sound = true,
	head_swivel = "head.control",
	head_eye_height = 0.5,
	head_bone_position = vector.new( 0, 3.5, 0 ), -- for minetest <= 5.8
	horizontal_head_height=0,
	curiosity = 3,
	head_yaw="z",
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
	do_custom = update_tail,
	follow = { "mcl_mobitems:bone" },
	on_rightclick = function(self, clicker)
		-- Try to tame wolf (intentionally does NOT use mcl_mobs:feed_tame)
		local tool = clicker:get_wielded_item()

		local dog, ent
		if tool:get_name() == "mcl_mobitems:bone" then

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
				ent.tamed = true
				ent:set_animation("sit")
				ent.walk_chance = 0
				ent.jump = false
				local wolf_max = self.initial_properties and self.initial_properties.hp_max or 1
				local dog_max = ent.initial_properties and ent.initial_properties.hp_max or wolf_max
				if wolf_max <= 0 then wolf_max = 1 end
				if dog_max <= 0 then dog_max = wolf_max end
				ent.health = math.max(1, math.floor((self.health / wolf_max) * dog_max + 0.5))
				update_tail(ent)
				-- cornfirm taming
				minetest.sound_play("mobs_mc_wolf_bark", {object=dog, max_hear_distance=16}, true)
				-- Replace wolf
				self.object:remove()
			end
		end
	end,
	animation = {
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 40, walk_speed = 50,
		run_start = 0, run_end = 40, run_speed = 100,
		sit_start = 45, sit_end = 45,
	},
	child_animations = {
		stand_start = 46, stand_end = 46,
		walk_start = 46, walk_end = 86, walk_speed = 75,
		run_start = 46, run_end = 86, run_speed = 150,
		sit_start = 91, sit_end = 91,
	},
	jump = true,
	_on_tame_convert_to = "mobs_mc:dog",
	after_activate = function(self)
		update_tail(self)
		self:check_tame_conversion()
	end,
	attacks_monsters = true,
	attack_animals = true,
	specific_attack = { "player", "mobs_mc:sheep", "mobs_mc:rabbit" },
}

mcl_mobs.register_mob("mobs_mc:wolf", wolf)

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
dog.description = S("Dog")
dog.can_despawn = false
dog.passive = true
dog.initial_properties = table.copy(wolf.initial_properties)
dog.initial_properties.hp_min = 20
dog.initial_properties.hp_max = 20
-- Tamed wolf texture + red collar
dog.textures = get_dog_textures("unicolor_red")
dog.owner = ""
dog._walk_chance_roam = 50
-- TODO: Start sitting by default
dog.order = "sit"
dog.state = "stand"
dog.walk_chance = 0
dog.owner_loyal = true
dog.follow_velocity = 3.2
-- Automatically teleport dog to owner
local dog_teleport = mobs_mc.make_owner_teleport_function(24)
dog.do_custom = function(self, dtime)
	update_tail(self)
	return dog_teleport(self, dtime)
end
dog.after_activate = update_tail
dog.follow = {
	"mcl_mobitems:rabbit", "mcl_mobitems:cooked_rabbit",
	"mcl_mobitems:mutton", "mcl_mobitems:cooked_mutton",
	"mcl_mobitems:beef", "mcl_mobitems:cooked_beef",
	"mcl_mobitems:chicken", "mcl_mobitems:cooked_chicken",
	"mcl_mobitems:porkchop", "mcl_mobitems:cooked_porkchop",
	"mcl_mobitems:rotten_flesh",
}
dog.attack_animals = nil
dog.specific_attack = nil

local is_food = function(itemstring)
	return table.indexof(dog.follow, itemstring) ~= -1
end

dog.on_rightclick = function(self, clicker)
	local item = clicker:get_wielded_item()

	if self:feed_tame(clicker, 1, true, false) then
		update_tail(self)
		return
	elseif mcl_mobs:protect(self, clicker) then
		return
	elseif item:get_name() ~= "" and mcl_mobs:capture_mob(self, clicker, 0, 2, 80, false, nil) then
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
		if not self.owner or self.owner == "" then
		-- Huh? This dog has no owner? Let's fix this! This should never happen.
			self.owner = clicker:get_player_name()
		end
		if not minetest.settings:get_bool("mcl_extended_pet_control",true) then
			self:toggle_sit(clicker,-0.4)
		end
	end
end

mcl_mobs.register_mob("mobs_mc:dog", dog)
-- Spawn
mcl_mobs:spawn_setup({
	name = "mobs_mc:wolf",
	dimension = "overworld",
	type_of_spawning = "ground",
	biomes = {
		"Taiga",
		"MegaSpruceTaiga",
		"MegaTaiga",
		"Forest",
		"ColdTaiga",
		"Forest_beach",
		"ColdTaiga_beach_water",
		"Taiga_beach",
		"ColdTaiga_beach",
	},
	min_light = 0,
	max_light = minetest.LIGHT_MAX+1,
	chance = 80,
	interval = 30,
	aoc = 7,
	min_height = mobs_mc.water_level+3,
	max_height = mcl_vars.mg_overworld_max
})

mcl_mobs.register_egg("mobs_mc:wolf", S("Wolf"), "#d7d3d3", "#ceaf96", 0)
