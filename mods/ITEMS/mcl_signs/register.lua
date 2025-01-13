local S = ...

local woods = {
	oak = {
		_sign = {
			[1] = "#917056",
			[2] = {description = S("Oak Sign")},
		}
	},
	dark_oak = {
		_sign = {
			[1] = "#625048",
			[2] = {description = S("Dark Oak Sign")},
		}
	},
	acacia = {
		_sign = {
			[1] = "#965638",
			[2] = {description = S("Acacia Sign")},
		}
	},
	birch = {
		_sign = {
			[1] = "#AA907A",
			[2] = {description = S("Birch Sign")},
		}
	},
	jungle = {
		_sign = {
			[1] = "#845A43",
			[2] = {description = S("Jungle Sign")},
		}
	},
	spruce = {
		_sign = {
			[1] = "#604335",
			[2] = {description = S("Spruce Sign")},
		}
	},
	-- Non-core woods. Left here for historic reasons (to not disturb i18n)
	mangrove = {
		_sign = {
			[1] = "#8E3731",
			[2] = {description = S("Mangrove Sign")},
		}
	},
	--[[crimson = {
		_sign = {
			[2] = {description = S("Crimson Hyphae Sign")},
			[1] = "#810000",
		}
	},
	warped = {
		_sign = {
			[2] = {description = S("Warped Hyphae Sign")},
			[1] = "#0E4C4C",
		}
	},]]
}

vl_trees.register_on_woods_added(function(name, def)
	if not def._sign then return end

	local pname = def.planks
	mcl_signs.register_sign(name, unpack(def._sign))
	core.register_craft({
		output = "mcl_signs:wall_sign_"..name.." 3",
		recipe = {
			{pname, pname, pname},
			{pname, pname, pname},
			{"", "mcl_core:stick", ""}
		}
	})
end, woods)
