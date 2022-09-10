local S = minetest.get_translator(minetest.get_current_modname())
local F = minetest.formspec_escape

mcl_inventory = {}

--local mod_player = minetest.get_modpath("mcl_player")
--local mod_craftguide = minetest.get_modpath("mcl_craftguide")

---Returns a single itemstack in the given inventory to the main inventory, or drop it when there's no space left.
---@param itemstack ItemStack
---@param dropper ObjectRef
---@param pos Vector
---@param inv InvRef
local function return_item(itemstack, dropper, pos, inv)
	if dropper:is_player() then
		-- Return to main inventory
		if inv:room_for_item("main", itemstack) then
			inv:add_item("main", itemstack)
		else
			-- Drop item on the ground
			local v = dropper:get_look_dir()
			local p = vector.offset(pos, 0, 1.2, 0)
			p.x = p.x + (math.random(1, 3) * 0.2)
			p.z = p.z + (math.random(1, 3) * 0.2)
			local obj = minetest.add_item(p, itemstack)
			if obj then
				v.x = v.x * 4
				v.y = v.y * 4 + 2
				v.z = v.z * 4
				obj:set_velocity(v)
				obj:get_luaentity()._insta_collect = false
			end
		end
	else
		-- Fallback for unexpected cases
		minetest.add_item(pos, itemstack)
	end
	return itemstack
end

---Return items in the given inventory list (name) to the main inventory, or drop them if there is no space left.
---@param player ObjectRef
---@param name string
local function return_fields(player, name)
	local inv = player:get_inventory()

	---@diagnostic disable need-check-nil

	local list = inv:get_list(name)
	if not list then return end
	for i, stack in ipairs(list) do
		return_item(stack, player, player:get_pos(), inv)
		stack:clear()
		inv:set_stack(name, i, stack)
	end

	---@diagnostic enable need-check-nil
end

---@param player ObjectRef
local function set_inventory(player)
	if minetest.is_creative_enabled(player:get_player_name()) then
		mcl_inventory.set_creative_formspec(player)
		return
	end

	local inv = player:get_inventory()

	---@diagnostic disable need-check-nil
	inv:set_width("craft", 2)
	inv:set_size("craft", 4)

	local armor_slots = { "helmet", "chestplate", "leggings", "boots" }
	local armor_slot_imgs = ""

	for a = 1, 4 do
		if inv:get_stack("armor", a + 1):is_empty() then
			armor_slot_imgs = armor_slot_imgs ..
				"image[0.375," ..
				(0.375 + (a - 1) * 1.25) .. ";1,1;mcl_inventory_empty_armor_slot_" .. armor_slots[a] .. ".png]"
		end
	end

	if inv:get_stack("offhand", 1):is_empty() then
		armor_slot_imgs = armor_slot_imgs .. "image[5.375,4.125;1,1;mcl_inventory_empty_armor_slot_shield.png]"
	end

	---@diagnostic enable need-check-nil

	local form = table.concat({
		"formspec_version[6]",
		"size[11.75,10.9]",

		--Armor slots
		mcl_formspec.get_itemslot_bg_v4(0.375, 0.375, 1, 4),
		"list[current_player;armor;0.375,0.375;1,1;1]",
		"list[current_player;armor;0.375,1.625;1,1;2]",
		"list[current_player;armor;0.375,2.875;1,1;3]",
		"list[current_player;armor;0.375,4.125;1,1;4]",

		--Main inventory
		mcl_formspec.get_itemslot_bg_v4(0.375, 5.575, 9, 3),
		"list[current_player;main;0.375,5.575;9,3;9]",

		--Hotbar
		mcl_formspec.get_itemslot_bg_v4(0.375, 9.525, 9, 1),
		"list[current_player;main;0.375,9.525;9,1;]",

		--Player model
		"image[1.57,0.343;3.62,4.85;mcl_inventory_background9.png;2]",
		mcl_player.get_player_formspec_model(player, 1.57, 0.4, 3.62, 4.85, ""),

		--Offhand
		mcl_formspec.get_itemslot_bg_v4(5.375, 4.125, 1, 1),
		"list[current_player;offhand;5.375,4.125;1,1]",

		armor_slot_imgs,

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

		--Advancements button
		"image_button[10.325,4.075;1.1,1.1;mcl_achievements_button.png;__mcl_achievements;]",
		"tooltip[__mcl_achievements;" .. F(S("Advancements")) .. "]",

		--Listring
		"listring[current_player;main]",
		"listring[current_player;armor]",
		"listring[current_player;main]",
		"listring[current_player;craft]",
		"listring[current_player;main]",
	})

	player:set_inventory_formspec(form)
end

-- Drop items in craft grid and reset inventory on closing
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.quit then
		return_fields(player, "craft")
		return_fields(player, "enchanting_lapis")
		return_fields(player, "enchanting_item")
		if not minetest.is_creative_enabled(player:get_player_name()) and (formname == "" or formname == "main") then
			set_inventory(player)
		end
	end
end)

mcl_inventory.update_inventory_formspec = set_inventory

-- Drop crafting grid items on leaving
minetest.register_on_leaveplayer(function(player)
	return_fields(player, "craft")
	return_fields(player, "enchanting_lapis")
	return_fields(player, "enchanting_item")
end)

minetest.register_on_joinplayer(function(player)
	--init inventory
	local inv = player:get_inventory()

	---get_inventory can return nil if object isn't a player, but we are sure this is one :)
	---@diagnostic disable need-check-nil
	inv:set_width("main", 9)
	inv:set_size("main", 36)
	inv:set_size("offhand", 1)
	---@diagnostic enable need-check-nil

	--set hotbar size
	player:hud_set_hotbar_itemcount(9)
	--add hotbar images
	player:hud_set_hotbar_image("mcl_inventory_hotbar.png")
	player:hud_set_hotbar_selected_image("mcl_inventory_hotbar_selected.png")

	-- In Creative Mode, the initial inventory setup is handled in creative.lua
	if not minetest.is_creative_enabled(player:get_player_name()) then
		set_inventory(player)
	end

	--[[ Make sure the crafting grid is empty. Why? Because the player might have
	items remaining in the crafting grid from the previous join; this is likely
	when the server has been shutdown and the server didn't clean up the player
	inventories. ]]
	return_fields(player, "craft")
	return_fields(player, "enchanting_item")
	return_fields(player, "enchanting_lapis")
end)


dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/creative.lua")

local mt_is_creative_enabled = minetest.is_creative_enabled

function minetest.is_creative_enabled(name)
	if mt_is_creative_enabled(name) then return true end
	if not name then return false end
	local p = minetest.get_player_by_name(name)
	if p then
		return p:get_meta():get_string("gamemode") == "creative"
	end
	return false
end

--Insta "digging" nodes in gamemode-creative
minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
	if not puncher or not puncher:is_player() then return end
	local name = puncher:get_player_name()
	if not minetest.is_creative_enabled(name) then return end
	if pointed_thing.type ~= "node" then return end
	local def = minetest.registered_nodes[node.name]
	if def then
		minetest.node_dig(pos, node, puncher)
		return true
	end
end)

--Don't subtract from inv when placing in gamemode-creative
minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	if placer and placer:is_player() and minetest.is_creative_enabled(placer:get_player_name()) then return true end
end)

local function in_table(n, h)
	for k, v in pairs(h) do
		if v == n then return true end
	end
	return false
end

local gamemodes = {
	"survival",
	"creative"
}

function mcl_inventory.player_set_gamemode(p, g)
	local m = p:get_meta()
	m:set_string("gamemode", g)
	if g == "survival" then
		mcl_experience.setup_hud(p)
		mcl_experience.update(p)
	elseif g == "creative" then
		mcl_experience.remove_hud(p)
	end
	mcl_meshhand.update_player(p)
	set_inventory(p)
end

minetest.register_chatcommand("gamemode", {
	params = S("[<gamemode>] [<player>]"),
	description = S("Change gamemode (survival/creative) for yourself or player"),
	privs = { server = true },
	func = function(n, param)
		-- Full input validation ( just for @erlehmann <3 )
		local p
		local args = param:split(" ")
		if args[2] ~= nil then
			p = minetest.get_player_by_name(args[2])
			n = args[2]
		else
			p = minetest.get_player_by_name(n)
		end
		if not p then
			return false, S("Player not online")
		end
		if args[1] ~= nil and not in_table(args[1], gamemodes) then
			return false, S("Gamemode " .. args[1] .. " does not exist.")
		elseif args[1] ~= nil then
			mcl_inventory.player_set_gamemode(p, args[1])
		end

		--Result message - show effective game mode
		local gm = p:get_meta():get_string("gamemode")
		if gm == "" then gm = gamemodes[1] end
		return true, S("Gamemode for player ") .. n .. S(": " .. gm)
	end
})
local S = minetest.get_translator(minetest.get_current_modname())
local F = minetest.formspec_escape

---get_inventory can return nil if object isn't a player, but we are sure sometimes this is one :)
---@diagnostic disable need-check-nil

mcl_inventory = {}

dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/creative.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/survival.lua")

--local mod_player = minetest.get_modpath("mcl_player")
--local mod_craftguide = minetest.get_modpath("mcl_craftguide")

---Returns a single itemstack in the given inventory to the main inventory, or drop it when there's no space left.
---@param itemstack ItemStack
---@param dropper ObjectRef
---@param pos Vector
---@param inv InvRef
local function return_item(itemstack, dropper, pos, inv)
	if dropper:is_player() then
		-- Return to main inventory
		if inv:room_for_item("main", itemstack) then
			inv:add_item("main", itemstack)
		else
			-- Drop item on the ground
			local v = dropper:get_look_dir()
			local p = vector.offset(pos, 0, 1.2, 0)
			p.x = p.x + (math.random(1, 3) * 0.2)
			p.z = p.z + (math.random(1, 3) * 0.2)
			local obj = minetest.add_item(p, itemstack)
			if obj then
				v.x = v.x * 4
				v.y = v.y * 4 + 2
				v.z = v.z * 4
				obj:set_velocity(v)
				obj:get_luaentity()._insta_collect = false
			end
		end
	else
		-- Fallback for unexpected cases
		minetest.add_item(pos, itemstack)
	end
	return itemstack
end

---Return items in the given inventory list (name) to the main inventory, or drop them if there is no space left.
---@param player ObjectRef
---@param name string
local function return_fields(player, name)
	local inv = player:get_inventory()

	local list = inv:get_list(name)
	if not list then return end
	for i, stack in ipairs(list) do
		return_item(stack, player, player:get_pos(), inv)
		stack:clear()
		inv:set_stack(name, i, stack)
	end
end

---@param player ObjectRef
---@param armor_change_only? boolean
local function set_inventory(player, armor_change_only)
	if minetest.is_creative_enabled(player:get_player_name()) then
		if armor_change_only then
			-- Stay on survival inventory plage if only the armor has been changed
			mcl_inventory.set_creative_formspec(player, 0, 0, nil, nil, "inv")
		else
			mcl_inventory.set_creative_formspec(player, 0, 1)
		end
		return
	end



	player:set_inventory_formspec(mcl_inventory.build_survival_formspec(player))
end

-- Drop items in craft grid and reset inventory on closing
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.quit then
		return_fields(player, "craft")
		return_fields(player, "enchanting_lapis")
		return_fields(player, "enchanting_item")
		if not minetest.is_creative_enabled(player:get_player_name()) and (formname == "" or formname == "main") then
			set_inventory(player)
		end
	end
end)

if not minetest.is_creative_enabled("") then
	function mcl_inventory.update_inventory_formspec(player)
		set_inventory(player)
	end
end

-- Drop crafting grid items on leaving
minetest.register_on_leaveplayer(function(player)
	return_fields(player, "craft")
	return_fields(player, "enchanting_lapis")
	return_fields(player, "enchanting_item")
end)

minetest.register_on_joinplayer(function(player)
	--init inventory
	local inv = player:get_inventory()

	inv:set_width("main", 9)
	inv:set_size("main", 36)
	inv:set_size("offhand", 1)

	--set hotbar size
	player:hud_set_hotbar_itemcount(9)
	--add hotbar images
	player:hud_set_hotbar_image("mcl_inventory_hotbar.png")
	player:hud_set_hotbar_selected_image("mcl_inventory_hotbar_selected.png")

	local old_update_player = mcl_armor.update_player
	function mcl_armor.update_player(player, info)
		old_update_player(player, info)
		set_inventory(player, true)
	end

	-- In Creative Mode, the initial inventory setup is handled in creative.lua
	if not minetest.is_creative_enabled(player:get_player_name()) then
		set_inventory(player)
	end

	--[[ Make sure the crafting grid is empty. Why? Because the player might have
	items remaining in the crafting grid from the previous join; this is likely
	when the server has been shutdown and the server didn't clean up the player
	inventories. ]]
	return_fields(player, "craft")
	return_fields(player, "enchanting_item")
	return_fields(player, "enchanting_lapis")
end)

---@param player ObjectRef
---@param armor_change_only? boolean
function mcl_inventory.update_inventory(player, armor_change_only)
	local player_gamemode = mcl_gamemode.get_gamemode(player)
	if player_gamemode == "creative" then
		if armor_change_only then
			-- Stay on survival inventory plage if only the armor has been changed
			mcl_inventory.set_creative_formspec(player, 0, 0, nil, nil, "inv")
		else
			mcl_inventory.set_creative_formspec(player, 0, 1)
		end
	elseif player_gamemode == "survival" then
		player:set_inventory_formspec(mcl_inventory.build_survival_formspec(player))
	end
end

mcl_gamemode.register_on_gamemode_change(function(player, old_gamemode, new_gamemode)
	set_inventory(player)
end)
