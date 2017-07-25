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

local colors = {
	{ "red", "Red Bed", "mcl_wool:red" },
	{ "blue", "Blue Bed", "mcl_wool:blue" },
	{ "cyan", "Cyan Bed", "mcl_wool:cyan" },
	{ "grey", "Grey Bed", "mcl_wool:grey" },
	{ "silver", "Light Grey Bed", "mcl_wool:silver" },
	{ "black", "Black Bed", "mcl_wool:black" },
	{ "yellow", "Yellow Bed", "mcl_wool:yellow" },
	{ "green", "Green Bed", "mcl_wool:green" },
	{ "magenta", "Magenta Bed", "mcl_wool:magenta" },
	{ "orange", "Orange Bed", "mcl_wool:orange" },
	{ "purple", "Purple Bed", "mcl_wool:purple" },
	{ "brown", "Brown Bed", "mcl_wool:brown" },
	{ "pink", "Pink Bed", "mcl_wool:pink" },
	{ "lime", "Lime Bed", "mcl_wool:lime" },
	{ "light_blue", "Light Blue Bed", "mcl_wool:light_blue" },
	{ "white", "White Bed", "mcl_wool:white" },
}

for c=1, #colors do
	local colorid = colors[c][1]

	mcl_beds.register_bed("mcl_beds:bed_"..colorid, {
		description = colors[c][2],
		inventory_image = "mcl_beds_bed_"..colorid..".png",
		wield_image = "mcl_beds_bed_"..colorid..".png",
		tiles = {
			bottom = {
				"mcl_beds_bed_top_bottom_"..colorid..".png^[transformR90",
				"default_wood.png^mcl_beds_bed_bottom_bottom.png",
				"mcl_beds_bed_side_bottom_r_"..colorid..".png",
				"mcl_beds_bed_side_bottom_r_"..colorid..".png^[transformfx",
				"mcl_beds_bed_side_top_"..colorid..".png",
				"mcl_beds_bed_side_bottom_"..colorid..".png"
			},
			top = {
				"mcl_beds_bed_top_top_"..colorid..".png^[transformR90",
				"default_wood.png^mcl_beds_bed_bottom_top.png",
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
		-- Simplified collision box because Minetest acts weird if we use the nodebox one
		collisionbox = {
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
