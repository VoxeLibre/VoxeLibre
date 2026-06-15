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

local UI = {
	padding = 0.375, -- 3 / 8
	gap = 0.1,
	button_height = 0.807692, -- 21 / 26
	toolbar_button_width = 0.75, -- 0.8 * 1.25 - (1.25 - 1)
	toolbar_button_height = 0.769231, -- 0.8 * (15 / 13) - ((15 / 13) - 1)
	item_button_width = 1.125, -- 1.1 * 1.25 - (1.25 - 1)
	item_button_height = 1.115385, -- 1.1 * (15 / 13) - ((15 / 13) - 1)
	item_column_step = 1.1875, -- (1 - 0.05) * 1.25
	item_row_step = 1.153846, -- 15 / 13
	recipe_height = 3.2,
	station_width = 2.1,
	station_cell_size = 0.8,
	station_button_size = 0.75,
	tab_size = 0.95,
	tab_wide_width = 2.5,
	tab_icon_size = 0.65,
	tab_icon_padding = 0.15,
	tab_label_gap = 0.1,
	action_button_width = 0.75, -- 0.8 * 1.25 - (1.25 - 1)
	action_button_height = 0.769231, -- 0.8 * (15 / 13) - ((15 / 13) - 1)
}

local function center_start(available_width, content_width, min_x)
	return max(min_x or 0, (available_width - content_width) / 2)
end

local function list_width(count, item_width, gap)
	if count <= 0 then
		return 0
	end
	return count * item_width + (count - 1) * gap
end

local function grid_xy(index, columns, cell_size)
	local column = (index - 1) % columns
	local row = floor((index - 1) / columns)
	return column * cell_size, row * cell_size
end

local function find_selected_tab_index(data, tabs)
	for i = 1, #tabs do
		if tabs[i].name == data.selected_recipe_tab then
			return i
		end
	end
	return 1
end

local function calculate_tab_header(data, tabs, area)
	local wide_width = list_width(#tabs, UI.tab_wide_width, UI.gap)
	if wide_width <= area.w then
		data.recipe_tab_page = nil
		return {
			mode = "wide",
			first = 1,
			last = #tabs,
			button_w = UI.tab_wide_width,
			total_w = wide_width,
		}
	end

	local thin_width = list_width(#tabs, UI.tab_size, UI.gap)
	if thin_width <= area.w then
		data.recipe_tab_page = nil
		return {
			mode = "thin",
			first = 1,
			last = #tabs,
			button_w = UI.tab_size,
			total_w = thin_width,
		}
	end

	local arrow_space = 2 * UI.tab_size + 2 * UI.gap
	local tabs_width = max(0, area.w - arrow_space)
	local tabs_per_page = max(1,
		floor((tabs_width + UI.gap) / (UI.tab_size + UI.gap)))
	local page_count = ceil(#tabs / tabs_per_page)
	local selected_index = find_selected_tab_index(data, tabs)
	local selected_page = ceil(selected_index / tabs_per_page)
	local page = data.recipe_tab_page or selected_page
	page = min(page_count, max(1, page))
	data.recipe_tab_page = page

	local first = (page - 1) * tabs_per_page + 1
	local last = min(#tabs, first + tabs_per_page - 1)
	return {
		mode = "pages",
		first = first,
		last = last,
		button_w = UI.tab_size,
		total_w = list_width(last - first + 1, UI.tab_size, UI.gap),
		page = page,
		page_count = page_count,
		arrow_prev_x = area.x,
		arrow_next_x = area.x + area.w - UI.tab_size,
		tabs_x = area.x + UI.tab_size + UI.gap,
		tabs_w = tabs_width,
	}
end

local function calculate_layout(data)
	local columns = data.iX
	local rows = columns - 5

	local form_width = (columns - 0.35) * FORM_SPACING_X + 0.5
		-- Legacy: (data.iX - 0.35) * 1.25 + 0.5
	local form_height = (rows + 4.55) * FORM_SPACING_Y + 45 / 52
		-- Legacy: (iY + 4.55) * (15 / 13) + 45 / 52
	local toolbar_y = FORM_PADDING + 0.12 * FORM_SPACING_Y
		-- Legacy: 0.375 + 0.12 * (15 / 13)
	local item_grid_y = FORM_PADDING + FORM_SPACING_Y
		-- Legacy first row: 0.375 + 1 * (15 / 13)
	local tabs_y = FORM_PADDING + (rows + 1.05) * FORM_SPACING_Y +
		0.4 - FORM_BUTTON_HEIGHT / 2
		-- Legacy: 0.375 + (iY + 1.05) * (15 / 13)
		--   + 0.4 - (21 / 26) / 2
	local recipe_base_row = rows + 0.68
		-- Legacy: iY + 1.05 - 0.37
	local recipe_y = FORM_PADDING + (recipe_base_row + 1.25) * FORM_SPACING_Y
		-- Legacy: 0.375 + (iY + 1.25) * (15 / 13)
	local actions_x = FORM_PADDING + (columns - 1.2) * FORM_SPACING_X
		-- Legacy: 0.375 + (data.iX - 1.2) * 1.25
	local content_x = FORM_PADDING + UI.station_width + UI.gap
		-- Legacy: station_x + 2.2
	local content_width = max(1, actions_x - content_x - 0.2)
		-- Legacy: max(1, right_x - (station_x + 2.2) - 0.2)
	local recipe_nav_y = FORM_PADDING + (recipe_base_row + 3.45) * FORM_SPACING_Y
		-- Legacy: 0.375 + (iY + 3.45) * (15 / 13)
	local recipe_label_y = (recipe_base_row + 3.4) * FORM_SPACING_Y + 77 / 104
		-- Legacy: (iY + 3.4) * (15 / 13) + 77 / 104

	return {
		columns = columns,
		rows = rows,
		items_per_page = columns * rows, -- Legacy: data.iX * iY
		form = { w = form_width, h = form_height },
		toolbar = {
			y = toolbar_y,
			button_w = UI.toolbar_button_width,
			button_h = UI.toolbar_button_height,
			zoom_in_x = FORM_PADDING + columns * 0.47 * FORM_SPACING_X,
				-- Legacy: 0.375 + data.iX * 0.47 * 1.25
			zoom_out_x = FORM_PADDING + (columns * 0.47 + 0.6) * FORM_SPACING_X,
				-- Legacy: 0.375 + (data.iX * 0.47 + 0.6) * 1.25
			search_x = FORM_PADDING + 2.4 * FORM_SPACING_X,
				-- Legacy: 0.375 + 2.4 * 1.25
			clear_x = FORM_PADDING + 3.05 * FORM_SPACING_X,
				-- Legacy: 0.375 + 3.05 * 1.25
			favorites_x = FORM_PADDING + 3.7 * FORM_SPACING_X,
				-- Legacy: 0.375 + 3.7 * 1.25
			page_label_x = FORM_PADDING + (columns - 2.2) * FORM_SPACING_X,
				-- Legacy: 0.375 + (data.iX - 2.2) * 1.25
			page_label_y = 0.992308,
				-- Legacy: 0.22 * (15 / 13) + 77 / 104
			page_prev_x = FORM_PADDING + (columns - 3.1) * FORM_SPACING_X,
				-- Legacy: 0.375 + (data.iX - 3.1) * 1.25
			page_next_x = FORM_PADDING + ((columns - 1.2) -
				(columns >= 11 and 0.08 or 0)) * FORM_SPACING_X,
				-- Legacy: 0.375 + ((data.iX - 1.2)
				--   - (data.iX >= 11 and 0.08 or 0)) * 1.25
			filter_x = 0.375, -- Legacy: 0.3 * 1.25
			filter_y = 0.465385,
				-- Legacy: 0.32 * (15 / 13) + 0.5 - (21 / 26) / 2
			filter_w = 2.875,
				-- Legacy: 2.5 * 1.25 - (1.25 - 1)
		},
		items = {
			x = FORM_PADDING,
			y = item_grid_y,
			column_step = UI.item_column_step,
			row_step = UI.item_row_step,
			button_w = UI.item_button_width,
			button_h = UI.item_button_height,
			empty_label_y = 3.048077,
				-- Legacy: 2 * (15 / 13) + 77 / 104
		},
		tabs = {
			x = FORM_PADDING,
			y = tabs_y,
			w = form_width - 2 * FORM_PADDING,
			h = UI.tab_size,
		},
		stations = {
			x = FORM_PADDING,
			y = recipe_y,
			w = UI.station_width,
			h = UI.recipe_height,
		},
		content = {
			x = content_x,
			y = recipe_y,
			w = content_width,
			h = UI.recipe_height,
		},
		actions = {
			x = actions_x,
			w = UI.action_button_width,
			h = UI.action_button_height,
			first_y = FORM_PADDING + (recipe_base_row + 1.3) * FORM_SPACING_Y,
				-- Legacy: 0.375 + (iY + 1.3) * (15 / 13)
			second_y = FORM_PADDING + (recipe_base_row + 2.0) * FORM_SPACING_Y,
				-- Legacy: 0.375 + (iY + 2.0) * (15 / 13)
			favorite_y = FORM_PADDING + (recipe_base_row + 2.7) * FORM_SPACING_Y,
				-- Legacy: 0.375 + (iY + 2.7) * (15 / 13)
		},
		recipe_nav = {
			y = recipe_nav_y,
			prev_x = FORM_PADDING + (columns - 3.4) * FORM_SPACING_X,
				-- Legacy: 0.375 + (data.iX - 3.4) * 1.25
			label_x = FORM_PADDING + (columns - 2.65) * FORM_SPACING_X,
				-- Legacy: 0.375 + (data.iX - 2.65) * 1.25
			label_y = recipe_label_y,
			next_x = actions_x,
		},
	}
end

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

local group_definitions = {
	wood = { description = S("Any wood planks") },
	sand = { description = S("Any sand") },
	wool = { item = "mcl_wool:white", description = S("Any wool") },
	carpet = { item = "mcl_wool:white_carpet", description = S("Any carpet") },
	dye = { item = "mcl_dye:red", description = S("Any dye") },
	water_bucket = {
		item = "mcl_buckets:bucket_water",
		description = S("Any water bucket"),
	},
	flower = {
		item = "mcl_flowers:dandelion",
		description = S("Any flower"),
	},
	mushroom = {
		item = "mcl_mushrooms:mushroom_brown",
		description = S("Any mushroom"),
	},
	wood_slab = {
		item = "mcl_stairs:slab_wood",
		description = S("Any wooden slab"),
	},
	wood_stairs = {
		item = "mcl_stairs:stairs_wood",
		description = S("Any wooden stairs"),
	},
	coal = { description = S("Any coal") },
	shulker_box = {
		item = "mcl_chests:violet_shulker_box",
		description = S("Any shulker box"),
	},
	quartz_block = {
		item = "mcl_nether:quartz_block",
		description = S("Any kind of quartz block"),
	},
	banner = { item = "mcl_banners:banner_item_white" },
	mesecon_conductor_craftable = { item = "mesecons:wire_00000000_off" },
	purpur_block = {
		item = "mcl_end:purpur_block",
		description = S("Any kind of purpur block"),
	},
	normal_sandstone = { description = S("Any normal sandstone") },
	red_sandstone = { description = S("Any red sandstone") },
	tree = { description = S("Any wood") },
	stonebrick = { description = S("Any stone bricks") },
	stick = { description = S("Any stick") },
}

function mcl_craftguide.register_group(name, def)
	local func = "mcl_craftguide.register_group(): "
	assert(type(name) == "string" and name ~= "",
		func .. "'name' must be a string")
	assert(type(def) == "table", func .. "'def' must be a table")
	assert(def.item == nil or type(def.item) == "string",
		func .. "'item' must be a string")
	assert(def.description == nil or type(def.description) == "string",
		func .. "'description' must be a string")
	assert(def.is_item == nil or type(def.is_item) == "boolean",
		func .. "'is_item' must be a boolean")

	local group_def = group_definitions[name] or {}
	if def.item ~= nil then
		group_def.item = def.item
	end
	if def.description ~= nil then
		group_def.description = def.description
	end
	if def.is_item ~= nil then
		group_def.is_item = def.is_item
	end
	group_definitions[name] = group_def
end



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
		tab_state = {},
		recipe_tab_page = nil,
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
local recipe_tabs, recipe_tab_order = {}, {}
local recipe_tab_contributions = {}
local render_grid_recipe

local function validate_recipe_provider(func, def, required)
	assert(def.get_recipes == nil or type(def.get_recipes) == "function",
		func .. "'get_recipes' must be a function")
	assert(def.get_items == nil or type(def.get_items) == "function",
		func .. "'get_items' must be a function")
	assert(def.is_recipe == nil or type(def.is_recipe) == "function",
		func .. "'is_recipe' must be a function")
	assert(def.is_visible == nil or type(def.is_visible) == "function",
		func .. "'is_visible' must be a function")
	assert(not required or def.get_recipes or def.is_recipe,
		func .. "either 'get_recipes' or 'is_recipe' is required")
end

local function registration_source()
	return M.get_current_modname() or "<unknown>"
end

function mcl_craftguide.register_tab(name, def)
	local func = "mcl_craftguide.register_tab(): "
	assert(type(name) == "string" and name ~= "", func .. "'name' must be a string")
	assert(type(def) == "table", func .. "'def' must be a table")
	assert(type(def.description) == "string", func .. "'description' must be a string")
	assert(def.icon == nil or type(def.icon) == "string",
		func .. "'icon' must be a string")
	assert(type(def.build) == "function", func .. "'build' function missing")
	assert(def.handle == nil or type(def.handle) == "function",
		func .. "'handle' must be a function")
	validate_recipe_provider(func, def, false)

	if recipe_tabs[name] then
		M.log("warning", fmt(
			"[mcl_craftguide] Replacing recipe tab '%s' registered by '%s' with definition from '%s'",
			name, recipe_tabs[name].source_mod, registration_source()))
	else
		recipe_tab_order[#recipe_tab_order + 1] = name
	end

	recipe_tabs[name] = {
		name = name,
		description = def.description,
		icon = def.icon,
		get_recipes = def.get_recipes,
		get_items = def.get_items,
		is_recipe = def.is_recipe,
		build = def.build,
		handle = def.handle,
		is_visible = def.is_visible,
		source_mod = registration_source(),
	}
end

function mcl_craftguide.register_tab_recipes(tab_name, contribution_name, def)
	local func = "mcl_craftguide.register_tab_recipes(): "
	assert(type(tab_name) == "string" and tab_name ~= "",
		func .. "'tab_name' must be a string")
	assert(type(contribution_name) == "string" and contribution_name ~= "",
		func .. "'contribution_name' must be a string")
	assert(type(def) == "table", func .. "'def' must be a table")
	validate_recipe_provider(func, def, true)

	local contributions = recipe_tab_contributions[tab_name]
	if not contributions then
		contributions = { order = {}, definitions = {} }
		recipe_tab_contributions[tab_name] = contributions
	end

	local previous = contributions.definitions[contribution_name]
	if previous then
		M.log("warning", fmt(
			"[mcl_craftguide] Replacing contribution '%s' for recipe tab '%s' registered by '%s' with definition from '%s'",
			contribution_name, tab_name, previous.source_mod, registration_source()))
	else
		contributions.order[#contributions.order + 1] = contribution_name
	end

	contributions.definitions[contribution_name] = {
		get_recipes = def.get_recipes,
		get_items = def.get_items,
		is_recipe = def.is_recipe,
		is_visible = def.is_visible,
		source_mod = registration_source(),
	}
end

function mcl_craftguide.get_tab(name)
	local tab = recipe_tabs[name]
	return tab and copy(tab)
end

function mcl_craftguide.get_tabs()
	local tabs = {}
	for i = 1, #recipe_tab_order do
		local name = recipe_tab_order[i]
		tabs[name] = copy(recipe_tabs[name])
	end
	return tabs
end

function mcl_craftguide.register_craft_type(name, def)
	local func = "mcl_craftguide.register_craft_type(): "
	assert(name, func .. "'name' field missing")
	assert(def.description, func .. "'description' field missing")
	assert(def.icon, func .. "'icon' field missing")

	craft_types[name] = def
	mcl_craftguide.register_tab(name, {
		description = def.description,
		icon = def.icon,
		is_recipe = function(recipe)
			return recipe.type == name
		end,
		build = function(ctx)
			return render_grid_recipe(ctx, def)
		end,
	}, recipe_tabs[name] ~= nil)
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
	assert(def.actions == nil or type(def.actions) == "table",
		func .. "'actions' must be a table")
	assert(def.on_action == nil or type(def.on_action) == "function",
		func .. "'on_action' must be a function")
	assert(not def.actions or #def.actions <= 2,
		func .. "at most two actions are supported")
	assert(not def.actions or #def.actions == 0 or def.on_action,
		func .. "'on_action' is required with 'actions'")

	local action_names = {}
	for i = 1, #(def.actions or {}) do
		local action = def.actions[i]
		assert(type(action) == "table",
			func .. "'actions[" .. i .. "]' must be a table")
		assert(type(action.name) == "string" and action.name ~= "",
			func .. "'actions[" .. i .. "].name' must be a non-empty string")
		assert(not action_names[action.name],
			func .. "duplicate action name '" .. action.name .. "'")
		assert(type(action.tooltip) == "string",
			func .. "'actions[" .. i .. "].tooltip' must be a string")
		assert(action.item == nil or
			(type(action.item) == "string" and reg_items[action.item]),
			func .. "'actions[" .. i .. "].item' must be a registered item")
		assert(action.image == nil or type(action.image) == "string",
			func .. "'actions[" .. i .. "].image' must be a string")
		assert(not action.item or not action.image,
			func .. "'actions[" .. i .. "]' cannot define both 'item' and 'image'")
		action_names[action.name] = true
	end

	local station = {
		item_name = item_name,
		is_recipe_supported = def.is_recipe_supported,
		actions = def.actions and copy(def.actions),
		on_action = def.on_action,
	}

	for i = 1, #stations do
		if stations[i].item_name == item_name then
			assert(override,
				func .. "'" .. item_name .. "' is already registered")
			stations[i] = station
			return
		end
	end

	stations[#stations + 1] = station
end

function mcl_craftguide.get_station(item_name)
	for i = 1, #stations do
		local station = stations[i]
		if station.item_name == item_name then
			return copy({
				is_recipe_supported = station.is_recipe_supported,
				actions = station.actions,
				on_action = station.on_action,
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
local search_filter_descriptions = {}

function mcl_craftguide.add_search_filter(name, f, description)
	local func = "mcl_craftguide.add_search_filter(): "
	assert(name, func .. "filter name missing")
	assert(f and type(f) == "function", func .. "filter function missing")
	assert(description == nil or type(description) == "string",
		func .. "description must be a string")

	search_filters[name] = f
	search_filter_descriptions[name] = description
end

function mcl_craftguide.remove_search_filter(name)
	search_filters[name] = nil
	search_filter_descriptions[name] = nil
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

local function append_station_usages(item, usages)
	local station
	for i = 1, #stations do
		if stations[i].item_name == item then
			station = stations[i]
			break
		end
	end

	if not station then
		return
	end

	local included = {}
	for i = 1, #usages do
		included[usages[i]] = true
	end

	for _, recipes in pairs(recipes_cache) do
		for i = 1, #recipes do
			local recipe = recipes[i]
			if not included[recipe] and station.is_recipe_supported(recipe) then
				usages[#usages + 1] = recipe
				included[recipe] = true
			end
		end
	end

	for fuel_item in pairs(fuel_cache) do
		local recipe = { type = "fuel", width = 1, items = { fuel_item } }
		if station.is_recipe_supported(recipe) then
			usages[#usages + 1] = recipe
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

	append_station_usages(item, usages)

	return usages
end

local function for_each_tab_provider(tab_name, callback)
	local tab = recipe_tabs[tab_name]
	if tab then
		callback(tab)
	end

	local contributions = recipe_tab_contributions[tab_name]
	if not contributions then
		return
	end

	for i = 1, #contributions.order do
		local name = contributions.order[i]
		callback(contributions.definitions[name])
	end
end

local function get_filtered_items(player)
	local items, c = {}, 0

	for i = 1, #init_items do
		local item = init_items[i]
		local recipes = recipes_cache[item]
		local usages = usages_cache[item]
		local visible = recipes and #apply_recipe_filters(recipes, player) > 0 or
			usages and #apply_recipe_filters(usages, player) > 0

		if not visible then
			for j = 1, #recipe_tab_order do
				local tab_name = recipe_tab_order[j]
				local tab = recipe_tabs[tab_name]
				for direction = 0, 1 do
					local show_usages = direction == 1
					if not tab.is_visible or
						tab.is_visible(player, item, show_usages) then
						for_each_tab_provider(tab_name, function(provider)
							if visible or not provider.get_recipes or
								provider ~= tab and provider.is_visible and
								not provider.is_visible(
									player, item, show_usages) then
								return
							end
							local provided =
								provider.get_recipes(
									item, show_usages, player) or {}
							visible =
								#apply_recipe_filters(provided, player) > 0
						end)
					end
					if visible then break end
				end
				if visible then break end
			end
		end

		if visible then
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

local function get_cached_recipes(item, show_usages, player)
	local recipes = show_usages and usages_cache[item] or recipes_cache[item]

	if recipes then
		recipes = apply_recipe_filters(recipes, player)
	end

	return recipes
end

local function collect_recipe_tabs(item, show_usages, player)
	local cached = get_cached_recipes(item, show_usages, player) or {}
	local available = {}

	for i = 1, #recipe_tab_order do
		local tab_name = recipe_tab_order[i]
		local tab = recipe_tabs[tab_name]
		local recipes = {}
		local included = {}
		local visible = not tab.is_visible or tab.is_visible(player, item, show_usages)

		if visible then
			for_each_tab_provider(tab_name, function(provider)
				if provider ~= tab and provider.is_visible and
					not provider.is_visible(player, item, show_usages) then
					return
				end

				if provider.get_recipes then
					local provided =
						provider.get_recipes(item, show_usages, player) or {}
					provided = apply_recipe_filters(provided, player)
					for j = 1, #provided do
						local recipe = provided[j]
						if not included[recipe] then
							recipes[#recipes + 1] = recipe
							included[recipe] = true
						end
					end
				elseif provider.is_recipe then
					for j = 1, #cached do
						local recipe = cached[j]
						if not included[recipe] and provider.is_recipe(recipe) then
							recipes[#recipes + 1] = recipe
							included[recipe] = true
						end
					end
				end
			end)
		end

		if #recipes > 0 then
			available[#available + 1] = {
				name = tab_name,
				def = tab,
				recipes = recipes,
			}
		end
	end

	return available
end

local function set_recipe_tabs(data, item, player, preferred_tab)
	local tabs = collect_recipe_tabs(item, data.show_usages, player)
	if #tabs == 0 and not data.show_usages then
		local usage_tabs = collect_recipe_tabs(item, true, player)
		if #usage_tabs > 0 then
			data.show_usages = true
			tabs = usage_tabs
		end
	end

	data.recipe_tabs = tabs
	data.recipe_tab_page = nil
	if #tabs == 0 then
		data.selected_recipe_tab = nil
		data.recipes = nil
		data.rnum = 1
		return false
	end

	local selected
	preferred_tab = preferred_tab or data.selected_recipe_tab
	for i = 1, #tabs do
		if tabs[i].name == preferred_tab then
			selected = tabs[i]
			break
		end
	end
	selected = selected or tabs[1]

	data.selected_recipe_tab = selected.name
	data.recipes = selected.recipes
	data.rnum = min(data.rnum or 1, #data.recipes)
	if data.rnum == 0 then
		data.rnum = 1
	end
	return true
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
		local group_def = group_definitions[group]

		if group_def and group_def.item then
			return group_def.item
		end
	end

	for name, def in pairs(reg_items) do
		if item_has_groups(def.groups, groups) then
			return name
		end
	end

	return ""
end

local function get_tooltip(item, groups, cooktime, burntime, target)
	local tooltip

	if groups then
		local gcol = mcl_colors.LIGHT_PURPLE
		if #groups == 1 then
			local group_def = group_definitions[groups[1]]
			local g = group_def and group_def.description
			local groupstr
			if group_def and group_def.is_item then
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

	return fmt("tooltip[%s;%s]", target or item, ESC(tooltip))
end

local function make_tab_context(data, player, area)
	local recipe = data.recipes[data.rnum]
	local tab = recipe_tabs[data.selected_recipe_tab]
	local tab_state = data.tab_state[data.selected_recipe_tab]
	if not tab_state then
		tab_state = {}
		data.tab_state[data.selected_recipe_tab] = tab_state
	end

	data.recipe_item_fields = {}
	data.recipe_tab_fields = {}
	local item_field_index = 0

	local ctx = {
		player = player,
		item = data.query_item,
		show_usages = data.show_usages == true,
		recipe = recipe,
		recipe_index = data.rnum,
		recipe_count = #data.recipes,
		state = tab_state,
		width = area.w,
		height = area.h,
	}

	function ctx:field_name(name)
		assert(type(name) == "string" and name ~= "",
			"mcl_craftguide tab field name must be a non-empty string")
		local field = "__cg_tab_" .. name:gsub("[^%w_]", "_")
		data.recipe_tab_fields[field] = name
		return field
	end

	function ctx:item_button(x, y, item, options)
		options = options or {}
		local w = options.w or 1.1
		local h = options.h or 1.1
		local groups
		local stack = item

		if type(item) ~= "string" then
			stack = ItemStack(item):to_string()
		end
		if sub(stack, 1, 6) == "group:" then
			groups = extract_groups(stack)
			stack = groups_to_item(groups)
		end

		local item_name = match(stack, "%S+")
		if not item_name or not reg_items[item_name] then
			return ""
		end

		item_field_index = item_field_index + 1
		local field = "__cg_item_" .. item_field_index
		data.recipe_item_fields[field] = item_name

		local label = options.label or ""
		local group_def = groups and #groups == 1 and
			group_definitions[groups[1]]
		if groups and not (group_def and group_def.is_item) then
			label = label .. "\nG"
		end

		local fs = {
			fmt(FMT.item_image_button, x, y, w, h, stack, field, ESC(label)),
		}
		if groups or options.cooktime or options.burntime then
			fs[#fs + 1] = get_tooltip(
				item_name, groups, options.cooktime, options.burntime, field)
		elseif options.tooltip then
			fs[#fs + 1] = fmt(FMT.tooltip, field, ESC(options.tooltip))
		end
		return concat(fs)
	end

	function ctx:image(x, y, w, h, texture)
		return fmt(FMT.image, x, y, w, h, texture)
	end

	function ctx:label(x, y, text)
		return fmt(FMT.label, x, y, ESC(text))
	end

	function ctx:button(x, y, w, h, name, label)
		return fmt(FMT.button, x, y, w, h, self:field_name(name), ESC(label))
	end

	return ctx, tab
end

render_grid_recipe = function(ctx, craft_type)
	local recipe = ctx.recipe
	local fs = {}
	local width = recipe.width
	local cooktime
	local shapeless

	if recipe.type == "cooking" then
		cooktime, width = width, 1
	elseif width == 0 then
		shapeless = true
		width = #recipe.items <= 4 and 2 or min(3, #recipe.items)
	end

	local rows = ceil(maxn(recipe.items) / width)
	if width > GRID_LIMIT or rows > GRID_LIMIT then
		return ctx:label(0.5, ctx.height / 2,
			S("Recipe is too big to be displayed (@1×@2)", width, rows))
	end

	local button_size = 1.1
	if width > 3 or rows > 3 then
		button_size = width > 3 and 3 / width or 3 / rows
	end

	local grid_w = width * button_size
	local grid_h = rows * button_size
	local total_w = grid_w + 3.1
	local start_x = max(0, (ctx.width - total_w) / 2)
	local start_y = max(0, (ctx.height - grid_h) / 2)

	for i, item in pairs(recipe.items) do
		local x = start_x + ((i - 1) % width) * button_size
		local y = start_y + floor((i - 1) / width) * button_size
		local item_name = match(item, "%S+")
		fs[#fs + 1] = ctx:item_button(x, y, item, {
			w = button_size,
			h = button_size,
			cooktime = cooktime,
			burntime = item_name and fuel_cache[item_name],
		})

		if ctx.missing_recipe_slots and ctx.missing_recipe_slots[i] then
			fs[#fs + 1] = fmt(FMT.box,
				x + 0.04, y + 0.04, button_size - 0.07,
				button_size - 0.08, "#D84A4A66")
		end
	end

	local icon = craft_type and craft_type.icon
	local tooltip = craft_type and craft_type.description
	if shapeless then
		icon = "craftguide_shapeless.png"
		tooltip = S("Shapeless")
	elseif recipe.type == "cooking" then
		icon = "craftguide_furnace.png"
		tooltip = S("Cooking")
	end

	local arrow_x = start_x + grid_w + 0.65
	if icon then
		fs[#fs + 1] = ctx:image(arrow_x - 0.05, start_y, 0.5, 0.5, icon)
		fs[#fs + 1] = fmt("tooltip[%f,%f;%f,%f;%s]",
			arrow_x - 0.05, start_y, 0.5, 0.5, ESC(tooltip))
	end
	fs[#fs + 1] = ctx:image(
		arrow_x, start_y + max(0.55, grid_h / 2 - 0.35),
		0.9, 0.7, "craftguide_arrow.png")

	local output_x = arrow_x + 1.25
	local output_y = start_y + max(0, grid_h / 2 - 0.55)
	if recipe.type == "fuel" then
		local fuel_name = match(recipe.items[1], "%S+")
		local burntime = fuel_name and fuel_cache[fuel_name]
		if burntime then
			fs[#fs + 1] = ctx:label(output_x + 0.1, output_y - 0.45,
				colorize(mcl_colors.YELLOW, burntime))
		end
		fs[#fs + 1] = ctx:image(
			output_x, output_y, 1.1, 1.1, "mcl_craftguide_fuel.png")
	else
		fs[#fs + 1] = ctx:item_button(output_x, output_y, recipe.output)
	end

	return concat(fs)
end

local function build_construction_recipe(ctx)
	local recipe = ctx.recipe
	local items = recipe.items or {}
	local width = max(1, recipe.width or 1)
	local rows = ceil(maxn(items) / width)
	local fs = {}

	if recipe.description then
		fs[#fs + 1] = ctx:label(0.2, 0.1, recipe.description)
	end
	if width > GRID_LIMIT or rows > GRID_LIMIT then
		fs[#fs + 1] = ctx:label(0.2, 0.7,
			S("Structure is too big to be displayed (@1×@2)", width, rows))
		return concat(fs)
	end

	local available_height = ctx.height - (recipe.description and 0.65 or 0)
	local button_size = min(1.1, ctx.width / width, available_height / max(1, rows))
	local start_x = max(0, (ctx.width - width * button_size) / 2)
	local start_y = (recipe.description and 0.65 or 0) +
		max(0, (available_height - rows * button_size) / 2)

	for i, item in pairs(items) do
		if item and item ~= "" then
			local x = start_x + ((i - 1) % width) * button_size
			local y = start_y + floor((i - 1) / width) * button_size
			fs[#fs + 1] = ctx:item_button(x, y, item, {
				w = button_size,
				h = button_size,
			})
		end
	end
	return concat(fs)
end

local function build_trading_recipe(ctx)
	local recipe = ctx.recipe
	local inputs = recipe.items or {}
	local fs = {}
	local title = recipe.description or recipe.trader
	if title then
		fs[#fs + 1] = ctx:label(0.2, 0.1, title)
	end

	local input_count = min(3, #inputs)
	local total_w = input_count * 1.1 + max(0, input_count - 1) * 0.2 + 3
	local start_x = max(0, (ctx.width - total_w) / 2)
	local y = max(0.65, (ctx.height - 1.1) / 2)

	for i = 1, input_count do
		fs[#fs + 1] = ctx:item_button(
			start_x + (i - 1) * 1.3, y, inputs[i])
	end

	local arrow_x = start_x + input_count * 1.3 + 0.25
	fs[#fs + 1] = ctx:image(
		arrow_x, y + 0.2, 0.9, 0.7, "craftguide_arrow.png")
	if recipe.output then
		fs[#fs + 1] = ctx:item_button(arrow_x + 1.25, y, recipe.output)
	end
	return concat(fs)
end

local function format_treasure_chance(entry)
	if entry.chance_text then
		return tostring(entry.chance_text)
	elseif type(entry.chance) == "number" then
		local chance = entry.chance <= 1 and entry.chance * 100 or entry.chance
		return fmt("%.2f%%", chance):gsub("%.00%%$", "%%")
	end
	return ""
end

local function build_treasure_recipe(ctx)
	local recipe = ctx.recipe
	local loot = recipe.loot or {}
	local fs = {}
	local title = recipe.description or recipe.source
	if title then
		fs[#fs + 1] = ctx:label(0.2, 0.1, title)
	end

	local columns = max(1, floor(ctx.width / 1.15))
	for i = 1, #loot do
		local entry = loot[i]
		local item = type(entry) == "table" and (entry.item or entry.name) or entry
		local column = (i - 1) % columns
		local row = floor((i - 1) / columns)
		local x = 0.2 + column * 1.15
		local y = 0.65 + row * 1.35
		if y + 0.85 > ctx.height then
			break
		end

		if item then
			fs[#fs + 1] = ctx:item_button(
				x, y, item, { w = 0.85, h = 0.85 })
		end
		if type(entry) == "table" then
			local chance = format_treasure_chance(entry)
			if chance ~= "" then
				fs[#fs + 1] = ctx:label(x, y + 1.02, chance)
			end
		end
	end
	return concat(fs)
end

local function format_mob_drop_chance(drop)
	if type(drop.chance) ~= "number" or drop.chance <= 0 then
		return S("Conditional")
	end

	local chance = min(100, 100 / drop.chance)
	if chance == floor(chance) then
		return fmt("%d%%", chance)
	end
	return fmt("%.2f%%", chance)
end

local function get_mob_drop_tooltip(drop)
	local item = reg_items[drop.name]
	local lines = {
		item and item.description or drop.name,
		S("Base roll chance: @1", format_mob_drop_chance(drop)),
	}
	local min_count = drop.min or 1
	local max_count = drop.max or min_count
	if min_count == max_count then
		lines[#lines + 1] = S("Amount: @1", min_count)
	else
		lines[#lines + 1] = S("Amount: @1-@2", min_count, max_count)
	end

	if drop.looting == "rare" then
		lines[#lines + 1] = S("Requires a player kill")
		lines[#lines + 1] = S("Looting increases the drop chance")
	elseif drop.looting == "common" then
		lines[#lines + 1] = S("Looting may increase the amount")
	end
	if drop.looting_chance_function then
		lines[#lines + 1] = S("Chance is modified by Looting")
	end
	if drop.conditions then
		lines[#lines + 1] = S("Special drop conditions apply")
	end
	return concat(lines, "\n")
end

local function build_mob_drop_recipe(ctx)
	local fs = {
		ctx:label(0.2, 0.1, ctx.recipe.mob_description),
	}
	local columns = max(1, floor(ctx.width / 1.15))
	local button_size = 0.85

	for i = 1, #ctx.recipe.drops do
		local drop = ctx.recipe.drops[i]
		local column = (i - 1) % columns
		local row = floor((i - 1) / columns)
		local x = 0.2 + column * 1.15
		local y = 0.65 + row * 1.35
		if y + button_size > ctx.height then
			break
		end

		fs[#fs + 1] = ctx:item_button(x, y, drop.name, {
			w = button_size,
			h = button_size,
			tooltip = get_mob_drop_tooltip(drop),
		})
		fs[#fs + 1] = ctx:label(x, y + 1.02, format_mob_drop_chance(drop))
	end
	return concat(fs)
end

local function get_tabbed_recipe_fs(data, player, layout)
	local fs = {}
	local recipe = data.recipes[data.rnum]
	local tabs = data.recipe_tabs or {}

	if #tabs > 0 then
		local header = calculate_tab_header(data, tabs, layout.tabs)
		local tab_x
		if header.mode == "pages" then
			tab_x = header.tabs_x + center_start(header.tabs_w, header.total_w)

			local prev_texture = "craftguide_prev_icon.png"
			local next_texture = "craftguide_next_icon.png"
			if data.focus_target then
				fs[#fs + 1] = fmt(
					"set_focus[%s;true]", data.focus_target)
				data.focus_target = nil
			end
			if header.page > 1 then
				fs[#fs + 1] = fmt(FMT.image_button,
					header.arrow_prev_x, layout.tabs.y,
					UI.tab_size, layout.tabs.h,
					prev_texture, "recipe_tabs_page_prev", "")
			else
				fs[#fs + 1] = fmt(FMT.image,
					header.arrow_prev_x, layout.tabs.y,
					UI.tab_size, layout.tabs.h,
					prev_texture .. "^[opacity:80")
			end
			if header.page < header.page_count then
				fs[#fs + 1] = fmt(FMT.image_button,
					header.arrow_next_x, layout.tabs.y,
					UI.tab_size, layout.tabs.h,
					next_texture, "recipe_tabs_page_next", "")
			else
				fs[#fs + 1] = fmt(FMT.image,
					header.arrow_next_x, layout.tabs.y,
					UI.tab_size, layout.tabs.h,
					next_texture .. "^[opacity:80")
			end
			fs[#fs + 1] = fmt(FMT.tooltip,
				"recipe_tabs_page_prev", ESC(S("Previous page")))
			fs[#fs + 1] = fmt(FMT.tooltip,
				"recipe_tabs_page_next", ESC(S("Next page")))
		else
			tab_x = layout.tabs.x +
				center_start(layout.tabs.w, header.total_w)
		end

		for i = header.first, header.last do
			local tab = tabs[i]
			local field_name = fmt("rtab_%d", i)
			if tab.name == data.selected_recipe_tab then
				fs[#fs + 1] = fmt(
					"style[rtab_%d;border=false;" ..
					"bgimg=mcl_inventory_button9_pressed.png;" ..
					"bgimg_pressed=mcl_inventory_button9_pressed.png;" ..
					"bgimg_middle=2,2]", i)
			end

			if header.mode == "wide" then
				fs[#fs + 1] = fmt(FMT.button,
					tab_x, layout.tabs.y, header.button_w, layout.tabs.h,
					field_name, "")
				if tab.def.icon and reg_items[tab.def.icon] then
					fs[#fs + 1] = fmt(FMT.item_image,
						tab_x + UI.tab_icon_padding,
						layout.tabs.y + UI.tab_icon_padding,
						UI.tab_icon_size, UI.tab_icon_size, tab.def.icon)
				elseif tab.def.icon then
					fs[#fs + 1] = fmt(FMT.image,
						tab_x + UI.tab_icon_padding,
						layout.tabs.y + UI.tab_icon_padding,
						UI.tab_icon_size, UI.tab_icon_size, tab.def.icon)
				end
				local label_x = tab_x + UI.tab_icon_padding
				if tab.def.icon then
					label_x = label_x + UI.tab_icon_size + UI.tab_label_gap
				end
				fs[#fs + 1] = fmt(FMT.label,
					label_x, layout.tabs.y + layout.tabs.h / 2,
					ESC(tab.def.description))
			elseif tab.def.icon and reg_items[tab.def.icon] then
				fs[#fs + 1] = fmt(FMT.item_image_button,
					tab_x, layout.tabs.y, header.button_w, layout.tabs.h,
					tab.def.icon, field_name, "")
			elseif tab.def.icon then
				fs[#fs + 1] = fmt(FMT.image_button,
					tab_x, layout.tabs.y, header.button_w, layout.tabs.h,
					tab.def.icon, field_name, "")
			else
				fs[#fs + 1] = fmt(FMT.button,
					tab_x, layout.tabs.y, header.button_w, layout.tabs.h,
					field_name, ESC(tab.def.description))
			end
			fs[#fs + 1] = fmt(FMT.tooltip,
				field_name, ESC(tab.def.description))
			tab_x = tab_x + header.button_w + UI.gap
		end
	end

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
			local x, y = grid_xy(i, 2, UI.station_cell_size)
			station_fs[#station_fs + 1] = fmt(FMT.item_image_button,
				x, y, UI.station_button_size, UI.station_button_size,
				station.item_name, station.item_name, "")
		end
		fs[#fs + 1] = fmt(
			"scroll_container[%f,%f;2.1,3.2;station_scroll;vertical;0.8]",
			layout.stations.x, layout.stations.y)
		fs[#fs + 1] = concat(station_fs)
		fs[#fs + 1] = "scroll_container_end[]"
		if #supported_stations > 8 then
			local station_rows = ceil(#supported_stations / 2)
			fs[#fs + 1] = fmt(
				"scrollbaroptions[min=0;max=%d;smallstep=1;largestep=4;arrows=hide]",
				station_rows - 4)
			fs[#fs + 1] = fmt(
				"scrollbar[%f,%f;0.35,3.2;vertical;station_scroll;0]",
				layout.stations.x + 1.7, layout.stations.y)
		end
	end

	local context_station = data.context and mcl_craftguide.get_station(data.context)
	if context_station and context_station.actions and
		context_station.is_recipe_supported(recipe) then
		local action_y = {
			layout.actions.first_y,
			layout.actions.second_y,
		}
		for i = 1, #context_station.actions do
			local action = context_station.actions[i]
			local field_name = fmt("station_action_%d", i)
			if action.image then
				fs[#fs + 1] = fmt(FMT.image_button,
					layout.actions.x,
					action_y[i], layout.actions.w, layout.actions.h,
					action.image, field_name, "")
			else
				fs[#fs + 1] = fmt(FMT.item_image_button,
					layout.actions.x, action_y[i],
					layout.actions.w, layout.actions.h,
					action.item or data.context, field_name, "")
			end
			fs[#fs + 1] = fmt(FMT.tooltip,
				field_name, ESC(action.tooltip))
		end
	end

	local favorite_item = data.query_item and data.favorite_items and
		data.favorite_items[data.query_item]
	fs[#fs + 1] = fmt(FMT.image_button,
		layout.actions.x, layout.actions.favorite_y,
		layout.actions.w, layout.actions.h,
		favorite_item and "mcl_end_ender_eye.png" or
			"mcl_throwing_ender_pearl.png",
		"toggle_item_favorite", "")
	fs[#fs + 1] = fmt(FMT.tooltip, "toggle_item_favorite",
		ESC(favorite_item and S("Unfavorite") or S("Favorite")))

	local ctx, tab = make_tab_context(data, player, layout.content)
	ctx.missing_recipe_slots = data.missing_recipe_slots
	fs[#fs + 1] = fmt(
		"container[%f,%f]", layout.content.x, layout.content.y)
	fs[#fs + 1] = tab.build(ctx) or ""
	fs[#fs + 1] = "container_end[]"

	local btn_lab = data.show_usages and
		ESC(S("Usage @1 of @2", data.rnum, #data.recipes)) or
		ESC(S("Recipe @1 of @2", data.rnum, #data.recipes))
	fs[#fs + 1] = fmt(FMT.image_button,
		layout.recipe_nav.prev_x, layout.recipe_nav.y,
		layout.actions.w, layout.actions.h,
		"craftguide_prev_icon.png", "recipe_prev", "")
	fs[#fs + 1] = fmt(FMT.label,
		layout.recipe_nav.label_x, layout.recipe_nav.label_y, btn_lab)
	fs[#fs + 1] = fmt(FMT.image_button,
		layout.recipe_nav.next_x, layout.recipe_nav.y,
		layout.actions.w, layout.actions.h,
		"craftguide_next_icon.png", "recipe_next", "")

	return concat(fs)
end

mcl_craftguide.register_tab("mcl_craftguide:crafting", {
	description = S("Crafting"),
	icon = "mcl_crafting_table:crafting_table",
	is_recipe = function(recipe)
		return not recipe.type or recipe.type == "normal"
	end,
	build = function(ctx)
		return render_grid_recipe(ctx)
	end,
})

mcl_craftguide.register_tab("mcl_craftguide:smelting", {
	description = S("Smelting"),
	icon = "mcl_furnaces:furnace",
	is_recipe = function(recipe)
		return recipe.type == "cooking"
	end,
	build = function(ctx)
		return render_grid_recipe(ctx)
	end,
})

mcl_craftguide.register_tab("mcl_craftguide:fuel", {
	description = S("Fuel"),
	icon = "mcl_fire:fire",
	is_recipe = function(recipe)
		return recipe.type == "fuel"
	end,
	build = function(ctx)
		return render_grid_recipe(ctx)
	end,
})

mcl_craftguide.register_tab("mcl_craftguide:construction", {
	description = S("Construction"),
	icon = "mcl_anvils_inventory_hammer.png",
	build = build_construction_recipe,
})

mcl_craftguide.register_tab("mcl_craftguide:trading", {
	description = S("Trading"),
	icon = "mcl_core_emerald.png",
	build = build_trading_recipe,
})

mcl_craftguide.register_tab("mcl_craftguide:treasure", {
	description = S("Treasure"),
	icon = "mcl_chests_normal.png",
	build = build_treasure_recipe,
})

mcl_craftguide.register_tab("mcl_craftguide:mob_drops", {
	description = S("Mob Drops"),
	icon = "mcl_tools:sword_iron",
	build = build_mob_drop_recipe,
})

-- for i = 1, 20 do
-- 	local name = "test_" .. i
-- 	mcl_craftguide.register_tab(name, {
-- 		description = name,
-- 		icon = "mcl_core:ironblock",
-- 		get_items = function()
-- 			return { "mcl_core:iron_ingot", "mcl_core:ironblock" }
-- 		end,
-- 		get_recipes = function(item, show_usages)
-- 			local relevant = show_usages and item == "mcl_core:iron_ingot" or
-- 				not show_usages and item == "mcl_core:ironblock"
-- 			if not relevant then
-- 				return {}
-- 			end
-- 			return {
-- 				{
-- 					type = name,
-- 					width = 1,
-- 					items = { "mcl_core:iron_ingot" },
-- 					output = "mcl_core:ironblock",
-- 				},
-- 			}
-- 		end,
-- 		build = function(ctx)
-- 			return render_grid_recipe(ctx)
-- 		end,
-- 	})
-- end

local function make_formspec(name)
	local data = get_player_data(name)
	local player = get_player_by_name(name)
	local layout = calculate_layout(data)

	data.pagemax = max(1, ceil(#data.items / layout.items_per_page))

	local fs = {}

	fs[#fs + 1] = "formspec_version[10]"
	fs[#fs + 1] = fmt("size[%f,%f;]", layout.form.w, layout.form.h)

	fs[#fs + 1] = fmt(
		"background9[0,0;%f,%f;mcl_base_textures_background9.png;false;7]",
		layout.form.w,
		layout.form.h)

	fs[#fs + 1] = fmt([[ tooltip[size_inc;%s]
					tooltip[size_dec;%s] ]],
		ESC(S("Increase window size")),
		ESC(S("Decrease window size")))

	fs[#fs + 1] = fmt(FMT.image_button,
		layout.toolbar.zoom_in_x,
		layout.toolbar.y,
		layout.toolbar.button_w,
		layout.toolbar.button_h,
		"craftguide_zoomin_icon.png", "size_inc", "")
	fs[#fs + 1] = fmt(FMT.image_button,
		layout.toolbar.zoom_out_x,
		layout.toolbar.y,
		layout.toolbar.button_w,
		layout.toolbar.button_h,
		"craftguide_zoomout_icon.png", "size_dec", "")

	fs[#fs + 1] = fmt(FMT.image_button,
		layout.toolbar.search_x,
		layout.toolbar.y,
		layout.toolbar.button_w,
		layout.toolbar.button_h,
		"craftguide_search_icon.png", "search", "")
	fs[#fs + 1] = fmt(FMT.image_button,
		layout.toolbar.clear_x,
		layout.toolbar.y,
		layout.toolbar.button_w,
		layout.toolbar.button_h,
		"craftguide_clear_icon.png", "clear", "")
	fs[#fs + 1] = fmt(FMT.image_button,
		layout.toolbar.favorites_x,
		layout.toolbar.y,
		layout.toolbar.button_w,
		layout.toolbar.button_h,
		data.favorites_only and
			"mcl_end_ender_eye.png" or "mcl_throwing_ender_pearl.png",
		"toggle_favorites",
		"")
	fs[#fs + 1] = "field_close_on_enter[filter;false]"
	fs[#fs + 1] = "field_enter_after_edit[filter;true]"

	local search_help = {
		S("Search item names and descriptions."),
		S("Filter by mod:") .. " @mod",
		S("Search tooltips:") .. " #text",
		S("Match group names:") .. " $group1,group2 " ..
			S("or") .. " $group1 $group2",
	}
	local described_filters = {}
	for filter_name, description in pairs(search_filter_descriptions) do
		if description then
			described_filters[#described_filters + 1] = filter_name
		end
	end
	sort(described_filters)
	for i = 1, #described_filters do
		local filter_name = described_filters[i]
		search_help[#search_help + 1] =
			"+" .. filter_name .. "=value1,value2: " ..
			search_filter_descriptions[filter_name]
	end
	search_help[#search_help + 1] =
		S("Example:") .. " wood @mcl_core $flammable #damage"

	fs[#fs + 1] = fmt([[ tooltip[filter;%s]
				 tooltip[search;%s]
				 tooltip[clear;%s]
				 tooltip[toggle_favorites;%s]
				 tooltip[prev;%s]
				 tooltip[next;%s] ]],
		ESC(concat(search_help, "\n")),
		ESC(S("Search")),
		ESC(S("Reset")),
		ESC(data.favorites_only and S("Show all items") or S("Show favorite items only")),
		ESC(S("Previous page")),
		ESC(S("Next page")))

	fs[#fs + 1] = fmt(FMT.label,
		layout.toolbar.page_label_x,
		layout.toolbar.page_label_y,
		ESC(colorize("#383838", fmt("%s / %u", data.pagenum, data.pagemax))))

	fs[#fs + 1] = fmt(FMT.image_button,
		layout.toolbar.page_prev_x,
		layout.toolbar.y,
		layout.toolbar.button_w,
		layout.toolbar.button_h,
		"craftguide_prev_icon.png", "prev", "")
	fs[#fs + 1] = fmt(FMT.image_button,
		layout.toolbar.page_next_x,
		layout.toolbar.y,
		layout.toolbar.button_w,
		layout.toolbar.button_h,
		"craftguide_next_icon.png",
		"next",
		"")

	fs[#fs + 1] = fmt(
		"field[%f,%f;%f,%f;filter;;%s]",
		layout.toolbar.filter_x,
		layout.toolbar.filter_y,
		layout.toolbar.filter_w,
		UI.button_height,
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
				-- Legacy: 0.375 + pos * 1.25
			layout.items.empty_label_y,
			ESC(no_item))
	end

	local first_item = (data.pagenum - 1) * layout.items_per_page
	for i = first_item, first_item + layout.items_per_page - 1 do
		local item = data.items[i + 1]
		if not item then
			break
		end

		local page_index = i % layout.items_per_page
		local column = page_index % layout.columns
		local row = floor(page_index / layout.columns)
		local item_x = layout.items.x + column * layout.items.column_step
		local item_y = layout.items.y + row * layout.items.row_step

		fs[#fs + 1] = fmt(FMT.item_image_button,
			item_x,
			item_y,
			layout.items.button_w,
			layout.items.button_h,
			item,
			item .. "_inv",
			"")
	end

	if data.recipes and #data.recipes > 0 then
		fs[#fs + 1] = get_tabbed_recipe_fs(data, player, layout)
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

	data.missing_recipe_slots = nil
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
end, S("Require exact item groups"))

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
	local tooltip_words = {}
	local mod_prefix
	local text_words = {}

	for word in gmatch(filter, "%S+") do
		local filter_name, values = match(word, "^%+([%w_]+)=([%w_,]+)$")
		local groups = match(word, "^%$([%w_,]+)$")

		if filter_name and search_filters[filter_name] then
			values = split(values, ",")
			filters[filter_name] = filters[filter_name] or {}
			table_merge(filters[filter_name], values)
		elseif groups then
			table_merge(group_substrings, split(groups, ","))
		elseif sub(word, 1, 1) == "@" and #word > 1 then
			mod_prefix = sub(word, 2)
		elseif sub(word, 1, 1) == "#" and #word > 1 then
			tooltip_words[#tooltip_words + 1] = sub(word, 2)
		else
			text_words[#text_words + 1] = word
		end
	end
	local text_filter = concat(text_words, " ")

	for i = 1, #data.items_raw do
		local item = data.items_raw[i]
		local def  = reg_items[item]
		local base_description = def._tt_original_description or def.description
		base_description = match(base_description, "^[^\n]*") or base_description
		local desc = lower(M.strip_colors(
			M.get_translated_string(data.lang_code, base_description)))
		local tooltip = lower(M.strip_colors(
			M.get_translated_string(data.lang_code, def.description)))
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
		for j = 1, #tooltip_words do
			to_add = to_add and find(tooltip, tooltip_words[j], 1, true)
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
		data.recipe_tabs = nil
		data.selected_recipe_tab = nil
		data.recipe_tab_page = nil
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
	data.recipe_tabs = nil
	data.selected_recipe_tab = nil
	data.recipe_tab_page = nil
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
	local provided_items = {}
	for i = 1, #recipe_tab_order do
		for_each_tab_provider(recipe_tab_order[i], function(provider)
			if provider.get_items then
				local items = provider.get_items() or {}
				for j = 1, #items do
					provided_items[match(items[j], "%S+")] = true
				end
			end
		end)
	end

	for name, def in pairs(reg_items) do
		local is_fuel = cache_fuel(name)
		if not (def.groups.not_in_craft_guide == 1) and
			def.description and def.description ~= "" and
			(cache_recipes(name) or is_fuel or provided_items[name]) then
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
	local selected_recipe_item
	local tab_field
	local station_action
	local search_submitted = fields.key_enter_field == "filter" or fields.search
	data.missing_recipe_slots = nil

	for elem_name, def in pairs(formspec_elements) do
		if fields[elem_name] and def.action then
			return def.action(player, data)
		end
	end

	for field in pairs(fields) do
		recipe_tab = match(field, "^rtab_(%d+)$")
		if recipe_tab then
			break
		end
		station_action = match(field, "^station_action_(%d+)$")
		if station_action then
			break
		end
		if data.recipe_item_fields and data.recipe_item_fields[field] then
			selected_recipe_item = data.recipe_item_fields[field]
			break
		end
		if data.recipe_tab_fields and data.recipe_tab_fields[field] then
			tab_field = data.recipe_tab_fields[field]
			break
		end
	end

	if selected_recipe_item then
		if selected_recipe_item ~= data.query_item then
			data.show_usages = nil
		else
			data.show_usages = not data.show_usages
		end
		data.query_item = selected_recipe_item
		data.rnum = 1
		if set_recipe_tabs(data, selected_recipe_item, player) then
			show_fs(player, name)
		end

	elseif tab_field then
		local tab = recipe_tabs[data.selected_recipe_tab]
		if tab and tab.handle then
			local ctx = make_tab_context(data, player, { w = 0, h = 0 })
			if tab.handle(ctx, tab_field, fields) then
				show_fs(player, name)
			end
		end

	elseif fields.clear or (search_submitted and (fields.filter or "") == "") then
		reset_data(data)
		refresh_items(data, player)
		show_fs(player, name)

	elseif fields.recipe_tabs_page_prev or fields.recipe_tabs_page_next then
		if not data.recipe_tab_page then
			return
		end

		data.recipe_tab_page = data.recipe_tab_page +
			(fields.recipe_tabs_page_next and 1 or -1)
		local page_count = data.recipe_tabs and
			calculate_tab_header(data, data.recipe_tabs, calculate_layout(data).tabs).page_count
		if fields.recipe_tabs_page_next and
			data.recipe_tab_page == page_count then
			data.focus_target = "recipe_tabs_page_prev"
		elseif fields.recipe_tabs_page_prev and data.recipe_tab_page == 1 then
			data.focus_target = "recipe_tabs_page_next"
		end
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

	elseif station_action then
		local station = data.context and mcl_craftguide.get_station(data.context)
		local recipe = data.recipes and data.recipes[data.rnum]
		local action = station and station.actions and
			station.actions[tonumber(station_action)]
		if not station or not station.on_action or not action or not recipe or
			not station.is_recipe_supported(recipe) then
			return
		end

		local missing_slots = station.on_action(player, recipe, action.name)
		if missing_slots and next(missing_slots) then
			data.missing_recipe_slots = missing_slots
			show_fs(player, name)
		end

	elseif recipe_tab then
		local tab_idx = tonumber(recipe_tab)
		local selected = tab_idx and data.recipe_tabs and data.recipe_tabs[tab_idx]
		if not selected or selected.name == data.selected_recipe_tab then
			return
		end

		data.rnum = 1
		data.selected_recipe_tab = selected.name
		data.recipes = selected.recipes
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
		data.recipe_tab_page = nil
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

		data.query_item = item
		data.rnum = 1
		if not set_recipe_tabs(data, item, player) then
			return
		end

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
			if item ~= "" and not item_in_inv(item, inv_items) then
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

function mcl_craftguide.show(name, item, show_usages, context, tab_name)
	local player = get_player_by_name(name)
	local data = get_player_data(name)
	data.context = context
	refresh_items(data, player)
	if item then
		item = match(item, "%S+")
		if reg_items[item] then
			data.query_item = item
			data.show_usages = show_usages == true
			data.rnum = 1
			set_recipe_tabs(data, item, player, tab_name)
		end
	end
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
