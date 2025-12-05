-- By EliasFleckenstein03 and Code-Sploit

local S = minetest.get_translator("mcl_smithing_table")
local F = minetest.formspec_escape
local C = minetest.colorize

mcl_smithing_table = {}

-- Function to upgrade diamond tool/armor to netherite tool/armor
---@param itemstack ItemStack
function mcl_smithing_table.upgrade_item_netherite(itemstack)
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
	mcl_armor.reload_trim_inv_image(itemstack)

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
	"list[context;upgrade_item;1.625,2.6;1,1;]",

	"image[3.125,2.6;1,1;mcl_anvils_inventory_cross.png]",

	mcl_formspec.get_itemslot_bg_v4(4.75, 2.6, 1, 1),
	"list[context;mineral;4.75,2.6;1,1;]",

	mcl_formspec.get_itemslot_bg_v4(6, 2.6, 1, 1),
    mcl_formspec.get_itemslot_bg_v4(6, 2.6, 1, 1, 0, "mcl_smithing_table_inventory_trim_bg.png"),
	"list[context;template;6,2.6;1,1;]",

	"image[7,2.6;2,1;mcl_anvils_inventory_arrow.png]",

	mcl_formspec.get_itemslot_bg_v4(9.125, 2.6, 1, 1),
	"list[context;upgraded_item;9.125,2.6;1,1;]",

	-- Player Inventory

	mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
	"list[current_player;main;0.375,5.1;9,3;9]",

	mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
	"list[current_player;main;0.375,9.05;9,1;]",

	-- Listrings

	"listring[context;upgrade_item]",
	"listring[current_player;main]",
	"listring[context;mineral]",
	"listring[current_player;main]",
	"listring[context;upgraded_item]",
	"listring[current_player;main]",
	"listring[current_player;main]",
	"listring[context;upgrade_item]",
})

local smithing_materials = {
	["mcl_nether:netherite_ingot"]	= "netherite",
	["mcl_core:diamond"]			= "diamond",
	["mcl_core:lapis"]				= "lapis",
	["mcl_amethyst:amethyst_shard"]	= "amethyst",
	["mesecons:wire_00000000_off"]	= "redstone",
	["mcl_core:iron_ingot"]			= "iron",
	["mcl_core:gold_ingot"]			= "gold",
	["mcl_copper:copper_ingot"]		= "copper",
	["mcl_core:emerald"]			= "emerald",
	["mcl_nether:quartz"]			= "quartz"
}

local achievement_trims = {
	["mcl_armor:spire"]		=	true,
	["mcl_armor:snout"]		=	true,
	["mcl_armor:rib"]		=	true,
	["mcl_armor:ward"]		=	true,
	["mcl_armor:silence"]	=	true,
	["mcl_armor:vex"]		=	true,
	["mcl_armor:tide"]		=	true,
	["mcl_armor:wayfinder"]	=	true
}

function mcl_smithing_table.upgrade_trimmed(itemstack, color_mineral, template)
	--get information required
	local material_name = color_mineral:get_name()
	material_name = smithing_materials[material_name]

	local overlay = template:get_definition()._mcl_armor_template_name

	--trimming process
	mcl_armor.trim(itemstack, overlay, material_name)
	tt.reload_itemstack_description(itemstack)

	return itemstack
end

function mcl_smithing_table.is_smithing_mineral(itemname) 
	return smithing_materials[itemname] ~= nil
end

---@param pos Vector
local function reset_upgraded_item(pos)
	local inv = minetest.get_meta(pos):get_inventory()
	local upgraded_item
	local upgrade_stack = inv:get_stack("upgrade_item", 1)
	local upgrade_def = upgrade_stack:get_definition()
	local template_present = inv:get_stack("template",1):get_name() ~= ""
	local is_armor = upgrade_def._mcl_armor_element ~= nil

	if inv:get_stack("mineral", 1):get_name() == "mcl_nether:netherite_ingot" and not template_present then
		upgraded_item = mcl_smithing_table.upgrade_item_netherite(inv:get_stack("upgrade_item", 1))
	elseif template_present and is_armor and mcl_smithing_table.is_smithing_mineral(inv:get_stack("mineral", 1):get_name()) then
		upgraded_item = mcl_smithing_table.upgrade_trimmed(inv:get_stack("upgrade_item", 1),inv:get_stack("mineral", 1),inv:get_stack("template", 1))
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

		inv:set_size("upgrade_item", 1)
		inv:set_size("mineral", 1)
		inv:set_size("template",1)
		inv:set_size("upgraded_item", 1)
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return 0
		end

		local stackname = stack:get_name()
		local def = stack:get_definition()
		if 
					listname == "upgrade_item"
			and 	(def._mcl_armor_element
			and not mcl_armor.trims.blacklisted[stackname] -- allow any armor piece to go in (in case the player wants to trim them)
			or 		def._mcl_upgradable) -- for diamond tools
			or 		listname == "mineral"
			and 	mcl_smithing_table.is_smithing_mineral(stackname)
			or 		listname == "template"
			and 	def._mcl_armor_template
		then
			return stack:get_count()
		end

		return 0
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
			-- ToDo: make epic sound
			minetest.sound_play("mcl_smithing_table_upgrade", { pos = pos, max_hear_distance = 16 })
	
			if stack:get_name() == "mcl_farming:hoe_netherite" then
				awards.unlock(player:get_player_name(), "mcl:seriousDedication")
			elseif mcl_armor.is_trimmed(stack) then
				local template_name = inv:get_stack("template", 1):get_name()
				local playername = player:get_player_name()
				awards.unlock(playername, "mcl:trim")
	
				if not awards.players[playername].unlocked["mcl:lots_of_trimming"] and achievement_trims[template_name] then
					local meta = player:get_meta()
					local used_achievement_trims = minetest.deserialize(meta:get_string("mcl_smithing_table:achievement_trims")) or {}
					if not used_achievement_trims[template_name] then
						used_achievement_trims[template_name] = true
					end
	
					local used_all = true
					for name, _ in pairs(achievement_trims) do
						if not used_achievement_trims[name] then
							used_all = false
							break
						end
					end
	
					if used_all then
						awards.unlock(playername, "mcl:lots_of_trimming")
					else
						meta:set_string("mcl_smithing_table:achievement_trims", minetest.serialize(used_achievement_trims))
					end
				end
			end
	
			take_item("upgrade_item")
			take_item("mineral")
			take_item("template")
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

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_smithing_table:table",
	burntime = 15,
})

-- this is the exact same as mcl_smithing_table.upgrade_item_netherite , in case something relies on the old function
function mcl_smithing_table.upgrade_item(itemstack)
	return mcl_smithing_table.upgrade_item_netherite(itemstack)
end
