local init = os.clock()
local path = minetest.get_modpath(minetest.get_current_modname())

local filepath = minetest.get_worldpath()

CREATIVE_SEARCH_ITEMS = ""

local creative_type = "search"

filepath = minetest.get_worldpath()
se = {}

function save_player_data()
	local file = io.open(filepath .. "/playerdata.txt", "w")
	file:write(minetest.serialize(playerdata))
	file:close()
end

function load_player_data()
	local file = io.open(filepath .. "/playerdata.txt", "r")
	if file then
		local table = minetest.deserialize(file:read("*all"))
		if type(table) == "table" then
			return table
			
		end
	end
	return {}
end



inventory = {}
inventory.inventory_size = 0
pagenum = 0
playerdata = load_player_data()

dofile(path.."/config.txt")
dofile(path.."/api.lua")
dofile(path.."/workbench.lua")

local function save_newplayer(pname)
	if not playerdata[pname] then
		playerdata[pname] = {}
		playerdata[pname]['isPlayer'] = true
		playerdata[pname]['gamemode'] = Default_Mode
		save_player_data()
		minetest.after(1, function() load_player_data() end)
		playerdata = load_player_data()
	end
end

minetest.register_on_joinplayer(function(player)
	local pname = player:get_player_name()
	local playerdata = load_player_data()
	if not playerdata[pname] then
		playerdata[pname] = {}
		playerdata[pname]['isPlayer'] = true
		playerdata[pname]['gamemode'] = Default_Mode
		save_player_data()

	end
	if not playerdata[pname]['gamemode'] then
		playerdata[pname]['gamemode'] = Default_Mode
		save_player_data()
		playerdata = load_player_data()
		minetest.after(1, function() updategamemode(pname, "0") end)
	else
		minetest.after(1, function() updategamemode(pname, "0") end)
	end
end)

--Ensure that all mods are loaded before editing inventory.
minetest.after(0.3, function()
local trash = minetest.create_detached_inventory("creative_trash", {
		-- Allow the stack to be placed and remove it in on_put()
		-- This allows the creative inventory to restore the stack
		allow_put = function(inv, listname, index, stack, player)
				return stack:get_count()
		end,
		on_put = function(inv, listname, index, stack, player)
			inv:set_stack(listname, index, "")
		end,
})
trash:set_size("main", 1)


local creative_list = {}
for name,def in pairs(minetest.registered_items) do
		if (not def.groups.not_in_creative_inventory or def.groups.not_in_creative_inventory == 0)
				and def.description and def.description ~= "" then
			table.insert(creative_list, name)
		end

end


local inv = minetest.create_detached_inventory("creative", {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
				return count
		end,
		allow_put = function(inv, listname, index, stack, player)
			return 0
		end,
		allow_take = function(inv, listname, index, stack, player)
				return -1
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
	
table.sort(creative_list)

inv:set_size("main", #creative_list)

for _,itemstring in ipairs(creative_list) do
        local stack = ItemStack(itemstring)
        local stack2 = nil
        if stack:get_stack_max() == 1 then
            stack2 = ItemStack(stack:get_name())
        else
            stack2 = ItemStack(stack:get_name().." "..(stack:get_stack_max()))--- for know how many item
        end
        inv:add_item("main", stack2)
end
	inventory.inventory_size = #creative_list

end)	

-- Create detached creative inventory after loading all mods
function updategamemode(pname, status)
	playerdata = load_player_data()
	if not status then
		print(pname.." has switched to "..playerdata[pname]['gamemode'].." Mode.")
		minetest.chat_send_all(pname.." has switched to "..playerdata[pname]['gamemode'].." Mode.")
	end
	print(playerdata[pname])
	if playerdata[pname] == nil then
		save_newplayer(pname)
	end
	if playerdata[pname]['gamemode'] == "Creative" then
		local player = minetest.env:get_player_by_name(pname)
		inventory.set_player_formspec(player, 1, 1)
	else
	
	local player = minetest.env:get_player_by_name(pname)
	inventory.set_player_formspec(player, 1, 1)

	end
end
inventory.set_player_formspec = function(player, start_i, pagenum)
playerdata = load_player_data()
	if playerdata[player:get_player_name()]['gamemode'] == "Creative" then
		inventory.creative_inv(player)
		inventory.hotbar(player)
	end
	
	if creative_type == "search" and playerdata[player:get_player_name()]['gamemode'] == "Creative" then
		local pagenum = math.floor(pagenum)
		local pagemax = math.floor((inventory.inventory_size-1) / (9*3) + 1)
		CREATIVE_SEARCH_ITEMS = "size[10,7]"..
		"background[-0.22,-0.25;10.8,7.7;creative_inventory_bg.png]"..
			"button[8,0;1.5,1;creative_search;Search]"..
			"list[current_player;main;0.21,6.05;9,1;]"..
			"list[detached:creative;main;0.21,2.78;9,3;"..tostring(start_i).."]"..
			"label[7.25,1.7;"..tostring(pagenum).."/"..tostring(pagemax).."]"..
			"button[5.5,1.5;1.5,1;creative_prev;<<]"..
			"button[8,1.5;1.5,1;creative_next;>>]"..
			"button[5.5,0;1.5,1;creative_survival;Survival]"..
			"list[detached:creative_trash;main;9.28,6.05;1,1;]"
		player:set_inventory_formspec(CREATIVE_SEARCH_ITEMS)
		inventory.hotbar(player)
	end
	if playerdata[player:get_player_name()]['gamemode'] == "Survival" then
		inventory.survival_inv(player)
		inventory.hotbar(player)
	end
end
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if playerdata[player:get_player_name()]['gamemode'] == "Survival" then
		return
	end
	-- Figure out current page from formspec
	local current_page = 0
	local formspec = player:get_inventory_formspec()
	local start_i = string.match(formspec, "list%[detached:creative;main;[%d.]+,[%d.]+;[%d.]+,[%d.]+;(%d+)%]")
	start_i = tonumber(start_i) or 0

	if fields.clear_inventory then
		local inventory = {}
		player:get_inventory():set_list("main", inventory)
	end
	
	if fields.creative_search then
		creative_type = "search"
	end
	
	if fields.creative_survival then
		creative_type = "default"
		inventory.creative_inv(player)
	end
	
	if fields.creative_prev then
		start_i = start_i - 9*3
	end
	if fields.creative_next then
		start_i = start_i + 9*3
	end

	if start_i < 0 then
		start_i = start_i + 9*3
	end
	if start_i >= inventory.inventory_size then
		start_i = start_i - 9*3
	end
		
	if start_i < 0 or start_i >= inventory.inventory_size then
		start_i = 0
	end
	
	inventory.set_player_formspec(player, start_i, start_i / (9*3) + 1)
end)

local gm_priv = false

if minetest.setting_getbool("creative_mode")==false then
	 gm_priv = true
elseif minetest.setting_getbool("creative_mode")==true then
	 gm_priv = false
end

minetest.register_chatcommand('gamemode',{
	params = "1, c | 0, s",
	description = 'Switch your gamemode',
	privs = {gamemode = gm_priv},
	func = function(name, param)
		if param == "1" or param == "c" then
			playerdata[name]['gamemode'] = "Creative"
			save_player_data()
			minetest.chat_send_player(name, 'Your gamemode is now: '..playerdata[name]['gamemode'])
			updategamemode(name)
		elseif param == "0" or param == "s" then
			playerdata[name]['gamemode'] = "Survival"
			save_player_data()
			minetest.chat_send_player(name, 'Your gamemode is now: '..playerdata[name]['gamemode'])
			updategamemode(name)
		else
			minetest.chat_send_player(name, "Error: That player does not exist!")
			return false
		end
	end
})


--[[minetest.register_on_punchnode(function(pos, node, puncher)
	local pos = pos
	local pname = puncher:get_player_name()
	if playerdata[pname]['gamemode'] == "Creative" then
	minetest.after(0.1, function()
	minetest.env:remove_node(pos)
	end)
	end
end)]]

minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack)
	local pname = placer:get_player_name()
	if playerdata[pname]['gamemode'] == "Creative" then
	return true
	end
end)

minetest.register_privilege("gamemode", "Permission to use /gamemode.")
local time_to_load= os.clock() - init
print(string.format("[MOD] "..minetest.get_current_modname().." loaded in %.4f s", time_to_load))

