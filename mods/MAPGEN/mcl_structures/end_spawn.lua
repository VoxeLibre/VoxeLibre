local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local worldseed = minetest.get_mapgen_setting("seed")

-- mcl_structures_end_exit_portal open is triggered by mods/ENTITIES/mobs_mc/ender_dragon.lua
mcl_structures.spawn_end_exit_portal = function(pos)
	local schematic = vl_structures.load_schematic(modpath.."/schematics/mcl_structures_end_exit_portal.mts")
	vl_structures.place_schematic(pos, 0, schematic, "0", { name="end_exit_portal_open", prepare = false })
end

-- mcl_structures_end_gateway_portal.mts: see mods/ITEMS/mcl_portals/portal_gateway.lua
mcl_structures.spawn_end_gateway_portal = function(pos)
	local schematic = vl_structures.load_schematic(modpath.."/schematics/mcl_structures_end_gateway_portal.mts")
	vl_structures.place_schematic(pos, 0, schematic, "0", { name="end_gateway_portal", prepare = false })
end

local function make_endspike(pos, rad, height)
	-- FIXME: why find_nodes, not just use the circle?
	local nn = minetest.find_nodes_in_area(vector.offset(pos, -rad, 0, -rad), vector.offset(pos, rad, 0, rad), {"air", "group:solid"})
	table.sort(nn,function(a, b)
		return vector.distance(pos, a) < vector.distance(pos, b)
	end)
	local nodes = {}
	for i = 1, math.ceil(#nn * 0.55) do
		for j = 1, height do
			table.insert(nodes, vector.offset(nn[i], 0, j, 0))
		end
	end
	minetest.bulk_swap_node(nodes, {name = "mcl_core:obsidian"})
	return vector.offset(pos, 0, height, 0)
end

function make_cage(pos, rad)
	if not xpanes then return end
	local nodes = {}
	local r = math.max(1, rad - 2)
	for y = 0, rad * 2 do for xz = -r, r do
		table.insert(nodes,vector.add(pos,vector.new(xz,y, r)))
		table.insert(nodes,vector.add(pos,vector.new(xz,y,-r)))
		table.insert(nodes,vector.add(pos,vector.new( r,y,xz)))
		table.insert(nodes,vector.add(pos,vector.new(-r,y,xz)))
	end end
	minetest.bulk_swap_node(nodes, {name = "xpanes:bar_flat"} )
	for _,p in pairs(nodes) do xpanes.update_pane(p) end
end

local function get_points_on_circle(pos,r,n)
	local rt, step = {}, 2 * math.pi / n
	for i=1, n do
		table.insert(rt, vector.offset(pos, r * math.cos((i-1)*step), 0,  r * math.sin((i-1)*step)))
	end
	return rt
end

minetest.register_on_mods_loaded(function()
-- TODO: use LVM?
vl_mapgen.register_generator("end structures", nil, function(minp, maxp, blockseed)
	if maxp.y < mcl_vars.mg_end_min or minp.y > mcl_vars.mg_end_max then return end
	-- end spawn obsidian platform
	local pos = mcl_vars.mg_end_platform_pos
	if vector.in_area(pos, minp, maxp) then
		local obby = minetest.find_nodes_in_area(vector.offset(pos,-2,0,-2),vector.offset(pos,2,0,2),{"air","mcl_end:end_stone"})
		local air  = minetest.find_nodes_in_area(vector.offset(pos,-2,1,-2),vector.offset(pos,2,3,2),{"air","mcl_end:end_stone"})
		minetest.bulk_swap_node(obby,{name="mcl_core:obsidian"})
		minetest.bulk_swap_node(air,{name="air"})
	end
	-- end exit portal and pillars
	local pos = mcl_vars.mg_end_exit_portal_pos
	if vector.in_area(pos, minp, maxp) then
		local pr = PcgRandom(worldseed)
		-- emerge pillars
		local p1, p2 = vector.offset(pos, -43-6, -10, -43-6), vector.offset(pos, 43+6, 12*6-10, 43+6)
		minetest.emerge_area(p1, p2, function(_, _, calls_remaining)
			if calls_remaining ~= 0 then return end
			for _, p in ipairs(get_points_on_circle(vector.offset(pos, 0, -10, 0), 43, 10)) do
				local rad = pr:next(3,6)
				local top = make_endspike(p, rad, rad * 2 * pr:next(4,6) - 10)
				minetest.swap_node(vector.offset(top, 0, 1, 0), {name = "mcl_core:bedrock"})
				minetest.add_entity(vector.offset(top, 0, 2, 0), "mcl_end:crystal")
				if pr:next(1, 3) == 1 then make_cage(vector.offset(top, 0, 1, 0), rad) end
			end
		end)
		-- emerge end portal
		local schematic = vl_structures.load_schematic(modpath.."/schematics/mcl_structures_end_exit_portal.mts")
		vl_structures.place_schematic(pos, 0, schematic, "0", { name = "end portal", prepare = false,
			after_place = function(pos,def,pr,pmin,pmax,size,rot)
				-- spawn ender dragon
				if minetest.settings:get_bool("only_peaceful_mobs", false) then return end
				minetest.bulk_swap_node(minetest.find_nodes_in_area(pmin, pmax, {"mcl_portals:portal_end"}), { name="air" })
				local obj = minetest.add_entity(vector.offset(pos, 3, 11, 3), "mobs_mc:enderdragon")
				if obj then
					local dragon_entity = obj:get_luaentity()
					dragon_entity._portal_pos = pos
					dragon_entity._initial = true
				else
					minetest.log("error", "[vl_mapgen] ERROR! Ender dragon doesn't want to spawn")
				end
			end}, pr)
	end
end, 100)
end)
