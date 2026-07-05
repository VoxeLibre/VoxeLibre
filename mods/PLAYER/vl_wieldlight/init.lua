
local players = {}

local function wieldedlight(name)
	if not name then return end
	local player = core.get_player_by_name(name)
	local pos = player:get_pos()
	local ls = player:get_wielded_item():get_definition().light_source
	pos = vector.round(pos)
	local old_p = players[name]
	if old_p then
		core.fix_light(old_p[1], old_p[2])
		old_p = nil
	end
	if ls and ls > 0 then
		local p1 = vector.offset(pos, -ls, -ls, -ls)
		local p2 = vector.offset(pos, ls, ls, ls)
		local lvm = VoxelManip(p1, p2)
		local emin, emax = lvm:get_emerged_area()
		local area = VoxelArea(emin, emax)
		local ys, zs = area.ystride, area.zstride
		local ldt = lvm:get_light_data()
		local it = area:iterp(p1, p2)
		local i = it()
		while i do
			local vd = vector.abs(area:position(i)-pos)
			local l = math.max(ls-vd.x-vd.y-vd.z, 0)
			local n = math.floor(ldt[i]/16)
			local d = math.max(ldt[i] - n*16, l)
			n = math.max(n, l)
			ldt[i] = d + n*16
			i = it()
		end
		lvm:set_light_data(ldt)
		lvm:write_to_map(false)
		lvm:close()
		players[name] = {p1, p2}
	end
end

local p_queue = {}
local i_queue = 1

core.register_on_joinplayer(function(player)
	table.insert(p_queue, player:get_player_name())
end)

core.register_globalstep(function(dtime)
	local iter_num = math.ceil(dtime * #p_queue)
	for i=0, iter_num do
		wieldedlight(p_queue[i_queue])
		i_queue = i_queue + 1
		if i_queue > #p_queue then i_queue = 1 end
	end
end)

core.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	p_queue[table.find(name)] = p_queue[#p_queue]
	p_queue[#p_queue] = nil
	local p = players[name]
	if p then
		core.fix_light(p[1], p[2])
		players[name] = nil
	end
end)

core.register_on_shutdown(function()
	for _, p in pairs(players) do
		core.fix_light(p[1], p[2])
	end
end)
