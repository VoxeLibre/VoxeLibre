minetest.register_node("mcl_nether:nether_wart_0", {
	description = "Premature Nether Wart",
	_doc_items_longdesc = "A premature nether wart has just recently been planted on soul sand. Nether wart slowly grows on soul sand in 3 stages. Although nether wart is home to the Nether, it grows in any dimension.",
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
	sounds = mcl_sounds.node_sound_leaves_defaults(),
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
	sounds = mcl_sounds.node_sound_leaves_defaults(),
})

minetest.register_node("mcl_nether:nether_wart_2", {
	description = "Premature Nether Wart (Stage 2)",
	_doc_items_create_entry = false,
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
	sounds = mcl_sounds.node_sound_leaves_defaults(),
})

minetest.register_node("mcl_nether:nether_wart", {
	description = "Mature Nether Wart",
	_doc_items_longdesc = "The mature nether wart is a plant from the Nether and reached its full size and won't grow any further. It is ready to be harvested for its items.",
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
	sounds = mcl_sounds.node_sound_leaves_defaults(),
})

minetest.register_craftitem("mcl_nether:nether_wart_item", {
	description = "Nether Wart",
	_doc_items_longdesc = "Nether warts are plants home to the Nether. They can be planted on soul sand and grow in 3 stages.",
	_doc_items_usagehelp = "Place this item on soul sand to plant it and watch it grow.",
	inventory_image = "mcl_nether_nether_wart.png",
	wield_image = "mcl_nether_nether_wart.png",
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(pointed_thing.under)
		if placer and not placer:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
			end
		end

		local placepos = pointed_thing.above
		local soilpos = table.copy(placepos)
		soilpos.y = soilpos.y - 1

		-- Check for correct soil type
		local chk = minetest.get_item_group(minetest.get_node(soilpos).name, "soil_nether_wart")
		if chk ~= 0 and chk ~= nil then
			-- Check if node above soil node allows placement
			if minetest.registered_items[minetest.get_node(placepos).name].buildable_to then
				-- Place nether wart
				minetest.sound_play({name="default_place_node", gain=1.0}, {pos=placepos})
				minetest.set_node(placepos, {name="mcl_nether:nether_wart_0"})

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

