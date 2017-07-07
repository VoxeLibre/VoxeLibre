minetest.register_node("mcl_core:glass", {
	description = "Glass",
	_doc_items_longdesc = "A decorational and mostly transparent block.",
	drawtype = "glasslike",
	is_ground_content = false,
	tiles = {"default_glass.png"},
	paramtype = "light",
	sunlight_propagates = true,
	stack_max = 64,
	groups = {handy=1, glass=1, building_block=1, material_glass=1},
	sounds = mcl_sounds.node_sound_glass_defaults(),
	drop = "",
	_mcl_blast_resistance = 1.5,
	_mcl_hardness = 0.3,
})

------------------------
-- Create Color Glass -- 
------------------------
function mcl_core.add_glass(desc, recipeitem, colorgroup, color)

	minetest.register_node("mcl_core:glass_"..color, {
		description = desc,
		_doc_items_longdesc = "Stained glass is a decorational and mostly transparent block which comes in various different colors.",
		drawtype = "glasslike",
		is_ground_content = false,
		tiles = {"xpanes_pane_glass_"..color..".png"},
		paramtype = "light",
		sunlight_propagates = "true",
		use_texture_alpha = true,
		stack_max = 64,
		-- TODO: Add color to groups
		groups = {handy=1, glass=1, building_block=1, material_glass=1},
		sounds = mcl_sounds.node_sound_glass_defaults(),
		drop = "",
		_mcl_blast_resistance = 1.5,
		_mcl_hardness = 0.3,
	})
	
	minetest.register_craft({
		output = 'mcl_core:glass_'..color..' 8',
		recipe = {
			{'mcl_core:glass','mcl_core:glass','mcl_core:glass'},
			{'mcl_core:glass',recipeitem,'mcl_core:glass'},
			{'mcl_core:glass','mcl_core:glass','mcl_core:glass'},
		}
	})
end

---- colored glass
mcl_core.add_glass( "Red Stained Glass", "mcl_dye:red", "basecolor_red", "red")
mcl_core.add_glass( "Green Stained Glass", "mcl_dye:dark_green", "unicolor_dark_green", "green")
mcl_core.add_glass( "Blue Stained Glass", "mcl_dye:blue", "basecolor_blue", "blue")
mcl_core.add_glass( "Light Blue Stained Glass", "mcl_dye:lightblue", "unicolor_light_blue", "light_blue")
mcl_core.add_glass( "Black Stained Glass", "mcl_dye:black", "basecolor_black", "black")
mcl_core.add_glass( "White Stained Glass", "mcl_dye:white", "basecolor_white", "white")
mcl_core.add_glass( "Yellow Stained Glass", "mcl_dye:yellow", "basecolor_yellow", "yellow")
mcl_core.add_glass( "Brown Stained Glass", "mcl_dye:brown", "unicolor_dark_orange", "brown")
mcl_core.add_glass( "Orange Stained Glass", "mcl_dye:orange", "excolor_orange", "orange")
mcl_core.add_glass( "Pink Stained Glass", "mcl_dye:pink", "unicolor_light_red", "pink")
mcl_core.add_glass( "Grey Stained Glass", "mcl_dye:dark_grey", "unicolor_darkgrey", "gray")
mcl_core.add_glass( "Lime Stained Glass", "mcl_dye:green", "basecolor_green", "lime")
mcl_core.add_glass( "Light Grey Stained Glass", "mcl_dye:grey", "basecolor_grey", "silver")
mcl_core.add_glass( "Magenta Stained Glass", "mcl_dye:magenta", "basecolor_magenta", "magenta")
mcl_core.add_glass( "Purple Stained Glass", "mcl_dye:violet", "excolor_violet", "purple")
mcl_core.add_glass( "Cyan Stained Glass", "mcl_dye:cyan", "basecolor_cyan", "cyan")

