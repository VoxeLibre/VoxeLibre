local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local chance_per_chunk = 5
local random_offset    = 24435
local struct_threshold = chance_per_chunk - 1
local noise_params = {
	offset = 0,
	scale  = 1,
	spread = {
		x = 1000,
		y = 1000,
		z = 1000,
	},
	scale = 0.01,
	seed = 29313,
	octaves = 2,
	persistence = 0.7,
}

local node_list = {"mcl_core:snowblock", "mcl_core:dirt_with_grass_snow"}
local schematic = modpath.."/schematics/mcl_structures_ice_spike_large.mts"

minetest_find_nodes_in_area = minetest.find_nodes_in_area

local function place(pos, rotation, pr)
	mcl_structures.place_schematic({pos = pos, schematic = schematic, rotation = rotation, pr = pr})
end

local function is_place_ok(p)
	-- Check surface
	local floor = {x=p.x+4, y=p.y-1, z=p.z+4}
	local surface = #minetest_find_nodes_in_area({x=p.x+1,y=p.y-1,z=p.z+1}, floor, node_list, false)
	if surface < 9 then return end

	-- Check for collision with spruce
	local spruce_collisions = #minetest_find_nodes_in_area({x=p.x+1,y=p.y+2,z=p.z+1}, {x=p.x+4, y=p.y+6, z=p.z+4}, {"group:tree"}, false)
	if spruce_collisions > 0 then return end

	return true
end

local def = mcl_mapgen.v6 and {
	decoration = {
		deco_type = "simple",
		place_on = node_list,
		noise_params = noise_params,
		y_min = mcl_mapgen.overworld.min,
		y_max = mcl_mapgen.overworld.max,
		height = 1,
	},
	on_finished_chunk = mcl_mapgen.v6 and function(minp, maxp, seed, vm_context, pos_list)
		local pr = PseudoRandom(seed + random_offset)
		local random_number = pr:next(1, chance_per_chunk)
		if random_number < struct_threshold then return end
		for i = 1, #pos_list do
			local pos = pos_list[i]
			if is_place_ok(pos) then
				place(pos, nil, pr)
			end
		end
	end,
} or {}
def.name = "ice_spike_large"
def.place_function = place
mcl_structures.register_structure(def)
