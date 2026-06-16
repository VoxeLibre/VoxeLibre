local mob_drop_recipes

local function get_mob_drop_recipes()
	if mob_drop_recipes then
		return mob_drop_recipes
	end

	mob_drop_recipes = {}
	for mob_name, def in pairs(core.registered_entities) do
		if def.description and def.drops and #def.drops > 0 then
			local drops = {}
			for i = 1, #def.drops do
				local drop = def.drops[i]
				local item_name = type(drop.name) == "string" and
					ItemStack(drop.name):get_name()
				if item_name and core.registered_items[item_name] then
					local normalized_drop = table.copy(drop)
					normalized_drop.name = item_name
					drops[#drops + 1] = normalized_drop
				end
			end

			if #drops > 0 then
				local outputs = {}
				local included = {}
				for i = 1, #drops do
					local item = drops[i].name
					if not included[item] then
						outputs[#outputs + 1] = item
						included[item] = true
					end
				end
				mob_drop_recipes[#mob_drop_recipes + 1] = {
					type = "mcl_mobs:mob_drops",
					mob_name = mob_name,
					mob_description = def.description,
					drops = drops,
					outputs = outputs,
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

mcl_craftguide.register_tab_recipes(
	"mcl_craftguide:mob_drops",
	"mcl_mobs:mob_drops",
	{
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
				if table.indexof(mob_recipe.outputs, item) ~= -1 then
					local recipe = table.copy(mob_recipe)
					recipe.items = { item }
					recipes[#recipes + 1] = recipe
				end
			end
			return recipes
		end,
	}
)
