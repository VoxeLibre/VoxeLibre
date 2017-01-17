

local chest = minetest.get_content_id("default:chest")

local hopper_formspec =
	"size[9,7]"..
	"background[-0.19,-0.25;9.41,10.48;hopper_inventory.png]"..
	default.inventory_header..
	"list[current_name;main;2,0.5;5,1;]"..
	"list[current_player;main;0,2.5;9,3;9]"..
	"list[current_player;main;0,5.74;9,1;]"..
	"listring[current_name;main]"..
	"listring[current_player;main]"

minetest.register_node("hopper:hopper", {
	drop = "hopper:hopper_item",
	description = "Hopper (Node)",
	groups = {cracky=1,level=2,not_in_creative_inventory=1},
	drawtype = "nodebox",
	paramtype = "light",
	tiles = {"default_coal_block.png"},
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
		meta:set_string("formspec", hopper_formspec)
		local inv = meta:get_inventory()
		inv:set_size("main", 5)
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in hopper at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to hopper at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from hopper at "..minetest.pos_to_string(pos))
	end,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("hopper:hopper_side", {
	description = "Hopper (Side)",
	drop = "hopper:hopper_item",
	groups = {cracky=1,level=2,not_in_creative_inventory=1},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {"default_coal_block.png"},
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
		meta:set_string("formspec", hopper_formspec)
		local inv = meta:get_inventory()
		inv:set_size("main", 5)
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in hopper at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to hopper at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from hopper at "..minetest.pos_to_string(pos))
	end,
	sounds = default.node_sound_metal_defaults(),
})
--make hoppers suck in blocks
minetest.register_abm({
	nodenames = {"hopper:hopper","hopper:hopper_side"},
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
	nodenames = {"hopper:hopper"},
	neighbors = {"default:chest","default:chest_left","default:chest_right","hopper:hopper","hopper:hopper_side","default:furnace","default:furnace_active"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)

		local min = {x=pos.x-1,y=pos.y-1,z=pos.z-1}
		local max = {x=pos.x+1,y=pos.y+1,z=pos.z+1}
		local vm = minetest.get_voxel_manip()	
		local emin, emax = vm:read_from_map(min,max)
		local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
		local data = vm:get_data()	

		local a = vm:get_node_at({x=pos.x,y=pos.y-1,z=pos.z}).name
		local b = vm:get_node_at({x=pos.x,y=pos.y+1,z=pos.z}).name

		--the hopper input
		if b == "default:chest" then
			--hopper inventory
			local meta = minetest.get_meta(pos);
			local inv = meta:get_inventory()
			local invsize = inv:get_size("main")

			--chest/hopper/furnace inventory
			local meta2 = minetest.get_meta({x=pos.x,y=pos.y+1,z=pos.z});
			local inv2 = meta2:get_inventory()
			local invsize2 = inv2:get_size("main")
			if inv2:is_empty("main") == false then
				for i = 1,invsize2 do
					local stack = inv2:get_stack("main", i)
					local item = stack:get_name()
					if item ~= "" then
						if inv:room_for_item("main", item) == false then
							--print("no room for items 2")
							--return
						end
						--print(stack:to_string())
						stack:take_item(1)
						inv2:set_stack("main", i, stack)
						--add to hopper
						--print("adding item")
						inv:add_item("main", item)
						break
					
					end
				end
			end
		end
		if b == "default:furnace" or b == "default:furnace_active" then
			--hopper inventory
			local meta = minetest.get_meta(pos);
			local inv = meta:get_inventory()
			local invsize = inv:get_size("main")

			--chest/hopper/furnace inventory
			local meta2 = minetest.get_meta({x=pos.x,y=pos.y+1,z=pos.z});
			local inv2 = meta2:get_inventory()
			local invsize2 = inv2:get_size("dst")
			if inv2:is_empty("dst") == false then
		
				for i = 1,invsize2 do
					local stack = inv2:get_stack("dst", i)
					local item = stack:get_name()
					if item ~= "" then
						if inv:room_for_item("main", item) == false then
							--print("no room for items")
							return
						end
						--print(stack:to_string())
						stack:take_item(1)
						inv2:set_stack("dst", i, stack)
						--add to hopper
						--print("adding item")
						inv:add_item("main", item)
						break
					
					end
				end
			end
		end
	
		--the hopper output
		if a == "default:chest" or a == "default:chest_left" or a == "default:chest_right" or a == "hopper:hopper" or a == "hopper:hopper_side" then
			--hopper inventory
			local meta = minetest.get_meta(pos);
			local inv = meta:get_inventory()
			if inv:is_empty("main") == true then
				return
			end
			local invsize = inv:get_size("main")

			--chest/hopper/furnace inventory
			local meta2 = minetest.get_meta({x=pos.x,y=pos.y-1,z=pos.z});
			local inv2 = meta2:get_inventory()
			local invsize2 = inv2:get_size("main")
		
			for i = 1,invsize do
				local stack = inv:get_stack("main", i)
				local item = stack:get_name()
				if item ~= "" then
					if inv2:room_for_item("main", item) == false then
						--print("no room for items")
						return
					end
					stack:take_item(1)
					inv:set_stack("main", i, stack)
					--add to hopper or chest
					--print("adding item")
					inv2:add_item("main", item)
					break
					
				end
			end
			--print(inv)
		elseif a == "default:furnace" or a == "default:furnace_active" then
			--print("test")
			--room_for_item(listname, stack)
			--hopper inventory
			local meta = minetest.get_meta(pos);
			--print(dump(meta:to_table()))
			local inv = meta:get_inventory()
			if inv:is_empty("main") == true then
				return
			end
			local invsize = inv:get_size("main")

			--chest/hopper/furnace inventory
			local meta2 = minetest.get_meta({x=pos.x,y=pos.y-1,z=pos.z});
			local inv2 = meta2:get_inventory()
			local invsize2 = inv2:get_size("src")
		
			for i = 1,invsize do
				local stack = inv:get_stack("main", i)
				local item = stack:get_name()
				if item ~= "" then
					if inv2:room_for_item("src", item) == false then
						--print("no room for items")
						return
					end
					minetest.get_node_timer({x=pos.x,y=pos.y-1,z=pos.z}):start(1.0)
					stack:take_item(1)
					inv:set_stack("main", i, stack)
					--add to hopper or chest
					--print("adding item")
					inv2:add_item("src", item)
					break
					
				end
			end
		end
	end,
})


minetest.register_abm({
	nodenames = {"hopper:hopper_side"},
	neighbors = {"default:chest","default:chest_left","default_chest_right","hopper:hopper","hopper:hopper_side","default:furnace","default:furnace_active"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)

		local min = {x=pos.x-1,y=pos.y-1,z=pos.z-1}
		local max = {x=pos.x+1,y=pos.y+1,z=pos.z+1}
		local vm = minetest.get_voxel_manip()	
		local emin, emax = vm:read_from_map(min,max)
		local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
		local data = vm:get_data()	
		local face = vm:get_node_at(pos).param2
		local front = {}
		--print(face)
		if face == 0 then
			front = {x=pos.x-1,y=pos.y,z=pos.z}
		elseif face == 1 then
			front = {x=pos.x,y=pos.y,z=pos.z+1}
		elseif face == 2 then
			front = {x=pos.x+1,y=pos.y,z=pos.z}
		elseif face == 3 then
			front = {x=pos.x,y=pos.y,z=pos.z-1}
		end
		local a = vm:get_node_at(front).name
		local b = vm:get_node_at({x=pos.x,y=pos.y+1,z=pos.z}).name

		--the hopper input
		if b == "default:chest" or b == "default:chest_left" or b == "default:chest_right" then
			--hopper inventory
			local meta = minetest.get_meta(pos);
			local inv = meta:get_inventory()
			local invsize = inv:get_size("main")

			--chest/hopper/furnace inventory
			local meta2 = minetest.get_meta({x=pos.x,y=pos.y+1,z=pos.z});
			local inv2 = meta2:get_inventory()
			local invsize2 = inv2:get_size("main")
			if inv2:is_empty("main") == false then
				for i = 1,invsize2 do
					local stack = inv2:get_stack("main", i)
					local item = stack:get_name()
					if item ~= "" then
						if inv:room_for_item("main", item) == false then
							--print("no room for items 2")
							--return
						end
						--print(stack:to_string())
						stack:take_item(1)
						inv2:set_stack("main", i, stack)
						--add to hopper
						--print("adding item")
						inv:add_item("main", item)
						break
					
					end
				end
			end
		end
		if b == "default:furnace" or b == "default:furnace_active" then
			--hopper inventory
			local meta = minetest.get_meta(pos);
			local inv = meta:get_inventory()
			local invsize = inv:get_size("main")

			--chest/hopper/furnace inventory
			local meta2 = minetest.get_meta({x=pos.x,y=pos.y+1,z=pos.z});
			local inv2 = meta2:get_inventory()
			local invsize2 = inv2:get_size("dst")
			if inv2:is_empty("dst") == false then
				for i = 1,invsize2 do
					local stack = inv2:get_stack("dst", i)
					local item = stack:get_name()
					if item ~= "" then
						if inv:room_for_item("main", item) == false then
							--print("no room for items")
							return
						end
						--print(stack:to_string())
						stack:take_item(1)
						inv2:set_stack("dst", i, stack)
						--add to hopper
						--print("adding item")
						inv:add_item("main", item)
						break
					
					end
				end
			end
		end
	
		--the hopper output
		if a == "default:chest" or a == "default:chest_left" or "default:chest_right" or a == "hopper:hopper" or a == "hopper:hopper_side" then
			--print("test")
			--room_for_item(listname, stack)
			--hopper inventory
			local meta = minetest.get_meta(pos);
			--print(dump(meta:to_table()))
			local inv = meta:get_inventory()
			if inv:is_empty("main") == true then
				return
			end
			local invsize = inv:get_size("main")

			--chest/hopper/furnace inventory
			local meta2 = minetest.get_meta(front);
			local inv2 = meta2:get_inventory()
			local invsize2 = inv2:get_size("main")
		
			for i = 1,invsize do
				local stack = inv:get_stack("main", i)
				local item = stack:get_name()
				if item ~= "" then
					if inv2:room_for_item("main", item) == false then
						--print("no room for items")
						return
					end
					stack:take_item(1)
					inv:set_stack("main", i, stack)
					--add to hopper or chest
					--print("adding item")
					inv2:add_item("main", item)
					break
					
				end
			end
			--print(inv)
		elseif a == "default:furnace" or a == "default:furnace_active" then
			--print("test")
			--room_for_item(listname, stack)
			--hopper inventory
			local meta = minetest.get_meta(pos);
			--print(dump(meta:to_table()))
			local inv = meta:get_inventory()
			if inv:is_empty("main") == true then
				return
			end
			local invsize = inv:get_size("main")

			--chest/hopper/furnace inventory
			local meta2 = minetest.get_meta(front);
			local inv2 = meta2:get_inventory()
			local invsize2 = inv2:get_size("fuel")
		
			for i = 1,invsize do
				local stack = inv:get_stack("main", i)
				local item = stack:get_name()
				if item ~= "" then
					if inv2:room_for_item("fuel", item) == false then
						--print("no room for items")
						return
					end
					stack:take_item(1)
					inv:set_stack("main", i, stack)
					--add to hopper or chest
					--print("adding item")
					minetest.get_node_timer(front):start(1.0)
					inv2:add_item("fuel", item)
					break
					
				end
			end
		end
	end,
})

minetest.register_craftitem("hopper:hopper_item", {
	description = "Hopper",
	inventory_image = "hopper_item.png",
	on_place = function(itemstack, placer, pointed_thing)
		local pos  = pointed_thing.under
		local pos2 = pointed_thing.above

		local x = pos.x - pos2.x
		local y = pos.y - pos2.y
		local z = pos.z - pos2.z
		
		local placed = false

		if x == -1 then
			minetest.set_node(pos2, {name="hopper:hopper_side", param2=0})
			placed = true
		elseif x == 1 then
			minetest.set_node(pos2, {name="hopper:hopper_side", param2=2})
			placed = true
		elseif z == -1 then
			minetest.set_node(pos2, {name="hopper:hopper_side", param2=3})
			placed = true
		elseif z == 1 then
			minetest.set_node(pos2, {name="hopper:hopper_side", param2=1})
			placed = true
		else
			minetest.set_node(pos2, {name="hopper:hopper"})
			placed = true
		end
		if placed == true then
			if not minetest.setting_getbool("creative_mode") then
				itemstack:take_item()
			end
			return itemstack
		end
	end,
})
minetest.register_craft({
	output = "hopper:hopper_item",
	recipe = {
		{"default:steel_ingot","","default:steel_ingot"},
		{"default:steel_ingot","default:chest","default:steel_ingot"},
		{"","default:steel_ingot",""},
	}
})
