local function get_chest_neighborpos(pos, param2, side)
	if side == "right" then
		if param2 == 0 then
			return {x=pos.x-1, y=pos.y, z=pos.z}
		elseif param2 == 1 then
			return {x=pos.x, y=pos.y, z=pos.z+1}
		elseif param2 == 2 then
			return {x=pos.x+1, y=pos.y, z=pos.z}
		elseif param2 == 3 then
			return {x=pos.x, y=pos.y, z=pos.z-1}
		end
	else
		if param2 == 0 then
			return {x=pos.x+1, y=pos.y, z=pos.z}
		elseif param2 == 1 then
			return {x=pos.x, y=pos.y, z=pos.z-1}
		elseif param2 == 2 then
			return {x=pos.x-1, y=pos.y, z=pos.z}
		elseif param2 == 3 then
			return {x=pos.x, y=pos.y, z=pos.z+1}
		end
	end
end

minetest.register_node("mcl_chests:chest", {
	description = "Chest",
	tiles = {"default_chest_top.png", "default_chest_top.png", "default_chest_side.png",
		"default_chest_side.png", "default_chest_side.png", "default_chest_front.png"},
	paramtype2 = "facedir",
	stack_max = 64,
	groups = {choppy=2,oddly_breakable_by_hand=2, deco_block=1},
	is_ground_content = false,
	sounds = mcl_core.node_sound_wood_defaults(),
	on_construct = function(pos)
		local param2 = minetest.get_node(pos).param2
		local meta = minetest.get_meta(pos)
		if minetest.get_node(get_chest_neighborpos(pos, param2, "right")).name == "mcl_chests:chest" then
			minetest.set_node(pos, {name="mcl_chests:chest_right",param2=param2})
			local p = get_chest_neighborpos(pos, param2, "right")
			meta:set_string("formspec",
					"size[9,11.5]"..
					"background[-0.19,-0.25;9.41,12.5;crafting_inventory_chest_large.png]"..
					mcl_core.inventory_header..
					"list[nodemeta:"..p.x..","..p.y..","..p.z..";main;0,0.5;9,3;]"..
					"list[current_name;main;0,3.5;9,3;]"..
					"list[current_player;main;0,7.5;9,3;9]"..
					"list[current_player;main;0,10.75;9,1;]"..
					"listring[current_player;main]"..
					"listring[nodemeta:"..p.x..","..p.y..","..p.z..";main]"..
					"listring[current_player;main]"..
					"listring[current_name;main]")
			minetest.swap_node(p, { name = "mcl_chests:chest_left", param2 = param2 })
			local m = minetest.get_meta(p)
			m:set_string("formspec",
					"size[9,11.5]"..
					"background[-0.19,-0.25;9.41,12.5;crafting_inventory_chest_large.png]"..
					mcl_core.inventory_header..
					"list[current_name;main;0,0.5;9,3;]"..
					"list[nodemeta:"..pos.x..","..pos.y..","..pos.z..";main;0,3.5;9,3;]"..
					"list[current_player;main;0,7.5;9,3;9]"..
					"list[current_player;main;0,10.75;9,1;]"..
					"listring[current_player;main]"..
					"listring[current_name;main]"..
					"listring[current_player;main]"..
					"listring[nodemeta:"..pos.x..","..pos.y..","..pos.z..";main]")
		elseif minetest.get_node(get_chest_neighborpos(pos, param2, "left")).name == "mcl_chests:chest" then
			minetest.set_node(pos, {name="mcl_chests:chest_left",param2=param2})
			local p = get_chest_neighborpos(pos, param2, "left")
			meta:set_string("formspec",
					"size[9,11.5]"..
					"background[-0.19,-0.25;9.41,12.5;crafting_inventory_chest_large.png]"..
					mcl_core.inventory_header..
					"list[current_name;main;0,0.5;9,3;]"..
					"list[nodemeta:"..p.x..","..p.y..","..p.z..";main;0,3.5;9,3;]"..
					"list[current_player;main;0,7.5;9,3;9]"..
					"list[current_player;main;0,10.75;9,1;]"..
					"listring[current_player;main]"..
					"listring[current_name;main]"..
					"listring[current_player;main]"..
					"listring[nodemeta:"..p.x..","..p.y..","..p.z..";main]")
			minetest.swap_node(p, { name = "mcl_chests:chest_right", param2 = param2 })
			local m = minetest.get_meta(p)
			m:set_string("formspec",
					"size[9,11.5]"..
					"background[-0.19,-0.25;9.41,12.5;crafting_inventory_chest_large.png]"..
					mcl_core.inventory_header..
					"list[nodemeta:"..pos.x..","..pos.y..","..pos.z..";main;0,0.5;9,3;]"..
					"list[current_name;main;0,3.5;9,3;]"..
					"list[current_player;main;0,7.5;9,3;9]"..
					"list[current_player;main;0,10.75;9,1;]"..
					"listring[current_player;main]"..
					"listring[nodemeta:"..pos.x..","..pos.y..","..pos.z..";main]"..
					"listring[current_player;main]"..
					"listring[current_name;main]")
		else
			meta:set_string("formspec",
					"size[9,8.75]"..
					mcl_core.inventory_header..
					"background[-0.19,-0.25;9.41,10.48;crafting_inventory_chest.png]"..
					"image[0,-0.2;5,0.75;fnt_chest.png]"..
					"list[current_name;main;0,0.5;9,3;]"..
					"list[current_player;main;0,4.5;9,3;9]"..
					"list[current_player;main;0,7.74;9,1;]"..
					"listring[current_name;main]"..
					"listring[current_player;main]")
		end
		local inv = meta:get_inventory()
		inv:set_size("main", 9*3)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest.get_meta(pos)
		local meta2 = meta
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		for i=1,inv:get_size("main") do
			local stack = inv:get_stack("main", i)
			if not stack:is_empty() then
				local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
				minetest.add_item(p, stack)
			end
		end
		meta:from_table(meta2:to_table())
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in chest at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to chest at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from chest at "..minetest.pos_to_string(pos))
	end,
})

minetest.register_node("mcl_chests:chest_left", {
	tiles = {"default_chest_top_big.png", "default_chest_top_big.png", "default_chest_side.png",
		"default_chest_side.png", "default_chest_side_big.png^[transformFX", "default_chest_front_big.png"},
	paramtype2 = "facedir",
	groups = {choppy=2,oddly_breakable_by_hand=2,not_in_creative_inventory=1},
	drop = "mcl_chests:chest",
	is_ground_content = false,
	sounds = mcl_core.node_sound_wood_defaults(),
	on_destruct = function(pos)
		local n = minetest.get_node(pos)
		if n.name == "mcl_chests:chest" then
			return
		end
		local param2 = n.param2
		local p = get_chest_neighborpos(pos, param2, "left")
		if not p or minetest.get_node(p).name ~= "mcl_chests:chest_right" then
			return
		end
		local meta = minetest.get_meta(p)
		meta:set_string("formspec",
				"size[9,8.75]"..
				"background[-0.19,-0.25;9.41,10.48;crafting_inventory_chest.png]"..
				"image[0,-0.2;5,0.75;fnt_chest.png]"..
				mcl_core.inventory_header..
				"list[current_name;main;0,0.5;9,3;]"..
				"list[current_player;main;0,4.5;9,3;9]"..
				"list[current_player;main;0,7.74;9,1;]"..
				"listring[current_name;main]"..
				"listring[current_player;main]")
		minetest.swap_node(p, { name = "mcl_chests:chest", param2 = param2 })
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest.get_meta(pos)
		local meta2 = meta
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		for i=1,inv:get_size("main") do
			local stack = inv:get_stack("main", i)
			if not stack:is_empty() then
				local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
				minetest.add_item(p, stack)
			end
		end
		meta:from_table(meta2:to_table())
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in chest at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to chest at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from chest at "..minetest.pos_to_string(pos))
	end,
})

minetest.register_node("mcl_chests:chest_right", {
	tiles = {"default_chest_top_big.png^[transformFX", "default_chest_top_big.png^[transformFX", "default_chest_side.png",
		"default_chest_side.png", "default_chest_side_big.png", "default_chest_front_big.png^[transformFX"},
	paramtype2 = "facedir",
	groups = {choppy=2,oddly_breakable_by_hand=2,not_in_creative_inventory=1},
	drop = "mcl_chests:chest",
	is_ground_content = false,
	sounds = mcl_core.node_sound_wood_defaults(),
	on_destruct = function(pos)
		local n = minetest.get_node(pos)
		if n.name == "mcl_chests:chest" then
			return
		end
		local param2 = n.param2
		local p = get_chest_neighborpos(pos, param2, "right")
		if not p or minetest.get_node(p).name ~= "mcl_chests:chest_left" then
			return
		end
		local meta = minetest.get_meta(p)
		meta:set_string("formspec",
				"size[9,8.75]"..
				"background[-0.19,-0.25;9.41,10.48;crafting_inventory_chest.png]"..
				"image[0,-0.2;5,0.75;fnt_chest.png]"..
				mcl_core.inventory_header..
				"list[current_name;main;0,0.5;9,3;]"..
				"list[current_player;main;0,4.5;9,3;9]"..
				"list[current_player;main;0,7.74;9,1;]"..
				"listring[current_name;main]"..
				"listring[current_player;main]")
		minetest.swap_node(p, { name = "mcl_chests:chest", param2 = param2 })
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest.get_meta(pos)
		local meta2 = meta
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		for i=1,inv:get_size("main") do
			local stack = inv:get_stack("main", i)
			if not stack:is_empty() then
				local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
				minetest.add_item(p, stack)
			end
		end
		meta:from_table(meta2:to_table())
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in chest at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to chest at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from chest at "..minetest.pos_to_string(pos))
	end,
})

minetest.register_craft({
	output = 'mcl_chests:chest',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'group:wood', '', 'group:wood'},
		{'group:wood', 'group:wood', 'group:wood'},
	}
})

minetest.register_node("mcl_chests:ender_chest", {
	description = "Ender Chest",
	tiles = {"mcl_chests_ender_chest_top.png", "mcl_chests_ender_chest_bottom.png",
		"mcl_chests_ender_chest_right.png", "mcl_chests_ender_chest_left.png",
		"mcl_chests_ender_chest_back.png", "mcl_chests_ender_chest_front.png"},
	groups = {cracky=1, deco_block=1},
	is_ground_content = false,
	paramtype = "light",
	light_source = 7,
	paramtype2 = "facedir",
	sounds = mcl_core.node_sound_stone_defaults(),
	drop = "mcl_core:obsidian 8",
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", 
				"size[9,8.75]"..
				mcl_core.inventory_header..
				"background[-0.19,-0.25;9.41,10.48;crafting_inventory_chest.png]"..
				"image[0,-0.2;5,0.75;fnt_ender_chest.png]"..
				"list[current_player;enderchest;0,0.5;9,3;]"..
				"list[current_player;main;0,4.5;9,3;9]"..
				"list[current_player;main;0,7.74;9,1;]"..
				"listring[current_player;enderchest]"..
				"listring[current_player;main]")
	end,
})

minetest.register_on_joinplayer(function(player)
	local inv = player:get_inventory()
	inv:set_size("enderchest", 9*3)
end)

minetest.register_craft({
	output = 'mcl_chests:ender_chest',
	recipe = {
		{'mcl_core:obsidian', 'mcl_core:obsidian', 'mcl_core:obsidian'},
		{'mcl_core:obsidian', 'mcl_end:ender_eye', 'mcl_core:obsidian'},
		{'mcl_core:obsidian', 'mcl_core:obsidian', 'mcl_core:obsidian'},
	}
})

-- Shulker boxes
local boxtypes = {
	white = "White Shulker Box",
	grey = "Light Grey Shulker Box",
	orange = "Orange Shulker Box",
	cyan = "Cyan Shulker Box",
	magenta = "Magenta Shulker Box",
	violet = "Purple Shulker Box",
	lightblue = "Light Blue Shulker Box",
	blue = "Blue Shulker Box",
	yellow = "Yellow Shulker Box",
	brown = "Brown Shulker Box",
	green = "Lime Shulker Box",
	dark_green = "Green Shulker Box",
	pink = "Pink Shulker Box",
	red = "Red Shulker Box",
	dark_grey = "Grey Shulker Box",
	black = "Black Shulker Box",
}

for color, desc in pairs(boxtypes) do
	minetest.register_node("mcl_chests:"..color.."_shulker_box", {
		description = desc,
		tiles = {"mcl_chests_"..color.."_shulker_box_top.png", "mcl_chests_"..color.."_shulker_box_bottom.png",
			"mcl_chests_"..color.."_shulker_box_side.png", "mcl_chests_"..color.."_shulker_box_side.png",
			"mcl_chests_"..color.."_shulker_box_side.png", "mcl_chests_"..color.."_shulker_box_side.png"},
		groups = {cracky=2, deco_block=1, shulker_box=1},
		is_ground_content = false,
		sounds = mcl_core.node_sound_stone_defaults(),
		stack_max = 1,
		drop = "",
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec",
					"size[9,8.75]"..
					mcl_core.inventory_header..
					"background[-0.19,-0.25;9.41,10.48;crafting_inventory_chest.png]"..
					"image[0,-0.2;5,0.75;fnt_shulker_box.png]"..
					"list[current_name;main;0,0.5;9,3;]"..
					"list[current_player;main;0,4.5;9,3;9]"..
					"list[current_player;main;0,7.74;9,1;]"..
					"listring[current_name;main]"..
					"listring[current_player;main]")
			local inv = meta:get_inventory()
			inv:set_size("main", 9*3)
		end,
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			local nmeta = minetest.get_meta(pos)
			local ninv = nmeta:get_inventory()
			local imeta = itemstack:get_metadata()
			local iinv_main = minetest.deserialize(imeta)
			ninv:set_list("main", iinv_main)
			ninv:set_size("main", 9*3)
		end,
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			local meta = minetest.get_meta(pos)
			meta:from_table(oldmetadata)
			local inv = meta:get_inventory()
			local items = {}
			for i=1, inv:get_size("main") do
				items[i] = inv:get_stack("main", i):to_string()
			end
			local data = minetest.serialize(items)
			local boxitem = ItemStack("mcl_chests:"..color.."_shulker_box")
			boxitem:set_metadata(data)
			minetest.add_item(pos, boxitem)
		end,
		allow_metadata_inventory_put = function(pos, listname, index, stack, player)
			-- Do not allow to place shulker boxes into shulker boxes
			local group = minetest.get_item_group(stack:get_name(), "shulker_box")
			if group == 0 or group == nil then
				return stack:get_count()
			else
				return 0
			end
		end,
	})

	minetest.register_craft({
		type = "shapeless",
		output = 'mcl_chests:'..color..'_shulker_box',
		recipe = { 'group:shulker_box', 'mcl_dye:'..color }
	})
end

minetest.register_craft({
	output = 'mcl_chests:violet_shulker_box',
	recipe = {
		{'mcl_mobitems:shulker_shell'},
		{'mcl_chests:chest'},
		{'mcl_mobitems:shulker_shell'},
	}
})

