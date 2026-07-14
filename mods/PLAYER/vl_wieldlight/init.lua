if core.settings:get_bool("enable_vl_wieldlight", true) then

local players = {} -- areas impacted by player lights

local cdt = {} -- reusable cid buffer
local ldt = {} -- reusable light buffer

local shade_ci_cache -- cache of content IDs for nodes that cast shade
-- fill the above once everything (including overrides) is loaded
core.register_on_mods_loaded(function() core.after(0, function()
	shade_ci_cache = {}
	for n, def in pairs(core.registered_nodes) do
		if def.paramtype == "none" or def.groups.solid == 1 or def.sunlight_propagates == false then
			shade_ci_cache[core.get_content_id(n)] = true
		end
	end
end) end)

local DIRS = {
	vector.new(-1, 0, 0),
	vector.new(0, -1, 0),
	vector.new(0, 0, -1),
	vector.new(1, 0, 0),
	vector.new(0, 1, 0),
	vector.new(0, 0, 1)
}

local p_times = {}
local p_count = {}
local p_thuds = {}

local function wieldedlight(name)
	if not name then return end
	local player = core.get_player_by_name(name)
	if not player then return end
	local pos = player:get_pos()
	if not pos then return end
	pos = vector.round(pos) -- rounding needed for LVM

	-- Fix light at old position
	local old_p = players[name]
	if old_p then
		core.fix_light(old_p[1], old_p[2])
		players[name] = nil
	end

	-- Light source power
	local ls = player:get_wielded_item():get_definition().light_source
	local o_ls = player:get_inventory():get_stack("offhand", 1):get_definition().light_source
	if o_ls and (not ls or o_ls > ls) then ls = o_ls end
	if ls and ls > 0 then
		-- Acquire minimum LVM for the light source power
		local p1 = vector.offset(pos, -ls, -ls, -ls)
		local p2 = vector.offset(pos, ls, ls, ls)
		local lvm = VoxelManip(p1, p2)
		lvm:get_data(cdt) -- flat array of cid values
		lvm:get_light_data(ldt) -- flat array of param1 values
		-- Get indexer for the sub-area of the LVM
		local emin, emax = lvm:get_emerged_area()
		local area = VoxelArea(emin, emax)
		-- Run a DFS light spread
		local start = core.get_us_time()
		local stack = {{pos, 1, ls}} -- DFS stack
		while #stack > 0 do
			local frame = stack[#stack]
			local p = frame[1] -- position
			local dir = frame[2] -- next direction to check
			local l = frame[3] -- light value to spread
			for j=dir, 7 do
				if j == 7 then
					table.remove(stack)
					break
				end
				local pn = p + DIRS[j]
				local i = area:indexp(pn)
				if not shade_ci_cache[cdt[i]] then
					local n = math.floor(ldt[i]/16) -- current night lightbank
					local d = math.max(ldt[i] - n*16, l) -- amended day lightbank
					if l > n then
						n = math.max(n, l) -- amended night lightbank
						ldt[i] = d + n*16 -- pack into param1 again
						if l > 1 then
							frame[2] = j + 1
							table.insert(stack, {pn, 1, l-1})
							break
						end
					end
				end
			end
		end
		p_times[name] = core.get_us_time() - start + p_times[name]
		p_count[name] = p_count[name] + 1
		player:hud_change(p_thuds[name], "text", string.format("%f", p_times[name] / p_count[name] / 1e6))
		lvm:set_light_data(ldt)
		lvm:write_to_map(false)
		if lvm.close then lvm:close() end
		players[name] = {p1, p2}
	end
end

local p_queue = {} -- array-based cyclic queue
local p_index = {} -- hashmap index of the above (reverse)
local i_queue = 1 -- queue current element index

core.register_on_joinplayer(function(player)
	-- Add player into queue
	local name = player:get_player_name()
	table.insert(p_queue, name)
	p_index[name] = #p_queue
	p_times[name] = 0
	p_count[name] = 0
	p_thuds[name] = player:hud_add{
		type = "text",
		number = 0xFFFFFF,
		size = 25,
		position = {x = 0.5, y = 0},
		offset = {x = 0, y = 30},
		alignment = {x = 0, y = 1}
	}
end)

core.register_globalstep(function(dtime)
	if not shade_ci_cache then return end
	-- Iterate part of the queue
	local iter_num = math.ceil(dtime * #p_queue)
	for i=0, iter_num do
		wieldedlight(p_queue[i_queue])
		i_queue = i_queue + 1
		if i_queue > #p_queue then i_queue = 1 end
	end
end)

core.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	-- Remove player from the queue
	-- Moving last element into the hole is fine in this usecase
	p_queue[p_index[name]] = p_queue[#p_queue]
	p_queue[#p_queue] = nil
	p_index[name] = nil
	-- Cleanup wieldlight after player
	local p = players[name]
	if p then
		core.fix_light(p[1], p[2])
		players[name] = nil
	end
end)

-- Cleanup wieldlights on shutdown
core.register_on_shutdown(function()
	for _, p in pairs(players) do
		core.fix_light(p[1], p[2])
	end
end)

end
