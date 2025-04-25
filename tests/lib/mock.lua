local mock = {}
local posix = require('posix')
local os = require("os")
local LUANTI_PATH = os.getenv("LUANTI_PATH") or "/usr/share/luanti"

--print("package.path="..package.path)

function mock.luanti(g)
	local mock
	local luanti_core
	local storage_internal = {}
	local storage = {
		get_int = function(self, key, default)
			key = tostring(key)
			return tonumber(storage_internal[key] or default or 0)
		end,
		get_string = function(self, key, default)
			key = tostring(key)
			return tostring(storage_internal[key] or default or "")
		end,
		set_int = function(self, key, value)
			key = tostring(key)
			storage_internal[key] = tostring(value)
		end,
		set_string = function(self, key, value)
			key = tostring(key)
			storage_internal[key] = tostring(value)
		end,
		get_keys = function(self)
			local keys = {}
			for k,_ in pairs(storage_internal) do
				keys[#keys + 1] = k
			end
			return keys
		end,
	}
	mock = {
		registered_on_mods_loaded = {},
		globalsteps = 0,
		last_fake_globalstep_dtime = 0,
		time_offset = 0,
		current_modname = nil,
		modpaths = {},
		settings = {},
		mod_storage = {},
		log = {},
		registered_globalsteps = {
			function(dtime)
				mock.globalsteps = mock.globalsteps + 1
				mock.last_fake_globalstep_dtime = dtime
			end,
		},
		load_mod = function(name, path)
			local old_modname = mock.current_modname
			mock.current_modname = name
			mock.modpaths[name] = path
			dofile(path..DIR_DELIM.."init.lua")
			mock.current_modname = old_modname
		end,
		fastforward = function(dtime)
			mock.time_offset = mock.time_offset + dtime
		end,
		on_mods_loaded = function()
			local callbacks = mock.registered_on_mods_loaded
			for i = 1,#callbacks do
				callbacks[i]()
			end
		end,
		call_globalsteps = function(dtime)
			local callbacks = luanti_core.registered_globalsteps
			for i = 1,#callbacks do
				callbacks[i](dtime)
			end
		end,
		storage = storage,
	}

	function mock.fastforward(amount)
		mock.time_offset = mock.time_offset + amount
	end

	luanti_core = {
		registered_globalsteps = mock.registered_globalsteps,
		registered_nodes = {},
		log = function(class, msg)
			if not msg then
				msg = class
				class = "Server"
			end
			table.insert(mock.log, {class,msg})
			print("["..class.."] "..msg)
		end,
		settings = {
			get_bool = function(key)
				return mock.settings[key] == "true"
			end,
			get = function(key)
				return mock.settings[key] or ""
			end,
		},
		registered_aliases = {},
		get_current_modname = function()
			return mock.current_modname
		end,
		get_translator = function()
			return function(s,...)
				return s
			end
		end,
		get_modpath = function(modname)
			return mock.modpaths[modname]
		end,
		register_on_mods_loaded = function(func)
			table.insert(mock.registered_on_mods_loaded, func)
		end,
		register_globalstep = function(callback)
			table.insert(mock.registered_globalsteps, callback)
		end,
		register_on_leaveplayer = function()
		end,
		register_chatcommand = function()
		end,
		register_on_shutdown = function()
		end,
		register_on_dieplayer = function()
		end,
		register_craftitem = function()
		end,
		register_alias = function()
		end,
		get_us_time = function()
			local sec, nsec = posix.clock_gettime(0)
			return sec * 1e6 + math.floor(nsec / 1000) + mock.time_offset
		end,
		get_mapgen_setting = function() return "" end,
		set_mapgen_setting = function() end,
		log = function() end,
		get_worldpath = function() return "" end,
		get_game_info = function() return {
			path = "",
		} end,
		features = {},
		nodedef_default = {},
		craftitemdef_default = {},
		global_exists = function(name) return not not rawget(_G,name) end,
		serialize = function(value)
			return ""
		end,
		get_mod_storage = function()
			return mock.storage
		end,
		hash_node_position = function(pos)
			return (pos.z + 0x8000) * 0x100000000 + (pos.y + 0x8000) * 0x10000 + (pos.x + 0x8000)
		end,
		register_lbm = function()
		end,
	}

	-- Update the specified global environment to act as though the Luanti engine is present
	local old_G = _G
	_G = g
	g.core = {}
	g.dump = dump
	local vector_metatable = {}
	g.vector = {
		new = function(x,y,z)
			local res = {x=x, y=y, z=z}
			setmetatable(res, vector_metatable)
			return res
		end,
		copy = function(b)
			return vector.new(b.x, b.y, b.z)
		end,
		equals = function(a,b)
			return a.x == b.x and a.y == b.y and a.z == b.z
		end,
		offset = function(a,x,y,z)
			return vector.new(a.x + x, a.y + y, a.z + z)
		end,
		zero = function()
			return {x=0, y=0, z=0}
		end,
	}
	vector_metatable.__index = g.vector
	dofile(LUANTI_PATH.."/builtin/common/misc_helpers.lua")
	_G = old_G

	g.Settings = function()
		return {
			get = function() return "" end
		}
	end

	g.core = luanti_core
	g.minetest = luanti_core
	g.bit = require('bit')
	g.loadstring = loadstring or load
	g.unpack = table.unpack
	g.dump = dump
	g.math.round = function(x) return math.floor(x + 0.5) end
	g.PcgRandom = function() end
	g.DIR_DELIM = "/"
	g.vl_tuning = {
		setting = function() end
	}

	-- Interface to mock luanti engine
	return mock
end

return mock
