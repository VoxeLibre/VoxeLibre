local math, tonumber, vector, minetest, mcl_mobs = math, tonumber, vector, minetest, mcl_mobs
local mob_class = mcl_mobs.mob_class
local validate_vector = mcl_util.validate_vector

local active_particlespawners = {}
local disable_blood = minetest.settings:get_bool("mobs_disable_blood")
local DEFAULT_FALL_SPEED = -9.81*1.5
local PI = math.pi
local TWOPI = math.pi * 2
local PI_HALF = math.pi * 0.5 -- 90 degrees
local MAX_PITCH = math.pi * 0.45 -- about 80 degrees
local MAX_YAW = math.pi * 0.66 -- about 120 degrees

local PATHFINDING = "gowp"

local player_transfer_distance = tonumber(minetest.settings:get("player_transfer_distance")) or 128
if player_transfer_distance == 0 then player_transfer_distance = math.huge end

-- custom particle effects
function mcl_mobs.effect(pos, amount, texture, min_size, max_size, radius, gravity, glow, go_down)

	radius = radius or 2
	min_size = min_size or 0.5
	max_size = max_size or 1
	gravity = gravity or DEFAULT_FALL_SPEED
	glow = glow or 0
	go_down = go_down or false

	local ym
	if go_down then
		ym = 0
	else
		ym = -radius
	end

	minetest.add_particlespawner({
		amount = amount,
		time = 0.25,
		minpos = pos,
		maxpos = pos,
		minvel = {x = -radius, y = ym, z = -radius},
		maxvel = {x = radius, y = radius, z = radius},
		minacc = {x = 0, y = gravity, z = 0},
		maxacc = {x = 0, y = gravity, z = 0},
		minexptime = 0.1,
		maxexptime = 1,
		minsize = min_size,
		maxsize = max_size,
		texture = texture,
		glow = glow,
	})
end

function mcl_mobs.death_effect(pos, yaw, collisionbox, rotate)
	local min, max
	if collisionbox then
		min = {x=collisionbox[1], y=collisionbox[2], z=collisionbox[3]}
		max = {x=collisionbox[4], y=collisionbox[5], z=collisionbox[6]}
	else
		min = { x = -0.5, y = 0, z = -0.5 }
		max = { x = 0.5, y = 0.5, z = 0.5 }
	end
	if rotate then
		min = vector.rotate(min, {x=0, y=yaw, z=math.pi/2})
		max = vector.rotate(max, {x=0, y=yaw, z=math.pi/2})
		min, max = vector.sort(min, max)
		min = vector.multiply(min, 0.5)
		max = vector.multiply(max, 0.5)
	end

	minetest.add_particlespawner({
		amount = 50,
		time = 0.001,
		minpos = vector.add(pos, min),
		maxpos = vector.add(pos, max),
		minvel = vector.new(-5,-5,-5),
		maxvel = vector.new(5,5,5),
		minexptime = 1.1,
		maxexptime = 1.5,
		minsize = 1,
		maxsize = 2,
		collisiondetection = false,
		vertical = false,
		texture = "mcl_particles_mob_death.png^[colorize:#000000:255",
	})

	minetest.sound_play("mcl_mobs_mob_poof", {
		pos = pos,
		gain = 1.0,
		max_hear_distance = 8,
	}, true)
end


-- play sound
function mob_class:mob_sound(soundname, is_opinion, fixed_pitch)

	local soundinfo
	if self.sounds_child and self.child then
		soundinfo = self.sounds_child
	elseif self.sounds then
		soundinfo = self.sounds
	end
	if not soundinfo then
		return
	end
	local sound = soundinfo[soundname]
	if sound then
		if is_opinion and self.opinion_sound_cooloff > 0 then
			return
		end
		local pitch
		if not fixed_pitch then
			local base_pitch = soundinfo.base_pitch
			if not base_pitch then
				base_pitch = 1
			end
			if self.child and (not self.sounds_child) then
				-- Children have higher pitch
				pitch = base_pitch * 1.5
			else
				pitch = base_pitch
			end
			-- randomize the pitch a bit
			pitch = pitch + math.random(-10, 10) * 0.005
		end
		-- Should be 0.1 to 0.2 for mobs. Cow and zombie farms loud. At least have cool down.
		minetest.sound_play(sound, {
			object = self.object,
			gain = 1.0,
			max_hear_distance = self.sounds.distance,
			pitch = pitch,
		}, true)
		self.opinion_sound_cooloff = 1
	end
end

function mob_class:step_opinion_sound(dtime)
	if self.state ~= "attack" and self.state ~= PATHFINDING then

		if self.opinion_sound_cooloff > 0 then
			self.opinion_sound_cooloff = self.opinion_sound_cooloff - dtime
		end
		-- mob plays random sound at times. Should be 120. Zombie and mob farms are ridiculous
		if math.random(1, 70) == 1 then
			self:mob_sound("random", true)
		end
	end
end

function mob_class:add_texture_mod(mod)
	local full_mod = ""
	local already_added = false
	for i=1, #self.texture_mods do
		if mod == self.texture_mods[i] then
			already_added = true
		end
		full_mod = full_mod .. self.texture_mods[i]
	end
	if not already_added then
		full_mod = full_mod .. mod
		table.insert(self.texture_mods, mod)
	end
	self.object:set_texture_mod(full_mod)
end

function mob_class:remove_texture_mod(mod)
	local full_mod = ""
	local remove = {}
	for i=1, #self.texture_mods do
		if self.texture_mods[i] ~= mod then
			full_mod = full_mod .. self.texture_mods[i]
		else
			table.insert(remove, i)
		end
	end
	for i=#remove, 1 do
		table.remove(self.texture_mods, remove[i])
	end
	self.object:set_texture_mod(full_mod)
end

function mob_class:damage_effect(damage)
	-- damage particles
	if (not disable_blood) and damage > 0 then

		local amount_large = math.floor(damage / 2)
		local amount_small = damage % 2

		local pos = self.object:get_pos()

		local cb = self.initial_properties.collisionbox
		pos.y = pos.y + (cb[5] - cb[2]) * .5

		local texture = "mobs_blood.png"
		-- full heart damage (one particle for each 2 HP damage)
		if amount_large > 0 then
			mcl_mobs.effect(pos, amount_large, texture, 2, 2, 1.75, 0, nil, true)
		end
		-- half heart damage (one additional particle if damage is an odd number)
		if amount_small > 0 then
			-- TODO: Use "half heart"
			mcl_mobs.effect(pos, amount_small, texture, 1, 1, 1.75, 0, nil, true)
		end
	end
end

function mob_class:crit_effect()
	local pos = mcl_util.get_object_center(self.object)
	local texture = "mcl_particles_crit.png^[colorize:#bc7a57:127"
	mcl_mobs.effect(pos, 8, texture, 2, 2, 1.75, 0, nil, true)
end

function mob_class:remove_particlespawners(pn)
	if not active_particlespawners[pn] then return end
	if not active_particlespawners[pn][self.object] then return end
	for k,v in pairs(active_particlespawners[pn][self.object]) do
		minetest.delete_particlespawner(v)
	end
end

function mob_class:add_particlespawners(pn)
	if not active_particlespawners[pn] then active_particlespawners[pn] = {} end
	if not active_particlespawners[pn][self.object] then active_particlespawners[pn][self.object] = {} end
	for _,ps in pairs(self.particlespawners) do
		ps.attached = self.object
		ps.playername = pn
		table.insert(active_particlespawners[pn][self.object],minetest.add_particlespawner(ps))
	end
end

function mob_class:check_particlespawners(dtime)
	if not self.particlespawners then return end
	--minetest.log(dump(active_particlespawners))
	if self._particle_timer and self._particle_timer >= 1 then
		self._particle_timer = 0
		local players = {}
		for _,player in pairs(minetest.get_connected_players()) do
			local pn = player:get_player_name()
			table.insert(players,pn)
			if not active_particlespawners[pn] then
				active_particlespawners[pn] = {} end

			local dst = vector.distance(player:get_pos(),self.object:get_pos())
			if dst < player_transfer_distance and not active_particlespawners[pn][self.object] then
				self:add_particlespawners(pn)
			elseif dst >= player_transfer_distance and active_particlespawners[pn][self.object] then
				self:remove_particlespawners(pn)
			end
		end
	elseif not self._particle_timer then
		self._particle_timer = 0
	end
	self._particle_timer = self._particle_timer + dtime
end


-- set defined animation
function mob_class:set_animation(anim, fixed_frame)
	if not self.animation or not anim then return end

	if self.jockey and self.object:get_attach() then
		anim = "jockey"
	elseif not self.object:get_attach() then
		self.jockey = nil
	end
	
	if self.state == "die" and anim ~= "die" and anim ~= "stand" then return end

	if self.fly and self:flight_check() and anim == "walk" then anim = "fly" end

	self._current_animation = self._current_animation or ""

	if (anim == self._current_animation
	or not self.animation[anim .. "_start"]
	or not self.animation[anim .. "_end"]) and self.state ~= "die" then
		return
	end

	self._current_animation = anim

	local a_start = self.animation[anim .. "_start"]
	local a_end = fixed_frame and a_start or self.animation[anim .. "_end"]
	if a_start and a_end then
		self.object:set_animation({
			x = a_start,
			y = a_end},
			self.animation[anim .. "_speed"] or self.animation.speed_normal or 15,
			0, self.animation[anim .. "_loop"] ~= false)
		end
end

local function who_are_you_looking_at (self, dtime)
	if self.order == "sleep" then
		self._locked_object = nil
		return
	end

	-- was 10000 - div by 12 for avg entities as outside loop
	local stop_look_at_player = math.random() * 833 <= self.curiosity

	if self.attack then
		self._locked_object = not self.target_time_lost and self.attack or nil
	elseif self.following then
		self._locked_object = self.following
	elseif self._locked_object then
		if stop_look_at_player then self._locked_object = nil end
	elseif not self._locked_object then
		if mcl_util.check_dtime_timer(self, dtime, "step_look_for_someone", 0.2) then
			local pos = self.object:get_pos()
			for _, obj in pairs(minetest.get_objects_inside_radius(pos, 8)) do
				if obj:is_player() and vector.distance(pos, obj:get_pos()) < 4 then
					self._locked_object = obj
					break
				elseif obj:is_player() or (obj:get_luaentity() and self ~= obj:get_luaentity() and obj:get_luaentity().name == self.name) then
					-- For the wither this was 20/60=0.33, so probably need to rebalance and divide rates.
					-- but frequency of check isn't good as it is costly. Making others too infrequent requires testing
					-- was 5000 but called in loop based on entities. so div by 12 as estimate avg of entities found,
					-- then div by 20 as less freq lookup
					if math.random() * 150 <= self.curiosity then
						self._locked_object = obj
						break
					end
				end
			end
		end
	end
end

function mob_class:check_head_swivel(dtime)
	if not self.head_swivel or type(self.head_swivel) ~= "string" then return end

	who_are_you_looking_at(self, dtime)

	local newr, oldp, oldr = vector.zero(), nil, nil
	if self.object.get_bone_override then -- minetest >= 5.9
		local ov = self.object:get_bone_override(self.head_swivel)
		oldp, oldr = ov.position.vec, ov.rotation.vec
	else -- minetest < 5.9
		oldp, oldr = self.object:get_bone_position(self.head_swivel)
		oldr = vector.apply(oldr, math.rad) -- old API uses radians
	end

	local locked_object = self._locked_object
	if locked_object and (locked_object:is_player() or locked_object:get_luaentity()) and locked_object:get_hp() > 0 then
		local _locked_object_eye_height = (locked_object:is_player() and locked_object:get_properties().eye_height * 0.8) -- food in hands of player
			or (locked_object:get_luaentity() and locked_object:get_luaentity().head_eye_height) or 1.5
		local self_rot = self.object:get_rotation()
		-- If a mob is attached, should we really be messing with what they are looking at?
		-- Should this be excluded?
		if self.object:get_attach() and self.object:get_attach():get_rotation() then
			self_rot = self.object:get_attach():get_rotation()
		end

		local ps = self.object:get_pos()
		ps.y = ps.y + self.head_eye_height -- why here, instead of below? * .7
		local pt = locked_object:get_pos()
		pt.y = pt.y + _locked_object_eye_height
		local dir = vector.direction(ps, pt) -- is (pt-ps):normalize()
		local mob_yaw = math.atan2(dir.x, dir.z)
		local mob_pitch = -math.asin(dir.y) * (self.head_pitch_multiplier or 1) -- allow axis inversion

		mob_yaw = mob_yaw + self_rot.y -- to relative orientation
		while mob_yaw > PI do mob_yaw = mob_yaw - TWOPI end
		while mob_yaw < -PI do mob_yaw = mob_yaw + TWOPI end
		mob_yaw = mob_yaw * 0.8 -- lessen the effect so it become less staring
		local max_yaw = self.head_max_yaw or MAX_YAW
		mob_yaw = (mob_yaw < -max_yaw and -max_yaw) or (mob_yaw < max_yaw and mob_yaw) or max_yaw -- avoid twisting the neck

		mob_pitch = mob_pitch * 0.8 -- make it less obvious that this is computed
		local max_pitch = self.head_max_pitch or MAX_PITCH
		mob_pitch = (mob_pitch < -max_pitch and -max_pitch) or (mob_pitch < max_pitch and mob_pitch) or max_pitch

		local smoothing = (self.state == "attack" and self.attack and 0.25) or 0.05
		local old_pitch = oldr.x
		local old_yaw = (self.head_yaw == "y" and oldr.y or -oldr.z) - self.head_yaw_offset
		-- to -pi:+pi range, so we rotate over 0 when interpolating:
		while old_yaw > PI do old_yaw = old_yaw - TWOPI end
		while old_yaw < -PI do old_yaw = old_yaw + TWOPI end
		mob_pitch, mob_yaw = (mob_pitch-old_pitch)*smoothing+old_pitch, (mob_yaw-old_yaw)*smoothing+old_yaw
		-- apply the yaw to the mob
		mob_yaw = mob_yaw + self.head_yaw_offset
		if self.head_yaw == "y" then
			newr = vector.new(mob_pitch, mob_yaw, 0)
		elseif self.head_yaw == "z" then
			newr = vector.new(mob_pitch, 0, -mob_yaw) -- z yaw is opposite direction
		end
	elseif math.abs(oldr.x) + math.abs(oldr.y) + math.abs(oldr.z) > 0.05 then
		newr = vector.multiply(oldr, 0.9) -- smooth stop looking
	end

	-- 0.02 is about 1.14 degrees tolerance, to update less often
	if math.abs(oldr.x-newr.x) + math.abs(oldr.y-newr.y) + math.abs(oldr.z-newr.z) < 0.02 then return end

	if self.object.get_bone_override then -- minetest >= 5.9
		self.object:set_bone_override(self.head_swivel, {
			position = { vec = self.head_bone_position, absolute = true },
			rotation = { vec = newr, absolute = true, interpolation = 0.1 },
			scale = self.head_scale and { vec = self.head_scale, absolute = true, interpolation = 0.1 } or nil,
		})
	else -- minetest < 5.9
		-- old API uses degrees not radians and absolute positions
		self.object:set_bone_position(self.head_swivel, self.head_bone_position, vector.apply(newr, math.deg))
	end
end


function mob_class:set_animation_speed()
	local v = self.object:get_velocity()
	if v then
		if self.frame_speed_multiplier then
			local v2 = math.abs(v.x)+math.abs(v.z)*.833
			if not self.animation.walk_speed then
				self.animation.walk_speed = 25
			end
			if math.abs(v.x)+math.abs(v.z) > 0.5 then
				self.object:set_animation_frame_speed((v2/math.max(1,self.run_velocity))*self.animation.walk_speed*self.frame_speed_multiplier)
			else
				self.object:set_animation_frame_speed(25)
			end
		end
		--set_speed
		if validate_vector(self.acc) then
			self.object:add_velocity(self.acc)
		end
	end
end

minetest.register_on_leaveplayer(function(player)
	local pn = player:get_player_name()
	if not active_particlespawners[pn] then return end
	for _,m in pairs(active_particlespawners[pn]) do
		for k,v in pairs(m) do
			minetest.delete_particlespawner(v)
		end
	end
	active_particlespawners[pn] = nil
end)
