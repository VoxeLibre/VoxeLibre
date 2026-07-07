# `vl_tools` API

`vl_tools` provides tool-type namespaces for registering tools and reusing their
related callbacks.

## Common Fields

Tool registration definitions use structured Luanti-style subtables where practical.
Tool-type APIs add their default values first, then merge the provided subtables over
those defaults.

### Item Fields

* `description`: Display name for the registered tool.
* `icon`: Inventory image texture. Tool-type APIs require this field.
* `repair_material`: Item name or group used to repair the tool. Tool-type APIs
also use this for crafting recipes.
* `_doc_items_hidden`: Optional doc item visibility override.
* `_mcl_upgradable`: Marks a tool as upgradable.
* `_mcl_upgrade_item`: Item name of the upgraded tool.

### Durability and Mining Fields

* `_mcl_diggroups`: Dig group capability table used by `mcl_autogroup`.

### Combat Fields

* `tool_capabilities`: Luanti tool capability table.

### Groups and Enchanting

* `groups`: Extra or overriding item groups. Tool APIs merge this into their default
group table.

### Crafting Fields

* `no_craft`: If true, suppresses default crafting recipe registration.
* `fuel_burntime`: If set, registers the tool as fuel with this burn time.
* `cook_result`: If set, registers a cooking recipe from the tool to this output.
* `cooktime`: Optional cooking time. Defaults to 10 where supported.

### Override Fields

* `overrides`: Extra or overriding fields applied directly to the final registered
tool definition.

Use `overrides` for fields that are not part of a tool-type API yet.

## Axe API `vl_tools.axe.register(name, def)`

Registers an axe and its default crafting-related recipes.

### Required fields:

* `name`: Full item name passed as the first argument.
* `def.icon`
* `def.repair_material`

### Default behavior:

* Adds `groups = { tool = 1, axe = 1 }`.
* Sets `_mcl_toollike_wield = true`.
* Sets `_repair_material = def.repair_material`.
* Uses `vl_tools.axe.make_stripped_trunk` as `on_place`.
* Merges `groups`, `tool_capabilities`, and `_mcl_diggroups` into axe defaults.
* Creates two crafting recipes from `repair_material`, unless `no_craft` is true.
* Registers optional fuel and cooking recipes from `fuel_burntime` and `cook_result`.

### Example:

```lua
vl_tools.axe.register("mcl_tools:axe_diamond", {
	-- Required properties
	description = S("Diamond Axe"),
	icon = "default_tool_diamondaxe.png",
	repair_material = "mcl_core:diamond",

	groups = { dig_speed_class = 5, enchantability = 10 },

	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level = 5,
		damage_groups = { fleshy = 9 },
		punch_attack_uses = 1562,
	},

	_mcl_diggroups = {
		axey = { speed = 8, level = 5, uses = 1562 },
	},

	-- Crafting
	fuel_burntime = 10,
	cook_result = "mcl_core:diamond",
	cooktime = 10,
	no_craft = true,

	-- Upgrades
	_mcl_upgradable = true,
	_mcl_upgrade_item = "mcl_tools:axe_netherite",

	-- Documentation
	_doc_items_hidden = false,

	-- Overrides go here
	overrides = {
		on_use = function(itemstack, placer, pointed_thing)
			-- Do some different stuff here.
		end,
	},
})
```

### `vl_tools.axe.make_stripped_trunk(itemstack, placer, pointed_thing)`

Default axe `on_place` callback.

It handles:

* Calling a pointed node's right-click handler when appropriate.
* Protection checks.
* Replacing nodes that define `_mcl_stripped_variant`.
* Unlocking the wax-off achievement for waxed nodes.
* Applying axe wear through `mcl_autogroup.get_wear`.

## Pickaxe API `vl_tools.pickaxe.register(name, def)`

Registers a pickaxe and its default crafting-related recipes.

### Required fields:

* `name`: Full item name passed as the first argument.
* `def.icon`
* `def.repair_material`

### Default behavior:

* Adds `grpups = { tool = 1, pickaxe = 1 }`.
* Sets `_mcl_toollike_wield = true`.
* Sets `_repair_material = def.repair_material`.
* Merges `groups`, `tool_capabilities`, and `_mcl_diggroups` into pickaxe defaults.
* Creates crafting recipe from `repair_material`, unless `no_craft` is true.
* Registers optional fuel and cooking recipes from `fuel_burntime` and `cook_result`.

### Example:

```lua
vl_tools.pickaxe.register("mcl_tools:pick_diamond", {
	-- Required properties
	description = S("Diamond Pickaxe"),
	icon = "default_tool_diamondpick.png",
	repair_material = "mcl_core:diamond",

	groups = { dig_speed_class = 5, enchantability = 10 },

	tool_capabilities = {
		full_punch_interval = 0.83333333,
		max_drop_level = 5,
		damage_groups = { fleshy = 5 },
		punch_attack_uses = 781,
	},

	_mcl_diggroups = {
		pickaxey = { speed = 8, level = 5, uses = 1562 },
	},

	-- Crafting
	fuel_burntime = 10,
	cook_result = "mcl_core:diamond",
	cooktime = 10,
	no_craft = true,

	-- Upgrades
	_mcl_upgradable = true,
	_mcl_upgrade_item = "mcl_tools:pick_netherite",

	-- Documentation
	_doc_items_hidden = false,

	-- Overrides go here
	overrides = {
		on_use = function(itemstack, user, pointed_thing)
			-- Do some different stuff here.
		end,
	},
})
```

## Shovel API `vl_tools.shovel.register(name, def)`

Registers a shovel and its default crafting-related recipes.

### Required fields:

* `name`: Full item name passed as the first argument.
* `def.icon`
* `def.repair_material`

### Default behavior:

* Adds `groups = { tool = 1, shovel = 1 }`.
* Sets `_mcl_toollike_wield = true`.
* Sets `_repair_material = def.repair_material`.
* Uses `vl_tools.shovel.make_grass_path` as `on_place`.
* Merges `groups`, `tool_capabilities`, and `_mcl_diggroups` into shovel defaults.
* Creates crafting recipe from `repair_material`, unless `no_craft` is true.
* Registers optional fuel and cooking recipes from `fuel_burntime` and `cook_result`.

### Example:

```lua
vl_tools.shovel.register("mcl_tools:shovel_diamond", {
	-- Required properties
	description = S("Diamond Shovel"),
	icon = "default_tool_diamondshovel.png",
	repair_material = "mcl_core:diamond",

	groups = { dig_speed_class = 5, enchantability = 10 },

	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level = 5,
		damage_groups = { fleshy = 5 },
		punch_attack_uses = 781,
	},

	_mcl_diggroups = {
		shovely = { speed = 8, level = 5, uses = 1562 },
	},

	-- Crafting
	fuel_burntime = 10,
	cook_result = "mcl_core:diamond",
	cooktime = 10,
	no_craft = true,

	-- Upgrades
	_mcl_upgradable = true,
	_mcl_upgrade_item = "mcl_tools:shovel_netherite",

	-- Documentation
	_doc_items_hidden = false,

	-- Overrides go here
	overrides = {
		on_place = function(itemstack, placer, pointed_thing)
			-- Do some different stuff here.
		end,
	},
})
```

### `vl_tools.shovel.make_grass_path(itemstack, placer, pointed_thing)`

Default shovel `on_place` callback.

It handles:

* Calling a pointed node's right-click handler when appropriate.
* Protection checks.
* Turning path-creation nodes into `mcl_core:grass_path`.
* Turning path-removal nodes into `mcl_core:dirt` when sneaking.
* Applying shovel wear through `mcl_autogroup.get_wear`.

## Hoe API `vl_tools.hoe.register(name, def)`

Registers a hoe and its default crafting-related recipes.

### Required fields:

* `name`: Full item name passed as the first argument.
* `def.icon`
* `def.repair_material`

### Default behavior:

* Adds `groups = { tool = 1, hoe = 1 }`.
* Sets `_mcl_toollike_wield = true`.
* Sets `_repair_material = def.repair_material`.
* Uses `vl_tools.hoe.on_place_function(...)` as `on_place`.
* Merges `groups`, `tool_capabilities`, and `_mcl_diggroups` into hoe defaults.
* Creates two crafting recipes from `repair_material`, unless `no_craft` is true.
* Registers optional fuel and cooking recipes from `fuel_burntime` and `cook_result`.

Example:

```lua
vl_tools.hoe.register("mcl_farming:hoe_diamond", {
	-- Required properties
	description = S("Diamond Hoe"),
	icon = "farming_tool_diamondhoe.png",
	repair_material = "mcl_core:diamond",

	groups = { enchantability = 10 },

	tool_capabilities = {
		full_punch_interval = 0.25,
		damage_groups = { fleshy = 1 },
		punch_attack_uses = 1562,
	},

	_mcl_diggroups = {
		hoey = { speed = 8, level = 5, uses = 1562 },
	},

	-- Crafting
	fuel_burntime = 10,
	cook_result = "mcl_core:diamond",
	cooktime = 10,
	no_craft = true,

	-- Upgrades
	_mcl_upgradable = true,
	_mcl_upgrade_item = "mcl_farming:hoe_netherite",

	-- Documentation
	_doc_items_hidden = false,

	-- Overrides go here
	overrides = {
		on_place = function(itemstack, user, pointed_thing)
			-- Do some different stuff here.
		end,
	},
})
```

### `vl_tools.hoe.create_soil(pos)`

Turns a cultivatable node into soil or dirt.

It handles:

* Nodes in `cultivatable = 2` becoming `mcl_farming:soil`.
* Nodes in `cultivatable = 1` becoming `mcl_core:dirt`.
* Requiring air above the target node.
* Playing the default crumbly dig sound.

### `vl_tools.hoe.on_place_function(wear_divisor)`

Returns the default hoe `on_place` callback.

It handles:

* Calling a pointed node's right-click handler when appropriate.
* Protection checks.
* Calling `vl_tools.hoe.create_soil`.
* Applying hoe wear based on `wear_divisor`.

## Shears API `vl_tools.shears.register(name, def)`

Registers shears and their default crafting recipe.

### Required fields:

* `name`: Full item name passed as the first argument.
* `def.icon`
* `def.repair_material`

### Default behavior:

* Adds `groups = { tool = 1, shears = 1 }`.
* Sets `_mcl_toollike_wield = true`.
* Sets `_repair_material = def.repair_material`.
* Uses `vl_tools.shears.carve_pumpkin` as `on_place`.
* Merges `groups`, `tool_capabilities`, and `_mcl_diggroups` into shears defaults.
* Creates two crafting recipes from `repair_material`, unless `no_craft` is true.

Example:

```lua
vl_tools.shears.register("mcl_tools:shears", {
	-- Required properties
	description = S("Shears"),
	icon = "default_tool_shears.png",
	repair_material = "mcl_core:iron_ingot",

	wield_image = "default_tool_shears.png",
	stack_max = 1,

	groups = { dig_speed_class = 4, enchantability = -1 },

	tool_capabilities = {
		full_punch_interval = 0.5,
		max_drop_level = 1,
	},

	_mcl_diggroups = {
		shearsy = { speed = 1.5, level = 1, uses = 238 },
		shearsy_wool = { speed = 5, level = 1, uses = 238 },
		shearsy_cobweb = { speed = 15, level = 1, uses = 238 },
	},

	-- Crafting
	no_craft = true,

	-- Upgrades
	_mcl_upgradable = true,
	_mcl_upgrade_item = "mcl_tools:shears_upgraded",

	-- Documentation
	_doc_items_hidden = false,

	-- Overrides go here
	overrides = {
		on_place = function(itemstack, placer, pointed_thing)
			-- Do some different stuff here.
		end,
	},
})
```

### `vl_tools.shears.carve_pumpkin(itemstack, placer, pointed_thing)`

Default shears `on_place` callback.

It handles:

* Calling a pointed node's right-click handler when appropriate.
* Requiring a side click on a faceless pumpkin.
* Turning `mcl_farming:pumpkin` into `mcl_farming:pumpkin_face`.
* Dropping pumpkin seeds.
* Applying shears wear through `mcl_autogroup.get_wear`.

## Hammer API `vl_tools.hammer.register(name, def)`

Registers a hammer and its default crafting recipe.

### Required fields:

* `name`: Full item name passed as the first argument.
* `def.icon`
* `def.repair_material`

### Default behavior:

* Adds `groups = { weapon = 1, hammer = 1 }`.
* Sets `_mcl_toollike_wield = true`.
* Sets `_repair_material = def.repair_material`.
* Merges `groups`, `tool_capabilities`, and `_mcl_diggroups` into hammer defaults.
* Creates crafting recipe from `repair_material`, unless `no_craft` is true.

### Example:

```lua
vl_tools.hammer.register("vl_weaponry:hammer_diamond", {
	-- Required properties
	description = S("Diamond Hammer"),
	icon = "vl_tool_diamondhammer.png",
	repair_material = "mcl_core:diamond",

	groups = { dig_speed_class = 2, enchantability = 10 },

	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level = 5,
		damage_groups = { fleshy = 7 },
		punch_attack_uses = 1562,
	},

	_mcl_diggroups = {
		pickaxey = { speed = 4, level = 5, uses = 1562 },
	},

	-- Crafting
	no_craft = true,

	-- Upgrades
	_mcl_upgradable = true,
	_mcl_upgrade_item = "vl_weaponry:hammer_netherite",

	-- Documentation
	_doc_items_hidden = false,

	-- Overrides go here
	overrides = {
		on_use = function(itemstack, user, pointed_thing)
			-- Do some different stuff here.
		end,
	},
})
```
