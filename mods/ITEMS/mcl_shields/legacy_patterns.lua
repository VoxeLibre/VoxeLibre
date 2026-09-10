-- Decode only the texture grammar written by the old banner-on-shield recipe.
-- Unknown layers are discarded; saved texture expressions are never used for display.
local base = "mcl_shield_base_nopattern.png^mcl_shield_pattern_base.png"
local layer_prefix = "((" .. base .. "^[colorize:"
local mask_separator = ":225)^[mask:"
local base_texture = "(" .. base .. "^[mask:" .. base .. ")"

--- Mask expressions mapped to ordered concrete pattern names; false marks ambiguity and nil means unknown.
---@alias mcl_shields.LegacyMaskLookup table<string, string[]|false|nil>

--- Lowercase hex colors mapped to dye IDs
---@alias mcl_shields.LegacyColorLookup table<string, string|nil>

---@type mcl_shields.LegacyMaskLookup
local legacy_masks = {}
---@type mcl_shields.LegacyColorLookup
local legacy_colors = {}
---@type table<string, string>
local legacy_base_layers = {}

-- Texture modifiers escape their arguments once per nesting level. A separator
-- inside a group or behind a backslash does not end a top-level layer term.
---@param texture string
---@return string[]? terms Top-level terms, or nil for unbalanced groups, dangling escapes or empty terms.
local function split_terms(texture)
	local terms, depth, start, index = {}, 0, 1, 1
	while index <= #texture do
		local char = texture:sub(index, index)
		if char == "\\" then
			if index == #texture then return end
			index = index + 1
		elseif char == "(" then
			depth = depth + 1
		elseif char == ")" then
			depth = depth - 1
			if depth < 0 then return end
		elseif char == "^" and depth == 0 then
			if index == start then return end
			table.insert(terms, texture:sub(start, index - 1))
			start = index + 1
		end
		index = index + 1
	end
	if depth ~= 0 or start > #texture then return end
	table.insert(terms, texture:sub(start))
	return terms
end

---@param mask string
---@return string? texture Unescaped mask, or nil if its escaping is unsupported or invalid.
local function unescape_mask(mask)
	local result, index = {}, 1
	while index <= #mask do
		local char = mask:sub(index, index)
		if char == "\\" then
			index = index + 1
			char = mask:sub(index, index)
			if char ~= "\\" and char ~= "^" and char ~= ":" then return end
		elseif char == "^" or char == ":" then
			return -- An unescaped modifier is not part of this mask operand.
		end
		table.insert(result, char)
		index = index + 1
	end
	return table.concat(result)
end

---@param a string[]
---@param b string[]
---@return boolean equal Whether both arrays contain the same names in the same order.
local function same_names(a, b)
	if #a ~= #b then return false end
	for i, name in ipairs(a) do
		if name ~= b[i] then return false end
	end
	return true
end

---@param masks mcl_shields.LegacyMaskLookup Lookup to update; conflicting interpretations become false.
---@param mask string Unescaped mask filename or texture expression.
---@param names string[] Ordered concrete pattern names represented by the mask.
---@return nil
local function add_mask_lookup(masks, mask, names)
	local previous = masks[mask]
	if previous == false then return end

	if previous and not same_names(previous, names) then
		masks[mask] = false
	else
		masks[mask] = names
	end
end

-- Registrations happen during mod initialization. Build the import tables once,
-- after dependent mods have also registered their patterns and migrations.
core.register_on_mods_loaded(function()
	for colorid, color in pairs(mcl_banners.colors) do
		local hex = color[4]:lower()
		legacy_colors[hex] = colorid
		legacy_base_layers[colorid] = layer_prefix .. hex .. mask_separator .. "mcl_shield_pattern_base.png)"
	end

	for _, pattern in ipairs(mcl_banners.registered_patterns) do
		add_mask_lookup(legacy_masks, pattern.shield_texture, { pattern.name })
		add_mask_lookup(legacy_masks, "mcl_shield_pattern_" .. pattern.name .. ".png", { pattern.name })
	end
	for name, replacements in pairs(mcl_banners.registered_pattern_migrations) do
		add_mask_lookup(legacy_masks, "mcl_shield_pattern_" .. name .. ".png", replacements)
		local current = {}
		local historical = {}
		for _, replacement in ipairs(replacements) do
			table.insert(current, mcl_banners.registered_patterns[replacement].shield_texture)
			table.insert(historical, "mcl_shield_pattern_" .. replacement .. ".png")
		end
		-- Previous compatibility code saved an escaped union of replacement masks.
		add_mask_lookup(legacy_masks, table.concat(current, "^"), replacements)
		add_mask_lookup(legacy_masks, table.concat(historical, "^"), replacements)
	end
end)

---@param term string
---@return string[]? names Ordered concrete pattern names, or nil when the term cannot be decoded.
---@return string? color Dye ID, or nil for an unknown color or undecodable term.
local function decode_legacy_layer(term)
	if term:sub(1, #layer_prefix) ~= layer_prefix or term:sub(-1) ~= ")" then return end

	local boundary = term:find(mask_separator, #layer_prefix + 1, true)
	if not boundary then return end

	local hex = term:sub(#layer_prefix + 1, boundary - 1)
	if not hex:match("^#%x%x%x%x%x%x$") then return end

	local color = legacy_colors[hex:lower()]
	local mask = unescape_mask(term:sub(boundary + #mask_separator, -2))
	local match = mask and legacy_masks[mask]
	if not match or not color then return end

	return match, color
end

--- Import recognizable layers, dropping unknown masks, colors and layer expressions.
--- Unparseable expressions or a base that disagrees with the shield item yield no layers.
---@param texture string
---@param base_color string?
---@return mcl_banners.PatternLayer[]
function mcl_shields.import_legacy_pattern_layers(texture, base_color)
    local expected_base_layer = base_color and legacy_base_layers[base_color]
    if not expected_base_layer then return {} end

    local terms = split_terms(texture)
    if not terms or #terms < 2 or terms[1] ~= base_texture or terms[2]:lower() ~= expected_base_layer then
        return {}
    end
    local layers = {}
    for i = 3, #terms do
        local names, color = decode_legacy_layer(terms[i])
        if names and color then
            for _, name in ipairs(names) do
                table.insert(layers, { pattern = name, color = color })
            end
        end
    end
    local migrated = mcl_banners.migrate_pattern_layers(layers)
    return migrated
end
