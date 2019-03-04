-- Simple Skins mod for Minetest (MineClone 2 Edition)

-- Released by TenPlus1 and based on Zeg9's code under MIT license

skins = {
	skins = {}, meta = {},
	modpath = minetest.get_modpath("simple_skins"),
	skin_count = 0, -- counter of _custom_ skins (all skins except character.png)
}


-- Load support for intllib.
local S, NS = dofile(skins.modpath .. "/intllib.lua")


-- load skin list and metadata
local id, f, data, skin = 1

while true do

	skin = "character_" .. id

	-- does skin file exist ?
	f = io.open(skins.modpath .. "/textures/" .. skin .. ".png")

	-- escape loop if not found and remove last entry
	if not f then
		id = id - 1
		break
	end

	f:close()

	-- does metadata exist for that skin file ?
	f = io.open(skins.modpath .. "/meta/" .. skin .. ".txt")

	if f then
		data = minetest.deserialize("return {" .. f:read('*all') .. "}")
		f:close()
	end

	-- add metadata to list
	skins.meta[skin] = {
		name = data and data.name or "",
		author = data and data.author or "",
	}

	id = id + 1
	skins.skin_count = skins.skin_count + 1
end

skins.set_player_skin = function(player, skin)
	if not player then
		return
	end
	local playername = player:get_player_name()
	skins.skins[playername] = skin
	player:set_attribute("simple_skins:skin", skins.skins[playername])
	skins.update_player_skin(player)
	if minetest.get_modpath("3d_armor") then
		armor.textures[playername].skin = skin .. ".png"
		armor:update_player_visuals(player)
	end
end

skins.update_player_skin = function(player)
	if not player then
		return
	end
	local playername = player:get_player_name()
	mcl_player.player_set_textures(player, { skins.skins[playername] .. ".png" })
end

-- load player skin on join
minetest.register_on_joinplayer(function(player)

	local name = player:get_player_name()
	local skin = player:get_attribute("simple_skins:skin")
	local set_skin
	-- do we already have a skin in player attributes?
	if skin then
		set_skin = skin

	-- otherwise use random skin if not set
	else
		local r = math.random(0, skins.skin_count)
		if r == 0 then
			set_skin = "character"
		else
			set_skin = "character_" .. r
		end
	end
	if set_skin then
		skins.set_player_skin(player, set_skin)
	end
end)

-- command to set player skin (usually for custom skins)
minetest.register_chatcommand("setskin", {
	params = "[<player>] <skin number>",
	description = S("Select player skin of yourself or another player"),
	privs = {},
	func = function(name, param)

		local playername, skin_id = string.match(param, "([^ ]+) (%d+)")
		if not playername or not skin_id then
			skin_id = string.match(param, "(%d+)")
			if not skin_id then
				return false, S("Insufficient or wrong parameters")
			end
			playername = name
		end
		skin_id = tonumber(skin_id)

		local player = minetest.get_player_by_name(playername)

		if not player then
			return false, S("Player @1 not online!", playername)
		end
		if name ~= playername then
			local privs = minetest.get_player_privs(name)
			if not privs.server then
				return false, S("You need the “server” privilege to change the skin of other players!")
			end
		end

		local skin
		if skin_id == nil or skin_id > skins.skin_count or skin_id < 0 then
			return false, S("Invalid skin number! Valid numbers: 0 to @1", skins.skin_count)
		elseif skin_id == 0 then
			skin = "character"
		else
			skin = "character_" .. tostring(skin_id)
		end

		skins.set_player_skin(player, skin)
		local skinfile = skin..".png"

		local your_msg = S("Your skin has been set to: @1", skinfile)
		if name == playername then
			return true, your_msg
		else
			minetest.chat_send_player(playername, your_msg)
			return true, S("Skin of @1 set to: @2", playername, skinfile)
		end

	end,
})
