local zombie_siege_enabled = minetest.settings:get_bool("mcl_raids_zombie_siege", false)

local function check_spawn_pos(pos)
	return mcl_util.get_natural_light(pos) < 7
end

local function spawn_zombies(self)
	local nn = minetest.find_nodes_in_area_under_air(vector.offset(self.pos,-16,-16,-16),vector.offset(self.pos,16,16,16),{"group:solid"})
	table.shuffle(nn)
	for i=1,20 do
		local p = vector.offset(nn[i%#nn],0,1,0)
		if check_spawn_pos(p) then
			local m = mcl_mobs.spawn(p,"mobs_mc:zombie")
			if m then
				local l = m:get_luaentity()
				l:gopath(self.pos)
				table.insert(self.mobs, m)
				self.health_max = self.health_max + l.health
			else
				--minetest.log("Failed to spawn zombie at location: " .. minetest.pos_to_string(p))
			end
		end
	end
end

mcl_events.register_event("zombie_siege",{
	readable_name = "Zombie Siege",
	max_stage = 1,
	health = 1,
	health_max = 1,
	exclusive_to_area = 128,
	enable_bossbar = false,
	cond_start  = function(self)
		--minetest.log("Cond start zs")
		local r = {}

		if not zombie_siege_enabled then
			--minetest.log("action", "Zombie siege disabled")
			return r
		else
			--minetest.log("action", "Zombie siege start check")
		end

		local t = minetest.get_timeofday()
		local pr = PseudoRandom(minetest.get_day_count())
		local rnd = pr:next(1,10)

		if t < 0.04 and rnd == 1 then
			--minetest.log("Well, it's siege time")
			for _,p in pairs(minetest.get_connected_players()) do
				local village = mcl_raids.find_village(p:get_pos())
				if village then
					minetest.log("action", "Zombie siege is starting")
					table.insert(r,{ player = p:get_player_name(), pos = village})
				end
			end
		else
			--minetest.log("Not night for a siege, or not success")
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
	on_stage_begin = spawn_zombies,
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
		--minetest.log("SIEGE complete")
		--awards.unlock(self.player,"mcl:hero_of_the_village")
	end,
})
