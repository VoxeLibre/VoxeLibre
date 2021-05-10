--[[
By EliasFleckenstein03 and Code-Sploit
]]

local S = minetest.get_translator("mcl_smithing_table")
mcl_smithing_table = {}

-- Function to upgrade diamond tool/armor to netherite tool/armor
function mcl_smithing_table.upgrade_item(itemstack)
	itemstack = ItemStack(itemstack)	-- Copy the stack

	local def = itemstack:get_definition()

	if not def or not def._mcl_upgradable then
		return
	end

	local itemname = itemstack:get_name()

	local upgrade_item = def._mcl_upgrade_item

	if upgrade_item and mcl_enchanting.is_enchanted(itemname) then
		upgrade_item = upgrade_item .. "_enchanted"
	end

	upgrade_item = upgrade_item or itemname:gsub("diamond", "netherite")

	if upgrade_item == itemname then
		return
	end

	itemstack:set_name(upgrade_item)

	-- Reload the ToolTips of the tool
	tt.reload_itemstack_description(itemstack)

	-- Only return itemstack if upgrade was successfull
	return itemstack
end

-- Badly copied over from mcl_anvils
-- ToDo: Make better formspec

local formspec = "size[9,9]" ..
		   "label[0,4.0;" .. minetest.formspec_escape(minetest.colorize(mcl_colors.DARK_GRAY, S("Inventory"))) .. "]" ..
		   "list[current_player;main;0,4.5;9,3;9]" ..
		   mcl_formspec.get_itemslot_bg(0,4.5,9,3) ..
		   "list[current_player;main;0,7.74;9,1;]" ..
		   mcl_formspec.get_itemslot_bg(0,7.74,9,1) ..
		   "list[context;diamond_item;1,2.5;1,1;]" ..
		   mcl_formspec.get_itemslot_bg(1,2.5,1,1) ..
		   "list[context;netherite;4,2.5;1,1;]" ..
		   mcl_formspec.get_itemslot_bg(4,2.5,1,1) ..
		   "list[context;upgraded_item;8,2.5;1,1;]" ..
		   mcl_formspec.get_itemslot_bg(8,2.5,1,1) ..
		   "label[3,0.1;" .. minetest.formspec_escape(minetest.colorize(mcl_colors.DARK_GRAY, S("Upgrade Gear"))) .. "]" ..
		   "listring[context;output]"..
		   "listring[current_player;main]"..
		   "listring[context;input]"..
		   "listring[current_player;main]"

local function reset_upgraded_item(pos)
	local inv = minetest.get_meta(pos):get_inventory()
	local upgraded_item

	if inv:get_stack("netherite", 1):get_name() == "mcl_nether:netherite_ingot" then
		upgraded_item = mcl_smithing_table.upgrade_item(inv:get_stack("diamond_item", 1))
	end

	inv:set_stack("upgraded_item", 1, upgraded_item)
end

minetest.register_node("mcl_smithing_table:table", {
	description = S("Smithing table"),
	-- ToDo: Add _doc_items_longdesc and _doc_items_usagehelp

	stack_max = 64,
	groups = {pickaxey = 2, deco_block = 1},

	tiles = {
		"mcl_smithing_table_top.png", "mcl_smithing_table_bottom.png", "mcl_smithing_table_side.png",
		"mcl_smithing_table_side.png", "mcl_smithing_table_side.png", "mcl_smithing_table_front.png"
	},

	sounds = mcl_sounds.node_sound_metal_defaults(),

	on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec", formspec)

			local inv = meta:get_inventory()

    	inv:set_size("diamond_item", 1)
			inv:set_size("netherite", 1)
			inv:set_size("upgraded_item", 1)
  end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "diamond_item" and mcl_smithing_table.upgrade_item(stack) or listname == "netherite" and stack:get_name() == "mcl_nether:netherite_ingot" then
			return stack:get_count()
		end

		return 0
	end,

	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		return 0
	end,

	on_metadata_inventory_put = reset_upgraded_item,

	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local inv = minetest.get_meta(pos):get_inventory()

		local function take_item(listname)
			local itemstack = inv:get_stack(listname, 1)
			itemstack:take_item()
			inv:set_stack(listname, 1, itemstack)
		end

		if listname == "upgraded_item" then
			take_item("diamond_item")
			take_item("netherite")

			-- ToDo: make epic sound
			minetest.sound_play("mcl_smithing_table_upgrade", {pos = pos, max_hear_distance = 16})
		end

		reset_upgraded_item(pos)
	end,

	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 2.5
})

minetest.register_craft({
	output = "mcl_smithing_table:table",
	recipe = {
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot", ""},
		{"group:wood", "group:wood", ""},
		{"group:wood", "group:wood", ""}
	}
})
