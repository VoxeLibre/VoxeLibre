local S = minetest.get_translator(minetest.get_current_modname())

local math = math
local vector = vector

-- Time in seconds after which a stuck arrow is deleted
local ARROW_TIMEOUT = 60
-- Time after which stuck arrow is rechecked for being stuck
local STUCK_RECHECK_TIME = 5

--local GRAVITY = 9.81

local YAW_OFFSET = -math.pi/2

local function dir_to_pitch(dir)
	--local dir2 = vector.normalize(dir)
	local xz = math.abs(dir.x) + math.abs(dir.z)
	return -math.atan2(-dir.y, xz)
end

local function random_arrow_positions(positions, placement)
	if positions == "x" then
		return math.random(-4, 4)
	elseif positions == "y" then
		return math.random(0, 10)
	end
	if placement == "front" and positions == "z" then
		return 3
	elseif placement == "back" and positions == "z" then
		return -3
	end
	return 0
end

local mod_awards = minetest.get_modpath("awards") and minetest.get_modpath("mcl_achievements")
local mod_button = minetest.get_modpath("mesecons_button")

minetest.register_craftitem("mcl_bows:arrow", {
	description = S("Arrow"),
	_tt_help = S("Ammunition").."\n"..S("Damage from bow: 1-10").."\n"..S("Damage from dispenser: 3"),
	_doc_items_longdesc = S("Arrows are ammunition for bows and dispensers.").."\n"..
S("An arrow fired from a bow has a regular damage of 1-9. At full charge, there's a 20% chance of a critical hit dealing 10 damage instead. An arrow fired from a dispenser always deals 3 damage.").."\n"..
S("Arrows might get stuck on solid blocks and can be retrieved again. They are also capable of pushing wooden buttons."),
	_doc_items_usagehelp = S("To use arrows as ammunition for a bow, just put them anywhere in your inventory, they will be used up automatically. To use arrows as ammunition for a dispenser, place them in the dispenser's inventory. To retrieve an arrow that sticks in a block, simply walk close to it."),
	inventory_image = "mcl_bows_arrow_inv.png",
	groups = { ammo=1, ammo_bow=1, ammo_bow_regular=1, ammo_crossbow=1 },
	_on_dispense = function(itemstack, dispenserpos, droppos, dropnode, dropdir)
		-- Shoot arrow
		local shootpos = vector.add(dispenserpos, vector.multiply(dropdir, 0.51))
		local yaw = math.atan2(dropdir.z, dropdir.x) + YAW_OFFSET
		mcl_bows.shoot_arrow(itemstack:get_name(), shootpos, dropdir, yaw, nil, 19, 3)
	end,
})

local ARROW_ENTITY={
	physical = true,
	pointable = false,
	visual = "mesh",
	mesh = "mcl_bows_arrow.obj",
	visual_size = {x=-1, y=1},
	textures = {"mcl_bows_arrow.png"},
	collisionbox = {-0.19, -0.125, -0.19, 0.19, 0.125, 0.19},
	collide_with_objects = false,
	_fire_damage_resistant = true,

	_lastpos={},
	_startpos=nil,
	_damage=1,	-- Damage on impact
	_is_critical=false, -- Whether this arrow would deal critical damage
	_stuck=false,   -- Whether arrow is stuck
	_stucktimer=nil,-- Amount of time (in seconds) the arrow has been stuck so far
	_stuckrechecktimer=nil,-- An additional timer for periodically re-checking the stuck status of an arrow
	_stuckin=nil,	--Position of node in which arow is stuck.
	_shooter=nil,	-- ObjectRef of player or mob who shot it
	_is_arrow = true,

	_viscosity=0,   -- Viscosity of node the arrow is currently in
	_deflection_cooloff=0, -- Cooloff timer after an arrow deflection, to prevent many deflections in quick succession
}

-- Destroy arrow entity self at pos and drops it as an item
local function spawn_item(self, pos)
	if not minetest.is_creative_enabled("") then
		local item = minetest.add_item(pos, "mcl_bows:arrow")
		item:set_velocity({x=0, y=0, z=0})
		item:set_yaw(self.object:get_yaw())
	end
	mcl_burning.extinguish(self.object)
	self.object:remove()
end

local function damage_particles(pos, is_critical)
	if is_critical then
		minetest.add_particlespawner({
			amount = 15,
			time = 0.1,
			minpos = {x=pos.x-0.5, y=pos.y-0.5, z=pos.z-0.5},
			maxpos = {x=pos.x+0.5, y=pos.y+0.5, z=pos.z+0.5},
			minvel = {x=-0.1, y=-0.1, z=-0.1},
			maxvel = {x=0.1, y=0.1, z=0.1},
			minacc = {x=0, y=0, z=0},
			maxacc = {x=0, y=0, z=0},
			minexptime = 1,
			maxexptime = 2,
			minsize = 1.5,
			maxsize = 1.5,
			collisiondetection = false,
			vertical = false,
			texture = "mcl_particles_crit.png^[colorize:#bc7a57:127",
		})
	end
end

function ARROW_ENTITY.on_step(self, dtime)
	mcl_burning.tick(self.object, dtime, self)

	self._time_in_air = self._time_in_air + .001

	local pos = self.object:get_pos()
	local dpos = table.copy(pos) -- digital pos
	dpos = vector.round(dpos)
	local node = minetest.get_node(dpos)

	if self._stuck then
		self._stucktimer = self._stucktimer + dtime
		self._stuckrechecktimer = self._stuckrechecktimer + dtime
		if self._stucktimer > ARROW_TIMEOUT then
			mcl_burning.extinguish(self.object)
			self.object:remove()
			return
		end
		-- Drop arrow as item when it is no longer stuck
		-- FIXME: Arrows are a bit slow to react and continue to float in mid air for a few seconds.
		if self._stuckrechecktimer > STUCK_RECHECK_TIME then
			local stuckin_def
			if self._stuckin then
				stuckin_def = minetest.registered_nodes[minetest.get_node(self._stuckin).name]
			end
			-- TODO: In MC, arrow just falls down without turning into an item
			if stuckin_def and stuckin_def.walkable == false then
				spawn_item(self, pos)
				return
			end
			self._stuckrechecktimer = 0
		end
		-- Pickup arrow if player is nearby (not in Creative Mode)
		local objects = minetest.get_objects_inside_radius(pos, 1)
		for _,obj in ipairs(objects) do
			if obj:is_player() then
				if self._collectable and not minetest.is_creative_enabled(obj:get_player_name()) then
					if obj:get_inventory():room_for_item("main", "mcl_bows:arrow") then
						obj:get_inventory():add_item("main", "mcl_bows:arrow")
						minetest.sound_play("item_drop_pickup", {
							pos = pos,
							max_hear_distance = 16,
							gain = 1.0,
						}, true)
					end
				end
				mcl_burning.extinguish(self.object)
				self.object:remove()
				return
			end
		end

	-- Check for object "collision". Done every tick (hopefully this is not too stressing)
	else

		if self._damage >= 9 and self._in_player == false then
			minetest.add_particlespawner({
				amount = 1,
				time = .001,
				minpos = pos,
				maxpos = pos,
				minvel = vector.new(-0.1,-0.1,-0.1),
				maxvel = vector.new(0.1,0.1,0.1),
				minexptime = 0.5,
				maxexptime = 0.5,
				minsize = 2,
				maxsize = 2,
				collisiondetection = false,
				vertical = false,
				texture = "mobs_mc_arrow_particle.png",
				glow = 1,
			})
		end
		-- We just check for any hurtable objects nearby.
		-- The radius of 3 is fairly liberal, but anything lower than than will cause
		-- arrow to hilariously go through mobs often.
		-- TODO: Implement an ACTUAL collision detection (engine support needed).
		local objs = minetest.get_objects_inside_radius(pos, 1.5)
		local closest_object
		local closest_distance

		if self._deflection_cooloff > 0 then
			self._deflection_cooloff = self._deflection_cooloff - dtime
		end

		-- Iterate through all objects and remember the closest attackable object
		for k, obj in pairs(objs) do
			local ok = false
			-- Arrows can only damage players and mobs
			if obj:is_player() then
				ok = true
			elseif obj:get_luaentity() then
				if (obj:get_luaentity()._cmi_is_mob or obj:get_luaentity()._hittable_by_projectile) then
					ok = true
				end
			end

			if ok then
				local dist = vector.distance(pos, obj:get_pos())
				if not closest_object or not closest_distance then
					closest_object = obj
					closest_distance = dist
				elseif dist < closest_distance then
					closest_object = obj
					closest_distance = dist
				end
			end
		end

		-- If an attackable object was found, we will damage the closest one only

		if closest_object then
			local obj = closest_object
			local is_player = obj:is_player()
			local lua = obj:get_luaentity()
			if obj == self._shooter and self._time_in_air > 1.02 or obj ~= self._shooter and (is_player or (lua and (lua._cmi_is_mob or lua._hittable_by_projectile))) then
				if obj:get_hp() > 0 then
					-- Check if there is no solid node between arrow and object
					local ray = minetest.raycast(self.object:get_pos(), obj:get_pos(), true)
					for pointed_thing in ray do
						if pointed_thing.type == "object" and pointed_thing.ref == closest_object then
							-- Target reached! We can proceed now.
							break
						elseif pointed_thing.type == "node" then
							local nn = minetest.get_node(minetest.get_pointed_thing_position(pointed_thing)).name
							local def = minetest.registered_nodes[nn]
							if (not def) or def.walkable then
								-- There's a node in the way. Delete arrow without damage
								mcl_burning.extinguish(self.object)
								self.object:remove()
								return
							end
						end
					end

					-- Punch target object but avoid hurting enderman.
					if not lua or lua.name ~= "mobs_mc:enderman" then
						if self._in_player == false then
							damage_particles(self.object:get_pos(), self._is_critical)
						end
						if mcl_burning.is_burning(self.object) then
							mcl_burning.set_on_fire(obj, 5)
						end
						if self._in_player == false then
							obj:punch(self.object, 1.0, {
								full_punch_interval=1.0,
								damage_groups={fleshy=self._damage},
							}, self.object:get_velocity())
							if obj:is_player() then
								local placement
								self._placement = math.random(1, 2)
								if self._placement == 1 then
									placement = "front"
								else
									placement = "back"
								end
								self._in_player = true
								if self._placement == 2 then
									self._rotation_station = 90
								else
									self._rotation_station = -90
								end
								self._y_position = random_arrow_positions("y", placement)
								self._x_position = random_arrow_positions("x", placement)
								if self._y_position > 6 and self._x_position < 2 and self._x_position > -2 then
									self._attach_parent = "Head"
									self._y_position = self._y_position - 6
								elseif self._x_position > 2 then
									self._attach_parent = "Arm_Right"
									self._y_position = self._y_position - 3
									self._x_position = self._x_position - 2
								elseif self._x_position < -2 then
									self._attach_parent = "Arm_Left"
									self._y_position = self._y_position - 3
									self._x_position = self._x_position + 2
								else
									self._attach_parent = "Body"
								end
								self._z_rotation = math.random(-30, 30)
								self._y_rotation = math.random( -30, 30)
								self.object:set_attach(obj, self._attach_parent, {x=self._x_position,y=self._y_position,z=random_arrow_positions("z", placement)}, {x=0,y=self._rotation_station + self._y_rotation,z=self._z_rotation})
								minetest.after(150, function()
									self.object:remove()
								end)
							end
						end
					end


					if is_player then
						if self._shooter and self._shooter:is_player() and self._in_player == false then
							-- “Ding” sound for hitting another player
							minetest.sound_play({name="mcl_bows_hit_player", gain=0.1}, {to_player=self._shooter:get_player_name()}, true)
						end
					end

					if lua then
						local entity_name = lua.name
						-- Achievement for hitting skeleton, wither skeleton or stray (TODO) with an arrow at least 50 meters away
						-- NOTE: Range has been reduced because mobs unload much earlier than that ... >_>
						-- TODO: This achievement should be given for the kill, not just a hit
						if self._shooter and self._shooter:is_player() and vector.distance(pos, self._startpos) >= 20 then
							if mod_awards and (entity_name == "mobs_mc:skeleton" or entity_name == "mobs_mc:stray" or entity_name == "mobs_mc:witherskeleton") then
								awards.unlock(self._shooter:get_player_name(), "mcl:snipeSkeleton")
							end
						end
					end
					if self._in_player == false then
						minetest.sound_play({name="mcl_bows_hit_other", gain=0.3}, {pos=self.object:get_pos(), max_hear_distance=16}, true)
					end
				end
				if not obj:is_player() then
					mcl_burning.extinguish(self.object)
					if self._piercing == 0 then
						self.object:remove()
					end
				end
				return
			end
		end
	end

	-- Check for node collision
	if self._lastpos.x~=nil and not self._stuck then
		local def = minetest.registered_nodes[node.name]
		local vel = self.object:get_velocity()
		-- Arrow has stopped in one axis, so it probably hit something.
		-- This detection is a bit clunky, but sadly, MT does not offer a direct collision detection for us. :-(
		if (math.abs(vel.x) < 0.0001) or (math.abs(vel.z) < 0.0001) or (math.abs(vel.y) < 0.00001) then
			-- Check for the node to which the arrow is pointing
			local dir
			if math.abs(vel.y) < 0.00001 then
				if self._lastpos.y < pos.y then
					dir = {x=0, y=1, z=0}
				else
					dir = {x=0, y=-1, z=0}
				end
			else
				dir = minetest.facedir_to_dir(minetest.dir_to_facedir(minetest.yaw_to_dir(self.object:get_yaw()-YAW_OFFSET)))
			end
			self._stuckin = vector.add(dpos, dir)
			local snode = minetest.get_node(self._stuckin)
			local sdef = minetest.registered_nodes[snode.name]

			-- If node is non-walkable, unknown or ignore, don't make arrow stuck.
			-- This causes a deflection in the engine.
			if not sdef or sdef.walkable == false or snode.name == "ignore" then
				self._stuckin = nil
				if self._deflection_cooloff <= 0 then
					-- Lose 1/3 of velocity on deflection
					local newvel = vector.multiply(vel, 0.6667)

					self.object:set_velocity(newvel)
					-- Reset deflection cooloff timer to prevent many deflections happening in quick succession
					self._deflection_cooloff = 1.0
				end
			else

				-- Node was walkable, make arrow stuck
				self._stuck = true
				self._stucktimer = 0
				self._stuckrechecktimer = 0

				self.object:set_velocity({x=0, y=0, z=0})
				self.object:set_acceleration({x=0, y=0, z=0})

				minetest.sound_play({name="mcl_bows_hit_other", gain=0.3}, {pos=self.object:get_pos(), max_hear_distance=16}, true)

				if mcl_burning.is_burning(self.object) and snode.name == "mcl_tnt:tnt" then
					tnt.ignite(self._stuckin)
				end

				-- Push the button! Push, push, push the button!
				if mod_button and minetest.get_item_group(node.name, "button") > 0 and minetest.get_item_group(node.name, "button_push_by_arrow") == 1 then
					local bdir = minetest.wallmounted_to_dir(node.param2)
					-- Check the button orientation
					if vector.equals(vector.add(dpos, bdir), self._stuckin) then
						mesecon.push_button(dpos, node)
					end
				end
			end
		elseif (def and def.liquidtype ~= "none") then
			-- Slow down arrow in liquids
			local v = def.liquid_viscosity
			if not v then
				v = 0
			end
			--local old_v = self._viscosity
			self._viscosity = v
			local vpenalty = math.max(0.1, 0.98 - 0.1 * v)
			if math.abs(vel.x) > 0.001 then
				vel.x = vel.x * vpenalty
			end
			if math.abs(vel.z) > 0.001 then
				vel.z = vel.z * vpenalty
			end
			self.object:set_velocity(vel)
		end
	end

	-- Update yaw
	if not self._stuck then
		local vel = self.object:get_velocity()
		local yaw = minetest.dir_to_yaw(vel)+YAW_OFFSET
		local pitch = dir_to_pitch(vel)
		self.object:set_rotation({ x = 0, y = yaw, z = pitch })
	end

	-- Update internal variable
	self._lastpos={x=pos.x, y=pos.y, z=pos.z}
end

-- Force recheck of stuck arrows when punched.
-- Otherwise, punching has no effect.
function ARROW_ENTITY.on_punch(self)
	if self._stuck then
		self._stuckrechecktimer = STUCK_RECHECK_TIME
	end
end

function ARROW_ENTITY.get_staticdata(self)
	local out = {
		lastpos = self._lastpos,
		startpos = self._startpos,
		damage = self._damage,
		is_critical = self._is_critical,
		stuck = self._stuck,
		stuckin = self._stuckin,
	}
	if self._stuck then
		-- If _stucktimer is missing for some reason, assume the maximum
		if not self._stucktimer then
			self._stucktimer = ARROW_TIMEOUT
		end
		out.stuckstarttime = minetest.get_gametime() - self._stucktimer
	end
	if self._shooter and self._shooter:is_player() then
		out.shootername = self._shooter:get_player_name()
	end
	return minetest.serialize(out)
end

function ARROW_ENTITY.on_activate(self, staticdata, dtime_s)
	self._time_in_air = 1.0
	self._in_player = false
	local data = minetest.deserialize(staticdata)
	if data then
		self._stuck = data.stuck
		if data.stuck then
			if data.stuckstarttime then
				-- First, check if the stuck arrow is aleady past its life timer.
				-- If yes, delete it.
				self._stucktimer = minetest.get_gametime() - data.stuckstarttime
				if self._stucktimer > ARROW_TIMEOUT then
					mcl_burning.extinguish(self.object)
					self.object:remove()
					return
				end
			end

			-- Perform a stuck recheck on the next step.
			self._stuckrechecktimer = STUCK_RECHECK_TIME

			self._stuckin = data.stuckin
		end

		-- Get the remaining arrow state
		self._lastpos = data.lastpos
		self._startpos = data.startpos
		self._damage = data.damage
		self._is_critical = data.is_critical
		if data.shootername then
			local shooter = minetest.get_player_by_name(data.shootername)
			if shooter and shooter:is_player() then
				self._shooter = shooter
			end
		end
	end
	self.object:set_armor_groups({ immortal = 1 })
end

minetest.register_entity("mcl_bows:arrow_entity", ARROW_ENTITY)

if minetest.get_modpath("mcl_core") and minetest.get_modpath("mcl_mobitems") then
	minetest.register_craft({
		output = "mcl_bows:arrow 4",
		recipe = {
			{"mcl_core:flint"},
			{"mcl_core:stick"},
			{"mcl_mobitems:feather"}
		}
	})
end

if minetest.get_modpath("doc_identifier") then
	doc.sub.identifier.register_object("mcl_bows:arrow_entity", "craftitems", "mcl_bows:arrow")
end
