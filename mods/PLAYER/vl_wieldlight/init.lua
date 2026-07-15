if core.settings:get_bool("enable_vl_wieldlight", true) then

local max_players_per_step = tonumber(core.settings:get("vl_wieldlight_player_step_lim"))
if max_players_per_step and max_players_per_step < 0 then max_players_per_step = nil end

local players = {} -- positions and powers of player lights

local cdt = {} -- reusable cid buffer
local ldt = {} -- reusable light buffer

local shade_ci_cache -- cache of content IDs for nodes that cast shade
local light_ci_cache -- cache of content IDs for light sources
-- fill the above once everything (including overrides) is loaded
core.register_on_mods_loaded(function() core.after(0, function()
	shade_ci_cache = {}
	light_ci_cache = {}
	for n, def in pairs(core.registered_nodes) do
		if def.paramtype == "none" then
			shade_ci_cache[core.get_content_id(n)] = true
		end
		if def.light_source and def.light_source > 0 then
			light_ci_cache[core.get_content_id(n)] = def.light_source
		end
	end
end) end)

local function chebyshev(v1, v2)
	return math.max(math.abs(v1.x-v2.x), math.abs(v1.y-v2.y), math.abs(v1.z-v2.z))
end

local function wieldedlight(name)
	if not name then return end
	local player = core.get_player_by_name(name)
	if not player then return end
	local pos = player:get_pos()
	if not pos then return end
	pos = vector.round(pos) -- rounding needed for LVM

	local p1, p2 -- LVM bounds
	local double_run = false
	-- Fix light at old position
	local old_p = players[name]
	if old_p then
		local old_po = old_p[1] -- old position
		local old_ls = old_p[2] -- old_strength
		p1 = vector.offset(old_po, -old_ls, -old_ls, -old_ls)
		p2 = vector.offset(old_po, old_ls, old_ls, old_ls)
		double_run = chebyshev(old_p[1], pos) > 16
	end

	-- Light source power
	local ls = player:get_wielded_item():get_definition().light_source
	local o_ls = player:get_inventory():get_stack("offhand", 1):get_definition().light_source
	if o_ls and (not ls or o_ls > ls) then ls = o_ls end
	local nn = core.get_node(pos).name
	local def = nn and core.registered_nodes[nn]
	local cl = def and def.light_source
	if not cl or ls and cl > ls then ls = nil end -- further calculations would be no-op
	local np1, np2 -- new LVM bounds
	if ls and ls > 0 then
		np1 = vector.offset(pos, -ls, -ls, -ls)
		np2 = vector.offset(pos, ls, ls, ls)
		if not double_run and old_p then -- areas are very close together, can go on a single LVM
			for _, i in ipairs{"x", "y", "z"} do
				-- Acquire minimum LVM for the light source power
				if np1[i] < p1[i] then p1[i] = np1[i] end
				if np2[i] > p2[i] then p2[i] = np2[i] end
			end
		end
	else
		double_run = false
	end
	if p1 or np1 then
		local DIRS
		local lvm, emin, emax, area, head
		local s_queue = {}
		-- Acquire the LVM
		if p1 then
			lvm = VoxelManip(p1, p2)
		elseif np1 then
			lvm = VoxelManip(np1, np2)
		end
		if lvm then
			lvm:get_data(cdt) -- flat array of cid values
			lvm:get_light_data(ldt) -- flat array of param1 values
			-- Get indexer for the sub-area of the LVM
			emin, emax = lvm:get_emerged_area()
			area = VoxelArea(emin, emax)
			DIRS = {
				-1,            -- -X
				-area.ystride, -- -Y
				-area.zstride, -- -Z
				1,             -- +X
				area.ystride,  -- +Y
				area.zstride   -- +Z
			}
		end
		if np1 and not double_run then
			table.insert(s_queue, {area:indexp(pos), ls-1})
		end
		if p1 then
			local oi = area:indexp(old_p[1])
			if cdt[oi] ~= core.CONTENT_IGNORE then
				local startlight = math.floor(ldt[oi]/16)
				local pls = light_ci_cache[cdt[oi]]
				if startlight > 0 and (not pls or pls < startlight) then
					local r_queue = {{area:indexp(old_p[1]), startlight}} -- removal BFS queue
					ldt[oi] = ldt[oi]%16
					-- Run a BFS light removal
					head = 1 -- queue head index
					while head <= #r_queue do
						local frame = r_queue[head]
						local p_i = frame[1] -- position index
						local l = frame[2] -- remembered light
						head = head + 1
						for _, dir in ipairs(DIRS) do
							local i = p_i + dir
							if ldt[i] and not shade_ci_cache[cdt[i]] then
								local n = math.floor(ldt[i]/16) -- current night lightbank
								if n >= l then -- light from other source, spread back
									table.insert(s_queue, {i, n-1})
								elseif n > 0 then -- light from this source, clear
									ldt[i] = ldt[i]%16
									table.insert(r_queue, {i, n})
								end
								if n < l and light_ci_cache[cdt[i]] then
									ldt[i] = ldt[i] + light_ci_cache[cdt[i]] *16
									if light_ci_cache[cdt[i]] > 1 then
										table.insert(s_queue, {i, light_ci_cache[cdt[i]]-1})
									end
								end
							elseif ldt[i] and light_ci_cache[cdt[i]] and light_ci_cache[cdt[i]] > 1 then
								table.insert(s_queue, {i, light_ci_cache[cdt[i]]-1})
							end
						end
					end
					if pls and pls > 0 then
						table.insert(s_queue, {oi, pls-1})
						ldt[oi] = ldt[oi]%16 + pls*16
					end
				end
			end
		end
		if np1 and not double_run then
			local ni = area:indexp(pos)
			ldt[ni] = ldt[ni]%16 + ls*16
		end
		local function bfs_light_spread()
			head = 1 -- queue head index
			while head <= #s_queue do
				local frame = s_queue[head]
				local p_i = frame[1] -- position index
				local l = frame[2] -- light value to spread
				head = head + 1
				for _, dir in ipairs(DIRS) do
					local i = p_i + dir
					if ldt[i] and not shade_ci_cache[cdt[i]] then
						local n = math.floor(ldt[i]/16) -- current night lightbank
						if l > n then
							ldt[i] = ldt[i]%16 + l*16 -- pack into param1 again
							if l > 1 then
								table.insert(s_queue, {i, l-1})
							end
						end
					end
				end
			end
		end
		bfs_light_spread()
		if double_run then -- reinitialize LVM for the second area
			lvm:set_light_data(ldt)
			lvm:write_to_map(false)
			if lvm.close then lvm:close() end
			lvm:initialize(np1, np2)
			lvm:read_from_map(np1, np2)
			lvm:get_data(cdt) -- flat array of cid values
			lvm:get_light_data(ldt) -- flat array of param1 values
			emin, emax = lvm:get_emerged_area()
			area = VoxelArea(emin, emax)
			DIRS = {
				-1,            -- -X
				-area.ystride, -- -Y
				-area.zstride, -- -Z
				1,             -- +X
				area.ystride,  -- +Y
				area.zstride   -- +Z
			}
			local ni = area:indexp(pos)
			table.insert(s_queue, {ni, ls-1})
			ldt[ni] = ldt[ni]%16 + ls*16
			bfs_light_spread()
		end
		lvm:set_light_data(ldt)
		lvm:write_to_map(false)
		if lvm.close then lvm:close() end
		players[name] = {pos, ls, np1, np2}
	end
	if not np1 then
		players[name] = nil
	end
end

local p_queue = {} -- array-based cyclic queue
local i_queue = 1 -- queue current element index

core.register_on_joinplayer(function(player)
	-- Add player into queue
	table.insert(p_queue, player:get_player_name())
end)

core.register_globalstep(function(dtime)
	if not shade_ci_cache then return end
	-- Iterate part of the queue
	local iter_num = math.ceil(dtime * #p_queue)
	if max_players_per_step and iter_num > max_players_per_step then
		iter_num = max_players_per_step
	end
	for i=1, iter_num do
		wieldedlight(p_queue[i_queue])
		i_queue = i_queue + 1
		if i_queue > #p_queue then i_queue = 1 end
	end
end)

core.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	local i = table.indexof(p_queue, name)
	if i > 0 then
		table.remove(p_queue, i)
		if i < i_queue then i_queue = i_queue - 1 end
	end
	if i_queue > #p_queue then i_queue = 1 end
	-- Cleanup wieldlight after player
	local p = players[name]
	if p then
		core.fix_light(p[3], p[4])
		players[name] = nil
	end
end)

-- Cleanup wieldlights on shutdown
core.register_on_shutdown(function()
	for _, p in pairs(players) do
		core.fix_light(p[3], p[4])
	end
end)

end
