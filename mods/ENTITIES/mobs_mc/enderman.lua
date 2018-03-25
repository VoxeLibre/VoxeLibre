--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

--dofile(minetest.get_modpath("mobs").."/api.lua")


--###################
--################### ENDERMAN
--###################

local pr = PseudoRandom(os.time()*(-334))

-- How freqeuntly to take and place blocks, in seconds
local take_frequency_min = 25
local take_frequency_max = 90
local place_frequency_min = 10
local place_frequency_max = 30

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
	-- TODO: Make endermen attack when looked at
	type = "animal",
	passive = false,
	pathfinding = 1,
	stepheight = 1.2,
	hp_min = 40,
	hp_max = 40,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 2.89, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_enderman.b3d",
	textures = create_enderman_textures(),
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
	sounds = {
		war_cry = "mobs_sandmonster",
		death = "green_slime_death",
		damage = "Creeperdeath",
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
		max = 1,},
	},
	animation = select_enderman_animation("normal"),
	_taken_node = "",
	do_custom = function(self, dtime)
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
			local pos = self.object:getpos()
			local takable_nodes = minetest.find_nodes_in_area({x=pos.x-2, y=pos.y-1, z=pos.z-2}, {x=pos.x+2, y=pos.y+1, z=pos.z+2}, mobs_mc.enderman_takable)
			if #takable_nodes >= 1 then
				local r = pr:next(1, #takable_nodes)
				local take_pos = takable_nodes[r]
				local node = minetest.get_node(take_pos)
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
						minetest.sound_play(def.sounds.dug, {pos = take_pos, max_hear_distance = 16})
					end
				end
			end
		elseif self._taken_node ~= nil and self._taken_node ~= "" and self._take_place_timer >= self._next_take_place_time then
			-- Place taken node
			self._take_place_timer = 0
			self._next_take_place_time = math.random(take_frequency_min, take_frequency_max)
			local pos = self.object:getpos()
			local yaw = self.object:get_yaw()
			-- Place node at looking direction
			local place_pos = vector.subtract(pos, minetest.facedir_to_dir(minetest.dir_to_facedir(minetest.yaw_to_dir(yaw))))
			if minetest.get_node(place_pos).name == "air" then
				-- ... but only if there's a free space
				local success = minetest.place_node(place_pos, {name = self._taken_node})
				if success then
					local def = minetest.registered_nodes[self._taken_node]
					-- Update animation accordingly (removes visible block)
					self.animation = select_enderman_animation("normal")
					mobs:set_animation(self, self.animation.current)
					if def.sounds and def.sounds.place then
						minetest.sound_play(def.sounds.place, {pos = place_pos, max_hear_distance = 16})
					end
					self._taken_node = ""
				end
			end
		end
	end,
	-- TODO: Teleport enderman on damage, etc.
	_do_teleport = function(self)
		-- Attempt to randomly teleport enderman
		local pos = self.object:getpos()
		-- Find all solid nodes below air in a 65×65×65 cuboid centered on the enderman
		local nodes = minetest.find_nodes_in_area_under_air(vector.subtract(pos, 32), vector.add(pos, 32), {"group:solid", "group:cracky", "group:crumbly"})
		local telepos
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
				self.object:setpos(telepos)
			end
		end
	end,
	on_die = function(self, pos)
		-- Drop carried node on death
		if self._taken_node ~= nil and self._taken_node ~= "" then
			minetest.add_item(pos, self._taken_node)
		end
	end,
	water_damage = 8,
	lava_damage = 4,
	light_damage = 0,
	view_range = 16,
	fear_height = 4,
	attack_type = "dogfight",
	blood_amount = 0,
})


-- End spawn
mobs:spawn_specific("mobs_mc:enderman", mobs_mc.spawn.solid, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 3000, 12, mobs_mc.spawn_height.end_min, mobs_mc.spawn_height.end_max)
-- Overworld spawn
mobs:spawn_specific("mobs_mc:enderman", mobs_mc.spawn.solid, {"air"}, 0, 7, 30, 19000, 2, mobs_mc.spawn_height.overworld_min, mobs_mc.spawn_height.overworld_max)
-- Nether spawn (rare)
mobs:spawn_specific("mobs_mc:enderman", mobs_mc.spawn.solid, {"air"}, 0, 7, 30, 27500, 4, mobs_mc.spawn_height.nether_min, mobs_mc.spawn_height.nether_max)

-- spawn eggs
mobs:register_egg("mobs_mc:enderman", S("Enderman"), "mobs_mc_spawn_icon_enderman.png", 0)

if minetest.settings:get_bool("log_mods") then

	minetest.log("action", "MC Enderman loaded")
end

