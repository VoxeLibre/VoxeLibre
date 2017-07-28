local patterns = {
	"border",
	"bricks",
	"circle",
	"creeper",
	"cross",
	"curly_border",
	"diagonal_left",
	"diagonal_right",
	"diagonal_up_left",
	"diagonal_up_right",
	"flower",	
	"gradient",
	"gradient_up",
	"half_horizontal_bottom",
	"half_horizontal",
	"half_vertical",
	"half_vertical_right",
	"thing",
	"rhombus",
	"skull",
	"small_stripes",
	"square_bottom_left",
	"square_bottom_right",
	"square_top_left",
	"square_top_right",
	"straight_cross",
	"stripe_bottom",
	"stripe_center",
	"stripe_downleft",
	"stripe_downright",
	"stripe_left",
	"stripe_middle",
	"stripe_right",
	"stripe_top",
	"triangle_bottom",
	"triangles_bottom",
	"triangles_top",
	"triangle_top",
}

minetest.register_craft_predict(function(itemstack, player, old_craft_grid, craft_inv)
	if minetest.get_item_group(itemstack:get_name(), "banner") ~= 1 then
		return
	end

	local original
	local index
	for i = 1, player:get_inventory():get_size("craft") do
		if minetest.get_item_group(old_craft_grid[i]:get_name(), "banner") == 1 then
			original = old_craft_grid[i]
			index = i
		end
	end
	if not original then
		return
	end

	local imeta = itemstack:get_meta()

	imeta:set_string("description", "Emblazoned Banner")
	return itemstack
end)


minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if minetest.get_item_group(itemstack:get_name(), "banner") ~= 1 then
		return
	end

	local original
	local index
	for i = 1, player:get_inventory():get_size("craft") do
		local itemname = old_craft_grid[i]:get_name()
		if minetest.get_item_group(itemname, "banner") == 1 then
			original = old_craft_grid[i]
			index = i
		end
	end
	if not original then
		return
	end

	local ometa = original:get_meta()
	local layers_raw = ometa:get_string("layers")
	local layers = minetest.deserialize(layers_raw)
	if type(layers) ~= "table" then
		layers = {}
	end

	table.insert(layers, {pattern="circle", color = "unicolor_yellow"})

	local imeta = itemstack:get_meta()
	imeta:set_string("layers", minetest.serialize(layers))

	imeta:set_string("description", "Emblazoned Banner")
	return itemstack
end)


minetest.register_craft({
	recipe = {
		{ "", "", "" },
		{ "", "mcl_banners:banner_item_red", "" },
		{ "mcl_dye:yellow", "mcl_dye:yellow", "mcl_dye:yellow" },
	},
	output = "mcl_banners:banner_item_red",
})

minetest.register_craft({
	recipe = {
		{ "mcl_dye:yellow", "mcl_dye:yellow", "mcl_dye:yellow" },
		{ "", "mcl_banners:banner_item_red", "" },
		{ "", "", "" },
	},
	output = "mcl_banners:banner_item_red",
})

minetest.register_craft({
	recipe = {
		{ "mcl_dye:yellow", "", "" },
		{ "mcl_dye:yellow", "mcl_banners:banner_item_red", "" },
		{ "mcl_dye:yellow", "", "" },
	},
	output = "mcl_banners:banner_item_red",
})

minetest.register_craft({
	recipe = {
		{ "", "mcl_dye:yellow", "" },
		{ "", "mcl_dye:yellow", "mcl_banners:banner_item_red", },
		{ "", "mcl_dye:yellow", "" },
	},
	output = "mcl_banners:banner_item_red",
})

minetest.register_craft({
	recipe = {
		{ "", "", "mcl_dye:yellow", },
		{ "", "mcl_banners:banner_item_red", "mcl_dye:yellow", },
		{ "", "", "mcl_dye:yellow" },
	},
	output = "mcl_banners:banner_item_red",
})


