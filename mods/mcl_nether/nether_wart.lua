minetest.register_node("mcl_nether:nether_wart_0", {
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	drawtype = "plantlike",
	drop = "mcl_nether:nether_wart_item",
	tiles = {"mcl_nether_nether_wart_stage_0.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.125, 0.5}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1,attached_node=1,dig_by_water=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

minetest.register_node("mcl_nether:nether_wart_1", {
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	drawtype = "plantlike",
	drop = "mcl_nether:nether_wart_item",
	tiles = {"mcl_nether_nether_wart_stage_1.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.15, 0.5}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1,attached_node=1,dig_by_water=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

minetest.register_node("mcl_nether:nether_wart_2", {
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	drawtype = "plantlike",
	drop = "mcl_nether:nether_wart_item",
	tiles = {"mcl_nether_nether_wart_stage_1.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.15, 0.5}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1,attached_node=1,dig_by_water=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

minetest.register_node("mcl_nether:nether_wart", {
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	drawtype = "plantlike",
	drop = {
		max_items = 2,
		items = {
			{ items = {"mcl_nether:nether_wart_item 2"}, rarity = 1 },
			{ items = {"mcl_nether:nether_wart_item 2"}, rarity = 3 },
			{ items = {"mcl_nether:nether_wart_item 1"}, rarity = 3 },
		},
	},
	tiles = {"mcl_nether_nether_wart_stage_2.png"},
	selection_box = { 
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.45, 0.5}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1,attached_node=1,dig_by_water=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

minetest.register_craftitem("mcl_nether:nether_wart_item", {
	description = "Nether Wart",
	inventory_image = "mcl_nether_nether_wart.png",
	wield_image = "mcl_nether_nether_wart.png",
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end
		-- Check for correct soil type
		local chk = minetest.get_item_group(minetest.get_node(pointed_thing.under).name, "soil_nether_wart")
		if chk ~= 0 and chk ~= nil then
			-- Check if node above soil node allows placement
			if minetest.registered_items[minetest.get_node(pointed_thing.above).name].buildable_to then
				-- Place nether wart
				minetest.sound_play({name="default_place_node", gain=1.0}, {pos=pointed_thing.above})
				minetest.set_node(pointed_thing.above, {name="mcl_nether:nether_wart_0"})

				if not minetest.setting_getbool("creative_mode") then
					itemstack:take_item()
				end
				return itemstack
			end
		end
	end,
	groups = { craftitem = 1 },
})

local names = {"mcl_nether:nether_wart_0", "mcl_nether:nether_wart_1", "mcl_nether:nether_wart_2"}

minetest.register_abm({
	nodenames = {"mcl_nether:nether_wart_0", "mcl_nether:nether_wart_1", "mcl_nether:nether_wart_2"},
	neighbors = {"group:soil_nether_wart"},
	interval = 35,
	chance = 11,
	action = function(pos, node)
		pos.y = pos.y-1
		if minetest.get_item_group(minetest.get_node(pos).name, "soil_nether_wart") == 0 then
			return
		end
		pos.y = pos.y+1
		local step = nil
		for i,name in ipairs(names) do
			if name == node.name then
				step = i
				break
			end
		end
		if step == nil then
			return
		end
		local new_node = {name=names[step+1]}
		if new_node.name == nil then
			new_node.name = "mcl_nether:nether_wart"
		end
		minetest.swap_node(pos, new_node)
	end
})

