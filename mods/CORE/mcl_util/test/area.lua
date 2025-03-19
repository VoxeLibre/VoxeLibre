package.path = package.path .. ";../../../tests/lib/?.lua"
local mock = require("mock").luanti(_G)

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
	describe('mcl_util.iterate_area', function()
		it('will return exactly one position if minp and maxp are equal', function()
			local n = 0
			for pos in mcl_util.iterate_area(vector.new(0,0,0), vector.new(0,0,0)) do
				n = n + 1
				assert(vector.equals(pos, vector.new(0,0,0)))
			end
			assert(n == 1)
		end)
		it('will return each position exactly once', function()
			local n = 0
			local seen = {}
			for pos in mcl_util.iterate_area(vector.new(0,0,0), vector.new(5,5,5)) do
				n = n + 1
				local s = string.format("%g,%g,%g", pos.x, pos.y, pos.z)
				assert(not seen[s])
				seen[s] = true
			end
			assert(n == 216)
		end)
	end)
end)
