local refresh_interval      = .63
local huds                  = {}
local default_debug         = 3
local after                 = minetest.after
local get_connected_players = minetest.get_connected_players
local get_biome_name        = minetest.get_biome_name
local get_biome_data        = minetest.get_biome_data
local format                = string.format

local min1, min2, min3 = mcl_mapgen.overworld.min, mcl_mapgen.end_.min, mcl_mapgen.nether.min
local max1, max2, max3 = mcl_mapgen.overworld.max, mcl_mapgen.end_.max, mcl_mapgen.nether.max + 128

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)
local storage = minetest.get_mod_storage()
local player_dbg = minetest.deserialize(storage:get_string("player_dbg") or "return {}") or {}

local function get_text(pos, bits)
	local bits = bits
	if bits == 0 then return "" end
	local y = pos.y
	if y >= min1 then
		y = y - min1
	elseif y >= min3 and y <= max3 then
		y = y - min3
	elseif y >= min2 and y <= max2 then
		y = y - min2
	end
	local biome_data = get_biome_data(pos)
	local biome_name = biome_data and get_biome_name(biome_data.biome) or "No biome"
	local text
	if bits == 1 then
		text = biome_name
	elseif bits == 2 then
		text = format("x:%.1f y:%.1f z:%.1f", pos.x, y, pos.z)
	elseif bits == 3 then
		text = format("%s x:%.1f y:%.1f z:%.1f", biome_name, pos.x, y, pos.z)
	end
	return text
end

local function info()
	for _, player in pairs(get_connected_players()) do
		local name = player:get_player_name()
		local pos = player:get_pos()
		local text = get_text(pos, player_dbg[name] or default_debug)
		local hud = huds[name]
		if not hud then
			local def = {
				hud_elem_type = "text",
				alignment     = {x = 1, y = -1},
				scale         = {x = 100, y = 100},
				position      = {x = 0.0073, y = 0.989},
				text          = text,
				style         = 5,
				["number"]    = 0xcccac0,
				z_index       = 0,
			}
			local def_bg = table.copy(def)
			def_bg.offset = {x = 2, y = 1}
			def_bg["number"] = 0
			def_bg.z_index = -1
			huds[name] = {
				player:hud_add(def),
				player:hud_add(def_bg),
				text,
			}
		elseif text ~= hud[3] then
			hud[3] = text
			player:hud_change(huds[name][1], "text", text)
			player:hud_change(huds[name][2], "text", text)
		end
	end
	after(refresh_interval, info)
end

minetest.register_on_authplayer(function(name, ip, is_success)
	if is_success then
		huds[name] = nil
	end
end)

minetest.register_chatcommand("debug",{
	description = S("Set debug bit mask: 0 = disable, 1 = biome name, 2 = coordinates, 3 = all"),
	func = function(name, params)
		local dbg = math.floor(tonumber(params) or default_debug)
		if dbg < 0 or dbg > 3 then
			minetest.chat_send_player(name, S("Error! Possible values are integer numbers from @1 to @2", 0, 3))
			return
		end
		if dbg == default_dbg then
			player_dbg[name] = nil
		else
			player_dbg[name] = dbg
		end
		minetest.chat_send_player(name, S("Debug bit mask set to @1", dbg))
	end
})

minetest.register_on_shutdown(function()
	storage:set_string("player_dbg", minetest.serialize(player_dbg))
end)

info()
