

local chest = minetest.get_content_id("mcl_chests:chest")

local mcl_hoppers_formspec =
	"size[9,7]"..
	"background[-0.19,-0.25;9.41,10.48;mcl_hoppers_inventory.png]"..
	mcl_core.inventory_header..
	"list[current_name;main;2,0.5;5,1;]"..
	"list[current_player;main;0,2.5;9,3;9]"..
	"list[current_player;main;0,5.74;9,1;]"..
	"listring[current_name;main]"..
	"listring[current_player;main]"

minetest.register_node("mcl_hoppers:hopper", {
	drop = "mcl_hoppers:hopper_item",
	description = "Hopper (Node)",
	groups = {cracky=1,level=2,container=2,not_in_creative_inventory=1},
	drawtype = "nodebox",
	paramtype = "light",
	tiles = {"mcl_hoppers_hopper_inside.png^mcl_hoppers_hopper_top.png", "mcl_hoppers_hopper_outside.png", "mcl_hoppers_hopper_outside.png", "mcl_hoppers_hopper_inside.png", "mcl_hoppers_hopper_outside.png", "mcl_hoppers_hopper_outside.png"},
	selection_box = {type="regular"},
	node_box = {
			type = "fixed",
			fixed = {
			--funnel walls
			{-0.5, 0.0, 0.4, 0.5, 0.5, 0.5},
			{0.4, 0.0, -0.5, 0.5, 0.5, 0.5},
			{-0.5, 0.0, -0.5, -0.4, 0.5, 0.5},
			{-0.5, 0.0, -0.5, 0.5, 0.5, -0.4},
			--funnel base
			{-0.5, 0.0, -0.5, 0.5, 0.1, 0.5},
			--spout
			{-0.3, -0.3, -0.3, 0.3, 0.0, 0.3},
			{-0.15, -0.3, -0.15, 0.15, -0.5, 0.15},
			},
		},

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", mcl_hoppers_formspec)
		local inv = meta:get_inventory()
		inv:set_size("main", 5)
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
				" moves stuff in mcl_hoppers at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to mcl_hoppers at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from mcl_hoppers at "..minetest.pos_to_string(pos))
	end,
	sounds = mcl_sounds.node_sound_metal_defaults(),
})

minetest.register_node("mcl_hoppers:hopper_side", {
	description = "Hopper (Side)",
	drop = "mcl_hoppers:hopper_item",
	groups = {cracky=1,level=2,container=2,not_in_creative_inventory=1},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {"mcl_hoppers_hopper_inside.png^mcl_hoppers_hopper_top.png", "mcl_hoppers_hopper_outside.png", "mcl_hoppers_hopper_outside.png", "mcl_hoppers_hopper_inside.png", "mcl_hoppers_hopper_outside.png", "mcl_hoppers_hopper_outside.png"},
	selection_box = {type="regular"},
	node_box = {
			type = "fixed",
			fixed = {
			--funnel walls
			{-0.5, 0.0, 0.4, 0.5, 0.5, 0.5},
			{0.4, 0.0, -0.5, 0.5, 0.5, 0.5},
			{-0.5, 0.0, -0.5, -0.4, 0.5, 0.5},
			{-0.5, 0.0, -0.5, 0.5, 0.5, -0.4},
			--funnel base
			{-0.5, 0.0, -0.5, 0.5, 0.1, 0.5},
			--spout
			{-0.3, -0.3, -0.3, 0.3, 0.0, 0.3},
			{-0.7, -0.3, -0.15, 0.15, 0.0, 0.15},
			},
		},

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", mcl_hoppers_formspec)
		local inv = meta:get_inventory()
		inv:set_size("main", 5)
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
				" moves stuff in mcl_hoppers at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to mcl_hoppers at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from mcl_hoppers at "..minetest.pos_to_string(pos))
	end,
	sounds = mcl_sounds.node_sound_metal_defaults(),
})
--make mcl_hopperss suck in blocks
minetest.register_abm({
	nodenames = {"mcl_hoppers:hopper","mcl_hoppers:hopper_side"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()

		for _,object in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
			if not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "__builtin:item" then
				if inv and inv:room_for_item("main", ItemStack(object:get_luaentity().itemstring)) then
					local posob = object:getpos()
					if math.abs(posob.x-pos.x) <= 0.5 and (posob.y-pos.y <= 0.85 and posob.y-pos.y >= 0.3) then
						inv:add_item("main", ItemStack(object:get_luaentity().itemstring))
						object:get_luaentity().itemstring = ""
						object:remove()
					end
				end
			end
		end
	end,
})

minetest.register_abm({
	nodenames = {"mcl_hoppers:hopper"},
	neighbors = {"group:container"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		-- Get node pos' for item transfer
		local uppos = {x=pos.x,y=pos.y+1,z=pos.z}
		local downpos = {x=pos.x,y=pos.y-1,z=pos.z}

		-- Suck an item from the container above into the hopper
		local upnode = minetest.get_node(uppos)
		local g = minetest.registered_nodes[upnode.name].groups.container
		if g == 2 or g == 3 then
			-- Typical container inventory
			mcl_util.move_item_container(uppos, "main", -1, pos)
		elseif g == 4 then
			-- Furnace output
			mcl_util.move_item_container(uppos, "dst", -1, pos)
		end

		-- Move an item from the hopper into container below
		mcl_util.move_item_container(pos, "main", -1, downpos)
	end,
})


minetest.register_abm({
	nodenames = {"mcl_hoppers:hopper_side"},
	neighbors = {"group:container"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		-- Determine to which side the hopper is facing, get nodes
		local face = minetest.get_node(pos).param2
		local front = {}
		if face == 0 then
			front = {x=pos.x-1,y=pos.y,z=pos.z}
		elseif face == 1 then
			front = {x=pos.x,y=pos.y,z=pos.z+1}
		elseif face == 2 then
			front = {x=pos.x+1,y=pos.y,z=pos.z}
		elseif face == 3 then
			front = {x=pos.x,y=pos.y,z=pos.z-1}
		end
		local above = {x=pos.x,y=pos.y+1,z=pos.z}

		local frontnode = minetest.get_node(front)
	
		-- Suck an item from the container above into the hopper
		local abovenode = minetest.get_node(above)
		local g = minetest.registered_nodes[abovenode.name].groups.container
		if g == 2 or g == 3 then
			-- Typical container inventory
			mcl_util.move_item_container(above, "main", -1, pos)
		elseif g == 4 then
			-- Furnace output
			mcl_util.move_item_container(above, "dst", -1, pos)
		end

		-- Move an item from the hopper into the container to which the hopper points to
		mcl_util.move_item_container(pos, "main", -1, front)
	end
})

minetest.register_craftitem("mcl_hoppers:hopper_item", {
	description = "Hopper",
	inventory_image = "mcl_hoppers_item.png",
	-- TODO: Move to redstone category
	groups = { deco_block = 1 },
	on_place = function(itemstack, placer, pointed_thing)
		local pos  = pointed_thing.under
		local pos2 = pointed_thing.above

		local x = pos.x - pos2.x
		local y = pos.y - pos2.y
		local z = pos.z - pos2.z
		
		local placed = false

		if x == -1 then
			minetest.set_node(pos2, {name="mcl_hoppers:hopper_side", param2=0})
			placed = true
		elseif x == 1 then
			minetest.set_node(pos2, {name="mcl_hoppers:hopper_side", param2=2})
			placed = true
		elseif z == -1 then
			minetest.set_node(pos2, {name="mcl_hoppers:hopper_side", param2=3})
			placed = true
		elseif z == 1 then
			minetest.set_node(pos2, {name="mcl_hoppers:hopper_side", param2=1})
			placed = true
		else
			minetest.set_node(pos2, {name="mcl_hoppers:hopper"})
			placed = true
		end
		if placed == true then
			minetest.sound_play(mcl_sounds.node_sound_metal_defaults().place, { pos = pos2 })
			if not minetest.setting_getbool("creative_mode") then
				itemstack:take_item()
			end
			return itemstack
		end
	end,
})
minetest.register_craft({
	output = "mcl_hoppers:hopper_item",
	recipe = {
		{"mcl_core:iron_ingot","","mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot","mcl_chests:chest","mcl_core:iron_ingot"},
		{"","mcl_core:iron_ingot",""},
	}
})
