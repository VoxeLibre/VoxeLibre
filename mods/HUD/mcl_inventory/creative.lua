-- Prepare player info table
local players = {}

-- Containing all the items for each Creative Mode tab
local inventory_lists = {}

-- Create tables
local builtin_filter_ids = {"blocks","deco","redstone","rail","food","tools","combat","brew","matr","misc","all"}
for _, f in pairs(builtin_filter_ids) do
	inventory_lists[f] = {}
end

--[[ Populate all the item tables. We only do this once. Note this mod must be
loaded after mcl_autogroup for this to work, because it required certain
groups to be set. ]]
do
	for name,def in pairs(minetest.registered_items) do
		if (not def.groups.not_in_creative_inventory or def.groups.not_in_creative_inventory == 0) and def.description and def.description ~= "" then
			local is_redstone = function(def)
				return def.mesecons or def.groups.mesecon or def.groups.mesecon_conductor_craftable or def.groups.mesecon_effecor_off
			end
			local is_tool = function(def)
				return def.groups.tool or (def.tool_capabilities ~= nil and def.tool_capabilities.damage_groups == nil)
			end
			local is_weapon_or_armor = function(def)
				return def.groups.weapon or def.groups.weapon_ranged or def.groups.ammo or def.groups.combat_item or ((def.groups.armor_head or def.groups.armor_torso or def.groups.armor_legs or def.groups.armor_feet or def.groups.horse_armor) and def.groups.non_combat_armor ~= 1)
			end
			if def.groups.building_block then
				table.insert(inventory_lists["blocks"], name)
			end
			if def.groups.deco_block then
				table.insert(inventory_lists["deco"], name)
			end
			if is_redstone(def) then
				table.insert(inventory_lists["redstone"], name)
			end
			if def.groups.transport then
				table.insert(inventory_lists["rail"], name)
			end
			if (def.groups.food and not def.groups.brewitem) or def.groups.eatable then
				table.insert(inventory_lists["food"], name)
			end
			if is_tool(def) then
				table.insert(inventory_lists["tools"], name)
			end
			if is_weapon_or_armor(def) then
				table.insert(inventory_lists["combat"], name)
			end
			if def.groups.brewitem then
				table.insert(inventory_lists["brew"], name)
			end
			if def.groups.craftitem then
				table.insert(inventory_lists["matr"], name)
			end
			if not def.groups.building_block and not def.groups.deco_block and not is_redstone(def) and not def.groups.transport and not def.groups.food and not def.groups.eatable and not is_tool(def) and not is_weapon_or_armor(def) and not def.groups.craftitem and not def.groups.brewitem then
				table.insert(inventory_lists["misc"], name)
			end

			table.insert(inventory_lists["all"], name)
		end
	end

	for _, to_sort in pairs(inventory_lists) do
		table.sort(to_sort)
	end
end

local function set_inv_search(filter, player)
	local playername = player:get_player_name()
	local inv = minetest.get_inventory({type="detached", name="creative_"..playername})
	local creative_list = {}
	for name,def in pairs(minetest.registered_items) do
		if (not def.groups.not_in_creative_inventory or def.groups.not_in_creative_inventory == 0) and def.description and def.description ~= "" then
			if string.find(string.lower(def.name), filter) or string.find(string.lower(def.description), filter) then
				table.insert(creative_list, name)
			end
		end
	end
	table.sort(creative_list)

	inv:set_size("main", #creative_list)
	inv:set_list("main", creative_list)
end

local function set_inv_page(page, player)
	local playername = player:get_player_name()
	local inv = minetest.get_inventory({type="detached", name="creative_"..playername})
	inv:set_size("main", 0)
	local creative_list = {}
	if inventory_lists[page] then -- Standard filter
		creative_list = inventory_lists[page]
	end
	inv:set_size("main", #creative_list)
	inv:set_list("main", creative_list)
end

local function init(player)
	local playername = player:get_player_name()
	local inv = minetest.create_detached_inventory("creative_"..playername, {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			if minetest.settings:get_bool("creative_mode") then
				return count
			else
				return 0
			end
		end,
		allow_put = function(inv, listname, index, stack, player)
			return 0
		end,
		allow_take = function(inv, listname, index, stack, player)
			if minetest.settings:get_bool("creative_mode") then
				return -1
			else
				return 0
			end
		end,
	}, playername)
	set_inv_page("all", player)
end

-- Create the trash field
local trash = minetest.create_detached_inventory("trash", {
	allow_put = function(inv, listname, index, stack, player)
		if minetest.settings:get_bool("creative_mode") then
			return stack:get_count()
		else
			return 0
		end
	end,
	on_put = function(inv, listname, index, stack, player)
		inv:set_stack(listname, index, "")
	end,
})
trash:set_size("main", 1)

local noffset = {} -- numeric tab offset
local offset = {} -- string offset:
local boffset = {} -- 
local hoch = {}
local bg = {}

local noffset_x_start = -0.24
local noffset_x = noffset_x_start
local noffset_y = -0.25
local next_noffset = function(id, right)
	if right then
		noffset[id] = { 8.94, noffset_y }
	else
		noffset[id] = { noffset_x, noffset_y }
		noffset_x = noffset_x + 1.25
	end
end

-- Upper row
next_noffset("blocks")
next_noffset("deco")
next_noffset("redstone")
next_noffset("rail")
next_noffset("misc")
next_noffset("nix", true)

noffset_x = noffset_x_start
noffset_y = 8.12

-- Lower row
next_noffset("food")
next_noffset("tools")
next_noffset("combat")
next_noffset("brew")
next_noffset("matr")
next_noffset("inv", true)

for k,v in pairs(noffset) do
	offset[k] = tostring(v[1]) .. "," .. tostring(v[2])
	boffset[k] = tostring(v[1]+0.19) .. "," .. tostring(v[2]+0.25)
end

hoch["blocks"] = ""
hoch["deco"] = ""
hoch["redstone"] = ""
hoch["rail"] = ""
hoch["misc"] = ""
hoch["nix"] = ""
hoch["default"] = ""
hoch["food"] = "^[transformfy"
hoch["tools"] = "^[transformfy"
hoch["combat"] = "^[transformfy"
hoch["brew"] = "^[transformfy"
hoch["matr"] = "^[transformfy"
hoch["inv"] = "^[transformfy"

local dark_bg = "crafting_creative_bg_dark.png"

local function reset_menu_item_bg()
	bg["blocks"] = dark_bg 
	bg["deco"] = dark_bg 
	bg["redstone"] = dark_bg 
	bg["rail"] = dark_bg 
	bg["misc"] = dark_bg 
	bg["nix"] = dark_bg 
	bg["food"] = dark_bg 
	bg["tools"] = dark_bg 
	bg["combat"] = dark_bg 
	bg["brew"] = dark_bg 
	bg["matr"] = dark_bg 
	bg["inv"] = dark_bg 
	bg["default"] = dark_bg
end


mcl_inventory.set_creative_formspec = function(player, start_i, pagenum, inv_size, show, page, filter)
	reset_menu_item_bg()
	pagenum = math.floor(pagenum) or 1

	local playername = player:get_player_name()

	if not inv_size then
		if page == "nix" then
			local inv = minetest.get_inventory({type="detached", name="creative_"..playername})
			inv_size = inv:get_size("main")
		elseif page ~= nil and page ~= "inv" then
			inv_size = #(inventory_lists[page])
		else
			inv_size = 0
		end
	end
	local pagemax = math.max(1, math.floor((inv_size-1) / (9*5) + 1))
	local slider_height
	local arrow_height = 0.85
	slider_height = (6.2-arrow_height*2) / pagemax
	local slider_pos = (slider_height*(pagenum-1)*0.8713125)+2.23
	local name = "nix"
	local formspec = ""
	local main_list
	local listrings = "listring[detached:creative_"..playername..";main]"..
		"listring[current_player;main]"..
		"listring[detached:trash;main]"

	if page ~= nil then
		name = page
		if players[playername] then
			players[playername].page = page
		end
	end
	bg[name] = "crafting_creative_bg.png"

		local inv_bg = "crafting_inventory_creative.png"
		if name == "inv" then
			inv_bg = "crafting_inventory_creative_survival.png"

			-- Show armor and player image
			local show_armor = minetest.get_modpath("3d_armor")
			local img = "player.png"
			local player_preview = "image[3.9,1.4;1.2333,2.4666;"..img.."]"
			if show_armor and armor.textures[playername] and armor.textures[playername].preview then
				img = armor.textures[playername].preview
				local s1 = img:find("character_preview")
				if s1 ~= nil then
					s1 = img:sub(s1+21)
					img = "player.png"..s1
				end
				player_preview = "image[3.9,1.4;1.2333,2.4666;"..img.."]"
			end

			-- Background images for armor slots (hide if occupied)
			local armor_slot_imgs = ""
			local inv = player:get_inventory()
			if inv:get_stack("armor", 2):is_empty() then
				armor_slot_imgs = armor_slot_imgs .. "image[2.5,1.3;1,1;mcl_inventory_empty_armor_slot_helmet.png]"
			end
			if inv:get_stack("armor", 3):is_empty() then
				armor_slot_imgs = armor_slot_imgs .. "image[2.5,2.75;1,1;mcl_inventory_empty_armor_slot_chestplate.png]"
			end
			if inv:get_stack("armor", 4):is_empty() then
				armor_slot_imgs = armor_slot_imgs .. "image[5.5,1.3;1,1;mcl_inventory_empty_armor_slot_leggings.png]"
			end
			if inv:get_stack("armor", 5):is_empty() then
				armor_slot_imgs = armor_slot_imgs .. "image[5.5,2.75;1,1;mcl_inventory_empty_armor_slot_boots.png]"
			end

			-- Survival inventory slots
			main_list = "list[current_player;main;0,3.75;9,3;9]"..
				-- armor
				"list[detached:"..playername.."_armor;armor;2.5,1.3;1,1;1]"..
				"list[detached:"..playername.."_armor;armor;2.5,2.75;1,1;2]"..
				"list[detached:"..playername.."_armor;armor;5.5,1.3;1,1;3]"..
				"list[detached:"..playername.."_armor;armor;5.5,2.75;1,1;4]"..
				armor_slot_imgs..
				-- player preview
				player_preview..
				-- crafting guide button
				"image_button[9,1;1,1;craftguide_book.png;__mcl_craftguide;]"..
				"tooltip[__mcl_craftguide;Recipe book]"..
				-- help button
				"image_button[9,2;1,1;doc_button_icon_lores.png;__mcl_doc;]"..
				"tooltip[__mcl_doc;Help]"..
				-- achievements button
				"image_button[9,3;1,1;mcl_achievements_button.png;__mcl_achievements;]"..
				"tooltip[__mcl_achievements;Achievements]"

			-- For shortcuts
			listrings = listrings ..
				"listring[detached:"..playername.."_armor;armor]"..
				"listring[current_player;main]"
		else
			inv_bg = inv_bg .. "^crafting_inventory_creative_scroll.png"
			-- Creative inventory slots
			main_list = "list[detached:creative_"..playername..";main;0,1.75;9,5;"..tostring(start_i).."]" ..
			-- ... and scroll bar
				"image_button[9.02,1.76;"..tostring(arrow_height)..",0.6;crafting_creative_up.png;creative_prev;]"..
				"image[9.033," .. tostring(slider_pos) .. ";0.78,"..tostring(slider_height) .. ";crafting_slider.png]"..
				"image_button[9.02,6.15;"..tostring(arrow_height)..",0.6;crafting_creative_down.png;creative_next;]"
		end

		local tab_icon = {
			blocks = "mcl_core:brick_block",
			deco = "mcl_flowers:peony",
			redstone = "mesecons:redstone",
			rail = "mcl_minecarts:golden_rail",
			misc = "mcl_buckets:bucket_lava",
			nix = "mcl_compass:compass",
			food = "mcl_core:apple",
			tools = "mcl_core:axe_iron",
			combat = "mcl_core:sword_gold",
			brew = "mcl_potions:potion_water",
			matr = "mcl_core:stick",
			inv = "mcl_chests:chest",
		}
		local function tab(current_tab, this_tab)
			local bg_img
			if current_tab == this_tab then
				bg_img = "crafting_creative_active.png"
			else
				bg_img = "crafting_creative_inactive.png"
			end
			return 
				"item_image_button[" .. boffset[this_tab] ..";1,1;"..tab_icon[this_tab]..";"..this_tab..";]"..
				"image[" .. offset[this_tab] .. ";1.5,1.44;" .. bg_img .. hoch[this_tab].. "]" ..
				"image[" .. boffset[this_tab] .. ";1,1;crafting_creative_marker.png]"
		end
		local fnt = ""
		if name ~= "inv" then
			fnt = "image[0,1;5,0.75;mcl_inventory_fnt_"..name..".png]"
		end

		formspec = "size[10,9.3]"..
			mcl_vars.inventory_header..
			"background[-0.19,-0.25;10.5,9.87;"..inv_bg.."]"..
			"label[-5,-5;"..name.."]"..
			tab(name, "blocks") ..
			"tooltip[blocks;Building Blocks]"..
			tab(name, "deco") ..
			"tooltip[deco;Decoration Blocks]"..
			tab(name, "redstone") ..
			"tooltip[redstone;Redstone]"..
			tab(name, "rail") ..
			"tooltip[rail;Transportation]"..
			tab(name, "misc") ..
			"tooltip[misc;Miscellaneous]"..
			tab(name, "nix") ..
			"tooltip[nix;Search Items]"..
			fnt..
			"list[current_player;main;0,7;9,1;]"..
			main_list..
			tab(name, "food") ..
			"tooltip[food;Foodstuffs]"..
			tab(name, "tools") ..
			"tooltip[tools;Tools]"..
			tab(name, "combat") ..
			"tooltip[combat;Combat]"..
			tab(name, "brew") ..
			"tooltip[brew;Brewing]"..
			tab(name, "matr") ..
			"tooltip[matr;Materials]"..
			tab(name, "inv") ..
			"tooltip[inv;Survival Inventory]"..
			"list[detached:trash;main;9,7;1,1;]"..
			"image[9,7;1,1;crafting_creative_trash.png]"..
			listrings

			if name == "nix" then
				if filter == nil then
					filter = ""
				end
				formspec = formspec .. "field[5.3,1.34;4,0.75;suche;;"..minetest.formspec_escape(filter).."]"
				formspec = formspec .. "field_close_on_enter[suche;false]"
			end
			if pagenum ~= nil then formspec = formspec .. "p"..tostring(pagenum) end


	player:set_inventory_formspec(formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local page = nil
	if not minetest.settings:get_bool("creative_mode") then
		return
	end
	if formname ~= "" or fields.quit == "true" then
		-- No-op if formspec closed or not player inventory (formname == "")
		return
	end

	local name = player:get_player_name()

	if fields.blocks then
		if players[name].page == "blocks" then return end
		set_inv_page("blocks",player)
		page = "blocks"
	elseif fields.deco then
		if players[name].page == "deco" then return end
		set_inv_page("deco",player)
		page = "deco"
	elseif fields.redstone then
		if players[name].page == "redstone" then return end
		set_inv_page("redstone",player)
		page = "redstone"
	elseif fields.rail then
		if players[name].page == "rail" then return end
		set_inv_page("rail",player)
		page = "rail"
	elseif fields.misc then
		if players[name].page == "misc" then return end
		set_inv_page("misc",player)
		page = "misc"
	elseif fields.nix then
		set_inv_page("all",player)
		page = "nix"
	elseif fields.food then
		if players[name].page == "food" then return end
		set_inv_page("food",player)
		page = "food"
	elseif fields.tools then
		if players[name].page == "tools" then return end
		set_inv_page("tools",player)
		page = "tools"
	elseif fields.combat then
		if players[name].page == "combat" then return end
		set_inv_page("combat",player)
		page = "combat"
	elseif fields.brew then
		if players[name].page == "brew" then return end
		set_inv_page("brew",player)
		page = "brew"
	elseif fields.matr then
		if players[name].page == "matr" then return end
		set_inv_page("matr",player)
		page = "matr"
	elseif fields.inv then
		if players[name].page == "inv" then return end
		page = "inv"
	elseif fields.suche == "" and not fields.creative_next and not fields.creative_prev then
		set_inv_page("all", player)
		page = "nix"
	elseif fields.suche ~= nil and not fields.creative_next and not fields.creative_prev then
		set_inv_search(string.lower(fields.suche),player)
		page = "nix"
	end

	if page then
		players[name].page = page
	end
	if players[name].page then
		page = players[name].page
	end

	-- Figure out current scroll bar from formspec
	local formspec = player:get_inventory_formspec()

	local start_i = players[name].start_i

	if fields.creative_prev then
		start_i = start_i - 9*5
	elseif fields.creative_next then
		start_i = start_i + 9*5
	else
		-- Reset scroll bar if not scrolled
		start_i = 0
	end
	if start_i < 0 then
		start_i = start_i + 9*5
	end

	local inv_size
	if page == "nix" then
		local inv = minetest.get_inventory({type="detached", name="creative_"..name})
		inv_size = inv:get_size("main")
	elseif page ~= nil and page ~= "inv" then
		inv_size = #(inventory_lists[page])
	else
		inv_size = 0
	end

	if start_i >= inv_size then
		start_i = start_i - 9*5
	end
	if start_i < 0 or start_i >= inv_size then
		start_i = 0
	end
	players[name].start_i = start_i

	local filter = ""
	if not fields.nix and fields.suche ~= nil and fields.suche ~= "" then
		filter = fields.suche
		players[name].filter = filter
	end

	mcl_inventory.set_creative_formspec(player, start_i, start_i / (9*5) + 1, inv_size, false, page, filter)
end)


if minetest.settings:get_bool("creative_mode") then
	minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack)
		-- Place infinite nodes, except for shulker boxes
		local group = minetest.get_item_group(itemstack:get_name(), "shulker_box")
		return group == 0 or group == nil
	end)

	function minetest.handle_node_drops(pos, drops, digger)
		if not digger or not digger:is_player() then
			return
		end
		local inv = digger:get_inventory()
		if inv then
			for _,item in ipairs(drops) do
				item = ItemStack(item):get_name()
				if not inv:contains_item("main", item) then
					inv:add_item("main", item)
				end
			end
		end
	end

end

minetest.register_on_joinplayer(function(player)
	-- Initialize variables and inventory
	local name = player:get_player_name()
	if not players[name] then
		players[name] = {}
		players[name].page = "nix"
		players[name].filter = ""
		players[name].start_i = 0
	end
	init(player)
	mcl_inventory.set_creative_formspec(player, 0, 1, nil, false, "nix", "")
end)
