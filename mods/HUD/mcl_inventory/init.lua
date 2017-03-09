mcl_inventory = {}

local show_armor = false
if minetest.get_modpath("3d_armor") ~= nil then show_armor = true end

local function item_drop(itemstack, dropper, pos)
	if dropper:is_player() then
		local v = dropper:get_look_dir()
		local p = {x=pos.x, y=pos.y+1.2, z=pos.z}
		p.x = p.x+(math.random(1,3)*0.2)
		p.z = p.z+(math.random(1,3)*0.2)
		local obj = minetest.add_item(p, itemstack)
		if obj then
			v.x = v.x*4
			v.y = v.y*4 + 2
			v.z = v.z*4
			obj:setvelocity(v)
		end
	else
		minetest.add_item(pos, itemstack)
	end
	return itemstack
end

local function drop_fields(player, name)
	local inv = player:get_inventory()
	for i,stack in ipairs(inv:get_list(name)) do
		item_drop(stack, player, player:getpos())
		stack:clear()
		inv:set_stack(name, i, stack)
	end
end

local function update_armor(player)
	return
end

local function set_inventory(player, armor_change_only)
	if minetest.setting_getbool("creative_mode") then
		if armor_change_only then
			-- Stay on survival inventory plage if only the armor has been changed
			mcl_inventory.set_creative_formspec(player, 0, 0, nil, "inv")
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
	-- TODO: Use player.png to allow for custom skins
	local img = "crafting_player2d.png"
	local armor_img = ""
	local player_preview = "image[0.6,0.2;2,4;"..img.."]"
	if show_armor and armor.textures[player_name] and armor.textures[player_name].preview then
		img = armor.textures[player_name].preview
		local s1 = img:find("character_preview")
		if s1 ~= nil then
			s1 = img:sub(s1+21)
			img = "crafting_player2d.png"..s1
		end
		player_preview = "image[1.1,0.2;2,4;"..img.."]"
	end

	local armor_slots = {"head", "torso", "legs", "feet"}
	local armor_slot_imgs = ""
	for a=1,4 do
		if inv:get_stack("armor", a+1):is_empty() then
			armor_slot_imgs = armor_slot_imgs .. "image[0,"..(a-1)..";1,1;crafting_slot_"..armor_slots[a]..".png]"
		end
	end

	local form = "size[9,8.75]"..
	"background[-0.19,-0.25;9.41,9.49;crafting_formspec_bg.png^crafting_inventory.png"..armor_img.."]"..
	mcl_vars.inventory_header..
	player_preview..
	--armor
	"list[detached:"..player_name.."_armor;armor;0,0;1,1;1]"..
	"list[detached:"..player_name.."_armor;armor;0,1;1,1;2]"..
	"list[detached:"..player_name.."_armor;armor;0,2;1,1;3]"..
	"list[detached:"..player_name.."_armor;armor;0,3;1,1;4]"..
	armor_slot_imgs..
	-- craft and inventory
	"list[current_player;main;0,4.5;9,3;9]"..
	"list[current_player;main;0,7.74;9,1;]"..
	"list[current_player;craft;4,1;2,2]"..
	"list[current_player;craftpreview;7,1.5;1,1;]"..
	-- crafting guide button
	"image_button[8,0;1,1;craftguide_book.png;__mcl_craftguide;]"..
	"tooltip[__mcl_craftguide;Show crafting recipes]"..
	-- achievements button
	"image_button[8,1;1,1;mcl_achievements_button.png;__mcl_achievements;]"..
	"tooltip[__mcl_achievements;Achievements]"..
	-- for shortcuts
	"listring[current_player;main]"..
	"listring[current_player;craft]"..
	"listring[current_player;main]"..
	"listring[detached:"..player_name.."_armor;armor]"..
	-- inventory marker
	"inv"
	
	player:set_inventory_formspec(form)
end

local function set_workbench(player)
	player:get_inventory():set_width("craft", 3)
	player:get_inventory():set_size("craft", 9)

	local form = "size[9,8.75]"..
	"background[-0.19,-0.25;9.41,9.49;crafting_formspec_bg.png^crafting_inventory_workbench.png]"..
	mcl_vars.inventory_header..
	"list[current_player;main;0,4.5;9,3;9]"..
	"list[current_player;main;0,7.74;9,1;]"..
	"list[current_player;craft;1.75,0.5;3,3;]"..
	"list[current_player;craftpreview;6.1,1.5;1,1;]"..
	"image_button[8,0;1,1;craftguide_book.png;__mcl_craftguide;]"..
	"tooltip[__mcl_craftguide;Show crafting recipes]"..
	"listring[current_player;main]"..
	"listring[current_player;craft]"..
	-- inventory marker
	"wob"

	--player:set_inventory_formspec(form)
	minetest.show_formspec(player:get_player_name(), "main", form)
end

--drop craf items and reset inventory on closing
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.quit then
		local formspec = player:get_inventory_formspec()
		local size = string.len(formspec)
		local marker = string.sub(formspec,size-2)
		if marker == "inv" or marker == "wob" or marker == "cin" then
			drop_fields(player,"craft")			
			set_inventory(player)
		end
	end
end)

-- Drop crafting grid items on leaving
minetest.register_on_leaveplayer(function(player)
	drop_fields(player, "craft")
end)

minetest.register_on_joinplayer(function(player)
	--init inventory
	set_inventory(player)
	player:get_inventory():set_width("main", 9)
	player:get_inventory():set_size("main", 36)

	--set hotbar size
	player:hud_set_hotbar_itemcount(9)
	--add hotbar images
	player:hud_set_hotbar_image("crafting_hotbar.png")
 	player:hud_set_hotbar_selected_image("crafting_hotbar_selected.png")

	if show_armor then
		local armor_orginal = armor.set_player_armor
		armor.set_player_armor = function(self, player)
			armor_orginal(self, player)
			update_armor(player)
			set_inventory(player, true)
		end
	end

	--[[ Make sure the crafting grid is empty. Why? Because the player might have
	items remaining in the crafting grid from the previous join; this is likely
	when the server has been shutdown and the server didn't clean up the player
	inventories. ]]
	drop_fields(player, "craft")
end)

minetest.register_node("mcl_inventory:workbench", {
	description = "Crafting Table",
	tiles = {"crafting_workbench_top.png", "default_wood.png", "crafting_workbench_side.png",
		"crafting_workbench_side.png", "crafting_workbench_front.png", "crafting_workbench_front.png"},
	paramtype2 = "facedir",
	paramtype = "light",
	groups = {handy=1,axey=1, deco_block=1},
	on_rightclick = function(pos, node, clicker, itemstack)
		set_workbench(clicker)
	end,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 12.5,
	_mcl_hardness = 2.5,
})

minetest.register_craft({
	output = "mcl_inventory:workbench",
	recipe = {
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"}
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_inventory:workbench",
	burntime = 15,
})

minetest.register_alias("crafting:workbench", "mcl_inventory:workbench")

if minetest.setting_getbool("creative_mode") then
	dofile(minetest.get_modpath("mcl_inventory").."/creative.lua")
end
