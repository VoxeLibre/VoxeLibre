local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)

--- /spawnstruct chat command
minetest.register_chatcommand("spawnstruct", {
	params = "",
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
	local p = _G["mcl_dungeons"] and "dungeon" or ""
	for n,_ in pairs(vl_structures.registered_structures) do
		p = (p ~= "" and (p.." | ") or "")..n
	end
	minetest.registered_chatcommands["spawnstruct"].params = p
end)

--- /locate chat command
minetest.register_chatcommand("locate", {
	params = "",
	description = S("Locate a pre-defined structure near your position."),
	privs = {debug = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then return end
		local pos = player:get_pos()
		if not pos then return end
		if param == "" then
			local data = vl_structures.get_structure_spawns()
			local datastr = ""
			for i, d in ipairs(data) do datastr = datastr .. (i > 1 and " | " or "") .. d end
			if datastr == "" then
				minetest.chat_send_player(name, S("Error: No structure type given, and no structures were recently spawned."))
			else
				minetest.chat_send_player(name, S("Error: No structure type given. Recently spawned structures include: "..datastr.."”."))
			end
			return
		end
		local data = vl_structures.get_structure_spawns(param)
		local bestd, bestp = 1e9, nil
		for _, p in ipairs(data or {}) do
			local sdx = math.abs(p.x-pos.x) + math.abs(p.y-pos.y) + math.abs(p.z-pos.z)
			if sdx < bestd or not bestv then bestd, bestp = sdx, p end
		end
		if bestp then
			minetest.chat_send_player(name, S("A "..param.." can be found at "..minetest.pos_to_string(bestp)))
		else
			minetest.chat_send_player(name, S("Structure type not known or no structure of this type spawned yet."))
		end
	end
})

