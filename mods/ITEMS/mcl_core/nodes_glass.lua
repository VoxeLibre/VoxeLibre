-- Glass nodes
local S = minetest.get_translator(minetest.get_current_modname())
local mod_doc = minetest.get_modpath("doc")

minetest.register_node("mcl_core:glass", {
	description = S("Glass"),
	_doc_items_longdesc = S("A decorative and mostly transparent block."),
	drawtype = "glasslike_framed_optional",
	is_ground_content = false,
	tiles = {"default_glass.png", "default_glass_detail.png"},
	paramtype = "light",
	paramtype2 = "glasslikeliquidlevel",
	sunlight_propagates = true,
	stack_max = 64,
	groups = {handy=1, glass=1, building_block=1, material_glass=1},
	sounds = mcl_sounds.node_sound_glass_defaults(),
	drop = "",
	_mcl_blast_resistance = 0.3,
	_mcl_hardness = 0.3,
	_mcl_silk_touch_drop = true,
})

------------------------
-- Create Color Glass --
------------------------
local canonical_color = "yellow"
function mcl_core.add_stained_glass(desc, recipeitem, colorgroup, color)

	local longdesc, create_entry, entry_name
	if mod_doc then
		if color == canonical_color then
			longdesc = S("Stained glass is a decorative and mostly transparent block which comes in various different colors.")
			entry_name = S("Stained Glass")
		else
			create_entry = false
		end
	end
	minetest.register_node("mcl_core:glass_"..color, {
		description = desc,
		_doc_items_create_entry = create_entry,
		_doc_items_entry_name = entry_name,
		_doc_items_longdesc = longdesc,
		drawtype = "glasslike_framed_optional",
		is_ground_content = false,
		tiles = {"mcl_core_glass_"..color..".png", "mcl_core_glass_"..color.."_detail.png"},
		paramtype = "light",
		paramtype2 = "glasslikeliquidlevel",
		sunlight_propagates = true,
		use_texture_alpha = "blend",
		stack_max = 64,
		-- TODO: Add color to groups
		groups = {handy=1, glass=1, building_block=1, material_glass=1},
		sounds = mcl_sounds.node_sound_glass_defaults(),
		drop = "",
		_mcl_blast_resistance = 0.3,
		_mcl_hardness = 0.3,
		_mcl_silk_touch_drop = true,
	})

	minetest.register_craft({
		output = "mcl_core:glass_"..color.." 8",
		recipe = {
			{"mcl_core:glass","mcl_core:glass","mcl_core:glass"},
			{"mcl_core:glass",recipeitem,"mcl_core:glass"},
			{"mcl_core:glass","mcl_core:glass","mcl_core:glass"},
		}
	})

	if mod_doc and color ~= canonical_color then
		doc.add_entry_alias("nodes", "mcl_core:glass_"..canonical_color, "nodes", "mcl_core:glass_"..color)
	end

end

---- colored glass
mcl_core.add_stained_glass( S("Red Stained Glass"), "mcl_dye:red", "basecolor_red", "red")
mcl_core.add_stained_glass( S("Green Stained Glass"), "mcl_dye:dark_green", "unicolor_dark_green", "green")
mcl_core.add_stained_glass( S("Blue Stained Glass"), "mcl_dye:blue", "basecolor_blue", "blue")
mcl_core.add_stained_glass( S("Light Blue Stained Glass"), "mcl_dye:lightblue", "unicolor_light_blue", "light_blue")
mcl_core.add_stained_glass( S("Black Stained Glass"), "mcl_dye:black", "basecolor_black", "black")
mcl_core.add_stained_glass( S("White Stained Glass"), "mcl_dye:white", "basecolor_white", "white")
mcl_core.add_stained_glass( S("Yellow Stained Glass"), "mcl_dye:yellow", "basecolor_yellow", "yellow")
mcl_core.add_stained_glass( S("Brown Stained Glass"), "mcl_dye:brown", "unicolor_dark_orange", "brown")
mcl_core.add_stained_glass( S("Orange Stained Glass"), "mcl_dye:orange", "excolor_orange", "orange")
mcl_core.add_stained_glass( S("Pink Stained Glass"), "mcl_dye:pink", "unicolor_light_red", "pink")
mcl_core.add_stained_glass( S("Grey Stained Glass"), "mcl_dye:dark_grey", "unicolor_darkgrey", "gray")
mcl_core.add_stained_glass( S("Lime Stained Glass"), "mcl_dye:green", "basecolor_green", "lime")
mcl_core.add_stained_glass( S("Light Grey Stained Glass"), "mcl_dye:grey", "basecolor_grey", "silver")
mcl_core.add_stained_glass( S("Magenta Stained Glass"), "mcl_dye:magenta", "basecolor_magenta", "magenta")
mcl_core.add_stained_glass( S("Purple Stained Glass"), "mcl_dye:violet", "excolor_violet", "purple")
mcl_core.add_stained_glass( S("Cyan Stained Glass"), "mcl_dye:cyan", "basecolor_cyan", "cyan")
