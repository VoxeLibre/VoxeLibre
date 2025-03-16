# `mcl_boats` API

## Functions

* `mcl_boats.register_boat(name, def)`
    * `name` is the new boat craftitem's itemstring
    * `def` is a boat definition table


## Boat definition table

```lua
{
	item = {
		-- Boat item definition override
		-- Put at least a `description` and an `inventory_image`
	},
	item_chest = {
		-- Chest boat item definition override
		-- Optional (a chest boat won't be registered if nil)
		-- Put at least a `description` and an `inventory_image`
	},
	entity_texture = "", -- texture for the boat entity
	material = "", -- itemstring of the crafting material for the boat item
}
```
