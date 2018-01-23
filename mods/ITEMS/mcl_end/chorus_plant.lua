-- Chorus plants
-- This includes chorus flowers, chorus plant stem nodes and chorus fruit


--- Plant parts ---

local MAX_FLOWER_AGE = 5 -- Maximum age of chorus flower before it dies

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
	_doc_items_longdesc = "A chorus flower is the living part of a chorus plant. It can grow into a tall chorus plant, step by step. When it grows, it may die on old age eventually. It also dies when it is unable to grow.",
	_doc_items_usagehelp = "Place it and wait for it to grow. It can only be placed on top of end stone, on top of a chorus plant stem, or at the side of exactly a chorus plant stem.",
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

	node_placement_prediction = "",
	on_place = function(itemstack, placer, pointed_thing)
		local node_under = minetest.get_node(pointed_thing.under)
		local node_above = minetest.get_node(pointed_thing.above)
		if placer and not placer:get_player_control().sneak then
			-- Use pointed node's on_rightclick function first, if present
			if minetest.registered_nodes[node_under.name] and minetest.registered_nodes[node_under.name].on_rightclick then
				return minetest.registered_nodes[node_under.name].on_rightclick(pointed_thing.under, node_under, placer, itemstack) or itemstack
			end
		end

		--[[ Part 1: Check placement rules. Placement is legal is one of the following
		conditions is met:
		1) On top of end stone or chorus plant
		2) On top of air and horizontally adjacent to exactly 1 chorus plant ]]
		local pos
		if minetest.registered_nodes[node_under.name].buildable_to then
			pos = pointed_thing.under
		else
			pos = pointed_thing.above
		end


		local below = {x=pos.x, y=pos.y-1, z=pos.z}
		local node_below = minetest.get_node(below)
		local plant_ok = false
		-- Condition 1
		if node_below.name == "mcl_end:chorus_plant" or node_below.name == "mcl_end:end_stone" then
			plant_ok = true
		-- Condition 2
		elseif node_below.name == "air" then
			local around = {
				{ x= 1, y=0, z= 0 },
				{ x=-1, y=0, z= 0 },
				{ x= 0, y=0, z= 1 },
				{ x= 0, y=0, z=-1 },
			}
			local around_count = 0
			for a=1, #around do
				local pos_side = vector.add(pos, around[a])
				local node_side = minetest.get_node(pos_side)
				if node_side.name == "mcl_end:chorus_plant" then
					around_count = around_count + 1
					if around_count > 1 then
						break
					end
				end
			end
			if around_count == 1 then
				plant_ok = true
			end
		end
		if plant_ok then
			-- Placement OK! Proceed normally
			minetest.sound_play(mcl_sounds.node_sound_wood_defaults().place, {pos = pos})
			return minetest.item_place_node(itemstack, placer, pointed_thing)
		else
			return itemstack
		end
	end,
	_mcl_blast_resistance = 2,
	_mcl_hardness = 0.4,
})

minetest.register_node("mcl_end:chorus_flower_dead", {
	description = "Dead Chorus Flower",
	_doc_items_longdesc = "This is a part of a chorus plant. It doesn't grow. Chorus flowers die of old age or when they are unable to grow. A dead chorus flower can be harvested to obtain a fresh chorus flower which is able to grow again.",
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
	description = "Chorus Plant Stem",
	_doc_items_longdesc = "A chorus plant stem is the part of a chorus plant which holds the whole plant together. It needs end stone as its soil. Stems are grown from chorus flowers.",
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
	drop = {
		items = {
			{ items = { "mcl_end:chorus_fruit"}, rarity = 2 },
		}
	},
	groups = {handy=1,axey=1, not_in_creative_inventory = 1, dig_by_piston = 1, destroy_by_lava_flow = 1 },
	_mcl_blast_resistance = 2,
	_mcl_hardness = 0.4,
})


--- ABM ---
minetest.register_abm({
	label = "Chorus plant growth",
	nodenames = { "mcl_end:chorus_flower" },
	interval = 35.0,
	chance = 4.0,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local above = { x = pos.x, y = pos.y + 1, z = pos.z }
		local node_above = minetest.get_node(above)
		local around = {
			{ x=-1, y=0, z= 0 },
			{ x= 1, y=0, z= 0 },
			{ x= 0, y=0, z=-1 },
			{ x= 0, y=0, z= 1 },
		}
		local air_around = true
		for a=1, #around do
			if minetest.get_node(vector.add(above, around[a])).name ~= "air" then
				air_around = false
				break
			end
		end
		local grown = false
		if node_above.name == "air" and air_around then
			local branching = false
			local h = 0
			for y=1, 4 do
				local checkpos = {x=pos.x, y=pos.y-y, z=pos.z}
				local node = minetest.get_node(checkpos)
				if node.name == "mcl_end:chorus_plant" then
					h = y
					if not branching then
						for a=1, #around do
							local node_side = minetest.get_node(vector.add(checkpos, around[a]))
							if node_side.name == "mcl_end:chorus_plant" then
								branching = true
							end
						end
					end
				else
					break
				end
			end

			local grow_chance
			if h <= 1 then
				grow_chance = 100
			elseif h == 2 and branching == false then
				grow_chance = 60
			elseif h == 2 and branching == true then
				grow_chance = 50
			elseif h == 3 and branching == false then
				grow_chance = 40
			elseif h == 3 and branching == true then
				grow_chance = 25
			elseif h == 4 and branching == false then
				grow_chance = 20
			end

			if grow_chance then
				local new_flowers = {}
				local r = math.random(1, 100)
				local age = node.param2
				if r <= grow_chance then
					table.insert(new_flowers, above)
				else
					age = age + 1
					local branches
					if branching == false then
						branches = math.random(1, 4)
					elseif branching == true then
						branches = math.random(0, 3)
					end
					local branch_grown = false
					for b=1, branches do
						local next_branch = math.random(1, #around)
						local branch = vector.add(pos, around[next_branch])
						local below_branch = vector.add(branch, {x=0,y=-1,z=0})
						if minetest.get_node(below_branch).name == "air" then
							table.insert(new_flowers, branch)
						end
					end
				end

				for _, f in ipairs(new_flowers) do
					if age >= MAX_FLOWER_AGE then
						minetest.set_node(f, {name="mcl_end:chorus_flower_dead"})
						grown = true
					else
						minetest.set_node(f, {name="mcl_end:chorus_flower", param2 = age})
						grown = true
					end
				end
				if #new_flowers >= 1 then
					minetest.set_node(pos, {name="mcl_end:chorus_plant"})
					grown = true
				end
			end
		end
		if not grown then
			minetest.set_node(pos, {name = "mcl_end:chorus_flower_dead"})
		end
	end,
})

--- Craftitems ---
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

--- Crafting ---
minetest.register_craft({
	type = "cooking",
	output = "mcl_end:chorus_fruit_popped",
	recipe = "mcl_end:chorus_fruit",
	cooktime = 10,
})

