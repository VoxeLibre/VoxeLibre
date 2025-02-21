local modpath = minetest.get_modpath(minetest.get_current_modname())

mcl_structures.register_structure("ice_spike_small",{
	filenames = { modpath.."/schematics/mcl_structures_ice_spike_small.mts"	},
},true) --is spawned as a normal decoration. this is just for /spawnstruct
mcl_structures.register_structure("ice_spike_large",{
	sidelen = 6,
	filenames = { modpath.."/schematics/mcl_structures_ice_spike_large.mts"	},
},true) --is spawned as a normal decoration. this is just for /spawnstruct

