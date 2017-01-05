inven = {}
CREATIVE_FORMSPEC = "";
SURVIVAL_FORMSPEC = "";

function inventory.creative_inv(player)
local name = player:get_player_name()
CREATIVE_FORMSPEC = "invsize[11,9.75;]"..
	--"background[-0.25,1;10.5,8;inventory_creative_inventory_bg.png]"..
	"button[9.5,0;1.5,1.5;creative_search;Search]"..
	"list[detached:"..name.."_armor;armor_head;0.25,1.25;1,1;]"..
	"list[detached:"..name.."_armor;armor_torso;0.25,2.5;1,1;]"..
	"list[detached:"..name.."_armor;armor_legs;2.75,1.25;1,1;]"..
	"list[detached:"..name.."_armor;armor_feet;2.75,2.5;1,1;]"..
	"image[1.3,1;1.5,3;player.png]"..
	"list[current_player;main;0,4;9,4;9]"..
	"list[current_player;main;0,7.75;9,1;]"..
	"list[detached:creative_trash;main;9.1,7.75;1,1;]"..
	"button[9.15,6;1,1;clear_inventory;Clear]"..
	"button[9.5,8.75;1.5,1.5;creative_survival;Survival]"

	player:get_inventory():set_width("main", 9)
	player:get_inventory():set_size("main", 36)
	player:set_inventory_formspec(CREATIVE_FORMSPEC)
end

function inventory.survival_inv(player)
local name = player:get_player_name()
	SURVIVAL_FORMSPEC = "invsize[9,9.5;]"..
		--"background[-0.4,-0.45;9.8,9.825;inventory_survival_inventory_bg.png]"..
		"list[detached:"..name.."_armor;armor_head;0,0;1,1;]"..
		"list[detached:"..name.."_armor;armor_torso;0,1;1,1;]"..
		"list[detached:"..name.."_armor;armor_legs;0,2;1,1;]"..
		"list[detached:"..name.."_armor;armor_feet;0,3;1,1;]"..
		"image[1.6,0.25;2,4;player.png]"..
		"list[current_player;main;0,4.5;9,4;9]"..
		"list[current_player;main;0,8.25;9,1;]"..
		"list[current_player;craft;4,1;2,2;]"..
		"list[current_player;craftpreview;7,1.5;1,1;]"..
		"listring[current_player;main]"..
		"listring[current_player;craft]"..
		"listring[current_player;main]"..
		"listring[detached:"..name.."_armor;armor_head]"..
		"listring[current_player;main]"..
		"listring[detached:"..name.."_armor;armor_torso]"..
		"listring[current_player;main]"..
		"listring[detached:"..name.."_armor;armor_legs]"..
		"listring[current_player;main]"..
		"listring[detached:"..name.."_armor;armor_feet]"

	player:get_inventory():set_width("craft", 2)
	player:get_inventory():set_size("craft", 4)
	player:get_inventory():set_width("main", 9)
	player:get_inventory():set_size("main", 36)
	player:set_inventory_formspec(SURVIVAL_FORMSPEC)
end

CRAFTING_FORMSPEC = "size[9,8.5]"..
"background[-0.4,-0.5;9.78,9.5;inventory_crafting_inventory_bg.png]"..
"list[current_player;main;0,4.32;9,4;9]"..
"list[current_player;main;0,7.6;9,1;]"..
"list[current_player;craft;1.218,0.46;3,3;]"..
"list[current_player;craftpreview;6.44,1.5;1.5,1.5;]"..
"listring[current_player;main]"..
"listring[current_player;craft]"

--
-- Hotbar
--

function inventory.hotbar(player)
	local name = player:get_player_name()
	if player.hud_set_hotbar_itemcount then
		minetest.after(0, player.hud_set_hotbar_itemcount, player, 9)
	end
	player:hud_set_hotbar_image("inventory_hotbar.png")
	player:hud_set_hotbar_selected_image("inventory_hotbar_selected.png")
end
