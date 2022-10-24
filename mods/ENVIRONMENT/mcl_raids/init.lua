-- mcl_raids
mcl_raids = {}

-- Define the amount of illagers to spawn each wave.
local waves = {
	{
		["mobs_mc:pillager"] = 5,
		["mobs_mc:vindicator"] = 1,
	},
	{
		["mobs_mc:pillager"] = 4,
		["mobs_mc:vindicator"] = 3,
	},
	{
		["mobs_mc:pillager"] = 4,
		["mobs_mc:vindicator"] = 1,
		["mobs_mc:witch"] = 1,
		--["mobs_mc:ravager"] = 1,
	},
	{
		["mobs_mc:pillager"] = 5,
		["mobs_mc:vindicator"] = 2,
		["mobs_mc:witch"] = 3,
	},
	{
		["mobs_mc:pillager"] = 5,
		["mobs_mc:vindicator"] = 5,
		["mobs_mc:witch"] = 1,
		["mobs_mc:evoker"] = 1,
	},
}

local extra_wave = {
	["mobs_mc:pillager"] = 5,
	["mobs_mc:vindicator"] = 5,
	["mobs_mc:witch"] = 1,
	["mobs_mc:evoker"] = 1,
	--["mobs_mc:ravager"] = 2,
}

function mcl_raids.spawn_raid(event)
	local pos = event.pos
	local wave = event.stage
	local illager_count = 0
	local spawnable = false
	local r = 32
	local n = 12
	local i = math.random(1, n)
	local raid_pos = vector.offset(pos,r * math.cos(((i-1)/n) * (2*math.pi)),0,  r * math.sin(((i-1)/n) * (2*math.pi)))
	local sn = minetest.find_nodes_in_area_under_air(vector.offset(raid_pos,-5,-50,-5), vector.offset(raid_pos,5,50,5), {"group:grass_block", "group:grass_block_snow", "group:snow_cover", "group:sand"})
	if sn and #sn > 0 then
		local spawn_pos = sn[math.random(#sn)]
		if spawn_pos then
			minetest.log("action", "[mcl_raids] Raid Spawn Position chosen at " .. minetest.pos_to_string(spawn_pos) .. ".")
			event.health_max = 0
			for m,c in pairs(waves[event.stage]) do
				for i=1,c do
					local mob = mcl_mobs.spawn(spawn_pos,m)
					local l = mob:get_luaentity()
					if l then
						event.health_max = event.health_max + l.health
						table.insert(event.mobs,mob)
					end
				end
			end
			minetest.log("action", "[mcl_raids] Raid Spawned. Illager Count: " .. #event.mobs .. ".")
		else
			minetest.log("action", "[mcl_raids] Raid Spawn Postion not chosen.")
		end
	elseif not sn then
		minetest.log("action", "[mcl_raids] Raid Spawn Position error, no appropriate site found.")
	end
end

function mcl_raids.find_villager(pos)
	local obj = minetest.get_objects_inside_radius(pos, 8)
	for _, objects in ipairs(obj) do
		local object = objects:get_luaentity()
		if object then
			if object.name ~= "mobs_mc:villager" then
				return
			elseif object.name == "mobs_mc:villager" then
				minetest.log("action", "[mcl_raids] Villager Found.")
				return true
			else
				minetest.log("action", "[mcl_raids] No Villager Found.")
				return false
			end
		end
	end
end

function mcl_raids.find_bed(pos)
	local beds = minetest.find_nodes_in_area(vector.offset(pos, -8, -8, -8), vector.offset(pos, 8, 8, 8), "mcl_beds:bed_red_bottom")
	if beds[1] then
		minetest.log("action", "[mcl_raids] Bed Found.")
		return true
	else
		minetest.log("action", "[mcl_raids] No Bed Found.")
		return false
	end
end

function mcl_raids.find_village(pos)
	local bed = mcl_raids.find_bed(pos)
	local villager = mcl_raids.find_villager(pos)
	local raid_started = false

	if (bed and villager) and raid_started == false then
		local raid = mcl_raids.spawn_raid(pos, 1)
		if raid then
			minetest.log("action", "[mcl_raids] Village found, starting raid.")
			raid_started = true
		else
			minetest.log("action", "[mcl_raids] Village found.")
		end
		return true
	elseif raid_started == true then
		minetest.log("action", "[mcl_raids] Raid already started.")
		return
	else
		minetest.log("action", "[mcl_raids] Village not found, raid is not starting.")
		return false
	end
end

minetest.register_chatcommand("spawn_raid", {
	privs = {
		debug = true,
	},
	func = function(name)
		local m = minetest.get_player_by_name(name):get_meta()
		m:set_string("_has_bad_omen","yes")
	end
})

mcl_events.register_event("raid",{
	max_stage = 5,
	health = 1,
	health_max = 1,
	cond_start  = function(self)
		local r = {}
		for _,p in pairs(minetest.get_connected_players()) do
			local m=p:get_meta()
			if m:get_string("_has_bad_omen") == "yes" then
				m:set_string("_has_bad_omen","")
				table.insert(r,p:get_pos())
			end
		end
		if #r > 0 then return r end
	end,
	on_start = function(self)
		self.mobs = {}
		self.health_max = 1
		self.health = 0
	end,
	cond_progress = function(self)
		local m = {}
		local h = 0
		for k,o in pairs(self.mobs) do
			if o and o:get_pos() then
				local l = o:get_luaentity()
				h = h + l.health
				table.insert(m,o)
			end
		end
		self.mobs = m
		self.health = h
		self.percent = math.max(0,(self.health / self.health_max ) * 100)
		if #m < 1 then
			return true end
	end,
	on_stage_begin = mcl_raids.spawn_raid,
	cond_complete = function(self)
		local m = {}
		for k,o in pairs(self.mobs) do
			if o and o:get_pos() then
				local l = o:get_luaentity()
				table.insert(m,o)
			end
		end
		return self.stage >= self.max_stage and #m < 1
	end,
	on_complete = function(self)
		--minetest.log("RAID complete")
	end,
})
