--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

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

	hp_min = 8,
	hp_max = 8,
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
		war_cry = "mobs_wolf_attack",
		distance = 16,
	},
	pathfinding = 1,
	floats = 1,
	view_range = 16,
	walk_chance = default_walk_chance,
	walk_velocity = 2,
	run_velocity = 3,
	stepheight = 1.1,
	damage = 4,
	reach = 2,
	attack_type = "dogfight",
	fear_height = 4,
	water_damage = 0,
	lava_damage = 4,
	light_damage = 0,
	follow = mobs_mc.follow.wolf,
	on_rightclick = function(self, clicker)
		-- Try to tame wolf (intentionally does NOT use mobs:feed_tame)
		local tool = clicker:get_wielded_item()

		local dog, ent
		if tool:get_name() == mobs_mc.items.bone then

			if not minetest.settings:get_bool("creative_mode") then
				tool:take_item()
				clicker:set_wielded_item(tool)
			end
			-- 1/3 chance of getting tamed
			if pr:next(1, 3) == 1 then
				local yaw = self.object:get_yaw()
				dog = minetest.add_entity(self.object:getpos(), "mobs_mc:dog")
				dog:set_yaw(yaw)
				ent = dog:get_luaentity()
				ent.owner = clicker:get_player_name()
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
dog.passive = true
dog.hp_min = 20
dog.hp_max = 20
-- Tamed wolf texture + red collar
dog.textures = get_dog_textures("unicolor_red")
dog.owner = ""
-- TODO: Start sitting by default
dog.order = "roam"
dog.owner_loyal = true
-- Automatically teleport dog to owner
dog.do_custom = mobs_mc.make_owner_teleport_function(12)
dog.follow = mobs_mc.follow.dog
dog.on_rightclick = function(self, clicker)
	local item = clicker:get_wielded_item()

	if mobs:protect(self, clicker) then
		return
	elseif item:get_name() ~= "" and mobs:capture_mob(self, clicker, 0, 2, 80, false, nil) then
		return
	elseif is_food(item:get_name()) then
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
		if not minetest.settings:get_bool("creative_mode") then
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
					if not minetest.settings:get_bool("creative_mode") then
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

		if not self.order or self.order == "" or self.order == "sit" then
			self.order = "roam"
			self.walk_chance = default_walk_chance
			self.jump = true
		else
			-- TODO: Add sitting model
			self.order = "sit"
			self.walk_chance = 0
			self.jump = false
		end
	end
end

mobs:register_mob("mobs_mc:dog", dog)

-- Spawn
mobs:spawn_specific("mobs_mc:wolf", mobs_mc.spawn.wolf, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 9000, 20, mobs_mc.spawn_height.water+3, mobs_mc.spawn_height.overworld_max)

-- Compatibility
mobs:alias_mob("mobs:wolf", "mobs_mc:wolf")
mobs:alias_mob("mobs:dog", "mobs_mc:dog")
mobs:alias_mob("esmobs:wolf", "mobs_mc:wolf")
mobs:alias_mob("esmobs:dog", "mobs_mc:dog")

mobs:register_egg("mobs_mc:wolf", S("Wolf"), "mobs_mc_spawn_icon_wolf.png", 0)

if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC Wolf loaded")
end
