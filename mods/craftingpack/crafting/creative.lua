crafting = {}
crafting.creative_inventory_size = 0

function init()
 local inv = minetest.create_detached_inventory("creative", {
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
	})
 set_inv("all")
end

function set_inv(filter, player)
	local inv = minetest.get_inventory({type="detached", name="creative"})
	inv:set_size("main", 0)
	local creative_list = {}
	for name,def in pairs(minetest.registered_items) do
		if (not def.groups.not_in_creative_inventory or def.groups.not_in_creative_inventory == 0) and def.description and def.description ~= "" then
			if filter ~= "" then
				if filter == "#blocks" then
					if def.walkable == true then
						table.insert(creative_list, name)
					end
				elseif filter == "#deco" then
					if def.walkable == false or def.drawtype == "plantlike" or def.drawtype == "allfaces_optional" then--def.groups. == true then
						table.insert(creative_list, name)
					end
				elseif filter == "#mese" then
					if string.find(string.lower(def.name), "mese") or string.find(string.lower(def.description), "mese") then
						table.insert(creative_list, name)
					end
				elseif filter == "#rail" then
					if string.find(string.lower(def.name), "rail") or string.find(string.lower(def.description), "rail") or string.find(string.lower(def.name), "cart") or string.find(string.lower(def.description), "cart") or string.find(string.lower(def.description), "boat") then
						table.insert(creative_list, name)
					end
				elseif filter == "#misc" then
					if def.drawtype == nil and def.tool_capabilities == nil and not string.find(string.lower(def.description), "ingot") and not string.find(string.lower(def.description), "lump") and not string.find(string.lower(def.description), "dye") and not string.find(string.lower(def.name), "diamond") and not string.find(string.lower(def.name), "mese") and not string.find(string.lower(def.name), "obsidian") and not string.find(string.lower(def.description), "clay") then
						table.insert(creative_list, name)
					end
				elseif filter == "#food" then
					if def.groups.food ~= nil or string.find(string.lower(def.description), "apple") or string.find(string.lower(def.description), "bread") then
						table.insert(creative_list, name)
					end
				elseif filter == "#tools" then
					if def.tool_capabilities ~= nil and not string.find(string.lower(def.description), "sword") then
						table.insert(creative_list, name)
					end
				elseif filter == "#combat" then
					if def.tool_capabilities ~= nil and (string.find(string.lower(def.description), "sword") or string.find(string.lower(def.name), "armor") or string.find(string.lower(def.description), "bow") or string.find(string.lower(def.description), "arrow")) or string.find(string.lower(def.name), "armor") then
						table.insert(creative_list, name)
					end
				elseif filter == "#matr" then
					if def.drawtype == nil and def.tool_capabilities == nil and (string.find(string.lower(def.description), "ingot") or string.find(string.lower(def.description), "lump") or string.find(string.lower(def.description), "dye") or string.find(string.lower(def.name), "diamond") or string.find(string.lower(def.name), "mese") or string.find(string.lower(def.name), "obsidian") or string.find(string.lower(def.description), "clay") or string.find(string.lower(def.description), "stick") or string.find(string.lower(def.description), "flint") or string.find(string.lower(def.description), "seed")) then
						table.insert(creative_list, name)
					end
				elseif filter == "all" then
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
	--print("creative inventory size: "..dump(crafting.creative_inventory_size))
end

-- Create the trash field
local trash = minetest.create_detached_inventory("creative_trash", {
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


-- Create detached creative inventory after loading all mods
minetest.after(0, init)

local offset = {}
local hoch = {}
local bg = {}
offset["blocks"] = "-0.29,-0.25"
offset["deco"] = "0.98,-0.25"
offset["mese"] = "2.23,-0.25"
offset["rail"] = "3.495,-0.25"
offset["misc"] = "4.75,-0.25"
offset["nix"] = "8.99,-0.25"
offset["food"] = "-0.29,8.12"
offset["tools"] = "0.98,8.12"
offset["combat"] = "2.23,8.12"
offset["brew"] = "3.495,8.12"
offset["matr"] = offset["brew"]--"4.74,8.12"
offset["inv"] = "8.99,8.12"

hoch["blocks"] = ""
hoch["deco"] = ""
hoch["mese"] = ""
hoch["rail"] = ""
hoch["misc"] = ""
hoch["nix"] = ""
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
	bg["mese"] = dark_bg 
	bg["rail"] = dark_bg 
	bg["misc"] = dark_bg 
	bg["nix"] = dark_bg 
	bg["food"] = dark_bg 
	bg["tools"] = dark_bg 
	bg["combat"] = dark_bg 
	bg["brew"] = dark_bg 
	bg["matr"] = dark_bg 
	bg["inv"] = dark_bg 
end


crafting.set_creative_formspec = function(player, start_i, pagenum, show, page)
	reset_menu_item_bg()
	pagenum = math.floor(pagenum) or 1
	local pagemax = math.floor((crafting.creative_inventory_size-1) / (9*5) + 1)
	local slider_height = 4/pagemax
	local slider_pos = slider_height*(pagenum-1)+2.25
	local name = "nix"
	local formspec = ""
	local main_list = "list[detached:creative;main;0,1.75;9,5;"..tostring(start_i).."]"
	if page ~= nil then name = page end
	bg[name] = "crafting_creative_bg.png"
		if name == "inv" then
			main_list = "image[-0.2,1.7;11.35,2.33;crafting_creative_bg.png]"..
				"list[current_player;main;0,3.75;9,3;9]"
		end
		formspec = "size[10,9.3]"..
			"background[-0.19,-0.25;10.5,9.87;crafting_inventory_creative.png]"..
			"bgcolor[#080808BB;true]"..
			"listcolors[#9990;#FFF7;#FFF0;#160816;#D4D2FF]"..
			"label[-5,-5;"..name.."]"..
			"image[" .. offset[name] .. ";1.5,1.44;crafting_creative_active.png"..hoch[name].."]"..
			"image_button[-0.1,0;1,1;"..bg["blocks"].."^crafting_creative_build.png;build;]"..	--build blocks
			"image_button[1.15,0;1,1;"..bg["deco"].."^crafting_creative_deko.png;deco;]"..	--decoration blocks
			"image_button[2.415,0;1,1;"..bg["mese"].."^crafting_creative_mese.png;mese;]"..	--redstone
			"image_button[3.693,0;1,1;"..bg["rail"].."^crafting_creative_rail.png;rail;]"..	--transportation
			"image_button[4.93,0;1,1;"..bg["misc"].."^crafting_creative_misc.png;misc;]"..	--miscellaneous
			"image_button[9.19,0;1,1;"..bg["nix"].."^crafting_creative_all.png;default;]"..	--search
			"image[0,1;5,0.75;fnt_"..name..".png]"..
			"list[current_player;main;0,7;9,1;]"..
			main_list..
			"image_button[9.03,1.74;0.85,0.6;crafting_creative_up.png;creative_prev;]"..
			"image[9.04," .. tostring(slider_pos) .. ";0.75,"..tostring(slider_height) .. ";crafting_slider.png]"..
			"image_button[9.03,6.15;0.85,0.6;crafting_creative_down.png;creative_next;]"..
			"image_button[-0.1,8.28;1,1;"..bg["food"].."^crafting_food.png;food;]"..	--foodstuff
			"image_button[1.15,8.28;1,1;"..bg["tools"].."^crafting_creative_tool.png;tools;]"..	--tools
			"image_button[2.415,8.28;1,1;"..bg["combat"].."^crafting_creative_sword.png;combat;]"..	--combat
			"image_button[3.693,8.28;1,1;"..bg["matr"].."^crafting_creative_matr.png;matr;]"..	--brewing
			--"image_button[4.93,8.28;1,1;"..bg["brew"].."^crafting_creative_matr.png;matr;]"..	--materials^
			"image_button[9.19,8.28;1,1;"..bg["inv"].."^crafting_creative_inv.png;inv;]"..			--inventory
			"list[detached:creative_trash;main;9,7;1,1;]"..
			"image[9,7;1,1;crafting_creative_trash.png]"

			if name == "nix" then formspec = formspec .. "field[5.3,1.3;4,0.75;suche;;]" end
			if pagenum ~= nil then formspec = formspec .. "p"..tostring(pagenum) end
			
	player:set_inventory_formspec(formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local page = nil
	if not minetest.setting_getbool("creative_mode") then
		return
	end
	
	if fields.bgcolor then
		minetest.chat_send_all("jupp")
	end
	if fields.suche ~= nil and fields.suche ~= "" then
		set_inv(string.lower(fields.suche))
		minetest.after(0.5, function()
			minetest.show_formspec(player:get_player_name(), "detached:creative",  player:get_inventory_formspec())
		end)
	end

	if fields.build then		
		set_inv("#blocks",player)
		page = "blocks"		
	end
	if fields.deco then		
		set_inv("#deco",player)
		page = "deco"
	end
	if fields.mese then		
		set_inv("#mese",player)
		page = "mese"
	end
	if fields.rail then		
		set_inv("#rail",player)
		page = "rail"
	end
	if fields.misc then		
		set_inv("#misc",player)
		page = "misc"
	end
	if fields.default then		
		set_inv("all")
		page = nil
	end
	if fields.food then		
		set_inv("#food")
		page = "food"
	end
	if fields.tools then		
		set_inv("#tools")
		page = "tools"
	end
	if fields.combat then
		set_inv("#combat")
		page = "combat"
	end
	if fields.matr then
		set_inv("#matr")
		page = "matr"
	end
	if fields.inv then
		page = "inv"
	end
	-- Figure out current page from formspec
	local current_page = 0
	local formspec = player:get_inventory_formspec()

	local size = string.len(formspec)
	local marker = string.sub(formspec,size-2)
	marker = string.sub(marker,1)
	if marker ~= nil and marker == "p" then
		local page = string.sub(formspec,size-1)
		--minetest.chat_send_all(page)
		start_i = page
	end
	start_i = tonumber(start_i) or 0
	if fields.creative_prev then
		start_i = start_i - 9*5
		page = tmp_page
	end
	if fields.creative_next then
		start_i = start_i + 9*5
		page = tmp_page
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
	crafting.set_creative_formspec(player, start_i, start_i / (9*5) + 1, false, page)
end)


if minetest.setting_getbool("creative_mode") then
	minetest.register_item(":", {
		type = "none",
		wield_image = "wieldhand.png",
		wield_scale = {x=1,y=1,z=2.5},
		tool_capabilities = {
			full_punch_interval = 0.5,
			max_drop_level = 3,
			groupcaps = {
				crumbly = {times={[1]=0.5, [2]=0.5, [3]=0.5}, uses=0, maxlevel=3},
				cracky = {times={[1]=0.5, [2]=0.5, [3]=0.5}, uses=0, maxlevel=3},
				snappy = {times={[1]=0.5, [2]=0.5, [3]=0.5}, uses=0, maxlevel=3},
				choppy = {times={[1]=0.5, [2]=0.5, [3]=0.5}, uses=0, maxlevel=3},
				oddly_breakable_by_hand = {times={[1]=0.5, [2]=0.5, [3]=0.5}, uses=0, maxlevel=3},
			}
		}
	})
	
	minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack)
		return true
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
