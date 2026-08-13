# `vl_weaponry` API

`vl_weaponry` combines tool types with compatible materials. A concrete tool
is created only when either its tool type or its material provides a complete
pair definition. Types and materials may be registered in either order.

## Concrete tool definitions

A tool type can own a concrete definition in its `materials` table:

```lua
vl_weaponry.register_tool_type("example:hammer", {
	materials = {
		copper = {
			item_name = "example:hammer_copper",
			description = S("Copper Hammer"),
			inventory_image = "example_copper_hammer.png",
		},
	},
	-- base_stats, build_definition, ...
})
```

Alternatively, a material can own it in its `tool_types` table:

```lua
vl_weaponry.register_tool_material("copper", {
	tool_types = {
		["example:hammer"] = {
			item_name = "example:hammer_copper",
			description = S("Copper Hammer"),
			inventory_image = "example_copper_hammer.png",
		},
	},
	-- repair_material, stat_modifiers, ...
})
```

Do not define the same pair on both sides; this is an error. Every concrete
definition requires:

- `item_name`: complete namespaced item ID.
- `description`: non-empty, already translated item description.
- `inventory_image`: non-empty, complete texture name including its prefix.
- `upgrade_item`: optional complete item ID used as the smithing upgrade target.

## `vl_weaponry.register_tool_type(namespaced_prefix, definition)`

The definition fields are:

- `materials`: optional concrete definitions keyed by material name.
- `smelting_yield`: optional maximum smelting yield. Conventionally this is
  nine times the number of material ingots in the tool's recipe.
- `base_stats`: numeric semantic stats consumed by `build_definition`.
- `build_definition(material_name, material, stats)`: returns the behavioral
  portion of a Luanti tool definition. The API adds the concrete description
  and inventory image afterward.
- `register_crafts(item_name, craft_material, material)`: optional recipe
  callback.

## `vl_weaponry.register_tool_material(name, definition)`

The definition fields are:

- `tool_types`: optional concrete definitions keyed by namespaced type name.
- `repair_material` and `craft_material`: item strings used for repairing and
  recipes.
- `stat_modifiers`: modifiers keyed by the semantic stat names used by types.
- `craftable`: set to `false` to suppress normal recipes.
- `fire_immune` and `max_enchant_level`: optional common tool traits.
- `burn_time`: optional positive furnace fuel time applied to every tool made
  from the material.
- `smelting_output`: optional namespaced item name produced by smelting.

When a type has `smelting_yield` and its material has `smelting_output`, the
API registers a 10-second cooking recipe. A pristine tool produces the full
yield; worn tools produce the yield in proportion to remaining durability,
rounded up, with a minimum output of one item.

A modifier has optional `multiply` and `add` numbers. It is evaluated as:

```lua
result = base * (modifier.multiply or 1) + (modifier.add or 0)
```

Only stats declared by a tool type are calculated. Material modifiers for
other tool types are ignored. If neither side defines a concrete pair, no item
or recipe is registered for that combination.

## Tool behaviors

The standard `on_place` behaviors are public so other tools can reuse them:

- `vl_weaponry.make_grass_path(itemstack, user, pointed_thing)`
- `vl_weaponry.make_stripped_trunk(itemstack, user, pointed_thing)`
- `vl_weaponry.carve_pumpkin(itemstack, user, pointed_thing)`

Hoe behavior remains owned by `mcl_farming`:

- `mcl_farming.create_soil(pos)`
- `mcl_farming.hoe_on_place(itemstack, user, pointed_thing)`
