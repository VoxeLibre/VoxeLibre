local S = minetest.get_translator("mcl_mobs")
local mob_drop_recipes

local function get_mob_drop_recipes()
	if mob_drop_recipes then
		return mob_drop_recipes
	end

	mob_drop_recipes = {}
	for mob_name, def in pairs(minetest.registered_entities) do
		if def.description and def.drops and #def.drops > 0 then
			local drops = {}
			for i = 1, #def.drops do
				local drop = def.drops[i]
				local item_name = type(drop.name) == "string" and
					ItemStack(drop.name):get_name()
				if item_name and minetest.registered_items[item_name] then
					local normalized_drop = table.copy(drop)
					normalized_drop.name = item_name
					drops[#drops + 1] = normalized_drop
				end
			end

			if #drops > 0 then
				mob_drop_recipes[#mob_drop_recipes + 1] = {
					type = "mcl_mobs:mob_drops",
					mob_name = mob_name,
					mob_description = def.description,
					drops = drops,
				}
			end
		end
	end

	table.sort(mob_drop_recipes, function(a, b)
		if a.mob_description == b.mob_description then
			return a.mob_name < b.mob_name
		end
		return a.mob_description < b.mob_description
	end)
	return mob_drop_recipes
end

local function format_drop_chance(drop)
	if type(drop.chance) ~= "number" or drop.chance <= 0 then
		return S("Conditional")
	end

	local chance = math.min(100, 100 / drop.chance)
	if chance == math.floor(chance) then
		return string.format("%d%%", chance)
	end
	return string.format("%.2f%%", chance)
end

local function get_drop_tooltip(drop)
	local item = minetest.registered_items[drop.name]
	local lines = {
		item and item.description or drop.name,
		S("Base roll chance: @1", format_drop_chance(drop)),
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
	return table.concat(lines, "\n")
end

mcl_craftguide.register_tab("mcl_mobs:mob_drops", {
	description = S("Mob Drops"),
	icon = "mcl_tools:sword_iron",
	order = 40,

	get_items = function()
		local items = {}
		local included = {}
		local recipes = get_mob_drop_recipes()
		for i = 1, #recipes do
			for j = 1, #recipes[i].drops do
				local item = recipes[i].drops[j].name
				if not included[item] then
					items[#items + 1] = item
					included[item] = true
				end
			end
		end
		return items
	end,

	get_recipes = function(item, show_usages)
		if show_usages then
			return {}
		end

		local recipes = {}
		local mob_recipes = get_mob_drop_recipes()
		for i = 1, #mob_recipes do
			local mob_recipe = mob_recipes[i]
			for j = 1, #mob_recipe.drops do
				if mob_recipe.drops[j].name == item then
					local recipe = table.copy(mob_recipe)
					recipe.items = { item }
					recipe.output = item
					recipes[#recipes + 1] = recipe
					break
				end
			end
		end
		return recipes
	end,

	build = function(ctx)
		local fs = {
			ctx:label(0.2, 0.1, ctx.recipe.mob_description),
		}
		local columns = math.max(1, math.floor(ctx.width / 1.15))
		local button_size = 0.85

		for i = 1, #ctx.recipe.drops do
			local drop = ctx.recipe.drops[i]
			local column = (i - 1) % columns
			local row = math.floor((i - 1) / columns)
			local x = 0.2 + column * 1.15
			local y = 0.65 + row * 1.35
			if y + button_size > ctx.height then
				break
			end

			fs[#fs + 1] = ctx:item_button(x, y, drop.name, {
				w = button_size,
				h = button_size,
				tooltip = get_drop_tooltip(drop),
			})
			fs[#fs + 1] = ctx:label(x, y + 1.02, format_drop_chance(drop))
		end
		return table.concat(fs)
	end,
})
