local math, vector, minetest, mcl_mobs = math, vector, minetest, mcl_mobs
local mob_class = mcl_mobs.mob_class

local PATHFINDING_FAIL_THRESHOLD = 200 -- no. of ticks to fail before giving up. 20p/s. 5s helps them get through door
local PATHFINDING_FAIL_WAIT = 30 -- how long to wait before trying to path again
local PATHING_START_DELAY = 4 -- When doing non-prioritised pathing, how long to wait until last mob pathed

local PATHFINDING_SEARCH_DISTANCE = 25 -- How big the square is that pathfinding will look

local PATHFINDING = "gowp"

local MOBS_OPEN_GATES = core.settings:get_bool("mcl_mobs_open_gates", false)

local plane_adjacents = {
	vector.new(1,0,0),
	vector.new(-1,0,0),
	vector.new(0,0,1),
	vector.new(0,0,-1),
}

local LOGGING_ON = minetest.settings:get_bool("mcl_logging_mobs_pathfinding",false)
local visualize = minetest.settings:get_bool("mcl_mobs_pathfinding_visualize",false)

local LOG_MODULE = "[Mobs Pathfinding]"
local function mcl_log (message)
	if LOGGING_ON and message then
		minetest.log(LOG_MODULE .. " " .. message)
	end
end

function output_table (wp)
	if not wp then return end
	mcl_log("wp items: ".. tostring(#wp))
	for a,b in pairs(wp) do
		mcl_log(a.. ": ".. tostring(b))
	end
end

function append_paths (wp1, wp2)
	--mcl_log("Start append")
	if not wp1 or not wp2 then
		mcl_log("Cannot append wp's")
		return
	end
	--output_table(wp1)
	--output_table(wp2)
	for _,a in pairs (wp2) do
		table.insert(wp1, a)
	end
	--mcl_log("End append")
end

local function output_enriched (wp_out)
	--mcl_log("Output enriched path")
	local i = 0
	for _,outy in pairs (wp_out) do
		i = i + 1
		local action =  outy["action"]
		if action then
			mcl_log("Pos ".. i ..":" .. minetest.pos_to_string(outy["pos"])..", type: " .. action["type"]..", action: " .. action["action"]..", target: " .. minetest.pos_to_string(action["target"]))
		end
		--mcl_log("failed attempts: " .. outy["failed_attempts"])
	end
end

-- This function will take a list of paths, and enrich it with:
-- a var for failed attempts
-- an action, such as to open or close a door where we know that pos requires that action
local function generate_enriched_path(wp_in, door_open_pos, door_close_pos, cur_door_pos)
	local wp_out = {}
	for i, cur_pos in pairs(wp_in) do
		local action = nil

		if door_open_pos and vector.equals(cur_pos, door_open_pos) then
			mcl_log ("Door open match")
			action = {type = "door", action = "open", target = cur_door_pos}
		elseif door_close_pos and vector.equals(cur_pos, door_close_pos) then
			mcl_log ("Door close match")
			action = {type = "door", action = "close", target = cur_door_pos}
		elseif cur_door_pos and vector.equals(cur_pos, cur_door_pos) then
			mcl_log("Current door pos")
			action = {type = "door", action = "open", target = cur_door_pos}
		end

		wp_out[i] = {}
		wp_out[i]["pos"] = cur_pos
		wp_out[i]["failed_attempts"] = 0
		wp_out[i]["action"] = action

		--wp_out[i] = {"pos" = cur_pos, "failed_attempts" = 0, "action" = action}
		--output_pos(cur_pos, i)
	end
	output_enriched(wp_out)
	return wp_out
end

local last_pathing_time = os.time()

function mob_class:ready_to_path(prioritised)
	-- mcl_log("Check ready to path")
	if self._pf_last_failed and (os.time() - self._pf_last_failed) < PATHFINDING_FAIL_WAIT then
		-- mcl_log("Not ready to path as last fail is less than threshold: " .. (os.time() - self._pf_last_failed))
		return false
	else
		local time_since_path_start = os.time() - last_pathing_time
		if prioritised or (time_since_path_start) > PATHING_START_DELAY then
			mcl_log("We are ready to pathfind, no previous fail or we are past threshold: "..tostring(time_since_path_start))
			return true
		end
		mcl_log("time_since_path_start: " .. tostring(time_since_path_start))
	end
end

-- This function is used to see if we can path. We could use to check a route, rather than making people move.
local function calculate_path_through_door (p, cur_door_pos, t)
	if not cur_door_pos then return end
	if t then
		mcl_log("Plot route through door from pos: " .. minetest.pos_to_string(p) .. " through " .. minetest.pos_to_string(cur_door_pos) .. ", to target: " .. minetest.pos_to_string(t))
	else
		mcl_log("Plot route through door from pos: " .. minetest.pos_to_string(p) .. " through " .. minetest.pos_to_string(cur_door_pos))
	end

	for _,v in pairs(plane_adjacents) do
		local pos_closest_to_door = vector.add(cur_door_pos,v)
		local ndef = minetest.registered_nodes[minetest.get_node(pos_closest_to_door).name]
		if not ndef.walkable then
			mcl_log("We have open space next to door at: " .. minetest.pos_to_string(pos_closest_to_door))

			local prospective_wp = minetest.find_path(p, pos_closest_to_door, PATHFINDING_SEARCH_DISTANCE, 1, 4)

			if prospective_wp then
				local other_side_of_door = vector.add(cur_door_pos,-v)
				mcl_log("Found a path to next to door".. minetest.pos_to_string(pos_closest_to_door))
				mcl_log("Opposite is: ".. minetest.pos_to_string(other_side_of_door))

				table.insert(prospective_wp, cur_door_pos)

				if t then
					mcl_log("We have t, lets go from door to target")
					local wp_otherside_door_to_target = minetest.find_path(other_side_of_door, t, PATHFINDING_SEARCH_DISTANCE, 1, 4)

					if wp_otherside_door_to_target and #wp_otherside_door_to_target > 0 then
						append_paths (prospective_wp, wp_otherside_door_to_target)
						mcl_log("We have a path from outside door to target")
						return generate_enriched_path(prospective_wp, pos_closest_to_door, other_side_of_door, cur_door_pos)
					else
						mcl_log("We cannot path from outside door to target")
					end
				else
					mcl_log("No t, just add other side of door")
					table.insert(prospective_wp, other_side_of_door)
					return generate_enriched_path(prospective_wp, pos_closest_to_door, other_side_of_door, cur_door_pos)
				end
			else
				mcl_log("Cannot path to this air block next to door.")
			end
		end
	end
end

-- we treat ignore as solid, as we cannot path there
local function is_solid(pos)
	local ndef = minetest.registered_nodes[minetest.get_node(pos).name]
	return (not ndef) or ndef.walkable
end

local function find_open_node(pos, radius)
	local r = vector.round(pos)
	if not is_solid(r) then return r end
	local above = vector.offset(r, 0, 1, 0)
	if not is_solid(above) then return above, true end -- additional return: drop last
	local n = minetest.find_node_near(pos, radius or 1, {"air"})
	if n then return n end
	return nil
end

function mob_class:gopath(target, callback_arrived, prioritised)
	if self.state == PATHFINDING then mcl_log("Already pathfinding, don't set another until done.") return end
	if not self:ready_to_path(prioritised) then return end

	last_pathing_time = os.time()

	self.order = nil

	-- maybe feet are buried in solid?
	local start = self.object:get_pos()
	local p = find_open_node(start, 1)
	if not p then -- buried?
		minetest.log("action", "Cannot path from "..minetest.pos_to_string(start).." because it is solid. Nodetype: "..minetest.get_node(start).name)
		return
	end
	-- target might be a job-site that is solid
	local t, drop_last_wp = find_open_node(target, 1)
	if not t then
		minetest.log("action", "Cannot path to "..minetest.pos_to_string(target).." because it is solid. Nodetype: "..minetest.get_node(target).name)
		return
	end

	--Check direct route
	local wp = minetest.find_path(p, t, PATHFINDING_SEARCH_DISTANCE, 1, 4)

	if not wp then
		mcl_log("### No direct path. Path through door closest to target.")
		local door_near_target = minetest.find_node_near(target, 16, {"group:door"})
		local below = door_near_target and vector.offset(door_near_target, 0, -1, 0)
		if below and minetest.get_item_group(minetest.get_node(below), "door") > 0 then door_near_target = below end
		wp = calculate_path_through_door(p, door_near_target, t)

		if not wp then
			mcl_log("### No path though door closest to target. Try door closest to origin.")
			local door_closest = minetest.find_node_near(p, 16, {"group:door"})
			local below = door_closest and vector.offset(door_closest, 0, -1, 0)
			if below and minetest.get_item_group(minetest.get_node(below), "door") > 0 then door_closest = below end
			wp = calculate_path_through_door(p, door_closest, t)

			-- Path through 2 doors
			if not wp then
				mcl_log("### Still not wp. Need to path through 2 doors.")
				local path_through_closest_door = calculate_path_through_door(p, door_closest)

				if path_through_closest_door and #path_through_closest_door > 0 then
					mcl_log("We have path through first door")
					mcl_log("Number of pos in path through door: " .. tostring(#path_through_closest_door))

					local pos_after_door_entry = path_through_closest_door[#path_through_closest_door]
					if pos_after_door_entry then
						local pos_after_door = pos_after_door_entry["pos"]
						mcl_log("pos_after_door: " .. minetest.pos_to_string(pos_after_door))
						local path_after_door = calculate_path_through_door(pos_after_door, door_near_target, t)
						if path_after_door and #path_after_door > 1 then
							mcl_log("We have path after first door")
							table.remove(path_after_door, 1) -- Remove duplicate
							wp = path_through_closest_door
							append_paths (wp, path_after_door)
						else
							mcl_log("Path after door is not good")
						end
					else
						mcl_log("No pos after door")
					end
				else
					mcl_log("Path through closest door empty or null")
				end
			else
				mcl_log("ok, we have a path through 1 door")
			end
		end
	else
		wp = generate_enriched_path(wp)
		mcl_log("We have a direct route")
	end

	if not wp then
		mcl_log("Could not calculate path")
		self._pf_last_failed = os.time()
		-- If cannot path, don't immediately try again
	end

	-- todo: we would also need to avoid overhangs, but minetest.find_path cannot help us there
	-- we really need a better pathfinder overall.

	-- try to find a way around fences and walls. This is very barebones, but at least it should
	-- help path around very simple fences *IF* there is a detour that does not require jumping or gates.
	if wp and #wp > 0 then
		local i = 1
		while i < #wp do
			-- fence or wall underneath?
			local bdef = minetest.registered_nodes[minetest.get_node(vector.offset(wp[i].pos, 0, -1, 0)).name]
			if not bdef then minetest.log("warning", "There must not be unknown nodes on path") end
			-- carpets are fine
			if bdef and (bdef.groups.carpet or 0) > 0 then
				wp[i].pos = vector.offset(wp[i].pos, 0, -1, 0)
			-- target bottom of door
			elseif bdef and (bdef.groups.door or 0) > 0 then
				wp[i].pos = vector.offset(wp[i].pos, 0, -1, 0)
			-- not walkable?
			elseif bdef and not bdef.walkable then
				wp[i].pos = vector.offset(wp[i].pos, 0, -1, 0)
				i = i - 1
			-- plan opening fence gates
			elseif MOBS_OPEN_GATES and bdef and (bdef.groups.fence_gate or 0) > 0 then
				wp[i].pos = vector.offset(wp[i].pos, 0, -1, 0)
				wp[math.max(1,i-1)].action = {type = "door", action = "open", target = wp[i].pos}
				if i+1 < #wp then
					wp[i+1].action = {type = "door", action = "close", target = wp[i].pos}
				end
			-- do not jump on fences and walls, but try to walk around
			elseif bdef and i > 1 and ((bdef.groups.fence or 0) > 0 or (bdef.groups.wall or 0) > 0) and wp[i].pos.y > wp[i-1].pos.y then
				-- find end of wall(s)
				local j = i + 1
				while j <= #wp do
					local below = vector.offset(wp[j].pos, 0, -1, 0)
					local bdef = minetest.registered_nodes[minetest.get_node(below).name]
					if not bdef or ((bdef.groups.fence or 0) == 0 and (bdef.groups.wall or 0) == 0) then
						break
					end
					j = j + 1
				end
				-- minetest.log("warning", bdef.name .. " at "..tostring(i).." end at "..(j <= #wp and tostring(j) or "nil"))
				if j <= #wp and wp[i-1].pos.y == wp[j].pos.y then
					local swp = minetest.find_path(wp[i-1].pos, wp[j].pos, PATHFINDING_SEARCH_DISTANCE, 0, 0)
					-- TODO: if we do not find a path here, consider pathing through a fence gate!
					if swp and #swp > 0 then
						for k = j-1,i,-1 do table.remove(wp, k) end
						for k = 2, #swp-1 do table.insert(wp, i-2+k, {pos = swp[k], failed_attempts = 0}) end
						--minetest.log("warning", "Monkey patch pathfinding around "..bdef.name.." successful.")
						i = i + #swp - 4
					else
						--minetest.log("warning", "Monkey patch pathfinding around "..bdef.name.." failed.")
					end
				end
			end
			i = i + 1
		end
	end
	if wp and drop_last_wp and vector.equals(wp[#wp], t) then table.remove(wp, #wp) end
	if wp and #wp > 0 then
		if visualize then
			for i = 1,#wp do
				core.add_particle({pos = wp[i].pos, expirationtime=3+i/3, size=3+2/i, velocity=vector.new(0,-0.02,0),
					texture="mcl_copper_anti_oxidation_particle.png"}) -- white stars
			end
		end

		--output_table(wp)
		self._target = t
		self.callback_arrived = callback_arrived
		self.current_target = table.remove(wp,1)
		while self.current_target and self.current_target.pos and vector.distance(p, self.current_target.pos) < 0.5 do
			--mcl_log("Skipping close initial waypoint")
			self.current_target = table.remove(wp,1)
		end
		if self.current_target and self.current_target.pos then
			self:turn_in_direction(self.current_target.pos.x - p.x, self.current_target.pos.z - p.z, 2)
			self.waypoints = wp
			self.state = PATHFINDING
			return true
		end
	end
	self:turn_in_direction(target.x - p.x, target.z - p.z, 4)
	self.state = "walk"
	self.waypoints = nil
	self.current_target = nil
	--minetest.log("no path found")
end

function mob_class:interact_with_door(action, target)
	local p = self.object:get_pos()
	--local t = minetest.get_timeofday()
	--local dd = minetest.find_nodes_in_area(vector.offset(p,-1,-1,-1),vector.offset(p,1,1,1),{"group:door"})
	--for _,d in pairs(dd) do
	if target then
		mcl_log("Door target is: ".. minetest.pos_to_string(target))

		local n = minetest.get_node(target)
		if n.name:find("_b_") or n.name:find("_t_") then
			local def = minetest.registered_nodes[n.name]
			local meta = minetest.get_meta(target)
			local closed = meta:get_int("is_open") == 0
			if closed and action == "open" and def.on_rightclick then
				mcl_log("Open door")
				def.on_rightclick(target,n,self)
			elseif not closed and action == "close" and def.on_rightclick then
				mcl_log("Close door")
				def.on_rightclick(target,n,self)
			end
		elseif MOBS_OPEN_GATES and n.name:find("_gate") then
			local def = minetest.registered_nodes[n.name]
			local meta = minetest.get_meta(target)
			local closed = meta:get_int("state") == 0
			if closed and action == "open" and def.on_rightclick then
				mcl_log("Open gate")
				def.on_rightclick(target,n,self)
			elseif not closed and action == "close" and def.on_rightclick then
				mcl_log("Close gate")
				def.on_rightclick(target,n,self)
			end
		else
			mcl_log("Not door")
		end
	else
		mcl_log("no target. cannot try and open or close door")
	end
	--end
end

function mob_class:do_pathfind_action(action)
	if action then
		mcl_log("Action present")
		local type = action["type"]
		local action_val = action["action"]
		local target = action["target"]
		if target then
			mcl_log("Target: ".. minetest.pos_to_string(target))
		end
		if type and type == "door" then
			mcl_log("Type is door")
			self.object:set_velocity(vector.zero())
			self:interact_with_door(action_val, target)
		end
	end
end

function mob_class:check_gowp(dtime)
	local p = self.object:get_pos()

	-- no destination
	if not p or not self._target then
		mcl_log("p: ".. tostring(p)..", self._target: ".. tostring(self._target))
		return
	end

	-- arrived at location, finish gowp
	local distance_to_targ = vector.distance(p,self._target)
	--mcl_log("Distance to targ: ".. tostring(distance_to_targ))
	if distance_to_targ < 1.8 then
		mcl_log("Arrived at _target")
		self.waypoints = nil
		self._target = nil
		self.current_target = nil
		self.state = "stand"
		self.order = "stand"
		self.object:set_velocity(vector.zero())
		self.object:set_acceleration(vector.zero())
		if self.callback_arrived then return self.callback_arrived(self) end
		return true
	elseif not self.current_target then
		mcl_log("Not close enough to targ: ".. tostring(distance_to_targ))
	end

	-- More pathing to be done
	local distance_to_current_target = 50
	if self.current_target and self.current_target.pos then
		local dx, dy, dz = self.current_target.pos.x-p.x, self.current_target.pos.y-p.y, self.current_target.pos.z-p.z
		distance_to_current_target = (dx*dx+dy*dy*0.5+dz*dz)^0.5 -- reduced weight on y
		--distance_to_current_target = vector.distance(p,self.current_target.pos)
	end
	-- also check next target, maybe we were too fast
	local next_target = #self.waypoints > 1 and self.waypoints[1]
	if not self.current_target["action"] and next_target and next_target.pos and distance_to_current_target < 1.5 then
		local dx, dy, dz = next_target.pos.x-p.x, next_target.pos.y-p.y, next_target.pos.z-p.z
		local distance_to_next_target = (dx*dx+dy*dy*0.5+dz*dz)^0.5 -- reduced weight on y
		if distance_to_next_target < distance_to_current_target then
			mcl_log("Skipped one waypoint.")
			self.current_target = table.remove(self.waypoints, 1) -- pop waypoint already
			distance_to_current_target = distance_to_next_target
		end
	end
	-- debugging tool
	if visualize and self.current_target and self.current_target.pos then
		core.add_particle({pos = self.current_target.pos, expirationtime=.1, size=3, velocity=vector.new(0,-0.2,0), texture="mcl_particles_flame.png"})
	end

	-- 0.6 is working but too sensitive. sends villager back too frequently. 0.7 is quite good, but not with heights
	-- 0.8 is optimal for 0.025 frequency checks and also 1... Actually. 0.8 is winning
	-- 0.9 and 1.0 is also good. Stick with unless door open or closing issues
	local threshold = self.current_target["action"] and 0.7 or 0.9
	if self.waypoints and #self.waypoints > 0 and ( not self.current_target or not self.current_target.pos or distance_to_current_target < threshold ) then
		-- We have waypoints, and are at current_target or have no current target. We need a new current_target.
		self:do_pathfind_action (self.current_target["action"])

		local failed_attempts = self.current_target["failed_attempts"]
		mcl_log("There after " .. failed_attempts .. " failed attempts. current target:".. minetest.pos_to_string(self.current_target.pos) .. ". Distance: " ..  distance_to_current_target)

		local hurry = (self.order == "sleep" or #self.waypoints > 15) and self.run_velocity or self.walk_velocity
		self.current_target = table.remove(self.waypoints, 1)
		-- use smoothing -- TODO: check for blockers before cutting corners?
		if #self.waypoints > 0 and not self.current_target["action"] then
			local curwp, nextwp = self.current_target.pos, self.waypoints[1].pos
			self:go_to_pos(vector.new(curwp.x*0.7+nextwp.x*0.3,curwp.y,curwp.z*0.7+nextwp.z*0.3), hurry)
			return
		end
		self:go_to_pos(self.current_target.pos, hurry)
		--if self.current_target["action"] then self:set_velocity(self.walk_velocity * 0.5) end
		return
	elseif self.current_target and self.current_target.pos then
		-- No waypoints left, but have current target and not close enough. Potentially last waypoint to go to.

		self.current_target["failed_attempts"] = self.current_target["failed_attempts"] + 1
		local failed_attempts = self.current_target["failed_attempts"]
		if failed_attempts >= PATHFINDING_FAIL_THRESHOLD then
			mcl_log("Failed to reach position " .. minetest.pos_to_string(self.current_target.pos) .. " too many times. At: "..minetest.pos_to_string(p).." Abandon route. Times tried: " .. failed_attempts .. " current distance "..distance_to_current_target)
			self.state = "stand"
			self.current_target = nil
			self.waypoints = nil
			self._target = nil
			self._pf_last_failed = os.time()
			self.object:set_velocity(vector.zero())
			self.object:set_acceleration(vector.zero())
			return
		end

		--mcl_log("Not at pos with failed attempts ".. failed_attempts ..": ".. minetest.pos_to_string(p) .. "self.current_target: ".. minetest.pos_to_string(self.current_target.pos) .. ". Distance: ".. distance_to_current_target)
		self:go_to_pos(self.current_target["pos"])
		-- Do i just delete current_target, and return so we can find final path.
	else
		-- Not at target, no current waypoints or current_target. Through the door and should be able to path to target.
		-- Is a little sensitive and could take 1 - 7 times. A 10 fail count might be a good exit condition.

		mcl_log("We don't have waypoints or a current target. Let's try to path to target")

		if self.waypoints then
			mcl_log("WP: " .. tostring(self.waypoints))
			mcl_log("WP num: " .. tostring(#self.waypoints))
		else
			mcl_log("No wp set")
		end
		if self.current_target then
			mcl_log("Current target: " .. tostring(self.current_target))
		else
			mcl_log("No current target")
		end

		local final_wp = minetest.find_path(p, self._target, PATHFINDING_SEARCH_DISTANCE, 1, 4)
		if final_wp then
			mcl_log("We can get to target here.")
		--	self.waypoints = final_wp
			self:go_to_pos(self._target)
		else
			-- Abandon route?
			mcl_log("Cannot plot final route to target")
		end
	end

	-- I don't think we need the following anymore, but test first.
	-- Maybe just need something to path to target if no waypoints left
	--[[ ok, let's try
	if self.current_target and self.current_target["pos"] and (self.waypoints and #self.waypoints == 0) then
		local updated_p = self.object:get_pos()
		local distance_to_cur_targ = vector.distance(updated_p,self.current_target["pos"])

		mcl_log("Distance to current target: ".. tostring(distance_to_cur_targ))
		mcl_log("Current p: ".. minetest.pos_to_string(updated_p))

		-- 1.6 is good. is 1.9 better? It could fail less, but will it path to door when it isn't after door
		if distance_to_cur_targ > 1.6 then
			mcl_log("not close to current target: ".. minetest.pos_to_string(self.current_target["pos"]))
			self:go_to_pos(self._current_target)
		else
			mcl_log("close to current target: ".. minetest.pos_to_string(self.current_target["pos"]))
			mcl_log("target is: ".. minetest.pos_to_string(self._target))
			self.current_target = nil
		end
		return
	end
	--]]--
end
