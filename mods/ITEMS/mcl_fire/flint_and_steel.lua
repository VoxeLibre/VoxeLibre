-- Flint and Steel
minetest.register_tool("mcl_fire:flint_and_steel", {
	description = "Flint and Steel",
	inventory_image = "mcl_fire_flint_and_steel.png",
	liquids_pointable = false,
	stack_max = 1,
	groups = { tool = 1 },
	on_use = function(itemstack, user, pointed_thing)
		local idef = itemstack:get_definition()
		minetest.sound_play(
			"fire_flint_and_steel",
			{pos = pointed_thing.above, gain = 0.5, max_hear_distance = 8}
		)
		if pointed_thing.type == "node" then
			if minetest.get_node(pointed_thing.under).name == "mcl_tnt:tnt" then
				tnt.ignite(pointed_thing.under)
				if not minetest.setting_getbool("creative_mode") then
					itemstack:add_wear(65535/65) -- 65 uses
				end
			else
				mcl_fire.set_fire(pointed_thing)
				if not minetest.setting_getbool("creative_mode") then
					itemstack:add_wear(65535/65) -- 65 uses
				end
			end
		end
		if itemstack:get_count() == 0 and idef.sound and idef.sound.breaks then
			minetest.sound_play(idef.sound.breaks, {pos=user:getpos(), gain=0.5})
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
