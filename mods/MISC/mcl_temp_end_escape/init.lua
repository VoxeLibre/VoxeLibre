local escape = function(itemstack, user, pointed_thing)
	local pos = user:get_pos()
	if not pos then
		return itemstack
	end
	local dim = mcl_worlds.pos_to_dimension(pos)

	if dim == "end" then
		local target = mcl_spawn.get_spawn_pos(user)
		user:set_pos(target)
		minetest.sound_play("mcl_portals_teleport", {pos=target, gain=0.5, max_hear_distance = 16})
		itemstack:take_item()
	else
		minetest.chat_send_player(user:get_player_name(), "This item only works in the End.")
	end
	return itemstack
end
	

minetest.register_craftitem("mcl_temp_end_escape:end_escape_pearl", {
	description = "End Escape Pearl",
	_doc_items_longdesc = "With this item you can teleport from the End back to spawn point in the Overworld.".."\n".."This item will be removed in later versions.",
	_doc_items_uagehelp = "Use rightclick to use. This only works in the End.",
	inventory_image = "mcl_throwing_ender_pearl.png^[colorize:#0000FF:127",
	wield_image = "mcl_throwing_ender_pearl.png^[colorize:#0000FF:127",
	on_place = escape,
	on_secondary_use = escape, 
	stack_max = 64,
})

minetest.register_craft({
	output = "mcl_temp_end_escape:end_escape_pearl",
	type = "shapeless",
	recipe = {
		"mcl_throwing:ender_pearl","mcl_mobitems:shulker_shell",
		"mcl_mobitems:shulker_shell","mcl_throwing:ender_pearl",
	},
})
