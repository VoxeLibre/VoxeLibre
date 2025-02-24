package.path = package.path .. ";../../../tests/lib/?.lua"
local mock = require("mock").luanti(_G)
mock.current_modname = "vl_block_update"
mock.modpaths["vl_block_update"] = "./"

describe('vl_block_update',function()
	it('loads',function()
		local vl_scheduler = dofile("./init.lua")
	end)
end)

