## API

### Recipe groups

#### `mcl_craftguide.register_group(name, def)`

Registers presentation metadata for a recipe group. This allows the mod that
owns a group to choose the representative item shown by craftguide.

Repeated registrations merge the supplied fields into the existing definition.
This allows craftguide to provide a generic translated description while the
group owner provides its representative item.

Definition fields:

- `item`: optional representative item used for `group:<name>`.
- `description`: optional translated group description used in the tooltip.
- `is_item`: optional boolean. When true, the group represents variants of one
  logical item. Craftguide uses the representative item's normal description
  and does not add the generic group marker.

```lua
mcl_craftguide.register_group("clock", {
	item = "example:clock",
	is_item = true,
})
```

### Recipe tabs

#### `mcl_craftguide.register_tab(name, def)`

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
  If there are many tabs with recipes, they turn square and show only icon (or
  description if icon was not provided). Descriptions longer than 6 characters
  may look odd in square tab mode.
- `get_items()`: optional callback returning all item names that the tab can
  produce or use. Items without ordinary Luanti recipes must be returned here
  so they are included in the guide's item list. Called during mod loading.
- `get_recipes(item, show_usages, player)`: optional callback returning
  recipes relevant to `item`. `show_usages` is `false` for ways to obtain the
  item and `true` for ways to use it.
- `is_recipe(recipe)`: optional alternative to `get_recipes`, used to select
  recipes from craftguide's normal recipe cache.
- `build(ctx)`: returns formspec content for `ctx.recipe`.
- `handle(ctx, field_name, fields)`: optional handler for fields created with
  `ctx:field_name()` or `ctx:button()`. Return true to redraw the guide.
- `is_visible(player, item, show_usages)`: optional callback to hide the tab
  depending on `item` or `show_usages`. It can use machine discovery, quest
  progression, or similar state. It does not affect crafting and cannot force a
  tab without recipes to appear.
- `stations`: optional ordered list of crafting station definitions. Each entry
  has an `item` field and the fields accepted by
  `mcl_craftguide.register_station()`. This is a convenience for registering
  several stations owned by the tab and will be shown for each recipe in tab.

A tab may omit both `get_recipes` and `is_recipe` when it only provides the
presentation for recipes injected by other mods.

A tab should not implement both `get_recipes` and `is_recipe`. One is enough.

Tabs are displayed in first-registration order. Replacing a tab keeps its
existing position. Ordering between tabs registered by unrelated mods is
intentionally unspecified because it follows Luanti's mod load order.

Registering an existing tab name replaces its presentation and own recipe
provider. Craftguide logs a warning containing the previous and replacing mod
names, but does not stop the server.

### Recipe definitions

Craftguide recipes are Lua tables. Recipes returned by Luanti use the fields
described below, and custom providers should follow the same conventions where
possible:

```lua
{
	type = "example:macerating",
	width = 1,
	items = { "mcl_core:stone" },
	outputs = { "mcl_core:cobble" },
	time = 2,
}
```

Common fields:

- `type`: recipe type. Ordinary shaped and shapeless recipes use
  `"normal"` or no type, cooking/smelting recipes use `"cooking"`, and
  synthetic fuel recipes use `"fuel"`. Custom types should be namespaced.
- `items`: ordered table of input item stack strings. Group ingredients use
  `"group:name"` or `"group:name1,name2"`. Empty strings represent empty
  positions in shaped recipes. This field is required for recipes passed
  through the general craftguide APIs because progressive discovery, usage
  lookup, crafting stations, and other consumers inspect it.
- `outputs`: ordered list of resulting item stack strings, including optional
  counts, for example `{ "mcl_core:cobble 2", "example:stone_dust" }`. The
  first entry is the primary output displayed by built-in renderers. Recipes
  are indexed under every distinct output item name.
- `width`: number of columns in the input grid. A value of `0` denotes a
  shapeless recipe. It is required by the built-in grid renderer, but a custom
  renderer may define different layout fields.
- Additional fields may carry recipe-specific data, such as `time`,
  `description`, `source`, etc. Craftguide preserves unknown fields and
  passes the complete recipe table to renderers, filters, and station
  callbacks.

Recipe record is consumed by `build(ctx)` of the tab, so required fiels
may be different for each tab.

Several stacks of the same registered item may be present in `outputs`, but
craftguide indexes the recipe only once for that item. Custom renderers receive
the complete list and may display every output; built-in grid and trading
renderers display only `outputs[1]`.

#### Passing arbitrary recipe definitions

`get_recipes()` may return arbitrary recipe tables; craftguide does not require
them to correspond to recipes registered with `core.register_craft`. To do so
safely:

- Return a list of recipe tables, not a single recipe table.
- Give every recipe an `items` table, even when the recipe is conceptual rather
  than craftable. Use an empty table when it has no meaningful inputs.
- Return only recipes relevant to the requested `item` and `show_usages`
  direction. Craftguide does not infer this relationship for `get_recipes()`.
- Include every selectable input and output in `get_items()` if it is not
  already discoverable through an ordinary Luanti recipe. Otherwise the item
  may not appear in the guide's item list.
- Register a tab whose `build(ctx)` understands the custom fields. The built-in
  grid renderer expects `items`, `width`, and, except for fuel recipes,
  a non-empty `outputs` list.
- Use the common `items`, `outputs`, and `type` fields whenever possible if the
  recipe should work with progressive discovery, crafting stations, recipe
  filters, or other integrations.

After output normalization, recipe filters and station callbacks receive the
complete recipe table. Custom fields are therefore preserved, but providers
must not assume that generic consumers understand them.

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
start their layout at `0,0`; craftguide wraps the result in a formspec `container[]`.

`ctx:item_button()` accepts item names, stack strings, and group ingredients
directly. Craftguide resolves `group:*` values, adds their marker and tooltip,
generates a private field name, and selects the displayed item when clicked.

```lua
mcl_craftguide.register_tab("example:macerating", {
	description = S("Macerating"),
	icon = "example_macerator.png",

	get_items = function()
		local items = {}
		for input, recipe in pairs(example.macerator_recipes) do
			items[#items + 1] = input
			for i = 1, #recipe.outputs do
				items[#items + 1] = recipe.outputs[i]
			end
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
				outputs = def.outputs,
				time = def.time,
			}
			local produces_item
			for i = 1, #def.outputs do
				if ItemStack(def.outputs[i]):get_name() == item then
					produces_item = true
					break
				end
			end
			local relevant = show_usages and input == item or
				not show_usages and produces_item
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
			ctx:item_button(3.2, 0.8, recipe.outputs[1]),
			ctx:label(2.0, 2.2, S("@1 seconds", recipe.time)),
		})
	end,

	stations = {
		{
			item = "example:macerator",
			is_recipe_supported = function(recipe)
				return recipe.type == "example:macerating"
			end,
		},
		{
			item = "example:advanced_macerator",
			is_recipe_supported = function(recipe)
				return recipe.type == "example:macerating" and
					recipe.tier ~= "basic_only"
			end,
		},
	},
})
```

#### `mcl_craftguide.get_tab(name)`

Returns a copy of a registered tab definition or `nil`.

#### `mcl_craftguide.get_tabs()`

Returns copies of all registered tab definitions indexed by name.

#### `mcl_craftguide.register_tab_recipes(tab_name, contribution_name, def)`

Injects recipes into an existing or future tab without replacing its
description, icon, renderer, or handler. This allows independent mods to
contribute to a shared semantic category while keeping their implementations
separate.

`contribution_name` identifies the provider within the tab and should be
globally namespaced, for example `"mcl_portals:nether_portal"`. Contributions
are evaluated in registration order. Registering the same contribution name
again replaces it in place and logs a warning instead of stopping the server.

Contribution fields:

- `get_items()`: optional callback returning items that must be added to the
  guide's item list.
- `get_recipes(item, show_usages, player)`: supplies custom recipes.
- `is_recipe(recipe)`: alternatively selects recipes from craftguide's normal
  recipe cache.
- `is_visible(player, item, show_usages)`: optionally hides this contribution.

Each contribution must define `get_recipes` or `is_recipe` (one is enough).
The tab must still be registered by some mod before it can be displayed,
but contributions may be registered before or after the tab.

```lua
-- Shared presentation, typically registered by craftguide or a common API mod.
mcl_craftguide.register_tab("mcl_craftguide:construction", {
	description = S("Construction"),
	icon = "mcl_core:obsidian",
	build = build_construction_recipe,
})

-- Independent content contribution.
mcl_craftguide.register_tab_recipes(
	"mcl_craftguide:construction",
	"mcl_portals:nether_portal",
	{
		get_items = function()
			return { "mcl_core:obsidian", "mcl_fire:flint_and_steel" }
		end,
		get_recipes = function(item, show_usages)
			return get_nether_portal_recipes(item, show_usages)
		end,
	}
)
```

### Shared tabs

Craftguide registers these presentation-only tabs for recipe contributions from
game and external mods. A shared tab is only shown when at least one
contribution provides a relevant recipe.

#### Construction

Tab name: `mcl_craftguide:construction`

Construction recipes display a row-major structure grid. Empty strings leave
empty positions in the structure.

```lua
{
	type = "construction",
	description = S("Nether Portal"),
	width = 4,
	items = {
		"", "mcl_core:obsidian", "mcl_core:obsidian", "",
		"mcl_core:obsidian", "", "", "mcl_core:obsidian",
		"mcl_core:obsidian", "", "", "mcl_core:obsidian",
		"mcl_core:obsidian", "", "", "mcl_core:obsidian",
		"", "mcl_core:obsidian", "mcl_core:obsidian", "",
	},
}
```

#### Trading

Tab name: `mcl_craftguide:trading`

Trading recipes display up to three input stacks and one output stack.
`description` is used as the heading when present; otherwise `trader` is used.

```lua
{
	type = "trading",
	trader = S("Armorer"),
	items = { "mcl_core:emerald 5" },
	outputs = { "mcl_armor:helmet_iron" },
}
```

#### Treasure

Tab name: `mcl_craftguide:treasure`

Treasure recipes display the contents of `loot` as clickable item buttons.
Entries may be item strings or tables. Numeric `chance` values from 0 to 1 are
treated as fractions; larger values are treated as percentages. `chance_text`
overrides numeric formatting for conditional or otherwise complex chances.
`description` is used as the heading when present; otherwise `source` is used.

```lua
{
	type = "treasure",
	source = S("Desert Pyramid"),
	loot = {
		{ item = "mcl_core:diamond", chance = 0.0625 },
		{ item = "mcl_mobitems:rotten_flesh", chance = 28.7 },
		{ item = "mcl_enchanting:book_enchanted",
			chance_text = S("Varies by enchantment") },
	},
}
```

#### Mob drops

Tab name: `mcl_craftguide:mob_drops`

Mob-drop recipes display a mob description and its possible drops. Each drop
may define `name`, `chance`, `min`, `max`, `looting`,
`looting_chance_function`, and `conditions`. Providers should set `items` and
`outputs` to the available drops for common craftguide routing and filtering.

```lua
{
	type = "example:mob_drops",
	mob_description = S("Example Mob"),
	items = { "mcl_core:iron_ingot" },
	outputs = { "mcl_core:iron_ingot" },
	drops = {
		{ name = "mcl_core:iron_ingot", chance = 5, min = 1, max = 2 },
	},
}
```

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
	outputs = { "default:cobble 2" },
	items  = {"default:stone"},
})
```

### Crafting stations

#### `mcl_craftguide.register_station(item_name, def, override)`

Registers an item or node as a crafting station. The station is shown for a
recipe when it has been discovered by the player and `is_recipe_supported`
returns true. When progressive mode is disabled, all supported stations are
shown. Selecting the station in usage mode also shows every supported recipe
known by the player, grouped into the usual recipe-type tabs.

`is_recipe_supported(recipe)` receives the complete normalized recipe table,
including `items`, `outputs`, `type`, and any custom fields. Synthetic fuel
recipes have the form `{ type = "fuel", width = 1, items = { fuel_item },
outputs = {} }`.

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
user. Luanti recipes are normalized to the craftguide recipe contract before
filters run, so their result is available through `outputs`.

Example function to hide recipes for items from a mod called "secretstuff":

```lua
mcl_craftguide.add_recipe_filter("Hide secretstuff", function(recipes)
	local filtered = {}
	for _, recipe in ipairs(recipes) do
		if not recipe.outputs[1] or
				ItemStack(recipe.outputs[1]):get_name():sub(1, 12) ~= "secretstuff:" then
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
