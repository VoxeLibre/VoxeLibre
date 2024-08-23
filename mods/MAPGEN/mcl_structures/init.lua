local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)
mcl_structures = {}

-- some legacy API adapters
mcl_structures.is_disabled = vl_structures.is_disabled
mcl_structures.init_node_construct = vl_structures.init_node_construct
mcl_structures.construct_nodes = vl_structures.construct_nodes
mcl_structures.fill_chests = vl_structures.fill_chests
mcl_structures.spawn_mobs = vl_structures.spawn_mobs

-- TODO: provide more legacy adapters that translate parameters?

dofile(modpath.."/desert_temple.lua")
dofile(modpath.."/desert_well.lua")
dofile(modpath.."/end_city.lua")
dofile(modpath.."/end_spawn.lua")
dofile(modpath.."/fossil.lua")
dofile(modpath.."/geode.lua")
dofile(modpath.."/igloo.lua")
dofile(modpath.."/jungle_temple.lua")
dofile(modpath.."/ocean_ruins.lua")
dofile(modpath.."/ocean_temple.lua")
dofile(modpath.."/pillager_outpost.lua")
dofile(modpath.."/ruined_portal.lua")
dofile(modpath.."/shipwrecks.lua")
dofile(modpath.."/witch_hut.lua")
dofile(modpath.."/woodland_mansion.lua")

vl_structures.register_structure("boulder",{
	filenames = {
		modpath.."/schematics/mcl_structures_boulder_small.mts",
		modpath.."/schematics/mcl_structures_boulder_small.mts",
		modpath.."/schematics/mcl_structures_boulder_small.mts",
		modpath.."/schematics/mcl_structures_boulder.mts",
		-- small boulder 3x as likely
	},
},true) --is spawned as a normal decoration. this is just for /spawnstruct

vl_structures.register_structure("ice_spike_small",{
	filenames = { modpath.."/schematics/mcl_structures_ice_spike_small.mts" },
},true) --is spawned as a normal decoration. this is just for /spawnstruct

vl_structures.register_structure("ice_spike_large",{
	filenames = { modpath.."/schematics/mcl_structures_ice_spike_large.mts" },
},true) --is spawned as a normal decoration. this is just for /spawnstruct

