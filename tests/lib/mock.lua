local mock = {}
local posix = require('posix')
local os = require("os")
local LUANTI_PATH = os.getenv("LUANTI_PATH") or "/usr/share/luanti"

--print("package.path="..package.path)

function mock.luanti(g)
	local mock
	mock = {
		on_mods_loaded = {},
		globalsteps = 0,
		last_fake_globalstep_dtime = 0,
		time_offset = 0,
		current_modname = nil,
		modpaths = {},
		settings = {},
		mod_storage = {},
		registered_globalsteps = {
			function(dtime)
				mock.globalsteps = mock.globalsteps + 1
				mock.last_fake_globaltime_dtime = dtime
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
		call_globalsteps = function(dtime)
			local callbacks = mock.registered_globalsteps
			for i = 1,#callbacks do
				callbacks[i](dtime)
			end
		end,
	}

	function mock:fastforward(amount)
		self.time_offset = self.time_offset + amount
	end

	local luanti_core = {
		registered_globalsteps = mock.registered_globalsteps,
		registered_nodes = {},
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
			table.insert(mock.on_mods_loaded, func)
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
		get_mod_storage = function()
			local storage = mock.mod_storage[mock.current_modname] or {}
			mock.mod_storage[mock.current_modname] = storage

			return {
				get_keys = function()
					local keys = {}
					for k,_ in pairs(storage) do
						keys[#keys+1] = k
					end
					return keys
				end,
				set_string = function(k,v)
					storage[tostring(k)] = tostring(v)
				end,
			}
		end,
		serialize = function(value)
			return ""
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
