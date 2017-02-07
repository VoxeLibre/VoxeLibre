crafting = {}
crafting.creative_inventory_size = 0

-- Prepare player info table
local players = {}

local function set_inv(filter, player)
	local playername = player:get_player_name()
	local inv = minetest.get_inventory({type="detached", name="creative_"..playername})
	inv:set_size("main", 0)
	local creative_list = {}
	for name,def in pairs(minetest.registered_items) do
		if (not def.groups.not_in_creative_inventory or def.groups.not_in_creative_inventory == 0) and def.description and def.description ~= "" then
			if filter ~= "" then
				local is_redstone = function(def)
					return def.mesecons or def.groups.mesecon or def.groups.mesecon_conductor_craftable or def.groups.mesecon_effecor_off
				end
				local is_tool = function(def)
					return def.groups.tool or (def.tool_capabilities ~= nil and def.tool_capabilities.damage_groups == nil)
				end
				local is_weapon = function(def)
					return def.groups.weapon or def.groups.weapon_ranged or def.groups.ammo or def.groups.armor_head or def.groups.armor_torso or def.groups.armor_legs or def.groups.armor_feet
				end
				if filter == "\0blocks" then
					if def.groups.building_block then
						table.insert(creative_list, name)
					end
				elseif filter == "\0deco" then
					if def.groups.deco_block then
						table.insert(creative_list, name)
					end
				elseif filter == "\0redstone" then
					if is_redstone(def) then
						table.insert(creative_list, name)
					end
				elseif filter == "\0rail" then
					if def.groups.transport then
						table.insert(creative_list, name)
					end
				elseif filter == "\0food" then
					if def.groups.food or def.groups.eatable then
						table.insert(creative_list, name)
					end
				elseif filter == "\0tools" then
					if is_tool(def) then
						table.insert(creative_list, name)
					end
				elseif filter == "\0combat" then
					if is_weapon(def) then
						table.insert(creative_list, name)
					end
				elseif filter == "\0brew" then
					if def.groups.brewitem then
						table.insert(creative_list, name)
					end
				elseif filter == "\0matr" then
					if def.groups.craftitem then
						table.insert(creative_list, name)
					end
				elseif filter == "\0misc" then
					if not def.groups.building_block and not def.groups.deco_block and not is_redstone(def) and not def.groups.transport and not def.groups.food and not def.groups.eatable and not is_tool(def) and not is_weapon(def) and not def.groups.craftitem and not def.groups.brewitem then

						table.insert(creative_list, name)
					end
				elseif filter == "\0all" then
					table.insert(creative_list, name)
				else --for all other
					if string.find(string.lower(def.name), filter) or string.find(string.lower(def.description), filter) then
						table.insert(creative_list, name)
					end
				end
			end
		end
	end
	table.sort(creative_list)
	inv:set_size("main", #creative_list)
	for _,itemstring in ipairs(creative_list) do
		inv:add_item("main", ItemStack(itemstring))
	end
	crafting.creative_inventory_size = #creative_list
end

local function init(player)
	local playername = player:get_player_name()
	local inv = minetest.create_detached_inventory("creative_"..playername, {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			if minetest.setting_getbool("creative_mode") then
				return count
			else
				return 0
			end
		end,
		allow_put = function(inv, listname, index, stack, player)
			return 0
		end,
		allow_take = function(inv, listname, index, stack, player)
			if minetest.setting_getbool("creative_mode") then
				return -1
			else
				return 0
			end
		end,
		on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
		end,
		on_put = function(inv, listname, index, stack, player)
		end,
		on_take = function(inv, listname, index, stack, player)
			print(player:get_player_name().." takes item from creative inventory; listname="..dump(listname)..", index="..dump(index)..", stack="..dump(stack))
			if stack then
				print("stack:get_name()="..dump(stack:get_name())..", stack:get_count()="..dump(stack:get_count()))
			end
		end,
	}, playername)
	set_inv("\0all", player)
end

-- Create the trash field
local trash = minetest.create_detached_inventory("trash", {
	allow_put = function(inv, listname, index, stack, player)
		if minetest.setting_getbool("creative_mode") then
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

noffset["blocks"] = {-0.29,-0.25}
noffset["deco"] = {0.98,-0.25}
noffset["redstone"] = {2.23,-0.25}
noffset["rail"] = {3.495,-0.25}
noffset["misc"] = {4.75,-0.25}
noffset["nix"] = {8.99,-0.25}
noffset["food"] = {-0.29,8.12}
noffset["tools"] = {0.98,8.12}
noffset["combat"] = {2.23,8.12}
noffset["brew"] = {3.495,8.12}
noffset["matr"] = {4.74,8.12}
noffset["inv"] = {8.99,8.12}

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


crafting.set_creative_formspec = function(player, start_i, pagenum, show, page, filter)
	reset_menu_item_bg()
	pagenum = math.floor(pagenum) or 1
	local pagemax = math.floor((crafting.creative_inventory_size-1) / (9*5) + 1)
	local slider_height
	if pagemax == 1 then
		slider_height = 4.525
	else
		slider_height = 4/pagemax
	end
	local slider_pos = slider_height*(pagenum-1)+2.20
	local name = "nix"
	local formspec = ""
	local main_list
	local playername = player:get_player_name()
	local listrings = "listring[detached:creative_"..playername..";main]"..
		"listring[current_player;main]"..
		"listring[detached:trash;main]"

	if page ~= nil then name = page end
	bg[name] = "crafting_creative_bg.png"
		local inv_bg = "crafting_inventory_creative.png"
		if name == "inv" then
			-- Survival inventory slots
			main_list = "image[-0.2,1.7;11.35,2.33;crafting_creative_bg.png]"..
				"list[current_player;main;0,3.75;9,3;9]"
		else
			inv_bg = inv_bg .. "^crafting_inventory_creative_scroll.png"
			-- Creative inventory slots
			main_list = "list[detached:creative_"..playername..";main;0,1.75;9,5;"..tostring(start_i).."]" ..
			-- ... and scroll bar
				"image_button[9.03,1.74;0.85,0.6;crafting_creative_up.png;creative_prev;]"..
				"image[9.04," .. tostring(slider_pos) .. ";0.75,"..tostring(slider_height) .. ";crafting_slider.png]"..
				"image_button[9.03,6.15;0.85,0.6;crafting_creative_down.png;creative_next;]"
		end
		local function tab(current, check)
			local img
			if current == check then
				img = "crafting_creative_active.png"
			else
				img = "crafting_creative_inactive.png"
			end
			return "image[" .. offset[check] .. ";1.5,1.44;" .. img .. hoch[check].. "]" ..
				"image[" .. boffset[check] .. ";1,1;crafting_creative_marker.png]"
		end
		formspec = "size[10,9.3]"..
			mcl_core.inventory_header..
			"background[-0.19,-0.25;10.5,9.87;"..inv_bg.."]"..
			"label[-5,-5;"..name.."]"..
			"item_image_button[-0.1,0;1,1;mcl_core:brick_block;blocks;]"..	--build blocks
			tab(name, "blocks") ..
			"tooltip[blocks;Building Blocks]"..
			"item_image_button[1.15,0;1,1;mcl_flowers:peony;deco;]"..	--decoration blocks
			tab(name, "deco") ..
			"tooltip[deco;Decoration Blocks]"..
			"item_image_button[2.415,0;1,1;mesecons:redstone;redstone;]"..	--redstone
			tab(name, "redstone") ..
			"tooltip[redstone;Redstone]"..
			"item_image_button[3.693,0;1,1;mcl_minecarts:golden_rail;rail;]"..	--transportation
			tab(name, "rail") ..
			"tooltip[rail;Transportation]"..
			"item_image_button[4.93,0;1,1;bucket:bucket_lava;misc;]"..	--miscellaneous
			tab(name, "misc") ..
			"tooltip[misc;Miscellaneous]"..
			"item_image_button[9.19,0;1,1;mcl_compass:compass;nix;]"..	--search
			tab(name, "nix") ..
			"tooltip[nix;Search Items]"..
			"image[0,1;5,0.75;fnt_"..name..".png]"..
			"list[current_player;main;0,7;9,1;]"..
			main_list..
			"item_image_button[-0.1,8.37;1,1;mcl_core:apple;food;]"..	--foodstuff
			tab(name, "food") ..
			"tooltip[food;Foodstuffs]"..
			"item_image_button[1.15,8.37;1,1;mcl_core:axe_steel;tools;]"..	--tools
			tab(name, "tools") ..
			"tooltip[tools;Tools]"..
			"item_image_button[2.415,8.37;1,1;mcl_core:sword_gold;combat;]"..	--combat
			tab(name, "combat") ..
			"tooltip[combat;Combat]"..
			"item_image_button[3.693,8.37;1,1;mcl_potions:glass_bottle;brew;]"..	--brewing
			tab(name, "brew") ..
			"tooltip[brew;Brewing]"..
			"item_image_button[4.938,8.37;1,1;mcl_core:stick;matr;]"..	--materials
			tab(name, "matr") ..
			"tooltip[matr;Materials]"..
			"item_image_button[9.19,8.37;1,1;mcl_chests:chest;inv;]"..			--inventory
			tab(name, "inv") ..
			"tooltip[inv;Survival Inventory]"..
			"list[detached:trash;main;9,7;1,1;]"..
			"image[9,7;1,1;crafting_creative_trash.png]"..
			listrings

			if name == "nix" then
				if filter == nil then
					filter = ""
				end
				formspec = formspec .. "field[5.3,1.3;4,0.75;suche;;"..minetest.formspec_escape(filter).."]"
				formspec = formspec .. "field_close_on_enter[suche;false]"
			end
			if pagenum ~= nil then formspec = formspec .. "p"..tostring(pagenum) end
			
	player:set_inventory_formspec(formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local page = nil
	if not minetest.setting_getbool("creative_mode") then
		return
	end

	local name = player:get_player_name()

	if fields.blocks then
		set_inv("\0blocks",player)
		page = "blocks"		
	elseif fields.deco then
		set_inv("\0deco",player)
		page = "deco"
	elseif fields.redstone then
		set_inv("\0redstone",player)
		page = "redstone"
	elseif fields.rail then
		set_inv("\0rail",player)
		page = "rail"
	elseif fields.misc then
		set_inv("\0misc",player)
		page = "misc"
	elseif fields.nix then
		set_inv("\0all",player)
		page = "nix"
	elseif fields.food then
		set_inv("\0food",player)
		page = "food"
	elseif fields.tools then
		set_inv("\0tools",player)
		page = "tools"
	elseif fields.combat then
		set_inv("\0combat",player)
		page = "combat"
	elseif fields.brew then
		set_inv("\0brew",player)
		page = "brew"
	elseif fields.matr then
		set_inv("\0matr",player)
		page = "matr"
	elseif fields.inv then
		page = "inv"
	elseif fields.suche == "" and not fields.creative_next and not fields.creative_prev then
		set_inv("\0all", player)
		page = "nix"
	elseif fields.suche ~= nil and not fields.creative_next and not fields.creative_prev then
		set_inv(string.lower(fields.suche),player)
		page = "nix"
	end

	if page then
		players[name].page = page
	end
	if players[name].page then
		page = players[name].page
	end

	-- Figure out current page from formspec
	local formspec = player:get_inventory_formspec()

	local size = string.len(formspec)
	local start_i = players[name].start_i
	if fields.creative_prev then
		start_i = start_i - 9*5
	end
	if fields.creative_next then
		start_i = start_i + 9*5
	end
	if start_i < 0 then
		start_i = start_i + 9*5
	end
	if start_i >= crafting.creative_inventory_size then
		start_i = start_i - 9*5
	end		
	if start_i < 0 or start_i >= crafting.creative_inventory_size then
		start_i = 0
	end
	players[name].start_i = start_i

	local filter
	if fields.suche ~= nil and fields.suche ~= "" then
		filter = fields.suche
		players[name].filter = filter
	end

	crafting.set_creative_formspec(player, start_i, start_i / (9*5) + 1, false, page, filter)
end)


if minetest.setting_getbool("creative_mode") then
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
	local name = player:get_player_name()
	if not players[name] then
		players[name] = {}
		players[name].page = "nix"
		players[name].filter = ""
		players[name].start_i = 0
	end
	init(player)
end)
