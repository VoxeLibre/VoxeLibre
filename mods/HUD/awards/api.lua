-- AWARDS
--
-- Copyright (C) 2013-2015 rubenwardy
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation; either version 2.1 of the License, or
-- (at your option) any later version.
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.
-- You should have received a copy of the GNU Lesser General Public License along
-- with this program; if not, write to the Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
--

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

-- Tunable parameters
local notif_delay = vl_tuning.setting("award_display_time", "number", {
	description = S("Amount of time award notification are displayed"), default = 3, min = 2, max = 10
})
local announce_in_chat = vl_tuning.setting("gamerule:announceAdvancements", "bool", {
	description = S("Whether advancements should be announced in chat"),
	default = minetest.settings:get_bool("mcl_showAdvancementMessages", true),
})

-- The global award namespace
awards = {
	show_mode = "hud",
}

dofile(modpath.."/api_helpers.lua")

-- Table Save Load Functions
function awards.save()
	local file = io.open(minetest.get_worldpath().."/awards.txt", "w")
	if file then
		file:write(minetest.serialize(awards.players))
		file:close()
	end
end

function awards.init()
	awards.players = awards.load()
	awards.def = {}
	awards.trigger_types = {}
	awards.on = {}
	awards.on_unlock = {}
end

function awards.load()
	local file = io.open(minetest.get_worldpath().."/awards.txt", "r")
	if file then
		local table = minetest.deserialize(file:read("*all"))
		if type(table) == "table" then
			return table
		end
	end
	return {}
end

function awards.register_trigger(name, func)
	awards.trigger_types[name] = func
	awards.on[name] = {}
	awards["register_on_"..name] = function(func)
		table.insert(awards.on[name], func)
	end
end

function awards.run_trigger_callbacks(player, data, trigger, table_func)
	for i = 1, #awards.on[trigger] do
		local res = nil
		local entry = awards.on[trigger][i]
		if type(entry) == "function" then
			res = entry(player, data)
		elseif type(entry) == "table" and entry.award then
			res = table_func(entry)
		end

		if res then
			awards.unlock(player:get_player_name(), res)
		end
	end
end

function awards.increment_item_counter(data, field, itemname, count)
	local name_split = string.split(itemname, ":")
	if #name_split ~= 2 then
		return false
	end
	local mod = name_split[1]
	local item = name_split[2]

	if data and field and mod and item then
		awards.assertPlayer(data)
		awards.tbv(data, field)
		awards.tbv(data[field], mod)
		awards.tbv(data[field][mod], item, 0)

		data[field][mod][item] = data[field][mod][item] + (count or 1)
		return true
	else
		return false
	end
end

function awards.get_item_count(data, field, itemname)
	local name_split = string.split(itemname, ":")
	if #name_split ~= 2 then
		return false
	end
	local mod = name_split[1]
	local item = name_split[2]

	if data and field and mod and item then
		awards.assertPlayer(data)
		awards.tbv(data, field)
		awards.tbv(data[field], mod)
		awards.tbv(data[field][mod], item, 0)
		return data[field][mod][item]
	end
end

function awards.get_total_item_count(data, field)
	local i = 0
	if data and field then
		awards.assertPlayer(data)
		awards.tbv(data, field)
		for mod,_ in pairs(data[field]) do
			awards.tbv(data[field], mod)
			for item,_ in pairs(data[field][mod]) do
				awards.tbv(data[field][mod], item, 0)
				i = i + data[field][mod][item]
			end
		end
	end
	return i
end

function awards.register_on_unlock(func)
	table.insert(awards.on_unlock, func)
end

-- API Functions
function awards._additional_triggers(name, def)
	-- Depreciated!
end

function awards.register_achievement(name, def)
	def.name = name

	-- Add Triggers
	if def.trigger and def.trigger.type then
		local func = awards.trigger_types[def.trigger.type]

		if func then
			func(def)
		else
			awards._additional_triggers(name, def)
		end
	end

	-- Add Award
	awards.def[name] = def

	local tdef = awards.def[name]
	if def.description == nil and tdef.getDefaultDescription then
		def.description = tdef:getDefaultDescription()
	end
end

function awards.enable(name)
	local data = awards.player(name)
	if data then
		data.disabled = nil
	end
end

function awards.disable(name)
	local data = awards.player(name)
	if data then
		data.disabled = true
	end
end

function awards.clear_player(name)
	awards.players[name] = {}
end

-- Returns true if award exists, false otherwise
function awards.exists(award)
	return awards.def[award] ~= nil
end

-- This function is called whenever a target condition is met.
-- It checks if a player already has that achievement, and if they do not,
-- it gives it to them
----------------------------------------------
--awards.unlock(name, award)
-- name - the name of the player
-- award - the name of the award to give
function awards.unlock(name, award)
	-- Access Player Data
	local data  = awards.players[name]
	local awdef = awards.def[award]

	-- Perform checks
	if not data then
		return
	end
	if not awdef then
		return
	end
	if data.disabled then
		return
	end
	awards.tbv(data,"unlocked")

	-- Don't give the achievement if it has already been given
	if data.unlocked[award] and data.unlocked[award] == award then
		return
	end

	-- Get award
	minetest.log("action", name.." has gotten award "..award)
	if announce_in_chat[1] then
		minetest.chat_send_all(S("@1 has made the advancement @2", name, minetest.colorize(mcl_colors.GREEN, "[" .. (awdef.title or award) .. "]")))
	end
	data.unlocked[award] = award
	awards.save()

	-- Give Prizes
	if awdef and awdef.prizes then
		for i = 1, #awdef.prizes do
			local itemstack = ItemStack(awdef.prizes[i])
			if not itemstack:is_empty() then
				local receiverref = minetest.get_player_by_name(name)
				if receiverref then
					receiverref:get_inventory():add_item("main", itemstack)
				end
			end
		end
	end

	-- Run callbacks
	if awdef.on_unlock and awdef.on_unlock(name, awdef) then
		return
	end
	for _, callback in pairs(awards.on_unlock) do
		if callback(name, awdef) then
			return
		end
	end

	-- Get Notification Settings
	local title = awdef.title or award
	local desc = awdef.description or ""
	local background = awdef.background or "awards_bg_default.png"
	local icon = awdef.icon or "awards_unknown.png"
	local sound = awdef.sound
	if sound == nil then
		-- Explicit check for nil because sound could be `false` to disable it
		sound = {name="awards_got_generic", gain=0.25}
	end
	local custom_announce = awdef.custom_announce
	if not custom_announce then
		if awdef.secret then
			custom_announce = S("Secret Advancement Made:")
		elseif awdef.type == "Goal" then
			custom_announce = S("Goal Completed:")
		elseif awdef.type == "Challenge" then
			custom_announce = S("Challenge Completed:")
		else
			custom_announce = S("Advancement Made:")
		end
	end

	-- Do Notification
	if sound then
		-- Enforce sound delay to prevent sound spamming
		local lastsound = awards.players[name].lastsound
		if lastsound == nil or os.difftime(os.time(), lastsound) >= 1 then
			minetest.sound_play(sound, {to_player=name}, true)
			awards.players[name].lastsound = os.time()
		end
	end

	if awards.show_mode == "formspec" then
		-- use a formspec to send it
		minetest.show_formspec(name, "achievements:unlocked", "size[4,2]"..
				"image_button_exit[0,0;4,2;"..background..";close1; ]"..
				"image_button_exit[0.2,0.8;1,1;"..icon..";close2; ]"..
				"label[1.1,1;"..title.."]"..
				"label[0.3,0.1;"..custom_announce.."]")
	elseif awards.show_mode == "chat" then
		local chat_announce
		if awdef.secret == true then
			chat_announce = S("Secret Advancement Made: @1")
		elseif awdef.type == "Goal" then
			chat_announce = S("Goal Completed: @1")
		elseif awdef.type == "Challenge" then
			chat_announce = S("Challenge Completed: @1")
		else
			chat_announce = S("Advancement Made: @1")
		end
		-- use the chat console to send it
		minetest.chat_send_player(name, string.format(chat_announce, title))
		if desc~="" then
			minetest.chat_send_player(name, desc)
		end
	else
		local player = minetest.get_player_by_name(name)
		local one = player:hud_add({
			[mcl_vars.hud_type_field] = "image",
			name = "award_bg",
			scale = {x = 1.25, y = 1},
			text = background,
			position = {x = 0.5, y = 0},
			offset = {x = 0, y = 138},
			alignment = {x = 0, y = -1},
			z_index = 101,
		})
		local hud_announce
		if awdef.secret == true then
			hud_announce = S("Secret Advancement Made!")
		elseif awdef.type == "Goal" then
			hud_announce = S("Goal Completed!")
		elseif awdef.type == "Challenge" then
			hud_announce = S("Challenge Completed!")
		else
			hud_announce = S("Advancement Made!")
		end
		local two = player:hud_add({
			[mcl_vars.hud_type_field] = "text",
			name = "award_au",
			number = 0xFFFF00,
			scale = {x = 100, y = 20},
			text = hud_announce,
			position = {x = 0.5, y = 0},
			offset = {x = 30, y = 40},
			alignment = {x = 0, y = -1},
			z_index = 102,
		})
		local three = player:hud_add({
			[mcl_vars.hud_type_field] = "text",
			name = "award_title",
			number = 0xFFFFFF,
			scale = {x = 100, y = 20},
			text = title,
			position = {x = 0.5, y = 0},
			offset = {x = 35, y = 100},
			alignment = {x = 0, y = -1},
			z_index = 102,
		})
		--[[ We use a statbar instead of image here because statbar allows us to scale the image
		properly. Note that number is 2, thus leading to a single full image.
		Yes, it's a hack, but it works for all texture sizes and is needed because the image
		type does NOT allow us a simple scaling. ]]
		local four = player:hud_add({
			[mcl_vars.hud_type_field] = "statbar",
			name = "award_icon",
			size = {x=64, y = 64},
			number = 2,
			text = icon,
			position = {x = 0.5, y = 0},
			offset = {x = -138, y = 62},
			alignment = {x = 0, y = 0},
			direction = 0,
			z_index = 102,
		})
		minetest.after(notif_delay[1], function(name)
			local player = minetest.get_player_by_name(name)
			if not player then
				return
			end
			player:hud_remove(one)
			player:hud_remove(two)
			player:hud_remove(three)
			player:hud_remove(four)
		end, player:get_player_name())
	end
end

-- Backwards compatibility
awards.give_achievement = awards.unlock

--[[minetest.register_chatcommand("gawd", {
	params = "award name",
	description = "gawd: give award to self",
	func = function(name, param)
		awards.unlock(name,param)
	end
})]]--

function awards.getFormspec(name, to, sid)
	local formspec = ""
	local listofawards = awards._order_awards(name)
	local playerdata = awards.players[name]

	if #listofawards == 0 then
		formspec = formspec .. "label[3.9,1.5;"..minetest.formspec_escape(S("Error: No awards available.")).."]"
		formspec = formspec .. "button_exit[4.2,2.3;3,1;close;"..minetest.formspec_escape(S("OK")).."]"
		return formspec
	end

	-- Sidebar
	if sid then
		local item = listofawards[sid+0]
		local def = awards.def[item.name]

		if def and def.secret and not item.got then
			formspec = formspec .. "label[1,2.75;"..minetest.formspec_escape(S("(Secret Advancement)")).."]"..
								"image[1,0;3,3;awards_unknown.png]"
			if def and def.description then
				formspec = formspec	.. "textarea[0.25,3.25;4.8,1.7;;"..minetest.formspec_escape(S("Make this advancement to find out what it is."))..";]"
			end
		else
			local title = item.name
			if def and def.title then
				title = def.title
			end
			local status
			if item.got then
				status = S("@1 (got)", title)
			else
				status = title
			end
			formspec = formspec .. "label[1,2.75;" ..
				minetest.formspec_escape(status) ..
				"]"
			if def and def.icon then
				formspec = formspec .. "image[1,0;3,3;" .. def.icon .. "]"
			end
			local barwidth = 4.6
			local perc = nil
			local label = nil
			if def.getProgress and playerdata then
				local res = def:getProgress(playerdata)
				perc = res.perc
				label = res.label
			end
			if perc then
				if perc > 1 then
					perc = 1
				end
				formspec = formspec .. "background[0,4.80;" .. barwidth ..",0.3;awards_progress_gray.png;false]"
				if perc > 0 then
					formspec = formspec .. "background[0,4.80;" .. (barwidth * perc) ..",0.3;awards_progress_green.png;false]"
				end
				if label then
					formspec = formspec .. "label[1.75,4.63;" .. minetest.formspec_escape(label) .. "]"
				end
			end
			if def and def.description then
				formspec = formspec	.. "textarea[0.25,3.25;4.8,1.7;;"..minetest.formspec_escape(def.description)..";]"
			end
		end
	end

	-- Create list box
	formspec = formspec ..
	"textlist[4.75,0;6,5;awards;"
	local first = true
	for _,award in pairs(listofawards) do
		local def = awards.def[award.name]
		if def then
			if not first then
				formspec = formspec .. ","
			end
			first = false

			if def.secret and not award.got then
				formspec = formspec .. "#707070" .. minetest.formspec_escape(S("(Secret Advancement)"))
			else
				local title = award.name
				if def and def.title then
					title = def.title
				end
				if award.got then
					formspec = formspec .. minetest.formspec_escape(title)
				else
					formspec = formspec .. "#ACACAC" .. minetest.formspec_escape(title)
				end
			end
		end
	end
	return formspec .. ";"..sid.."]"
end

function awards.show_to(name, to, sid, text)
	if name == "" or name == nil then
		name = to
	end
	if name == to and awards.player(to).disabled then
		minetest.chat_send_player(name,S("You've disabled awards. Type /awards enable to reenable."))
		return
	end
	if text then
		local listofawards = awards._order_awards(name)
		if #listofawards == 0 then
			minetest.chat_send_player(to, S("Error: No awards available."))
			return
		elseif not awards.players[name] or not awards.players[name].unlocked  then
			minetest.chat_send_player(to, S("You have not gotten any awards."))
			return
		end
		minetest.chat_send_player(to, S("@1’s awards:", name))

		for _, str in pairs(awards.players[name].unlocked) do
			local def = awards.def[str]
			if def then
				if def.title then
					if def.description then
						minetest.chat_send_player(to, S("@1: @2", def.title, def.description))
					else
						minetest.chat_send_player(to, def.title)
					end
				else
					minetest.chat_send_player(to, str)
				end
			end
		end
	else
		if sid == nil or sid < 1 then
			sid = 1
		end
		local deco = ""
		if minetest.global_exists("default") then
			deco = default.gui_bg .. default.gui_bg_img
		end
		-- Show formspec to user
		minetest.show_formspec(to,"awards:awards",
			"size[11,5]" .. deco ..
			awards.getFormspec(name, to, sid))
	end
end
awards.showto = awards.show_to

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "awards:awards" then
		return false
	end
	if fields.quit then
		return true
	end
	local name = player:get_player_name()
	if fields.awards then
		local event = minetest.explode_textlist_event(fields.awards)
		if event.type == "CHG" then
			awards.show_to(name, name, event.index, false)
		end
	end

	return true
end)

awards.init()

minetest.register_on_newplayer(function(player)
	local playern = player:get_player_name()
	awards.assertPlayer(playern)
end)

minetest.register_on_shutdown(function()
	awards.save()
end)
