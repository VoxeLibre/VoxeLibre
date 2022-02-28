local refresh_interval      = .63
local huds                  = {}
local after                 = minetest.after
local get_connected_players = minetest.get_connected_players
local get_biome_name        = minetest.get_biome_name
local get_biome_data        = minetest.get_biome_data
local format                = string.format

local min1, min2, min3 = mcl_mapgen.overworld.min, mcl_mapgen.end_.min, mcl_mapgen.nether.min
local max1, max2, max3 = mcl_mapgen.overworld.max, mcl_mapgen.end_.max, mcl_mapgen.nether.max + 128

local function get_text(pos)
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
	local text = format("%s x:%.1f y:%.1f z:%.1f", biome_name, pos.x, y, pos.z)
	return text
end

local function info()
	for _, player in pairs(get_connected_players()) do
		local name = player:get_player_name()
		local pos = player:get_pos()
		local text = get_text(pos)
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

info()
