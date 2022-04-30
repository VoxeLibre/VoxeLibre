--[[ This mod registers 3 nodes:
- One node for the horizontal-facing dropper (mcl_droppers:dropper)
- One node for the upwards-facing droppers (mcl_droppers:dropper_up)
- One node for the downwards-facing droppers (mcl_droppers:dropper_down)

3 node definitions are needed because of the way the textures are defined.
All node definitions share a lot of code, so this is the reason why there
are so many weird tables below.
]]

local S = minetest.get_translator(minetest.get_current_modname())

-- For after_place_node
local function setup_dropper(pos)
	-- Set formspec and inventory
	local form = "size[9,8.75]"..
	"background[-0.19,-0.25;9.41,9.49;crafting_inventory_9_slots.png]"..
	"label[0,4.0;"..minetest.formspec_escape(minetest.colorize("#313131", S("Inventory"))).."]"..
	"list[current_player;main;0,4.5;9,3;9]"..
	"list[current_player;main;0,7.74;9,1;]"..
	"label[3,0;"..minetest.formspec_escape(minetest.colorize("#313131", S("Dropper"))).."]"..
	"list[context;main;3,0.5;3,3;]"..
	"listring[context;main]"..
	"listring[current_player;main]"
	local meta = minetest.get_meta(pos)
	meta:set_string("formspec", form)
	local inv = meta:get_inventory()
	inv:set_size("main", 9)
end

local function orientate_dropper(pos, placer)
	-- Not placed by player
	if not placer then return end

	-- Pitch in degrees
	local pitch = placer:get_look_vertical() * (180 / math.pi)

	if pitch > 55 then
		minetest.swap_node(pos, {name="mcl_droppers:dropper_up"})
	elseif pitch < -55 then
		minetest.swap_node(pos, {name="mcl_droppers:dropper_down"})
	end
end

local on_rotate
if minetest.get_modpath("screwdriver") then
	on_rotate = screwdriver.rotate_simple
end

-- Shared core definition table
local dropperdef = {
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest.get_meta(pos)
		local meta2 = meta:to_table()
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		for i=1, inv:get_size("main") do
			local stack = inv:get_stack("main", i)
			if not stack:is_empty() then
				local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
				minetest.add_item(p, stack)
			end
		end
		meta:from_table(meta2)
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return count
		end
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	_mcl_blast_resistance = 3.5,
	_mcl_hardness = 3.5,
	mesecons = {effector = {
		-- Drop random item when triggered
		action_on = function(pos, node)
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
				local dropitem = ItemStack(stack)
				dropitem:set_count(1)
				local stack_id = stacks[r].stackpos

				-- If it's a container, attempt to put it into the container
				local dropped = mcl_util.move_item_container(pos, droppos, nil, stack_id)
				-- No container?
				if not dropped and not dropnodedef.groups.container then
					-- Drop item normally
					minetest.add_item(droppos, dropitem)
					stack:take_item()
					inv:set_stack("main", stack_id, stack)
				end
			end
		end,
		rules = mesecon.rules.alldirs,
	}},
	on_rotate = on_rotate,
}

-- Horizontal dropper

local horizontal_def = table.copy(dropperdef)
horizontal_def.description = S("Dropper")
horizontal_def._doc_items_longdesc = S("A dropper is a redstone component and a container with 9 inventory slots which, when supplied with redstone power, drops an item or puts it into a container in front of it.")
horizontal_def._doc_items_usagehelp = S("Droppers can be placed in 6 possible directions, items will be dropped out of the hole. Use the dropper to access its inventory. Supply it with redstone energy once to make the dropper drop or transfer a random item.")

function horizontal_def.after_place_node(pos, placer, itemstack, pointed_thing)
	setup_dropper(pos)
	orientate_dropper(pos, placer)
end

horizontal_def.tiles = {
	"default_furnace_top.png", "default_furnace_bottom.png",
	"default_furnace_side.png", "default_furnace_side.png",
	"default_furnace_side.png", "mcl_droppers_dropper_front_horizontal.png",
}
horizontal_def.paramtype2 = "facedir"
horizontal_def.groups = {pickaxey=1, container=2, material_stone=1}

minetest.register_node("mcl_droppers:dropper", horizontal_def)

-- Down dropper
local down_def = table.copy(dropperdef)
down_def.description = S("Downwards-Facing Dropper")
down_def.after_place_node = setup_dropper
down_def.tiles = {
	"default_furnace_top.png", "mcl_droppers_dropper_front_vertical.png",
	"default_furnace_side.png", "default_furnace_side.png",
	"default_furnace_side.png", "default_furnace_side.png",
}
down_def.groups = {pickaxey=1, container=2,not_in_creative_inventory=1, material_stone=1}
down_def._doc_items_create_entry = false
down_def.drop = "mcl_droppers:dropper"
minetest.register_node("mcl_droppers:dropper_down", down_def)

-- Up dropper
-- The up dropper is almost identical to the down dropper, it only differs in textures
local up_def = table.copy(down_def)
up_def.description = S("Upwards-Facing Dropper")
up_def.tiles = {
	"mcl_droppers_dropper_front_vertical.png", "default_furnace_bottom.png",
	"default_furnace_side.png", "default_furnace_side.png",
	"default_furnace_side.png", "default_furnace_side.png",
}
minetest.register_node("mcl_droppers:dropper_up", up_def)



-- Ladies and gentlemen, I present to you: the crafting recipe!
minetest.register_craft({
	output = "mcl_droppers:dropper",
	recipe = {
		{"mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble",},
		{"mcl_core:cobble", "", "mcl_core:cobble",},
		{"mcl_core:cobble", "mesecons:redstone", "mcl_core:cobble",},
	}
})

-- Add entry aliases for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mcl_droppers:dropper", "nodes", "mcl_droppers:dropper_down")
	doc.add_entry_alias("nodes", "mcl_droppers:dropper", "nodes", "mcl_droppers:dropper_up")
end

minetest.register_lbm({
	label = "Update dropper formspecs (0.51.0)",
	name = "mcl_droppers:update_formspecs_0_51_0",
	nodenames = { "mcl_droppers:dropper", "mcl_droppers:dropper_down", "mcl_droppers:dropper_up" },
	action = function(pos, node)
		minetest.registered_nodes[node.name].on_construct(pos)
		minetest.log("action", "[mcl_droppers] Node formspec updated at "..minetest.pos_to_string(pos))
	end,
})

