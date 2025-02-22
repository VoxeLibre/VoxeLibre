local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
-- Future biomes API, work in progress
vl_biomes = {}

vl_biomes.overworld_min = mcl_vars.mg_overworld_min
vl_biomes.overworld_max = mcl_vars.mg_overworld_max
vl_biomes.nether_min = mcl_vars.mg_nether_min
vl_biomes.lava_nether_max = mcl_vars.mg_lava_nether_max
vl_biomes.nether_deco_max = mcl_vars.mg_nether_deco_max
vl_biomes.nether_max = mcl_vars.mg_nether_max
vl_biomes.end_min = mcl_vars.mg_end_min
vl_biomes.end_max = mcl_vars.mg_end_max

vl_biomes.OCEAN_MIN = -15
vl_biomes.DEEP_OCEAN_MAX = vl_biomes.OCEAN_MIN - 1
vl_biomes.DEEP_OCEAN_MIN = -31

--- sky, fog and water colors
vl_biomes.skycolor = {}
vl_biomes.fogcolor = {}

vl_biomes.fogcolor.overworld = "#C0D8FF"
vl_biomes.skycolor.beach = "#78A7FF" -- This is the case for all beach biomes except for the snowy ones! Those beaches will have their own colour instead of this one. Also used by plains biomes
vl_biomes.skycolor.ocean = "#7BA4FF" -- This is the case for all ocean biomes except for non-deep frozen oceans! Those oceans will have their own colour instead of this one.
vl_biomes.skycolor.icy = "#7FA1FF" -- Sky in icy biomes
vl_biomes.skycolor.jungle = "#77A8FF" -- Sky in jungle and bamboo jungle biomes
vl_biomes.skycolor.taiga = "#7DA2FF" -- Sky in most taiga biomes

vl_biomes.skycolor.nether = "#6EB1FF" -- The Nether biomes seemingly don't use the sky colour, despite having this value according to the wiki. The fog colour is used for both sky and fog.

vl_biomes.skycolor["end"] = "#000000"
vl_biomes.fogcolor["end"] = "#A080A0" -- The End biomes seemingly don't use the fog colour, despite having this value according to the wiki. The sky colour is used for both sky and fog.

-- Colors of underwater fog effect, defaults for temperatures
-- Swamp and Mangrove Swamp differ
vl_biomes.waterfogcolor = { warm = "#43D5EE", lukewarm = "#45ADF2", ocean = "#3F76E4", cold = "#3D57D6", frozen = "#3938C9" }

-- TODO: use these, right now this is just for reference
-- Grass palette map (for reference)
vl_biomes.grass_palettes = {
	plains = 0,
	savanna = 1,
	snowy_plains_spikes = 2,
	snowy_taiga = 3,
	taiga_old_pine = 4,
	taiga_old_spruce = 5,
	windswepthills = 6,
	windswepthills_gravelly = 7,
	windswepthills_forest = 8,
	stonebeach = 9,
	snowy_plains = 10,
	plains_sunflower = 11,
	taiga = 12,
	forest = 13,
	forest_flower = 14,
	birchforest = 15,
	birchforest_old = 16,
	desert = 17,
	dark_forest = 18,
	badlands = 19,
	badlands_eroded = 20,
	badlands_wooded = 21,
	badlands_wooded_mod = 22,
	savanna_windswept = 23,
	bamboojungle = 24,
	jungle = 24,
	bamboojungle = 24,
	jungle_modified = 25,
	bamboojungle_modified = 25,
	jungle_edge = 26,
	bamboojungle_edge = 26,
	jungle_modified_edge = 27,
	bamboojungle_modified_edge = 27,
	mangroveswamp = 27,
	swampland = 28,
	mushroomisland = 29
}
-- Foliage palette map (for reference)
vl_biomes.foliage_palette = {
	plains = 1,
	snowy_plains = 2,
	snowy_taiga = 2,
	desert = 3,
	savanna = 3,
	badlands = 4,
	swampland = 5,
	mangroveswamp = 6,
	forest = 7,
	dark_forest = 7,
	birchforest = 8,
	taiga = 10,
	taiga_old_pine = 9,
	taiga_old_spruce = 10,
	stonebeach = 11,
	windswepthills = 11,
	jungle = 12,
	bamboojungle = 12,
	jungle_edge = 13,
	bamboojungle_edge = 13,
	-- FIXME: unused: 14,15
	snowy_taiga_beach = 16, -- FIXME: only beach?
	mushroomisland = 17,
}
-- Water palettes map
vl_biomes.water_palette = {
	plains = 0,
	forest = 0,
	birchforest = 0,
	mushroomisland = 0,
	swampland = 1,
	jungle = 2,
	bamboojungle = 2,
	savanna = 2,
	badlands = 3,
	desert = 3,
	stonebeach = 4,
	taiga = 4,
	windswepthills = 4,
	snowy = 5,
	-- FIXME: unused: 6
	mangroveswamp = 7,
}

local mg_name = core.get_mapgen_setting("mg_name")
local superflat = mg_name == "flat" and core.get_mapgen_setting("mcl_superflat_classic") == "true"

-- Biomes by water temperature, for decorations and structures
vl_biomes.by_water_temp = {}
vl_biomes.overworld_biomes = {}
-- TODO: also add a list of nether and end biomes

-- Register a biome
-- This API has a few extensions over core.register_biome:
--
-- - _mcl_skycolor affects sky color
-- - _mcl_waterfogcolor affects sky color depending on weather
-- - _mcl_biome_type = "snowy", "cold", "medium" or "hot" affects weather
-- - _mcl_foliage_palette_index affects tree colors
-- - _mcl_grass_palette_index affects grass color
-- - _mcl_water_palette_index affects water color
-- - some default values
-- - subbiomes that inherit from defaults or their parents
--
-- TODO: add a "_mcl_world" parameter to set defaults for y_min, y_max, and ensure bounds?
-- TODO: switch to "_vl" prefix?
function vl_biomes.register_biome(def)
	local is_overworld = (def.y_min or def.min_pos.y) >= vl_biomes.overworld_min - 5 and (def.y_max or def.max_pos.y) <= vl_biomes.overworld_max + 5
	local sub = def._vl_subbiomes or {}
	if is_overworld then
		-- some defaults:
		def._mcl_fogcolor = def._mcl_fogcolor or vl_biomes.fogcolor.overworld
		if sub.beach then
			sub.beach._mcl_skycolor = sub.beach._mcl_skycolor or vl_biomes.skycolor.beach
		end
		if sub.ocean then
			local odef = sub.ocean
			odef._mcl_skycolor = odef._mcl_skycolor or vl_biomes.skycolor.ocean
			odef._mcl_water_temp = odef._mcl_water_temp or def._mcl_water_temp or "ocean"
			odef._mcl_waterfogcolor = odef._mcl_waterfogcolor or def._mcl_waterfogcolor or vl_biomes.waterfogcolor[odef._mcl_water_temp]
			if not odef.min_pos then odef.y_min = odef.y_min or vl_biomes.OCEAN_MIN end
			if not odef.max_pos then odef.y_max = odef.y_max or 0 end
			odef._mcl_foliage_palette_index = odef._mcl_foliage_palette_index or 0
		end
		-- add deep ocean automatically
		if sub.ocean and sub.deep_ocean == nil then
			-- TODO: what if min_pos/max_pos are set?
			sub.deep_ocean = {
				y_min = vl_biomes.DEEP_OCEAN_MIN,
				y_max = vl_biomes.DEEP_OCEAN_MAX,
				node_top = sub.ocean.node_top or def.node_top,
				depth_top = 2,
				node_filler = sub.ocean.node_filler or def.node_filler,
				depth_filler = 3,
				node_riverbed = sub.ocean.node_riverbed or def.node_riverbed,
				depth_riverbed = 2,
				vertical_blend = 5,
				_mcl_foliage_palette_index = 0, -- to avoid running the foliage fix
				_mcl_skycolor = vl_biomes.skycolor.ocean,
				_mcl_waterfogcolor = sub.ocean._mcl_waterfogcolor,
			}
		end
		-- Underground biomes are used to identify the underground and to prevent nodes from the surface
		-- (sand, dirt) from leaking into the underground.
		if sub.underground == nil then
			-- TODO: y_min, y_max only if not min_pos, max_pos
			sub.underground = {
				node_dust = "",
				depth_top = 0,
				depth_filler = 0,
				node_stone = "mcl_core:stone", -- reset to stone
				y_min = vl_biomes.overworld_min,
				y_max = vl_biomes.DEEP_OCEAN_MIN - 1,
			}
		end
	end
	-- subbiomes
	for k, sdef in pairs(sub) do
		sdef.name = sdef.name or (def.name .. "_" .. k)
		-- merge from parent
		for k2, v2 in pairs(def) do
			if k2 ~= "_vl_subbiomes" and sdef[k2] == nil then
				sdef[k2] = v2
			end
		end
		-- build a biome lookup map based on water temperature
		-- TODO: make this a biome.groups mechanism
		if k == "ocean" and sdef._mcl_water_temp then
			local temp = sdef._mcl_water_temp
			vl_biomes.by_water_temp[temp] = vl_biomes.by_water_temp[temp] or {}
			table.insert(vl_biomes.by_water_temp[temp], sdef.name)
		end
	end
	core.register_biome(def)
	if is_overworld and def.y_max > 0 then table.insert(vl_biomes.overworld_biomes, def.name) end
	for _, sdef in pairs(sub) do
		core.register_biome(sdef)
		if is_overworld and sdef.y_max > 0 then -- omit ocean
			table.insert(vl_biomes.overworld_biomes, sdef.name)
		end
	end
end

-- TODO: also add similar helper as below for oaks?

-- helper for spruce decorations
function vl_biomes.register_spruce_decoration(seed, offset, sprucename, biomes, y_min)
	local mod_mcl_core = core.get_modpath("mcl_core")
	mcl_mapgen_core.register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block", "mcl_core:dirt", "mcl_core:podzol"},
		sidelen = 16,
		noise_params = {
			offset = offset,
			scale = 0.0006,
			spread = vector.new(250, 250, 250),
			seed = seed,
			octaves = 3,
			persist = 0.66
		},
		biomes = biomes,
		y_min = y_min or 1,
		y_max = vl_biomes.overworld_max,
		schematic = mod_mcl_core .. "/schematics/" .. sprucename,
		flags = "place_center_x, place_center_z",
		-- not supported by spruceleaves: _mcl_foliage_palette_index = foliage_color,
	})
end

--
-- Detect mapgen to select functions
--
if mg_name == "singlenode" then
	-- nothing in singlenode
elseif superflat then
	-- Implementation of Minecraft's Superflat mapgen, classic style:
	-- * Perfectly flat land, 1 grass biome, no decorations, no caves
	-- * 4 layers, from top to bottom: grass block, dirt, dirt, bedrock
	core.clear_registered_biomes()
	core.clear_registered_decorations()
	core.clear_registered_schematics()
	-- Classic Superflat: bedrock (not part of biome), 2 dirt, 1 grass block
	vl_biomes.register_biome({
		name = "flat",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_stone = "mcl_core:dirt",
		y_min = mcl_vars.mg_overworld_min - 512,
		y_max = mcl_vars.mg_overworld_max,
		humidity_point = 50,
		heat_point = 50,
		_mcl_biome_type = "medium",
		_mcl_grass_palette_index = 0,
		_mcl_foliage_palette_index = 1,
		_mcl_water_palette_index = 0,
		_mcl_watertemp = "ocean",
		_mcl_waterfogcolor = vl_biomes.waterfogcolor.ocean,
		_mcl_skycolor = "#78A7FF",
		_mcl_fogcolor = vl_biomes.fogcolor.overworld
	})
elseif mg_name ~= "v6" then
	-- OVERWORLD biomes
	--[[ These biomes try to resemble MC. This means especially the floor cover and the type of
	plants and structures (shapes might differ). The terrain itself will be of course different and
	depends on the mapgen.
	Important: MC also takes the terrain into account while Luanti biomes so far don't care about the
	terrain at all (except height).
	MC has many “M” and “Hills” variants, most of which only differ in terrain compared to their original
	counterpart.
	In Luanti, any biome can occour in any terrain, so these variants are implied and are therefore
	not explicitly implmented in VL. “M” variants are only included if they have another unique feature,
	such as a different land cover.
	In VL, the MC Overworld biomes are split in multiple more parts (stacked by height):
	* The main part, this represents the land. It begins at around sea level and usually goes all the way up
	* ocean: For the area covered by ocean water. The y_max may vary for various beach effects.
	          Has sand or dirt as floor.
	* deep_ocean: Like ocean, but deeper and has gravel as floor
	* underground:
	* Other modifiers: Some complex biomes require more layers to improve the landscape.

	The following naming conventions apply:
	* The land biome name is equal to the MC biome name, as of Minecraft 1.11 (in camel case)
	* Height modifiers and sub-biomes are appended with underscores and in lowercase. Example: “_ocean”
	* Non-MC biomes are written in lowercase
	* MC dimension biomes are named after their MC dimension

	Intentionally missing biomes:
	* River (generated by valleys and v7)
	* Frozen River (generated by valleys and v7)
	* Hills biomes (shape only)
	* Plateau (shape only)
	* Plateau M (shape only)
	* Cold Taiga M (mountain only)
	* Taiga M (mountain only)
	* Roofed Forest M (mountain only)
	* Swampland M (mountain only)
	* Extreme Hills Edge (unused in MC)

	TODO:
	* Better beaches
	* Improve Extreme Hills M
	* Desert M (desert lakes - removed?)
	]]

	dofile(modpath.."/plains.lua")
	dofile(modpath.."/plains_sunflower.lua")
	dofile(modpath.."/savanna.lua")
	dofile(modpath.."/savanna_windswept.lua")
	dofile(modpath.."/desert.lua")
	-- missing: Meadow, similar to Plains?

	dofile(modpath.."/forest.lua")
	dofile(modpath.."/forest_flower.lua")
	dofile(modpath.."/birchforest.lua")
	dofile(modpath.."/birchforest_old.lua")
	dofile(modpath.."/taiga.lua")
	dofile(modpath.."/taiga_old_pine.lua")
	dofile(modpath.."/taiga_old_spruce.lua")
	dofile(modpath.."/dark_forest.lua")
	-- missing: Cherry Grove

	-- missing: Frozen Peaks -- just a matter of shape?
	-- missing: Grove, but how does it differ from snowy taiga?
	-- missing: Jagged Peaks -- just a matter of shape?
	dofile(modpath.."/snowy_taiga.lua")
	dofile(modpath.."/snowy_plains.lua")
	dofile(modpath.."/snowy_plains_spikes.lua")
	-- missing: Snowy Slopes -- just a matter of shape?

	dofile(modpath.."/badlands.lua")
	dofile(modpath.."/badlands_eroded.lua")
	dofile(modpath.."/badlands_wooded.lua")
	dofile(modpath.."/badlands_wooded_mod.lua")
	dofile(modpath.."/badlands-strata.lua") -- shared, nst come AFTER the badlands biomes

	dofile(modpath.."/jungle.lua")
	dofile(modpath.."/jungle_edge.lua")
	dofile(modpath.."/jungle_modified.lua")
	dofile(modpath.."/jungle_modified_edge.lua")

	dofile(modpath.."/bamboojungle.lua")
	dofile(modpath.."/bamboojungle_edge.lua")
	dofile(modpath.."/bamboojungle_modified.lua")
	dofile(modpath.."/bamboojungle_modified_edge.lua")

	dofile(modpath.."/swampland.lua")
	dofile(modpath.."/mangroveswamp.lua")
	dofile(modpath.."/mushroomisland.lua")

	dofile(modpath.."/stonebeach.lua")
	dofile(modpath.."/windswepthills.lua")
	dofile(modpath.."/windswepthills_forest.lua")
	dofile(modpath.."/windswepthills_gravelly.lua")
	dofile(modpath.."/windswepthills-ores.lua") -- shared, must come AFTER the windswepthills biomes
	-- missing: Stony Peaks -- just a matter of shape?

	-- missing: Deep Dark
	-- missing: Dripstone Caves
	-- missing: Lush Caves

	-- Additional decorations
	dofile(modpath.."/deco/bamboo.lua")
	dofile(modpath.."/deco/boulder.lua")
	dofile(modpath.."/deco/cacti.lua")
	dofile(modpath.."/deco/corals.lua")
	dofile(modpath.."/deco/fallentree.lua")
	dofile(modpath.."/deco/fern.lua")
	dofile(modpath.."/deco/flowers.lua")
	dofile(modpath.."/deco/fossil.lua")
	dofile(modpath.."/deco/geode.lua")
	dofile(modpath.."/deco/kelp.lua")
	dofile(modpath.."/deco/lakes.lua")
	dofile(modpath.."/deco/melon.lua")
	dofile(modpath.."/deco/mushrooms.lua")
	dofile(modpath.."/deco/pumpkin.lua")
	dofile(modpath.."/deco/reeds.lua")
	dofile(modpath.."/deco/seagrass.lua")
	dofile(modpath.."/deco/snowy_dirt.lua")
	dofile(modpath.."/deco/sponges.lua")
	dofile(modpath.."/deco/sweet_berry.lua")
	dofile(modpath.."/deco/tallgrass.lua")
end
-- FIXME: did we lose any v6 support in the refactoring?

-- Non-overworld in everything except singlenode
if mg_name ~= "singlenode" then
	-- Nether biomes
	dofile(modpath.."/nether/netherwastes.lua")
	dofile(modpath.."/nether/soulsandvalley.lua")
	dofile(modpath.."/nether/crimsonforest.lua")
	dofile(modpath.."/nether/warpedforest.lua")
	dofile(modpath.."/nether/basaltdelta.lua")
	-- Shared ores across nether biomes
	dofile(modpath.."/nether/ores.lua")

	--[[ THE END ]]
	dofile(modpath.."/end/end.lua")
end
