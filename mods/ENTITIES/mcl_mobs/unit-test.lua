package.path = package.path .. ";../../../tests/lib/?.lua"
local mock = require("mock").luanti(_G)

local mcl_mobs = nil

describe('mcl_mobs', function()
	it('loads',function()
		-- Additional Mocks
		_G.mcl_util = {}
		_G.mcl_vars = {
			mapgen_limit = 32000
		}
		mock.current_modname = "mcl_mobs"
		mock.modpaths["mcl_mobs"] = "./"
		mock.modpaths["mcl_util"] = "../../CORE/mcl_util"
		mock.modpaths["vl_unit_testing"] = "true"

		dofile("./init.lua")
		mcl_mobs = _G.mcl_mobs
	end)
	it('has functional despawn_allowed check',function()
		local despawn_allowed = mcl_mobs.despawn_allowed

		assert(despawn_allowed({can_despawn=false}) == false, "despawn_allowed - can_despawn false failed")
		assert(despawn_allowed({can_despawn=true}) == true, "despawn_allowed - can_despawn true failed")

		assert(despawn_allowed({can_despawn=true, nametag=""}) == true, "despawn_allowed - blank nametag failed")
		assert(despawn_allowed({can_despawn=true, nametag=nil}) == true, "despawn_allowed - nil nametag failed")
		assert(despawn_allowed({can_despawn=true, nametag="bob"}) == false, "despawn_allowed - nametag failed")

		assert(despawn_allowed({can_despawn=true, state="attack"}) == false, "despawn_allowed - attack state failed")
		assert(despawn_allowed({can_despawn=true, following="blah"}) == false, "despawn_allowed - following state failed")

		assert(despawn_allowed({can_despawn=true, tamed=false}) == true, "despawn_allowed - not tamed")
		assert(despawn_allowed({can_despawn=true, tamed=true}) == false, "despawn_allowed - tamed")

		assert(despawn_allowed({can_despawn=true, persistent=true}) == false, "despawn_allowed - persistent")
		assert(despawn_allowed({can_despawn=true, persistent=false}) == true, "despawn_allowed - not persistent")
	end)
end)
