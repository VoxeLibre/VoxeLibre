local S = minetest.get_translator("mcl_lanterns")

mcl_lanterns.register_lantern("lantern", {
	description = S("Lantern"),
	texture = "mcl_lanterns_lantern.png",
	texture_inv = "mcl_lanterns_lantern_inv.png",
	light_level = 15,
})