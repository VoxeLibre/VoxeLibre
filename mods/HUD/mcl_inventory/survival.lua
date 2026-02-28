---@diagnostic disable need-check-nil
local S = minetest.get_translator("mcl_inventory")
local F = minetest.formspec_escape

---@type {id: string, description: string, item_icon: string, build: (fun(player: ObjectRef): string), handle: fun(player: ObjectRef, fields: table), access: (fun(player): boolean), show_inventory: boolean}[]
mcl_inventory.registered_survival_inventory_tabs = {}


---@param def {id: string, description: string, item_icon: string, build: (fun(player: ObjectRef): string), handle: fun(player: ObjectRef, fields: table), access: (fun(player): boolean), show_inventory: boolean}
function mcl_inventory.register_survival_inventory_tab(def)
	if #mcl_inventory.registered_survival_inventory_tabs == 7 then
		error("Too many tabs registered!")
	end

	assert(def.id)
	assert(def.description)
	assert(def.item_icon)
	assert(def.build)
	assert(def.handle)

	for _, d in ipairs(mcl_inventory.registered_survival_inventory_tabs) do
		assert(d.id ~= def.id, "Another tab exists with the same name!")
	end

	if not def.access then
		function def.access(player)
			return true
		end
	end

	if def.show_inventory == nil then
		def.show_inventory = true
	end

	table.insert(mcl_inventory.registered_survival_inventory_tabs, def)
end

local player_current_tab = {}
function get_player_tab(player)
	local tab = player_current_tab[player] or "main"
	player_current_tab[player] = tab
	return tab
end

minetest.register_on_joinplayer(function(player, last_login)
	get_player_tab(player)
	player:get_inventory():set_size("distr", 1)
end)

minetest.register_on_leaveplayer(function(player, timed_out)
	player_current_tab[player] = nil
end)

---@param player ObjectRef
---@param content string
---@param inventory boolean
---@param tabname string
local function build_page(player, content, inventory, tabname)
	local tab_buttons = "style_type[image;noclip=true]"

	if #mcl_inventory.registered_survival_inventory_tabs ~= 1 then
		for i, d in ipairs(mcl_inventory.registered_survival_inventory_tabs) do
			local btn_name = "tab_" .. d.id

			tab_buttons = tab_buttons .. table.concat({
				"style[" .. btn_name .. ";border=false;bgimg=;bgimg_pressed=;noclip=true]",
				"image[" ..
					(0.2 + (i - 1) * 1.6) ..
					",-1.34;1.5,1.44;" .. (tabname == d.id and "crafting_creative_active.png" or "crafting_creative_inactive.png") ..
					"]",
				"item_image_button[" .. (0.44 + (i - 1) * 1.6) .. ",-1.1;1,1;" .. d.item_icon .. ";" .. btn_name .. ";]",
				"tooltip[" .. btn_name .. ";" .. F(d.description) .. "]"
			})
		end
	end

	return table.concat({
		"formspec_version[6]",
		"size[11.75,10.9]",

		inventory and table.concat({
			--Main inventory
			mcl_formspec.get_itemslot_bg_v4(0.375, 5.575, 9, 3),
			"list[current_player;main;0.375,5.575;9,3;9]",

			--Hotbar
			mcl_formspec.get_itemslot_bg_v4(0.375, 9.525, 9, 1),
			"list[current_player;main;0.375,9.525;9,1;]"
		}) or "",

		content,
		tab_buttons,
	})
end

local main_page_static = table.concat({
	--Armor slots
	mcl_formspec.get_itemslot_bg_v4(0.375, 0.375, 1, 4),
	"list[current_player;armor;0.375,0.375;1,1;1]",
	"list[current_player;armor;0.375,1.625;1,1;2]",
	"list[current_player;armor;0.375,2.875;1,1;3]",
	"list[current_player;armor;0.375,4.125;1,1;4]",

	--Player model background
	"image[1.57,0.343;3.62,4.85;mcl_inventory_background9.png;2]",

	--Offhand
	mcl_formspec.get_itemslot_bg_v4(5.375, 4.125, 1, 1),
	"list[current_player;offhand;5.375,4.125;1,1]",

	--Craft grid
	"label[6.61,0.5;" .. F(minetest.colorize(mcl_formspec.label_color, S("Crafting"))) .. "]",

	mcl_formspec.get_itemslot_bg_v4(6.625, 0.875, 2, 2),
	"list[current_player;craft;6.625,0.875;2,2]",

	"image[9.125,1.5;1,1;crafting_formspec_arrow.png]",

	mcl_formspec.get_itemslot_bg_v4(10.375, 1.5, 1, 1),
	"list[current_player;craftpreview;10.375,1.5;1,1;]",

	--Crafting guide button
	"image_button[6.575,4.075;1.1,1.1;craftguide_book.png;__mcl_craftguide;]",
	"tooltip[__mcl_craftguide;" .. F(S("Recipe book")) .. "]",

	--Help button
	"image_button[7.825,4.075;1.1,1.1;doc_button_icon_lores.png;__mcl_doc;]",
	"tooltip[__mcl_doc;" .. F(S("Help")) .. "]",

	--Skins button
	"image_button[9.075,4.075;1.1,1.1;mcl_skins_button.png;__mcl_skins;]",
	"tooltip[__mcl_skins;" .. F(S("Select player skin")) .. "]",

	--Achievements button
	"image_button[10.325,4.075;1.1,1.1;mcl_achievements_button.png;__mcl_achievements;]",
	"tooltip[__mcl_achievements;" .. F(S("Achievements")) .. "]",

	--Listring
	"listring[current_player;craft]",
	"listring[current_player;main]",
	"listring[current_player;distr]",
	"listring[current_player;armor]",
	"listring[current_player;main]",
})

mcl_inventory.register_survival_inventory_tab({
	id = "main",
	description = "Main Inventory",
	item_icon = "mcl_crafting_table:crafting_table",
	show_inventory = true,
	build = function(player)
		local inv = player:get_inventory()

		local armor_slots = { "helmet", "chestplate", "leggings", "boots" }
		local armor_slot_imgs = ""

		for a = 1, 4 do
			if inv:get_stack("armor", a + 1):is_empty() then
				armor_slot_imgs = armor_slot_imgs ..
					"image[0.375," .. (0.375 + (a - 1) * 1.25) .. ";1,1;mcl_inventory_empty_armor_slot_" .. armor_slots[a] .. ".png]"
			end
		end

		if inv:get_stack("offhand", 1):is_empty() then
			armor_slot_imgs = armor_slot_imgs .. "image[5.375,4.125;1,1;mcl_inventory_empty_armor_slot_shield.png]"
		end
		local main_list = main_page_static .. armor_slot_imgs .. mcl_player.get_player_formspec_model(player, 1.57, 0.4, 3.62, 4.85, "")
		if core.check_player_privs(player, {server = true}) then
			main_list = main_list .. table.concat({
				-- Server Settings
				"image_button[10.325,2.825;1.1,1.1;screwdriver.png;__vl_tuning;]",
				--"style_type[image_button;border=;bgimg=;bgimg_pressed=]",
				"tooltip[__vl_tuning;" .. F(S("Server Settings")) .. "]",
			})
		end
		return main_list
	end,
	handle = function() end,
})

--[[
mcl_inventory.register_survival_inventory_tab({
	id = "test",
	description = "Test",
	item_icon = "mcl_core:stone",
	show_inventory = true,
	build = function(player)
		return "label[1,1;Hello hello]button[2,2;2,2;Hello;hey]"
	end,
	handle = function(player, fields)
		print(dump(fields))
	end,
})]]

---@param player ObjectRef
function mcl_inventory.build_survival_formspec(player)
	local inv = player:get_inventory()

	inv:set_width("craft", 2)
	inv:set_size("craft", 4)

	local tab = get_player_tab(player)

	local tab_def = nil

	for _, d in ipairs(mcl_inventory.registered_survival_inventory_tabs) do
		if tab == d.id then
			tab_def = d
			break
		end
	end

	local form = build_page(player, tab_def.build(player), tab_def.show_inventory, tab)

	return form
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local player_name = player:get_player_name()
	if formname == "" and #mcl_inventory.registered_survival_inventory_tabs ~= 1 and
		not minetest.is_creative_enabled(player_name) then
		for _, d in ipairs(mcl_inventory.registered_survival_inventory_tabs) do
			if fields["tab_" .. d.id] and d.access(player) then
				player_current_tab[player] = d.id
				mcl_inventory.update_inventory(player)
				break
			end
		end

		for _, d in ipairs(mcl_inventory.registered_survival_inventory_tabs) do
			if get_player_tab(player) == d.id and d.access(player) then
				d.handle(player, fields)
				return
			end
		end
	end
end)

core.register_allow_player_inventory_action(function (player, action, inventory, inventory_info)
	if inventory_info.to_list ~= "distr" or action ~= "move" then
		return
	end

	local fit_stack = inventory:get_stack(inventory_info.from_list, inventory_info.from_index)
	local lim = mcl_armor.pub_limit_put(player, inventory, inventory_info.to_index, fit_stack, inventory_info.count)
	if lim > 0 then
		return lim
	end

	-- If stack can fit as a whole
	if inventory:room_for_item("craft", fit_stack) then
		return fit_stack:get_count()
	end

	-- Otherwise, count how much of it can fit
	local can_fit_amount = 0
	fit_stack:set_count(1)
	for i=1, inventory:get_size("craft") do
		local craft_stack = inventory:get_stack("craft", i)
		local free_space = craft_stack:get_free_space()
		craft_stack:set_count(1)
		if craft_stack:equals(fit_stack) then
			can_fit_amount = can_fit_amount + free_space
		end
	end

	return can_fit_amount
end)

core.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
	if inventory_info.to_list ~= "distr" or action ~= "move" then
		return
	end
	
	local stack = inventory:get_stack(inventory_info.to_list, inventory_info.to_index)
	if mcl_armor.pub_limit_put(player, inventory, inventory_info.to_index, stack, inventory_info.count) > 0 then
		mcl_armor.equip(stack, player)
		inventory:set_stack("distr", 1, nil)
		return
	end

	local leftover = inventory:add_item("craft", stack)
	if not leftover:is_empty() then
		core.add_item(player:get_pos(), leftover)
		core.log("warning", "Distribution overflow! If repeats - report a bug!")
	end
	inventory:set_stack("distr", 1, nil)
end)

