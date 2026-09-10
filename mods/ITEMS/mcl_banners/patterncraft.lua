-- Banner patterns are applied with the loom. Crafting is only used to copy an
-- existing design to a blank banner of the same base color.

local function get_layers(stack)
	local layers = core.deserialize(stack:get_meta():get_string("layers"))
	return type(layers) == "table" and layers or {}
end

local function copy_banner_pattern(itemstack, old_craft_grid, craft_inv, craft_predict)
	if core.get_item_group(itemstack:get_name(), "banner") == 0 then return end

	local banners = {}
	for index, stack in ipairs(old_craft_grid) do
		if not stack:is_empty() then
			if core.get_item_group(stack:get_name(), "banner") == 0 then return end
			table.insert(banners, { stack = stack, index = index, layers = get_layers(stack) })
		end
	end
	if #banners ~= 2 then return end

	local source
	if #banners[1].layers > 0 and #banners[2].layers == 0 then
		source = banners[1]
	elseif #banners[2].layers > 0 and #banners[1].layers == 0 then
		source = banners[2]
	else
		return ItemStack("")
	end

	local layers, changed = mcl_banners.migrate_pattern_layers(source.layers)
	local layers_raw = changed and core.serialize(layers) or source.stack:get_meta():get_string("layers")
	local meta = itemstack:get_meta()
	meta:set_string("layers", layers_raw)
	meta:set_string("description", mcl_banners.make_advanced_banner_description(
		itemstack:get_definition().description, layers))

	if not craft_predict then
		if changed then
			local source_meta = source.stack:get_meta()
			source_meta:set_string("layers", layers_raw)
			if source_meta:get_string("name") == "" then
				source_meta:set_string("description", mcl_banners.make_advanced_banner_description(
					source.stack:get_definition().description, layers))
			end
		end
		-- Restore the source so copying only consumes the blank banner.
		craft_inv:set_stack("craft", source.index, source.stack)
	end
	return itemstack
end

core.register_craft_predict(function(itemstack, _, old_craft_grid, craft_inv)
	return copy_banner_pattern(itemstack, old_craft_grid, craft_inv, true)
end)

core.register_on_craft(function(itemstack, _, old_craft_grid, craft_inv)
	return copy_banner_pattern(itemstack, old_craft_grid, craft_inv, false)
end)

for _, colortab in pairs(mcl_banners.colors) do
	local banner = "mcl_banners:banner_item_" .. colortab[1]
	core.register_craft({
		type = "shapeless",
		output = banner,
		recipe = { banner, banner },
	})
end
