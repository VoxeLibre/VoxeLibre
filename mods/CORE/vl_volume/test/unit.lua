package.path = package.path .. ";../../../tests/lib/?.lua"
--local mock = require("mock").luanti(_G)

local vl_volume

-- Mock to get this to load, replace with the one from automated testing branch
local modname
local modpaths = {}
_G.DIR_DELIM = "/"
_G.bit = require('bitop.funcs')
local mock = {
	load_mod = function(p_modname, path)
		modname = p_modname
		modpaths[p_modname] = path
		dofile(path..DIR_DELIM.."init.lua")
	end
}
local storage = {}
local core = {
	get_current_modname = function()
		return modname
	end,
	get_modpath = function(mod)
		return modpaths[mod]
	end,
	get_mod_storage = function()
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
	settings = {
		get_bool = function() return false end,
		get = function() return "" end,
	},
	serialize = function(value)
		return ""
	end,
}
local vector = {
	new = function(x,y,z)
		return {x=x, y=y, z=z}
	end,
	copy = function(b)
		return {x = b.x, y = b.y, z = b.z}
	end
}
local mcl_util = {}
_G.mcl_util = mcl_util
_G.core = core
_G.minetest = core
_G.vector = vector
_G.PcgRandom = function() end

-- Dependency
mock.load_mod("mcl_util", "../mcl_util")

describe('vl_volume',function()
	it('loads',function()
		mock.load_mod("vl_volume", "./")
		vl_volume = _G.vl_volume
	end)
	it('can create a volumes',function()
		local md1 = vl_volume.create_volume(vector.new(-10,0,-10), vector.new(10,0,10))
		md1:set_string("test", "1")

		local md2 = vl_volume.create_volume(vector.new(0,0,0), vector.new(10,0,10))
		md2:set_string("test2", "2")
	end)
	it('can query position data', function()
		local md = vl_volume.get_meta(vector.new(1,0,1))
		assert(md)
		assert(md:get_string("test") == "1")
		assert(md:get_string("test2") == "2")
	end)
end)
