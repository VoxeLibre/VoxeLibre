local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local S = core.get_translator(modname)
local N = function(s) return s end

local mod_mcl_core = core.get_modpath("mcl_core")
local mod_doc = core.get_modpath("doc")

local node_sounds
if core.get_modpath("mcl_sounds") then
	node_sounds = mcl_sounds.node_sound_wood_defaults()
end

-- Helper function
local function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

mcl_banners = {}

mcl_banners.colors = {
	-- Format:
	-- [ID] = { banner description, wool, unified dyes color group, overlay color, dye, color name for emblazonings }
	["unicolor_white"] =      {"white",      S("White Banner"),      "mcl_wool:white", "#C8C8C8", "mcl_dye:white", N("White") },
	["unicolor_darkgrey"] =   {"grey",       S("Grey Banner"),       "mcl_wool:grey", "#303030", "mcl_dye:dark_grey", N("Grey") },
	["unicolor_grey"] =       {"silver",     S("Light Grey Banner"), "mcl_wool:silver", "#5B5B5B", "mcl_dye:grey", N("Light Grey") },
	["unicolor_black"] =      {"black",      S("Black Banner"),      "mcl_wool:black", "#000000", "mcl_dye:black", N("Black") },
	["unicolor_red"] =        {"red",        S("Red Banner"),        "mcl_wool:red", "#760F15", "mcl_dye:red", N("Red") },
	["unicolor_yellow"] =     {"yellow",     S("Yellow Banner"),     "mcl_wool:yellow", "#E2b43E", "mcl_dye:yellow", N("Yellow") },
	["unicolor_dark_green"] = {"green",      S("Green Banner"),      "mcl_wool:green", "#385833", "mcl_dye:dark_green", N("Green") },
	["unicolor_cyan"] =       {"cyan",       S("Cyan Banner"),       "mcl_wool:cyan", "#114C56", "mcl_dye:cyan", N("Cyan") },
	["unicolor_blue"] =       {"blue",       S("Blue Banner"),       "mcl_wool:blue", "#20336B", "mcl_dye:blue", N("Blue") },
	["unicolor_red_violet"] = {"magenta",    S("Magenta Banner"),    "mcl_wool:magenta", "#B36897", "mcl_dye:magenta", N("Magenta")},
	["unicolor_orange"] =     {"orange",     S("Orange Banner"),     "mcl_wool:orange", "#B35E2E", "mcl_dye:orange", N("Orange") },
	["unicolor_violet"] =     {"purple",     S("Violet Banner"),     "mcl_wool:purple", "#764F91", "mcl_dye:violet", N("Violet") },
	["unicolor_brown"] =      {"brown",      S("Brown Banner"),      "mcl_wool:brown", "#46251A", "mcl_dye:brown", N("Brown") },
	["unicolor_pink"] =       {"pink",       S("Pink Banner"),       "mcl_wool:pink", "#C98196", "mcl_dye:pink", N("Pink") },
	["unicolor_lime"] =       {"lime",       S("Lime Banner"),       "mcl_wool:lime", "#7DA553", "mcl_dye:green", N("Lime") },
	["unicolor_light_blue"] = {"light_blue", S("Light Blue Banner"), "mcl_wool:light_blue", "#5176B2", "mcl_dye:lightblue", N("Light Blue") },
}

---@type table<string, string>
local colors_reverse = {}
for colorid, colortab in pairs(mcl_banners.colors) do
	colors_reverse["mcl_banners:banner_item_" .. colortab[1]] = colorid
end

---@param itemname string
---@return string?
function mcl_banners.color_reverse(itemname)
	return colors_reverse[itemname]
end


-- Overlay ratios (0-255)
local base_color_ratio = 225
local layer_ratio = 225
local max_layer_lines = 6

--- Registered patterns indexed by name and by their 1-based registration order for loom display.
---@type table<string|integer, mcl_banners.PatternDef>
mcl_banners.registered_patterns = {}

--- Registered patterns indexed by the item name required to use them in the loom.
---@type table<string, mcl_banners.PatternDef>
mcl_banners.pattern_item_to_pattern = {}

--- Ordered replacement pattern names indexed by the retired pattern name.
---@type table<string, string[]>
mcl_banners.registered_pattern_migrations = {}

local dye_to_colorid = {}
for colorid, colortab in pairs(mcl_banners.colors) do
	dye_to_colorid[colortab[5]] = colorid
end

---@param itemname string
---@return string?
function mcl_banners.get_dye_colorid(itemname)
	return dye_to_colorid[itemname]
end

---@param text string
---@return string, number
local function escape_texture(text)
	return text:gsub("\\", "\\\\"):gsub("%^", "\\%^"):gsub(":", "\\:")
end


---@class mcl_banners.PatternRegistrationDef
---@field description string Layer description
---@field texture string Texture name used as the banner pattern mask
---@field shield_texture string Texture name used as the shield pattern mask
---@field loom boolean? Whether the pattern is available in the loom, defaults to true
---@field pattern_item string? Reusable item required in the loom; must be unique to this pattern and have the banner_pattern=1 group.

---@class mcl_banners.PatternDef: mcl_banners.PatternRegistrationDef
---@field name string Unique pattern identifier supplied to register_pattern
---@field loom boolean Whether the pattern is available in the loom, defaults to true
---@field preview_items table<string, string> Generated preview item names keyed by mcl_banners.colors[colorid][1], e.g. "white"

--- Register a banner pattern. Namespaced pattern names are recommended for external mods.
---@param pattern_name string Unique identifier stored as the registered pattern's name.
---@param def mcl_banners.PatternRegistrationDef
function mcl_banners.register_pattern(pattern_name, def)
	if type(def.texture) ~= "string" or def.texture == "" then
		error("Banner pattern requires a texture: " .. pattern_name)
	end
	if type(def.shield_texture) ~= "string" or def.shield_texture == "" then
		error("Banner pattern requires a shield_texture: " .. pattern_name)
	end
	if mcl_banners.registered_patterns[pattern_name] or mcl_banners.registered_pattern_migrations[pattern_name] then
		error("Banner pattern already registered: " .. pattern_name)
	end
	if def.pattern_item and mcl_banners.pattern_item_to_pattern[def.pattern_item] then
		error("Banner pattern item already in use: " .. def.pattern_item)
	end

	local preview_namespace = core.get_current_modname()
	local preview_pattern_name = pattern_name:gsub(":", "_")
	---@type table<string, string>
	local preview_items = {}

	for _, colortab in pairs(mcl_banners.colors) do
		local itemid = colortab[1]
		local colorize = colortab[4]
		local color = S(colortab[6])
		local itemname = preview_namespace .. ":banner_preview_" .. preview_pattern_name .. "_" .. itemid

		local base = "mcl_banners_item_base.png^(mcl_banners_item_overlay.png^[colorize:#CCCCCC)^[resize:32x32"
		local layer = "(([combine:20x40:-2,-2=" .. def.texture ..
			"^[resize:16x24^[colorize:" .. colorize .. ":" .. layer_ratio .. "))"
		local inventory_image = "[combine:32x32:0,0=" .. escape_texture(base) ..
			":8,4=" .. escape_texture(layer)

		core.register_craftitem(itemname, {
			description = S("Preview Banner"),
			_tt_help = S(def.description, color),
			_doc_items_create_entry = false,
			inventory_image = inventory_image,
			wield_image = inventory_image,
			groups = { not_in_creative_inventory = 1 },
			stack_max = 16,
		})
		preview_items[itemid] = itemname
	end

	---@type mcl_banners.PatternDef
	local pattern = {
		name = pattern_name,
		description = def.description,
		texture = def.texture,
		shield_texture = def.shield_texture,
		loom = def.loom ~= false,
		pattern_item = def.pattern_item,
		preview_items = preview_items,
	}

	mcl_banners.registered_patterns[pattern_name] = pattern
	table.insert(mcl_banners.registered_patterns, pattern)
	if pattern.pattern_item then
		mcl_banners.pattern_item_to_pattern[pattern.pattern_item] = pattern
	end
end


--- Register ordered replacements for a retired pattern name.
---
--- Replacements are resolved for display and saved when banner layers are edited.
---
--- Targets must already be registered with register_pattern
---@param name string Retired pattern identifier
---@param new_names string[] Non-empty list of replacement pattern names
function mcl_banners.register_pattern_migration(name, new_names)
	if type(name) ~= "string" or name == "" then
		error("Invalid banner pattern migration name")
	end
	if mcl_banners.registered_patterns[name] or mcl_banners.registered_pattern_migrations[name] then
		error("Banner pattern or migration already registered: " .. name)
	end
	if type(new_names) ~= "table" or next(new_names) == nil then
		error("Banner pattern migration requires a nonempty list: " .. name)
	end

	local count = 0
	for index in pairs(new_names) do
		if type(index) ~= "number" or index < 1 or index % 1 ~= 0 then
			error("Banner pattern migration requires an ordered list: " .. name)
		end
		count = count + 1
	end
	local replacements = {}
	for index = 1, count do
		local target = new_names[index]
		if type(target) ~= "string" or not mcl_banners.registered_patterns[target] then
			error("Unknown banner pattern migration target: " .. tostring(target))
		end
		replacements[index] = target
	end
	mcl_banners.registered_pattern_migrations[name] = replacements
end

---@class mcl_banners.PatternLayer
---@field pattern string Registered pattern name or alias
---@field color string Dye color ID from mcl_banners.colors, e.g. "unicolor_white"

--- Expand retired patterns without changing the input array or its layer records.
--- Unknown pattern names and additional layer fields are preserved.
---@param layers mcl_banners.PatternLayer[]? Stored layers
---@return mcl_banners.PatternLayer[] layers Independent copies of the layers, with replacements inserted in order
---@return boolean changed Whether any retired pattern was replaced
function mcl_banners.migrate_pattern_layers(layers)
	local migrated, changed = {}, false
	if type(layers) ~= "table" then
		return migrated, changed
	end
	for _, layer in ipairs(layers) do
		local replacements = mcl_banners.registered_pattern_migrations[layer.pattern]
		if replacements then
			for _, pattern_name in ipairs(replacements) do
				local replacement = table.copy(layer)
				replacement.pattern = pattern_name
				table.insert(migrated, replacement)
			end
			changed = true
		else
			table.insert(migrated, table.copy(layer))
		end
	end
	return migrated, changed
end

core.register_on_mods_loaded(function()
	for _, pattern in ipairs(mcl_banners.registered_patterns) do
		if pattern.pattern_item then
			if not core.registered_items[pattern.pattern_item] then
				error("Unknown banner pattern item: " .. pattern.pattern_item)
			end
			if core.get_item_group(pattern.pattern_item, "banner_pattern") == 0 then
				error("Banner pattern item is missing banner_pattern=1: " .. pattern.pattern_item)
			end
		end
	end
end)

---@param description string
---@param layers mcl_banners.PatternLayer[]?
---@return string
function mcl_banners.make_advanced_banner_description(description, layers)
	layers = mcl_banners.migrate_pattern_layers(layers)
	if #layers == 0 then
		return ""
	end

	local layerstrings = {}
	for index, layer in ipairs(layers) do
		if index > max_layer_lines then
			break
		end

		local colortab = mcl_banners.colors[layer.color]
		local color = colortab and S(colortab[6]) or S("Unknown Color")
		local pattern = mcl_banners.registered_patterns[layer.pattern]
		if pattern then
			table.insert(layerstrings, S(pattern.description, color))
		else
			table.insert(layerstrings, S("@1 Unknown Pattern (@2)", color, tostring(layer.pattern)))
		end
	end

	if #layers == max_layer_lines + 1 then
		table.insert(layerstrings, S("And one additional layer"))
	elseif #layers > max_layer_lines + 1 then
		table.insert(layerstrings, S("And @1 additional layers", #layers - max_layer_lines))
	end

	return description .. "\n" .. core.colorize(mcl_colors.GRAY, table.concat(layerstrings, "\n"))
end

function mcl_banners.add_pattern_layer(banner, pattern_name, dye)
	local pattern = mcl_banners.registered_patterns[pattern_name]
	local colorid = dye_to_colorid[dye:get_name()]
	if not pattern or not colorid or core.get_item_group(banner:get_name(), "banner") == 0 then
		return ItemStack("")
	end

	local meta = banner:get_meta()
	local layers = mcl_banners.migrate_pattern_layers(core.deserialize(meta:get_string("layers")))
	table.insert(layers, { pattern = pattern_name, color = colorid })
	meta:set_string("layers", core.serialize(layers))

	if meta:get_string("name") == "" then
		meta:set_string("description", mcl_banners.make_advanced_banner_description(
			banner:get_definition().description, layers))
	end
	return banner
end

local banner_surface = {
	base = "mcl_banners_banner_base.png",
	preserve = "mcl_banners_base_inverted.png",
	mask = "mcl_banners_base.png",
	pattern_field = "texture",
}
local shield_surface = {
	base = "mcl_shield_base_nopattern.png^mcl_shield_pattern_base.png",
	preserve = "mcl_shield_base_nopattern.png^mcl_shield_pattern_base.png",
	mask = "mcl_shield_pattern_base.png",
	pattern_field = "shield_texture",
}

-- Keep the surface's original base and tinting recipe, sharing layer composition.
local function make_pattern_texture(surface, base_color, layers)
	local colortab = mcl_banners.colors[base_color]
	if not colortab then
		return surface.base
	end

	local colorize = colortab[4]
	local texture = "(" .. surface.base .. "^[mask:" .. surface.preserve .. ")^" ..
		"((" .. surface.base .. "^[colorize:" .. colorize .. ":" .. base_color_ratio ..
		")^[mask:" .. surface.mask .. ")"

	layers = mcl_banners.migrate_pattern_layers(layers)
	for _, layerinfo in ipairs(layers) do
		local pattern = mcl_banners.registered_patterns[layerinfo.pattern]
		local layer_color = mcl_banners.colors[layerinfo.color]
		if pattern and layer_color then
			local layer = "((" .. surface.base .. "^[colorize:" .. layer_color[4] .. ":" ..
				layer_ratio .. ")^[mask:" .. escape_texture(pattern[surface.pattern_field]) .. ")"
			texture = texture .. "^" .. layer
		end
	end
	return texture
end

--- Build a banner entity or preview texture
---@param base_color string? Dye color ID from mcl_banners.colors
---@param layers mcl_banners.PatternLayer[]?
---@return string
function mcl_banners.make_banner_texture(base_color, layers)
	return make_pattern_texture(banner_surface, base_color, layers)
end

--- Build a patterned shield texture
---@param base_color string? Dye color ID from mcl_banners.colors
---@param layers mcl_banners.PatternLayer[]?
---@return string
function mcl_banners.make_shield_texture(base_color, layers)
	if not mcl_banners.colors[base_color] then return "mcl_shield_base_nopattern.png" end
	return make_pattern_texture(shield_surface, base_color, layers)
end


local standing_banner_entity_offset = vector.new(0, -0.499, 0)
local hanging_banner_entity_offset = vector.new(0, -1.7, 0)

---@param rotation_level integer
---@return number
local function rotation_level_to_yaw(rotation_level)
	return (rotation_level * (math.pi/8)) + math.pi
end

local function on_dig_banner(pos, node, digger)
	-- Check protection
	local name = digger:get_player_name()
	if core.is_protected(pos, name) then
		core.record_protection_violation(pos, name)
		return
	end

	local inv = core.get_meta(pos):get_inventory()
	local item = inv:get_stack("banner", 1)
	local item_str = item:is_empty() and "mcl_banners:banner_item_white"
		or item:to_string()

	core.handle_node_drops(pos, { item_str }, digger)

	item:set_count(0)
	inv:set_stack("banner", 1, item)

	-- Remove node
	core.remove_node(pos)
end

local function on_destruct_banner(pos, hanging)
	local offset, nodename
	if hanging then
		offset = hanging_banner_entity_offset
		nodename = "mcl_banners:hanging_banner"
	else
		offset = standing_banner_entity_offset
		nodename = "mcl_banners:standing_banner"
	end
	-- Find this node's banner entity and remove it
	local checkpos = vector.add(pos, offset)
	local objects = core.get_objects_inside_radius(checkpos, 0.5)
	for _, v in ipairs(objects) do
		local ent = v:get_luaentity()
		if ent and ent.name == nodename then
			v:remove()
		end
	end

	-- Drop item only if it was not handled in on_dig_banner
	local inv = core.get_meta(pos):get_inventory()
	local item = inv:get_stack("banner", 1)
	if not item:is_empty() then
		core.handle_node_drops(pos, {item:to_string()})
	end
end

local function on_destruct_standing_banner(pos)
	return on_destruct_banner(pos, false)
end

local function on_destruct_hanging_banner(pos)
	return on_destruct_banner(pos, true)
end

local function spawn_banner_entity(pos, hanging, itemstack)
	local banner
	if hanging then
		banner = core.add_entity(pos, "mcl_banners:hanging_banner")
	else
		banner = core.add_entity(pos, "mcl_banners:standing_banner")
	end
	if banner == nil then
		return banner
	end
	local imeta = itemstack:get_meta()
	local layers_raw = imeta:get_string("layers")
	local layers = core.deserialize(layers_raw)
	local colorid = mcl_banners.color_reverse(itemstack:get_name())
	banner:get_luaentity():_set_textures(colorid, layers)
	local mname = imeta:get_string("name")
	if mname and mname ~= "" then
		banner:get_luaentity()._item_name = mname
		banner:get_luaentity()._item_description = imeta:get_string("description")
	end

	return banner
end

local function respawn_banner_entity(pos, node, force)
	local hanging = node.name == "mcl_banners:hanging_banner"
	local offset
	if hanging then
		offset = hanging_banner_entity_offset
	else
		offset = standing_banner_entity_offset
	end
	-- Check if a banner entity already exists
	local bpos = vector.add(pos, offset)
	local objects = core.get_objects_inside_radius(bpos, 0.5)
	for _, v in ipairs(objects) do
		local ent = v:get_luaentity()
		if ent and (ent.name == "mcl_banners:standing_banner" or ent.name == "mcl_banners:hanging_banner") then
			if force then
				v:remove()
			else
				return
			end
		end
	end
	-- Spawn new entity
	local meta = core.get_meta(pos)
	local banner_item = meta:get_inventory():get_stack("banner", 1)
	local banner_entity = spawn_banner_entity(bpos, hanging, banner_item)

	-- Set rotation
	local rotation_level = meta:get_int("rotation_level")
	local final_yaw = rotation_level_to_yaw(rotation_level)
	if banner_entity then
		banner_entity:set_yaw(final_yaw)
	end
end

-- Banner nodes.
-- These are an invisible nodes which are only used to destroy the banner entity.
-- All the important banner information (such as color) is stored in the entity.
-- It is used only used internally.

-- Standing banner node
-- This one is also used for the help entry to avoid spamming the help with 16 entries.
core.register_node("mcl_banners:standing_banner", {
	_doc_items_entry_name = S("Banner"),
	_doc_items_image = "mcl_banners_item_base.png^mcl_banners_item_overlay.png",
	_doc_items_longdesc = S("Banners are tall colorful decorative blocks. They can be placed on the floor and at walls. Banners can be emblazoned with a variety of patterns using a loom."),
	_doc_items_usagehelp = S("Use a loom with a banner and dye to add a pattern. Some patterns also require a banner pattern item. Emblazoned banners can be emblazoned again to combine various patterns.").."\n"..
	S("You can copy the pattern of a banner by placing two banners of the same color in the crafting grid—one needs to be emblazoned, the other one must be clean. Finally, you can use a banner on a cauldron with water to wash off its top-most layer."),
	walkable = false,
	is_ground_content = false,
	paramtype = "light",
	sunlight_propagates = true,
	drawtype = "nodebox",
	-- Nodebox is drawn as fallback when the entity is missing, so that the
	-- banner node is never truly invisible.
	-- If the entity is drawn, the nodebox disappears within the real banner mesh.
	node_box = {
		type = "fixed",
		fixed = { -1/32, -0.49, -1/32, 1/32, 1.49, 1/32 },
	},
	-- This texture is based on the banner base texture
	tiles = { "mcl_banners_fallback_wood.png" },

	inventory_image = "mcl_banners_item_base.png",
	wield_image = "mcl_banners_item_base.png",

	selection_box = {type = "fixed", fixed= {-0.3, -0.5, -0.3, 0.3, 0.5, 0.3} },
	groups = {axey=1,handy=1, attached_node = 1, not_in_creative_inventory = 1, not_in_craft_guide = 1, material_wood=1, dig_by_piston=1, flammable=-1 },
	stack_max = 16,
	sounds = node_sounds,
	drop = "", -- Item drops are handled in entity code

	on_dig = on_dig_banner,
	on_destruct = on_destruct_standing_banner,
	on_punch = function(pos, node)
		respawn_banner_entity(pos, node)
	end,
	_mcl_hardness = 1,
	_mcl_blast_resistance = 1,
	on_rotate = function(pos, node, user, mode, param2)
		if mode == screwdriver.ROTATE_FACE then
			local meta = core.get_meta(pos)
			local rot = meta:get_int("rotation_level")
			rot = (rot - 1) % 16
			meta:set_int("rotation_level", rot)
			respawn_banner_entity(pos, node, true)
			return true
		else
			return false
		end
	end,
})

-- Hanging banner node
core.register_node("mcl_banners:hanging_banner", {
	walkable = false,
	is_ground_content = false,
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	drawtype = "nodebox",
	inventory_image = "mcl_banners_item_base.png",
	wield_image = "mcl_banners_item_base.png",
	tiles = { "mcl_banners_fallback_wood.png" },
	node_box = {
		type = "wallmounted",
		wall_side = { -0.49, 0.41, -0.49, -0.41, 0.49, 0.49 },
		wall_top = { -0.49, 0.41, -0.49, -0.41, 0.49, 0.49 },
		wall_bottom = { -0.49, -0.49, -0.49, -0.41, -0.41, 0.49 },
	},
	selection_box = {type = "wallmounted", wall_side = {-0.5, -0.5, -0.5, -4/16, 0.5, 0.5} },
	groups = {axey=1,handy=1, attached_node = 1, not_in_creative_inventory = 1, not_in_craft_guide = 1, material_wood=1, flammable=-1 },
	stack_max = 16,
	sounds = node_sounds,
	drop = "", -- Item drops are handled in entity code

	on_dig = on_dig_banner,
	on_destruct = on_destruct_hanging_banner,
	on_punch = function(pos, node)
		respawn_banner_entity(pos, node)
	end,
	_mcl_hardness = 1,
	_mcl_blast_resistance = 1,
	on_rotate = function(pos, node, user, mode, param2)
		if mode == screwdriver.ROTATE_FACE then
			local r = screwdriver.rotate.wallmounted(pos, node, mode)
			node.param2 = r
			core.swap_node(pos, node)
			local meta = core.get_meta(pos)
			local rot = 0
			if node.param2 == 2 then
				rot = 12
			elseif node.param2 == 3 then
				rot = 4
			elseif node.param2 == 4 then
				rot = 0
			elseif node.param2 == 5 then
				rot = 8
			end
			meta:set_int("rotation_level", rot)
			respawn_banner_entity(pos, node, true)
			return true
		else
			return false
		end
	end,
})

for _, colortab in pairs(mcl_banners.colors) do
	local itemid = colortab[1]
	local desc = colortab[2]
	local wool = colortab[3]
	local colorize = colortab[4]
	local itemstring = "mcl_banners:banner_item_" .. itemid

	local inventory_image
	if colorize then
		inventory_image = "mcl_banners_item_base.png^(mcl_banners_item_overlay.png^[colorize:" ..
			colorize .. ")^[resize:32x32"
	else
		inventory_image = "mcl_banners_item_base.png^mcl_banners_item_overlay.png^[resize:32x32"
	end

	core.register_craftitem(itemstring, {
		description = desc,
		_tt_help = S("Paintable decoration"),
		_doc_items_create_entry = false,
		inventory_image = inventory_image,
		wield_image = inventory_image,
		-- Banner group groups together the banner items, but not the nodes.
		-- Used for crafting.
		groups = { banner = 1, deco_block = 1, flammable = -1 },
		stack_max = 16,

		on_place = function(itemstack, placer, pointed_thing)
			local above = pointed_thing.above
			local under = pointed_thing.under

			local node_under = core.get_node(under)
			if placer and not placer:get_player_control().sneak then
				if core.get_modpath("mcl_cauldrons") then
					-- Use banner on cauldron to remove the top-most layer. This reduces the water level by 1.
					local new_node
					if node_under.name == "mcl_cauldrons:cauldron_3" then
						new_node = "mcl_cauldrons:cauldron_2"
					elseif node_under.name == "mcl_cauldrons:cauldron_2" then
						new_node = "mcl_cauldrons:cauldron_1"
					elseif node_under.name == "mcl_cauldrons:cauldron_1" then
						new_node = "mcl_cauldrons:cauldron"
					elseif node_under.name == "mcl_cauldrons:cauldron_3r" then
						new_node = "mcl_cauldrons:cauldron_2r"
					elseif node_under.name == "mcl_cauldrons:cauldron_2r" then
						new_node = "mcl_cauldrons:cauldron_1r"
					elseif node_under.name == "mcl_cauldrons:cauldron_1r" then
						new_node = "mcl_cauldrons:cauldron"
					end
					if new_node then
						local playername = placer:get_player_name()
						if core.is_protected(under, playername) then
							core.record_protection_violation(under, playername)
							return itemstack
						end

						local imeta = itemstack:get_meta()
						local layers_raw = imeta:get_string("layers")
						local layers = mcl_banners.migrate_pattern_layers(core.deserialize(layers_raw))
						if #layers > 0 then
							table.remove(layers)
							imeta:set_string("layers", core.serialize(layers))
							local newdesc = mcl_banners.make_advanced_banner_description(itemstack:get_definition().description, layers)
							local mname = imeta:get_string("name")
							-- Don't change description if item has a name
							if mname == "" then
								imeta:set_string("description", newdesc)
							end
						end

						-- Washing off reduces the water level by 1.
						-- (It is possible to waste water if the banner had 0 layers.)
						core.set_node(pointed_thing.under, {name=new_node})

						-- Play sound (from mcl_potions mod)
						core.sound_play("mcl_potions_bottle_pour", {pos=pointed_thing.under, gain=0.5, max_hear_range=16}, true)

						return itemstack
					end
				end
				-- Let other nodes handle right-click before placing a banner.
				if core.registered_nodes[node_under.name] and core.registered_nodes[node_under.name].on_rightclick then
					return core.registered_nodes[node_under.name].on_rightclick(under, node_under, placer, itemstack) or itemstack
				end
			end

			-- Place the node!
			local hanging = false

			-- Standing or hanging banner. The placement rules are enforced by the node definitions
			local _, success = core.item_place_node(ItemStack("mcl_banners:standing_banner"), placer, pointed_thing)
			if not success then
				-- Forbidden on ceiling
				if pointed_thing.under.y ~= pointed_thing.above.y then
					return itemstack
				end
				_, success = core.item_place_node(ItemStack("mcl_banners:hanging_banner"), placer, pointed_thing)
				if not success then
					return itemstack
				end
				hanging = true
			end
			local place_pos
			if core.registered_nodes[node_under.name].buildable_to then
				place_pos = under
			else
				place_pos = above
			end
			local bnode = core.get_node(place_pos)
			if bnode.name ~= "mcl_banners:standing_banner" and bnode.name ~= "mcl_banners:hanging_banner" then
				core.log("error", "[mcl_banners] The placed banner node is not what the mod expected!")
				return itemstack
			end
			local meta = core.get_meta(place_pos)
			local inv = meta:get_inventory()
			inv:set_size("banner", 1)
			local store_stack = ItemStack(itemstack)
			store_stack:set_count(1)
			inv:set_stack("banner", 1, store_stack)

			-- Spawn entity
			local entity_place_pos
			if hanging then
				entity_place_pos = vector.add(place_pos, hanging_banner_entity_offset)
			else
				entity_place_pos = vector.add(place_pos, standing_banner_entity_offset)
			end
			local banner_entity = spawn_banner_entity(entity_place_pos, hanging, itemstack)
			-- Set rotation
			local final_yaw, rotation_level
			if hanging then
				local pdir = vector.direction(pointed_thing.under, pointed_thing.above)
				final_yaw = core.dir_to_yaw(pdir)
				if pdir.x > 0 then
					rotation_level = 4
				elseif pdir.z > 0 then
					rotation_level = 8
				elseif pdir.x < 0 then
					rotation_level = 12
				else
					rotation_level = 0
				end
			else
				-- Determine the rotation based on player's yaw
				local yaw = placer:get_look_horizontal()
				-- Select one of 16 possible rotations (0-15)
				rotation_level = round((yaw / (math.pi*2)) * 16)
				if rotation_level >= 16 then
					rotation_level = 0
				end
				final_yaw = rotation_level_to_yaw(rotation_level)
			end
			meta:set_int("rotation_level", rotation_level)

			if banner_entity then
				banner_entity:set_yaw(final_yaw)
			end

			if not core.is_creative_enabled(placer:get_player_name()) then
				itemstack:take_item()
			end
			core.sound_play({name="default_place_node_hard", gain=1.0}, {pos = place_pos}, true)

			return itemstack
		end,

		_mcl_generate_description = function(itemstack)
			local meta = itemstack:get_meta()
			local layers_raw = meta:get_string("layers")
			local layers, changed = mcl_banners.migrate_pattern_layers(core.deserialize(layers_raw))
			if changed then
				meta:set_string("layers", core.serialize(layers))
			end
			local desc = itemstack:get_definition().description
			local name = meta:get_string("name")
			local newdesc = name ~= "" and core.colorize(mcl_colors.YELLOW, name)
				or mcl_banners.make_advanced_banner_description(desc, layers)
			meta:set_string("description", newdesc)
			return newdesc
		end,
	})

	if mod_mcl_core and core.get_modpath("mcl_wool") then
		core.register_craft({
			output = itemstring,
			recipe = {
				{ wool, wool, wool },
				{ wool, wool, wool },
				{ "", "mcl_core:stick", "" },
			}
		})
	end

	if mod_doc then
		-- Add item to node alias
		doc.add_entry_alias("nodes", "mcl_banners:standing_banner", "craftitems", itemstring)
	end
end

if mod_doc then
	-- Add item to node alias
	doc.add_entry_alias("nodes", "mcl_banners:standing_banner", "nodes", "mcl_banners:hanging_banner")
end


-- Banner entities.
local entity_standing = {
	initial_properties = {
		physical = false,
		collide_with_objects = false,
		visual = "mesh",
		mesh = "amc_banner.b3d",
		visual_size = { x=2.499, y=2.499 },
		textures = {mcl_banners.make_banner_texture()},
		pointable = false,
	},

	_base_color = nil, -- base color of banner
	_layers = nil, -- table of layers painted over the base color.
		-- This is a table of tables with each table having the following fields:
			-- color: layer color ID (see colors table above)
			-- pattern: name of pattern (see list above)

	get_staticdata = function(self)
		local out = { _base_color = self._base_color, _layers = self._layers, _name = self._name }
		return core.serialize(out)
	end,
	on_activate = function(self, staticdata)
		if staticdata and staticdata ~= "" then
			local inp = core.deserialize(staticdata)
			self._base_color = inp._base_color
			self._layers = inp._layers
			self._name = inp._name
			self.object:set_properties({
				textures = {mcl_banners.make_banner_texture(self._base_color, self._layers)},
			})
		end
		-- Make banner slowly swing
		self.object:set_animation({x=0, y=80}, 25)
		self.object:set_armor_groups({immortal=1})
	end,

	-- Set the banner textures. This function can be used by external mods.
	-- Meaning of parameters:
	-- * self: Lua entity reference to entity.
	-- * other parameters: Same meaning as in mcl_banners.make_banner_texture
	_set_textures = function(self, base_color, layers)
		if base_color then
			self._base_color = base_color
		end
		if layers then
			self._layers = layers
		end
		self.object:set_properties({textures = {mcl_banners.make_banner_texture(self._base_color, self._layers)}})
	end,
}
core.register_entity("mcl_banners:standing_banner", entity_standing)

local entity_hanging = table.copy(entity_standing)
entity_hanging.initial_properties.mesh = "amc_banner_hanging.b3d"
core.register_entity("mcl_banners:hanging_banner", entity_hanging)

-- FIXME: Prevent entity destruction by /clearobjects
core.register_lbm({
	label = "Respawn banner entities",
	name = "mcl_banners:respawn_entities",
	run_at_every_load = true,
	nodenames = {"mcl_banners:standing_banner", "mcl_banners:hanging_banner"},
	action = function(pos, node)
		respawn_banner_entity(pos, node)
	end,
})

core.register_craft({
	type = "fuel",
	recipe = "group:banner",
	burntime = 15,
})

dofile(modpath .. "/patterns.lua")
dofile(modpath .. "/patterncraft.lua")
