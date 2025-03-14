local mcl_util = {}
_G.mcl_util = mcl_util

describe('mcl_util.make_fake_metadata',function()
	it('loads',function()
		dofile("./fake_metadata.lua")
	end)
	it('can create a fake metadata that acts like a MetaDataRef', function()
		local md = mcl_util.make_fake_metadata({
			table = {},
			on_save = function() end,
		})
		assert(md)

		md:set_string("test", "1")
		assert(md:get_string("test") == "1")
		assert(md:get_string("does not exist") == "")
	end)
	it('can create a read-only metadata', function()
		local data = {test = "2"}
		local md = mcl_util.make_fake_metadata({
			table = data,
			readonly = true,
		})

		assert(md)
		md:set_string("test", "1")
		assert(data.test == "2")
	end)
end)
