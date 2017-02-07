minetest.register_craftitem("mesecons_materials:slimeball", {
	image = "jeija_glue.png",
	on_place_on_ground = minetest.craftitem_place_item,
    	description="Slimeball",
	groups = { craftitem = 1 },
})

minetest.register_craft({
	output = 'mesecons_materials:slimeball 9',
	recipe = {{"mcl_core:slimeblock"}},
})

minetest.register_craft({
	output = "mcl_core:slimeblock",
	recipe = {{"mesecons_materials:slimeball","mesecons_materials:slimeball","mesecons_materials:slimeball",},
		{"mesecons_materials:slimeball","mesecons_materials:slimeball","mesecons_materials:slimeball",},
		{"mesecons_materials:slimeball","mesecons_materials:slimeball","mesecons_materials:slimeball",}},
})

minetest.register_alias("mesecons_materials:glue", "mesecons_materials:slimeball")
