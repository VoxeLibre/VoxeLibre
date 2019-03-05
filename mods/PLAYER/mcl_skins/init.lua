-- Skins for MineClone 2

mcl_skins = {
	skins = {}, list = {}, previews = {}, meta = {},
	modpath = minetest.get_modpath("mcl_skins"),
	skin_count = 0, -- counter of _custom_ skins (all skins except character.png)
}


-- Load support for intllib.
local S, NS = dofile(mcl_skins.modpath .. "/intllib.lua")


-- load skin list and metadata
local id, f, data, skin = 1

mcl_skins.list[0] = "character"

while true do

	skin = "character_" .. id

	-- does skin file exist ?
	f = io.open(mcl_skins.modpath .. "/textures/" .. skin .. ".png")

	-- escape loop if not found and remove last entry
	if not f then
		mcl_skins.list[id] = nil
		id = id - 1
		break
	end

	f:close()
	table.insert(mcl_skins.list, skin)

	-- does metadata exist for that skin file ?
	f = io.open(mcl_skins.modpath .. "/meta/" .. skin .. ".txt")

	if f then
		data = minetest.deserialize("return {" .. f:read('*all') .. "}")
		f:close()
	end

	-- add metadata to list
	mcl_skins.meta[skin] = {
		name = data and data.name or "",
		author = data and data.author or "",
	}

	id = id + 1
	mcl_skins.skin_count = mcl_skins.skin_count + 1
end

mcl_skins.set_player_skin = function(player, skin_id)
	if not player then
		return false
	end
	local playername = player:get_player_name()
	local skin, skin_file, preview
	if skin_id == nil or type(skin_id) ~= "number" or skin_id < 0 or skin_id > mcl_skins.skin_count then
		return false
	elseif skin_id == 0 then
		skin = "character"
		preview = "player"
	else
		skin = "character_" .. tostring(skin_id)
		preview = "player_" .. tostring(skin_id)
	end
	skin_file = skin .. ".png"
	mcl_skins.skins[playername] = skin
	mcl_skins.previews[playername] = preview
	player:set_attribute("mcl_skins:skin_id", tostring(skin_id))
	mcl_skins.update_player_skin(player)
	if minetest.get_modpath("3d_armor") then
		armor.textures[playername].skin = skin_file
		armor:update_player_visuals(player)
	end
	if minetest.get_modpath("mcl_inventory") then
		mcl_inventory.update_inventory_formspec(player)
	end
	for i=1, #mcl_skins.registered_on_set_skins do
		mcl_skins.registered_on_set_skins[i](player, skin)
	end
	minetest.log("action", "[mcl_skins] Player skin for "..playername.." set to skin #"..skin_id)
	return true
end

mcl_skins.update_player_skin = function(player)
	if not player then
		return
	end
	local playername = player:get_player_name()
	mcl_player.player_set_textures(player, { mcl_skins.skins[playername] .. ".png" }, mcl_skins.previews[playername] .. ".png" )
end

-- load player skin on join
minetest.register_on_joinplayer(function(player)

	local name = player:get_player_name()
	local skin_id = player:get_attribute("mcl_skins:skin_id")
	local set_skin
	-- do we already have a skin in player attributes?
	if skin_id then
		set_skin = tonumber(skin_id)
	-- otherwise use random skin if not set
	else
		set_skin = math.random(0, mcl_skins.skin_count)
	end
	if set_skin then
		local ok = mcl_skins.set_player_skin(player, set_skin)
		if not ok then
			set_skin = math.random(0, mcl_skins.skin_count)
			minetest.log("warning", "[mcl_skins] Player skin for "..name.." not found, falling back to skin #"..set_skin)
			mcl_skins.set_player_skin(player, set_skin)
		end
	end
end)

mcl_skins.registered_on_set_skins = {}

mcl_skins.register_on_set_skin = function(func)
	table.insert(mcl_skins.registered_on_set_skins, func)
end

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
		local ok = mcl_skins.set_player_skin(player, skin_id)
		if not ok then
			return false, S("Invalid skin number! Valid numbers: 0 to @1", mcl_skins.skin_count)
		end
		local skinfile = "Skin #"..skin_id

		local your_msg = S("Your skin has been set to: @1", skinfile)
		if name == playername then
			return true, your_msg
		else
			minetest.chat_send_player(playername, your_msg)
			return true, S("Skin of @1 set to: @2", playername, skinfile)
		end

	end,
})

minetest.log("action", "[mcl_skins] Mod initialized with "..mcl_skins.skin_count.." custom skin(s)")
