mcl_craftguide = {}

local M = minetest
local player_data = {}

-- Caches
local init_items    = {}
local searches      = {}
local recipes_cache = {}
local usages_cache  = {}
local fuel_cache    = {}

local progressive_mode = M.settings:get_bool("mcl_craftguide_progressive_mode", true)

local colorize = M.colorize
local reg_items = M.registered_items
local get_result = M.get_craft_result
local show_formspec = M.show_formspec
local get_player_by_name = M.get_player_by_name
local serialize, deserialize = M.serialize, M.deserialize

local ESC = M.formspec_escape
local S = M.get_translator("mcl_craftguide")

local maxn, sort, concat, insert, copy =
	table.maxn, table.sort, table.concat, table.insert,
	table.copy

local fmt, find, gmatch, match, sub, split, lower =
	string.format, string.find, string.gmatch, string.match,
	string.sub, string.split, string.lower

local min, max, floor, ceil = math.min, math.max, math.floor, math.ceil
local pairs, next, unpack = pairs, next, unpack

local DEFAULT_SIZE = 10
local MIN_LIMIT, MAX_LIMIT = 10, 12
DEFAULT_SIZE = min(MAX_LIMIT, max(MIN_LIMIT, DEFAULT_SIZE))

local GRID_LIMIT = 5
local POLL_FREQ  = 0.25

local FORM_SPACING_X = 5 / 4
local FORM_SPACING_Y = 15 / 13
local FORM_PADDING = 3 / 8
local FORM_BUTTON_HEIGHT = 21 / 26

local FMT = {
	box               = "box[%f,%f;%f,%f;%s]",
	label             = "label[%f,%f;%s]",
	image             = "image[%f,%f;%f,%f;%s]",
	button            = "button[%f,%f;%f,%f;%s;%s]",
	tooltip           = "tooltip[%s;%s]",
	item_image        = "item_image[%f,%f;%f,%f;%s]",
	image_button      = "image_button[%f,%f;%f,%f;%s;%s;%s]",
	item_image_button = "item_image_button[%f,%f;%f,%f;%s;%s;%s]",
}

local function render_v1_box(x, y, w, h, color)
	x, y = mcl_formspec.old_to_real.position(x, y)
	w, h = mcl_formspec.old_to_real.spaced_geometry(w, h)
	return fmt(FMT.box, x, y, w, h, color)
end

local function render_v1_label(x, y, text)
	x, y = mcl_formspec.old_to_real.label(x, y)
	return fmt(FMT.label, x, y, text)
end

local function render_v1_image(x, y, w, h, texture)
	x, y = mcl_formspec.old_to_real.position(x, y)
	return fmt(FMT.image, x, y, w, h, texture)
end

local function render_v1_button(x, y, w, h, name, label)
	x, y, w, h = mcl_formspec.old_to_real.button(x, y, w, h)
	return fmt(FMT.button, x, y, w, h, name, label)
end

local function render_v1_item_image(x, y, w, h, item)
	x, y = mcl_formspec.old_to_real.position(x, y)
	return fmt(FMT.item_image, x, y, w, h, item)
end

local function render_v1_image_button(x, y, w, h, texture, name, label)
	x, y = mcl_formspec.old_to_real.position(x, y)
	w, h = mcl_formspec.old_to_real.button_geometry(w, h)
	return fmt(FMT.image_button, x, y, w, h, texture, name, label)
end

local function render_v1_item_image_button(x, y, w, h, item, name, label)
	x, y = mcl_formspec.old_to_real.position(x, y)
	w, h = mcl_formspec.old_to_real.button_geometry(w, h)
	return fmt(FMT.item_image_button, x, y, w, h, item, name, label)
end

local ELEMENT_RENDERERS_V1 = {
	box = render_v1_box,
	label = render_v1_label,
	image = render_v1_image,
	button = render_v1_button,
	tooltip = function(name, text)
		return fmt(FMT.tooltip, name, text)
	end,
	item_image = render_v1_item_image,
	image_button = render_v1_image_button,
	item_image_button = render_v1_item_image_button,
}

local group_stereotypes = {
	wood                        = "mcl_core:wood",
	stone                       = "mcl_core:stone",
	sand                        = "mcl_core:sand",
	wool                        = "mcl_wool:white",
	carpet                      = "mcl_wool:white_carpet",
	dye                         = "mcl_dye:red",
	water_bucket                = "mcl_buckets:bucket_water",
	flower                      = "mcl_flowers:dandelion",
	mushroom                    = "mcl_mushrooms:mushroom_brown",
	wood_slab                   = "mcl_stairs:slab_wood",
	wood_stairs                 = "mcl_stairs:stairs_wood",
	coal                        = "mcl_core:coal_lump",
	shulker_box                 = "mcl_chests:violet_shulker_box",
	quartz_block                = "mcl_nether:quartz_block",
	banner                      = "mcl_banners:banner_item_white",
	mesecon_conductor_craftable = "mesecons:wire_00000000_off",
	purpur_block                = "mcl_end:purpur_block",
	normal_sandstone            = "mcl_core:sandstone",
	red_sandstone               = "mcl_core:redsandstone",
	compass                     = mcl_compass.stereotype,
	clock                       = mcl_clock.sterotype,
}

local group_names = {
	shulker_box = S("Any shulker box"),
	wool = S("Any wool"),
	wood = S("Any wood planks"),
	tree = S("Any wood"),
	sand = S("Any sand"),
	normal_sandstone = S("Any normal sandstone"),
	red_sandstone = S("Any red sandstone"),
	carpet = S("Any carpet"),
	dye = S("Any dye"),
	water_bucket = S("Any water bucket"),
	flower = S("Any flower"),
	mushroom = S("Any mushroom"),
	wood_slab = S("Any wooden slab"),
	wood_stairs = S("Any wooden stairs"),
	coal = S("Any coal"),
	quartz_block = S("Any kind of quartz block"),
	purpur_block = S("Any kind of purpur block"),
	stonebrick = S("Any stone bricks"),
	stick = S("Any stick"),
}



local item_lists = {
	"main",
	"craft",
	"craftpreview",
}

local function init_data(name)
	player_data[name] = {
		filter  = "",
		favorites_only = nil,
		pagenum = 1,
		iX      = DEFAULT_SIZE,
		items   = init_items,
		items_raw = init_items,
		lang_code = M.get_player_information(name).lang_code or "en",
	}
end
local function get_player_data(name)
	-- If the data alrady exists, use it
	local data = player_data[name]
	if data then return data end

	-- Initialize player data if it doesn't exist
	init_data(name)
	local player = minetest.get_player_by_name(name)
	local meta = player:get_meta()
	local data = player_data[name]

	data.inv_items = deserialize(meta:get_string("inv_items")) or {}
	data.favorite_items = deserialize(meta:get_string("favorite_items")) or {}
	return data
end

local function table_merge(t, t2)
	t, t2 = t or {}, t2 or {}
	local c = #t

	for i = 1, #t2 do
		c = c + 1
		t[c] = t2[i]
	end

	return t
end

local function table_replace(t, val, new)
	for k, v in pairs(t) do
		if v == val then
			t[k] = new
		end
	end
end

local function table_diff(t, t2)
	local hash = {}

	for i = 1, #t do
		local v = t[i]
		hash[v] = true
	end

	for i = 1, #t2 do
		local v = t2[i]
		hash[v] = nil
	end

	local diff, c = {}, 0

	for i = 1, #t do
		local v = t[i]
		if hash[v] then
			c = c + 1
			diff[c] = v
		end
	end

	return diff
end

local custom_crafts, craft_types, stations = {}, {}, {}

function mcl_craftguide.register_craft_type(name, def)
	local func = "mcl_craftguide.register_craft_type(): "
	assert(name, func .. "'name' field missing")
	assert(def.description, func .. "'description' field missing")
	assert(def.icon, func .. "'icon' field missing")

	craft_types[name] = def
end

function mcl_craftguide.register_craft(def)
	local func = "mcl_craftguide.register_craft(): "
	assert(def.type, func .. "'type' field missing")
	assert(def.width, func .. "'width' field missing")
	assert(def.output, func .. "'output' field missing")
	assert(def.items, func .. "'items' field missing")

	custom_crafts[#custom_crafts + 1] = def
end

function mcl_craftguide.register_station(item_name, def, override)
	local func = "mcl_craftguide.register_station(): "
	assert(type(item_name) == "string", func .. "'item_name' must be a string")
	assert(reg_items[item_name], func .. "'" .. item_name .. "' is not a registered item")
	assert(type(def) == "table", func .. "'def' must be a table")
	assert(override == nil or type(override) == "boolean",
		func .. "'override' must be a boolean")
	assert(type(def.is_recipe_supported) == "function",
		func .. "'is_recipe_supported' function missing")

	for i = 1, #stations do
		if stations[i].item_name == item_name then
			assert(override,
				func .. "'" .. item_name .. "' is already registered")
			stations[i] = {
				item_name = item_name,
				is_recipe_supported = def.is_recipe_supported,
			}
			return
		end
	end

	stations[#stations + 1] = {
		item_name = item_name,
		is_recipe_supported = def.is_recipe_supported,
	}
end

function mcl_craftguide.get_station(item_name)
	for i = 1, #stations do
		local station = stations[i]
		if station.item_name == item_name then
			return copy({
				is_recipe_supported = station.is_recipe_supported,
			})
		end
	end
end

local recipe_filters = {}

function mcl_craftguide.add_recipe_filter(name, f)
	local func = "mcl_craftguide.add_recipe_filter(): "
	assert(name, func .. "filter name missing")
	assert(f and type(f) == "function", func .. "filter function missing")

	recipe_filters[name] = f
end

function mcl_craftguide.remove_recipe_filter(name)
	recipe_filters[name] = nil
end

function mcl_craftguide.set_recipe_filter(name, f)
	local func = "mcl_craftguide.set_recipe_filter(): "
	assert(name, func .. "filter name missing")
	assert(f and type(f) == "function", func .. "filter function missing")

	recipe_filters = { [name] = f }
end

function mcl_craftguide.get_recipe_filters()
	return recipe_filters
end

local function apply_recipe_filters(recipes, player)
	for _, filter in pairs(recipe_filters) do
		recipes = filter(recipes, player)
	end

	return recipes
end

local search_filters = {}

function mcl_craftguide.add_search_filter(name, f)
	local func = "mcl_craftguide.add_search_filter(): "
	assert(name, func .. "filter name missing")
	assert(f and type(f) == "function", func .. "filter function missing")

	search_filters[name] = f
end

function mcl_craftguide.remove_search_filter(name)
	search_filters[name] = nil
end

function mcl_craftguide.get_search_filters()
	return search_filters
end

local formspec_elements = {}

function mcl_craftguide.add_formspec_element(name, def)
	local func = "mcl_craftguide.add_formspec_element(): "
	local api_version = def.api_version or 1
	assert(def.element, func .. "'element' field not defined")
	assert(def.type, func .. "'type' field not defined")
	assert(FMT[def.type],
		func .. "'" .. def.type .. "' type not supported by the API")
	assert(api_version == 1 or api_version == 2,
		func .. "unsupported API version " .. tostring(api_version))

	formspec_elements[name] = {
		type        = def.type,
		element     = def.element,
		action      = def.action,
		api_version = api_version,
	}
end

function mcl_craftguide.remove_formspec_element(name)
	formspec_elements[name] = nil
end

function mcl_craftguide.get_formspec_elements()
	return formspec_elements
end

local function item_has_groups(item_groups, groups)
	for i = 1, #groups do
		local group = groups[i]
		if not item_groups[group] then
			return
		end
	end

	return true
end

local function extract_groups(str)
	return split(sub(str, 7), ",")
end

local function item_in_recipe(item, recipe)
	for _, recipe_item in pairs(recipe.items) do
		if recipe_item == item then
			return true
		end
	end
end

local function groups_item_in_recipe(item, recipe)
	local item_groups = reg_items[item].groups
	for _, recipe_item in pairs(recipe.items) do
		if sub(recipe_item, 1, 6) == "group:" then
			local groups = extract_groups(recipe_item)
			if item_has_groups(item_groups, groups) then
				local usage = copy(recipe)
				table_replace(usage.items, recipe_item, item)
				return usage
			end
		end
	end
end

local function get_item_usages(item)
	local usages, c = {}, 0

	for _, recipes in pairs(recipes_cache) do
		for i = 1, #recipes do
			local recipe = recipes[i]
			if item_in_recipe(item, recipe) then
				c = c + 1
				usages[c] = recipe
			else
				recipe = groups_item_in_recipe(item, recipe)
				if recipe then
					c = c + 1
					usages[c] = recipe
				end
			end
		end
	end

	if fuel_cache[item] then
		usages[#usages + 1] = { type = "fuel", width = 1, items = { item } }
	end

	return usages
end

local function get_filtered_items(player)
	local items, c = {}, 0

	for i = 1, #init_items do
		local item = init_items[i]
		local recipes = recipes_cache[item]
		local usages = usages_cache[item]

		if recipes and #apply_recipe_filters(recipes, player) > 0 or
			usages and #apply_recipe_filters(usages, player) > 0 then
			c = c + 1
			items[c] = item
		end
	end

	return items
end

local function get_player_items(data, player)
	local items = next(recipe_filters) and get_filtered_items(player) or init_items
	if not data.favorite_items or not data.favorites_only then
		return items
	end

	local filtered, c = {}, 0
	for i = 1, #items do
		local item = items[i]
		if data.favorite_items[item] then
			c = c + 1
			filtered[c] = item
		end
	end

	return filtered
end

local function cache_recipes(output)
	local recipes = M.get_all_craft_recipes(output) or {}
	local c = 0

	for i = 1, #custom_crafts do
		local custom_craft = custom_crafts[i]
		if match(custom_craft.output, "%S*") == output then
			c = c + 1
			recipes[c] = custom_craft
		end
	end

	if #recipes > 0 then
		recipes_cache[output] = recipes
		return true
	end
end

local function get_recipes(item, data, player)
	local recipes = recipes_cache[item]
	local usages = usages_cache[item]

	if recipes then
		recipes = apply_recipe_filters(recipes, player)
	end

	if recipes and fuel_cache[item] then
		recipes = copy(recipes)
		recipes[#recipes + 1] = {type = "fuel", width = 1, items = {item}}
	end

	local no_recipes = not recipes or #recipes == 0
	if no_recipes and not usages then
		return
	elseif usages and no_recipes then
		data.show_usages = true
	end

	if data.show_usages then
		recipes = apply_recipe_filters(usages_cache[item], player)
		if #recipes == 0 then
			return
		end
	end

	return recipes
end

local function get_recipe_type_label(recipe_type)
	if recipe_type == "normal" then
		return S("Crafting")
	elseif recipe_type == "cooking" then
		return S("Smelting")
	elseif recipe_type == "fuel" then
		return S("Fuel")
	end

	local custom_recipe = craft_types[recipe_type]
	return custom_recipe and custom_recipe.description or recipe_type
end

local function set_recipe_list(data, recipes, recipe_type)
	data.all_recipes = recipes
	data.recipe_types = {}

	if not recipes or #recipes == 0 then
		data.selected_recipe_type = nil
		data.recipes = nil
		data.rnum = 1
		return
	end

	local available_types = {}
	for i = 1, #recipes do
		local current_type = recipes[i].type or "normal"
		if not available_types[current_type] then
			available_types[current_type] = true
			data.recipe_types[#data.recipe_types + 1] = current_type
		end
	end

	recipe_type = available_types[recipe_type] and recipe_type or data.recipe_types[1]
	data.selected_recipe_type = recipe_type
	data.recipes = {}

	for i = 1, #recipes do
		local recipe = recipes[i]
		if (recipe.type or "normal") == recipe_type then
			data.recipes[#data.recipes + 1] = recipe
		end
	end

	data.rnum = min(data.rnum or 1, #data.recipes)
	if data.rnum == 0 then
		data.rnum = 1
	end
end

local function get_burntime(item)
	return get_result({ method = "fuel", width = 1, items = { item } }).time
end

local function cache_fuel(item)
	local burntime = get_burntime(item)
	if burntime > 0 then
		fuel_cache[item] = burntime
		return true
	end
end

local function groups_to_item(groups)
	if #groups == 1 then
		local group = groups[1]
		local def_gr = "mcl_core:" .. group

		if group_stereotypes[group] then
			return group_stereotypes[group]
		elseif reg_items[def_gr] then
			return def_gr
		end
	end

	for name, def in pairs(reg_items) do
		if item_has_groups(def.groups, groups) then
			return name
		end
	end

	return ""
end

local function get_tooltip(item, groups, cooktime, burntime)
	local tooltip

	if groups then
		local gcol = mcl_colors.LIGHT_PURPLE
		if #groups == 1 then
			local g = group_names[groups[1]]
			local groupstr
			-- Treat the groups “compass” and “clock” as fake groups
			-- and just print the normal item name without special formatting
			if groups[1] == "compass" or groups[1] == "clock" then
				groupstr = reg_items[item].description
			elseif g then
				-- Use the special group name string
				groupstr = minetest.colorize(gcol, g)
			else
				--[[ Fallback: Generic group explanation: This always
				works, but the internally used group name (which
				looks ugly) is exposed to the user. ]]
				groupstr = minetest.colorize(gcol, groups[1])
				groupstr = S("Any item belonging to the @1 group", groupstr)
			end
			tooltip = groupstr
		else

			local group_table, c = {}, 0
			for i = 1, #groups do
				c = c + 1
				group_table[c] = colorize(gcol, groups[i])
			end

			groupstr = concat(group_table, ", ")
			tooltip = S("Any item belonging to the groups: @1", groupstr)
		end
	else
		tooltip = reg_items[item].description
	end

	if not groups and cooktime then
		tooltip = tooltip .. "\n" ..
			S("Cooking time: @1", colorize(mcl_colors.YELLOW, cooktime))
	end

	if not groups and burntime then
		tooltip = tooltip .. "\n" ..
			S("Burning time: @1", colorize(mcl_colors.YELLOW, burntime))
	end

	return fmt("tooltip[%s;%s]", item, ESC(tooltip))
end

local function get_recipe_fs(data, iY)
	local fs = {}
	local recipe = data.recipes[data.rnum]
	local width = recipe.width
	local xoffset = data.iX / 2.15
	local cooktime, shapeless
	iY = iY + 1.05

	if data.recipe_types and #data.recipe_types > 0 then
		local btn_w = 1.8
		local gap = 0.1
		local total_w = (#data.recipe_types * btn_w) + ((#data.recipe_types - 1) * gap)
		local start_x = max(0.3, (data.iX - total_w) / 2)

		for i = 1, #data.recipe_types do
			local recipe_type = data.recipe_types[i]
			local label = get_recipe_type_label(recipe_type)

			local tab_x = start_x + (i - 1) * (btn_w + gap)

			if recipe_type == data.selected_recipe_type then
				fs[#fs + 1] = fmt(
					"style[rtype_%d;border=false;" ..
					"bgimg=mcl_inventory_button9_pressed.png;" ..
					"bgimg_pressed=mcl_inventory_button9_pressed.png;" ..
					"bgimg_middle=2,2]",
					i)
			end

			fs[#fs + 1] = fmt(FMT.button,
				FORM_PADDING + tab_x * FORM_SPACING_X,
				FORM_PADDING + iY * FORM_SPACING_Y + 0.4 - FORM_BUTTON_HEIGHT / 2,
				btn_w * FORM_SPACING_X - (FORM_SPACING_X - 1),
				FORM_BUTTON_HEIGHT,
				fmt("rtype_%d", i),
				ESC(label))
		end
	end

	iY = iY - 0.37

	local visible_items = {}
	for i = 1, #data.items_raw do
		visible_items[data.items_raw[i]] = true
	end

	local supported_stations = {}
	for i = 1, #stations do
		local station = stations[i]
		if visible_items[station.item_name] and station.is_recipe_supported(recipe) then
			supported_stations[#supported_stations + 1] = station
		end
	end

	if #supported_stations > 0 then
		local station_fs = {}
		for i = 1, #supported_stations do
			local station = supported_stations[i]
			local station_x = (i - 1) % 2 * 0.8
			local station_y = floor((i - 1) / 2) * 0.8
			station_fs[#station_fs + 1] = fmt(
				"item_image_button[%f,%f;%f,%f;%s;%s;%s]",
				station_x,
				station_y,
				0.75,
				0.75,
				station.item_name,
				station.item_name,
				"")
			end

		local station_x = FORM_PADDING
		local station_y = FORM_PADDING + (iY + 1.25) * FORM_SPACING_Y
		fs[#fs + 1] = fmt(
			"scroll_container[%f,%f;2.1,3.2;station_scroll;vertical;0.8]",
			station_x,
			station_y)
		fs[#fs + 1] = concat(station_fs)
		fs[#fs + 1] = "scroll_container_end[]"

		if #supported_stations > 8 then
			local station_rows = ceil(#supported_stations / 2)
			fs[#fs + 1] = fmt(
				"scrollbaroptions[min=0;max=%d;smallstep=1;largestep=4;arrows=hide]",
				station_rows - 4)
			fs[#fs + 1] = fmt(
				"scrollbar[%f,%f;0.35,3.2;vertical;station_scroll;0]",
				station_x + 1.7,
				station_y)
		end
	end

	if recipe.type == "cooking" then
		cooktime, width = width, 1
	elseif width == 0 then
		shapeless = true
		if #recipe.items <= 4 then
			width = 2
		else
			width = min(3, #recipe.items)
		end
	end

	local rows = ceil(maxn(recipe.items) / width)
	local rightest, btn_size, s_btn_size = 0, 1.1, nil

	local btn_lab = data.show_usages and
		ESC(S("Usage @1 of @2", data.rnum, #data.recipes)) or
		ESC(S("Recipe @1 of @2", data.rnum, #data.recipes))

	local favorite_item = data.query_item and data.favorite_items and
		data.favorite_items[data.query_item]

	if data.query_item then
		fs[#fs + 1] = fmt(FMT.image_button,
			FORM_PADDING + (data.iX - 1.2) * FORM_SPACING_X,
			FORM_PADDING + (iY + 2.35) * FORM_SPACING_Y,
			0.8 * FORM_SPACING_X - (FORM_SPACING_X - 1),
			0.8 * FORM_SPACING_Y - (FORM_SPACING_Y - 1),
			favorite_item and
				"mcl_end_ender_eye.png" or "mcl_throwing_ender_pearl.png",
			"toggle_item_favorite",
			"")
		fs[#fs + 1] = fmt("tooltip[%s;%s]",
			"toggle_item_favorite",
			ESC(favorite_item and S("Unfavorite") or S("Favorite")))
	end

	fs[#fs + 1] = fmt(FMT.image_button,
		FORM_PADDING + (data.iX - 3.4) * FORM_SPACING_X,
		FORM_PADDING + (iY + 3.3) * FORM_SPACING_Y,
		0.8 * FORM_SPACING_X - (FORM_SPACING_X - 1),
		0.8 * FORM_SPACING_Y - (FORM_SPACING_Y - 1),
		"craftguide_prev_icon.png",
		"recipe_prev",
		"")

	fs[#fs + 1] = fmt(FMT.label,
		FORM_PADDING + (data.iX - 2.65) * FORM_SPACING_X,
		(iY + 3.4) * FORM_SPACING_Y + 77 / 104,
		btn_lab)

	fs[#fs + 1] = fmt(FMT.image_button,
		FORM_PADDING + (data.iX - 1.2) * FORM_SPACING_X,
		FORM_PADDING + (iY + 3.3) * FORM_SPACING_Y,
		0.8 * FORM_SPACING_X - (FORM_SPACING_X - 1),
		0.8 * FORM_SPACING_Y - (FORM_SPACING_Y - 1),
		"craftguide_next_icon.png",
		"recipe_next",
		"")

	if width > GRID_LIMIT or rows > GRID_LIMIT then
		fs[#fs + 1] = fmt(FMT.label,
			FORM_PADDING + ((data.iX / 2) - 2) * FORM_SPACING_X,
			(iY + 2.2) * FORM_SPACING_Y + 77 / 104,
			ESC(S("Recipe is too big to be displayed (@1×@2)", width, rows)))

		return concat(fs)
	end

	for i, item in pairs(recipe.items) do
		local X = (i - 1) % width + xoffset - width - 0.2
		local Y = ceil(i / width) + (iY + 2) - min(2, rows)

		if width > 3 or rows > 3 then
			btn_size = width > 3 and 3 / width or 3 / rows
			s_btn_size = btn_size
			X = btn_size * (i % width) + xoffset - 2.65
			Y = btn_size * floor((i - 1) / width) + (iY + 2) - min(2, rows)
		end

		if X > rightest then
			rightest = X
		end

		local groups
		if sub(item, 1, 6) == "group:" then
			groups = extract_groups(item)
			item = groups_to_item(groups)
		end

		local label = ""
		if groups and (#groups >= 1 and groups[1] ~= "compass" and groups[1] ~= "clock") then
			label = "\nG"
		end

		fs[#fs + 1] = fmt(FMT.item_image_button,
			FORM_PADDING + X * FORM_SPACING_X,
			FORM_PADDING + (Y + 0.2) * FORM_SPACING_Y,
			btn_size * FORM_SPACING_X - (FORM_SPACING_X - 1),
			btn_size * FORM_SPACING_Y - (FORM_SPACING_Y - 1),
			item,
			match(item, "%S*"),
			ESC(label))

		local burntime = fuel_cache[item]

		if groups or cooktime or burntime then
			fs[#fs + 1] = get_tooltip(item, groups, cooktime, burntime)
		end
	end

	local custom_recipe = craft_types[recipe.type]

	if custom_recipe or shapeless or recipe.type == "cooking" then
		local icon = custom_recipe and custom_recipe.icon or
			shapeless and "shapeless" or "furnace"

		if recipe.type == "cooking" then
			icon = "craftguide_furnace.png"
		elseif not custom_recipe then
			icon = fmt("craftguide_%s.png", icon)
		end

		fs[#fs + 1] = fmt(FMT.image,
			FORM_PADDING + (rightest + 1.2) * FORM_SPACING_X,
			FORM_PADDING + (iY + 1.7) * FORM_SPACING_Y,
			0.5,
			0.5,
			icon)

		local tooltip = custom_recipe and custom_recipe.description or
			shapeless and S("Shapeless") or S("Cooking")

		fs[#fs + 1] = fmt("tooltip[%f,%f;%f,%f;%s]",
			FORM_PADDING + (rightest + 1.2) * FORM_SPACING_X,
			FORM_PADDING + (iY + 1.7) * FORM_SPACING_Y,
			0.5 * FORM_SPACING_X,
			0.5 * FORM_SPACING_Y,
			ESC(tooltip))
	end

	local arrow_X  = rightest + (s_btn_size or 1.1)
	local output_X = arrow_X + 0.9

	fs[#fs + 1] = fmt(FMT.image,
		FORM_PADDING + arrow_X * FORM_SPACING_X,
		FORM_PADDING + (iY + 2.35) * FORM_SPACING_Y,
		0.9,
		0.7,
		"craftguide_arrow.png")

	if recipe.type == "fuel" then
		local fuel_name = match(recipe.items[1], "%S+")
		local burntime = fuel_cache[fuel_name]

		if burntime then
			fs[#fs + 1] = fmt(FMT.label,
				FORM_PADDING + (output_X + 0.1) * FORM_SPACING_X,
				(iY + 1.78) * FORM_SPACING_Y + 77 / 104,
				ESC(colorize(mcl_colors.YELLOW, burntime)))
		end

		fs[#fs + 1] = fmt(FMT.image,
			FORM_PADDING + output_X * FORM_SPACING_X,
			FORM_PADDING + (iY + 2.18) * FORM_SPACING_Y,
			1.1,
			1.1,
			"mcl_craftguide_fuel.png")
	else
		local output_name = match(recipe.output, "%S+")

		fs[#fs + 1] = fmt(FMT.item_image_button,
			FORM_PADDING + output_X * FORM_SPACING_X,
			FORM_PADDING + (iY + 2.2) * FORM_SPACING_Y,
			1.1 * FORM_SPACING_X - (FORM_SPACING_X - 1),
			1.1 * FORM_SPACING_Y - (FORM_SPACING_Y - 1),
			recipe.output,
			ESC(output_name),
			"")
	end

	return concat(fs)
end

local function make_formspec(name)
	local data = get_player_data(name)
	local iY = data.iX - 5
	local ipp = data.iX * iY

	data.pagemax = max(1, ceil(#data.items / ipp))

	local fs = {}
	local form_w = (data.iX - 0.35) * FORM_SPACING_X + 0.5
	local form_h = (iY + 4.55) * FORM_SPACING_Y + 45 / 52
	local toolbar_y = FORM_PADDING + 0.12 * FORM_SPACING_Y
	local toolbar_w = 0.8 * FORM_SPACING_X - (FORM_SPACING_X - 1)
	local toolbar_h = 0.8 * FORM_SPACING_Y - (FORM_SPACING_Y - 1)

	fs[#fs + 1] = "formspec_version[10]"
	fs[#fs + 1] = fmt("size[%f,%f;]", form_w, form_h)

	fs[#fs + 1] = fmt(
		"background9[0,0;%f,%f;mcl_base_textures_background9.png;false;7]",
		form_w,
		form_h)

	fs[#fs + 1] = fmt([[ tooltip[size_inc;%s]
					tooltip[size_dec;%s] ]],
		ESC(S("Increase window size")),
		ESC(S("Decrease window size")))

	fs[#fs + 1] = fmt(FMT.image_button,
		FORM_PADDING + data.iX * 0.47 * FORM_SPACING_X,
		toolbar_y,
		toolbar_w,
		toolbar_h,
		"craftguide_zoomin_icon.png", "size_inc", "")
	fs[#fs + 1] = fmt(FMT.image_button,
		FORM_PADDING + (data.iX * 0.47 + 0.6) * FORM_SPACING_X,
		toolbar_y,
		toolbar_w,
		toolbar_h,
		"craftguide_zoomout_icon.png", "size_dec", "")

	fs[#fs + 1] = fmt(FMT.image_button,
		FORM_PADDING + 2.4 * FORM_SPACING_X,
		toolbar_y,
		toolbar_w,
		toolbar_h,
		"craftguide_search_icon.png", "search", "")
	fs[#fs + 1] = fmt(FMT.image_button,
		FORM_PADDING + 3.05 * FORM_SPACING_X,
		toolbar_y,
		toolbar_w,
		toolbar_h,
		"craftguide_clear_icon.png", "clear", "")
	fs[#fs + 1] = fmt(FMT.image_button,
		FORM_PADDING + 3.7 * FORM_SPACING_X,
		toolbar_y,
		toolbar_w,
		toolbar_h,
		data.favorites_only and
			"mcl_end_ender_eye.png" or "mcl_throwing_ender_pearl.png",
		"toggle_favorites",
		"")
	fs[#fs + 1] = "field_close_on_enter[filter;false]"
	fs[#fs + 1] = "field_enter_after_edit[filter;true]"

	fs[#fs + 1] = fmt([[ tooltip[filter;%s]
				 tooltip[search;%s]
				 tooltip[clear;%s]
				 tooltip[toggle_favorites;%s]
				 tooltip[prev;%s]
				 tooltip[next;%s] ]],
		ESC(S("Search names and descriptions.") .. "\n" ..
			S("Filter by mod:") .. " @mod\n" ..
			S("Match group names:") .. " +group1,group2 " ..
				S("or") .. " +group1 +group2\n" ..
			S("Require exact groups:") .. " +groups=group1,group2\n" ..
			S("Example:") .. " wood @mcl_core +flammable"),
		ESC(S("Search")),
		ESC(S("Reset")),
		ESC(data.favorites_only and S("Show all items") or S("Show favorite items only")),
		ESC(S("Previous page")),
		ESC(S("Next page")))

	fs[#fs + 1] = fmt(FMT.label,
		FORM_PADDING + (data.iX - 2.2) * FORM_SPACING_X,
		0.22 * FORM_SPACING_Y + 77 / 104,
		ESC(colorize("#383838", fmt("%s / %u", data.pagenum, data.pagemax))))

	fs[#fs + 1] = fmt(FMT.image_button,
		FORM_PADDING + (data.iX - 3.1) * FORM_SPACING_X,
		toolbar_y,
		toolbar_w,
		toolbar_h,
		"craftguide_prev_icon.png", "prev", "")
	fs[#fs + 1] = fmt(FMT.image_button,
		FORM_PADDING + ((data.iX - 1.2) -
			(data.iX >= 11 and 0.08 or 0)) * FORM_SPACING_X,
		toolbar_y,
		toolbar_w,
		toolbar_h,
		"craftguide_next_icon.png",
		"next",
		"")

	fs[#fs + 1] = fmt(
		"field[%f,%f;%f,%f;filter;;%s]",
		0.3 * FORM_SPACING_X,
		0.32 * FORM_SPACING_Y + 0.5 - FORM_BUTTON_HEIGHT / 2,
		2.5 * FORM_SPACING_X - (FORM_SPACING_X - 1),
		FORM_BUTTON_HEIGHT,
		ESC(data.filter))

	if #data.items == 0 then
		local no_item = S("No item to show")
		local pos = (data.iX / 2) - 1

		if next(recipe_filters) and #init_items > 0 and data.filter == "" then
			no_item = S("Collect items to reveal more recipes")
			pos = pos - 1
		end

		fs[#fs + 1] = fmt(FMT.label,
			FORM_PADDING + pos * FORM_SPACING_X,
			2 * FORM_SPACING_Y + 77 / 104,
			ESC(no_item))
	end

	local first_item = (data.pagenum - 1) * ipp
	for i = first_item, first_item + ipp - 1 do
		local item = data.items[i + 1]
		if not item then
			break
		end

		local X = i % data.iX
		local Y = (i % ipp - X) / data.iX + 1

		fs[#fs + 1] = fmt(FMT.item_image_button,
			FORM_PADDING + (X - X * 0.05) * FORM_SPACING_X,
			FORM_PADDING + Y * FORM_SPACING_Y,
			1.1 * FORM_SPACING_X - (FORM_SPACING_X - 1),
			1.1 * FORM_SPACING_Y - (FORM_SPACING_Y - 1),
			item,
			item .. "_inv",
			"")
	end

	if data.recipes and #data.recipes > 0 then
		fs[#fs + 1] = get_recipe_fs(data, iY)
	end

	for elem_name, def in pairs(formspec_elements) do
		local element = def.element(data)
		if element then
			if find(def.type, "button") then
				insert(element, #element, elem_name)
			end

			if def.api_version == 1 then
				fs[#fs + 1] = ELEMENT_RENDERERS_V1[def.type](unpack(element))
			else
				fs[#fs + 1] = fmt(FMT[def.type], unpack(element))
			end
		end
	end

	return concat(fs)
end

local function show_fs(player, name)
	show_formspec(name, "mcl_craftguide", make_formspec(name))
end

mcl_craftguide.add_search_filter("groups", function(item, groups)
	local itemdef = reg_items[item]

	for i = 1, #groups do
		if not itemdef.groups[groups[i]] then
			return false
		end
	end

	return true
end)

local function match_group_substrings(item, groups)
	for i = 1, #groups do
		local matches_group
		for item_group, rating in pairs(reg_items[item].groups) do
			if rating > 0 and find(item_group, groups[i], 1, true) then
				matches_group = true
				break
			end
		end
		if not matches_group then
			return false
		end
	end

	return true
end

local function search(data)
	local filter = data.filter

	if not data.favorites_only and searches[filter] then
		data.items = searches[filter]
		return
	end

	local filtered_list, c = {}, 0
	local filters = {}
	local group_substrings = {}
	local mod_prefix
	local text_words = {}

	for word in gmatch(filter, "%S+") do
		local filter_name, values = match(word, "^%+([%w_]+)=([%w_,]+)$")
		local groups = match(word, "^%+([%w_,]+)$")

		if filter_name and search_filters[filter_name] then
			values = split(values, ",")
			filters[filter_name] = filters[filter_name] or {}
			table_merge(filters[filter_name], values)
		elseif groups then
			table_merge(group_substrings, split(groups, ","))
		elseif sub(word, 1, 1) == "@" and #word > 1 then
			mod_prefix = sub(word, 2)
		else
			text_words[#text_words + 1] = word
		end
	end
	local text_filter = concat(text_words, " ")

	for i = 1, #data.items_raw do
		local item = data.items_raw[i]
		local def  = reg_items[item]
		local desc = string.lower(M.get_translated_string(data.lang_code, def.description))
		local search_in = item .. desc
		local item_mod = match(item, "^[^:]+") or ""
		local matches_mod = not mod_prefix or find(item_mod, mod_prefix, 1, true)
		local to_add = matches_mod and
			(text_filter == "" or find(search_in, text_filter, 1, true))

		if next(filters) then
			for filter_name, values in pairs(filters) do
				local func = search_filters[filter_name]
				to_add = to_add and func(item, values)
			end
		end
		if #group_substrings > 0 then
			to_add = to_add and match_group_substrings(item, group_substrings)
		end

		if to_add then
			c = c + 1
			filtered_list[c] = item
		end
	end

	if not next(recipe_filters) and not data.favorites_only then
		-- Cache the results only if searched 2 times
		if searches[filter] == nil then
			searches[filter] = false
		else
			searches[filter] = filtered_list
		end
	end

	data.items = filtered_list
end

local function refresh_items(data, player)
	data.items_raw = get_player_items(data, player)

	if data.filter ~= "" then
		search(data)
	else
		data.items = data.items_raw
	end

	if data.query_item and table.indexof(data.items_raw, data.query_item) == -1 then
		data.query_item = nil
		data.show_usages = nil
		data.all_recipes = nil
		data.recipe_types = nil
		data.selected_recipe_type = nil
		data.recipes = nil
		data.rnum = 1
	end
end

local function get_inv_items(player)
	local inv = player:get_inventory()
	local stacks = {}

	for i = 1, #item_lists do
		local list = inv:get_list(item_lists[i])
		table_merge(stacks, list)
	end

	local inv_items, c = {}, 0

	for i = 1, #stacks do
		local stack = stacks[i]
		if not stack:is_empty() then
			local name = stack:get_name()
			if reg_items[name] then
				c = c + 1
				inv_items[c] = name
			end
		end
	end

	return inv_items
end

local function reset_data(data)
	data.filter      = ""
	data.pagenum     = 1
	data.rnum        = 1
	data.query_item  = nil
	data.show_usages = nil
	data.all_recipes = nil
	data.recipe_types = nil
	data.selected_recipe_type = nil
	data.recipes     = nil
end

local function cache_usages()
	for i = 1, #init_items do
		local item = init_items[i]
		usages_cache[item] = get_item_usages(item)
	end
end

local function get_init_items()
	local c = 0
	for name, def in pairs(reg_items) do
		local is_fuel = cache_fuel(name)
		if not (def.groups.not_in_craft_guide == 1) and
			def.description and def.description ~= "" and
			(cache_recipes(name) or is_fuel) then
			c = c + 1
			init_items[c] = name
		end
	end

	sort(init_items)
	cache_usages()
end

local function on_receive_fields(player, fields)
	local name = player:get_player_name()
	local data = get_player_data(name)
	local recipe_tab
	local search_submitted = fields.key_enter_field == "filter" or fields.search

	for elem_name, def in pairs(formspec_elements) do
		if fields[elem_name] and def.action then
			return def.action(player, data)
		end
	end

	for field in pairs(fields) do
		recipe_tab = match(field, "^rtype_(%d+)$")
		if recipe_tab then
			break
		end
	end

	if fields.clear or (search_submitted and (fields.filter or "") == "") then
		reset_data(data)
		refresh_items(data, player)
		show_fs(player, name)

	elseif fields.recipe_prev or fields.recipe_next then
		if #data.recipes == 1 then
			return
		end

		data.rnum = data.rnum + (fields.recipe_next and 1 or -1)
		if data.rnum > #data.recipes then
			data.rnum = 1
		elseif data.rnum < 1 then
			data.rnum = #data.recipes
		end

		show_fs(player, name)

	elseif recipe_tab then
		local tab_idx = tonumber(recipe_tab)
		local recipe_type = tab_idx and data.recipe_types and data.recipe_types[tab_idx]
		if not recipe_type or recipe_type == data.selected_recipe_type then
			return
		end

		data.rnum = 1
		set_recipe_list(data, data.all_recipes, recipe_type)
		show_fs(player, name)

	elseif fields.toggle_favorites then
		data.favorites_only = not data.favorites_only
		data.pagenum = 1
		refresh_items(data, player)
		show_fs(player, name)

	elseif fields.toggle_item_favorite and data.query_item then
		local item = data.query_item
		if data.favorite_items[item] then
			data.favorite_items[item] = nil
		else
			data.favorite_items[item] = true
		end

		refresh_items(data, player)
		show_fs(player, name)

	elseif search_submitted then
		local fltr = lower(fields.filter)
		if data.filter == fltr then
			return
		end

		data.filter = fltr
		data.pagenum = 1
		search(data)
		show_fs(player, name)

	elseif fields.prev or fields.next then
		if data.pagemax == 1 then
			return
		end

		data.pagenum = data.pagenum - (fields.prev and 1 or -1)

		if data.pagenum > data.pagemax then
			data.pagenum = 1
		elseif data.pagenum == 0 then
			data.pagenum = data.pagemax
		end

		show_fs(player, name)

	elseif (fields.size_inc and data.iX < MAX_LIMIT) or
		(fields.size_dec and data.iX > MIN_LIMIT) then
		data.pagenum = 1
		data.iX = data.iX + (fields.size_inc and 1 or -1)
		show_fs(player, name)
	else
		local item
		for field in pairs(fields) do
			if find(field, ":") then
				item = field
				break
			end
		end

		if not item then
			return
		elseif sub(item, -4) == "_inv" then
			item = sub(item, 1, -5)
		end

		if item ~= data.query_item then
			data.show_usages = nil
		else
			data.show_usages = not data.show_usages
		end

		local recipes = get_recipes(item, data, player)
		if not recipes then
			return
		end

		data.query_item = item
		data.rnum       = 1
		set_recipe_list(data, recipes)

		show_fs(player, name)
	end
end

M.register_on_mods_loaded(get_init_items)

M.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mcl_craftguide" then
		on_receive_fields(player, fields)
	elseif fields.__mcl_craftguide then
		mcl_craftguide.show(player:get_player_name())
	end
end)

if progressive_mode then
	local function item_in_inv(item, inv_items)
		local inv_items_size = #inv_items

		if sub(item, 1, 6) == "group:" then
			local groups = extract_groups(item)
			for i = 1, inv_items_size do
				local inv_item = reg_items[inv_items[i]]
				if inv_item then
					local item_groups = inv_item.groups
					if item_has_groups(item_groups, groups) then
						return true
					end
				end
			end
		else
			for i = 1, inv_items_size do
				if inv_items[i] == item then
					return true
				end
			end
		end
	end

	local function recipe_in_inv(recipe, inv_items)
		for _, item in pairs(recipe.items) do
			if not item_in_inv(item, inv_items) then
				return
			end
		end

		return true
	end

	local function progressive_filter(recipes, player)
		local name = player:get_player_name()
		local data = get_player_data(name)

		if #data.inv_items == 0 then
			return {}
		end

		local filtered, c = {}, 0
		for i = 1, #recipes do
			local recipe = recipes[i]
			if recipe_in_inv(recipe, data.inv_items) then
				c = c + 1
				filtered[c] = recipe
			end
		end

		return filtered
	end

	-- Workaround. Need an engine call to detect when the contents
	-- of the player inventory changed, instead.
	local function poll_new_items()
		local players = M.get_connected_players()
		for i = 1, #players do
			local player = players[i]
			local name   = player:get_player_name()
			local data   = get_player_data(name)
			local inv_items = get_inv_items(player)
			local diff      = table_diff(inv_items, data.inv_items)

			if #diff > 0 then
				data.inv_items = table_merge(diff, data.inv_items)
			end
		end

		M.after(POLL_FREQ, poll_new_items)
	end

	M.register_on_mods_loaded(function()
		M.after(1, poll_new_items)
	end)

	mcl_craftguide.add_recipe_filter("Default progressive filter", progressive_filter)

	M.register_on_joinplayer(function(player)
		get_player_data(player:get_player_name())
	end)

	local function save_meta(player)
		local meta = player:get_meta()
		local name = player:get_player_name()
		local data = player_data[name]

		if not data then
			return
		end

		local inv_items = data.inv_items or {}
		local favorite_items = data.favorite_items or {}

		meta:set_string("inv_items", serialize(inv_items))
		meta:set_string("favorite_items", serialize(favorite_items))
	end

	M.register_on_leaveplayer(function(player)
		save_meta(player)
		local name = player:get_player_name()
		player_data[name] = nil
	end)

	M.register_on_shutdown(function()
		local players = M.get_connected_players()
		for i = 1, #players do
			local player = players[i]
			save_meta(player)
		end
	end)
else
	M.register_on_joinplayer(function(player)
		get_player_data(player:get_player_name())
	end)

	M.register_on_leaveplayer(function(player)
		local meta = player:get_meta()
		local name = player:get_player_name()
		local data = player_data[name]
		if data then
			meta:set_string("favorite_items", serialize(data.favorite_items or {}))
		end
		player_data[name] = nil
	end)

	M.register_on_shutdown(function()
		local players = M.get_connected_players()
		for i = 1, #players do
			local player = players[i]
			local meta = player:get_meta()
			local name = player:get_player_name()
			local data = player_data[name]
			if data then
				meta:set_string("favorite_items", serialize(data.favorite_items or {}))
			end
		end
	end)
end

function mcl_craftguide.show(name)
	local player = get_player_by_name(name)
	local data = get_player_data(name)
	refresh_items(data, player)
	show_formspec(name, "mcl_craftguide", make_formspec(name))
end

--[[ Custom recipes (>3x3) test code

M.register_craftitem(":secretstuff:custom_recipe_test", {
	description = "Custom Recipe Test",
})

local cr = {}
for x = 1, 6 do
	cr[x] = {}
	for i = 1, 10 - x do
		cr[x][i] = {}
		for j = 1, 10 - x do
			cr[x][i][j] = "group:wood"
		end
	end

	M.register_craft({
		output = "secretstuff:custom_recipe_test",
		recipe = cr[x]
	})
end
]]
