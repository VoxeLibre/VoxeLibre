local S = minetest.get_translator("mcl_fire")
local get_node = minetest.get_node
local add_node = minetest.add_node

-- Flint and Steel
minetest.register_tool("mcl_fire:flint_and_steel", {
	description = S("Flint and Steel"),
	_tt_help = S("Starts fires and ignites blocks"), 
	_doc_items_longdesc = S("Flint and steel is a tool to start fires and ignite blocks."),
	_doc_items_usagehelp = S("Rightclick the surface of a block to attempt to light a fire in front of it or ignite the block. A few blocks have an unique reaction when ignited."),
	inventory_image = "mcl_fire_flint_and_steel.png",
	liquids_pointable = false,
	stack_max = 1,
	groups = { tool = 1, },
	on_place = function(itemstack, user, pointed_thing)
		-- Use pointed node's on_rightclick function first, if present
		local node = get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
			end
		end
		-- Check protection
		local protname = user:get_player_name()
		if minetest.is_protected(pointed_thing.under, protname) then
			minetest.record_protection_violation(pointed_thing.under, protname)
			return itemstack
		end

		local idef = itemstack:get_definition()
		minetest.sound_play(
			"fire_flint_and_steel",
			{pos = pointed_thing.above, gain = 0.5, max_hear_distance = 8},
			true
		)
		local used = false
		if pointed_thing.type == "node" then
			local nodedef = minetest.registered_nodes[get_node(pointed_thing.under).name]
			if nodedef and nodedef._on_ignite then
				local overwrite = nodedef._on_ignite(user, pointed_thing)
				if not overwrite then
					mcl_fire.set_fire(pointed_thing, user, false)
				end
			else
				mcl_fire.set_fire(pointed_thing, user, false)
			end
			used = true
		end
		if itemstack:get_count() == 0 and idef.sound and idef.sound.breaks then
			minetest.sound_play(idef.sound.breaks, {pos=user:get_pos(), gain=0.5}, true)
		end
		if (not minetest.is_creative_enabled(user:get_player_name())) and used == true then
			itemstack:add_wear(65535/65) -- 65 uses
		end
		return itemstack
	end,
	_dispense_into_walkable = true,
	_on_dispense = function(stack, pos, droppos, dropnode, dropdir)
		-- Ignite air
		if dropnode.name == "air" then
			add_node(droppos, {name="mcl_fire:fire"})
			if not minetest.is_creative_enabled("") then
				stack:add_wear(65535/65) -- 65 uses
			end
		-- Ignite TNT
		elseif dropnode.name == "mcl_tnt:tnt" then
			tnt.ignite(droppos)
			if not minetest.is_creative_enabled("") then
				stack:add_wear(65535/65) -- 65 uses
			end
		end
		return stack
	end,
	sound = { breaks = "default_tool_breaks" },
	_mcl_uses = 65,
})

minetest.register_craft({
	type = 'shapeless',
	output = 'mcl_fire:flint_and_steel',
	recipe = { 'mcl_core:iron_ingot', 'mcl_core:flint'},
})
