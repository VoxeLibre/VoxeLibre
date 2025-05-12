mcl_info = {}
local format, pairs,ipairs,table,vector,minetest,mcl_info,tonumber,tostring = string.format,pairs,ipairs,table,vector,minetest,mcl_info,tonumber,tostring

local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local storage = minetest.get_mod_storage()
local player_dbg = {}

local refresh_interval      = .63
local huds                  = {}
local default_debug         = 0

local function check_setting(s)
	return s
end

--return player setting, set it to 2nd argument if supplied
local function player_setting(p,s)
	local name = p:get_player_name()
	if check_setting(s) then
		p:get_meta():set_string("mcl_info_show",s)
		player_dbg[name] = tonumber(s)
	end
	if not player_dbg[name] then
		local r = p:get_meta():get_string("mcl_info_show")
		if r == nil or r == "" then r = 0 end
		player_dbg[name] = tonumber(r)
	end
	return player_dbg[name]
end

mcl_info.registered_debug_fields = {}
local fields_keyset = {}
function mcl_info.register_debug_field(name,def)
	table.insert(fields_keyset,name)
	mcl_info.registered_debug_fields[name]=def
end

local function nodeinfo(pos)
	local n = minetest.get_node_or_nil(pos)
	if not n then return "" end
	local l = minetest.get_node_light(pos)
	local ld = minetest.get_node_light(pos,0.5)
	local r = n.name .. " p1:"..n.param1.." p2:"..n.param2
	if l and ld then
		r = r .. " Light: "..l.."/"..ld
	end
	return r
end

local function get_text(player, bits)
	local pos = vector.offset(player:get_pos(),0,0.5,0)
	local bits = bits
	if bits == -1 then return "" end

	local r = ""
	for _,key in ipairs(fields_keyset) do
		local def = mcl_info.registered_debug_fields[key]
		if def then
			if def.level == nil or def.level <= bits then
				r = r ..key..": "..tostring(def.func(player,pos)).."\n"
			end
		else
			r = r ..key..": <Unknown Field>\n"
		end
	end
	return r
end

local function info()
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local s = player_setting(player)
		local pos = player:get_pos()
		local text = get_text(player, s)
		local hud = huds[name]
		if s and not hud then
			local def = {
				[mcl_vars.hud_type_field] = "text",
				alignment     = {x = 1, y = -1},
				scale         = {x = 100, y = 100},
				position      = {x = 0.0073, y = 0.889},
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
	minetest.after(refresh_interval, info)
end
minetest.after(0,info)

minetest.register_on_leaveplayer(function(p)
	local name = p:get_player_name()
	huds[name] = nil
	player_dbg[name] = nil
end)

minetest.register_chatcommand("debug",{
	description = S("Set debug level: 0 = disable, 1 = player coords, 2 = coordinates, 3 = biome name, 4 = all"),
	params = S("<level>"),
	privs = { debug = true },
	func = function(name, params)
		local player = minetest.get_player_by_name(name)
		if params == "" then return true, S("Debug level is @1", player_setting(player)) end
		local dbg = math.floor(tonumber(params) or default_debug)
		if dbg < 0 or dbg > 4 then
			minetest.chat_send_player(name, S("Error! Possible values are integer numbers from @1 to @2", 0, 4))
			return false, S("Debug level is @1", player_setting(player))
		end
		return true, S("Debug level set to @1", player_setting(player,dbg))
	end
})

-- register normal user access to debug levels 1 and 0.
minetest.register_chatcommand("whereami", {
	description = S("Show location: 0 = disable, 1 = coordinates"),
	params = S("<level>"),
	-- privs = { },
	func = function(name, params)
		local player = minetest.get_player_by_name(name)
		if params == "" then
			return true, S("Show location is set to: @1", player_setting(player))
		end
		local loc_lev = math.floor(tonumber(params) or default_debug)
		if loc_lev < 0 or loc_lev > 1 then
			minetest.chat_send_player(name, S("Error! Possible values are integer numbers from @1 to @2", 0, 1))
			return false, S("Show location is set to: @1", player_setting(player))
		end
		return true, S("Show location set to @1", player_setting(player, loc_lev))
	end
})

mcl_info.register_debug_field("Node feet",{
	level = 4,
	func = function(pl,pos)
		return nodeinfo(pos)
	end
})
mcl_info.register_debug_field("Node below",{
	level = 4,
	func = function(pl,pos)
		return nodeinfo(vector.offset(pos,0,-1,0))
	end
})
mcl_info.register_debug_field("Biome",{
	level = 3,
	func = function(pl,pos)
		local biome_data = minetest.get_biome_data(pos)
		local biome = biome_data and minetest.get_biome_name(biome_data.biome) or "No biome"
		if biome_data then
			return format("%s (%s), Humidity: %.1f, Temperature: %.1f",biome, biome_data.biome, biome_data.humidity, biome_data.heat)
		end
		return "No biome"
	end
})

mcl_info.register_debug_field("Coords", {
	level = 2,
	func = function(pl, pos)
		return format("x:%.1f y:%.1f z:%.1f", pos.x, pos.y, pos.z)
	end
})

-- TODO: remove when we can get the name from dimension data
local DIMENSION_NAMES = {
	overworld = "Overworld",
	underworld = "Underworld",
	fringe = "Fringe",
	void = "Void",
}

mcl_info.register_debug_field("Location", {
	level = 1,
	func = function(_, pos)
		local dim = vl_worlds.dimension_at_pos(pos)
		local name = dim and (DIMENSION_NAMES[dim.id] or dim.id) or "Unknown"

		-- TODO: get name from dimension data
		-- TODO: can we use the translation API for this?
		return format("%s: x:%.1f y:%.1f z:%.1f", name, pos.x, pos.y, pos.z)
	end
})
