local dim = {"x", "z"}

local modpath = minetest.get_modpath(minetest.get_current_modname())

local anti_troll = minetest.settings:get_bool("wither_anti_troll_measures", false)
local peaceful = minetest.settings:get_bool("only_peaceful_mobs", false)

local function load_schem(filename)
	local file = io.open(modpath .. "/schems/" .. filename, "r")
	local data = minetest.deserialize(file:read())
	file:close()
	return data
end

local wboss_overworld = 0
local wboss_nether = 0
local wboss_end = 0

local LIM_OVERWORLD = tonumber(minetest.settings:get("wither_cap_overworld")) or 3
local LIM_NETHER = tonumber(minetest.settings:get("wither_cap_nether")) or 10
local LIM_END = tonumber(minetest.settings:get("wither_cap_end")) or 5

local wither_spawn_schems = {}

for _, d in pairs(dim) do
	wither_spawn_schems[d] = load_schem("wither_spawn_" .. d .. ".we")
end

local function check_schem(pos, schem)
	local cn_name
	for _, n in pairs(schem) do
		cn_name = minetest.get_node(vector.add(pos, n)).name
		if string.find(cn_name, "mcl_heads:wither_skeleton") then
			cn_name = "mcl_heads:wither_skeleton"
		end
		if cn_name ~= n.name then
			return false
		end
	end
	return true
end

local function remove_schem(pos, schem)
	for _, n in pairs(schem) do
		minetest.remove_node(vector.add(pos, n))
	end
end

local function check_limit(pos)
	local dim = mcl_worlds.pos_to_dimension(pos)
	if dim == "overworld" and wboss_overworld >= LIM_OVERWORLD then return false
	elseif dim == "end" and wboss_end >= LIM_END then return false
	elseif wboss_nether >= LIM_NETHER then return false
	else return true end
end

local function wither_spawn(pos, player)
	if peaceful then return end
	for _, d in pairs(dim) do
		for i = 0, 2 do
			local p = vector.add(pos, {x = 0, y = -2, z = 0, [d] = -i})
			local schem = wither_spawn_schems[d]
			if check_schem(p, schem) and (not anti_troll or check_limit(pos)) then
				remove_schem(p, schem)
				local wither = minetest.add_entity(vector.add(p, {x = 0, y = 1, z = 0, [d] = 1}), "mobs_mc:wither")
				if not wither then return end
				local wither_ent = wither:get_luaentity()
				wither_ent._spawner = player:get_player_name()
				local dim = mcl_worlds.pos_to_dimension(pos)
				if dim == "overworld" then
					wboss_overworld = wboss_overworld + 1
				elseif dim == "end" then
					wboss_end = wboss_end + 1
				else wboss_nether = wboss_nether + 1 end
				local objects = minetest.get_objects_inside_radius(pos, 20)
				for _, players in ipairs(objects) do
					if players:is_player() then
						awards.unlock(players:get_player_name(), "mcl:witheringHeights")
					end
				end
			end
		end
	end
end

local wither_head = minetest.registered_nodes["mcl_heads:wither_skeleton"]
local old_on_place = wither_head.on_place
function wither_head.on_place(itemstack, placer, pointed)
	local n = minetest.get_node(vector.offset(pointed.above,0,-1,0))
	if n and n.name  == "mcl_nether:soul_sand" then
		minetest.after(0, wither_spawn, pointed.above, placer)
	end
	return old_on_place(itemstack, placer, pointed)
end

if anti_troll then
	-- pull wither counts per dimension
	minetest.register_globalstep(function(dtime)
		wboss_overworld = mobs_mc.wither_count_overworld
		wboss_nether = mobs_mc.wither_count_nether
		wboss_end = mobs_mc.wither_count_end
		mobs_mc.wither_count_overworld = 0
		mobs_mc.wither_count_nether = 0
		mobs_mc.wither_count_end = 0
	end)
end
