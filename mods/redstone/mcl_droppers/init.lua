--[[ This mod registers 3 nodes:
- One node for the horizontal-facing dropper (mcl_droppers:dropper)
- One node for the upwards-facing droppers (mcl_droppers:dropper_up)
- One node for the downwards-facing droppers (mcl_droppers:dropper_down)

3 node definitions are needed because of the way the textures are defined.
All node definitions share a lot of code, so this is the reason why there
are so many weird tables below.
]]

-- For after_place_node
local setup_dropper = function(pos)
	-- Set formspec and inventory
	local form = "size[9,8.75]"..
	"background[-0.19,-0.25;9.41,9.49;crafting_inventory_9_slots.png]"..
	mcl_core.inventory_header..
	"image[3,-0.2;5,0.75;mcl_droppers_fnt_dropper.png]"..
	"list[current_player;main;0,4.5;9,3;9]"..
	"list[current_player;main;0,7.74;9,1;]"..
	"list[current_name;main;3,0.5;3,3;]"..
	"listring[current_name;main]"..
	"listring[current_player;main]"
	local meta = minetest.get_meta(pos)
	meta:set_string("formspec", form)
	local inv = meta:get_inventory()
	inv:set_size("main", 9)
end

-- Shared core definition table
local dropperdef = {
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
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
			local droppos
			if node.name == "mcl_droppers:dropper" then
				droppos  = vector.subtract(pos, minetest.facedir_to_dir(node.param2))
			elseif node.name == "mcl_droppers:dropper_up" then
				droppos  = {x=pos.x, y=pos.y+1, z=pos.z}
			elseif node.name == "mcl_droppers:dropper_down" then
				droppos  = {x=pos.x, y=pos.y-1, z=pos.z}
			end
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

				-- If it's a container, attempt to put it into the container
				local dropped = mcl_util.move_item_container(pos, "main", stack_id, droppos)
				-- No container?
				if not dropped and not dropnodedef.groups.container then
					-- Drop item normally
					minetest.add_item(droppos, dropitem)
					stack:take_item()
					inv:set_stack("main", stack_id, stack)
				end
			end
		end
	}}
}

-- Horizontal dropper

local horizontal_def = table.copy(dropperdef)
horizontal_def.description = "Dropper"
horizontal_def.after_place_node = function(pos, placer, itemstack, pointed_thing)
	setup_dropper(pos)

	-- When placed up and down, convert node to up/down dropper
	if pointed_thing.above.y < pointed_thing.under.y then
		minetest.swap_node(pos, {name = "mcl_droppers:dropper_down"})
	elseif pointed_thing.above.y > pointed_thing.under.y then
		minetest.swap_node(pos, {name = "mcl_droppers:dropper_up"})
	end

	-- Else, the normal facedir logic applies
end
horizontal_def.tiles = {
	"default_furnace_top.png", "default_furnace_bottom.png",
	"default_furnace_side.png", "default_furnace_side.png",
	"default_furnace_side.png", "mcl_droppers_dropper_front_horizontal.png"
}
horizontal_def.paramtype2 = "facedir"
horizontal_def.groups = {cracky=2,container=2}

minetest.register_node("mcl_droppers:dropper", horizontal_def)

-- Down dropper
local down_def = table.copy(dropperdef)
down_def.description = "Downwards-Facing Dropper"
down_def.after_place_node = setup_dropper
down_def.tiles = {
	"default_furnace_top.png", "mcl_droppers_dropper_front_vertical.png",
	"default_furnace_side.png", "default_furnace_side.png",
	"default_furnace_side.png", "default_furnace_side.png"
}
down_def.groups = {cracky=2,container=2,not_in_creative_inventory=1}
down_def.drop = "mcl_droppers:dropper"
minetest.register_node("mcl_droppers:dropper_down", down_def)

-- Up dropper
-- The up dropper is almost identical to the down dropper, it only differs in textures
up_def = table.copy(down_def)
up_def.description = "Upwards-Facing Dropper"
up_def.tiles = {
	"mcl_droppers_dropper_front_vertical.png", "default_furnace_bottom.png",
	"default_furnace_side.png", "default_furnace_side.png",
	"default_furnace_side.png", "default_furnace_side.png"
}
minetest.register_node("mcl_droppers:dropper_up", up_def)



-- Ladies and gentlemen, I present to you: the crafting recipe!
minetest.register_craft({
	output = 'mcl_droppers:dropper',
	recipe = {
		{"mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble",},
		{"mcl_core:cobble", "", "mcl_core:cobble",},
		{"mcl_core:cobble", "mesecons:redstone", "mcl_core:cobble",},
	}
})
