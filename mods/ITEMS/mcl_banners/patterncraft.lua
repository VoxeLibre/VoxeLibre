-- Pattern crafting. This file contains the code for crafting all the
-- emblazonings you can put on the banners. It's quite complicated;
-- normal 08/15 crafting won't work here.

-- Number of maximum lines in the descriptions for the banner layers.
-- To avoid huge tooltips.
local max_layer_lines = 6

-- Maximum number of layers which can be put on a banner by crafting.
local max_layers_crafting = 6

-- List of patterns with crafting rules
local d = "group:dye" -- dye
local e = "" -- empty slot (one of them must contain the banner)
local patterns = {
	["border"] = {
		name = "%s Bordure",
		{ d, d, d },
		{ d, e, d },
		{ d, d, d },
	},
	["bricks"] = {
		name = "%s Bricks",
		type = "shapeless",
		{ e, "mcl_core:brick_block", d },
	},
	["circle"] = {
		name = "%s Roundel",
		{ e, e, e },
		{ e, d, e },
		{ e, e, e },
	},
	["creeper"] = {
		name = "%s Creeper Charge",
		type = "shapeless",
		{ e, "mcl_heads:creeper", d },
	},
	["cross"] = {
		name = "%s Saltire",
		{ d, e, d },
		{ e, d, e },
		{ d, e, d },
	},
	["curly_border"] = {
		name = "%s Intented Bordure",
		type = "shapeless",
		{ e, "mcl_core:vine", d },
	},
	["diagonal_left"] = {
		name = "%s Inverted Per Bend",
		{ e, e, e },
		{ d, e, e },
		{ d, d, e },
	},
	["diagonal_right"] = {
		name = "%s Inverted Per Bend Sinister",
		{ e, e, e },
		{ e, e, d },
		{ e, d, d },
	},
	["diagonal_up_left"] = {
		name = "%s Per Bend",
		{ e, d, d },
		{ e, e, d },
		{ e, e, e },
	},
	["diagonal_up_right"] = {
		name = "%s Per Bend Sinister",
		{ d, d, e },
		{ d, e, e },
		{ e, e, e },
	},
	["flower"] = {
		name = "%s Flower Charge",
		type = "shapeless",
		{ e, "mcl_flowers:oxeye_daisy", d },
	},
	["gradient"] = {
		name = "%s Gradient",
		{ d, e, d },
		{ e, d, e },
		{ e, d, e },
	},
	["gradient_up"] = {
		name = "%s Base Gradient",
		{ e, d, e },
		{ e, d, e },
		{ d, e, d },
	},
	["half_horizontal_bottom"] = {
		name = "%s Inverted Per Fess",
		{ e, e, e },
		{ d, d, d },
		{ d, d, d },
	},
	["half_horizontal"] = {
		name = "%s Per Fess",
		{ d, d, d },
		{ d, d, d },
		{ e, e, e },
	},
	["half_vertical"] = {
		name = "%s Per Pale",
		{ d, d, e },
		{ d, d, e },
		{ d, d, e },
	},
	["half_vertical_right"] = {
		name = "%s Inverted Per Pale",
		{ e, d, d },
		{ e, d, d },
		{ e, d, d },
	},
	["thing"] = {
		-- Symbol used for the “Thing”: U+1F65D 🙝

		name = "%s Thing",
		type = "shapeless",
		-- TODO: Replace with enchanted golden apple
		{ e, "mcl_core:apple_gold", d },
	},
	["rhombus"] = {
		name = "%s Lozenge",
		{ e, d, e },
		{ d, e, d },
		{ e, d, e },
	},
	["skull"] = {
		name = "%s Skull Charge",
		type = "shapeless",
		{ e, "mcl_heads:wither_skeleton", d },
	},
	["small_stripes"] = {
		name = "%s Paly",
		{ d, e, d },
		{ d, e, d },
		{ e, e, e },
	},
	["square_bottom_left"] = {
		name = "%s Base Dexter Canton",
		{ e, e, e },
		{ e, e, e },
		{ d, e, e },
	},
	["square_bottom_right"] = {
		name = "%s Base Sinister Canton",
		{ e, e, e },
		{ e, e, e },
		{ e, e, d },
	},
	["square_top_left"] = {
		name = "%s Chief Dexter Canton",
		{ d, e, e },
		{ e, e, e },
		{ e, e, e },
	},
	["square_top_right"] = {
		name = "%s Chief Sinister Canton",
		{ e, e, d },
		{ e, e, e },
		{ e, e, e },
	},
	["straight_cross"] = {
		name = "%s Cross",
		{ e, d, e },
		{ d, d, d },
		{ e, d, e },
	},
	["stripe_bottom"] = {
		name = "%s Base",
		{ e, e, e },
		{ e, e, e },
		{ d, d, d },
	},
	["stripe_center"] = {
		name = "%s Fess",
		{ e, e, e },
		{ d, d, d },
		{ e, e, e },
	},
	["stripe_downleft"] = {
		name = "%s Bend Sinister",
		{ e, e, d },
		{ e, d, e },
		{ d, e, e },
	},
	["stripe_downright"] = {
		name = "%s Bend",
		{ d, e, e },
		{ e, d, e },
		{ e, e, d },
	},
	["stripe_left"] = {
		name = "%s Pale Dexter",
		{ d, e, e },
		{ d, e, e },
		{ d, e, e },
	},
	["stripe_middle"] = {
		name = "%s Pale",
		{ e, d, e },
		{ e, d, e },
		{ e, d, e },
	},
	["stripe_right"] = {
		name = "%s Pale Sinister",
		{ e, e, d },
		{ e, e, d },
		{ e, e, d },
	},
	["stripe_top"] = {
		name = "%s Chief",
		{ d, d, d },
		{ e, e, e },
		{ e, e, e },
	},
	["triangle_bottom"] = {
		name = "%s Chevron",
		{ e, e, e },
		{ e, d, e },
		{ d, e, d },
	},
	["triangle_top"] = {
		name = "%s Inverted Chevron",
		{ d, e, d },
		{ e, d, e },
		{ e, e, e },
	},
	["triangles_bottom"] = {
		name = "%s Base Indented",
		{ e, e, e },
		{ d, e, d },
		{ e, d, e },
	},
	["triangles_top"] = {
		name = "%s Chief Indented",
		{ e, d, e },
		{ d, e, d },
		{ e, e, e },
	},
}

-- Just a simple reverse-lookup table from dye itemstring to banner color ID
-- to avoid some pointless future iterations.
local dye_to_colorid_mapping = {}
for colorid, colortab in pairs(mcl_banners.colors) do
	dye_to_colorid_mapping[colortab[5]] = colorid
end

-- This is for handling all those complex pattern crafting recipes
local banner_pattern_craft = function(itemstack, player, old_craft_grid, craft_inv)
	if minetest.get_item_group(itemstack:get_name(), "banner") ~= 1 then
		return
	end

	local banner -- banner item
	local dye -- itemstring of the dye being used
	local banner_index -- crafting inventory index of the banner
	for i = 1, player:get_inventory():get_size("craft") do
		local itemname = old_craft_grid[i]:get_name()
		if minetest.get_item_group(itemname, "banner") == 1 then
			banner = old_craft_grid[i]
			banner_index = i
		-- Check if all dyes are equal
		elseif minetest.get_item_group(itemname, "dye") == 1 then
			if dye == nil then
				dye = itemname
			elseif itemname ~= dye then
				return ItemStack("")
			end
		end
	end
	if not banner then
		return ItemStack("")
	end

	-- Get old layers
	local ometa = banner:get_meta()
	local layers_raw = ometa:get_string("layers")
	local layers = minetest.deserialize(layers_raw)
	if type(layers) ~= "table" then
		layers = {}
	end
	-- Disallow crafting when a certain number of layers is reached or exceeded
	if #layers >= max_layers_crafting then
		return ItemStack("")
	end

	local matching_pattern
	local max_i = player:get_inventory():get_size("craft")
	-- Find the matching pattern
	for pattern_name, pattern in pairs(patterns) do
		-- Shaped / fixed
		if pattern.type == nil then
			local pattern_ok = true
			local inv_i = 1
			-- This complex code just iterates through the pattern slots one-by-one and compares them with the pattern
			for p=1, #pattern do
				local row = pattern[p]
				if inv_i > max_i then
					break
				end
				for r=1, #row do
					local itemname = old_craft_grid[inv_i]:get_name()
					local pitem = row[r]
					if (pitem == d and minetest.get_item_group(itemname, "dye") == 0) or (pitem == e and itemname ~= e and inv_i ~= banner_index) then
						pattern_ok = false
						break
					else
					end
					inv_i = inv_i + 1
				end
			end
			-- Everything matched! We found our pattern!
			if pattern_ok then
				matching_pattern = pattern_name
				break
			end

		elseif pattern.type == "shapeless" then
			local orig = pattern[1]
			local no_mismatches_so_far = true
			-- This code compares the craft grid with the required items
			for o=1, #orig do
				local item_ok = false
				for i=1, max_i do
					local itemname = old_craft_grid[i]:get_name()
					if (orig[o] == e) or -- Empty slot: Always wins
							(orig[o] ~= e and orig[o] == itemname) or -- non-empty slot: Exact item match required
							(orig[o] == d and minetest.get_item_group(itemname, "dye") == 1) then -- Dye slot
						item_ok = true
						break
					end
				end
				-- Sorry, item not found. :-(
				if not item_ok then
					no_mismatches_so_far = false
					break
				end
			end
			-- Ladies and Gentlemen, we have a winner!
			if no_mismatches_so_far then
				matching_pattern = pattern_name
				break
			end
		end

		if matching_pattern then
			break
		end
	end
	if not matching_pattern then
		return ItemStack("")
	end

	-- Add the new layer and update other metadata
	local color = dye_to_colorid_mapping[dye]
	table.insert(layers, {pattern=matching_pattern, color=color})

	local imeta = itemstack:get_meta()
	imeta:set_string("layers", minetest.serialize(layers))

	local odesc = itemstack:get_definition().description
	local description = mcl_banners.make_advanced_banner_description(odesc, layers)
	imeta:set_string("description", description)
	return itemstack
end

minetest.register_craft_predict(banner_pattern_craft)
minetest.register_on_craft(banner_pattern_craft)


-- Register crafting recipes for all the patterns
for pattern_name, pattern in pairs(patterns) do
	-- Shaped and fixed recipes
	if pattern.type == nil then
		for colorid, colortab in pairs(mcl_banners.colors) do
			local banner = "mcl_banners:banner_item_"..colortab[1]
			local bannered = false
			local recipe = {}
			for row_id=1, #pattern do
				local row = pattern[row_id]
				local newrow = {}
				for r=1, #row do
					if row[r] == e and not bannered then
						newrow[r] = banner
						bannered = true
					else
						newrow[r] = row[r]
					end
				end
				table.insert(recipe, newrow)
			end
			minetest.register_craft({
				output = banner,
				recipe = recipe,
			})
		end
	-- Shapeless recipes
	elseif pattern.type == "shapeless" then
		for colorid, colortab in pairs(mcl_banners.colors) do
			local banner = "mcl_banners:banner_item_"..colortab[1]
			local orig = pattern[1]
			local recipe = {}
			for r=1, #orig do
				if orig[r] == e then
					recipe[r] = banner
				else
					recipe[r] = orig[r]
				end
			end

			minetest.register_craft({
				type = "shapeless",
				output = banner,
				recipe = recipe,
			})
		end
	end
end

