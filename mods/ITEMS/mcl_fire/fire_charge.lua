-- Fire Charge
minetest.register_craftitem("mcl_fire:fire_charge", {
	description = "Fire Charge",
	inventory_image = "mcl_fire_fire_charge.png",
	liquids_pointable = false,
	stack_max = 64,
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			if minetest.get_node(pointed_thing.under).name == "mcl_tnt:tnt" then
				tnt.ignite(pointed_thing.under)
				if not minetest.setting_getbool("creative_mode") then
					itemstack:take_item()
				end
			else
				mcl_fire.set_fire(pointed_thing)
				if not minetest.setting_getbool("creative_mode") then
					itemstack:take_item()
				end
			end
		end
		return itemstack
	end,
})

minetest.register_craft({
	type = 'shapeless',
	output = 'mcl_fire:fire_charge 3',
	recipe = { 'mcl_mobitems:blaze_powder', 'group:coal', 'mcl_core:gunpowder' },
})
