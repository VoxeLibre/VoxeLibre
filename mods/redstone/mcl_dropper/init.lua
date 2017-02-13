minetest.register_node("mcl_dropper:dropper", {
	description = "Dropper",
	tiles = {
		"default_furnace_top.png", "default_furnace_bottom.png",
		"default_furnace_side.png", "default_furnace_side.png",
		"default_furnace_side.png", "mcl_dropper_dropper_front_horizontal.png"
	}, 
	groups = {cracky=2,container=2},
	is_ground_content = false,
	paramtype2 = "facedir",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	after_place_node = function(pos)
		local form = "size[9,8.75]"..
		"background[-0.19,-0.25;9.41,9.49;crafting_inventory_9_slots.png]"..
		mcl_core.inventory_header..
		"image[3,-0.2;5,0.75;mcl_dropper_fnt_dropper.png]"..
		"list[current_player;main;0,4.5;9,3;9]"..
		"list[current_player;main;0,7.74;9,1;]"..
		"list[current_name;main;3,0.5;3,3;]"..
		"listring[current_name;main]"..
		"listring[current_player;main]"
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", form)
		local inv = meta:get_inventory()
		inv:set_size("main", 9)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest.get_meta(pos)
		local meta2 = meta
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		for i=1, inv:get_size("main") do
			local stack = inv:get_stack("main", i)
			if not stack:is_empty() then
				local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
				minetest.add_item(p, stack)
			end
		end
		meta:from_table(meta2:to_table())
	end,
	mesecons = {effector = {
		-- Drop random item when triggered
		action_on = function (pos, node)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local droppos = vector.subtract(pos, minetest.facedir_to_dir(node.param2))
			local dropnode = minetest.get_node(droppos)
			-- Do not drop into solid nodes, unless they are containers
			local dropnodedef = minetest.registered_nodes[dropnode.name]
			if dropnodedef.walkable and not dropnodedef.groups.container then
				return
			end
			local stacks = {}
			for i=1,inv:get_size("main") do
				local stack = inv:get_stack("main", i)
				if not stack:is_empty() then
					table.insert(stacks, {stack = stack, stackpos = i})
				end
			end
			if #stacks >= 1 then
				local r = math.random(1, #stacks)
				local stack = stacks[r].stack
				local dropitem = ItemStack(stack:get_name())
				local stack_id = stacks[r].stackpos
				-- If it's a container, put it into the container
				if dropnodedef.groups.container then
					local dropmeta = minetest.get_meta(droppos)
					local dropinv = dropmeta:get_inventory()
					if dropnodedef.groups.container == 2 then
						mcl_util.move_item(inv, "main", stack_id, dropinv, "main")
					elseif dropnodedef.groups.container == 3 then
						if not minetest.registered_nodes[stack:get_name()].groups.shulker_box then
							mcl_util.move_item(inv, "main", stack_id, dropinv, "main")
						end
					elseif dropnodedef.groups.container == 4 then
						mcl_util.move_item(inv, "main", stack_id, dropinv, "src")
					end
				else
				-- Drop item normally
					minetest.add_item(droppos, dropitem)
					stack:take_item()
					inv:set_stack("main", stack_id, stack)
				end
			end
		end
	}}
})

minetest.register_craft({
	output = 'mcl_dropper:dropper',
	recipe = {
		{"mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble",},
		{"mcl_core:cobble", "", "mcl_core:cobble",},
		{"mcl_core:cobble", "mesecons:redstone", "mcl_core:cobble",},
	}
})
