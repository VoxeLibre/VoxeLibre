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

local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_chatcommand("awards", {
	params = S("[c|clear|disable|enable]"),
	description = S("Show, clear, disable or enable your advancements."),
	func = function(name, param)
		if param == "enable" then
			awards.enable(name)
			minetest.chat_send_player(name, S("You have enabled your advancements."))
			return
		end

		if awards.player(name).disabled then
			minetest.chat_send_player(name, S("Awards are disabled, enable them first by using /awards enable!"))
			return
		end

		if param == "clear" then
			awards.clear_player(name)
			minetest.chat_send_player(name,
			S("All your awards and statistics have been cleared. You can now start again."))
		elseif param == "disable" then
			awards.disable(name)
			minetest.chat_send_player(name, S("You have disabled your advancements."))
		else
			awards.show_to(name, name, nil, false)
		end
	end
})

minetest.register_privilege("advancements", {
	description = S("Can give advancements to any player"),
	give_to_singleplayer = false,
	give_to_admin = false,
})

minetest.register_chatcommand("advancement", {
	params = S("(grant <player> (<advancement> | all)) | list"),
	privs = { advancements = true },
	description = S("Give advancement to player or list all advancements"),
	func = function(name, param)
		if param == "list" then
			local list = {}
			for k,_ in pairs(awards.def) do
				table.insert(list, k)
			end
			table.sort(list)
			for a=1, #list do
				minetest.chat_send_player(name, S("@1 (@2)", awards.def[list[a]].title, list[a]))
			end
			return true
		end
		local keyword, playername, achievement = string.match(param, "([^ ]+) (.+) (.+)")
		if not keyword or not playername or not achievement then
			return false, S("Invalid syntax.")
		end
		if keyword ~= "grant" then
			return false, S("Invalid action.")
		end
		local player = minetest.get_player_by_name(playername)
		if not player then
			return false, S("Player is not online.")
		end
		if achievement == "all" then
			for k,_ in pairs(awards.def) do
				awards.unlock(playername, k)
			end
			return true, S("Done.")
		elseif awards.exists(achievement) then
			awards.unlock(playername, achievement)
			return true, S("Done.")
		else
			return false, S("Advancement “@1” does not exist.", achievement)
		end
	end
})

