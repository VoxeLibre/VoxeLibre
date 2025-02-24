local mock = {}
local posix = require('posix')

print("package.path="..package.path)

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
		registered_globalsteps = {
			function(dtime)
				mock.globalsteps = mock.globalsteps + 1
				mock.last_fake_globaltime_dtime = dtime
			end,
		},
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
	}

	-- Update the specified global environment to act as though the Luanti engine is present
	local old_G = _G
	_G = g
	g.core = {}
	g.dump = dump
	g.vector = {
		new = function() end
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
