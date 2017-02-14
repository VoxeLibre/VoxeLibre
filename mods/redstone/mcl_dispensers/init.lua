--[[ This mod registers 3 nodes:
- One node for the horizontal-facing dispensers (mcl_dispensers:dispenser)
- One node for the upwards-facing dispensers (mcl_dispenser:dispenser_up)
- One node for the downwards-facing dispensers (mcl_dispenser:dispenser_down)

3 node definitions are needed because of the way the textures are defined.
All node definitions share a lot of code, so this is the reason why there
are so many weird tables below.
]]

-- For after_place_node
local setup_dispenser = function(pos)
	-- Set formspec and inventory
	local form = "size[9,8.75]"..
	"background[-0.19,-0.25;9.41,9.49;crafting_inventory_9_slots.png]"..
	mcl_core.inventory_header..
	"image[3,-0.2;5,0.75;mcl_dispensers_fnt_dispenser.png]"..
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
local dispenserdef = {
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
		-- Dispense random item when triggered
		action_on = function (pos, node)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local droppos
			if node.name == "mcl_dispensers:dispenser" then
				droppos  = vector.subtract(pos, minetest.facedir_to_dir(node.param2))
			elseif node.name == "mcl_dispensers:dispenser_up" then
				droppos  = {x=pos.x, y=pos.y+1, z=pos.z}
			elseif node.name == "mcl_dispensers:dispenser_down" then
				droppos  = {x=pos.x, y=pos.y-1, z=pos.z}
			end
			local dropnode = minetest.get_node(droppos)
			-- Do not dispense into solid nodes
			local dropnodedef = minetest.registered_nodes[dropnode.name]
			if dropnodedef.walkable then
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
				local iname = stack:get_name()
				local igroups = minetest.registered_items[iname].groups

				--[===[ Dispense item ]===]
				if iname == "mcl_fire:flint_and_steel" then
					-- Ignite air or fire
					if dropnode.name == "air" then
						minetest.add_node(droppos, {name="mcl_fire:basic_flame"})
						if not minetest.setting_getbool("creative_mode") then
							stack:add_wear(65535/65) -- 65 uses
						end
					elseif dropnode.name == "mcl_tnt:tnt" then
						tnt.ignite(droppos)
						if not minetest.setting_getbool("creative_mode") then
							stack:add_wear(65535/65) -- 65 uses
						end
					end

					inv:set_stack("main", stack_id, stack)
				elseif igroups.head or igroups.shulker_box or iname == "mcl_farming:pumpkin_face" then
					-- Place head, shulker box, or pumpkin
					if dropnodedef.buildable_to then
						minetest.set_node(droppos, {name = iname, param2 = node.param2})
						stack:take_item()
						inv:set_stack("main", stack_id, stack)
					end

				-- TODO: Many other dispenser actions
				else
					-- Drop item
					minetest.add_item(droppos, dropitem)
	
					stack:take_item()
					inv:set_stack("main", stack_id, stack)
				end
			end
		end
	}}
}

-- Horizontal dispenser

local horizontal_def = table.copy(dispenserdef)
horizontal_def.description = "Dispenser"
horizontal_def.after_place_node = function(pos, placer, itemstack, pointed_thing)
	setup_dispenser(pos)

	-- When placed up and down, convert node to up/down dispenser
	if pointed_thing.above.y < pointed_thing.under.y then
		minetest.swap_node(pos, {name = "mcl_dispensers:dispenser_down"})
	elseif pointed_thing.above.y > pointed_thing.under.y then
		minetest.swap_node(pos, {name = "mcl_dispensers:dispenser_up"})
	end

	-- Else, the normal facedir logic applies
end
horizontal_def.tiles = {
	"default_furnace_top.png", "default_furnace_bottom.png",
	"default_furnace_side.png", "default_furnace_side.png",
	"default_furnace_side.png", "mcl_dispensers_dispenser_front_horizontal.png"
}
horizontal_def.paramtype2 = "facedir"
horizontal_def.groups = {cracky=2,container=2}

minetest.register_node("mcl_dispensers:dispenser", horizontal_def)

-- Down dispenser
local down_def = table.copy(dispenserdef)
down_def.description = "Downwards-Facing Dispenser"
down_def.after_place_node = setup_dispenser
down_def.tiles = {
	"default_furnace_top.png", "mcl_dispensers_dispenser_front_vertical.png",
	"default_furnace_side.png", "default_furnace_side.png",
	"default_furnace_side.png", "default_furnace_side.png"
}
down_def.groups = {cracky=2,container=2,not_in_creative_inventory=1}
down_def.drop = "mcl_dispensers:dispenser"
minetest.register_node("mcl_dispensers:dispenser_down", down_def)

-- Up dispenser
-- The up dispenser is almost identical to the down dispenser , it only differs in textures
up_def = table.copy(down_def)
up_def.description = "Upwards-Facing Dispenser"
up_def.tiles = {
	"mcl_dispensers_dispenser_front_vertical.png", "default_furnace_bottom.png",
	"default_furnace_side.png", "default_furnace_side.png",
	"default_furnace_side.png", "default_furnace_side.png"
}
minetest.register_node("mcl_dispensers:dispenser_up", up_def)



minetest.register_craft({
	output = 'mcl_dispensers:dispenser',
	recipe = {
		{"mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble",},
		{"mcl_core:cobble", "mcl_throwing:bow", "mcl_core:cobble",},
		{"mcl_core:cobble", "mesecons:redstone", "mcl_core:cobble",},
	}
})
