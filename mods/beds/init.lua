local player_in_bed = 0
local guy
local hand
local old_yaw = 0

local function get_dir(pos)
	local btop = "beds:bed_top"
	if minetest.get_node({x=pos.x+1,y=pos.y,z=pos.z}).name == btop then
		return 7.9
	elseif minetest.get_node({x=pos.x-1,y=pos.y,z=pos.z}).name == btop then
		return 4.75
	elseif minetest.get_node({x=pos.x,y=pos.y,z=pos.z+1}).name == btop then
		return 3.15
	elseif minetest.get_node({x=pos.x,y=pos.y,z=pos.z-1}).name == btop then
		return 6.28
	end
end

local function plock(start, max, tick, player, yaw)
	if start+tick < max then
		player:set_look_pitch(-1.2)
		player:set_look_yaw(yaw)
		minetest.after(tick, plock, start+tick, max, tick, player, yaw) 
	else
		player:set_look_pitch(0)
		if old_yaw ~= 0 then minetest.after(0.1+tick, function() player:set_look_yaw(old_yaw) end) end
	end
end

local function exit(pos)
	local npos = minetest.find_node_near(pos, 1, "beds:bed_bottom")
	if npos ~= nil then pos = npos end
	if minetest.get_node({x=pos.x+1,y=pos.y,z=pos.z}).name == "air" then
		return {x=pos.x+1,y=pos.y,z=pos.z}
	elseif minetest.get_node({x=pos.x-1,y=pos.y,z=pos.z}).name == "air" then
		return {x=pos.x-1,y=pos.y,z=pos.z}
	elseif minetest.get_node({x=pos.x,y=pos.y,z=pos.z+1}).name == "air" then
		return {x=pos.x,y=pos.y,z=pos.z+1}
	elseif minetest.get_node({x=pos.x,y=pos.y,z=pos.z-1}).name == "air" then
		return {x=pos.x,y=pos.y,z=pos.z-1}
	else 
		return {x=pos.x,y=pos.y,z=pos.z}
	end
end

minetest.register_node("beds:bed_bottom", {
	description = "Bed",
	inventory_image = "beds_bed.png",
	wield_image = "beds_bed.png",
	wield_scale = {x=0.8,y=2.5,z=1.3},
	drawtype = "nodebox",
	is_ground_content = false,
	tiles = {"beds_bed_top_bottom.png^[transformR90", "default_wood.png",  "beds_bed_side_bottom_r.png",  "beds_bed_side_bottom_r.png^[transformfx", "beds_bed_leer.png", "beds_bed_side_bottom.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	stack_max = 1,
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=3,bed=1,deco_block=1},
	sounds = mcl_core.node_sound_wood_defaults(),
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.06, 0.5},
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.06, 1.5},
				
	},
	
	after_place_node = function(pos, placer, itemstack)
		local node = minetest.get_node(pos)
		local param2 = node.param2
		local npos = {x=pos.x, y=pos.y, z=pos.z}
		if param2 == 0 then
			npos.z = npos.z+1
		elseif param2 == 1 then
			npos.x = npos.x+1
		elseif param2 == 2 then
			npos.z = npos.z-1
		elseif param2 == 3 then
			npos.x = npos.x-1
		end
		if minetest.registered_nodes[minetest.get_node(npos).name].buildable_to == true and minetest.get_node({x=npos.x, y=npos.y-1, z=npos.z}).name ~= "air" then
			minetest.set_node(npos, {name="beds:bed_top", param2 = param2})
		else
			minetest.dig_node(pos)
			return true
		end
	end,	
	
	on_destruct = function(pos)
		pos = minetest.find_node_near(pos, 1, "beds:bed_top")
		if pos ~= nil then minetest.remove_node(pos) end
	end,
	
	 on_rightclick = function(pos, node, clicker, itemstack)
		if not clicker:is_player() then
			return
		end

		if minetest.get_timeofday() > 0.2 and minetest.get_timeofday() < 0.805 then
			minetest.chat_send_all("You can only sleep at night")
			return
		else			
			clicker:set_physics_override(0,0,0)
			old_yaw = clicker:get_look_yaw()
			guy = clicker
			clicker:set_look_yaw(get_dir(pos))
			minetest.chat_send_all("Good night")
			plock(0,2,0.1,clicker, get_dir(pos))
		end

		if not clicker:get_player_control().sneak then
			local meta = minetest.get_meta(pos)
			local param2 = node.param2
			if param2 == 0 then
				pos.z = pos.z+1
			elseif param2 == 1 then
				pos.x = pos.x+1
			elseif param2 == 2 then
				pos.z = pos.z-1
			elseif param2 == 3 then
				pos.x = pos.x-1
			end
			if clicker:get_player_name() == meta:get_string("player") then
				if param2 == 0 then
					pos.x = pos.x-1
				elseif param2 == 1 then
					pos.z = pos.z+1
				elseif param2 == 2 then
					pos.x = pos.x+1
				elseif param2 == 3 then
					pos.z = pos.z-1
				end
				pos.y = pos.y-0.5
				clicker:setpos(pos)
				meta:set_string("player", "")
				player_in_bed = player_in_bed-1
			elseif meta:get_string("player") == "" then
				pos.y = pos.y-0.5
				clicker:setpos(pos)
				meta:set_string("player", clicker:get_player_name())
				player_in_bed = player_in_bed+1
			end
		end
	end
})

minetest.register_node("beds:bed_top", {
	drawtype = "nodebox",
	tiles = {"beds_bed_top_top.png^[transformR90", "beds_bed_leer.png",  "beds_bed_side_top_r.png",  "beds_bed_side_top_r.png^[transformfx",  "beds_bed_side_top.png", "beds_bed_leer.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=3,not_in_creative_inventory=1},
	sounds = mcl_core.node_sound_wood_defaults(),
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.06, 0.5},
	},
	selection_box = {
		type = "fixed",
		fixed = {0, 0, 0, 0, 0, 0},
	},
})

minetest.register_alias("beds:bed", "beds:bed_bottom")

minetest.register_craft({
	output = "beds:bed",
	recipe = {
		{"group:wool", "group:wool", "group:wool", },
		{"group:wood", "group:wood", "group:wood", }
	}
})

local beds_player_spawns = {}
local file = io.open(minetest.get_worldpath().."/beds_player_spawns", "r")
if file then
	beds_player_spawns = minetest.deserialize(file:read("*all"))
	file:close()
end

local timer = 0
local wait = false
minetest.register_globalstep(function(dtime)
	if timer<2 then
		timer = timer+dtime
		return
	end
	timer = 0
	
	local players = #minetest.get_connected_players()
	if players == player_in_bed and players ~= 0 then
		if minetest.get_timeofday() < 0.2 or minetest.get_timeofday() > 0.805 then
			if not wait then
				minetest.after(2, function()
					minetest.set_timeofday(0.23)
					wait = false
					guy:set_physics_override(1,1,1)
					guy:setpos(exit(guy:getpos()))
					
				end)
				wait = true
				for _,player in ipairs(minetest.get_connected_players()) do
					beds_player_spawns[player:get_player_name()] = player:getpos()
				end
				local file = io.open(minetest.get_worldpath().."/beds_player_spawns", "w")
				if file then
					file:write(minetest.serialize(beds_player_spawns))
					file:close()
				end
			end
		end
	end
end)

minetest.register_on_respawnplayer(function(player)
	local name = player:get_player_name()
	if beds_player_spawns[name] then
		player:setpos(beds_player_spawns[name])
		return true
	end
end)

minetest.register_abm({
	nodenames = {"beds:bed_bottom"},
	interval = 1,
	chance = 1,
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		if meta:get_string("player") ~= "" then
			local param2 = node.param2
			if param2 == 0 then
				pos.z = pos.z+1
			elseif param2 == 1 then
				pos.x = pos.x+1
			elseif param2 == 2 then
				pos.z = pos.z-1
			elseif param2 == 3 then
				pos.x = pos.x-1
			end
			local player = minetest.get_player_by_name(meta:get_string("player"))
			if player == nil then
				meta:set_string("player", "")
				player_in_bed = player_in_bed-1
				return
			end
			local player_pos = player:getpos()
			player_pos.x = math.floor(0.5+player_pos.x)
			player_pos.y = math.floor(0.5+player_pos.y)
			player_pos.z = math.floor(0.5+player_pos.z)
			if pos.x ~= player_pos.x or pos.y ~= player_pos.y or pos.z ~= player_pos.z then
				meta:set_string("player", "")
				player_in_bed = player_in_bed-1
				return
			end
		end
	end
})

if minetest.setting_get("log_mods") then
	minetest.log("action", "beds loaded")
end
