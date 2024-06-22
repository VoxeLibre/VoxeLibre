local modname = "vl_tuning"
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)
local F = function(f) return minetest.formspec_escape(S(f)) end

function vl_tuning.show_formspec(player_name, tab)
	if not tab then tab = 1 end

	local gamerules = {}
	local settings = {}
	for name,_ in pairs(vl_tuning.registered_settings) do
		if name:sub(0,#"gamerule:") == "gamerule:" then
			table.insert(gamerules, name)
		else
			table.insert(settings, name)
		end
	end
	local formspec =
		"formspec_version[4]"..
		"size[25,15,true]"..
		"tabheader[0,0;tab;"..
			F("Game Rules")..","..
			F("Settings")..
		";"..tab..";false;false]"

	minetest.show_formspec(player_name, "vl_tuning:settings", formspec)
end
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "vl_tuning:settings" then return end

	minetest.log("action",dump({
		player = player,
		fields = fields,
		formname = formname,
	}))
	if fields.quit then
		return
	end
	vl_tuning.show_formspec(player:get_player_name(), fields.tab)
end)

minetest.register_chatcommand("settings",{
	func = function(player_name, param)
		dofile(modpath.."/gui.lua")
		vl_tuning.show_formspec(player_name)
	end
})

