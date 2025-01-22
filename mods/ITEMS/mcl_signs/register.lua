local S = ...

local woods = {
	oak = {
		def = {description = S("Oak Sign")},
		color = "#917056",
		wood = "mcl_core:wood",
	},
	dark_oak = {
		def = {description = S("Dark Oak Sign")},
		color = "#625048",
		wood = "mcl_core:darkwood",
	},
	acacia = {
		def = {description = S("Acacia Sign")},
		color = "#965638",
		wood = "mcl_core:acaciawood",
	},
	birch = {
		def = {description = S("Birch Sign")},
		color = "#AA907A",
		wood = "mcl_core:birchwood",
	},
	jungle = {
		def = {description = S("Jungle Sign")},
		color = "#845A43",
		wood = "mcl_core:junglewood",
	},
	spruce = {
		def = {description = S("Spruce Sign")},
		color = "#604335",
		wood = "mcl_core:sprucewood",
	},
}

if core.get_modpath("mcl_mangrove") then
	woods.mangrove = {
		def = {description = S("Mangrove Sign")},
		color = "#8E3731",
		wood = "mcl_mangrove:mangrove_wood",
	}
end

if core.get_modpath("mcl_crimson") then
	woods.crimson = {
		def = {description = S("Crimson Hyphae Sign")},
		color = "#810000",
		wood = "mcl_crimson:crimson_hyphae_wood",
	}
	woods.warped = {
		def = {description = S("Warped Hyphae Sign")},
		color = "#0E4C4C",
		wood = "mcl_crimson:warped_hyphae_wood",
	}
end

for name, tbl in pairs(woods) do
	mcl_signs.register_sign(name, tbl.color, tbl.def)
	core.register_craft({
		output = "mcl_signs:wall_sign_"..name.." 3",
		recipe = {
			{tbl.wood, tbl.wood, tbl.wood},
			{tbl.wood, tbl.wood, tbl.wood},
			{"", "mcl_core:stick", ""}
		}
	})
end
