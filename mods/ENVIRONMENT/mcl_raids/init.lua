-- mcl_raids

mcl_raids = {}

-- Define the amount of illagers to spawn each wave.
mcl_raids.wave_definitions = {
	-- Pillager
	{
		illager_name = "mobs_mc:pillager", 
		wave_1 = 5, 
		wave_2 = 4, 
		wave_3 = 4, 
		wave_4 = 5, 
		wave_5 = 5, 
		extra_wave = 5,
	},
	-- Vindicator aka Angry Axeman
	{
		illager_name = "mobs_mc:vindicator", 
		wave_1 = 1, 
		wave_2 = 3, 
		wave_3 = 1, 
		wave_4 = 2, 
		wave_5 = 5, 
		extra_wave = 5,
	},
	--{"mobs_mc:ravager", 0, 0, 1, 0, 0, 2},
	-- Witch
	{
		illager_name = "mobs_mc:witch", 
		wave_1 = 0, 
		wave_2 = 0, 
		wave_3 = 1, 
		wave_4 = 3, 
		wave_5 = 1, 
		extra_wave = 1,
	},
	-- Evoker
	{
		illager_name = "mobs_mc:evoker", 
		wave_1 = 0, 
		wave_2 = 0, 
		wave_3 = 0, 
		wave_4 = 0, 
		wave_5 = 1, 
		extra_wave = 1,
	},
}

mcl_raids.spawn_raid = function(pos, wave)
	local illager_count = 0
	local spawnable = false
	local r = 32
	local n = 12
	local i = math.random(1, n)
	local raid_pos = vector.offset(pos,r * math.cos(((i-1)/n) * (2*math.pi)),0,  r * math.sin(((i-1)/n) * (2*math.pi)))
	local sn = minetest.find_nodes_in_area_under_air(vector.offset(raid_pos,0,100,0), vector.offset(raid_pos,0,-100,0), {"group:grass_block", "group:grass_block_snow", "group:snow_cover", "group:sand"})
	if sn and #sn > 0 then
		spawn_pos = sn[1]
		if spawn_pos then
			minetest.log("action", "[mcl_raids] Raid Spawn Position chosen at " .. minetest.pos_to_string(spawn_pos) .. ".")
			spawnable = true
		else
			minetest.log("action", "[mcl_raids] Raid Spawn Postion not chosen.")
		end
	elseif not sn then
		minetest.log("action", "[mcl_raids] Raid Spawn Position error, no appropriate site found.")
	end
	if spawnable and spawn_pos then
		for _, raiddefs in pairs(mcl_raids.wave_definitions) do
			local wave_count = raiddefs.wave_1
			for i = 0, wave_count do
				local entity = minetest.add_entity(spawn_pos, raiddefs.illager_name)
				if entity then
					local l = entity:get_luaentity()
					l.raidmember = true
					illager_count = illager_count + 1
				end
			end
		end
		minetest.log("action", "[mcl_raids] Raid Spawned. Illager Count: " .. illager_count .. ".")
	end
end

mcl_raids.find_villager = function(pos)
	local obj = minetest.get_objects_inside_radius(pos, 16)
	for _, objects in pairs(obj) do
		object = objects:get_luaentity()
		if object and object.name == "mobs_mc:villager" then
			minetest.log("action", "[mcl_raids] Villager Found.")
			return true
		else
			minetest.log("action", "[mcl_raids] No Villager Found.")
			return false
		end
	end
end

mcl_raids.find_bed = function(pos)
	local beds = minetest.find_nodes_in_area(vector.offset(pos, -8, -8, -8), vector.offset(pos, 8, 8, 8), "mcl_beds:bed_red_bottom")
	if beds then
		minetest.log("action", "[mcl_raids] Bed Found.")
		return true
	else
		minetest.log("action", "[mcl_raids] No Bed Found.")
		return false
	end
end

mcl_raids.find_village = function(pos)
	local bed = mcl_raids.find_bed(pos)
	local villager = mcl_raids.find_villager(pos)
	local raid_started = false
	
	if (bed and villager) and raid_started == false then
		mcl_raids.spawn_raid(pos, 1)
		raid_started = true
		minetest.log("action", "[mcl_raids] Village found, starting raid.")
		return true
	else
		minetest.log("action", "[mcl_raids] Village not found, raid is not starting.")
		return false
	end
end

minetest.register_chatcommand("spawn_raid", {
	privs = {
		server = true,
	},
	func = function(name)
		local wave = 1
		local player = minetest.get_player_by_name(name)
		local pos = player:get_pos()
		mcl_raids.spawn_raid(pos, wave)
	end
})

local etime = 0
minetest.register_globalstep(function(dtime)
	etime = dtime + etime
	if etime < 10 then return end
	etime = 0
	for _,pl in pairs(minetest.get_connected_players()) do
		if pl:get_meta():get_string("_has_bad_omen") then
			mcl_raids.find_village(pl:get_pos())
		else
			return
		end
	end
end)
