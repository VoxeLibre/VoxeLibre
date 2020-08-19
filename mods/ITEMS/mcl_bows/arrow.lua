local S = minetest.get_translator("mcl_bows")

-- Time in seconds after which a stuck arrow is deleted
local ARROW_TIMEOUT = 60
-- Time after which stuck arrow is rechecked for being stuck
local STUCK_RECHECK_TIME = 5

local GRAVITY = 9.81

local YAW_OFFSET = -math.pi/2

local dir_to_pitch = function(dir)
	local dir2 = vector.normalize(dir)
	local xz = math.abs(dir.x) + math.abs(dir.z)
	return -math.atan2(-dir.y, xz)
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
	groups = { ammo=1, ammo_bow=1 },
	_on_dispense = function(itemstack, dispenserpos, droppos, dropnode, dropdir)
		-- Shoot arrow
		local shootpos = vector.add(dispenserpos, vector.multiply(dropdir, 0.51))
		local yaw = math.atan2(dropdir.z, dropdir.x) + YAW_OFFSET
		mcl_bows.shoot_arrow(itemstack:get_name(), shootpos, dropdir, yaw, nil, 19, 3)
	end,
})

-- This is a fake node, used as model for the arrow entity.
-- It's not supposed to be usable as item or real node.
-- TODO: Use a proper mesh for the arrow entity
minetest.register_node("mcl_bows:arrow_box", {
	drawtype = "nodebox",
	is_ground_content = false,
	node_box = {
		type = "fixed",
		fixed = {
			-- Shaft
			{-6.5/17, -1.5/17, -1.5/17, -4.5/17, 1.5/17, 1.5/17},
			{-4.5/17, -0.5/17, -0.5/17, 5.5/17, 0.5/17, 0.5/17},
			{5.5/17, -1.5/17, -1.5/17, 6.5/17, 1.5/17, 1.5/17},
			-- Tip
			{-4.5/17, 2.5/17, 2.5/17, -3.5/17, -2.5/17, -2.5/17},
			{-8.5/17, 0.5/17, 0.5/17, -6.5/17, -0.5/17, -0.5/17},
			-- Fletching
			{6.5/17, 1.5/17, 1.5/17, 7.5/17, 2.5/17, 2.5/17},
			{7.5/17, -2.5/17, 2.5/17, 6.5/17, -1.5/17, 1.5/17},
			{7.5/17, 2.5/17, -2.5/17, 6.5/17, 1.5/17, -1.5/17},
			{6.5/17, -1.5/17, -1.5/17, 7.5/17, -2.5/17, -2.5/17},

			{7.5/17, 2.5/17, 2.5/17, 8.5/17, 3.5/17, 3.5/17},
			{8.5/17, -3.5/17, 3.5/17, 7.5/17, -2.5/17, 2.5/17},
			{8.5/17, 3.5/17, -3.5/17, 7.5/17, 2.5/17, -2.5/17},
			{7.5/17, -2.5/17, -2.5/17, 8.5/17, -3.5/17, -3.5/17},
		}
	},
	tiles = {"mcl_bows_arrow.png^[transformFX", "mcl_bows_arrow.png^[transformFX", "mcl_bows_arrow_back.png", "mcl_bows_arrow_front.png", "mcl_bows_arrow.png", "mcl_bows_arrow.png^[transformFX"},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	groups = {not_in_creative_inventory=1, dig_immediate=3},
	drop = "",
	node_placement_prediction = "",
	on_construct = function(pos)
		minetest.log("error", "[mcl_bows] Trying to construct mcl_bows:arrow_box at "..minetest.pos_to_string(pos))
		minetest.remove_node(pos)
	end,
})

local ARROW_ENTITY={
	physical = true,
	visual = "wielditem",
	visual_size = {x=0.4, y=0.4},
	textures = {"mcl_bows:arrow_box"},
	collisionbox = {-0.19, -0.125, -0.19, 0.19, 0.125, 0.19},
	collide_with_objects = false,

	_lastpos={},
	_startpos=nil,
	_damage=1,	-- Damage on impact
	_is_critical=false, -- Whether this arrow would deal critical damage
	_stuck=false,   -- Whether arrow is stuck
	_stucktimer=nil,-- Amount of time (in seconds) the arrow has been stuck so far
	_stuckrechecktimer=nil,-- An additional timer for periodically re-checking the stuck status of an arrow
	_stuckin=nil,	--Position of node in which arow is stuck.
	_shooter=nil,	-- ObjectRef of player or mob who shot it

	_viscosity=0,   -- Viscosity of node the arrow is currently in
	_deflection_cooloff=0, -- Cooloff timer after an arrow deflection, to prevent many deflections in quick succession
}

-- Destroy arrow entity self at pos and drops it as an item
local spawn_item = function(self, pos)
	if not minetest.is_creative_enabled("") then
		local item = minetest.add_item(pos, "mcl_bows:arrow")
		item:set_velocity({x=0, y=0, z=0})
		item:set_yaw(self.object:get_yaw())
	end
	self.object:remove()
end

local damage_particles = function(pos, is_critical)
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

ARROW_ENTITY.on_step = function(self, dtime)
	local pos = self.object:get_pos()
	local dpos = table.copy(pos) -- digital pos
	dpos = vector.round(dpos)
	local node = minetest.get_node(dpos)

	if self._stuck then
		self._stucktimer = self._stucktimer + dtime
		self._stuckrechecktimer = self._stuckrechecktimer + dtime
		if self._stucktimer > ARROW_TIMEOUT then
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
				if not minetest.is_creative_enabled(obj:get_player_name()) then
					if obj:get_inventory():room_for_item("main", "mcl_bows:arrow") then
						obj:get_inventory():add_item("main", "mcl_bows:arrow")
						minetest.sound_play("item_drop_pickup", {
							pos = pos,
							max_hear_distance = 16,
							gain = 1.0,
						}, true)
					end
				end
				self.object:remove()
				return
			end
		end

	-- Check for object "collision". Done every tick (hopefully this is not too stressing)
	else
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
			if obj ~= self._shooter and obj:is_player() then
				ok = true
			elseif obj:get_luaentity() ~= nil then
				if obj ~= self._shooter and obj:get_luaentity()._cmi_is_mob then
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
		if closest_object ~= nil then
			local obj = closest_object
			local is_player = obj:is_player()
			local lua = obj:get_luaentity()
			if obj ~= self._shooter and (is_player or (lua and lua._cmi_is_mob)) then
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
								self.object:remove()
								return
							end
						end
					end

					-- Punch target object but avoid hurting enderman.
					if lua then
						if lua.name ~= "mobs_mc:enderman" then
							damage_particles(self.object:get_pos(), self._is_critical)
							obj:punch(self.object, 1.0, {
								full_punch_interval=1.0,
								damage_groups={fleshy=self._damage},
							}, nil)
						end
					else
						damage_particles(self.object:get_pos(), self._is_critical)
						obj:punch(self.object, 1.0, {
							full_punch_interval=1.0,
							damage_groups={fleshy=self._damage},
						}, nil)
					end


					if is_player then
						if self._shooter and self._shooter:is_player() then
							-- “Ding” sound for hitting another player
							minetest.sound_play({name="mcl_bows_hit_player", gain=0.1}, {to_player=self._shooter}, true)
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
				end
				self.object:remove()
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
			local old_v = self._viscosity
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
ARROW_ENTITY.on_punch = function(self)
	if self._stuck then
		self._stuckrechecktimer = STUCK_RECHECK_TIME
	end
end

ARROW_ENTITY.get_staticdata = function(self)
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

ARROW_ENTITY.on_activate = function(self, staticdata, dtime_s)
	local data = minetest.deserialize(staticdata)
	if data then
		self._stuck = data.stuck
		if data.stuck then
			if data.stuckstarttime then
				-- First, check if the stuck arrow is aleady past its life timer.
				-- If yes, delete it.
				self._stucktimer = minetest.get_gametime() - data.stuckstarttime
				if self._stucktimer > ARROW_TIMEOUT then
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
		output = 'mcl_bows:arrow 4',
		recipe = {
			{'mcl_core:flint'},
			{'mcl_core:stick'},
			{'mcl_mobitems:feather'}
		}
	})
end

if minetest.get_modpath("doc_identifier") ~= nil then
	doc.sub.identifier.register_object("mcl_bows:arrow_entity", "craftitems", "mcl_bows:arrow")
end
