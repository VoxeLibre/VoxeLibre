local modpath = core.get_modpath(core.get_current_modname())
local S = core.get_translator("vl_announcements")
local F = core.formspec_escape
local H = core.hypertext_escape
local C = core.colorize
local formname = "vl_announcements:main"
local states = {}

vl_announcements = {}
dofile(modpath .. "/api.lua")
dofile(modpath .. "/voxelibre.lua")

local function seen_key(provider)
	return "vl_announcements:seen:" .. provider.id
end

local function is_unread(player, provider)
	local newest = provider.announcements[1]
	return newest and player:get_meta():get_string(seen_key(provider)) ~= newest.id
end

local function mark_seen(player, provider)
	local newest = provider.announcements[1]
	if newest then player:get_meta():set_string(seen_key(provider), newest.id) end
end

local function provider_tabs(providers, selected)
	local fs = {"style_type[image_button;border=false;bgimg=;bgimg_pressed=]"}
	local width = math.min(1.2, 14.8 / math.max(1, #providers))
	for index, provider in ipairs(providers) do
		local x = 0.6 + (index - 1) * width
		if provider.id == selected.id then
			fs[#fs + 1] = "box[" .. x .. ",0.1;" .. width .. ",0.8;#FFFFFF22]"
		end
		fs[#fs + 1] = "image_button[" .. (x + (width - 0.55) / 2) .. ",0.18;0.65,0.65;" ..
			F(provider.icon) .. ";provider_" .. F(provider.id) .. ";]"
		fs[#fs + 1] = "tooltip[provider_" .. F(provider.id) .. ";" .. F(provider.name) .. "]"
	end
	return table.concat(fs)
end

local function feature_cards(announcement, left, width)
	local fs = {}
	local card_width = (width - 0.6) / 4
	for index, feature in ipairs(announcement.features) do
		if index > 4 then break end
		local x = left + (index - 1) * (card_width + 0.2)
		local y = 9.35
		fs[#fs + 1] = "button[" .. x .. "," .. y .. ";" .. card_width .. ",0.75;feature_" .. index .. ";" ..
			F(feature.title) .. "]"
		fs[#fs + 1] = "image[" .. (x + 0.1) .. "," .. (y + 0.1) .. ";0.55,0.55;" .. F(feature.icon) .. "]"
		fs[#fs + 1] = "tooltip[feature_" .. index .. ";" .. F(feature.description) .. "]"
	end
	return table.concat(fs)
end

local function details_text(announcement)
	local lines = {}
	for _, section in ipairs(announcement.details) do
		lines[#lines + 1] = section.title
		for _, entry in ipairs(section.entries or {}) do lines[#lines + 1] = "• " .. entry end
		lines[#lines + 1] = ""
	end
	return table.concat(lines, "\n")
end

local function article(state, provider, announcement)
	local left = state.mode == "archive" and 3.35 or 0.65
	local width = state.mode == "archive" and 12 or 14.7
	if state.page == "feature" then
		local feature = announcement.features[state.feature]
		if not feature then state.page = "release" return article(state, provider, announcement) end
		return table.concat({
			"image[", left, ",1.5;1.75,1.75;", F(feature.icon), "]",
			"label[", left + 2.05, ",1.95;", F(C(mcl_formspec.label_color, feature.title)), "]",
			"textarea[", left, ",3.6;", width, ",6.5;;;", F(feature.description), "]",
			"button[", left, ",10.75;2.2,0.8;back;", F(S("Back")), "]",
		})
	elseif state.page == "details" then
		return table.concat({
			"label[", left, ",1.25;", F(C(mcl_formspec.label_color, S("Changes and fixes"))), "]",
			"textarea[", left, ",1.75;", width, ",8.35;;;", F(details_text(announcement)), "]",
			"button[", left, ",10.75;2.2,0.8;back;", F(S("Back")), "]",
		})
	else --archive and greeting
		local poster_width = math.min(12, width)
		local poster_height = 6.27
		local widgets = {
			"hypertext[", left, ",1.0;", width,
				",0.55;release_title;<global halign='center' color='", mcl_formspec.label_color,
				"'><big><b>", F(H(provider.name .. " " .. announcement.version .. " — " ..
					announcement.title)), "</b></big>]",
			announcement.poster and "image[" .. (left + (width - poster_width) / 2) ..
				",1.65;" .. poster_width .. "," .. poster_height .. ";" .. F(announcement.poster) .. "]" or "",
			"textarea[", left, ",8.15;", width, ",1.0;;;", F(announcement.intro), "]",
			feature_cards(announcement, left, width),
			"button[", left, ",10.75;2.8,0.8;details;", F(S("Changes & fixes")), "]",
		}
		if state.mode == "greeting" then
			widgets[#widgets + 1] =
				"button[" .. left + width - 2.8 .. ",10.75;2.8,0.8;archive;" .. F(S("Archive")) .. "]"
		end
		return table.concat(widgets)
	end
end

local function show(player, state)
	local providers = state.providers
	local provider = providers[state.provider_index] or providers[1]
	if not provider then return end
	state.provider_index = table.indexof(providers, provider)
	local announcement_index = state.mode == "greeting" and 1 or state.announcement_index
	local announcement = provider.announcements[announcement_index] or provider.announcements[1]
	state.announcement_index = table.indexof(provider.announcements, announcement)
	mark_seen(player, provider)

	local fs = {"formspec_version[6]", "size[16,12]", provider_tabs(providers, provider)}
	if state.mode == "archive" then
		local versions = {}
		for _, item in ipairs(provider.announcements) do versions[#versions + 1] = F(item.version) end
		fs[#fs + 1] = "label[0.45,1.25;" .. F(S("Releases")) .. "]"
		fs[#fs + 1] = "textlist[0.4,1.65;2.45,8.75;versions;" .. table.concat(versions, ",") ..
			";" .. state.announcement_index .. ";false]"
	end
	fs[#fs + 1] = article(state, provider, announcement)
	fs[#fs + 1] = "button_exit[7,11.05;2,0.65;close;" .. F(S("Close")) .. "]"
	states[player:get_player_name()] = state
	core.show_formspec(player:get_player_name(), formname, table.concat(fs))
end

function vl_announcements.show_archive(player)
	local providers = vl_announcements.get_providers()
	if #providers == 0 then return end
	show(player, {mode = "archive", providers = providers, provider_index = 1,
		announcement_index = 1, page = "release"})
end

local function show_greeting(player, providers)
	for _, provider in ipairs(providers) do mark_seen(player, provider) end
	show(player, {mode = "greeting", providers = providers, provider_index = 1,
		announcement_index = 1, page = "release"})
end

core.register_on_player_receive_fields(function(player, received_formname, fields)
	if fields.__vl_announcements then vl_announcements.show_archive(player) return end
	if received_formname ~= formname then return end
	local state = states[player:get_player_name()]
	if not state then return end

	for index, provider in ipairs(state.providers) do
		if fields["provider_" .. provider.id] then
			state.provider_index, state.announcement_index, state.page = index, 1, "release"
			show(player, state)
			return
		end
	end
	if fields.versions then
		local event = core.explode_textlist_event(fields.versions)
		if event.type == "CHG" or event.type == "DCL" then
			state.announcement_index, state.page = event.index, "release"
			show(player, state)
		end
	elseif fields.archive then
		vl_announcements.show_archive(player)
	elseif fields.details then
		state.page = "details" show(player, state)
	elseif fields.back then
		state.page = "release" show(player, state)
	else
		for index = 1, 4 do
			if fields["feature_" .. index] then
				state.page, state.feature = "feature", index
				show(player, state)
				return
			end
		end
	end
	if fields.quit or fields.close then states[player:get_player_name()] = nil end
end)

core.register_on_joinplayer(function(player, last_login)
	local providers = vl_announcements.get_providers()
	if not last_login then
		for _, provider in ipairs(providers) do mark_seen(player, provider) end
		return
	end
	if not core.settings:get_bool("vl_announcements_auto_show", true) then return end
	local unread = {}
	for _, provider in ipairs(providers) do
		if is_unread(player, provider) then unread[#unread + 1] = provider end
	end
	if #unread == 0 then return end
	local name = player:get_player_name()
	core.after(0.5, function()
		local current = core.get_player_by_name(name)
		if current then
			show_greeting(current, unread)
			core.chat_send_player(player:get_player_name(),
				S("New updates have been released! Use /announcements for more info."))
		end
	end)
end)

core.register_on_leaveplayer(function(player) states[player:get_player_name()] = nil end)

core.register_chatcommand("announcements", {
	description = S("Show VoxeLibre announcements and release highlights."),
	params = S("[clear|greeting]"),
	func = function(name, param)
		local player = core.get_player_by_name(name)
		if not player then return false, S("This command can only be used in-game.") end

		local command = (param or ""):trim():lower()
		if command == "clear" then
			for _, provider in ipairs(vl_announcements.get_providers()) do
				player:get_meta():set_string(seen_key(provider), "")
			end
			return true, S("Announcement history cleared.")
		elseif command == "greeting" then
			local providers = vl_announcements.get_providers()
			if #providers == 0 then return false, S("No announcements are registered.") end
			show_greeting(player, providers)
			return true
		elseif command ~= "" then
			return false, S("Usage: /announcements [clear|greeting]")
		end
		vl_announcements.show_archive(player)
		return true
	end,
})
