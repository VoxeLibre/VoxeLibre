--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

-- ENDERMAN BEHAVIOUR (OLD):
-- In this game, endermen attack the player on sight, like other monsters do.
-- However, they have a reduced viewing range to make them less dangerous.
-- This differs from MC, in which endermen only become hostile when provoked,
-- and they are provoked by looking directly at them.

-- Rootyjr
-----------------------------
-- implemented ability to detect when seen / break eye contact and aggressive response
-- implemented teleport to avoid arrows.
-- implemented teleport to avoid rain.
-- implemented teleport to chase.
-- added enderman particles.
-- drew mcl_portal_particle1.png
-- drew mcl_portal_particle2.png
-- drew mcl_portal_particle3.png
-- drew mcl_portal_particle4.png
-- drew mcl_portal_particle5.png
-- added rain damage.
-- fixed the grass_with_dirt issue.

local S = minetest.get_translator("mobs_mc")

local telesound = function(pos, is_source)
	local snd
	if is_source then
		snd = "mobs_mc_enderman_teleport_src"
	else
		snd = "mobs_mc_enderman_teleport_dst"
	end
	minetest.sound_play(snd, {pos=pos, max_hear_distance=16}, true)
end

--###################
--################### ENDERMAN
--###################

local pr = PseudoRandom(os.time()*(-334))

-- How freqeuntly to take and place blocks, in seconds
local take_frequency_min = 235
local take_frequency_max = 245
local place_frequency_min = 235
local place_frequency_max = 245

-- Create the textures table for the enderman, depending on which kind of block
-- the enderman holds (if any).
local create_enderman_textures = function(block_type, itemstring)
	local base = "mobs_mc_enderman.png^mobs_mc_enderman_eyes.png"

	--[[ Order of the textures in the texture table:
		Flower, 90 degrees
		Flower, 45 degrees
		Held block, backside
		Held block, bottom
		Held block, front
		Held block, left
		Held block, right
		Held block, top
		Enderman texture (base)
	]]
	-- Regular cube
	if block_type == "cube" then
		local tiles = minetest.registered_nodes[itemstring].tiles
		local textures = {}
		local last
		if mobs_mc.enderman_block_texture_overrides[itemstring] then
			-- Texture override available? Use these instead!
			textures = mobs_mc.enderman_block_texture_overrides[itemstring]
		else
			-- Extract the texture names
			for i = 1, 6 do
				if type(tiles[i]) == "string" then
					last = tiles[i]
				elseif type(tiles[i]) == "table" then
					if tiles[i].name then
						last = tiles[i].name
					end
				end
				table.insert(textures, last)
			end
		end
		return {
			"blank.png",
			"blank.png",
			textures[5],
			textures[2],
			textures[6],
			textures[3],
			textures[4],
			textures[1],
			base, -- Enderman texture
		}
	-- Node of plantlike drawtype, 45° (recommended)
	elseif block_type == "plantlike45" then
		local textures = minetest.registered_nodes[itemstring].tiles
		return {
			"blank.png",
			textures[1],
			"blank.png",
			"blank.png",
			"blank.png",
			"blank.png",
			"blank.png",
			"blank.png",
			base,
		}
	-- Node of plantlike drawtype, 90°
	elseif block_type == "plantlike90" then
		local textures = minetest.registered_nodes[itemstring].tiles
		return {
			textures[1],
			"blank.png",
			"blank.png",
			"blank.png",
			"blank.png",
			"blank.png",
			"blank.png",
			"blank.png",
			base,
		}
	elseif block_type == "unknown" then
		return {
			"blank.png",
			"blank.png",
			"unknown_node.png",
			"unknown_node.png",
			"unknown_node.png",
			"unknown_node.png",
			"unknown_node.png",
			"unknown_node.png",
			base, -- Enderman texture
		}
	-- No block held (for initial texture)
	elseif block_type == "nothing" or block_type == nil then
		return {
			"blank.png",
			"blank.png",
			"blank.png",
			"blank.png",
			"blank.png",
			"blank.png",
			"blank.png",
			"blank.png",
			base, -- Enderman texture
		}
	end
end

-- Select a new animation definition.
local select_enderman_animation = function(animation_type)
	-- Enderman holds a block
	if animation_type == "block" then
		return {
			walk_speed = 25,
			run_speed = 50,
			stand_speed = 25,
			stand_start = 200,
			stand_end = 200,
			walk_start = 161,
			walk_end = 200,
			run_start = 161,
			run_end = 200,
			punch_start = 121,
			punch_end = 160,
		}
	-- Enderman doesn't hold a block
	elseif animation_type == "normal" or animation_type == nil then
		return {
			walk_speed = 25,
			run_speed = 50,
			stand_speed = 25,
			stand_start = 40,
			stand_end = 80,
			walk_start = 0,
			walk_end = 40,
			run_start = 0,
			run_end = 40,
			punch_start = 81,
			punch_end = 120,
		}
	end
end

local mobs_griefing = minetest.settings:get_bool("mobs_griefing") ~= false

mobs:register_mob("mobs_mc:enderman", {
	type = "monster",
	spawn_class = "passive",
	passive = true,
	pathfinding = 1,
	hp_min = 40,
	hp_max = 40,
	xp_min = 5,
	xp_max = 5,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 2.89, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_enderman.b3d",
	textures = create_enderman_textures(),
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
	sounds = {
		-- TODO: Custom war cry sound
		war_cry = "mobs_sandmonster",
		death = {name="mobs_mc_enderman_death", gain=0.7},
		damage = {name="mobs_mc_enderman_hurt", gain=0.5},
		random = {name="mobs_mc_enderman_random", gain=0.5},
		distance = 16,
	},
	walk_velocity = 0.2,
	run_velocity = 3.4,
	damage = 7,
	reach = 2,
	drops = {
		{name = mobs_mc.items.ender_pearl,
		chance = 1,
		min = 0,
		max = 1,
		looting = "common"},
	},
	animation = select_enderman_animation("normal"),
	_taken_node = "",
	do_custom = function(self, dtime)
		-- PARTICLE BEHAVIOUR HERE.
		local enderpos = self.object:get_pos()
		local chanceOfParticle = math.random(0, 1)
		if chanceOfParticle == 1 then
			minetest.add_particle({
				pos = {x=enderpos.x+math.random(-1,1)*math.random()/2,y=enderpos.y+math.random(0,3),z=enderpos.z+math.random(-1,1)*math.random()/2},
				velocity = {x=math.random(-.25,.25), y=math.random(-.25,.25), z=math.random(-.25,.25)},
				acceleration = {x=math.random(-.5,.5), y=math.random(-.5,.5), z=math.random(-.5,.5)},
				expirationtime = math.random(),
				size = math.random(),
				collisiondetection = true,
				vertical = false,
				texture = "mcl_portals_particle"..math.random(1, 5)..".png",
			})
		end
		-- RAIN DAMAGE / EVASIVE WARP BEHAVIOUR HERE.
		if mcl_weather.state == "rain" or mcl_weather.state == "lightning" then
			local damage = true
			local enderpos = self.object:get_pos()
			enderpos.y = enderpos.y+2.89
			local height = {x=enderpos.x, y=enderpos.y+512,z=enderpos.z}
			local ray = minetest.raycast(enderpos, height, true)
			-- Check for blocks above enderman.
			for pointed_thing in ray do
				if pointed_thing.type == "node" then
					local nn = minetest.get_node(minetest.get_pointed_thing_position(pointed_thing)).name
					local def = minetest.registered_nodes[nn]
					if (not def) or def.walkable then
						-- There's a node in the way. Delete arrow without damage
						damage = false
						break
					end
				end
			end

			if damage == true then
				self.state = ""
				--rain hurts enderman
				self.object:punch(self.object, 1.0, {
					full_punch_interval=1.0,
					damage_groups={fleshy=self._damage},
				}, nil)
				--randomly teleport hopefully under something.
				self:teleport(nil)
			end
		end
		-- AGRESSIVELY WARP/CHASE PLAYER BEHAVIOUR HERE.
		if self.state == "attack" then
			--if (minetest.get_timeofday() * 24000) > 5001 and (minetest.get_timeofday() * 24000) < 19000 then
				--self:teleport(nil)
				--self.state = ""
			--else
				if self.attack then
					local target = self.attack
					local pos = target:get_pos()
					if pos ~= nil then
						if vector.distance(self.object:get_pos(), target:get_pos()) > 10 then
							self:teleport(target)
						end
					end
				end
			--end
		end
		-- ARROW / DAYTIME PEOPLE AVOIDANCE BEHAVIOUR HERE.
		-- Check for arrows and people nearby.
		local enderpos = self.object:get_pos()
		local objs = minetest.get_objects_inside_radius(enderpos, 4)
		for n = 1, #objs do
			local obj = objs[n]
			if obj then
				if minetest.is_player(obj) then
					-- Warp from players during day.
					--if (minetest.get_timeofday() * 24000) > 5001 and (minetest.get_timeofday() * 24000) < 19000 then
					--	self:teleport(nil)
					--end
				else
					local lua = obj:get_luaentity()
					if lua then
						if lua.name == "mcl_bows:arrow_entity" then
							self:teleport(nil)
						end
					end
				end
			end
		end
		-- PROVOKED BEHAVIOUR HERE.
		local enderpos = self.object:get_pos()
		if self.provoked == "broke_contact" then
			self.provoked = "false"
			--if (minetest.get_timeofday() * 24000) > 5001 and (minetest.get_timeofday() * 24000) < 19000 then
			--	self:teleport(nil)
			--	self.state = ""
			--else
				if self.attack ~= nil then
					self.state = 'attack'
				end
			--end
		end
		-- Check to see if people are near by enough to look at us.
		local objs = minetest.get_objects_inside_radius(enderpos, 64)
		local obj
		for n = 1, #objs do
			obj = objs[n]
			if obj then
				if minetest.is_player(obj) then
					-- Check if they are looking at us.
					local player_pos = obj:get_pos()
					local look_dir_not_normalized = obj:get_look_dir()
					local look_dir = vector.normalize(look_dir_not_normalized)
					local look_pos = vector.new({x = look_dir.x+player_pos.x, y = look_dir.y+player_pos.y + 1.5, z = look_dir.z+player_pos.z}) -- Arbitrary value (1.5) is head level according to player info mod.
					-- Cast up to 64 to see if player is looking at enderman.
					for n = 1,64,.25 do
						local node = minetest.get_node(look_pos)
						if node.name ~= "air" then
							break
						end
						if look_pos.x-1<enderpos.x and look_pos.x+1>enderpos.x and look_pos.y-2.89<enderpos.y and look_pos.y-2>enderpos.y and look_pos.z-1<enderpos.z and look_pos.z+1>enderpos.z then
							self.provoked = "staring"
							self.attack = minetest.get_player_by_name(obj:get_player_name())
							break
						else
							if self.provoked == "staring" then
								self.provoked = "broke_contact"
							end
						end
						look_pos.x = look_pos.x + (.25 * look_dir.x)
						look_pos.y = look_pos.y + (.25 * look_dir.y)
						look_pos.z = look_pos.z + (.25 * look_dir.z)
					end
				end
			end
		end
		-- TAKE AND PLACE STUFF BEHAVIOUR BELOW.
		if not mobs_griefing then
			return
		end
		-- Take and put nodes
		if not self._take_place_timer or not self._next_take_place_time then
			self._take_place_timer = 0
			self._next_take_place_time = math.random(take_frequency_min, take_frequency_max)
			return
		end
		self._take_place_timer = self._take_place_timer + dtime
		if (self._taken_node == nil or self._taken_node == "") and self._take_place_timer >= self._next_take_place_time then
			-- Take random node
			self._take_place_timer = 0
			self._next_take_place_time = math.random(place_frequency_min, place_frequency_max)
			local pos = self.object:get_pos()
			local takable_nodes = minetest.find_nodes_in_area_under_air({x=pos.x-2, y=pos.y-1, z=pos.z-2}, {x=pos.x+2, y=pos.y+1, z=pos.z+2}, mobs_mc.enderman_takable)
			if #takable_nodes >= 1 then
				local r = pr:next(1, #takable_nodes)
				local take_pos = takable_nodes[r]
				local node = minetest.get_node(take_pos)
				-- Don't destroy protected stuff.
				if not minetest.is_protected(take_pos, "") then
					local dug = minetest.dig_node(take_pos)
					if dug then
						if mobs_mc.enderman_replace_on_take[node.name] then
							self._taken_node = mobs_mc.enderman_replace_on_take[node.name]
						else
							self._taken_node = node.name
						end
						local def = minetest.registered_nodes[self._taken_node]
						-- Update animation and texture accordingly (adds visibly carried block)
						local block_type
						-- Cube-shaped
						if def.drawtype == "normal" or
								def.drawtype == "nodebox" or
								def.drawtype == "liquid" or
								def.drawtype == "flowingliquid" or
								def.drawtype == "glasslike" or
								def.drawtype == "glasslike_framed" or
								def.drawtype == "glasslike_framed_optional" or
								def.drawtype == "allfaces" or
								def.drawtype == "allfaces_optional" or
								def.drawtype == nil then
							block_type = "cube"
						elseif def.drawtype == "plantlike" then
							-- Flowers and stuff
							block_type = "plantlike45"
						elseif def.drawtype == "airlike" then
							-- Just air
							block_type = nil
						else
							-- Fallback for complex drawtypes
							block_type = "unknown"
						end
						self.base_texture = create_enderman_textures(block_type, self._taken_node)
						self.object:set_properties({ textures = self.base_texture })
						self.animation = select_enderman_animation("block")
						mobs:set_animation(self, self.animation.current)
						if def.sounds and def.sounds.dug then
							minetest.sound_play(def.sounds.dug, {pos = take_pos, max_hear_distance = 16}, true)
						end
					end
				end
			end
		elseif self._taken_node ~= nil and self._taken_node ~= "" and self._take_place_timer >= self._next_take_place_time then
			-- Place taken node
			self._take_place_timer = 0
			self._next_take_place_time = math.random(take_frequency_min, take_frequency_max)
			local pos = self.object:get_pos()
			local yaw = self.object:get_yaw()
			-- Place node at looking direction
			local place_pos = vector.subtract(pos, minetest.facedir_to_dir(minetest.dir_to_facedir(minetest.yaw_to_dir(yaw))))
			-- Also check to see if protected.
			if minetest.get_node(place_pos).name == "air" and not minetest.is_protected(place_pos, "") then
				-- ... but only if there's a free space
				local success = minetest.place_node(place_pos, {name = self._taken_node})
				if success then
					local def = minetest.registered_nodes[self._taken_node]
					-- Update animation accordingly (removes visible block)
					self.animation = select_enderman_animation("normal")
					mobs:set_animation(self, self.animation.current)
					if def.sounds and def.sounds.place then
						minetest.sound_play(def.sounds.place, {pos = place_pos, max_hear_distance = 16}, true)
					end
					self._taken_node = ""
				end
			end
		end
	end,
	do_teleport = function(self, target)
		if target ~= nil then
			local target_pos = target:get_pos()
			-- Find all solid nodes below air in a 10×10×10 cuboid centered on the target
			local nodes = minetest.find_nodes_in_area_under_air(vector.subtract(target_pos, 5), vector.add(target_pos, 5), {"group:solid", "group:cracky", "group:crumbly"})
			local telepos
			if nodes ~= nil then
				if #nodes > 0 then
					-- Up to 64 attempts to teleport
					for n=1, math.min(64, #nodes) do
						local r = pr:next(1, #nodes)
						local nodepos = nodes[r]
						local node_ok = true
						-- Selected node needs to have 3 nodes of free space above
						for u=1, 3 do
							local node = minetest.get_node({x=nodepos.x, y=nodepos.y+u, z=nodepos.z})
							if minetest.registered_nodes[node.name].walkable then
								node_ok = false
								break
							end
						end
						if node_ok then
							telepos = {x=nodepos.x, y=nodepos.y+1, z=nodepos.z}
						end
					end
					if telepos then
						telesound(self.object:get_pos(), false)
						self.object:set_pos(telepos)
						telesound(telepos, true)
					end
				end
			end
		else
			-- Attempt to randomly teleport enderman
			local pos = self.object:get_pos()
			-- Up to 8 top-level attempts to teleport
			for n=1, 8 do
				local node_ok = false
				-- We need to add (or subtract) different random numbers to each vector component, so it couldn't be done with a nice single vector.add() or .subtract():
				local randomCube = vector.new( pos.x + 8*(pr:next(0,16)-8), pos.y + 8*(pr:next(0,16)-8), pos.z + 8*(pr:next(0,16)-8) )
				local nodes = minetest.find_nodes_in_area_under_air(vector.subtract(randomCube, 4), vector.add(randomCube, 4), {"group:solid", "group:cracky", "group:crumbly"})
				if nodes ~= nil then
					if #nodes > 0 then
						-- Up to 8 low-level (in total up to 8*8 = 64) attempts to teleport
						for n=1, math.min(8, #nodes) do
							local r = pr:next(1, #nodes)
							local nodepos = nodes[r]
							node_ok = true
							for u=1, 3 do
								local node = minetest.get_node({x=nodepos.x, y=nodepos.y+u, z=nodepos.z})
								if minetest.registered_nodes[node.name].walkable then
									node_ok = false
									break
								end
							end
							if node_ok then
								telesound(self.object:get_pos(), false)
								local telepos = {x=nodepos.x, y=nodepos.y+1, z=nodepos.z}
								self.object:set_pos(telepos)
								telesound(telepos, true)
								break
							end
						end
					end
				end
				if node_ok then
					 break
				end
			end
		end
	end,
	on_die = function(self, pos)
		-- Drop carried node on death
		if self._taken_node ~= nil and self._taken_node ~= "" then
			minetest.add_item(pos, self._taken_node)
		end
	end,
	do_punch = function(self, hitter, tflp, tool_caps, dir)
		-- damage from rain caused by itself so we don't want it to attack itself.
		if hitter ~= self.object and hitter ~= nil then
			--if (minetest.get_timeofday() * 24000) > 5001 and (minetest.get_timeofday() * 24000) < 19000 then
			--	self:teleport(nil)
			--else
				self:teleport(hitter)
				self.attack=hitter
				self.state="attack"
			--end
		end
	end,
	armor = { fleshy = 100, water_vulnerable = 100 },
	water_damage = 8,
	view_range = 64,
	fear_height = 4,
	attack_type = "dogfight",
})


-- End spawn
mobs:spawn_specific("mobs_mc:enderman", mobs_mc.spawn.solid, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 3000, 12, mobs_mc.spawn_height.end_min, mobs_mc.spawn_height.end_max)
-- Overworld spawn
mobs:spawn_specific("mobs_mc:enderman", mobs_mc.spawn.solid, {"air"}, 0, 7, 30, 19000, 2, mobs_mc.spawn_height.overworld_min, mobs_mc.spawn_height.overworld_max)
-- Nether spawn (rare)
mobs:spawn_specific("mobs_mc:enderman", mobs_mc.spawn.solid, {"air"}, 0, 7, 30, 27500, 4, mobs_mc.spawn_height.nether_min, mobs_mc.spawn_height.nether_max)

-- spawn eggs
mobs:register_egg("mobs_mc:enderman", S("Enderman"), "mobs_mc_spawn_icon_enderman.png", 0)
