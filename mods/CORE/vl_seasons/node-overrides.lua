core.override_item("mcl_core:snowblock", {
	groups = {oxidizable = 1,},
    _mcl_oxidized_seasonal_variant = "mcl_core:dirt_with_grass",
    _mcl_oxidized_season_disallowed = {"winter"},
})
core.override_item("mcl_core:dirt_with_grass", {
	groups = {oxidizable = 1,},
    _mcl_oxidized_seasonal_variant = "mcl_core:snowblock",
    _mcl_oxidized_season_disallowed = {"spring", "summer", "fall"},
})


core.override_item("mcl_core:ice", {
	groups = {oxidizable = 1,},
    _mcl_oxidized_seasonal_variant = "mcl_core:water_source",
    _mcl_oxidized_season_disallowed = {"winter"},
})
core.override_item("mcl_core:water_source", {
	groups = {oxidizable = 1,}, 
   _mcl_oxidized_seasonal_variant = "mcl_core:ice",
    _mcl_oxidized_season_disallowed = {"spring", "summer","fall"},
})
