local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
-- Future biomes API, work in progress
vl_biomes = {}

vl_biomes.overworld_fogcolor = "#C0D8FF"
vl_biomes.beach_skycolor = "#78A7FF" -- This is the case for all beach biomes except for the snowy ones! Those beaches will have their own colour instead of this one.
vl_biomes.ocean_skycolor = "#7BA4FF" -- This is the case for all ocean biomes except for non-deep frozen oceans! Those oceans will have their own colour instead of this one.

vl_biomes.nether_skycolor = "#6EB1FF" -- The Nether biomes seemingly don't use the sky colour, despite having this value according to the wiki. The fog colour is used for both sky and fog.

vl_biomes.end_skycolor = "#000000"
vl_biomes.end_fogcolor = "#A080A0" -- The End biomes seemingly don't use the fog colour, despite having this value according to the wiki. The sky colour is used for both sky and fog.

-- Colors of underwater fog effect, defaults for temperatures
-- Swamp and Mangrove Swamp differ
local waterfogcolor = { warm = "#43D5EE", lukewarm = "#45ADF2", ocean = "#3F76E4", cold = "#3D57D6", frozen = "#3938C9" }

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

local mg_name = minetest.get_mapgen_setting("mg_name")
local superflat = mg_name == "flat" and minetest.get_mapgen_setting("mcl_superflat_classic") == "true"

-- Biomes by water temperature, for decorations and structures
vl_biomes.by_water_temp = {}
vl_biomes.overworld_biomes = {}
-- TODO: also add a list of nether and end biomes

-- Fix the grass color via decoration mechanism,
-- by replacing node_top with node_top and param2 set
-- TODO: this can be removed when param2 support to biomes is added
-- <https://github.com/minetest/minetest/issues/15319>
vl_biomes.fix_grass_color = function(def)
	if (def._mcl_grass_palette_index or 0) == 0 then return end -- not necessary
	-- for now, only support node_top.
	local name = def.node_top
	local ndef = minetest.registered_nodes[name]
	if ndef and (ndef.groups.grass_palette or 0) ~= 0 and ndef.paramtype2 == "color" then -- no mixed types
		local param2 = def._mcl_grass_palette_index
		mcl_mapgen_core.register_decoration({
			name = "Set "..name.." param2 in "..def.name,
			rank = 10, -- run early to not modify other decorations
			deco_type = "simple",
			place_on = {name},
			biomes = { def.name },
			y_min = def.y_min or vl_biomes.overworld_min,
			y_max = def.y_max or vl_biomes.overworld_max,
			fill_ratio = 10, -- everything
			decoration = name,
			param2 = param2,
			flags = "force_placement",
			place_offset_y = -1, -- replace the node itself
		})
	end
end

-- Register a biome
-- This API has a few extensions over minetest.register_biome:
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
vl_biomes.register_biome = function(def)
	local is_overworld = (def.y_min or def.min_pos.y) >= vl_biomes.overworld_min - 5 and (def.y_max or def.max_pos.y) <= vl_biomes.overworld_max + 5
	if is_overworld then
		-- some defaults:
		if def._mcl_fogcolor == nil then def._mcl_fogcolor = vl_biomes.overworld_fogcolor end
		if def._beach and def._beach._mcl_skycolor == nil then def._beach._mcl_skycolor = vl_biomes.beach_skycolor end
		if def._ocean then
			local odef = def._ocean
			if odef._mcl_skycolor == nil then odef._mcl_skycolor = vl_biomes.ocean_skycolor end
			if odef._mcl_water_temp == nil or odef._mcl_water_temp == "default" then odef._mcl_water_temp = "ocean" end
			if odef._mcl_waterfogcolor == nil then odef._mcl_waterfogcolor = waterfogcolor[odef._mcl_water_temp] end
			if odef.y_min == nil and not odef.min_pos then odef.y_min = vl_biomes.OCEAN_MIN end
			if odef.y_max == nil and not odef.max_pos then odef.y_max = 0 end
			if odef._mcl_foliage_palette_index == nil then odef._mcl_foliage_palette_index = 0 end -- no param2 updates
		end
		-- add deep ocean automatically
		if def._deep_ocean == nil then
			-- TODO: y_min, y_max only if not min_pos, max_pos
			def._deep_ocean = {
				y_min = vl_biomes.DEEP_OCEAN_MIN,
				y_max = vl_biomes.DEEP_OCEAN_MAX,
				node_top = def._ocean.node_top or def.node_top,
				depth_top = 2,
				node_filler = def._ocean.node_filler or def.node_filler,
				depth_filler = 3,
				node_riverbed = def._ocean.node_riverbed or def.node_riverbed,
				depth_riverbed = 2,
				vertical_blend = 5,
				_mcl_foliage_palette_index = 0, -- to avoid running the foliage fix
				_mcl_skycolor = vl_biomes.ocean_skycolor,
			}
		end
		-- Underground biomes are used to identify the underground and to prevent nodes from the surface
		-- (sand, dirt) from leaking into the underground.
		if def._underground == nil then
			-- TODO: y_min, y_max only if not min_pos, max_pos
			def._underground = {
				node_top = def._ocean.node_top or def.node_top,
				depth_top = 2,
				node_filler = def._ocean.node_filler or def.node_filler,
				depth_filler = 3,
				node_riverbed = def._ocean.node_riverbed or def.node_riverbed,
				depth_riverbed = 2,
				y_min = vl_biomes.overworld_min,
				y_max = vl_biomes.DEEP_OCEAN_MIN - 1,
			}
		end
	end
	-- subbiomes
	local subbiomes = {}
	for k, sdef in pairs(def) do
		-- currently, all _tables are subbiomes
		-- TODO: more precise check, or use _subbiomes = {}?
		if k:sub(1,1) == "_" and type(sdef) == "table" then
			-- subbiome name
			if not sdef.name then sdef.name = def.name .. k end
			-- merge from parent
			for k2, v2 in pairs(def) do
				if type(v2) ~= "table" and sdef[k2] == nil then
					sdef[k2] = v2
				end
			end
			table.insert(subbiomes, sdef)
			def[k] = nil -- remove
		end
		-- build a biome map based on water temperature
		if k == "_ocean" and sdef._mcl_water_temp then
			local temp = sdef._mcl_water_temp
			if not vl_biomes.by_water_temp[temp] then vl_biomes.by_water_temp[temp] = {} end
			table.insert(vl_biomes.by_water_temp[temp], sdef.name)
		end
	end
	minetest.register_biome(def)
	if is_overworld and def.y_max > 0 then table.insert(vl_biomes.overworld_biomes, def.name) end
	vl_biomes.fix_grass_color(def)
	-- minetest.log("action", "registering biome "..tostring(def.name))
	for _, sdef in ipairs(subbiomes) do
		-- minetest.log("action", "registering subbiome "..tostring(sdef.name))
		minetest.register_biome(sdef)
		if is_overworld and sdef.y_max > 0 then -- omit _ocean
			table.insert(vl_biomes.overworld_biomes, sdef.name)
		end
		vl_biomes.fix_grass_color(sdef) -- usually a no-op
	end
end

-- helper for spruce decorations
function vl_biomes.register_spruce_decoration(seed, offset, sprucename, biomes, y_min)
	local mod_mcl_core = minetest.get_modpath("mcl_core")
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
	minetest.clear_registered_biomes()
	minetest.clear_registered_decorations()
	minetest.clear_registered_schematics()
	-- Classic Superflat: bedrock (not part of biome), 2 dirt, 1 grass block
	minetest.register_biome({
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
		_mcl_waterfogcolor = waterfogcolor["ocean"],
		_mcl_skycolor = "#78A7FF",
		_mcl_fogcolor = vl_biomes.overworld_fogcolor
	})
elseif mg_name ~= "v6" then
	-- OVERWORLD biomes
	--[[ These biomes try to resemble MC. This means especially the floor cover and the type of
	plants and structures (shapes might differ). The terrain itself will be of course different and
	depends on the mapgen.
	Important: MC also takes the terrain into account while MT biomes so far don't care about the
	terrain at all (except height).
	MC has many “M” and “Hills” variants, most of which only differ in terrain compared to their original
	counterpart.
	In MT, any biome can occour in any terrain, so these variants are implied and are therefore
	not explicitly implmented in MCL2. “M” variants are only included if they have another unique feature,
	such as a different land cover.
	In MCL2, the MC Overworld biomes are split in multiple more parts (stacked by height):
	* The main part, this represents the land. It begins at around sea level and usually goes all the way up
	* _ocean: For the area covered by ocean water. The y_max may vary for various beach effects.
	          Has sand or dirt as floor.
	* _deep_ocean: Like _ocean, but deeper and has gravel as floor
	* _underground:
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
	dofile(modpath.."/badlands-strata.lua") -- not a biome, but shared code that needs to be last

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
	-- missing: Stony Peaks -- just a matter of shape?

	-- missing: Deep Dark
	-- missing: Dripstone Caves
	-- missing: Lush Caves

	-- Additional decorations
	dofile(modpath.."/deco/bamboo.lua")
	dofile(modpath.."/deco/cacti.lua")
	dofile(modpath.."/deco/corals.lua")
	dofile(modpath.."/deco/fern.lua")
	dofile(modpath.."/deco/flowers.lua")
	dofile(modpath.."/deco/mushrooms.lua")
	dofile(modpath.."/deco/pumpkin.lua")
	dofile(modpath.."/deco/reeds.lua")
	dofile(modpath.."/deco/seagrass_kelp.lua")
	dofile(modpath.."/deco/snowy_dirt.lua")
	dofile(modpath.."/deco/sweet_berry.lua")
	dofile(modpath.."/deco/tallgrass.lua")
end
-- FIXME: add back some v6 support?

-- Non-overworld in everything except singlenode
if mg_name ~= "singlenode" then
	--[[ THE NETHER ]]
	-- the following decoration is a hack to cover exposed bedrock in netherrack - be careful
	-- not to put any ceiling decorations in a way that would apply to this
	-- (they would get generated regardless of biome)
	mcl_mapgen_core.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:bedrock"},
		sidelen = 16,
		fill_ratio = 10,
		y_min = vl_biomes.lava_nether_max,
		y_max = vl_biomes.nether_max + 15,
		height = 6,
		max_height = 10,
		decoration = "mcl_nether:netherrack",
		flags = "all_ceilings",
		param2 = 0,
	})
	mcl_mapgen_core.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:bedrock"},
		sidelen = 16,
		fill_ratio = 10,
		y_min = vl_biomes.nether_min - 10,
		y_max = vl_biomes.lava_nether_max,
		height = 7,
		max_height = 14,
		decoration = "mcl_nether:netherrack",
		flags = "all_floors,force_placement",
		param2 = 0,
	})

	-- Nether biomes
	dofile(modpath.."/nether/netherwastes.lua")
	dofile(modpath.."/nether/soulsandvalley.lua")
	dofile(modpath.."/nether/crimsonforest.lua")
	dofile(modpath.."/nether/warpedforest.lua")
	dofile(modpath.."/nether/basaltdelta.lua")
	-- Sahred ores across nether biomes
	dofile(modpath.."/nether/ores.lua")

	--[[ THE END ]]
	dofile(modpath.."/end/end.lua")
end

