--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")
local snow_trail_frequency = 0.5 -- Time in seconds for checking to add a new snow trail

local mobs_griefing = minetest.settings:get_bool("mobs_griefing") ~= false

mobs:register_mob("mobs_mc:snowman", {
	type = "npc",
	passive = true,
	hp_min = 4,
	hp_max = 4,
	pathfinding = 1,
	view_range = 10,
	fall_damage = 0,
	water_damage = 4,
	lava_damage = 20,
	attacks_monsters = true,
	collisionbox = {-0.35, -0.01, -0.35, 0.35, 1.89, 0.35},
	visual = "mesh",
	mesh = "mobs_mc_snowman.b3d",
	textures = {
		{"mobs_mc_snowman.png^mobs_mc_snowman_pumpkin.png"},
	},
	gotten_texture = { "mobs_mc_snowman.png" },
	drops = {{ name = mobs_mc.items.snowball, chance = 1, min = 0, max = 15 }},
	visual_size = {x=3, y=3},
	walk_velocity = 0.6,
	run_velocity = 2,
	jump = true,
	makes_footstep_sound = true,
	attack_type = "shoot",
	arrow = "mobs_mc:snowball_entity",
	shoot_interval = 1,
	shoot_offset = 1,
	animation = {
		speed_normal = 25,
		speed_run = 50,
		stand_start = 20,
		stand_end = 40,
		walk_start = 0,
		walk_end = 20,
		run_start = 0,
		run_end = 20,
		die_start = 40,
		die_end = 50,
		die_loop = false,
	},
	blood_amount = 0,
	do_custom = function(self, dtime)
		if not mobs_griefing then
			return
		end
		-- Leave a trail of top snow behind.
		-- This is done in do_custom instead of just using replace_what because with replace_what,
		-- the top snop may end up floating in the air.
		if not self._snowtimer then
			self._snowtimer = 0
			return
		end
		self._snowtimer = self._snowtimer + dtime
		if self.health > 0 and self._snowtimer > snow_trail_frequency then
			self._snowtimer = 0
			local pos = self.object:getpos()
			local below = {x=pos.x, y=pos.y-1, z=pos.z}
			local def = minetest.registered_nodes[minetest.get_node(pos).name]
			-- Node at snow golem's position must be replacable
			if def and def.buildable_to then
				-- Node below must be walkable
				-- and a full cube (this prevents oddities like top snow on top snow, lower slabs, etc.)
				local belowdef = minetest.registered_nodes[minetest.get_node(below).name]
				if belowdef and belowdef.walkable and (belowdef.node_box == nil or belowdef.node_box.type == "regular") then
					-- Place top snow
					minetest.set_node(pos, {name = mobs_mc.items.top_snow})
				end
			end
		end
	end,
	-- Remove pumpkin if using shears
	on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		if self.gotten ~= true and item:get_name() == mobs_mc.items.shears then
			-- Remove pumpkin
			self.gotten = true
			self.object:set_properties({
				textures = {"mobs_mc_snowman.png"},
			})

			local pos = self.object:getpos()
			minetest.sound_play("shears", {pos = pos})

			-- Wear out
			if not minetest.settings:get_bool("creative_mode") then
				item:add_wear(mobs_mc.misc.shears_wear)
				clicker:get_inventory():set_stack("main", clicker:get_wield_index(), item)
			end
		end
	end,
})

-- This is to be called when a pumpkin or jack'o lantern has been placed. Recommended: In the on_construct function
-- of the node.
-- This summons a snow golen when pos is next to a row of two snow blocks.
mobs_mc.tools.check_snow_golem_summon = function(pos)
	local checks = {
		-- These are the possible placement patterns
		-- { snow block pos. 1, snow block pos. 2, snow golem spawn position }
		{ {x=pos.x, y=pos.y-1, z=pos.z}, {x=pos.x, y=pos.y-2, z=pos.z}, {x=pos.x, y=pos.y-2.5, z=pos.z} },
		{ {x=pos.x, y=pos.y+1, z=pos.z}, {x=pos.x, y=pos.y+2, z=pos.z}, {x=pos.x, y=pos.y-0.5, z=pos.z} },
		{ {x=pos.x-1, y=pos.y, z=pos.z}, {x=pos.x-2, y=pos.y, z=pos.z}, {x=pos.x-2, y=pos.y-0.5, z=pos.z} },
		{ {x=pos.x+1, y=pos.y, z=pos.z}, {x=pos.x+2, y=pos.y, z=pos.z}, {x=pos.x+2, y=pos.y-0.5, z=pos.z} },
		{ {x=pos.x, y=pos.y, z=pos.z-1}, {x=pos.x, y=pos.y, z=pos.z-2}, {x=pos.x, y=pos.y-0.5, z=pos.z-2} },
		{ {x=pos.x, y=pos.y, z=pos.z+1}, {x=pos.x, y=pos.y, z=pos.z+2}, {x=pos.x, y=pos.y-0.5, z=pos.z+2} },
	}

	for c=1, #checks do
		local b1 = checks[c][1]
		local b2 = checks[c][2]
		local place = checks[c][3]
		local b1n = minetest.get_node(b1)
		local b2n = minetest.get_node(b2)
		if b1n.name == mobs_mc.items.snow_block and b2n.name == mobs_mc.items.snow_block then
			-- Remove the pumpkin and both snow blocks and summon the snow golem
			minetest.remove_node(pos)
			minetest.remove_node(b1)
			minetest.remove_node(b2)
			core.check_for_falling(pos)
			core.check_for_falling(b1)
			core.check_for_falling(b2)
			minetest.add_entity(place, "mobs_mc:snowman")
			break
		end
	end
end

-- Spawn egg
mobs:register_egg("mobs_mc:snowman", S("Snow Golem"), "mobs_mc_spawn_icon_snowman.png", 0)

if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC Snow Golem loaded")
end
