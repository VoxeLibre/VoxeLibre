local vector = {
	new = function(x,y,z) return {x=x, y=y, z=z} end,
}
_G.vector = vector
local core = {}
_G.core = core
_G.minetest = core

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
end)
