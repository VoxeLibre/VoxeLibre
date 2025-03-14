local mcl_util = {}
_G.mcl_util = mcl_util

describe('mcl_util.make_fake_metadata',function()
	it('loads',function()
		dofile("./fake_metadata.lua")
	end)
	it('can create a fake metadata', function()
		local md = mcl_util.make_fake_metadata({
			table = {},
			on_save = function() end,
		})
	end)
	it('can create a read-only metadata', function()
		local data = {test = "2"}
		local md = mcl_util.make_fake_metadata({
			table = data,
			on_save = function() end,
			readonly = true,
		})

		md:set_string("test", "1")
		assert(data.test == "2")
	end)
end)
