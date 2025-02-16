-- Pumpkin
vl_biomes.register_decoration({
	biomes = {"ExtremeHills", "ExtremeHillsM", "ExtremeHills+", "Taiga", "MegaTaiga", "MegaSpruceTaiga", "Plains", "SunflowerPlains", "Swampland", "MangroveSwamp"},
	decoration = "mcl_farming:pumpkin",
	param2 = 0,
	param2_max = 3,
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	place_on = {"group:grass_block_no_snow"},
	noise_params = {
		offset = -0.016,
		scale = 0.01332,
		spread = vector.new(125, 125, 125),
		seed = 666,
		octaves = 6,
		persist = 0.666
	},
})
