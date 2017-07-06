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
local take_frequency = 10
local place_frequency = 10

mobs:register_mob("mobs_mc:enderman", {
	type = "monster",
	runaway = true,
	pathfinding = 2,
	stepheight = 1.2,
	hp_min = 40,
	hp_max = 40,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 2.89, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_enderman.b3d",
	textures = {
		{"mobs_mc_enderman.png^(mobs_mc_enderman_eyes.png^[makealpha:0,0,0)"},
	},
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
	drops = {
		{name = mobs_mc.items.ender_pearl,
		chance = 1,
		min = 0,
		max = 1,},
	},
	animation = {
		speed_normal = 25,		speed_run = 50,
		stand_start = 40,		stand_end = 80,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},
	_taken_node = "",
	do_custom = function(self, dtime)
		-- Take and put nodes
		if not self._take_place_timer then
			self._take_place_timer = 0
			return
		end
		self._take_place_timer = self._take_place_timer + dtime
		if (self._taken_node == nil or self._taken_node == "") and self._take_place_timer >= take_frequency  then
			-- Take random node
			self._take_place_timer = 0
			local pos = self.object:getpos()
			local takable_nodes = minetest.find_nodes_in_area({x=pos.x-2, y=pos.y-1, z=pos.z-2}, {x=pos.x+2, y=pos.y+1, z=pos.z+2}, mobs_mc.enderman_takable)
			if #takable_nodes >= 1 then
				local r = pr:next(1, #takable_nodes)
				local take_pos = takable_nodes[r]
				local node = minetest.get_node(take_pos)
				local dug = minetest.dig_node(take_pos)
				if dug then
					self._taken_node = node.name
					-- TODO: Update enderman model (enderman holding block)
					local def = minetest.registered_nodes[self._taken_node]
					if def.sounds and def.sounds.dug then
						minetest.sound_play(def.sounds.dug, {pos = place_pos, max_hear_distance = 16})
					end
				end
			end
		elseif self._taken_node ~= nil and self._taken_node ~= "" and self._take_place_timer >= place_frequency then
			-- Place taken node
			self._take_place_timer = 0
			local pos = self.object:getpos()
			local yaw = self.object:get_yaw()
			-- Place node at looking direction
			local place_pos = vector.subtract(pos, minetest.facedir_to_dir(minetest.dir_to_facedir(minetest.yaw_to_dir(yaw))))
			if minetest.get_node(place_pos).name == "air" then
				-- ... but only if there's a free space
				minetest.place_node(place_pos, {name = self._taken_node})
				local def = minetest.registered_nodes[self._taken_node]
				if def.sounds and def.sounds.place then
					minetest.sound_play(def.sounds.place, {pos = place_pos, max_hear_distance = 16})
				end
				self._taken_node = ""
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



--spawn on solid blocks
mobs:register_spawn("mobs_mc:enderman", mobs_mc.spawn.desert, 7, 0, 9000, -31000, 31000)
mobs:register_spawn("mobs_mc:enderman", mobs_mc.end_city, minetest.LIGHT_MAX+1, 0, 9000, -31000, -5000)
-- spawn eggs
mobs:register_egg("mobs_mc:enderman", S("Enderman"), "mobs_mc_spawn_icon_enderman.png", 0)

if minetest.settings:get_bool("log_mods") then

	minetest.log("action", "MC Enderman loaded")
end

