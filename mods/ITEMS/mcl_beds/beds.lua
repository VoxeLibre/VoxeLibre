local S = minetest.get_translator("mcl_beds")
local mod_doc = minetest.get_modpath("doc")

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
	-- { ID, decription, wool, dye }
	{ "red", S("Red Bed"), "mcl_wool:red", "mcl_dye:red" },
	{ "blue", S("Blue Bed"), "mcl_wool:blue", "mcl_dye:blue" },
	{ "cyan", S("Cyan Bed"), "mcl_wool:cyan", "mcl_dye:cyan" },
	{ "grey", S("Grey Bed"), "mcl_wool:grey", "mcl_dye:dark_grey" },
	{ "silver", S("Light Grey Bed"), "mcl_wool:silver", "mcl_dye:grey" },
	{ "black", S("Black Bed"), "mcl_wool:black", "mcl_dye:black" },
	{ "yellow", S("Yellow Bed"), "mcl_wool:yellow", "mcl_dye:yellow" },
	{ "green", S("Green Bed"), "mcl_wool:green", "mcl_dye:dark_green" },
	{ "magenta", S("Magenta Bed"), "mcl_wool:magenta", "mcl_dye:magenta" },
	{ "orange", S("Orange Bed"), "mcl_wool:orange", "mcl_dye:orange" },
	{ "purple", S("Purple Bed"), "mcl_wool:purple", "mcl_dye:violet" },
	{ "brown", S("Brown Bed"), "mcl_wool:brown", "mcl_dye:brown" },
	{ "pink", S("Pink Bed"), "mcl_wool:pink", "mcl_dye:pink" },
	{ "lime", S("Lime Bed"), "mcl_wool:lime", "mcl_dye:green" },
	{ "light_blue", S("Light Blue Bed"), "mcl_wool:light_blue", "mcl_dye:lightblue" },
	{ "white", S("White Bed"), "mcl_wool:white", "mcl_dye:white" },
}
local canonical_color = "red"

for c=1, #colors do
	local colorid = colors[c][1]
	local is_canonical = colorid == canonical_color

	-- Recoloring recipe for white bed
	if minetest.get_modpath("mcl_dye") then
		minetest.register_craft({
			type = "shapeless",
			output = "mcl_beds:bed_"..colorid.."_bottom",
			recipe = { "mcl_beds:bed_white_bottom", colors[c][4] },
		})
	end

	-- Main bed recipe
	local main_recipe
	if minetest.get_modpath("mcl_wool") then
		main_recipe = {
			{colors[c][3], colors[c][3], colors[c][3]},
			{"group:wood", "group:wood", "group:wood"}
		}
	end

	local entry_name, create_entry
	if mod_doc then
		if is_canonical then
			entry_name = S("Bed")
		else
			create_entry = false
		end
	end
	-- Register bed
	mcl_beds.register_bed("mcl_beds:bed_"..colorid, {
		description = colors[c][2],
		_doc_items_entry_name = entry_name,
		_doc_items_create_entry = create_entry,
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
		recipe = main_recipe,
	})
	if mod_doc and not is_canonical then
		doc.add_entry_alias("nodes", "mcl_beds:bed_"..canonical_color.."_bottom", "nodes", "mcl_beds:bed_"..colorid.."_bottom")
		doc.add_entry_alias("nodes", "mcl_beds:bed_"..canonical_color.."_bottom", "nodes", "mcl_beds:bed_"..colorid.."_top")
	end

end

minetest.register_alias("beds:bed_bottom", "mcl_beds:bed_red_bottom")
minetest.register_alias("beds:bed_top", "mcl_beds:bed_red_top")
