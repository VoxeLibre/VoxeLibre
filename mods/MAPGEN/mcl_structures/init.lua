local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)

local name_prefix = "mcl_structures:"

mcl_structures = {}
local rotations = {
	"0",
	"90",
	"180",
	"270"
}
local registered_structures = {}
local use_process_mapgen_block_lvm = false
local use_process_mapgen_chunk = false
local on_finished_block_callbacks = {}
local on_finished_chunk_callbacks = {}

local noise_params = {
	offset = 0,
	scale  = 1,
	spread = {
		x = mcl_mapgen.CS_NODES,
		y = mcl_mapgen.CS_NODES,
		z = mcl_mapgen.CS_NODES,
	},
	seed = 329,
	octaves = 1,
	persistence = 0.6,
}

local perlin_noise
local get_perlin_noise_level = function(minp)
	perlin_noise = perlin_noise or minetest.get_perlin(noise_params)
	return perlin_noise:get_3d(minp)
end
mcl_structures.get_perlin_noise_level = get_perlin_noise_level

local spawnstruct_hint = S("Use /help spawnstruct to see a list of avaiable types.")

local function dir_to_rotation(dir)
	local ax, az = math.abs(dir.x), math.abs(dir.z)
	if ax > az then
		if dir.x < 0 then
			return "270"
		end
		return "90"
	end
	if dir.z < 0 then
		return "180"
	end
	return "0"
end

local function spawnstruct_function(name, param)
	local player = minetest.get_player_by_name(name)
	if not player then return end
	if param == "" then
		minetest.chat_send_player(name, S("Error: No structure type given. Please use “/spawnstruct <type>”."))
		minetest.chat_send_player(name, spawnstruct_hint)
		return
	end
	local struct = registered_structures[param]
	if not struct then
		struct = registered_structures[name_prefix .. param]
	end
	if not struct then
		minetest.chat_send_player(name, S("Error: Unknown structure type. Please use “/spawnstruct <type>”."))
		minetest.chat_send_player(name, spawnstruct_hint)
		return
	end
	local place = struct.place_function
	if not place then return end

	local pos = player:get_pos()
	if not pos then return end
	local pr = PseudoRandom(math.floor(pos.x * 333 + pos.y * 19 - pos.z + 4))
	pos = vector.round(pos)
	local dir = minetest.yaw_to_dir(player:get_look_horizontal())
	local rot = dir_to_rotation(dir)
	place(pos, rot, pr, player)
	minetest.chat_send_player(name, S("Structure placed."))
end

local function update_spawnstruct_chatcommand()
	local spawnstruct_params = ""
	for _, registered_structure in pairs(registered_structures) do
		if spawnstruct_params ~= "" then
			spawnstruct_params = spawnstruct_params .. " | "
		end
		spawnstruct_params = spawnstruct_params .. registered_structure.short_name
	end
	local def = {
		params = spawnstruct_params,
		description = S("Generate a pre-defined structure near your position."),
		privs = {debug = true},
		func = spawnstruct_function,
	}
	local registered_chatcommands = minetest.registered_chatcommands
	if registered_chatcommands["spawnstruct"] then
		minetest.override_chatcommand("spawnstruct", def)
	else
		minetest.register_chatcommand("spawnstruct", def)
	end
end

function process_mapgen_block_lvm(vm_context)
	local nodes = minetest.find_nodes_in_area(vm_context.minp, vm_context.maxp, {"group:struct"}, true)
	for node_name, pos_list in pairs(nodes) do
		local lvm_callback = on_finished_block_callbacks[node_name]
		if lvm_callback then
			lvm_callback(vm_context, pos_list)
		end
	end
end

function process_mapgen_chunk(minp, maxp, seed, vm_context)
	local nodes = minetest.find_nodes_in_area(minp, maxp, {"group:struct"}, true)
	for node_name, pos_list in pairs(nodes) do
		local chunk_callback = on_finished_chunk_callbacks[node_name]
		if chunk_callback then
			chunk_callback(minp, maxp, seed, vm_context, pos_list)
		end
	end
	for node_name, pos_list in pairs(nodes) do
		for _, pos in pairs(pos_list) do
			local node = minetest.get_node(pos)
			if string.sub(node.name, 1, 15) == 'mcl_structures:' then
				minetest.swap_node(pos, {name = 'air'})
			end
		end
	end
end

--------------------------------------------------------------------------------------
-- mcl_structures.register_structure(struct_def)
-- struct_def:
--	name              - name, like 'desert_temple'
--	decoration        - decoration definition, to use as structure seed (thanks cora for the idea)
--	on_finished_block - callback, if needed, to use with decorations: funcion(vm_context, pos_list)
--	on_finished_chunk - next callback if needed: funcion(minp, maxp, seed, vm_context, pos_list)
--	place_function    - callback to place schematic by /spawnstruct debug command: function(pos, rotation, pr, placer)
--	on_placed         - useful when you want to process the area after placement: function(pos, rotation, pr, size)
function mcl_structures.register_structure(def)
	local short_name         = def.name
	local name               = "mcl_structures:" .. short_name
	local decoration         = def.decoration
	local on_finished_block  = def.on_finished_block
	local on_finished_chunk  = def.on_finished_chunk
	local place_function     = def.place_function
	if not name then
		minetest.log('warning', 'Structure name is not passed for registration - ignoring')
		return
	end
	if registered_structures[name] then
		minetest.log('warning', 'Structure '..name..' is already registered - owerwriting')
	end
	local decoration_id
	if decoration then
		minetest.register_node(':' .. name, {
			drawtype            = "airlike",
			sunlight_propagates = true,
			pointable           = false,
			walkable            = false,
			diggable            = false,
			buildable_to        = true,
			groups              = {
				struct                    = 1,
				not_in_creative_inventory = 1,
			},
		})
		decoration_id = minetest.register_decoration({
			deco_type      = decoration.deco_type,
			place_on       = decoration.place_on,
			sidelen        = decoration.sidelen,
			fill_ratio     = decoration.fill_ratio,
			noise_params   = decoration.noise_params,
			biomes         = decoration.biomes,
			y_min          = decoration.y_min,
			y_max          = decoration.y_max,
			spawn_by       = decoration.spawn_by,
			num_spawn_by   = decoration.num_spawn_by,
			flags          = decoration.flags,
			decoration     = name,
			height         = decoration.height,
			height_max     = decoration.height_max,
			param2         = decoration.param2,
			param2_max     = decoration.param2_max,
			place_offset_y = decoration.place_offset_y,
			schematic      = decoration.schematic,
			replacements   = decoration.replacements,
			flags          = decoration.flags,
			rotation       = decoration.rotation,
		})
	end
	registered_structures[name] = {
		place_function    = place_function,
		on_finished_block = on_finished_block,
		on_finished_chunk = on_finished_chunk,
		decoration_id     = decoration_id,
		short_name        = short_name,
	}
	update_spawnstruct_chatcommand()
	if on_finished_block then
		on_finished_block_callbacks[name] = on_finished_block
		if not use_process_mapgen_block_lvm then
			use_process_mapgen_block_lvm = true
			mcl_mapgen.register_mapgen_block_lvm(process_mapgen_block_lvm, mcl_mapgen.order.BUILDINGS)
		end
	end
	if on_finished_chunk then
		on_finished_chunk_callbacks[name] = on_finished_chunk
		if not use_process_mapgen_chunk then
			use_process_mapgen_chunk = true
			mcl_mapgen.register_mapgen(process_mapgen_chunk, mcl_mapgen.order.BUILDINGS)
		end
	end
end

-- It doesN'T remove registered node and decoration!
function mcl_structures.unregister_structure(name)
	if not registered_structures[name] then
		minetest.log('warning','Structure '..name..' is not registered - skipping')
		return
	end
	registered_structures[name] = nil
end

local function ecb_place(blockpos, action, calls_remaining, param)
	if calls_remaining >= 1 then return end
	local pos = param.pos
	local rotation = param.rotation
	minetest.place_schematic(pos, param.schematic, rotation, param.replacements, param.force_placement, param.flags)
	local on_placed = param.on_placed
	if not on_placed then
		return
	end
	on_placed(pos, rotation, param.pr, param.size)
end

function mcl_structures.place_schematic(def)
	local pos       = def.pos
	local schematic = def.schematic
	local rotation  = def.rotation
	local pr        = def.pr
	local on_placed = def.on_placed -- on_placed(pos, rotation, pr, size)
	local emerge    = def.emerge
	if not pos then
		minetest.log('warning', '[mcl_structures] No pos. specified to place schematic')
		return
	end
	if not schematic then
		minetest.log('warning', '[mcl_structures] No schematic specified to place at ' .. minetest.pos_to_string(pos))
		return
	end
	if not rotation or rotation == 'random' then
		if pr then
			rotation = rotations[pr:next(1,#rotations)]
		else
			rotation = rotations[math.random(1,#rotations)]
		end
	end

	if not emerge and not on_placed then
		minetest.place_schematic(pos, schematic, rotation, def.replacements, def.force_placement, def.flags)
		return
	end

	local serialized_schematic = minetest.serialize_schematic(schematic, "lua", {lua_use_comments = false, lua_num_indent_spaces = 0}) .. " return schematic"
	local loaded_schematic = loadstring(serialized_schematic)()
	if not loaded_schematic then
		minetest.log('warning', '[mcl_structures] Schematic ' .. schematic .. ' load serialized string problem at ' .. minetest.pos_to_string(pos))
		return
	end
	local size = loaded_schematic.size
	if not size then
		minetest.log('warning', '[mcl_structures] Schematic ' .. schematic .. ' has no size at ' .. minetest.pos_to_string(pos))
		return
	end
	local size_x, size_y, size_z = size.x, size.y, size.z
	if rotation == "90" or rotation == "270" then
		size_x, size_z = size_z, size_x
	end
	local x, y, z = pos.x, pos.y, pos.z
	local p1 = {x = x, y = y, z = z}
	local p2 = {x = x + size_x - 1, y = y + size_y - 1, z = size_z - 1}
	local ecb_param = {
		pos             = vector.new(pos),
		schematic       = loaded_schematic,
		rotation        = rotation,
		replacements    = replacements,
		force_placement = force_placement,
		flags           = flags,
		size            = vector.new(size),
		pr              = pr,
		on_placed       = on_placed,
	}
	if not emerge then
		ecb_place(p1, nil, 0, ecb_param)
		return
	end
	minetest.log("verbose", "[mcl_structures] Emerge area " .. minetest.pos_to_string(p1) .. " - " .. minetest.pos_to_string(p2)
		.. " of size " ..minetest.pos_to_string(size) .. " to place " .. schematic .. ", rotation " .. tostring(rotation))
	minetest.emerge_area(p1, p2, ecb_place, ecb_param)
end

function mcl_structures.get_struct(file)
	local localfile = modpath.."/schematics/"..file
	local file, errorload = io.open(localfile, "rb")
	if errorload then
		minetest.log("error", "[mcl_structures] Could not open this struct: "..localfile)
		return nil
	end

	local allnode = file:read("*a")
	file:close()

	return allnode
end

-- Call on_construct on pos.
-- Useful to init chests from formspec.
function mcl_structures.init_node_construct(pos)
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	if def and def.on_construct then
		def.on_construct(pos)
		return true
	end
	return false
end

-- The call of Struct
function mcl_structures.call_struct(pos, struct_style, rotation, pr, callback)
	minetest.log("action","[mcl_structures] call_struct " .. struct_style.." at "..minetest.pos_to_string(pos))
	if not rotation then
		rotation = "random"
	end
	if struct_style == "boulder" then
		return mcl_structures.generate_boulder(pos, rotation, pr)
	elseif struct_style == "end_exit_portal" then
		return mcl_structures.generate_end_exit_portal(pos, rotation, pr, callback)
	elseif struct_style == "end_exit_portal_open" then
		return mcl_structures.generate_end_exit_portal_open(pos, rotation)
	elseif struct_style == "end_gateway_portal" then
		return mcl_structures.generate_end_gateway_portal(pos, rotation)
	elseif struct_style == "end_portal_shrine" then
		return mcl_structures.generate_end_portal_shrine(pos, rotation, pr)
	elseif struct_style == "end_portal" then
		return mcl_structures.generate_end_portal(pos, rotation, pr)
	end
end

function mcl_structures.generate_end_portal(pos, rotation, pr)
	-- todo: proper facedir
	local x0, y0, z0 = pos.x - 2, pos.y, pos.z - 2
	for x = 0, 4 do
		for z = 0, 4 do
			if x % 4 == 0 or z % 4 == 0 then
				if x % 4 ~= 0 or z % 4 ~= 0 then
					minetest.swap_node({x = x0 + x, y = y0, z = z0 + z}, {name = "mcl_portals:end_portal_frame_eye"})
				end
			else
				minetest.swap_node({x = x0 + x, y = y0, z = z0 + z}, {name = "mcl_portals:portal_end"})
			end
		end
	end
end

function mcl_structures.generate_boulder(pos, rotation, pr)
	-- Choose between 2 boulder sizes (2×2×2 or 3×3×3)
	local r = pr:next(1, 10)
	local path
	if r <= 3 then
		path = modpath.."/schematics/mcl_structures_boulder_small.mts"
	else
		path = modpath.."/schematics/mcl_structures_boulder.mts"
	end

	local newpos = {x=pos.x,y=pos.y-1,z=pos.z}

	return minetest.place_schematic(newpos, path, rotation) -- don't serialize schematics for registered biome decorations, for MT 5.4.0, https://github.com/minetest/minetest/issues/10995
end

function mcl_structures.generate_end_exit_portal(pos, rot, pr, callback)
	local path = modpath.."/schematics/mcl_structures_end_exit_portal.mts"
	return mcl_structures.place_schematic(pos, path, rot or "0", {["mcl_portals:portal_end"] = "air"}, true, nil, callback)
end

function mcl_structures.generate_end_exit_portal_open(pos, rot)
	local path = modpath.."/schematics/mcl_structures_end_exit_portal.mts"
	return mcl_structures.place_schematic(pos, path, rot or "0", nil, true)
end

function mcl_structures.generate_end_gateway_portal(pos, rot)
	local path = modpath.."/schematics/mcl_structures_end_gateway_portal.mts"
	return mcl_structures.place_schematic(pos, path, rot or "0", nil, true)
end

local chunk_square = mcl_mapgen.CS_NODES * mcl_mapgen.CS_NODES
local block_square = mcl_mapgen.BS * mcl_mapgen.BS

function mcl_structures.from_16x16_to_chunk_inverted_chance(x)
	return math.floor(x * 256 / chunk_square + 0.5)
end

function mcl_structures.from_16x16_to_block_inverted_chance(x)
	return math.floor(x * 256 / block_square + 0.5)
end

dofile(modpath .. "/structures.lua")
