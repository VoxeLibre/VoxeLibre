-- Skins for MineClone 2

mcl_skins = {
	skins = {}, list = {}, previews = {}, meta = {}, has_preview = {},
	modpath = minetest.get_modpath("mcl_skins"),
	skin_count = 0, -- counter of _custom_ skins (all skins except character.png)
}

local S = minetest.get_translator("mcl_skins")
local has_mcl_armor = minetest.get_modpath("mcl_armor")
local has_mcl_inventory = minetest.get_modpath("mcl_inventory")

-- load skin list and metadata
local id, f, data, skin = 0

while true do

	if id == 0 then
		skin = "character"
		mcl_skins.has_preview[id] = true
	else
		skin = "mcl_skins_character_" .. id
		local preview = "mcl_skins_player_" .. id

		-- Does skin file exist?
		f = io.open(mcl_skins.modpath .. "/textures/" .. skin .. ".png")

		-- escape loop if not found
		if not f then
			break
		end
		f:close()

		-- Does skin preview file exist?
		local file_preview = io.open(mcl_skins.modpath .. "/textures/" .. preview .. ".png")
		if file_preview == nil then
			minetest.log("warning", "[mcl_skins] Player skin #"..id.." does not have preview image (player_"..id..".png)")
			mcl_skins.has_preview[id] = false
		else
			mcl_skins.has_preview[id] = true
			file_preview:close()
		end
	end

	mcl_skins.list[id] = skin

	-- does metadata exist for that skin file ?
	if id == 0 then
		metafile = "mcl_skins_character.txt"
	else
		metafile = "mcl_skins_character_"..id..".txt"
	end
	f = io.open(mcl_skins.modpath .. "/meta/" .. metafile)

	data = nil
	if f then
		data = minetest.deserialize("return {" .. f:read('*all') .. "}")
		f:close()
	end

	-- add metadata to list
	mcl_skins.meta[skin] = {
		name = data and data.name or "",
		author = data and data.author or "",
		gender = data and data.gender or "",
	}

	if id > 0 then
		mcl_skins.skin_count = mcl_skins.skin_count + 1
	end
	id = id + 1
end

mcl_skins.cycle_skin = function(player)
	local skin_id = tonumber(player:get_meta():get_string("mcl_skins:skin_id"))
	if not skin_id then
		skin_id = 0
	end
	skin_id = skin_id + 1
	if skin_id > mcl_skins.skin_count then
		skin_id = 0
	end
	mcl_skins.set_player_skin(player, skin_id)
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
		mcl_player.player_set_model(player, "mcl_armor_character.b3d")
	else
		skin = "mcl_skins_character_" .. tostring(skin_id)
		local meta = mcl_skins.meta[skin]
		if meta.gender == "female" then
			mcl_player.player_set_model(player, "mcl_armor_character_female.b3d")
		else
			mcl_player.player_set_model(player, "mcl_armor_character.b3d")
		end
		if mcl_skins.has_preview[skin_id] then
			preview = "mcl_skins_player_" .. tostring(skin_id)
		else
			-- Fallback preview image if preview image is missing
			preview = "mcl_skins_player_dummy"
		end
	end
	skin_file = skin .. ".png"
	mcl_skins.skins[playername] = skin
	mcl_skins.previews[playername] = preview
	player:get_meta():set_string("mcl_skins:skin_id", tostring(skin_id))
	mcl_skins.update_player_skin(player)
	if has_mcl_armor then
		armor.textures[playername].skin = skin_file
		armor:update_player_visuals(player)
	end
	if has_mcl_inventory then
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
	local skin_id = player:get_meta():get_string("mcl_skins:skin_id")
	local set_skin
	-- do we already have a skin in player attributes?
	if skin_id ~= nil and skin_id ~= "" then
		set_skin = tonumber(skin_id)
	-- otherwise use random skin if not set
	end
	if not set_skin then
		set_skin = math.random(0, mcl_skins.skin_count)
	end
	local ok = mcl_skins.set_player_skin(player, set_skin)
	if not ok then
		set_skin = math.random(0, mcl_skins.skin_count)
		minetest.log("warning", "[mcl_skins] Player skin for "..name.." not found, falling back to skin #"..set_skin)
		mcl_skins.set_player_skin(player, set_skin)
	end
end)

mcl_skins.registered_on_set_skins = {}

mcl_skins.register_on_set_skin = function(func)
	table.insert(mcl_skins.registered_on_set_skins, func)
end

-- command to set player skin (usually for custom skins)
minetest.register_chatcommand("setskin", {
	params = S("[<player>] [<skin number>]"),
	description = S("Select player skin of yourself or another player"),
	privs = {},
	func = function(name, param)

		if param == "" and name ~= "" then
			mcl_skins.show_formspec(name)
			return true
		end
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

		local ok = mcl_skins.set_player_skin(player, skin_id)
		if not ok then
			return false, S("Invalid skin number! Valid numbers: 0 to @1", mcl_skins.skin_count)
		end
		local skinfile = "#"..skin_id

		local meta = mcl_skins.meta[mcl_skins.skins[playername]]
		local your_msg
		if not meta.name or meta.name == "" then
			your_msg = S("Your skin has been set to: @1", skinfile)
		else
			your_msg = S("Your skin has been set to: @1 (@2)", meta.name, skinfile)
		end
		if name == playername then
			return true, your_msg
		else
			minetest.chat_send_player(playername, your_msg)
			return true, S("Skin of @1 set to: @2 (@3)", playername, meta.name, skinfile)
		end

	end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.__mcl_skins then
		if mcl_skins.skin_count <= 6 then
			-- Change skin immediately if there are not many skins
			mcl_skins.cycle_skin(player)
			if player:get_attach() ~= nil then
				mcl_player.player_set_animation(player, "sit")
			end
		else
			-- Show skin selection formspec otherwise
			mcl_skins.show_formspec(player:get_player_name())
		end
	end
end)

mcl_skins.show_formspec = function(playername)
	local formspec = "size[7,8.5]"

	formspec = formspec .. "label[2,2;" .. minetest.formspec_escape(minetest.colorize(mcl_colors.DARK_GRAY, S("Select player skin:"))) .. "]"
		.. "textlist[0,2.5;6.8,6;skins_set;"

	local meta
	local selected = 1

	for i = 0, mcl_skins.skin_count do

		local label = S("@1 (@2)", mcl_skins.meta[mcl_skins.list[i]].name, "#"..i)

		formspec = formspec .. minetest.formspec_escape(label)

		if mcl_skins.skins[playername] == mcl_skins.list[i] then
			selected = i + 1
			meta = mcl_skins.meta[mcl_skins.list[i]]
		end

		if i < #mcl_skins.list then
			formspec = formspec ..","
		end
	end

	formspec = formspec .. ";" .. selected .. ";false]"

	formspec = formspec .. "image[0,0;1.35,2.7;" .. mcl_skins.previews[playername] .. ".png]"

	if meta then
		if meta.name and meta.name ~= "" then
			formspec = formspec .. "label[2,0.5;" .. minetest.formspec_escape(minetest.colorize(mcl_colors.DARK_GRAY, S("Name: @1", meta.name))) .. "]"
		end
	end

	minetest.show_formspec(playername, "mcl_skins:skin_select", formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)

	if formname == "mcl_skins:skin_select" then

		local name = player:get_player_name()

		local event = minetest.explode_textlist_event(fields["skins_set"])

		if event.type == "CHG" or event.type == "DCL" then

			local skin_id = math.min(event.index - 1, mcl_skins.skin_count)
			if not mcl_skins.list[skin_id] then
				return -- Do not update wrong skin number
			end

			mcl_skins.set_player_skin(player, skin_id)
			mcl_skins.show_formspec(name)
		end
	end
end)

minetest.log("action", "[mcl_skins] Mod initialized with "..mcl_skins.skin_count.." custom skin(s)")
