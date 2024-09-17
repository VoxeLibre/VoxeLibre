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
mcl_structures.place_schematic = function(pos, schematic, rotation, replacements, force_placement, flags, after_placement_callback, pr, callback_param)
	vl_structures.place_schematic(pos, yoffset, schematic, rotation, {
		replacements = replacements,
		force_placement = force_placement,
		flags = flags,
		after_place = after_placement_callback,
		callback_param = callback_param
	}, pr)
end
mcl_structures.place_structure = vl_structures.place_structure -- still compatible
mcl_structures.register_structure = function(name, def, nospawn)
	-- nospawn: ignored, just pass no place_on!
	if not def.solid_ground then def.prepare = def.prepare or {} end
	vl_structures.register_structure(name, def)
end

dofile(modpath.."/campsite.lua")
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
dofile(modpath.."/spider_cocoon.lua")
dofile(modpath.."/witch_hut.lua")
dofile(modpath.."/woodland_mansion.lua")

vl_structures.register_structure("boulder",{
	-- as they have no place_on, they will not be spawned by this mechanism. this is just for /spawnstruct
	filenames = {
		-- small boulder 3x as likely
		modpath.."/schematics/mcl_structures_boulder_small.mts",
		modpath.."/schematics/mcl_structures_boulder_small.mts",
		modpath.."/schematics/mcl_structures_boulder_small.mts",
		modpath.."/schematics/mcl_structures_boulder.mts",
	},
})

vl_structures.register_structure("ice_spike_small",{
	-- as they have no place_on, they will not be spawned by this mechanism. this is just for /spawnstruct
	filenames = { modpath.."/schematics/mcl_structures_ice_spike_small.mts" },
})

vl_structures.register_structure("ice_spike_large",{
	-- as they have no place_on, they will not be spawned by this mechanism. this is just for /spawnstruct
	filenames = { modpath.."/schematics/mcl_structures_ice_spike_large.mts" },
})

