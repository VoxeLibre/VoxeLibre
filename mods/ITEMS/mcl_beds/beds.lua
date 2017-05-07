-- 3D bed

local nodebox = {
	bottom = {
		{-0.5, -5/16, -0.5, 0.5, 0.06, 0.5},
		{-0.5, -0.5, -0.5, -5/16, -5/16, -5/16},
		{0.5, -0.5, -0.5, 5/16, -5/16, -5/16},
	},
	top = {
		{-0.5, -5/16, -0.5, 0.5, 0.06, 0.5},
		{-0.5, -0.5, 0.5, -5/16, -5/16, 5/16},
		{0.5, -0.5, 0.5, 5/16, -5/16, 5/16},
	},
}

-- TODO: All 16 bed colors
local colors = {
	{ "red", "Bed", "group:wool" },
}

for c=1, #colors do
	local colorid = colors[c][1]

	mcl_beds.register_bed("mcl_beds:bed_"..colorid, {
		description = colors[c][2],
		inventory_image = "mcl_beds_bed_"..colorid..".png",
		wield_image = "mcl_beds_bed_"..colorid..".png",
		tiles = {
			bottom = {
				"mcl_beds_bed_top_bottom_"..colorid..".png",
				"mcl_beds_bed_bottom_bottom.png",
				"mcl_beds_bed_side_bottom_r_"..colorid..".png",
				"mcl_beds_bed_side_bottom_r_"..colorid..".png^[transformfx",
				"mcl_beds_bed_side_top_"..colorid..".png",
				"mcl_beds_bed_side_bottom_"..colorid..".png"
			},
			top = {
				"mcl_beds_bed_top_top_"..colorid..".png",
				"mcl_beds_bed_bottom_top.png",
				"mcl_beds_bed_side_top_r_"..colorid..".png",
				"mcl_beds_bed_side_top_r_"..colorid..".png^[transformfx",
				"mcl_beds_bed_side_top_"..colorid..".png",
				"mcl_beds_bed_side_bottom_"..colorid..".png"
			}
		},
		nodebox = nodebox,
		selectionbox = {
			bottom = {-0.5, -0.5, -0.5, 0.5, 0.06, 0.5},
			top = {-0.5, -0.5, -0.5, 0.5, 0.06, 0.5},
		},
		recipe = {
			{colors[c][3], colors[c][3], colors[c][3]},
			{"group:wood", "group:wood", "group:wood"}
		},
	})
end

minetest.register_alias("beds:bed_bottom", "mcl_beds:bed_red_bottom")
minetest.register_alias("beds:bed_top", "mcl_beds:bed_red_top")
