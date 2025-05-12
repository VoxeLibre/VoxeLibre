--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

local overworld_bounds = vl_worlds.get_dimension_bounds("overworld")
assert(overworld_bounds)

local function get_texture(self, prev)
	local standing_on = minetest.registered_nodes[self.standing_on]
	-- TODO: we do not have access to param2 here (color palette index) yet
	local texture
	local texture_suff = ""
	if standing_on and (standing_on.walkable or standing_on.groups.liquid) then
		local tiles = standing_on.tiles
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
				color = minetest.colorspec_to_colorstring(standing_on.color)
			end
			if color then
				texture_suff = "^[multiply:" .. color .. "^[hsl:0:0:20"
			end
		end
	end
	if not texture or texture == "" then
		-- try to keep last texture when, e.g., falling
		if prev and (not (not self.attack)) == (string.find(prev, "vl_mobs_stalker_overlay_angry.png") ~= nil) then
			return prev
		end
		texture = "vl_stalker_default.png"
	else
		texture = texture:gsub("([\\^:\\[])", "\\%1") -- escape texture modifiers
		texture = "(vl_stalker_default.png^[combine:16x24:0,0=(" ..
			texture .. "):0,16=(" .. texture .. ")" .. texture_suff .. ")"
	end
	if self.attack then
		texture = texture .. "^vl_mobs_stalker_overlay_angry.png"
	else
		texture = texture .. "^vl_mobs_stalker_overlay.png"
	end
	return texture
end

--- Returns true if the cause of death should cause a music disc to drop.
--- @param cmi_cause {type: string?, puncher: core.ObjectRef?}?
--- @return boolean
local function should_drop_music_disc(cmi_cause)
	if not cmi_cause or cmi_cause.type ~= "punch" then
		return false
	end
	local e = cmi_cause.puncher and cmi_cause.puncher:get_luaentity()
	if not e or not e.name:find("arrow") then
		return false
	end
	local s = e._source_object and e._source_object:get_luaentity()
	if not s then
		return false
	end
	return s.name == "mobs_mc:skeleton" or s.name == "mobs_mc:stray"
end

---
---@param self
---@param clicker core.Player
local function stalker_on_rightclick(self, clicker)
	-- Force-ignite stalker with flint and steel.
	--
	if self:fuse_is_triggered() then
		-- Fuse already triggered
		self.allow_fuse_reset = false
		return
	end
	local item = clicker:get_wielded_item()
	if not item or item:get_name() ~= "mcl_fire:flint_and_steel" then
		return
	end
	self:fuse_start({ force = true })

	-- Damage player's Flint and Steel.
	-- FIXME: Move tool wear logic to a more appropriate place.
	if not minetest.is_creative_enabled(clicker:get_player_name()) then
		local wdef = item:get_definition()
		item:add_wear(1000)
		if item:get_count() == 0 and wdef.sound and wdef.sound.breaks then
			core.sound_play(wdef.sound.breaks, { pos = clicker:get_pos(), gain = 0.5 }, true)
		end
		clicker:set_wielded_item(item)
	end
end

local AURA = "vl_stalker_overloaded_aura.png"
local function get_overloaded_aura(timer)
	local frame = math.floor(timer * 16)
	local f = tostring(frame)
	local nf = tostring(16 - f)
	return "[combine:16x24:-" .. nf .. ",0=" .. AURA .. ":" .. f .. ",0=" .. AURA
end

---@class camouflage_opts
---@field aura_timer number? If provided, the stalker will have an overload aura.

---
---@param self any
---@param opts camouflage_opts?
local function stalker_camouflage(self, opts)
	local has_aura = opts and opts.aura_timer ~= nil
	local new_texture = get_texture(self, self._stalker_texture)
	
	if self._stalker_texture == new_texture and not has_aura then
		return
	end
	self._stalker_texture = new_texture

	if has_aura then
		assert(opts)
		self.object:set_properties({ textures = { new_texture, get_overloaded_aura(opts.aura_timer) } })
	else
		self.object:set_properties({ textures = { new_texture, "mobs_mc_empty.png" } })
	end
end

--- @param pos       {x: number, y: number, z: number}
--- @param cmi_cause {type: string?, puncher: core.ObjectRef?}?
local function stalker_on_die(self, pos, cmi_cause)
	if should_drop_music_disc(cmi_cause) then
		local drops = table.copy(self.drops)
		table.insert(drops, {
			name   = "mcl_jukebox:record_" .. math.random(9),
			chance = 1,
			min    = 1,
			max    = 1
		})
		self.drops = drops
	end
end

local stalker = {
	description = S("Stalker"),
	type = "monster",
	spawn_class = "hostile",
	spawn_in_group = 1,
	initial_properties = {
		hp_min = 20,
		hp_max = 20,
		collisionbox = { -0.3, -0.01, -0.3, 0.3, 1.69, 0.3 },
	},
	xp_min = 5,
	xp_max = 5,
	pathfinding = 1,
	visual = "mesh",
	mesh = "vl_stalker.b3d",
	-- 	head_swivel = "Head_Control",
	head_eye_height = 1.2,
	head_bone_position = vector.new(0, 2.35, 0), -- for minetest <= 5.8
	curiosity = 2,
	textures = { { get_texture({}), "mobs_mc_empty.png" } },
	visual_size = { x = 2, y = 2 },
	walk_velocity = 1.05,
	run_velocity = 2.0,
	runaway_from = { "mobs_mc:ocelot", "mobs_mc:cat" },
	attack_type = "explode",

	makes_footstep_sound = true,
	sounds = {
		attack = "tnt_ignite",
		death = "mobs_mc_creeper_death",
		damage = "mobs_mc_creeper_hurt",
		fuse = "tnt_ignite",
		explode = "tnt_explode",
		distance = 16,
	},

	explosion_strength = 3,
	explosion_radius = 3.5,
	explosion_damage_radius = 3.5,
	explosiontimer_reset_radius = 3,
	reach = 3,
	explosion_timer = 1.5,
	allow_fuse_reset = true,
	stop_to_explode = true,

	on_rightclick = stalker_on_rightclick,
	on_die = stalker_on_die,

	do_custom = function(self, _ --[[dtime]])
		stalker_camouflage(self)
	end,

	on_lightning_strike = function(self, _ --[[pos]], _ --[[pos2]], _ --[[objects]])
		mcl_util.replace_mob(self.object, "mobs_mc:stalker_overloaded")
		return true
	end,

	maxdrops = 2,

	drops = {
		{
			name = "mcl_mobitems:gunpowder",
			chance = 1,
			min = 0,
			max = 2,
			looting = "common",
		},
		{
			name = "mcl_heads:stalker",
			chance = 200, -- 0.5%
			min = 1,
			max = 1,
			conditions = {
				guarantee_if_killed_by = { "mobs_mc:stalker_overloaded" }
			}
		},
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
			visual_size = { x = 2, y = 2 },
			mesh = "vl_stalker.b3d",
			textures = { { get_texture({}), "mobs_mc_empty.png" }, },
		})
	end,
}

local stalker_overloaded = table.update(table.copy(stalker), {
	description = S("Overloaded Stalker"),
	textures = { { get_texture({}), AURA } },
	use_texture_alpha = true,
	explosion_strength = 6,
	explosion_radius = 8,
	explosion_damage_radius = 8,
	fire_resistant = true,
	glow = 3,
	
	---@param dtime number
	do_custom = function(self, dtime)
		--- Tick aura timer
		if not self._aura_timer or self._aura_timer > 1 then
			self._aura_timer = 0
		end
		self._aura_timer = self._aura_timer + dtime

		stalker_camouflage(self, { aura_timer = self._aura_timer })
	end,

	on_lightning_strike = function(self, pos, pos2, objects)
		mcl_util.replace_mob(self.object, "mobs_mc:stalker_overloaded")
		return true
	end,

	_on_after_convert = function(obj)
		obj:set_properties({
			visual_size = { x = 2, y = 2 },
			mesh = "vl_stalker.b3d",
			textures = { { get_texture({}), AURA } },
		})
	end,
})

mcl_mobs.register_mob("mobs_mc:stalker", stalker)
mcl_mobs.register_mob("mobs_mc:stalker_overloaded", stalker_overloaded)

mcl_mobs.register_conversion("mobs_mc:creeper", "mobs_mc:stalker")
mcl_mobs.register_conversion("mobs_mc:creeper_charged", "mobs_mc:stalker_overloaded")

mcl_mobs:spawn_setup({
	name = "mobs_mc:stalker",
	dimension = "overworld",
	type_of_spawning = "ground",
	biomes = {
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
		"BambooJungle",
		"BambooJungleM",
		"BambooJungleEdge",
		"BambooJungleEdgeM",
		"BambooJungle_underground",
		"BambooJungleM_underground",
		"BambooJungleEdge_underground",
		"BambooJungleEdgeM_underground",
		"BambooJungle_ocean",
		"BambooJungleM_ocean",
		"BambooJungleEdge_ocean",
		"BambooJungleEdgeM_ocean",
		"BambooJungle_deep_ocean",
		"BambooJungleM_deep_ocean",
		"BambooJungleEdge_deep_ocean",
		"BambooJungleEdgeM_deep_ocean",
		"BambooJungle_shore",
		"BambooJungleM_shore",
		"BambooJungleEdge_shore",
		"BambooJungleEdgeM_shore",
	},
	min_light = 0,
	max_light = 7,
	chance = 400,
	soft_cap = 5,
	interval = 20,
	aoc = 2,
	min_height = overworld_bounds.min,
	max_height = overworld_bounds.max,
})

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:stalker", S("Stalker"), "#0da70a", "#000000", 0)
minetest.register_alias("mobs_mc:creeper", "mobs_mc:stalker")
mcl_mobs.register_egg("mobs_mc:stalker_overloaded", S("Overloaded Stalker"), "#00a77a", "#000000", 0)
