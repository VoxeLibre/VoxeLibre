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

mcl_beds.register_bed("mcl_beds:bed_red", {
	description = "Bed",
	inventory_image = "mcl_beds_bed_red.png",
	wield_image = "mcl_beds_bed_red.png",
	tiles = {
		bottom = {
			"mcl_beds_bed_top_bottom_red.png",
			"mcl_beds_bed_bottom_bottom.png",
			"mcl_beds_bed_side_bottom_r_red.png",
			"mcl_beds_bed_side_bottom_r_red.png^[transformfx",
			"mcl_beds_bed_side_top_red.png",
			"mcl_beds_bed_side_bottom_red.png"
		},
		top = {
			"mcl_beds_bed_top_top_red.png",
			"mcl_beds_bed_bottom_top.png",
			"mcl_beds_bed_side_top_r_red.png",
			"mcl_beds_bed_side_top_r_red.png^[transformfx",
			"mcl_beds_bed_side_top_red.png",
			"mcl_beds_bed_side_bottom_red.png"
		}
	},
	nodebox = nodebox,
	selectionbox = {
		bottom = {-0.5, -0.5, -0.5, 0.5, 0.06, 0.5},
		top = {-0.5, -0.5, -0.5, 0.5, 0.06, 0.5},
	},
	recipe = {
		{"group:wool", "group:wool", "group:wool"},
		{"group:wood", "group:wood", "group:wood"}
	},
})

minetest.register_alias("beds:bed_bottom", "mcl_beds:bed_red_bottom")
minetest.register_alias("beds:bed_top", "mcl_beds:bed_red_top")
