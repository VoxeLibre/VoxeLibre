local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)

mcl_structures = {}

local rotations = {
	"0",
	"90",
	"180",
	"270"
}

local function ecb_place(blockpos, action, calls_remaining, param)
	if calls_remaining >= 1 then return end
	minetest.place_schematic(param.pos, param.schematic, param.rotation, param.replacements, param.force_placement, param.flags)
	if param.after_placement_callback and param.p1 and param.p2 then
		param.after_placement_callback(param.p1, param.p2, param.size, param.rotation, param.pr, param.callback_param)
	end
end

function mcl_structures.place_schematic(pos, schematic, rotation, replacements, force_placement, flags, after_placement_callback, pr, callback_param)
	local s = loadstring(minetest.serialize_schematic(schematic, "lua", {lua_use_comments = false, lua_num_indent_spaces = 0}) .. " return schematic")()
	if s and s.size then
		local x, z = s.size.x, s.size.z
		if rotation then
			if rotation == "random" and pr then
				rotation = rotations[pr:next(1,#rotations)]
			end
			if rotation == "random" then
				x = math.max(x, z)
				z = x
			elseif rotation == "90" or rotation == "270" then
				x, z = z, x
			end
		end
		local p1 = {x=pos.x    , y=pos.y           , z=pos.z    }
		local p2 = {x=pos.x+x-1, y=pos.y+s.size.y-1, z=pos.z+z-1}
		minetest.log("verbose", "[mcl_structures] size=" ..minetest.pos_to_string(s.size) .. ", rotation=" .. tostring(rotation) .. ", emerge from "..minetest.pos_to_string(p1) .. " to " .. minetest.pos_to_string(p2))
		local param = {pos=vector.new(pos), schematic=s, rotation=rotation, replacements=replacements, force_placement=force_placement, flags=flags, p1=p1, p2=p2, after_placement_callback = after_placement_callback, size=vector.new(s.size), pr=pr, callback_param=callback_param}
		minetest.emerge_area(p1, p2, ecb_place, param)
		return true
	end
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
local function init_node_construct(pos)
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	if def and def.on_construct then
		def.on_construct(pos)
		return true
	end
	return false
end
mcl_structures.init_node_construct = init_node_construct

-- The call of Struct
function mcl_structures.call_struct(pos, struct_style, rotation, pr)
	minetest.log("action","[mcl_structures] call_struct " .. struct_style.." at "..minetest.pos_to_string(pos))
	if not rotation then
		rotation = "random"
	end
	if struct_style == "end_exit_portal" then
		return mcl_structures.generate_end_exit_portal(pos, rotation)
	elseif struct_style == "end_exit_portal_open" then
		return mcl_structures.generate_end_exit_portal_open(pos, rotation)
	elseif struct_style == "end_gateway_portal" then
		return mcl_structures.generate_end_gateway_portal(pos, rotation)
	elseif struct_style == "end_portal_shrine" then
		return mcl_structures.generate_end_portal_shrine(pos, rotation, pr)
	end
end


function mcl_structures.generate_end_exit_portal(pos, rot)
	local path = modpath.."/schematics/mcl_structures_end_exit_portal.mts"
	return mcl_structures.place_schematic(pos, path, rot or "0", {["mcl_portals:portal_end"] = "air"}, true)
end

function mcl_structures.generate_end_exit_portal_open(pos, rot)
	local path = modpath.."/schematics/mcl_structures_end_exit_portal.mts"
	return mcl_structures.place_schematic(pos, path, rot or "0", nil, true)
end

function mcl_structures.generate_end_gateway_portal(pos, rot)
	local path = modpath.."/schematics/mcl_structures_end_gateway_portal.mts"
	return mcl_structures.place_schematic(pos, path, rot or "0", nil, true)
end

local function shrine_placement_callback(p1, p2, size, rotation, pr)
	-- Find and setup spawner with silverfish
	local spawners = minetest.find_nodes_in_area(p1, p2, "mcl_mobspawners:spawner")
	for s=1, #spawners do
		--local meta = minetest.get_meta(spawners[s])
		mcl_mobspawners.setup_spawner(spawners[s], "mobs_mc:silverfish")
	end

	-- Shuffle stone brick types
	local bricks = minetest.find_nodes_in_area(p1, p2, "mcl_core:stonebrick")
	for b=1, #bricks do
		local r_bricktype = pr:next(1, 100)
		local r_infested = pr:next(1, 100)
		local bricktype
		if r_infested <= 5 then
			if r_bricktype <= 30 then -- 30%
				bricktype = "mcl_monster_eggs:monster_egg_stonebrickmossy"
			elseif r_bricktype <= 50 then -- 20%
				bricktype = "mcl_monster_eggs:monster_egg_stonebrickcracked"
			else -- 50%
				bricktype = "mcl_monster_eggs:monster_egg_stonebrick"
			end
		else
			if r_bricktype <= 30 then -- 30%
				bricktype = "mcl_core:stonebrickmossy"
			elseif r_bricktype <= 50 then -- 20%
				bricktype = "mcl_core:stonebrickcracked"
			end
			-- 50% stonebrick (no change necessary)
		end
		if bricktype then
			minetest.set_node(bricks[b], { name = bricktype })
		end
	end

	-- Also replace stairs
	local stairs = minetest.find_nodes_in_area(p1, p2, {"mcl_stairs:stair_stonebrick", "mcl_stairs:stair_stonebrick_outer", "mcl_stairs:stair_stonebrick_inner"})
	for s=1, #stairs do
		local stair = minetest.get_node(stairs[s])
		local r_type = pr:next(1, 100)
		if r_type <= 30 then -- 30% mossy
			if stair.name == "mcl_stairs:stair_stonebrick" then
				stair.name = "mcl_stairs:stair_stonebrickmossy"
			elseif stair.name == "mcl_stairs:stair_stonebrick_outer" then
				stair.name = "mcl_stairs:stair_stonebrickmossy_outer"
			elseif stair.name == "mcl_stairs:stair_stonebrick_inner" then
				stair.name = "mcl_stairs:stair_stonebrickmossy_inner"
			end
			minetest.set_node(stairs[s], stair)
		elseif r_type <= 50 then -- 20% cracky
			if stair.name == "mcl_stairs:stair_stonebrick" then
				stair.name = "mcl_stairs:stair_stonebrickcracked"
			elseif stair.name == "mcl_stairs:stair_stonebrick_outer" then
				stair.name = "mcl_stairs:stair_stonebrickcracked_outer"
			elseif stair.name == "mcl_stairs:stair_stonebrick_inner" then
				stair.name = "mcl_stairs:stair_stonebrickcracked_inner"
			end
			minetest.set_node(stairs[s], stair)
		end
		-- 50% no change
	end

	-- Randomly add ender eyes into end portal frames, but never fill the entire frame
	local frames = minetest.find_nodes_in_area(p1, p2, "mcl_portals:end_portal_frame")
	local eyes = 0
	for f=1, #frames do
		local r_eye = pr:next(1, 10)
		if r_eye == 1 then
			eyes = eyes + 1
			if eyes < #frames then
				local frame_node = minetest.get_node(frames[f])
				frame_node.name = "mcl_portals:end_portal_frame_eye"
				minetest.set_node(frames[f], frame_node)
			end
		end
	end
end

function mcl_structures.generate_end_portal_shrine(pos, rotation, pr)
	local offset = {x=6, y=4, z=6}
	--local size = {x=13, y=8, z=13}
	local newpos = { x = pos.x - offset.x, y = pos.y, z = pos.z - offset.z }

	local path = modpath.."/schematics/mcl_structures_end_portal_room_simple.mts"
	mcl_structures.place_schematic(newpos, path, rotation or "0", nil, true, nil, shrine_placement_callback, pr)
end

local structure_data = {}

--[[ Returns a table of structure of the specified type.
Currently the only valid parameter is "stronghold".
Format of return value:
{
	{ pos = <position>, generated=<true/false> }, -- first structure
	{ pos = <position>, generated=<true/false> }, -- second structure
	-- and so on
}

TODO: Implement this function for all other structure types as well.
]]
function mcl_structures.get_structure_data(structure_type)
	if structure_data[structure_type] then
		return table.copy(structure_data[structure_type])
	else
		return {}
	end
end

-- Register a structures table for the given type. The table format is the same as for
-- mcl_structures.get_structure_data.
function mcl_structures.register_structure_data(structure_type, structures)
	structure_data[structure_type] = structures
end

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

dofile(modpath.."/api.lua")
dofile(modpath.."/shipwrecks.lua")
dofile(modpath.."/desert_temple.lua")
dofile(modpath.."/jungle_temple.lua")
dofile(modpath.."/ocean_ruins.lua")
dofile(modpath.."/witch_hut.lua")
dofile(modpath.."/igloo.lua")
dofile(modpath.."/woodland_mansion.lua")
dofile(modpath.."/geode.lua")



mcl_structures.register_structure("desert_well",{
	place_on = {"group:sand"},
	fill_ratio = 0.01,
	flags = "place_center_x, place_center_z",
	not_near = { "desert_temple_new" },
	solid_ground = true,
	sidelen = 4,
	chunk_probability = 600,
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	y_offset = -2,
	biomes = { "Desert" },
	filenames = { modpath.."/schematics/mcl_structures_desert_well.mts" },
})

mcl_structures.register_structure("fossil",{
	place_on = {"group:material_stone","group:sand"},
	fill_ratio = 0.01,
	flags = "place_center_x, place_center_z",
	solid_ground = true,
	sidelen = 13,
	chunk_probability = 1000,
	y_offset = function(pr) return ( pr:next(1,16) * -1 ) -16 end,
	y_max = 15,
	y_min = mcl_vars.mg_overworld_min + 35,
	biomes = { "Desert" },
	filenames = {
		modpath.."/schematics/mcl_structures_fossil_skull_1.mts", -- 4×5×5
		modpath.."/schematics/mcl_structures_fossil_skull_2.mts", -- 5×5×5
		modpath.."/schematics/mcl_structures_fossil_skull_3.mts", -- 5×5×7
		modpath.."/schematics/mcl_structures_fossil_skull_4.mts", -- 7×5×5
		modpath.."/schematics/mcl_structures_fossil_spine_1.mts", -- 3×3×13
		modpath.."/schematics/mcl_structures_fossil_spine_2.mts", -- 5×4×13
		modpath.."/schematics/mcl_structures_fossil_spine_3.mts", -- 7×4×13
		modpath.."/schematics/mcl_structures_fossil_spine_4.mts", -- 8×5×13
	},
})

mcl_structures.register_structure("boulder",{
	filenames = {
		modpath.."/schematics/mcl_structures_boulder_small.mts",
		modpath.."/schematics/mcl_structures_boulder_small.mts",
		modpath.."/schematics/mcl_structures_boulder_small.mts",
		modpath.."/schematics/mcl_structures_boulder.mts",
		-- small boulder 3x as likely
	},
},true) --is spawned as a normal decoration. this is just for /spawnstruct
mcl_structures.register_structure("ice_spike_small",{
	filenames = {
		modpath.."/schematics/mcl_structures_ice_spike_small.mts"
	},
},true) --is spawned as a normal decoration. this is just for /spawnstruct
mcl_structures.register_structure("ice_spike_large",{
	sidelen = 6,
	filenames = {
		modpath.."/schematics/mcl_structures_ice_spike_large.mts"
	},
},true) --is spawned as a normal decoration. this is just for /spawnstruct

-- Debug command
minetest.register_chatcommand("spawnstruct", {
	params = "end_exit_portal | end_exit_portal_open | end_gateway_portal | end_portal_shrine | nether_portal | dungeon",
	description = S("Generate a pre-defined structure near your position."),
	privs = {debug = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then return end
		local pos = player:get_pos()
		if not pos then return end
		pos = vector.round(pos)
		local dir = minetest.yaw_to_dir(player:get_look_horizontal())
		local rot = dir_to_rotation(dir)
		local pr = PseudoRandom(pos.x+pos.y+pos.z)
		local errord = false
		local message = S("Structure placed.")
		if param == "end_exit_portal" then
			mcl_structures.generate_end_exit_portal(pos, rot, pr)
		elseif param == "end_exit_portal_open" then
			mcl_structures.generate_end_exit_portal_open(pos, rot, pr)
		elseif param == "end_gateway_portal" then
			mcl_structures.generate_end_gateway_portal(pos, rot, pr)
		elseif param == "end_portal_shrine" then
			mcl_structures.generate_end_portal_shrine(pos, rot, pr)
		elseif param == "dungeon" and mcl_dungeons and mcl_dungeons.spawn_dungeon then
			mcl_dungeons.spawn_dungeon(pos, rot, pr)
		elseif param == "nether_portal" and mcl_portals and mcl_portals.spawn_nether_portal then
			mcl_portals.spawn_nether_portal(pos, rot, pr, name)
		elseif param == "" then
			message = S("Error: No structure type given. Please use “/spawnstruct <type>”.")
			errord = true
		else
			for n,d in pairs(mcl_structures.registered_structures) do
				if n == param then
					mcl_structures.place_structure(pos,d,pr,math.random())
					return true,message
				end
			end
			message = S("Error: Unknown structure type. Please use “/spawnstruct <type>”.")
			errord = true
		end
		minetest.chat_send_player(name, message)
		if errord then
			minetest.chat_send_player(name, S("Use /help spawnstruct to see a list of avaiable types."))
		end
	end
})
minetest.register_on_mods_loaded(function()
	local p = ""
	for n,_ in pairs(mcl_structures.registered_structures) do
		p = p .. " | "..n
	end
	minetest.registered_chatcommands["spawnstruct"].params = minetest.registered_chatcommands["spawnstruct"].params .. p
end)
