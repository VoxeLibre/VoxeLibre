local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)

--- /spawnstruct chat command
minetest.register_chatcommand("spawnstruct", {
	params = mcl_dungeons and "dungeon" or "",
	description = S("Generate a pre-defined structure near your position."),
	privs = {debug = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then return end
		local pos = player:get_pos()
		if not pos then return end
		pos = vector.round(pos)
		local dir = minetest.yaw_to_dir(player:get_look_horizontal())
		local rot = math.abs(dir.x) > math.abs(dir.z) and (dir.x < 0 and "270" or "90") or (dir.z < 0 and "180" or "0")
		local seed = minetest.hash_node_position(pos)
		local pr = PcgRandom(seed)
		local errord = false
		if param == "dungeon" and mcl_dungeons and mcl_dungeons.spawn_dungeon then
			mcl_dungeons.spawn_dungeon(pos, rot, pr)
			return true, "Spawning "..param
		elseif param == "" then
			minetest.chat_send_player(name, S("Error: No structure type given. Please use “/spawnstruct "..minetest.registered_chatcommands["spawnstruct"].params.."”."))
		else
			for n,d in pairs(vl_structures.registered_structures) do
				if n == param then
					vl_structures.place_structure(pos, d, pr, seed, rot)
					return true, "Spawning "..param
				end
			end
			minetest.chat_send_player(name, S("Error: Unknown structure type. Please use “/spawnstruct "..minetest.registered_chatcommands["spawnstruct"].params.."”."))
		end
	end
})
minetest.register_on_mods_loaded(function()
	local p = minetest.registered_chatcommands["spawnstruct"].params
	for n,_ in pairs(vl_structures.registered_structures) do
		p = (p ~= "" and (p.." | ") or "")..n
	end
	minetest.registered_chatcommands["spawnstruct"].params = p
end)

