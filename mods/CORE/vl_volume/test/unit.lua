package.path = package.path .. ";../../../tests/lib/?.lua"
--local mock = require("mock").luanti(_G)

local vl_volume

-- Mock to get this to load
-- TODO: Replace this with the one from automated testing branch once that PR is merged
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
	end,
	equals = function(a,b)
		return a.x == b.x and a.y == b.y and a.z == b.z
	end,
}
local mcl_util = {}
_G.mcl_util = mcl_util
_G.core = core
_G.minetest = core
_G.vector = vector
_G.PcgRandom = function() end
dofile("/usr/share/luanti/builtin/common/misc_helpers.lua")

-- Dependency
mock.load_mod("mcl_util", "../mcl_util")

describe('vl_volume',function()
	it('loads',function()
		mock.load_mod("vl_volume", "./")
		vl_volume = _G.vl_volume
	end)

	-- Basic behavior
	it('can create a volumes',function()
		vl_volume.create_volume(vector.new(-10,0,-10), vector.new(10,0,10), function(md1)
			md1:set_string("test", "1")
			md1:set_string("structure", "true")
		end)

		vl_volume.create_volume(vector.new(0,0,0), vector.new(10,0,10), function(md2)
			md2:set_string("test2", "2")
		end)

		vl_volume.create_volume(vector.new(12,0,12), vector.new(20,0,20),function(md3)
			md3:set_string("structure", "true")
		end)
	end)
	it('can query position data', function()
		local md = vl_volume.get_meta(vector.new(1,0,1))
		assert(md)
		assert(md:get_string("test") == "1")
		assert(md:get_string("test2") == "2")
	end)
	it('can query areas', function()
		vl_volume.get_area_meta(vector.new(8,0,8), vector.new(12,2,12),function(md1)
			assert(md1)
			assert(md1:get_string("structure") == "true")
		end)

		local md2 = vl_volume.get_area_meta(vector.new(11,0,11), vector.new(11,2,11))
		assert(md2)
		assert(md2:get_string("structure") ~= "true")
	end)

	-- Caching support
	it('will cache queries for better performance', function()
		local v = vector.new(1,0,0)
		local md1 = vl_volume.get_meta(v)
		local md2 = vl_volume.get_meta(v)
		assert(md1 == md2)
	end)
	it('will clear the cache when changes occur', function()
		local v = vector.new(1,0,0)

		local md1 = vl_volume.get_meta(v)
		vl_volume.create_volume(vector.new(-2,0,-2), vector.new(2,2,2))

		local md2 = vl_volume.get_meta(v)
		assert(md1 ~= md2)
	end)
end)
