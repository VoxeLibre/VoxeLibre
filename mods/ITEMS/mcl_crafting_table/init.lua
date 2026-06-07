---@diagnostic disable lowercase-global

local S = minetest.get_translator(minetest.get_current_modname())
local F = minetest.formspec_escape
local C = minetest.colorize
local show_formspec = minetest.show_formspec
local floor, ceil = math.floor, math.ceil
local maxn = table.maxn

mcl_crafting_table = {}

local function ensure_crafting_grid(inv)
	inv:set_width("craft", 3)
	inv:set_size("craft", 9)
end

mcl_crafting_table.formspec = table.concat({
	"formspec_version[4]",
	"size[11.75,10.425]",

	"label[2.25,0.375;" .. F(C(mcl_formspec.label_color, S("Crafting"))) .. "]",

	mcl_formspec.get_itemslot_bg_v4(2.25, 0.75, 3, 3),
	"list[current_player;craft;2.25,0.75;3,3;]",

	"image[6.125,2;1.5,1;gui_crafting_arrow.png]",

	mcl_formspec.get_itemslot_bg_v4(8.2, 2, 1, 1, 0.2),
	"list[current_player;craftpreview;8.2,2;1,1;]",

	"label[0.375,4.7;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]",

	mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
	"list[current_player;main;0.375,5.1;9,3;9]",

	mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
	"list[current_player;main;0.375,9.05;9,1;]",

	"listring[current_player;craft]",
	"listring[current_player;main]",

	--Crafting guide button
	"image_button[0.325,1.95;1.1,1.1;craftguide_book.png;__mcl_craftguide_crafting_table;]",
	"tooltip[__mcl_craftguide_crafting_table;" .. F(S("Recipe book")) .. "]",
})

---@param player ObjectRef
function mcl_crafting_table.show_crafting_form(player)
	local inv = player:get_inventory()
	if inv then
		ensure_crafting_grid(inv)
	end

	show_formspec(player:get_player_name(), "main", mcl_crafting_table.formspec)
end

core.register_on_player_receive_fields(function(player, formname, fields)
	if fields.__mcl_craftguide_crafting_table then
		mcl_craftguide.show(player:get_player_name(), nil, nil,
			"mcl_crafting_table:crafting_table")
	end
end)

minetest.register_node("mcl_crafting_table:crafting_table", {
	description = S("Crafting Table"),
	_tt_help = S("3×3 crafting grid"),
	_doc_items_longdesc = S("A crafting table is a block which grants you access to a 3×3 crafting grid which allows you to perform advanced crafts."),
	_doc_items_usagehelp = S("Rightclick the crafting table to access the 3×3 crafting grid."),
	_doc_items_hidden = false,
	is_ground_content = false,
	tiles = { "crafting_workbench_top.png", "default_wood.png", "crafting_workbench_side.png",
		"crafting_workbench_side.png", "crafting_workbench_front.png", "crafting_workbench_front.png" },
	paramtype2 = "facedir",
	groups = { handy = 1, axey = 1, deco_block = 1, material_wood = 1, flammable = -1 },
	on_rightclick = function(pos, node, player, itemstack)
		if not player:get_player_control().sneak then
			mcl_crafting_table.show_crafting_form(player)
		end
	end,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 2.5,
})

minetest.register_craft({
	output = "mcl_crafting_table:crafting_table",
	recipe = {
		{ "group:wood", "group:wood" },
		{ "group:wood", "group:wood" }
	},
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_crafting_table:crafting_table",
	burntime = 15,
})

local function copy_stack_list(stacks)
	local result = {}
	for i = 1, #stacks do
		result[i] = ItemStack(stacks[i])
	end
	return result
end

local function add_stack_to_list(stacks, stack)
	local leftover = ItemStack(stack)
	for i = 1, #stacks do
		leftover = stacks[i]:add_item(leftover)
		if leftover:is_empty() then
			return true
		end
	end
end

local function ingredient_matches(stack, ingredient)
	local groups = ingredient:match("^group:(.+)$")
	local item_name = not groups and ItemStack(ingredient):get_name()
	groups = groups and groups:split(",")
	local name = stack:get_name()

	if not groups then
		return name == item_name
	end

	for i = 1, #groups do
			if core.get_item_group(name, groups[i]) == 0 then
			return false
		end
	end

	return true
end

local function stack_key(stack)
	local unit = ItemStack(stack)
	unit:set_count(1)
	return unit:to_string()
end

local function take_ingredient(stacks, ingredient, count)
	local candidates = {}

	for i = 1, #stacks do
		local stack = stacks[i]
		if not stack:is_empty() and ingredient_matches(stack, ingredient) then
			local key = stack_key(stack)
			local candidate = candidates[key]
			if candidate then
				candidate.count = candidate.count + stack:get_count()
			else
				local item = ItemStack(stack)
				item:set_count(1)
				candidates[key] = {
					count = stack:get_count(),
					item = item,
				}
			end
		end
	end

	local selected_key
	local selected
	for key, candidate in pairs(candidates) do
		if candidate.count >= count and candidate.item:get_stack_max() >= count and
			(not selected or candidate.count > selected.count) then
			selected_key = key
			selected = candidate
		end
	end

	if not selected then
		return
	end

	local remaining = count
	for i = 1, #stacks do
		local stack = stacks[i]
		if not stack:is_empty() and stack_key(stack) == selected_key then
			local taken = stack:take_item(remaining)
			remaining = remaining - taken:get_count()
			if remaining == 0 then
				break
			end
		end
	end

	selected.item:set_count(count)
	return selected.item
end

local function prepare_crafting_grid(main, recipe, count)
	local width = recipe.width or 0
	local item_count = maxn(recipe.items)
	local rows = width > 0 and ceil(item_count / width) or 1
	if width > 3 or rows > 3 or (width == 0 and item_count > 9) then
		return
	end

	local craft = {}
	for i = 1, 9 do
		craft[i] = ItemStack()
	end

	local ingredients = {}
	local shapeless_slot = 1
	for i = 1, item_count do
		local ingredient = recipe.items[i]
		if ingredient and ingredient ~= "" then
			local slot
			if width == 0 then
				slot = shapeless_slot
				shapeless_slot = shapeless_slot + 1
			else
				local row = floor((i - 1) / width)
				local column = (i - 1) % width
				slot = row * 3 + column + 1
			end
			ingredients[#ingredients + 1] = {
				ingredient = ingredient,
				index = i,
				slot = slot,
			}
		end
	end

	table.sort(ingredients, function(a, b)
		local a_is_group = a.ingredient:sub(1, 6) == "group:"
		local b_is_group = b.ingredient:sub(1, 6) == "group:"
		if a_is_group == b_is_group then
			return a.slot < b.slot
		end
		return not a_is_group
	end)

	for i = 1, #ingredients do
		local entry = ingredients[i]
		local stack = take_ingredient(main, entry.ingredient, count)
		if not stack then
			return
		end
		craft[entry.slot] = stack
	end

	return craft
end

local function get_missing_recipe_slots(main, recipe)
	local item_count = maxn(recipe.items)
	local ingredients = {}

	for i = 1, item_count do
		local ingredient = recipe.items[i]
		if ingredient and ingredient ~= "" then
			ingredients[#ingredients + 1] = {
				ingredient = ingredient,
				index = i,
			}
		end
	end

	table.sort(ingredients, function(a, b)
		local a_is_group = a.ingredient:sub(1, 6) == "group:"
		local b_is_group = b.ingredient:sub(1, 6) == "group:"
		if a_is_group == b_is_group then
			return a.index < b.index
		end
		return not a_is_group
	end)

	local missing = {}
	for i = 1, #ingredients do
		local entry = ingredients[i]
		if not take_ingredient(main, entry.ingredient, 1) then
			missing[entry.index] = true
		end
	end

	return next(missing) and missing or nil
end

local function fill_crafting_grid(player, recipe, fill_all)
	local inv = player:get_inventory()
	if inv:get_size("craft") ~= 9 or inv:get_width("craft") ~= 3 then
		return false
	end

	local main = copy_stack_list(inv:get_list("main"))
	local old_craft = inv:get_list("craft")

	for i = 1, #old_craft do
		if not old_craft[i]:is_empty() and
			not add_stack_to_list(main, old_craft[i]) then
			return false
		end
	end

	local selected_main
	local selected_craft
	local count = 1
	repeat
		local candidate_main = copy_stack_list(main)
		local candidate_craft = prepare_crafting_grid(candidate_main, recipe, count)
		if not candidate_craft then
			break
		end

		selected_main = candidate_main
		selected_craft = candidate_craft
		count = count + 1
	until not fill_all or count > 99

	if not selected_craft then
		return false, get_missing_recipe_slots(copy_stack_list(main), recipe)
	end

	inv:set_list("main", selected_main)
	inv:set_list("craft", selected_craft)
	return true
end

mcl_craftguide.register_station("mcl_crafting_table:crafting_table", {
	is_recipe_supported = function(recipe)
		return not recipe.type or recipe.type == "normal"
	end,
	recipe_action_tooltips = {
		one = S("Fill the crafting grid for one craft"),
		all = S("Fill the crafting grid for all possible crafts"),
	},
	on_recipe_action = function(player, recipe, fill_all)
		local success, missing_slots = fill_crafting_grid(player, recipe, fill_all)
		if not success then
			return missing_slots
		end

		mcl_crafting_table.show_crafting_form(player)
	end,
})

minetest.register_alias("crafting:workbench", "mcl_crafting_table:crafting_table")
minetest.register_alias("mcl_inventory:workbench", "mcl_crafting_table:crafting_table")
