--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

-- foliage and grass palettes, loaded from mcl_maps
local colors = {}

local mapmodpath = minetest.get_modpath("mcl_maps")
if mapmodpath then
	local file = assert(io.open(mapmodpath .. "/colors.json", "r"))
	local data = minetest.parse_json(file:read("*all"))
	file:close()
	for k,v in pairs(data) do
		colors[k] = v
	end
end


local function get_texture(self, prev)
	local standing_on = self.standing_on
	local texture
	local tex_mod = ""
	if standing_on and (standing_on.walkable or standing_on.groups.liquid) then
		local tiles = standing_on.tiles
		if tiles then
			local tile = tiles[1]
			local color
			if type(tile) == "table" then
				texture = tile.name or tile.image
				color = tile.color and minetest.colorspec_to_colorstring(tile.color)
			elseif type(tile) == "string" then
				texture = tile
			end
			color = color or minetest.colorspec_to_colorstring(standing_on.color)
			-- get colors from mcl_maps data where possible, including param2
			local cols = colors[standing_on.name]
			if cols and type(cols[1]) == "table" and self.standing_on_node then
				local param2
				if standing_on.paramtype2 == "color" then
					param2 = self.standing_on_node.param2
				elseif standing_on.paramtype2 == "colorfacedir" then
					param2 = math.floor(self.standing_on_node.param2 / 8)
				elseif standing_on.paramtype2 == "colorwallmounted" then
					param2 = math.floor(self.standing_on_node.param2 / 32)
				elseif standing_on.paramtype2 == "color4dir" then
					param2 = math.floor(self.standing_on_node.param2 / 64)
				elseif standing_on.paramtype2 == "colordegrotate" then
					param2 = math.floor(self.standing_on_node.param2 / 8)
				end
				color = cols[param2 + 1] or color
			end
			if color then
				if type(color) == "table" then color = minetest.rgba(color[1], color[2], color[3], color[4]) end
				tex_mod = "^[multiply:" .. color
			end
			tex_mod = tex_mod .. "^[hsl:0:20:20"
		end
	end
	if not texture or texture == "" then
		-- try to keep last texture when, e.g., falling
		if prev and (not (not self.attack)) == (string.find(prev, "vl_mobs_stalker_overlay_angry.png") ~= nil) then
			return prev
		end
		texture = "vl_stalker_default.png"
		if tex_mod then texture = texture .. tex_mod end
	else
		texture = texture:gsub("([\\^:\\[])", "\\%1") -- escape texture modifiers
		texture = "(vl_stalker_default.png^[combine:16x24:0,0=(" .. texture .. "):0,16=(" .. texture .. ")" .. tex_mod .. ")"
	end
	if self.attack then
		texture = texture .. "^vl_mobs_stalker_overlay_angry.png"
	else
		texture = texture .. "^vl_mobs_stalker_overlay.png"
	end
	return texture
end

local AURA = "vl_stalker_overloaded_aura.png"
local function get_overloaded_aura(timer)
	local frame = math.floor(timer*16)
	local f = tostring(frame)
	local nf = tostring(16-f)
	return "[combine:16x24:-" .. nf ..",0=" .. AURA .. ":" .. f .. ",0=" .. AURA
end



mcl_mobs.register_mob("mobs_mc:stalker", {
	description = S("Stalker"),
	type = "monster",
	spawn_class = "hostile",
	spawn_in_group = 1,
	hp_min = 20,
	hp_max = 20,
	xp_min = 5,
	xp_max = 5,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.69, 0.3},
	pathfinding = 1,
	visual = "mesh",
	mesh = "vl_stalker.b3d",
-- 	head_swivel = "Head_Control",
	head_eye_height = 1.2;
	head_bone_position = vector.new( 0, 2.35, 0 ), -- for minetest <= 5.8
	curiosity = 2,
	textures = {
		{get_texture({}),
		"mobs_mc_empty.png"},
	},
	visual_size = {x=2, y=2},
	sounds = {
		attack = "tnt_ignite",
		death = "mobs_mc_creeper_death",
		damage = "mobs_mc_creeper_hurt",
		fuse = "tnt_ignite",
		explode = "tnt_explode",
		distance = 16,
	},
	makes_footstep_sound = true,
	walk_velocity = 1.05,
	run_velocity = 2.0,
	runaway_from = { "mobs_mc:ocelot", "mobs_mc:cat" },
	attack_type = "explode",

	--hssssssssssss

	explosion_strength = 3,
	explosion_radius = 3.5,
	explosion_damage_radius = 3.5,
	explosiontimer_reset_radius = 3,
	reach = 3,
	see_through_opaque = false,
	explosion_timer = 1.5,
	allow_fuse_reset = true,
	stop_to_explode = true,

	-- Force-ignite stalker with flint and steel and explode after 1.5 seconds.
	-- TODO: Make stalker flash after doing this as well.
	-- TODO: Test and debug this code.
	on_rightclick = function(self, clicker)
		if self._forced_explosion_countdown_timer ~= nil then
			return
		end
		local item = clicker:get_wielded_item()
		if item:get_name() == "mcl_fire:flint_and_steel" then
			if not minetest.is_creative_enabled(clicker:get_player_name()) then
				-- Wear tool
				local wdef = item:get_definition()
				item:add_wear(1000)
				-- Tool break sound
				if item:get_count() == 0 and wdef.sound and wdef.sound.breaks then
					minetest.sound_play(wdef.sound.breaks, {pos = clicker:get_pos(), gain = 0.5}, true)
				end
				clicker:set_wielded_item(item)
			end
			self._forced_explosion_countdown_timer = self.explosion_timer
			minetest.sound_play(self.sounds.attack, {pos = self.object:get_pos(), gain = 1, max_hear_distance = 16}, true)
		end
	end,
	do_custom = function(self, dtime)
		if self._forced_explosion_countdown_timer ~= nil then
			self._forced_explosion_countdown_timer = self._forced_explosion_countdown_timer - dtime
			if self._forced_explosion_countdown_timer <= 0 then
				self:boom(mcl_util.get_object_center(self.object), self.explosion_strength)
			end
		end
		local new_texture = get_texture(self, self._stalker_texture)
		if self._stalker_texture ~= new_texture then
			self.object:set_properties({textures={new_texture, "mobs_mc_empty.png"}})
			self._stalker_texture = new_texture
		end
	end,
	on_die = function(self, pos, cmi_cause)
		-- Drop a random music disc when killed by skeleton or stray
		if cmi_cause and cmi_cause.type == "punch" then
			local luaentity = cmi_cause.puncher and cmi_cause.puncher:get_luaentity()
			if luaentity and luaentity.name:find("arrow") then
				local shooter_luaentity = luaentity._shooter and luaentity._shooter:get_luaentity()
				if shooter_luaentity and (shooter_luaentity.name == "mobs_mc:skeleton" or shooter_luaentity.name == "mobs_mc:stray") then
					minetest.add_item({x=pos.x, y=pos.y+1, z=pos.z}, "mcl_jukebox:record_" .. math.random(9))
				end
			end
		end
	end,
	maxdrops = 2,
	drops = {
		{name = "mcl_mobitems:gunpowder",
		chance = 1,
		min = 0,
		max = 2,
		looting = "common",},

		-- Head
		-- TODO: Only drop if killed by charged stalker
		{name = "mcl_heads:stalker",
		chance = 200, -- 0.5%
		min = 1,
		max = 1,},
	},
	animation = {
		speed_normal = 30,
		speed_run = 60,
		stand_start = 0,
		stand_end = 23,
		walk_start = 24,
		walk_end = 49,
		run_start = 24,
		run_end = 49,
		fuse_start = 49,
		fuse_end = 80,
	},
	floats = 1,
	fear_height = 4,
	view_range = 16,

	_on_after_convert = function(obj)
		obj:set_properties({
			visual_size = {x=2, y=2},
			mesh = "vl_stalker.b3d",
			textures = {
				{get_texture({}),
				"mobs_mc_empty.png"},
			},
		})
	end,
}) -- END mcl_mobs.register_mob("mobs_mc:stalker", {

mcl_mobs.register_mob("mobs_mc:stalker_overloaded", {
	description = S("Overloaded Stalker"),
	type = "monster",
	spawn_class = "hostile",
	hp_min = 20,
	hp_max = 20,
	xp_min = 5,
	xp_max = 5,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.69, 0.3},
	pathfinding = 1,
	visual = "mesh",
	mesh = "vl_stalker.b3d",

	--BOOM

	textures = {
		{get_texture({}),
		AURA},
	},
	use_texture_alpha = true,
	visual_size = {x=2, y=2},
	sounds = {
		attack = "tnt_ignite",
		death = "mobs_mc_creeper_death",
		damage = "mobs_mc_creeper_hurt",
		fuse = "tnt_ignite",
		explode = "tnt_explode",
		distance = 16,
	},
	makes_footstep_sound = true,
	walk_velocity = 1.05,
	run_velocity = 2.1,
	runaway_from = { "mobs_mc:ocelot", "mobs_mc:cat" },
	attack_type = "explode",

	explosion_strength = 6,
	explosion_radius = 8,
	explosion_damage_radius = 8,
	explosiontimer_reset_radius = 3,
	reach = 3,
	explosion_timer = 1.5,
	allow_fuse_reset = true,
	stop_to_explode = true,

	-- Force-ignite stalker with flint and steel and explode after 1.5 seconds.
	-- TODO: Make stalker flash after doing this as well.
	-- TODO: Test and debug this code.
	on_rightclick = function(self, clicker)
		if self._forced_explosion_countdown_timer ~= nil then
			return
		end
		local item = clicker:get_wielded_item()
		if item:get_name() == "mcl_fire:flint_and_steel" then
			if not minetest.is_creative_enabled(clicker:get_player_name()) then
				-- Wear tool
				local wdef = item:get_definition()
				item:add_wear(1000)
				-- Tool break sound
				if item:get_count() == 0 and wdef.sound and wdef.sound.breaks then
					minetest.sound_play(wdef.sound.breaks, {pos = clicker:get_pos(), gain = 0.5}, true)
				end
				clicker:set_wielded_item(item)
			end
			self._forced_explosion_countdown_timer = self.explosion_timer
			minetest.sound_play(self.sounds.attack, {pos = self.object:get_pos(), gain = 1, max_hear_distance = 16}, true)
		end
	end,
	do_custom = function(self, dtime)
		if self._forced_explosion_countdown_timer ~= nil then
			self._forced_explosion_countdown_timer = self._forced_explosion_countdown_timer - dtime
			if self._forced_explosion_countdown_timer <= 0 then
				self:boom(mcl_util.get_object_center(self.object), self.explosion_strength)
			end
		end
		if not self._aura_timer or self._aura_timer > 1 then self._aura_timer = 0 end
		self._aura_timer = self._aura_timer + dtime
		self.object:set_properties({textures={get_texture(self), get_overloaded_aura(self._aura_timer)}})
	end,
	on_die = function(self, pos, cmi_cause)
		-- Drop a random music disc when killed by skeleton or stray
		if cmi_cause and cmi_cause.type == "punch" then
			local luaentity = cmi_cause.puncher and cmi_cause.puncher:get_luaentity()
			if luaentity and luaentity.name:find("arrow") then
				local shooter_luaentity = luaentity._shooter and luaentity._shooter:get_luaentity()
				if shooter_luaentity and (shooter_luaentity.name == "mobs_mc:skeleton" or shooter_luaentity.name == "mobs_mc:stray") then
					minetest.add_item({x=pos.x, y=pos.y+1, z=pos.z}, "mcl_jukebox:record_" .. math.random(9))
				end
			end
		end
	end,
	on_lightning_strike = function(self, pos, pos2, objects)
		 mcl_util.replace_mob(self.object, "mobs_mc:stalker_overloaded")
		 return true
	end,
	maxdrops = 2,
	drops = {
		{name = "mcl_mobitems:gunpowder",
		chance = 1,
		min = 0,
		max = 2,
		looting = "common",},

		-- Head
		-- TODO: Only drop if killed by overloaded stalker
		{name = "mcl_heads:stalker",
		chance = 200, -- 0.5%
		min = 1,
		max = 1,},
	},
	animation = {
		speed_normal = 30,
		speed_run = 60,
		stand_start = 0,
		stand_end = 23,
		walk_start = 24,
		walk_end = 49,
		run_start = 24,
		run_end = 49,
		fuse_start = 49,
		fuse_end = 80,
	},
	floats = 1,
	fear_height = 4,
	view_range = 16,
	--Having trouble when fire is placed with lightning
	fire_resistant = true,
	glow = 3,

	_on_after_convert = function(obj)
		obj:set_properties({
			visual_size = {x=2, y=2},
			mesh = "vl_stalker.b3d",
			textures = {
				{get_texture({}),
				AURA},
			},
		})
	end,
}) -- END mcl_mobs.register_mob("mobs_mc:stalker_overloaded", {

-- compat
mcl_mobs.register_conversion("mobs_mc:creeper", "mobs_mc:stalker")
mcl_mobs.register_conversion("mobs_mc:creeper_charged", "mobs_mc:stalker_overloaded")

mcl_mobs:spawn_specific(
"mobs_mc:stalker",
"overworld",
"ground",
{
"Mesa",
"FlowerForest",
"Swampland",
"Taiga",
"ExtremeHills",
"Jungle",
"Savanna",
"BirchForest",
"MegaSpruceTaiga",
"MegaTaiga",
"ExtremeHills+",
"Forest",
"Plains",
"Desert",
"ColdTaiga",
"IcePlainsSpikes",
"SunflowerPlains",
"IcePlains",
"RoofedForest",
"ExtremeHills+_snowtop",
"MesaPlateauFM_grasstop",
"JungleEdgeM",
"ExtremeHillsM",
"JungleM",
"BirchForestM",
"MesaPlateauF",
"MesaPlateauFM",
"MesaPlateauF_grasstop",
"MesaBryce",
"JungleEdge",
"SavannaM",
"FlowerForest_beach",
"Forest_beach",
"StoneBeach",
"ColdTaiga_beach_water",
"Taiga_beach",
"Savanna_beach",
"Plains_beach",
"ExtremeHills_beach",
"ColdTaiga_beach",
"Swampland_shore",
"JungleM_shore",
"Jungle_shore",
"MesaPlateauFM_sandlevel",
"MesaPlateauF_sandlevel",
"MesaBryce_sandlevel",
"Mesa_sandlevel",
"RoofedForest_ocean",
"JungleEdgeM_ocean",
"BirchForestM_ocean",
"BirchForest_ocean",
"IcePlains_deep_ocean",
"Jungle_deep_ocean",
"Savanna_ocean",
"MesaPlateauF_ocean",
"ExtremeHillsM_deep_ocean",
"Savanna_deep_ocean",
"SunflowerPlains_ocean",
"Swampland_deep_ocean",
"Swampland_ocean",
"MegaSpruceTaiga_deep_ocean",
"ExtremeHillsM_ocean",
"JungleEdgeM_deep_ocean",
"SunflowerPlains_deep_ocean",
"BirchForest_deep_ocean",
"IcePlainsSpikes_ocean",
"Mesa_ocean",
"StoneBeach_ocean",
"Plains_deep_ocean",
"JungleEdge_deep_ocean",
"SavannaM_deep_ocean",
"Desert_deep_ocean",
"Mesa_deep_ocean",
"ColdTaiga_deep_ocean",
"Plains_ocean",
"MesaPlateauFM_ocean",
"Forest_deep_ocean",
"JungleM_deep_ocean",
"FlowerForest_deep_ocean",
"MegaTaiga_ocean",
"StoneBeach_deep_ocean",
"IcePlainsSpikes_deep_ocean",
"ColdTaiga_ocean",
"SavannaM_ocean",
"MesaPlateauF_deep_ocean",
"MesaBryce_deep_ocean",
"ExtremeHills+_deep_ocean",
"ExtremeHills_ocean",
"Forest_ocean",
"MegaTaiga_deep_ocean",
"JungleEdge_ocean",
"MesaBryce_ocean",
"MegaSpruceTaiga_ocean",
"ExtremeHills+_ocean",
"Jungle_ocean",
"RoofedForest_deep_ocean",
"IcePlains_ocean",
"FlowerForest_ocean",
"ExtremeHills_deep_ocean",
"MesaPlateauFM_deep_ocean",
"Desert_ocean",
"Taiga_ocean",
"BirchForestM_deep_ocean",
"Taiga_deep_ocean",
"JungleM_ocean",
"FlowerForest_underground",
"JungleEdge_underground",
"StoneBeach_underground",
"MesaBryce_underground",
"Mesa_underground",
"RoofedForest_underground",
"Jungle_underground",
"Swampland_underground",
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
"ColdTaiga_underground",
"IcePlains_underground",
"IcePlainsSpikes_underground",
"MegaTaiga_underground",
"Taiga_underground",
"ExtremeHills+_underground",
"JungleM_underground",
"ExtremeHillsM_underground",
"JungleEdgeM_underground",
},
0,
7,
20,
1000,
2,
mcl_vars.mg_overworld_min,
mcl_vars.mg_overworld_max)

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:stalker", S("Stalker"), "#0da70a", "#000000", 0)
minetest.register_alias("mobs_mc:creeper", "mobs_mc:stalker")
mcl_mobs.register_egg("mobs_mc:stalker_overloaded", S("Overloaded Stalker"), "#00a77a", "#000000", 0)
