--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### STALKER
--###################


local function get_texture(self)
	local on_name = self.standing_on
	local texture
	local texture_suff = ""
	if on_name and on_name ~= "air" then
		local tiles = minetest.registered_nodes[on_name].tiles
		if tiles then
			local tile = tiles[1]
			local color
			if type(tile) == "table" then
				texture = tile.name or tile.image
				if tile.color then
					color = minetest.colorspec_to_colorstring(tile.color)
				end
			elseif type(tile) == "string" then
				texture = tile
			end
			if not color then
				color = minetest.colorspec_to_colorstring(minetest.registered_nodes[on_name].color)
			end
			if color then
				texture_suff = "^[multiply:" .. color .. "^[hsl:0:0:20"
			end
		end
	end
	if not texture then
		texture = "vl_stalker_default.png"
	end
	texture = "([combine:16x24:0,0=" .. texture .. ":0,16=" .. texture .. texture_suff
	if self.attack then
		texture = texture .. ")^vl_mobs_stalker_overlay_angry.png"
	else
		texture = texture .. ")^vl_mobs_stalker_overlay.png"
	end
	return texture
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
	bone_eye_height = 2.35,
	head_eye_height = 1.8;
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
		self.object:set_properties({textures={get_texture(self)}})
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
})

mcl_mobs.register_mob("mobs_mc:stalker_charged", {
	description = S("Charged Stalker"),
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
		"vl_stalker_charge.png"},
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
		self.object:set_properties({textures={get_texture(self), "vl_stalker_charge.png"}})
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
		 mcl_util.replace_mob(self.object, "mobs_mc:stalker_charged")
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
	--Having trouble when fire is placed with lightning
	fire_resistant = true,
	glow = 3,
})

-- compat
minetest.register_entity("mobs_mc:creeper", {
	on_activate = function(self, staticdata, dtime)
		local obj = minetest.add_entity(self.object:get_pos(), "mobs_mc:stalker", staticdata)
		obj:set_properties({
			visual_size = {x=2, y=2},
			mesh = "vl_stalker.b3d",
			textures = {
				{get_texture({}),
				"mobs_mc_empty.png"},
			},
		})
		self.object:remove()
	end,
})
minetest.register_entity("mobs_mc:creeper_charged", {
	on_activate = function(self, staticdata, dtime)
		local obj = minetest.add_entity(self.object:get_pos(), "mobs_mc:stalker_charged", staticdata)
		obj:set_properties({
			visual_size = {x=2, y=2},
			mesh = "vl_stalker.b3d",
			textures = {
				{get_texture({}),
				"vl_stalker_charge.png"},
			},
		})
		self.object:remove()
	end,
})

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
