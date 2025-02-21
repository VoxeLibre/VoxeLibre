local S = core.get_translator(core.get_current_modname())

--- /spawnstruct chat command
core.register_chatcommand("spawnstruct", {
	params = "",
	description = S("Generate a pre-defined structure near your position."),
	privs = {debug = true},
	func = function(name, param)
		local player = core.get_player_by_name(name)
		if not player then return end
		local pos = player:get_pos()
		if not pos then return end
		pos = vector.round(pos)
		local dir = core.yaw_to_dir(player:get_look_horizontal())
		local rot = math.abs(dir.x) > math.abs(dir.z) and (dir.x < 0 and "270" or "90") or (dir.z < 0 and "180" or "0")
		local seed = mcl_util.hash_pos(pos.x, pos.y, pos.z)
		local pr = PcgRandom(seed)
		if param == "dungeon" and mcl_dungeons and mcl_dungeons.spawn_dungeon then
			mcl_dungeons.spawn_dungeon(pos, rot, pr)
			return true, "Spawning "..param
		elseif param == "" then
			core.chat_send_player(name, S("Error: No structure type given. Please use “/spawnstruct "..core.registered_chatcommands["spawnstruct"].params.."”."))
		else
			for n,d in pairs(vl_structures.registered_structures) do
				if n == param then
					vl_structures.place_structure(pos, d, pr, seed, rot)
					return true, "Spawning "..param
				end
			end
			core.chat_send_player(name, S("Error: Unknown structure type. Please use “/spawnstruct "..core.registered_chatcommands["spawnstruct"].params.."”."))
		end
	end
})
core.register_on_mods_loaded(function()
	local p = _G["mcl_dungeons"] and "dungeon" or ""
	for n,_ in pairs(vl_structures.registered_structures) do
		p = (p ~= "" and (p.." | ") or "")..n
	end
	core.registered_chatcommands["spawnstruct"].params = p
end)

--- /locate chat command (debug privilege)
core.register_chatcommand("locate", {
	description = S("Locate a pre-defined structure near your position."),
	privs = {debug = true},
	func = function(name, param)
		local player = core.get_player_by_name(name)
		if not player then return end
		local pos = player:get_pos()
		if not pos then return end
		if param == "" then
			local data = vl_structures.get_structure_spawns()
			local datastr = ""
			for i, d in ipairs(data) do
				local c = vl_structures.get_structure_spawns(d)
				datastr = datastr .. (i > 1 and " | " or "") .. d .. " (" .. #c .. ")"
			end
			if datastr == "" then
				core.chat_send_player(name, S("Error: No structure type given, and no structures were recently spawned - try /emerge 128 and give the game some time."))
			else
				core.chat_send_player(name, S("Error: No structure type given. Recently spawned structures include: "..datastr))
			end
			return
		end
		local data = vl_structures.get_structure_spawns(param)
		local bestd, bestp = 1e9, nil
		for _, p in ipairs(data or {}) do
			local sdx = math.abs(p.x-pos.x) + math.abs(p.y-pos.y) + math.abs(p.z-pos.z)
			if sdx < bestd or not bestp then bestd, bestp = sdx, p end
		end
		if bestp then
			core.chat_send_player(name, S("A @1 can be found at @2, @3 blocks away.", param, core.pos_to_string(bestp), bestd))
		else
			core.chat_send_player(name, S("Structure type not known or no structure of this type spawned yet - try /emerge 128 and give the game some time."))
		end
	end
})

--- /emerge chat command (debug privilege, as this could be abused to slow down a server)
core.register_chatcommand("emerge", {
	description = S("Fully emerge the area near your position."),
	privs = {debug = true},
	func = function(name, param)
		local player = core.get_player_by_name(name)
		if not player then return end
		local pos = player:get_pos()
		if not pos then return end
		local distance = tonumber(param)
		if not distance or distance > 512 then
			core.chat_send_player(name, S("Error: the emerge distance must be at most 512, as too large emerges could be abused to create server load."))
			return
		end
		core.chat_send_player(name, S("Staring map generation, please be patient."))
		local calls_initial, start, lastrep, known_initial = nil, os.clock(), os.clock(), {}
		for _,k in ipairs(vl_structures.get_structure_spawns()) do known_initial[k] = #(vl_structures.get_structure_spawns(k) or {}) end
		core.emerge_area(vector.offset(pos, -distance, -16, distance), vector.offset(pos, distance, 16, distance),
		    function(blockpos, action, calls_remaining, param)
			calls_initial = calls_initial or calls_remaining + 1
			if calls_remaining == 0 then
				-- emerge twice to give the structure emerges a chance to run.
				calls_initial = 0
				core.chat_send_player(name, S("Initial emerge complete, starting second pass."))
				core.emerge_area(vector.offset(pos, -distance, -16, distance), vector.offset(pos, distance, 16, distance),
				    function(blockpos, action, calls_remaining, param)
					calls_initial = calls_initial or calls_remaining + 1
					local report = ""
					for _,k in pairs(vl_structures.get_structure_spawns()) do
						local n = #(vl_structures.get_structure_spawns(k) or {}) - (known_initial[k] or 0)
						if n > 0 then
							report = report..(report == "" and "" or ", ")..tostring(n).." "..k
						end
					end
					if report == "" then report = S("nothing yet.") end
					if calls_remaining == 0 then
						core.chat_send_player(name, S("Area has been successfully generated after @1 seconds. New: @2", math.floor(os.clock() - start), report))
					end
				    end)
			elseif os.clock() - lastrep >= 10 then
				lastrep = os.clock()
				core.chat_send_player(name, S("Initial emerge @1% complete.", math.floor(100 * (calls_initial - calls_remaining) / calls_initial)))
			end
		end)
		return
	end
})
