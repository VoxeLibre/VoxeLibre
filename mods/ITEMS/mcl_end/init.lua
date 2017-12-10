-- Nodes
minetest.register_node("mcl_end:end_stone", {
	description = "End Stone",
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"mcl_end_end_stone.png"},
	stack_max = 64,
	groups = {pickaxey=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 45,
	_mcl_hardness = 3,
})

minetest.register_node("mcl_end:end_bricks", {
	description = "End Stone Bricks",
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"mcl_end_end_bricks.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 4,
	_mcl_hardness = 0.8,
})

minetest.register_node("mcl_end:purpur_block", {
	description = "Purpur Block",
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"mcl_end_purpur_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 30,
	_mcl_hardness = 1.5,
})

minetest.register_node("mcl_end:purpur_pillar", {
	description = "Purpur Pillar",
	_doc_items_longdesc = doc.sub.items.temp.build,
	stack_max = 64,
	paramtype2 = "facedir",
	is_ground_content = false,
	on_place = mcl_util.rotate_axis,
	tiles = {"mcl_end_purpur_pillar_top.png", "mcl_end_purpur_pillar_top.png", "mcl_end_purpur_pillar.png"},
	groups = {pickaxey=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 30,
	_mcl_hardness = 1.5,
})

minetest.register_node("mcl_end:end_rod", {
	description = "End Rod",
	_doc_items_longdesc = "End rods are decorational light sources.",
	tiles = {
		"mcl_end_end_rod_top.png",
		"mcl_end_end_rod_bottom.png",
		"mcl_end_end_rod_side.png",
		"mcl_end_end_rod_side.png",
		"mcl_end_end_rod_side.png",
		"mcl_end_end_rod_side.png",
	},
	drawtype = "nodebox",
	is_ground_content = false,
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = 14,
	sunlight_propagates = true,
	groups = { dig_immediate=3, deco_block=1, destroy_by_lava_flow=1, },
	node_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.5, -0.125, 0.125, -0.4375, 0.125}, -- Base
			{-0.0625, -0.4375, -0.0625, 0.0625, 0.5, 0.0625}, -- Rod
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}, -- Base
		},
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}, -- Base
		},
	},
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		local p0 = pointed_thing.under
		local p1 = pointed_thing.above
		local param2 = 0

		local placer_pos = placer:getpos()
		if placer_pos then
			local dir = {
				x = p1.x - placer_pos.x,
				y = p1.y - placer_pos.y,
				z = p1.z - placer_pos.z
			}
			param2 = minetest.dir_to_facedir(dir)
		end

		if p0.y - 1 == p1.y then
			param2 = 20
		elseif p0.x - 1 == p1.x then
			param2 = 16
		elseif p0.x + 1 == p1.x then
			param2 = 12
		elseif p0.z - 1 == p1.z then
			param2 = 8
		elseif p0.z + 1 == p1.z then
			param2 = 4
		end

		return minetest.item_place(itemstack, placer, pointed_thing, param2)
	end,

	sounds = mcl_sounds.node_sound_glass_defaults(),
	_mcl_blast_resistance = 0,
})

minetest.register_node("mcl_end:dragon_egg", {
	description = "Dragon Egg",
	_doc_items_longdesc = "A dragon egg is a decorational item which can be placed.",
	tiles = {
		"mcl_end_dragon_egg.png",
		"mcl_end_dragon_egg.png",
		"mcl_end_dragon_egg.png",
		"mcl_end_dragon_egg.png",
		"mcl_end_dragon_egg.png",
		"mcl_end_dragon_egg.png",
	},
	drawtype = "nodebox",
	is_ground_content = false,
	paramtype = "light",
	light_source = 1,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.375, -0.5, -0.375, 0.375, -0.4375, 0.375},
			{-0.5, -0.4375, -0.5, 0.5, -0.1875, 0.5},
			{-0.4375, -0.1875, -0.4375, 0.4375, 0, 0.4375},
			{-0.375, 0, -0.375, 0.375, 0.125, 0.375},
			{-0.3125, 0.125, -0.3125, 0.3125, 0.25, 0.3125},
			{-0.25, 0.25, -0.25, 0.25, 0.3125, 0.25},
			{-0.1875, 0.3125, -0.1875, 0.1875, 0.375, 0.1875},
			{-0.125, 0.375, -0.125, 0.125, 0.4375, 0.125},
			{-0.0625, 0.4375, -0.0625, 0.0625, 0.5, 0.0625},
		}
	},
	selection_box = {
		type = "regular",
	},
	groups = {handy=1, falling_node = 1, deco_block = 1, not_in_creative_inventory = 1, dig_by_piston = 1 },
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 45,
	_mcl_hardness = 3,
	-- TODO: Make dragon egg teleport on punching
})

-- Eye of ender
minetest.register_entity("mcl_end:ender_eye", {
	physical = false,
	textures = {"mcl_end_ender_eye.png"},
	visual_size = {x=1.5, y=1.5},
	collisionbox = {0,0,0,0,0,0},

	-- Save and restore age
	get_staticdata = function(self)
		return tostring(self._age)
	end,
	on_activate = function(self, staticdata, dtime_s)
		local age = tonumber(staticdata)
		if type(age) == "number" then
			self._age = age
			if self._age >= 2 then
				self._phase = 1
			else
				self._phase = 0
			end
		end
	end,

	on_step = function(self, dtime)
		self._age = self._age + dtime
		if self._age >= 3 then
			-- End of life
			local r = math.random(1,5)
			if r == 1 or minetest.settings:get_bool("creative_mode") then
				-- 20% chance to get destroyed completely.
				-- 100% if in Creative Mode
				self.object:remove()
				return
			else
				-- 80% to drop as an item
				local pos = self.object:get_pos()
				local v = self.object:getvelocity()
				self.object:remove()
				local item = minetest.add_item(pos, "mcl_end:ender_eye")
				item:setvelocity(v)
				return
			end
		elseif self._age >= 2 then
			if self._phase == 0 then
				self._phase = 1
				-- Stop the eye and wait for another second.
				-- The vertical speed changes are just eye candy.
				self.object:setacceleration({x=0, y=-3, z=0})
				self.object:setvelocity({x=0, y=self.object:getvelocity().y*0.2, z=0})
			end
		else
			-- Fly normally and generate particles
			local pos = self.object:get_pos()
			pos.x = pos.x + math.random(-1, 1)*0.5
			pos.y = pos.y + math.random(-1, 0)*0.5
			pos.z = pos.z + math.random(-1, 1)*0.5
			minetest.add_particle({
				pos = pos,
				texture = "mcl_particles_teleport.png",
				expirationtime = 1,
				velocity = {x=math.random(-1, 1)*0.1, y=math.random(-30, 0)*0.1, z=math.random(-1, 1)*0.1},
				acceleration = {x=0, y=0, z=0},
				size = 2.5,
			})
		end
	end,

	_age = 0, -- age in seconds
	_phase = 0, -- phase 0: flying. phase 1: idling in mid air, about to drop or shatter
})

minetest.register_craftitem("mcl_end:ender_eye", {
	description = "Eye of Ender",
	_doc_items_longdesc = "This item is used to locate End portal shrines in the Overworld and to activate End portals.",
	_doc_items_usagehelp = "Use the attack key to release the eye of ender. It will rise and fly in the horizontal direction of the closest end portal shrine. If you're very close, the eye of ender will take the direct path to the End portal shrine instead. After a few seconds, it stops. It may drop as an item, but there's a 20% chance it shatters." .. "\n" .. "To activate an End portal, eyes of ender need to be placed into each block of an intact End portal frame.",
	wield_image = "mcl_end_ender_eye.png",
	inventory_image = "mcl_end_ender_eye.png",
	stack_max = 64,
	-- Throw eye of ender to make it fly to the closest stronghold
	on_use = function(itemstack, user, pointed_thing)
		if user == nil then
			return
		end
		local origin = user:get_pos()
		origin.y = origin.y + 1.5
		local strongholds = mcl_structures.get_registered_structures("stronghold")
		local dim = mcl_worlds.pos_to_dimension(origin)
		local is_creative = minetest.settings:get_bool("creative_mode")

		-- Just drop the eye of ender if there are no strongholds
		if #strongholds <= 0 or dim ~= "overworld" then
			if not is_creative then
				minetest.item_drop(ItemStack("mcl_end:ender_eye"), user, user:get_pos())
				itemstack:take_item()
			end
			return itemstack
		end

		-- Find closest stronghold.
		-- Note: Only the horizontal axes are taken into account.
		local closest_stronghold
		local lowest_dist
		for s=1, #strongholds do
			local h_pos = table.copy(strongholds[s].pos)
			local h_origin = table.copy(origin)
			h_pos.y = 0
			h_origin.y = 0
			local dist = vector.distance(h_origin, h_pos)
			if not closest_stronghold then
				closest_stronghold = strongholds[s]
				lowest_dist = dist
			else
				if dist < lowest_dist then
					closest_stronghold = strongholds[s]
					lowest_dist = dist
				end
			end
		end

		-- Throw it!
		local obj = minetest.add_entity(origin, "mcl_end:ender_eye")
		local dir

		if lowest_dist <= 25 then
			local velocity = 4
			-- Stronghold is close: Fly directly to stronghold and take Y into account.
			dir = vector.normalize(vector.direction(origin, closest_stronghold.pos))
			obj:setvelocity({x=dir.x*velocity, y=dir.y*velocity, z=dir.z*velocity})
		else
			local velocity = 12
			-- Don't care about Y if stronghold is still far away.
			-- Fly to direction of X/Z, and always upwards so it can be seen easily.
			local o = {x=origin.x, y=0, z=origin.z}
			local s = {x=closest_stronghold.pos.x, y=0, z=closest_stronghold.pos.z}
			dir = vector.normalize(vector.direction(o, s))
			obj:setacceleration({x=dir.x*-3, y=4, z=dir.z*-3})
			obj:setvelocity({x=dir.x*velocity, y=3, z=dir.z*velocity})
		end


		if not is_creative then
			itemstack:take_item()
		end
		return itemstack
	end,
})

local chorus_flower_box = {
	type = "fixed",
	fixed = {
		{-0.5, -0.375, -0.375, 0.5, 0.375, 0.375},
		{-0.375, -0.375, 0.375, 0.375, 0.375, 0.5},
		{-0.375, -0.375, -0.5, 0.375, 0.375, -0.375},
		{-0.375, 0.375, -0.375, 0.375, 0.5, 0.375},
		{-0.375, -0.5, -0.375, 0.375, -0.375, 0.375},
	}
}

minetest.register_node("mcl_end:chorus_flower", {
	description = "Chorus Flower",
	tiles = {
		"mcl_end_chorus_flower.png",
		"mcl_end_chorus_flower.png",
		"mcl_end_chorus_flower.png",
		"mcl_end_chorus_flower.png",
		"mcl_end_chorus_flower.png",
		"mcl_end_chorus_flower.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	node_box = chorus_flower_box,
	selection_box = { type = "regular" },
	sounds = mcl_sounds.node_sound_wood_defaults(),
	groups = {handy=1,axey=1, deco_block = 1, dig_by_piston = 1, destroy_by_lava_flow = 1,},
	_mcl_blast_resistance = 2,
	_mcl_hardness = 0.4,
})

minetest.register_node("mcl_end:chorus_flower_dead", {
	description = "Dead Chorus Flower",
	tiles = {
		"mcl_end_chorus_flower_dead.png",
		"mcl_end_chorus_flower_dead.png",
		"mcl_end_chorus_flower_dead.png",
		"mcl_end_chorus_flower_dead.png",
		"mcl_end_chorus_flower_dead.png",
		"mcl_end_chorus_flower_dead.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	node_box = chorus_flower_box,
	selection_box = { type = "regular" },
	sounds = mcl_sounds.node_sound_wood_defaults(),
	drop = "mcl_end:chorus_flower",
	groups = {handy=1,axey=1, deco_block = 1, dig_by_piston = 1, destroy_by_lava_flow = 1,},
	_mcl_blast_resistance = 2,
	_mcl_hardness = 0.4,
})

minetest.register_node("mcl_end:chorus_plant", {
	description = "Chorus Plant",
	tiles = {
		"mcl_end_chorus_plant.png",
		"mcl_end_chorus_plant.png",
		"mcl_end_chorus_plant.png",
		"mcl_end_chorus_plant.png",
		"mcl_end_chorus_plant.png",
		"mcl_end_chorus_plant.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	-- TODO: Maybe improve nodebox a bit to look more “natural”
	node_box = {
		type = "connected",
		fixed = { -0.25, -0.25, -0.25, 0.25, 0.25, 0.25 }, -- Core
		connect_top = { -0.1875, 0.25, -0.1875, 0.1875, 0.5, 0.1875 },
		connect_left = { -0.5, -0.1875, -0.1875, -0.25, 0.1875, 0.1875 },
		connect_right = { 0.25, -0.1875, -0.1875, 0.5, 0.1875, 0.1875 },
		connect_bottom = { -0.1875, -0.5, -0.25, 0.1875, -0.25, 0.25 },
		connect_front = { -0.1875, -0.1875, -0.5, 0.1875, 0.1875, -0.25 },
		connect_back = { -0.1875, -0.1875, 0.25, 0.1875, 0.1875, 0.5 },
	},
	connect_sides = { "top", "bottom", "front", "back", "left", "right" },
	connects_to = {"mcl_end:chorus_plant", "mcl_end:chorus_flower", "mcl_end:chorus_flower_dead", "mcl_end:end_stone"},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	-- TODO: Check drop probability
	drop = { items = { {items = { "mcl_end:chorus_fruit", rarity = 4 } } } },
	groups = {handy=1,axey=1, not_in_creative_inventory = 1, dig_by_piston = 1, destroy_by_lava_flow = 1 },
	_mcl_blast_resistance = 2,
	_mcl_hardness = 0.4,
})

-- Craftitems
minetest.register_craftitem("mcl_end:chorus_fruit", {
	description = "Chorus Fruit",
	_doc_items_longdesc = "Chorus fruits are the fruits of the chorus plant which is home to the End. They can be eaten to restore a few hunger points.",
	wield_image = "mcl_end_chorus_fruit.png",
	inventory_image = "mcl_end_chorus_fruit.png",
	-- TODO: Teleport player
	on_place = minetest.item_eat(4),
	on_secondary_use = minetest.item_eat(4),
	groups = { food = 2, eatable = 4, can_eat_when_full = 1 },
	_mcl_saturation = 2.4,
	stack_max = 64,
})

minetest.register_craftitem("mcl_end:chorus_fruit_popped", {
	description = "Popped Chorus Fruit",
	_doc_items_longdesc = doc.sub.items.temp.craftitem,
	wield_image = "mcl_end_chorus_fruit_popped.png",
	inventory_image = "mcl_end_chorus_fruit_popped.png",
	groups = { craftitem = 1 },
	stack_max = 64,
})

-- Crafting recipes
minetest.register_craft({
	output = "mcl_end:end_bricks 4",
	recipe = {
		{"mcl_end:end_stone", "mcl_end:end_stone"},
		{"mcl_end:end_stone", "mcl_end:end_stone"},
	}
})

minetest.register_craft({
	output = "mcl_end:purpur_block 4",
	recipe = {
		{"mcl_end:chorus_fruit_popped", "mcl_end:chorus_fruit_popped",},
		{"mcl_end:chorus_fruit_popped", "mcl_end:chorus_fruit_popped",},
	}
})

minetest.register_craft({
	output = "mcl_end:end_rod 4",
	recipe = {
		{"mcl_mobitems:blaze_rod"},
		{"mcl_end:chorus_fruit_popped"},
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_end:ender_eye",
	recipe = {"mcl_mobitems:blaze_powder", "mcl_throwing:ender_pearl"},
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_end:chorus_fruit_popped",
	recipe = "mcl_end:chorus_fruit",
	cooktime = 10,
})

