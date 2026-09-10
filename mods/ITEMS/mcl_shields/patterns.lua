-- A malformed value must never be mistaken for an empty design. Unknown symbolic
-- names/colors are still valid data and survive until their defining mod is present.
---@param raw string
---@return mcl_banners.PatternLayer[]?
function mcl_shields.deserialize_pattern_layers(raw)
	local layers = core.deserialize(raw, true)
	if type(layers) ~= "table" then return end

	local count = 0
	for index, layer in pairs(layers) do
		if type(index) ~= "number" or index < 1 or index % 1 ~= 0
			or type(layer) ~= "table" or type(layer.pattern) ~= "string" or type(layer.color) ~= "string" then
			return
		end
		count = count + 1
	end
	for i = 1, count do
		if layers[i] == nil then return end
	end
	return layers
end

--- Read authoritative structured data, or migrate recognized layers from a legacy expression.
--- Discard unsupported legacy layers and remove the old texture metadata on update.
---@return mcl_banners.PatternLayer[]?
---@return boolean changed
function mcl_shields.migrate_pattern_layers(itemstack)
	local meta = itemstack:get_meta()
	local raw = meta:get_string("layers")
	local texture = meta:get_string("mcl_shields:shield_custom_pattern_texture")
	if raw ~= "" then
		-- Structured data takes precedence, even when malformed. Never display or
		-- retain the obsolete texture as a fallback for it.
		if texture ~= "" then
			meta:set_string("mcl_shields:shield_custom_pattern_texture", "")
		end
		local layers = mcl_shields.deserialize_pattern_layers(raw)
		if not layers then return nil, texture ~= "" end

		local migrated, changed = mcl_banners.migrate_pattern_layers(layers)
		if changed then
			meta:set_string("layers", core.serialize(migrated))
		end
		return migrated, changed or texture ~= ""
	end

	if texture ~= "" then
		local layers = mcl_shields.import_legacy_pattern_layers(texture, itemstack:get_definition()._shield_colorid)
		meta:set_string("layers", core.serialize(layers))
		meta:set_string("mcl_shields:shield_custom_pattern_texture", "")
		return layers, true
	end
	return nil, false
end

-- Use the regular tooltip path for the item name, enchantments and other snippets.
tt.register_priority_snippet(function(itemstring, _, itemstack)
	if not itemstack or core.get_item_group(itemstring, "shield") == 0 then return end

	local layers = mcl_shields.migrate_pattern_layers(itemstack)
	if layers and #layers > 0 then
		local description = mcl_banners.make_advanced_banner_description("", layers)
		-- tt supplies the newline; the banner description already colors its layers.
		return description:sub(2), false
	end
end)

---@param layers mcl_banners.PatternLayer[]?
---@return string
function mcl_shields.make_texture(itemstack, layers)
	local def = itemstack:get_definition()
	if layers then
		return mcl_banners.make_shield_texture(def._shield_colorid, layers)
	end

	if def._shield_color then
		return "mcl_shield_base_nopattern.png^(mcl_shield_pattern_base.png^[colorize:" .. def._shield_color .. ")"
	end
	return "mcl_shield_base_nopattern.png"
end
