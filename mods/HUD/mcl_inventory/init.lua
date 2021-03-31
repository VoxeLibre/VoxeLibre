local S = minetest.get_translator("mcl_inventory")
local F = minetest.formspec_escape

mcl_inventory = {}

local show_armor = minetest.get_modpath("mcl_armor") ~= nil
local mod_player = minetest.get_modpath("mcl_player") ~= nil
local mod_craftguide = minetest.get_modpath("mcl_craftguide") ~= nil

-- Returns a single itemstack in the given inventory to the main inventory, or drop it when there's no space left
function return_item(itemstack, dropper, pos, inv)
	if dropper:is_player() then
		-- Return to main inventory
		if inv:room_for_item("main", itemstack) then
			inv:add_item("main", itemstack)
		else
			-- Drop item on the ground
			local v = dropper:get_look_dir()
			local p = {x=pos.x, y=pos.y+1.2, z=pos.z}
			p.x = p.x+(math.random(1,3)*0.2)
			p.z = p.z+(math.random(1,3)*0.2)
			local obj = minetest.add_item(p, itemstack)
			if obj then
				v.x = v.x*4
				v.y = v.y*4 + 2
				v.z = v.z*4
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

-- Return items in the given inventory list (name) to the main inventory, or drop them if there is no space left
function return_fields(player, name)
	local inv = player:get_inventory()
	local list = inv:get_list(name)
	if not list then return end
	for i,stack in ipairs(list) do
		return_item(stack, player, player:get_pos(), inv)
		stack:clear()
		inv:set_stack(name, i, stack)
	end
end

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
	local inv = player:get_inventory()
	inv:set_width("craft", 2)
	inv:set_size("craft", 4)

	local player_name = player:get_player_name()

	-- Show armor and player image
	local player_preview
	if minetest.settings:get_bool("3d_player_preview", true) then
		player_preview = mcl_player.get_player_formspec_model(player, 1.0, 0.0, 2.25, 4.5, "")
	else
		local img, img_player
		if mod_player then
			img_player = mcl_player.player_get_preview(player)
		else
			img_player = "player.png"
		end
		img = img_player
		player_preview = "image[0.6,0.2;2,4;"..img.."]"
		if show_armor and armor.textures[player_name] and armor.textures[player_name].preview then
			img = armor.textures[player_name].preview
			local s1 = img:find("character_preview")
			if s1 ~= nil then
				s1 = img:sub(s1+21)
				img = img_player..s1
			end
			player_preview = "image[1.1,0.2;2,4;"..img.."]"
		end
	end

	local armor_slots = {"helmet", "chestplate", "leggings", "boots"}
	local armor_slot_imgs = ""
	for a=1,4 do
		if inv:get_stack("armor", a+1):is_empty() then
			armor_slot_imgs = armor_slot_imgs .. "image[0,"..(a-1)..";1,1;mcl_inventory_empty_armor_slot_"..armor_slots[a]..".png]"
		end
	end

	local form = "size[9,8.75]"..
	"background[-0.19,-0.25;9.41,9.49;crafting_formspec_bg.png]"..
	player_preview..
	--armor
	"list[detached:"..player_name.."_armor;armor;0,0;1,1;1]"..
	"list[detached:"..player_name.."_armor;armor;0,1;1,1;2]"..
	"list[detached:"..player_name.."_armor;armor;0,2;1,1;3]"..
	"list[detached:"..player_name.."_armor;armor;0,3;1,1;4]"..
	mcl_formspec.get_itemslot_bg(0,0,1,1)..
	mcl_formspec.get_itemslot_bg(0,1,1,1)..
	mcl_formspec.get_itemslot_bg(0,2,1,1)..
	mcl_formspec.get_itemslot_bg(0,3,1,1)..
	armor_slot_imgs..
	-- craft and inventory
	"label[0,4;"..F(minetest.colorize(mcl_colors.DARK_GRAY, S("Inventory"))).."]"..
	"list[current_player;main;0,4.5;9,3;9]"..
	"list[current_player;main;0,7.74;9,1;]"..
	"label[4,0.5;"..F(minetest.colorize(mcl_colors.DARK_GRAY, S("Crafting"))).."]"..
	"list[current_player;craft;4,1;2,2]"..
	"list[current_player;craftpreview;7,1.5;1,1;]"..
	mcl_formspec.get_itemslot_bg(0,4.5,9,3)..
	mcl_formspec.get_itemslot_bg(0,7.74,9,1)..
	mcl_formspec.get_itemslot_bg(4,1,2,2)..
	mcl_formspec.get_itemslot_bg(7,1.5,1,1)..
	-- crafting guide button
	"image_button[4.5,3;1,1;craftguide_book.png;__mcl_craftguide;]"..
	"tooltip[__mcl_craftguide;"..F(S("Recipe book")).."]"..
	-- help button
	"image_button[8,3;1,1;doc_button_icon_lores.png;__mcl_doc;]"..
	"tooltip[__mcl_doc;"..F(S("Help")).."]"..
	-- skins button
	"image_button[3,3;1,1;mcl_skins_button.png;__mcl_skins;]"..
	"tooltip[__mcl_skins;"..F(S("Select player skin")).."]"..
	-- achievements button
	"image_button[7,3;1,1;mcl_achievements_button.png;__mcl_achievements;]"..
	"tooltip[__mcl_achievements;"..F(S("Achievements")).."]"..
	-- for shortcuts
	"listring[current_player;main]"..
	"listring[current_player;craft]"..
	"listring[current_player;main]"..
	"listring[detached:"..player_name.."_armor;armor]"

	player:set_inventory_formspec(form)
end

-- Drop items in craft grid and reset inventory on closing
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.quit then
		return_fields(player,"craft")
		return_fields(player,"enchanting_lapis")
		return_fields(player,"enchanting_item")
		if not minetest.is_creative_enabled(player:get_player_name()) and (formname == "" or formname == "main") then
			set_inventory(player)
		end
	end
end)

if not minetest.is_creative_enabled("") then
	mcl_inventory.update_inventory_formspec = function(player)
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
	player:get_inventory():set_width("main", 9)
	player:get_inventory():set_size("main", 36)

	--set hotbar size
	player:hud_set_hotbar_itemcount(9)
	--add hotbar images
	player:hud_set_hotbar_image("mcl_inventory_hotbar.png")
	player:hud_set_hotbar_selected_image("mcl_inventory_hotbar_selected.png")

	if show_armor then
		local set_player_armor_original = armor.set_player_armor
		local update_inventory_original = armor.update_inventory
		armor.set_player_armor = function(self, player)
			set_player_armor_original(self, player)
		end
		armor.update_inventory = function(self, player)
			update_inventory_original(self, player)
			set_inventory(player, true)
		end
		armor:set_player_armor(player)
		armor:update_inventory(player)
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

if minetest.is_creative_enabled("") then
	dofile(minetest.get_modpath("mcl_inventory").."/creative.lua")
end

