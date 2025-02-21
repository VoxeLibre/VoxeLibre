local modpath = minetest.get_modpath(minetest.get_current_modname())

mcl_structures = {}

-- some legacy API adapters
mcl_structures.is_disabled = function() return false end
mcl_structures.init_node_construct = vl_structures.construct_node
mcl_structures.construct_nodes = vl_structures.construct_nodes
mcl_structures.fill_chests = vl_structures.fill_chests
mcl_structures.spawn_mobs = vl_structures.spawn_mobs

mcl_structures.place_schematic = function(pos, schematic, rotation, replacements, force_placement, flags, after_placement_callback, pr, callback_param)
	-- Replace old PseudoRandom with PcgRandom
	if not pr.rand_normal_dist then pr = PcgRandom(pr:next() + pr:next() * 32768) end
	vl_structures.place_schematic(pos, yoffset, schematic, rotation, {
		replacements = replacements,
		force_placement = force_placement,
		flags = flags,
		after_place = function(pos,def,pr,pmin,pmax,size,rotation) after_placement_callback(pmin,pmax,size,rotation,pr) end,
		callback_param = callback_param
	}, pr)
end
mcl_structures.place_structure = vl_structures.place_structure -- still compatible
mcl_structures.register_structure = function(name, def, nospawn)
	def.name = def.name or name
	if not def.solid_ground then def.prepare = def.prepare or {} end
	-- nospawn: ignored, just do not set place_on!
	vl_structures.register_structure(name, def)
end
-- TODO: provide more legacy adapters that translate parameters?

dofile(modpath.."/desert_temple.lua")
dofile(modpath.."/desert_well.lua")
dofile(modpath.."/end_city.lua")
dofile(modpath.."/end_spawn.lua")
dofile(modpath.."/igloo.lua")
dofile(modpath.."/jungle_temple.lua")
dofile(modpath.."/ocean_ruins.lua")
dofile(modpath.."/ocean_temple.lua")
dofile(modpath.."/pillager_outpost.lua")
dofile(modpath.."/ruined_portal.lua")
dofile(modpath.."/shipwrecks.lua")
dofile(modpath.."/witch_hut.lua")
dofile(modpath.."/woodland_mansion.lua")

