## API

### Recipe tabs

#### `mcl_craftguide.register_tab(name, def, override)`

Registers an item-centric recipe tab. A tab is shown only when it returns at
least one recipe for the selected item and the current recipes/usages mode.
Names should be namespaced, for example `"example:macerating"`.

The guide owns the item list, item paging, tab buttons, recipe paging, crafting
stations, favorites, and item navigation. The tab only supplies recipes and
draws the active recipe in the content area between the station list and the
favorite button.

Definition fields:

- `description`: translated tab label.
- `icon`: optional item name or texture used by the tab header. Registered
  items are rendered as item images; other values are treated as textures.
  Tabs without an icon use their description as the button label.
- `order`: optional numeric sort order; defaults to `100`.
- `get_items()`: optional callback returning all item names that the tab can
  produce or use. Items without ordinary Luanti recipes must be returned here
  so they are included in the guide's item list. Called during mod loading.
- `get_recipes(item, show_usages, player)`: returns recipes relevant to
  `item`. `show_usages` is `false` for ways to obtain the item and `true` for
  ways to use it.
- `is_recipe(recipe)`: alternative to `get_recipes`, used to select recipes
  from craftguide's normal recipe cache.
- `build(ctx)`: returns formspec content for `ctx.recipe`.
- `handle(ctx, field_name, fields)`: optional handler for fields created with
  `ctx:field_name()` or `ctx:button()`. Return true to redraw the guide.
- `is_visible(player, item, show_usages)`: optional access callback.

Exactly one of `get_recipes` and `is_recipe` is required. Set `override` to
true to replace an existing tab.

Recipes should use the common fields where applicable:

```lua
{
	type = "example:macerating",
	width = 1,
	items = { "mcl_core:stone" },
	output = "mcl_core:cobble",
	time = 2,
}
```

`items` and `output` allow crafting stations and other craftguide features to
understand the recipe. Tabs may add their own fields.

The build context contains:

- `player`, `item`, `show_usages`, and `recipe`.
- `recipe_index` and `recipe_count`.
- `width` and `height`, in formspec units.
- `state`, a private per-player table belonging to this tab.
- `item_button(x, y, item, options)`.
- `image(x, y, width, height, texture)`.
- `label(x, y, text)`.
- `button(x, y, width, height, name, label)`.
- `field_name(name)`.

All coordinates are relative to the content area's top-left corner. Consumers
start their layout at `0,0`; craftguide wraps the result in a formspec
`container[]`.

`ctx:item_button()` accepts item names, stack strings, and group ingredients
directly. Craftguide resolves `group:*` values, adds their marker and tooltip,
generates a private field name, and selects the displayed item when clicked.

```lua
mcl_craftguide.register_tab("example:macerating", {
	description = S("Macerating"),
	icon = "example_macerator.png",
	order = 40,

	get_items = function()
		local items = {}
		for input, recipe in pairs(example.macerator_recipes) do
			items[#items + 1] = input
			items[#items + 1] = recipe.output
		end
		return items
	end,

	get_recipes = function(item, show_usages)
		local recipes = {}
		for input, def in pairs(example.macerator_recipes) do
			local recipe = {
				type = "example:macerating",
				width = 1,
				items = { input },
				output = def.output,
				time = def.time,
			}
			local relevant = show_usages and input == item or
				not show_usages and ItemStack(def.output):get_name() == item
			if relevant then
				recipes[#recipes + 1] = recipe
			end
		end
		return recipes
	end,

	build = function(ctx)
		local recipe = ctx.recipe
		return table.concat({
			ctx:item_button(0.5, 0.8, recipe.items[1]),
			ctx:image(2.0, 1.0, 0.9, 0.7, "craftguide_arrow.png"),
			ctx:item_button(3.2, 0.8, recipe.output),
			ctx:label(2.0, 2.2, S("@1 seconds", recipe.time)),
		})
	end,
})
```

#### `mcl_craftguide.get_tab(name)`

Returns a copy of a registered tab definition or `nil`.

#### `mcl_craftguide.get_tabs()`

Returns copies of all registered tab definitions indexed by name.

### Custom recipes

#### Registering a custom crafting type (example)

```Lua
mcl_craftguide.register_craft_type("digging", {
	description = "Digging",
	icon = "default_tool_steelpick.png",
})
```

#### Registering a custom crafting recipe (example)

```Lua
mcl_craftguide.register_craft({
	type   = "digging",
	width  = 1,
	output = "default:cobble 2",
	items  = {"default:stone"},
})
```

### Crafting stations

#### `mcl_craftguide.register_station(item_name, def, override)`

Registers an item or node as a crafting station. The station is shown for a
recipe when it has been discovered by the player and `is_recipe_supported`
returns true. When progressive mode is disabled, all supported stations are
shown. Selecting the station in usage mode also shows every supported recipe
known by the player, grouped into the usual recipe-type tabs. The callback
receives the displayed recipe, including synthetic recipes such as
`{ type = "fuel", items = { fuel_item } }`. Recipe-type-specific fields may
also be present, but are not part of the station API contract.

Stations may provide up to two recipe actions in an ordered `actions` list and
an `on_action(player, recipe, action_name)` callback. Each action requires a
unique `name` and translated `tooltip`. Its button uses the station item by
default. `item` may select another registered item, or `image` may provide the
complete `image_button` texture. `item` and `image` are mutually exclusive.
Image composition, padding, and texture modifiers remain entirely under the
station provider's control. When the guide is opened with that station as its
context, actions are shown for supported recipes.

Inventory handling and any station formspec changes remain the responsibility
of the station. On failure, `on_action` may return a set of missing recipe item
indices, such as `{ [2] = true, [5] = true }`. The guide highlights those inputs
until the next formspec interaction.

Set the optional `override` argument to `true` to intentionally replace an
existing definition. The station keeps its position in the registration order.
Registering a duplicate without `override` raises an error.

```lua
mcl_craftguide.register_station("example:processor", {
	is_recipe_supported = function(recipe)
		return recipe.type == "example_processing" or recipe.type == "fuel"
	end,
	actions = {
		{
			name = "fill_one",
			tooltip = "Configure station for one operation",
			image = "example_fill_one.png",
		},
		{
			name = "fill_all",
			tooltip = "Configure station for all possible operations",
			image = "example_fill_all.png",
		},
	},
	on_action = function(player, recipe, action_name)
		-- Populate or otherwise configure the station for this recipe.
	end,
})
```

#### `mcl_craftguide.get_station(item_name)`

Returns a copy of the registered station definition, or `nil` if the item is
not registered as a station. The returned definition can be modified and
registered again with the `override` argument set to `true`.

```lua
local def = mcl_craftguide.get_station("example:processor")
if def then
	local original = def.is_recipe_supported
	def.is_recipe_supported = function(recipe)
		return original(recipe) and recipe.type ~= "fuel"
	end
	mcl_craftguide.register_station("example:processor", def, true)
end
```

---

### Recipe filters

Recipe filters can be used to filter the recipes shown to players. Progressive
mode is implemented as a recipe filter.

#### `mcl_craftguide.add_recipe_filter(name, function(recipes, player))`

Adds a recipe filter with the given name. The filter function should return the
recipes to be displayed, given the available recipes and an `ObjectRef` to the
user. Each recipe is a table of the form returned by
`minetest.get_craft_recipe`.

Example function to hide recipes for items from a mod called "secretstuff":

```lua
mcl_craftguide.add_recipe_filter("Hide secretstuff", function(recipes)
	local filtered = {}
	for _, recipe in ipairs(recipes) do
		if recipe.output:sub(1,12) ~= "secretstuff:" then
			filtered[#filtered + 1] = recipe
		end
	end

	return filtered
end)
```

#### `mcl_craftguide.remove_recipe_filter(name)`

Removes the recipe filter with the given name.

#### `mcl_craftguide.set_recipe_filter(name, function(recipe, player))`

Removes all recipe filters and adds a new one.

#### `mcl_craftguide.get_recipe_filters()`

Returns a map of recipe filters, indexed by name.

---

### Search filters

Search filters are used to perform specific searches inside the search field.
They can be used like so:
`<optional search text> +<filter name>=<value1>,<value2>,<...>`

Built-in search modifiers:

- `@mod`: filter by mod name.
- `$group1,group2`: match partial item group names.
- `#text`: search full item tooltips.

Examples:

- `+groups=cracky,crumbly`: search for groups `cracky` and `crumbly` in all items.
- `sand+groups=falling_node`: search for group `falling_node` for items which contain `sand` in their names.

Notes:
- If `optional name` is omitted, the search filter will apply to all items, without pre-filtering.
- Filters can be combined.
- Values are comma-separated. The callback always receives them as a list.
- Repeated uses of the same filter are merged into one values list.
- The exact-match `groups` filter is implemented by default.

#### `mcl_craftguide.add_search_filter(name, function(item, values), description)`

Adds a search filter with the given name.
The search function should return a boolean value (whether the given item should be listed or not).
The optional `description` is shown in the search field tooltip next to the
filter syntax. It should be short and must be translated by the registering mod;
craftguide displays it as provided.

Example function to show items which contain at least a recipe of given width(s):

```lua
mcl_craftguide.add_search_filter("widths", function(item, widths)
	local has_width
	local recipes = recipes_cache[item]

	if recipes then
		for i = 1, #recipes do
			local recipe_width = recipes[i].width
			for j = 1, #widths do
				local width = tonumber(widths[j])
				if width == recipe_width then
					has_width = true
					break
				end
			end
		end
	end

	return has_width
end, S("Require a recipe with one of these widths"))
```

#### `mcl_craftguide.remove_search_filter(name)`

Removes the search filter with the given name.

#### `mcl_craftguide.get_search_filters()`

Returns a map of search filters, indexed by name.

---

### Custom formspec elements

#### `mcl_craftguide.add_formspec_element(name, def)`

Adds a formspec element to the current formspec.
Supported types: `box`, `label`, `image`, `button`, `tooltip`, `item_image`, `image_button`, `item_image_button`

`api_version` controls the coordinate contract:

- `1` (default) accepts formspec version 1 coordinates and translates them to
  real coordinates.
- `2` accepts real coordinates directly, as used by `formspec_version[4]`.

Specify `api_version` explicitly in new integrations. This allows later API
versions to change the contract without overloading the formspec version.

Example:

```lua
mcl_craftguide.add_formspec_element("export", {
	api_version = 2,
	type = "button",
	element = function(data)
		-- Should return a table of parameters according to the formspec element type.
		-- Note: for all buttons, the 'name' parameter *must not* be specified!
		if data.recipes then
			return {
				data.iX - 3.7,   -- X
				8,               -- Y
				1.6,             -- W
				1,               -- H
				ESC(S("Export")) -- label
			}
		end
	end,
	-- Optional.
	action = function(player, data)
		-- When the button is pressed.
		print("Exported!")
	end
})
```

#### `mcl_craftguide.remove_formspec_element(name)`

Removes the formspec element with the given name.

#### `mcl_craftguide.get_formspec_elements()`

Returns a map of formspec elements, indexed by name.

---

### Miscellaneous

#### `mcl_craftguide.show(player_name, item, show_usages, context, tab_name)`

Opens the Crafting Guide with the current filter applied.

   * `player_name`: string param.
   * `item`: optional item to select.
   * `show_usages`: whether to initially show usages instead of recipes.
   * `context`: optional registered station item identifying the formspec that
     opened the guide.
   * `tab_name`: optional preferred registered recipe tab.
