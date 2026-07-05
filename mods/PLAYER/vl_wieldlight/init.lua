if core.settings:get_bool("enable_vl_wieldlight", true) then

local players = {}

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
	if ls and ls > 0 then
		-- Acquire minimum LVM for the light source power
		local p1 = vector.offset(pos, -ls, -ls, -ls)
		local p2 = vector.offset(pos, ls, ls, ls)
		local lvm = VoxelManip(p1, p2)
		local ldt = lvm:get_light_data() -- flat array of param1 values
		-- Get iterator for the sub-area of the LVM
		local emin, emax = lvm:get_emerged_area()
		local area = VoxelArea(emin, emax)
		local it = area:iterp(p1, p2)
		local i = it()
		while i do
			local vd = vector.abs(area:position(i)-pos) -- Manhattan distance
			local l = math.max(ls-vd.x-vd.y-vd.z, 0) -- scalarization to light value
			local n = math.floor(ldt[i]/16) -- current night lightbank
			local d = math.max(ldt[i] - n*16, l) -- amended day lightbank
			n = math.max(n, l) -- amended night lightbank
			ldt[i] = d + n*16 -- pack into param1 again
			i = it()
		end
		lvm:set_light_data(ldt)
		lvm:write_to_map(false)
		lvm:close()
		players[name] = {p1, p2}
	end
end

local p_queue = {} -- array-based cyclic queue
local i_queue = 1 -- queue current element index

core.register_on_joinplayer(function(player)
	-- Add player into queue
	table.insert(p_queue, player:get_player_name())
end)

core.register_globalstep(function(dtime)
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
	p_queue[table.find(name)] = p_queue[#p_queue]
	p_queue[#p_queue] = nil
	local p = players[name]
	-- Cleanup wieldlight after player
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
