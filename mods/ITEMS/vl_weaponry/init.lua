local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)


local hammer_tt = S("Can crush blocks") .. "\n" .. S("Increased knockback")
local hammer_longdesc = S("Hammers are great in melee combat, as they deal high damage with increased knockback and can endure countless battles. Hammers can also be used to crush things.")
local hammer_use = S("To crush a block, dig the block with the hammer. This only works with some blocks.")

local spear_tt = S("Reaches farther") .. "\n" .. S("Can be thrown")
local spear_longdesc = S("Spears are great in melee combat, as they have an increased reach. They can also be thrown.")
local spear_use = S("To throw a spear, hold it in your hand, then hold use (rightclick) in the air.")

local wield_scale = mcl_vars.tool_wield_scale

local GRAVITY = 9.81
local YAW_OFFSET = -math.pi/2
local function dir_to_pitch(dir)
	--local dir2 = vector.normalize(dir)
	local xz = math.abs(dir.x) + math.abs(dir.z)
	return -math.atan2(-dir.y, xz)
end
-- Time after which stuck spear is rechecked for being stuck
local STUCK_RECHECK_TIME = 5
-- Time in seconds after which a stuck spear is deleted
local SPEAR_TIMEOUT = 180
local SPEAR_ENTITY={
	physical = true,
	pointable = false,
	visual = "item",
	visual_size = {x=-0.5, y=-0.5},
	textures = {"vl_weaponry:spear_wood"},
	collisionbox = {-0.19, -0.125, -0.19, 0.19, 0.125, 0.19},
	collide_with_objects = false,
	_fire_damage_resistant = true,

	_lastpos={},
	_startpos=nil,
	_damage=1,	-- Damage on impact
	_is_critical=false, -- Whether this spear would deal critical damage
	_stuck=false,   -- Whether spear is stuck
	_stucktimer=nil,-- Amount of time (in seconds) the spear has been stuck so far
	_stuckrechecktimer=nil,-- An additional timer for periodically re-checking the stuck status of an spear
	_stuckin=nil,	--Position of node in which spear is stuck.
	_shooter=nil,	-- ObjectRef of player or mob who threw it
	_is_arrow = true,
	_in_player = false,
	_blocked = false,
	_viscosity = 0,   -- Viscosity of node the spear is currently in
	_deflection_cooloff = 0, -- Cooloff timer after an spear deflection, to prevent many deflections in quick succession
	_itemstack = nil, -- ItemStack of the original object
}

-- Destroy spear entity self at pos and drops it as an item
local function spawn_item(self, pos)
	if not minetest.is_creative_enabled("") then
		local item = minetest.add_item(pos, self._itemstack)
		item:set_velocity(vector.new(0, 0, 0))
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
			minpos = vector.offset(pos, -0.5, -0.5, -0.5),
			maxpos = vector.offset(pos, 0.5, 0.5, 0.5),
			minvel = vector.new(-0.1, -0.1, -0.1),
			maxvel = vector.new(0.1, 0.1, 0.1),
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

function SPEAR_ENTITY.on_step(self, dtime)
	mcl_burning.tick(self.object, dtime, self)
	-- mcl_burning.tick may remove object immediately
	if not self.object:get_pos() then return end

	self._time_in_air = self._time_in_air + .001

	local pos = self.object:get_pos()
	local dpos = vector.round(vector.new(pos)) -- digital pos
	local node = minetest.get_node(dpos)

	if self._stuck then
		self._stucktimer = self._stucktimer + dtime
		self._stuckrechecktimer = self._stuckrechecktimer + dtime
		if self._stucktimer > SPEAR_TIMEOUT then
			spawn_item(self, pos)
			return
		end
		-- Drop spear as item when it is no longer stuck
		if self._stuckrechecktimer > STUCK_RECHECK_TIME then
			local stuckin_def
			if self._stuckin then
				stuckin_def = minetest.registered_nodes[minetest.get_node(self._stuckin).name]
			end
			-- TODO: fall down without turning into an item?
			if stuckin_def and stuckin_def.walkable == false then
				spawn_item(self, pos)
				return
			end
			self._stuckrechecktimer = 0
		end
		-- Pickup spear if player is nearby (not in Creative Mode)
		local objects = minetest.get_objects_inside_radius(pos, 1)
		for _,obj in ipairs(objects) do
			if obj:is_player() then
				if self._collectable and not minetest.is_creative_enabled(obj:get_player_name()) then
					if obj:get_inventory():room_for_item("main", self._itemstack) then
						obj:get_inventory():add_item("main", self._itemstack)
						minetest.sound_play("item_drop_pickup", {
							pos = pos,
							max_hear_distance = 16,
							gain = 1.0,
						}, true)
						mcl_burning.extinguish(self.object)
						self.object:remove()
					end
				else
					spawn_item(self, pos)
				end
				return
			end
		end

	-- Check for object "collision". Done every tick (hopefully this is not too stressing)
	else

		if self._damage >= 9 and self._in_player == false then
			minetest.add_particlespawner({
				amount = 20,
				time = .2,
				minpos = vector.new(0,0,0),
				maxpos = vector.new(0,0,0),
				minvel = vector.new(-0.1,-0.1,-0.1),
				maxvel = vector.new(0.1,0.1,0.1),
				minexptime = 0.5,
				maxexptime = 0.5,
				minsize = 2,
				maxsize = 2,
				attached = self.object,
				collisiondetection = false,
				vertical = false,
				texture = "mobs_mc_arrow_particle.png",
				glow = 1,
			})
		end

		local closest_object
		local closest_distance

		if self._deflection_cooloff > 0 then
			self._deflection_cooloff = self._deflection_cooloff - dtime
		end

		local spear_dir = self.object:get_velocity()
		--create a raycast from the spear based on the velocity of the spear to deal with lag
		local raycast = minetest.raycast(pos, vector.add(pos, vector.multiply(spear_dir, 0.1)), true, false)
		for hitpoint in raycast do
			if hitpoint.type == "object" then
				-- find the closest object that is in the way of the spear
				local ok = false
				if hitpoint.ref:is_player() and enable_pvp then
					ok = true
				elseif not hitpoint.ref:is_player() and hitpoint.ref:get_luaentity() then
					if (hitpoint.ref:get_luaentity().is_mob or hitpoint.ref:get_luaentity()._hittable_by_projectile) then
						ok = true
					end
				end
				if ok then
					local dist = vector.distance(hitpoint.ref:get_pos(), pos)
					if not closest_object or not closest_distance then
						closest_object = hitpoint.ref
						closest_distance = dist
					elseif dist < closest_distance then
						closest_object = hitpoint.ref
						closest_distance = dist
					end
				end
			end
		end

		if closest_object then
			local obj = closest_object
			local is_player = obj:is_player()
			local lua = obj:get_luaentity()
			if obj == self._shooter and self._time_in_air > 1.02 or obj ~= self._shooter and (is_player or (lua and (lua.is_mob or lua._hittable_by_projectile))) then
				if obj:get_hp() > 0 then
					-- Check if there is no solid node between spear and object
					local ray = minetest.raycast(self.object:get_pos(), obj:get_pos(), true)
					for pointed_thing in ray do
						if pointed_thing.type == "object" and pointed_thing.ref == closest_object then
							-- Target reached! We can proceed now.
							break
						elseif pointed_thing.type == "node" then
							local nn = minetest.get_node(minetest.get_pointed_thing_position(pointed_thing)).name
							local def = minetest.registered_nodes[nn]
							if (not def) or def.walkable then
								-- There's a node in the way. Delete spear without damage
								spawn_item(self, pos)
								return
							end
						end
					end

					-- Punch target object but avoid hurting enderman.
					if not lua or lua.name ~= "mobs_mc:enderman" then
						if not self._in_player then
							damage_particles(vector.add(pos, vector.multiply(self.object:get_velocity(), 0.1)), self._is_critical)
						end
						if mcl_burning.is_burning(self.object) then
							mcl_burning.set_on_fire(obj, 5)
						end
						if not self._in_player and not self._blocked then
							obj:punch(self.object, 1.0, {
								full_punch_interval=1.0,
								damage_groups={fleshy=self._damage},
							}, self.object:get_velocity())
							if obj:is_player() then
								if not mcl_shields.is_blocking(obj) then
									spawn_item(self, pos)
								else
									self._blocked = true
									self.object:set_velocity(vector.multiply(self.object:get_velocity(), -0.25))
								end
								minetest.after(150, function()
									spawn_item(self, pos)
								end)
							else
								spawn_item(self, pos)
							end
						end
					end


					if is_player then
						if self._shooter and self._shooter:is_player() and not self._in_player and not self._blocked then
							-- “Ding” sound for hitting another player
							minetest.sound_play({name="mcl_bows_hit_player", gain=0.1}, {to_player=self._shooter:get_player_name()}, true)
						end
					end

					if not self._in_player and not self._blocked then
						minetest.sound_play({name="mcl_bows_hit_other", gain=0.3}, {pos=self.object:get_pos(), max_hear_distance=16}, true)
					end
				end
				if not obj:is_player() then
					mcl_burning.extinguish(self.object)
					if self._piercing == 0 then
						spawn_item(self, pos)
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
		-- Spear has stopped in one axis, so it probably hit something.
		-- This detection is a bit clunky, but sadly, MT does not offer a direct collision detection for us. :-(
		if (math.abs(vel.x) < 0.0001) or (math.abs(vel.z) < 0.0001) or (math.abs(vel.y) < 0.00001) then
			-- Check for the node to which the spear is pointing
			local dir
			if math.abs(vel.y) < 0.00001 then
				if self._lastpos.y < pos.y then
					dir = vector.new(0, 1, 0)
				else
					dir = vector.new(0, -1, 0)
				end
			else
				dir = minetest.facedir_to_dir(minetest.dir_to_facedir(minetest.yaw_to_dir(self.object:get_yaw()-YAW_OFFSET)))
			end
			self._stuckin = vector.add(dpos, dir)
			local snode = minetest.get_node(self._stuckin)
			local sdef = minetest.registered_nodes[snode.name]

			-- If node is non-walkable, unknown or ignore, don't make spear stuck.
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

				-- Node was walkable, make spear stuck
				self._stuck = true
				self._stucktimer = 0
				self._stuckrechecktimer = 0

				self.object:set_velocity(vector.new(0, 0, 0))
				self.object:set_acceleration(vector.new(0, 0, 0))

				minetest.sound_play({name="mcl_bows_hit_other", gain=0.3}, {pos=self.object:get_pos(), max_hear_distance=16}, true)

				if mcl_burning.is_burning(self.object) and snode.name == "mcl_tnt:tnt" then
					tnt.ignite(self._stuckin)
				end

				-- Ignite Campfires
				if mod_campfire and mcl_burning.is_burning(self.object) and minetest.get_item_group(snode.name, "campfire") ~= 0 then
					mcl_campfires.light_campfire(self._stuckin)
				end

				-- Activate target
				if mod_target and snode.name == "mcl_target:target_off" then
					mcl_target.hit(self._stuckin, 1) --10 redstone ticks
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
			-- Slow down spear in liquids
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
	self._lastpos = pos
end

-- Force recheck of stuck spears when punched.
-- Otherwise, punching has no effect.
function SPEAR_ENTITY.on_punch(self)
	if self._stuck then
		self._stuckrechecktimer = STUCK_RECHECK_TIME
	end
end

function SPEAR_ENTITY.get_staticdata(self)
	local out = {
		lastpos = self._lastpos,
		startpos = self._startpos,
		damage = self._damage,
		is_critical = self._is_critical,
		stuck = self._stuck,
		stuckin = self._stuckin,
		stuckin_player = self._in_player,
	}
	if self._stuck then
		-- If _stucktimer is missing for some reason, assume the maximum
		if not self._stucktimer then
			self._stucktimer = SPEAR_TIMEOUT
		end
		out.stuckstarttime = minetest.get_gametime() - self._stucktimer
	end
	if self._shooter and self._shooter:is_player() then
		out.shootername = self._shooter:get_player_name()
	end
	return minetest.serialize(out)
end

function SPEAR_ENTITY.on_activate(self, staticdata, dtime_s)
	self._time_in_air = 1.0
	local data = minetest.deserialize(staticdata)
	if data then
		self._stuck = data.stuck
		if data.stuck then
			if data.stuckstarttime then
				-- First, check if the stuck spear is aleady past its life timer.
				-- If yes, delete it.
				self._stucktimer = minetest.get_gametime() - data.stuckstarttime
				if self._stucktimer > SPEAR_TIMEOUT then
					spawn_item(self, pos)
					return
				end
			end

			-- Perform a stuck recheck on the next step.
			self._stuckrechecktimer = STUCK_RECHECK_TIME

			self._stuckin = data.stuckin
		end

		-- Get the remaining spear state
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

		if data.stuckin_player then
			spawn_item(self, pos)
		end
	end
	self.object:set_armor_groups({ immortal = 1 })
end

minetest.register_entity("vl_weaponry:spear_entity", SPEAR_ENTITY)

local spear_throw_power = 25

local spear_on_place = function(wear_divisor)
	return function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			-- Call on_rightclick if the pointed node defines it
			local node = minetest.get_node(pointed_thing.under)
			if user and not user:get_player_control().sneak then
				if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
					return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
				end
			end
		end

		if minetest.is_protected(pointed_thing.under, user:get_player_name()) then
			minetest.record_protection_violation(pointed_thing.under, user:get_player_name())
			return itemstack
		end

		local pos = user:get_pos()
		pos.y = pos.y + 1.5
		local dir = user:get_look_dir()
		local yaw = user:get_look_horizontal()
		local obj = minetest.add_entity({x=pos.x,y=pos.y,z=pos.z}, "vl_weaponry:spear_entity")
		obj:set_velocity({x=dir.x*spear_throw_power, y=dir.y*spear_throw_power, z=dir.z*spear_throw_power})
		obj:set_acceleration({x=0, y=-GRAVITY, z=0})
		obj:set_yaw(yaw-math.pi/2)
		obj:set_properties({textures = {itemstack:get_name()}})
		local le = obj:get_luaentity()
		le._shooter = user
		le._source_object = user
		le._damage = itemstack:get_definition()._mcl_spear_thrown_damage
		le._is_critical = false
		le._startpos = pos
		le._collectable = true
		le._itemstack = itemstack
		minetest.sound_play("mcl_bows_bow_shoot", {pos=pos, max_hear_distance=16}, true)
		if user and user:is_player() then
			if obj:get_luaentity().player == "" then
				obj:get_luaentity().player = user
			end
-- 			obj:get_luaentity().node = shooter:get_inventory():get_stack("main", 1):get_name()
		end

		return ItemStack()
	end
end

local uses = {
	wood = 60,
	stone = 132,
	iron = 251,
	gold = 33,
	diamond = 1562,
	netherite = 2031,
}

local SPEAR_RANGE = 4.5

--Hammers
minetest.register_tool("vl_weaponry:hammer_wood", {
	description = S("Wooden Hammer"),
	_tt_help = hammer_tt,
	_doc_items_longdesc = hammer_longdesc,
	_doc_items_usagehelp = hammer_use,
	_doc_items_hidden = false,
	inventory_image = "vl_tool_woodhammer.png",
	wield_scale = wield_scale,
	groups = { weapon=1, hammer=1, dig_speed_class=2, enchantability=15 },
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=1,
		damage_groups = {fleshy=4},
		punch_attack_uses = 60,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "group:wood",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 1, level = 1, uses = 60 },
		shovely = { speed = 1, level = 2, uses = 60 }
	},
})
minetest.register_tool("vl_weaponry:hammer_stone", {
	description = S("Stone Hammer"),
	_tt_help = hammer_tt,
	_doc_items_longdesc = hammer_longdesc,
	_doc_items_usagehelp = hammer_use,
	inventory_image = "vl_tool_stonehammer.png",
	wield_scale = wield_scale,
	groups = { weapon=1, hammer=1, dig_speed_class=2, enchantability=5 },
	tool_capabilities = {
		full_punch_interval = 1.3,
		max_drop_level=3,
		damage_groups = {fleshy=5},
		punch_attack_uses = 132,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "group:cobble",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 2, level = 3, uses = 132 },
		shovely = { speed = 2, level = 3, uses = 132 }
	},
})
minetest.register_tool("vl_weaponry:hammer_iron", {
	description = S("Iron Hammer"),
	_tt_help = hammer_tt,
	_doc_items_longdesc = hammer_longdesc,
	_doc_items_usagehelp = hammer_use,
	inventory_image = "vl_tool_steelhammer.png",
	wield_scale = wield_scale,
	groups = { weapon=1, hammer=1, dig_speed_class=2, enchantability=14 },
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=4,
		damage_groups = {fleshy=6},
		punch_attack_uses = 251,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:iron_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 3, level = 4, uses = 251 },
		shovely = { speed = 3, level = 4, uses = 251 }
	},
})
minetest.register_tool("vl_weaponry:hammer_gold", {
	description = S("Golden Hammer"),
	_tt_help = hammer_tt,
	_doc_items_longdesc = hammer_longdesc,
	_doc_items_usagehelp = hammer_use,
	inventory_image = "vl_tool_goldhammer.png",
	wield_scale = wield_scale,
	groups = { weapon=1, hammer=1, dig_speed_class=2, enchantability=22 },
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=2,
		damage_groups = {fleshy=5},
		punch_attack_uses = 33,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:gold_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 8, level = 4, uses = 33 },
		shovely = { speed = 8, level = 4, uses = 33 }
	},
})
minetest.register_tool("vl_weaponry:hammer_diamond", {
	description = S("Diamond Hammer"),
	_tt_help = hammer_tt,
	_doc_items_longdesc = hammer_longdesc,
	_doc_items_usagehelp = hammer_use,
	inventory_image = "vl_tool_diamondhammer.png",
	wield_scale = wield_scale,
	groups = { weapon=1, hammer=1, dig_speed_class=2, enchantability=10 },
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=5,
		damage_groups = {fleshy=7},
		punch_attack_uses = 1562,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:diamond",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 4, level = 5, uses = 1562 },
		pickaxey = { speed = 4, level = 5, uses = 1562 }
	},
	_mcl_upgradable = true,
	_mcl_upgrade_item = "vl_weaponry:hammer_netherite"
})
minetest.register_tool("vl_weaponry:hammer_netherite", {
	description = S("Netherite Hammer"),
	_tt_help = hammer_tt,
	_doc_items_longdesc = hammer_longdesc,
	_doc_items_usagehelp = hammer_use,
	inventory_image = "vl_tool_netheritehammer.png",
	wield_scale = wield_scale,
	groups = { weapon=1, hammer=1, dig_speed_class=2, enchantability=10, fire_immune=1 },
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=5,
		damage_groups = {fleshy=9},
		punch_attack_uses = 2031,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_nether:netherite_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 6, level = 6, uses = 2031 },
		shovely = { speed = 6, level = 6, uses = 2031 }
	},
})

--Spears
minetest.register_tool("vl_weaponry:spear_wood", {
	description = S("Wooden Spear"),
	_tt_help = spear_tt,
	_doc_items_longdesc = spear_longdesc,
	_doc_items_usagehelp = spear_use,
	_doc_items_hidden = false,
	inventory_image = "vl_tool_woodspear.png",
	wield_scale = wield_scale,
	on_place = spear_on_place(uses.wood),
	on_secondary_use = spear_on_place(uses.wood),
	groups = { weapon=1, spear=1, dig_speed_class=2, enchantability=15 },
	range = SPEAR_RANGE,
	tool_capabilities = {
		full_punch_interval = 0.75,
		max_drop_level=1,
		damage_groups = {fleshy=3},
		punch_attack_uses = 60,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "group:wood",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 2, level = 1, uses = 60 },
		swordy_cobweb = { speed = 2, level = 1, uses = 60 }
	},
	_mcl_spear_thrown_damage = 5,
})
minetest.register_tool("vl_weaponry:spear_stone", {
	description = S("Stone Spear"),
	_tt_help = spear_tt,
	_doc_items_longdesc = spear_longdesc,
	_doc_items_usagehelp = spear_use,
	inventory_image = "vl_tool_stonespear.png",
	wield_scale = wield_scale,
	on_place = spear_on_place(uses.stone),
	on_secondary_use = spear_on_place(uses.stone),
	groups = { weapon=1, spear=1, dig_speed_class=2, enchantability=5 },
	range = SPEAR_RANGE,
	tool_capabilities = {
		full_punch_interval = 0.75,
		max_drop_level=3,
		damage_groups = {fleshy=4},
		punch_attack_uses = 132,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "group:cobble",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 2, level = 1, uses = 132 },
		swordy_cobweb = { speed = 2, level = 1, uses = 132 }
	},
	_mcl_spear_thrown_damage = 6,
})
minetest.register_tool("vl_weaponry:spear_iron", {
	description = S("Iron Spear"),
	_tt_help = spear_tt,
	_doc_items_longdesc = spear_longdesc,
	_doc_items_usagehelp = spear_use,
	inventory_image = "vl_tool_steelspear.png",
	wield_scale = wield_scale,
	on_place = spear_on_place(uses.iron),
	on_secondary_use = spear_on_place(uses.iron),
	groups = { weapon=1, spear=1, dig_speed_class=2, enchantability=14 },
	range = SPEAR_RANGE,
	tool_capabilities = {
		full_punch_interval = 0.75,
		max_drop_level=4,
		damage_groups = {fleshy=5},
		punch_attack_uses = 251,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:iron_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 2, level = 1, uses = 251 },
		swordy_cobweb = { speed = 2, level = 1, uses = 251 }
	},
	_mcl_spear_thrown_damage = 7,
})
minetest.register_tool("vl_weaponry:spear_gold", {
	description = S("Golden Spear"),
	_tt_help = spear_tt,
	_doc_items_longdesc = spear_longdesc,
	_doc_items_usagehelp = spear_use,
	inventory_image = "vl_tool_goldspear.png",
	wield_scale = wield_scale,
	on_place = spear_on_place(uses.gold),
	on_secondary_use = spear_on_place(uses.gold),
	groups = { weapon=1, spear=1, dig_speed_class=2, enchantability=22 },
	range = SPEAR_RANGE,
	tool_capabilities = {
		full_punch_interval = 0.75,
		max_drop_level=2,
		damage_groups = {fleshy=3},
		punch_attack_uses = 33,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:gold_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 2, level = 1, uses = 33 },
		swordy_cobweb = { speed = 2, level = 1, uses = 33 }
	},
	_mcl_spear_thrown_damage = 5,
})
minetest.register_tool("vl_weaponry:spear_diamond", {
	description = S("Diamond Spear"),
	_tt_help = spear_tt,
	_doc_items_longdesc = spear_longdesc,
	_doc_items_usagehelp = spear_use,
	inventory_image = "vl_tool_diamondspear.png",
	wield_scale = wield_scale,
	on_place = spear_on_place(uses.diamond),
	on_secondary_use = spear_on_place(uses.diamond),
	groups = { weapon=1, spear=1, dig_speed_class=2, enchantability=10 },
	range = SPEAR_RANGE,
	tool_capabilities = {
		full_punch_interval = 0.75,
		max_drop_level=5,
		damage_groups = {fleshy=6},
		punch_attack_uses = 1562,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:diamond",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 2, level = 1, uses = 1562 },
		swordy_cobweb = { speed = 2, level = 1, uses = 1562 }
	},
	_mcl_spear_thrown_damage = 8,
	_mcl_upgradable = true,
	_mcl_upgrade_item = "vl_weaponry:spear_netherite"
})
minetest.register_tool("vl_weaponry:spear_netherite", {
	description = S("Netherite Spear"),
	_tt_help = spear_tt,
	_doc_items_longdesc = spear_longdesc,
	_doc_items_usagehelp = spear_use,
	inventory_image = "vl_tool_netheritespear.png",
	wield_scale = wield_scale,
	on_place = spear_on_place(uses.netherite),
	on_secondary_use = spear_on_place(uses.netherite),
	groups = { weapon=1, spear=1, dig_speed_class=2, enchantability=10, fire_immune=1 },
	range = SPEAR_RANGE,
	tool_capabilities = {
		full_punch_interval = 0.75,
		max_drop_level=5,
		damage_groups = {fleshy=8},
		punch_attack_uses = 2031,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_nether:netherite_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 2, level = 1, uses = 2031 },
		swordy_cobweb = { speed = 2, level = 1, uses = 2031 }
	},
	_mcl_spear_thrown_damage = 12,
})
