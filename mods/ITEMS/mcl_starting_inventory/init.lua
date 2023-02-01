--- Copyright 2023, Michieal. (Modifications for the mod to be usable in Mineclone 2.)
---    Based on mtg mod, give_initial_stuff. "Written by C55 and various minetest developers."
---
--- Copyright notice created for the license to be valid. (MIT 3)

local DEBUG = false

local function mcl_log(message)
	if DEBUG then
		minetest.log(message)
	end
end

local give_inventory = minetest.settings:get_bool("give_starting_inv", false)

local stuff_string = "mcl_tools:pick_iron,mcl_tools:axe_iron,mcl_tools:shovel_iron,mcl_torches:torch 32,mcl_core:cobble 32"

mcl_starting_inventory = {
	items = {}
}

function mcl_starting_inventory.give(player)
	mcl_log("Giving initial stuff to player " .. player:get_player_name())
	local inv = player:get_inventory()
	for _, stack in ipairs(mcl_starting_inventory.items) do
		if inv:room_for_item("main", stack) then
			inv:add_item("main", stack)
		else
			mcl_log("no room for the item: " .. dump(stack))
		end
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

if give_inventory and give_inventory == true then
	mcl_starting_inventory.add_from_csv(stuff_string)
	mcl_log("Okay to give inventory:\n" .. dump(mcl_starting_inventory.get_list()))
end

minetest.register_on_newplayer(mcl_starting_inventory.give)
