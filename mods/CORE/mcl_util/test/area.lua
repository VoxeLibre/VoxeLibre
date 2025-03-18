local modname
local modpaths = {}
local mock = {
	load_mod = function(p_modname, path)
		modname = p_modname
		modpaths[p_modname] = path
		dofile(path..DIR_DELIM.."init.lua")
	end
}
local core = {
	get_current_modname = function()
		return modname
	end,
	get_modpath = function(mod)
		return modpaths[mod]
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
	offset = function(a,x,y,z)
		return vector.new(a.x + x, a.y + y, a.z + z)
	end,
}
_G.core = core
_G.vector = vector
_G.minetest = core
_G.DIR_DELIM = "/"
_G.Settings = function()
	return {
		get = function() return "" end
	}
end

mock.load_mod("mcl_init", "../mcl_init")

describe('mcl_util/area.lua', function()
	it('loads', function()
		_G.mcl_util = {}
		dofile("./area.lua")
	end)
	describe('mcl_util.area_overlaps',function()
		it('works',function()
			assert(mcl_util.area_overlaps(vector.new(0,0,0), vector.new(2,2,2), vector.new(3,3,3), vector.new(4,4,4)) == false)
			assert(mcl_util.area_overlaps(vector.new(0,0,0), vector.new(2,2,2), vector.new(2,2,2), vector.new(4,4,4)) == true)
			assert(mcl_util.area_overlaps(vector.new(0,0,0), vector.new(2,2,2), vector.new(2,2,3), vector.new(4,4,4)) == false)
		end)
	end)
	describe('mcl_util.chunk_to_area',function()
		it("doesn't overlay neighboring chunk areas",function()
			local a0,a1 = mcl_util.chunk_to_area(vector.new(0,0,0))
			local b0,b1 = mcl_util.chunk_to_area(vector.new(1,0,0))
			assert(not mcl_util.area_overlaps(a0,a1, b0,b1))
		end)
	end)
	describe('mcl_util.intersect_area', function()
		it("returns nil if the areas don't intersect", function()
			assert(mcl_util.intersect_area(vector.new(0,0,0), vector.new(3,3,3), vector.new(4,4,4), vector.new(4,4,4)) == nil)
		end)
		it("returns a correct intersection for areas that overlap", function()
			local minp,maxp
			minp,maxp = mcl_util.intersect_area(vector.new(0,0,0), vector.new(3,3,3), vector.new(0,0,0), vector.new(4,4,4))
			assert(vector.equals(minp, vector.new(0,0,0)))
			assert(vector.equals(maxp, vector.new(3,3,3)))

			minp,maxp = mcl_util.intersect_area(vector.new(0,0,0), vector.new(3,3,3), vector.new(0,0,0), vector.new(0,0,0))
			assert(vector.equals(minp, vector.new(0,0,0)))
			assert(vector.equals(maxp, vector.new(0,0,0)))
		end)
	end)
end)
