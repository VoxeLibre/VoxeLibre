-- By EliasFleckenstein03 and Code-Sploit

local S = minetest.get_translator("mcl_smithing_table")
local F = minetest.formspec_escape
local C = minetest.colorize

mcl_smithing_table = {}

---Function to upgrade diamond tool/armor to netherite tool/armor
---@param itemstack ItemStack
function mcl_smithing_table.upgrade_item(itemstack)
	local def = itemstack:get_definition()

	if not def or not def._mcl_upgradable then
		return
	end
	local itemname = itemstack:get_name()
	local upgrade_item = itemname:gsub("diamond", "netherite")

	if def._mcl_upgrade_item and upgrade_item == itemname then
		return
	end

	itemstack:set_name(upgrade_item)

	-- Reload the ToolTips of the tool

	tt.reload_itemstack_description(itemstack)

	-- Only return itemstack if upgrade was successfull
	return itemstack
end

local formspec = table.concat({
	"formspec_version[4]",
	"size[11.75,10.425]",

	"label[4.125,0.375;" .. F(C(mcl_formspec.label_color, S("Upgrade Gear"))) .. "]",

	"image[0.875,0.375;1.75,1.75;mcl_smithing_table_inventory_hammer.png]",

	mcl_formspec.get_itemslot_bg_v4(1.625, 2.6, 1, 1),
	"list[context;diamond_item;1.625,2.6;1,1;]",

	"image[3.5,2.6;1,1;mcl_anvils_inventory_cross.png]",

	mcl_formspec.get_itemslot_bg_v4(5.375, 2.6, 1, 1),
	"list[context;netherite;5.375,2.6;1,1;]",

	"image[6.75,2.6;2,1;mcl_anvils_inventory_arrow.png]",

	mcl_formspec.get_itemslot_bg_v4(9.125, 2.6, 1, 1),
	"list[context;upgraded_item;9.125,2.6;1,1;]",

	-- Player Inventory

	mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
	"list[current_player;main;0.375,5.1;9,3;9]",

	mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
	"list[current_player;main;0.375,9.05;9,1;]",

	-- Listrings

	"listring[context;diamond_item]",
	"listring[current_player;main]",
	"listring[context;netherite]",
	"listring[current_player;main]",
	"listring[context;upgraded_item]",
	"listring[current_player;main]",
	"listring[current_player;main]",
	"listring[context;diamond_item]",
})

---@param pos Vector
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

	groups = { pickaxey = 2, deco_block = 1 },

	tiles = {
		"mcl_smithing_table_top.png",
		"mcl_smithing_table_bottom.png",
		"mcl_smithing_table_side.png",
		"mcl_smithing_table_side.png",
		"mcl_smithing_table_side.png",
		"mcl_smithing_table_front.png",
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
		if listname == "diamond_item" and mcl_smithing_table.upgrade_item(stack) or
			listname == "netherite" and stack:get_name() == "mcl_nether:netherite_ingot" then
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
			minetest.sound_play("mcl_smithing_table_upgrade", { pos = pos, max_hear_distance = 16 })
		end
		if listname == "upgraded_item" then
			if stack:get_name() == "mcl_farming:hoe_netherite" then
				awards.unlock(player:get_player_name(), "mcl:seriousDedication")
			end
		end

		reset_upgraded_item(pos)
	end,

	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 2.5
})


minetest.register_craft({
	output = "mcl_smithing_table:table",
	recipe = {
		{ "mcl_core:iron_ingot", "mcl_core:iron_ingot", "" },
		{ "group:wood", "group:wood", "" },
		{ "group:wood", "group:wood", "" }
	},
})
