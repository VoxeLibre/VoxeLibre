-- List of patterns with crafting rules

local d = "group:dye" -- dye
local e = "" -- empty slot (one of them must contain the banner)
local patterns = {
	["border"] = {
		{ d, d, d },
		{ d, e, d },
		{ d, d, d },
	},
	["bricks"] = {
		type = "shapeless",
		{ e, "mcl_core:brick_block", d },
	},
	["circle"] = {
		{ e, e, e },
		{ e, d, e },
		{ e, e, e },
	},
	["creeper"] = {
		type = "shapeless",
		{ e, "mcl_heads:creeper", d },
	},
	["cross"] = {
		{ d, e, d },
		{ e, d, e },
		{ d, e, d },
	},
	["curly_border"] = {
		type = "shapeless",
		{ e, "mcl_core:vine", d },
	},
	["diagonal_left"] = {
		{ e, e, e },
		{ d, e, e },
		{ d, d, e },
	},
	["diagonal_right"] = {
		{ e, e, e },
		{ e, e, d },
		{ e, d, d },
	},
	["diagonal_up_left"] = {
		{ e, d, d },
		{ e, e, d },
		{ e, e, e },
	},
	["diagonal_up_right"] = {
		{ d, d, e },
		{ d, e, e },
		{ e, e, e },
	},
	["flower"] = {
		type = "shapeless",
		{ e, "mcl_flowers:oxeye_daisy", d },
	},
	["gradient"] = {
		{ d, e, d },
		{ e, d, e },
		{ e, d, e },
	},
	["gradient_up"] = {
		{ e, d, e },
		{ e, d, e },
		{ d, e, d },
	},
	["half_horizontal_bottom"] = {
		{ e, e, e },
		{ d, d, d },
		{ d, d, d },
	},
	["half_horizontal"] = {
		{ d, d, d },
		{ d, d, d },
		{ e, e, e },
	},
	["half_vertical"] = {
		{ d, d, e },
		{ d, d, e },
		{ d, d, e },
	},
	["half_vertical_right"] = {
		{ e, d, d },
		{ e, d, d },
		{ e, d, d },
	},
	["thing"] = {
		type = "shapeless",
		-- TODO: Replace with enchanted golden apple
		{ e, "mcl_core:apple_gold", d },
	},
	["rhombus"] = {
		{ e, d, e },
		{ d, e, d },
		{ e, d, e },
	},
	["skull"] = {
		type = "shapeless",
		{ e, "mcl_heads:wither_skeleton", d },
	},
	["small_stripes"] = {
		{ d, e, d },
		{ d, e, d },
		{ e, e, e },
	},
	["square_bottom_left"] = {
		{ e, e, e },
		{ e, e, e },
		{ d, e, e },
	},
	["square_bottom_right"] = {
		{ e, e, e },
		{ e, e, e },
		{ e, e, d },
	},
	["square_top_left"] = {
		{ d, e, e },
		{ e, e, e },
		{ e, e, e },
	},
	["square_top_right"] = {
		{ e, e, d },
		{ e, e, e },
		{ e, e, e },
	},
	["straight_cross"] = {
		{ e, d, e },
		{ d, d, d },
		{ e, d, e },
	},
	["stripe_bottom"] = {
		{ e, e, e },
		{ e, e, e },
		{ d, d, d },
	},
	["stripe_center"] = {
		{ e, e, e },
		{ d, d, d },
		{ e, e, e },
	},
	["stripe_downleft"] = {
		{ e, e, d },
		{ e, d, e },
		{ d, e, e },
	},
	["stripe_downright"] = {
		{ d, e, e },
		{ e, d, e },
		{ e, e, d },
	},
	["stripe_left"] = {
		{ d, e, e },
		{ d, e, e },
		{ d, e, e },
	},
	["stripe_middle"] = {
		{ e, d, e },
		{ e, d, e },
		{ e, d, e },
	},
	["stripe_right"] = {
		{ e, e, d },
		{ e, e, d },
		{ e, e, d },
	},
	["stripe_top"] = {
		{ d, d, d },
		{ e, e, e },
		{ e, e, e },
	},
	["triangle_bottom"] = {
		{ e, e, e },
		{ e, d, e },
		{ d, e, d },
	},
	["triangles_bottom"] = {
		{ e, e, e },
		{ d, e, d },
		{ e, d, e },
	},
	["triangles_top"] = {
		{ e, d, e },
		{ d, e, d },
		{ e, e, e },
	},
	["triangle_top"] = {
		{ d, e, d },
		{ e, d, e },
		{ e, e, e },
	},
}

minetest.register_craft_predict(function(itemstack, player, old_craft_grid, craft_inv)
	if minetest.get_item_group(itemstack:get_name(), "banner") ~= 1 then
		return
	end

	local banner
	local dye
	local banner_index
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

	local imeta = itemstack:get_meta()

	imeta:set_string("description", "Emblazoned Banner")
	return itemstack
end)

-- This is for handling all those complex pattern crafting recipes
minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if minetest.get_item_group(itemstack:get_name(), "banner") ~= 1 then
		return
	end

	local banner, dye
	local banner_index
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
			-- TODO
		end

		if matching_pattern then
			break
		end
	end
	if not matching_pattern then
		return ItemStack("")
	end

	-- Add the new layer

	table.insert(layers, {pattern=matching_pattern, color="unicolor_yellow"})

	local imeta = itemstack:get_meta()
	imeta:set_string("layers", minetest.serialize(layers))

	imeta:set_string("description", "Emblazoned Banner ("..matching_pattern..")")
	return itemstack
end)

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

