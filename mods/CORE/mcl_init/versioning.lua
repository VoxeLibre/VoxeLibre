local S = core.get_translator(core.get_current_modname())

--- Try to read gametime *before* initialization. Primarily to detect when an old world is loaded.
local start_time = tonumber(Settings(core.get_worldpath() .. DIR_DELIM .. "env_meta.txt"):get("game_time")) or 0

--- Get a version number for map generation.
local function parse_version(str)
	local parts = {}
	while str ~= "" do
		local m, tail = str:match("^(%d+)%.?(.*)$")
		if m then
			parts[#parts + 1] = tonumber(m)
			if tonumber(tail) then
				parts[#parts + 1] = tonumber(tail)
				break
			end
			str = tail
		else
			parts[#parts + 1] = str
			break
		end
	end
	return parts
end

-- test is the version v1 is larger or equal v2
function minimum_version(ver1, ver2)
	if not ver1 or not ver2 then return false end
	for i,v1 in ipairs(ver1) do
		local v2 = ver2[i] or 0 -- treat missing values as zero
		if type(v1) ~= "number" then return false end -- strings are prerelease versions
		assert(type(v2) == "number") -- version tests may only test release versions
		if v1 > v2 then return true end
		if v1 < v2 then return false end
	end
	return #ver1 >= #ver2
end
-- comparing version numbers is ugly
-- TODO: move tests into a separate unit test
assert(minimum_version({0, 88}, {0, 88}))
assert(minimum_version({0, 88}, {0, 88, 1}) == false)
assert(minimum_version({0, 88}, {0, 89}) == false)
assert(minimum_version({0, 88, 1}, {0, 88}))
assert(minimum_version({0, 88, 1}, {0, 88, 1}))
assert(minimum_version({0, 88, 1}, {0, 89}) == false)
assert(minimum_version({0, 89}, {0, 88}))
assert(minimum_version({0, 89}, {0, 88, 1}))
assert(minimum_version({0, 89}, {0, 89}))
assert(minimum_version(parse_version("0.89.0-SNAPSHOT"), {0, 88}))
assert(minimum_version(parse_version("0.89.0-SNAPSHOT"), {0, 89}) == false)

function format_version(ver, or_later)
	local v = {}
	for i, c in ipairs(ver) do
		c = tostring(c)
		if i > 1 and c:sub(1,1) ~= "-" then v[#v+1] = "." end
		v[#v+1] = c
	end
	-- append "or later" if the VL version is 0.87, as we cannot differentiate older
	if or_later and #v == 2 and v[1] == 0 and v[1] == 87 then v[#v+1] = " or later" end
	return table.concat(v)
end

-- Current game version
local game_version_str = Settings(core.get_game_info().path .. DIR_DELIM .. "game.conf"):get("version")
-- Active mapgen version; the user may activate this to use updates on new chunks
local map_version = parse_version(core.get_mapgen_setting("vl_world_version") or "")
-- Initial mapgen version; the user should not modify this, controls which upgrade LBMs are used
local map_initial_version = parse_version(core.get_mapgen_setting("vl_world_initial_version") or "")
if #map_version == 0 then
	if start_time == 0 then
		if game_version_str then
			core.set_mapgen_setting("vl_world_version", game_version_str, true)
			map_version = parse_version(game_version_str)
		end
	end
	if #map_version == 0 then -- old world, assume "0.87 or earlier"
		core.log("warning", "Could not obtain a game version. Fallback to 0.87.")
		core.set_mapgen_setting("vl_world_version", "0.87", true)
		map_version = {0, 87}
	end
end
if #map_initial_version == 0 then
	core.set_mapgen_setting("vl_world_initial_version", format_version(map_version), true)
	map_initial_version = table.copy(map_version)
end

-- Initial mapgen version; the user should not modify this, controls which upgrade LBMs are used
local luanti_initial_version = parse_version(core.get_mapgen_setting("vl_world_initial_luanti_version") or "")
if #luanti_initial_version == 0 then
	if start_time == 0 then
		local luanti_version = core.get_version().string
		core.set_mapgen_setting("vl_world_initial_luanti_version", luanti_version, true)
		luanti_initial_version = parse_version(luanti_version)
	else -- old world, assume Luanti 5.11 or earlier unless the engine is even older
		local luanti_version = core.get_version().string
		if not minimum_version(parse_version(luanti_version), {5,12}) then luanti_version = "5.11" end
		core.set_mapgen_setting("vl_world_initial_luanti_version", luanti_version, true)
		luanti_initial_version = parse_version(luanti_version)
	end
end

-- Export version information
mcl_vars.parse_version = parse_version
mcl_vars.minimum_version = minimum_version
mcl_vars.format_version = format_version
mcl_vars.game_version_str = game_version_str
mcl_vars.map_version = map_version
mcl_vars.map_initial_version = map_initial_version
mcl_vars.luanti_initial_version = luanti_initial_version
mcl_vars.start_time = start_time
core.log("action", "VoxeLibre mapgen version = "..format_version(map_version, true).." initial version = "..format_version(map_initial_version, true))
core.log("action", "World created with Luanti version = "..format_version(luanti_initial_version))

core.register_chatcommand("ver", {
	description = S("Display the game version."),
	func = function(name, params)
		local game_info = core.get_game_info and core.get_game_info()
		if not game_info then return true end
		local game_name = game_info.title ~= "" and game_info.title or "unknown"
		core.chat_send_player(name, S("Version: @1 @2", game_name, mcl_vars.game_version_str))
		core.chat_send_player(name, S("Map generator active version: @1", format_version(mcl_vars.map_version, true)))
		return true
	end
})

