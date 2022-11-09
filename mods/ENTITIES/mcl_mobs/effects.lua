local math, vector, minetest, mcl_mobs = math, vector, minetest, mcl_mobs
local mob_class = mcl_mobs.mob_class
local active_particlespawners = {}
local DEFAULT_FALL_SPEED = -9.81*1.5

local player_transfer_distance = tonumber(minetest.settings:get("player_transfer_distance")) or 128
if player_transfer_distance == 0 then player_transfer_distance = math.huge end

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
		minetest.sound_play(sound, {
			object = self.object,
			gain = 1.0,
			max_hear_distance = self.sounds.distance,
			pitch = pitch,
		}, true)
		self.opinion_sound_cooloff = 1
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

function mob_class:damage_effect(damage)
	-- damage particles
	if (not disable_blood) and damage > 0 then

		local amount_large = math.floor(damage / 2)
		local amount_small = damage % 2

		local pos = self.object:get_pos()

		pos.y = pos.y + (self.collisionbox[5] - self.collisionbox[2]) * .5

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

mcl_mobs.death_effect = function(pos, yaw, collisionbox, rotate)
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
	if not self.animation or not anim then
		return
	end
	if self.state == "die" and anim ~= "die" and anim ~= "stand" then
		return
	end

	if self.jockey then
		anim = "jockey"
	end


	if self:flight_check() and self.fly and anim == "walk" then anim = "fly" end

	self._current_animation = self._current_animation or ""

	if (anim == self._current_animation
	or not self.animation[anim .. "_start"]
	or not self.animation[anim .. "_end"]) and self.state ~= "die" then
		return
	end

	self._current_animation = anim

	local a_start = self.animation[anim .. "_start"]
	local a_end
	if fixed_frame then
		a_end = a_start
	else
		a_end = self.animation[anim .. "_end"]
	end
	if a_start and a_end then
		self.object:set_animation({
			x = a_start,
			y = a_end},
			self.animation[anim .. "_speed"] or self.animation.speed_normal or 15,
			0, self.animation[anim .. "_loop"] ~= false)
		end
end

-- above function exported for mount.lua
function mcl_mobs:set_animation(self, anim)
	self:set_animation(anim)
end
