local mock = {}
local posix = require('posix')

print("package.path="..package.path)

function mock.luanti(g)
	local mock = {
		on_mods_loaded = {},
		globalsteps = 0,
		last_fake_globalstep_dtime = 0,
		time_offset = 0,
		current_modname = nil,
		modpaths = {},
	}

	function mock:fastforward(amount)
		self.time_offset = self.time_offset + amount
	end

	local luanti_core = {
		registered_globalsteps = {
			function(dtime)
				mock.globalsteps = mock.globalsteps + 1
				mock.last_fake_globaltime_dtime = dtime
			end,
		},
		get_current_modname = function()
			return mock.current_modname
		end,
		get_modpath = function(modname)
			return mock.modpaths[modname]
		end,
		register_on_mods_loaded = function(func)
			table.insert(mock.on_mods_loaded, func)
		end,
		get_us_time() = function()
			local sec, nsec = posix.clock_gettime(0)
			return sec * 1e6 + nsec // 1000 + mock.time_offset
		end,
	}

	-- Update the specified global environment to act as though the Luanti engine is present
	local old_G = _G
	_G = g
	g.core = {}
	g.dump = dump
	require("misc_helpers")
	_G = old_G

	g.core = luanti_core
	g.minetest = luanti_core
	g.bit = require('bitop.funcs')
	g.loadstring = loadstring or load
	g.unpack = table.unpack
	g.dump = dump
	g.math.round = function(x) return math.floor(x + 0.5) end

	-- Interface to mock luanti engine
	return {
	}
end

return mock
