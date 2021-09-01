function mcl_mobs.mob:debug(msg)
	if mcl_mobs.const.debug then
		minetest.log("[mcl_mobs] " .. tostring(self.object) .. "[" .. self.name .. "]: " .. msg)
	end
end

function mcl_mobs.mob:do_timer(name, persistent)
	local k = name .. "_timer"
	local t = persistent and self.data or self
	local v = t[k]

	if not v then
		return
	end

	local r = true

	v = v - self.dtime
	if v <= 0 then
		self:debug(k .. " elapsed")
		v = nil
		r = false
	end

	t[k] = v

	return r
end

function mcl_mobs.mob:same_dimension_as(obj)
	return mcl_worlds.pos_to_dimension(obj:get_pos()) == mcl_worlds.pos_to_dimension(self.object:get_pos())
end

function mcl_mobs.mob:can_see(obj)
	return vector.distance(obj:get_pos(), self.object:get_pos()) <= self.def.view_range
end

function mcl_mobs.mob:get_player_in_sight()
	return self:get_near_player(self.def.view_range)
end

function mcl_mobs.mob:is_player_near(radius)
	for _, player in pairs(minetest.get_connected_players()) do
		if vector.distance(pos, player:get_pos()) < radius then
			return true
		end
	end
	return false
end

function mcl_mobs.mob:get_near_player(radius, condition)
	local pos = self.object:get_pos()
	local eye_pos = vector.new(pos.x, pos.y + self.eye_height, pos.z)

	local nearest_player
	local nearest_distance = radius -- this is very big brain right there, I feel genious

	for _, player in pairs(minetest.get_connected_players()) do
		if player:get_hp() > 0 then
			local player_pos = obj:get_pos()
			if vector.distance(pos, player_pos) < nearest_distance and (not condition or condition(self, player)) and minetest.line_of_sight(eye_pos, vector.new(player_pos.x, player_pos.y + player:get_properties().eye_height, player_pos.z)) then
				nearest_player = player
				nearest_distance = distance
			end
		end
	end

	return nearest_player
end

-- I know this repeats some things from the get_near_player function but things need to be optimized so these 2 functions actually differ (believe me, even tho it looks ugly, it makes sense)
function mcl_mobs.mob:get_near_object(radius, condition)
	local eye_pos = self.object:get_pos()
	eye_pos.y = eye_pos.y + self.eye_height

	for _, obj in ipairs(minetest.get_objects_inside_radius(pos, radius)) do
		if obj ~= self.object and mcl_util.get_hp(obj) > 0 and (not condition or condition(self, obj)) then
			local obj_eye_pos = obj:get_pos()
			obj_eye_pos.y = obj_eye_pos.y + mcl_mobs.util.get_eye_height(obj)
			if minetest.line_of_sight(eye_pos, obj_eye_pos) then
				return obj
			end
		end
	end
end

-- this function gets a definition field DYNAMICALLY (if the field is a function, call it and return the result, else return the field directly)
function mcl_mobs.mob:evaluate(key, ...)
	local value = self.def[key]

	if value then
		if type(value) == "function" then
			value = value(self, ...)
		end
		return value
	end
end

--[[
--a teleport functoin
mobs.teleport = function(self, target)
	if self.do_teleport then
		if self.do_teleport(self, target) == false then
			return
		end
	end
end

--a simple helper function for mobs following
mobs.get_2d_distance = function(pos1,pos2)
	pos1.y = 0
	pos2.y = 0
	return(vector.distance(pos1, pos2))
end
]]--
