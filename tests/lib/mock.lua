local mock = {}
local posix = require('posix')

print("package.path="..package.path)

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
		log = {},
		registered_globalsteps = {
			function(dtime)
				mock.globalsteps = mock.globalsteps + 1
				mock.last_fake_globalstep_dtime = dtime
			end,
		},
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
		register_lbm = function()
		end,
		get_us_time = function()
			local sec, nsec = posix.clock_gettime(0)
			return sec * 1e6 + math.floor(nsec / 1000) + mock.time_offset
		end,
		get_mod_storage = function()
			return mock.storage
		end,
		hash_node_position = function(pos)
			return (pos.z + 0x8000) * 0x100000000 + (pos.y + 0x8000) * 0x10000 + (pos.x + 0x8000)
		end,
	}

	-- Update the specified global environment to act as though the Luanti engine is present
	local old_G = _G
	_G = g
	g.core = {}
	g.dump = dump
	g.vector = {
		new = function(x,y,z)
			return {x=x, y=y, z=z}
		end,
		zero = function()
			return {x=0, y=0, z=0}
		end,
	}
	require("misc_helpers")
	_G = old_G

	g.core = luanti_core
	g.minetest = luanti_core
	g.bit = require('bitop.funcs')
	g.loadstring = loadstring or load
	g.unpack = table.unpack
	g.dump = dump
	g.math.round = function(x) return math.floor(x + 0.5) end
	g.PcgRandom = function() end

	-- Interface to mock luanti engine
	return mock
end

return mock
