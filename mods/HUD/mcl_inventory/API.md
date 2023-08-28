# `mcl_inventory`

## `mcl_inventory.register_survival_inventory_tab(def)`

```lua
mcl_inventory.register_survival_inventory_tab({
	-- Page identifier
	-- Used to uniquely identify the tab
	id = "test",

	-- The tab description, can be translated
	description = "Test",

	-- The name of the item that will be used as icon
	item_icon = "mcl_core:stone",

	-- If true, the main inventory will be shown at the bottom of the tab
	-- Listrings need to be added by hand
	show_inventory = true,

	-- This function must return the tab's formspec for the player
	build = function(player)
		return "label[1,1;Hello hello]button[2,2;2,2;Hello;hey]"
	end,

	-- This function will be called in the on_player_receive_fields callback if the tab is currently open
	handle = function(player, fields)
		print(dump(fields))
	end,

	-- This function will be called to know if a player can see the tab
	-- Returns true by default
	access = function(player)
	end,
```
