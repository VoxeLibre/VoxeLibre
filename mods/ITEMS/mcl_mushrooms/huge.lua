local template = {
	groups = {handy=1,axey=1, huge_mushroom = 1, building_block = 1, not_in_creative_inventory = 1, material_wood=1 },
	sounds = mcl_sounds.node_sound_wood_defaults(),
	is_ground_content = true,
	_mcl_blast_resistance = 1,
	_mcl_hardness = 0.2,
}

local red = table.copy(template)
red.drop = {
	items = {
		{ items = {'mcl_mushrooms:mushroom_red 1'}, rarity = 2 },
		{ items = {'mcl_mushrooms:mushroom_red 1'}, rarity = 2 },
	}
}

local brown= table.copy(template)
brown.drop = {
	items = {
		{ items = {'mcl_mushrooms:mushroom_brown 1'}, rarity = 2 },
		{ items = {'mcl_mushrooms:mushroom_brown 1'}, rarity = 2 },
	}
}

local register_mushroom = function(color, template, d_cap_top, d_cap_side, d_cap_corner, d_stem, d_pores, d_cap_all, d_stem_all, doc_items_entry_name, doc_items_longdesc)

	-- DV (Minecraft dava value) 14: Cap texture on all sides
	local full = table.copy(template)
	full.description = d_cap_all
	full._doc_items_entry_name = doc_items_entry_name
	full._doc_items_longdesc = doc_items_longdesc
	full.tiles = { "mcl_mushrooms_mushroom_block_skin_"..color..".png" }
	minetest.register_node("mcl_mushrooms:"..color.."_mushroom_block_cap_full", full)

	-- DV 0: Pores on all sides
	local pores_full = table.copy(template)
	pores_full.description = d_pores
	pores_full._doc_items_create_entry = false
	pores_full.tiles = { "mcl_mushrooms_mushroom_block_inside.png" }
	minetest.register_node("mcl_mushrooms:"..color.."_mushroom_block_pores_full", pores_full)

	-- DV 15: Stem texture on all sides
	local stem_full = table.copy(template)
	stem_full.description = d_stem_all
	stem_full._doc_items_create_entry = false
	stem_full.tiles = { "mcl_mushrooms_mushroom_block_skin_stem.png" }
	minetest.register_node("mcl_mushrooms:"..color.."_mushroom_block_stem_full", stem_full)

	-- DV 10: Stem
	local stem = table.copy(template)
	stem.description = d_stem
	stem._doc_items_create_entry = false
	stem.tiles = { "mcl_mushrooms_mushroom_block_inside.png", "mcl_mushrooms_mushroom_block_inside.png", "mcl_mushrooms_mushroom_block_skin_stem.png" }
	minetest.register_node("mcl_mushrooms:"..color.."_mushroom_block_stem", stem)

	-- DV 1, DV 3, DV 7, DV 9: Cap corner. Cap texture on top and two sides in a corner formation
	local cap_corner = table.copy(template)
	cap_corner.description = d_cap_corner
	cap_corner._doc_items_create_entry = false
	cap_corner.paramtype2 = "facedir"
	cap_corner.tiles = { "mcl_mushrooms_mushroom_block_skin_"..color..".png", "mcl_mushrooms_mushroom_block_inside.png", "mcl_mushrooms_mushroom_block_skin_"..color..".png", "mcl_mushrooms_mushroom_block_inside.png", "mcl_mushrooms_mushroom_block_inside.png", "mcl_mushrooms_mushroom_block_skin_"..color..".png" }
	minetest.register_node("mcl_mushrooms:"..color.."_mushroom_block_cap_corner", cap_corner)

	-- DV 5: Cap texture on top
	local cap_top = table.copy(template)
	cap_top.description = d_cap_top
	cap_top._doc_items_create_entry = false
	cap_top.tiles = { "mcl_mushrooms_mushroom_block_skin_"..color..".png", "mcl_mushrooms_mushroom_block_inside.png" }
	minetest.register_node("mcl_mushrooms:"..color.."_mushroom_block_cap_top", cap_top)

	-- DV 2, DV 4, DV 6, DV 8: Cap texture on top and one side
	local cap_side = table.copy(template)
	cap_side.description = d_cap_side
	cap_side._doc_items_create_entry = false
	cap_side.paramtype2 = "facedir"
	cap_side.tiles = { "mcl_mushrooms_mushroom_block_skin_"..color..".png", "mcl_mushrooms_mushroom_block_inside.png", "mcl_mushrooms_mushroom_block_inside.png", "mcl_mushrooms_mushroom_block_inside.png", "mcl_mushrooms_mushroom_block_inside.png", "mcl_mushrooms_mushroom_block_skin_"..color..".png" }
	minetest.register_node("mcl_mushrooms:"..color.."_mushroom_block_cap_side", cap_side)

end

local longdesc_red = "Huge red mushroom blocks are the plant parts of huge red mushrooms. This includes caps, pores and stems of huge red mushrooms; and these blocks come in some variants."
local entry_name_red = "Huge Red Mushroom Block"

register_mushroom("red", red, "Huge Red Mushroom Cap Top", "Huge Red Mushroom Cap Side", "Huge Red Mushroom Cap Corner", "Huge Red Mushroom Stem", "Huge Red Mushroom Pores", "Huge Red Mushroom All-Faces Cap", "Huge Red Mushroom All-Faces Stem", entry_name_red, longdesc_red)


local longdesc_brown = "Huge brown mushroom blocks are the plant parts of huge brown mushrooms. This includes caps, pores and stems of huge brown mushrooms; and these blocks come in some variants."
local entry_name_brown = "Huge Brown Mushroom Block"

register_mushroom("brown", brown, "Huge Brown Mushroom Cap Top", "Huge Brown Mushroom Cap Side", "Huge Brown Mushroom Cap Corner", "Huge Brown Mushroom Stem", "Huge Brown Mushroom Pores", "Huge Brown Mushroom All-Faces Cap", "Huge Brown Mushroom All-Faces Stem", entry_name_brown, longdesc_brown)

minetest.register_craft({
	type = "fuel",
	recipe = "group:huge_mushroom",
	burntime = 15,
})
