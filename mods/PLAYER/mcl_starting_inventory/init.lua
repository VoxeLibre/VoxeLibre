--- Copyright 2023, Michieal. (Modifications for the mod to be usable in Mineclone 2.)
---    Based on mtg mod, give_initial_stuff. "Written by C55 and various minetest developers."
---
--- Copyright notice created for the license to be valid. (MIT 3)

local stuff_string = minetest.settings:get("starting_inv_contents") or
		"mcl_tools:pick_iron,mcl_tools:axe_iron,mcl_tools:shovel_iron," ..
				"mcl_torches:torch 32,mcl_core:cobble 64"

mcl_starting_inventory = {
	items = {}
}

function mcl_starting_inventory.give(player)
	minetest.log("action",
			"Giving initial stuff to player " .. player:get_player_name())
	local inv = player:get_inventory()
	for _, stack in ipairs(mcl_starting_inventory.items) do
		inv:add_item("main", stack)
	end
end

function mcl_starting_inventory.add(stack)
	mcl_starting_inventory.items[#mcl_starting_inventory.items + 1] = ItemStack(stack)
end

function mcl_starting_inventory.clear()
	mcl_starting_inventory.items = {}
end

function mcl_starting_inventory.add_from_csv(str)
	local items = str:split(",")
	for _, itemname in ipairs(items) do
		mcl_starting_inventory.add(itemname)
	end
end

function mcl_starting_inventory.set_list(list)
	mcl_starting_inventory.items = list
end

function mcl_starting_inventory.get_list()
	return mcl_starting_inventory.items
end

mcl_starting_inventory.add_from_csv(stuff_string)
if minetest.settings:get_bool("mcl_starting_inventory") then
	minetest.register_on_newplayer(mcl_starting_inventory.give)
end
