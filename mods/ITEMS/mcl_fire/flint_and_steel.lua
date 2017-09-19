-- Flint and Steel
minetest.register_tool("mcl_fire:flint_and_steel", {
	description = "Flint and Steel",
	_doc_items_longdesc = "Flint and steel is a tool to start fires and ignite blocks.",
	_doc_items_usagehelp = "Rightclick the surface of a block to attempt to light a fire in front of it or ignite the block. A few blocks have an unique reaction when ignited.",
	inventory_image = "mcl_fire_flint_and_steel.png",
	liquids_pointable = false,
	stack_max = 1,
	groups = { tool = 1 },
	on_place = function(itemstack, user, pointed_thing)
		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
			end
		end

		local idef = itemstack:get_definition()
		minetest.sound_play(
			"fire_flint_and_steel",
			{pos = pointed_thing.above, gain = 0.5, max_hear_distance = 8}
		)
		local used = false
		if pointed_thing.type == "node" then
			local nodedef = minetest.registered_nodes[minetest.get_node(pointed_thing.under).name]
			if nodedef and nodedef._on_ignite then
				local overwrite = nodedef._on_ignite(user, pointed_thing)
				if not overwrite then
					mcl_fire.set_fire(pointed_thing)
				end
			else
				mcl_fire.set_fire(pointed_thing)
			end
			used = true
		end
		if itemstack:get_count() == 0 and idef.sound and idef.sound.breaks then
			minetest.sound_play(idef.sound.breaks, {pos=user:getpos(), gain=0.5})
		end
		if not minetest.settings:get_bool("creative_mode") and used == true then
			itemstack:add_wear(65535/65) -- 65 uses
		end
		return itemstack
	end,
	sound = { breaks = "default_tool_breaks" },
})

minetest.register_craft({
	type = 'shapeless',
	output = 'mcl_fire:flint_and_steel',
	recipe = { 'mcl_core:iron_ingot', 'mcl_core:flint'},
})
