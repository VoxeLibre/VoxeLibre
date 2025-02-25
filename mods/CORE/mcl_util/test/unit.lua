package.path = package.path .. ";../../../tests/lib/?.lua"
local mock = require("mock").luanti(_G)

local mcl_util = nil

describe('mcl_util', function()
	it('loads', function()
		-- Additional Mocks
		mock.current_modname = "mcl_util"
		mock.modpaths["mcl_util"] = "./"
		mock.modpaths["vl_unit_testing"] = true

		dofile("./init.lua")
		mcl_util = _G.mcl_util
	end)
	it('has roundN that works as expected',function()
		local roundN = mcl_util.roundN

		--tests for roundN
		local test_round1 = 15
		local test_round2 = 15.00199999999
		local test_round3 = 15.00111111
		local test_round4 = 15.00999999

		assert(roundN(test_round1, 2) == roundN(test_round1, 2))
		assert(roundN(test_round1, 2) == roundN(test_round2, 2))
		assert(roundN(test_round1, 2) == roundN(test_round3, 2))
		assert(roundN(test_round1, 2) ~= roundN(test_round4, 2))
	end)
	it('has close_enough that works as expected', function()
		local close_enough = mcl_util.close_enough

		-- tests for close_enough
		local test_cb = {-0.35, 0, -0.35, 0.35, 0.8, 0.35} --collisionboxes
		local test_cb_close = {-0.351213, 0, -0.35, 0.35, 0.8, 0.351212}
		local test_cb_diff = {-0.35, 0, -1.35, 0.35, 0.8, 0.35}

		local test_eh = 1.65 --eye height
		local test_eh_close = 1.65123123
		local test_eh_diff = 1.35

		local test_nt = {r = 225, b = 225, a = 225, g = 225} --nametag
		local test_nt_diff = {r = 225, b = 225, a = 0, g = 225}

		assert(close_enough(test_cb, test_cb_close))
		assert(not close_enough(test_cb, test_cb_diff))
		assert(close_enough(test_eh, test_eh_close))
		assert(not close_enough(test_eh, test_eh_diff))
		assert(not close_enough(test_nt, test_nt_diff)) --no floats involved here
	end)
	it('has properties_changed that works as expected', function()
		local props_changed = mcl_util.props_changed

		--tests for properties_changed
		local test_properties_set1 = {collisionbox = {-0.35, 0, -0.35, 0.35, 0.8, 0.35}, eye_height = 0.65,
			nametag_color = {r = 225, b = 225, a = 225, g = 225}}
		local test_properties_set2 = {collisionbox = {-0.35, 0, -0.35, 0.35, 0.8, 0.35}, eye_height = 1.35,
			nametag_color = {r = 225, b = 225, a = 225, g = 225}}

		local test_p1, _ = props_changed(test_properties_set1, test_properties_set1)
		local test_p2, _ = props_changed(test_properties_set1, test_properties_set2)

		assert(not test_p1)
		assert(test_p2)
	end)
end)
