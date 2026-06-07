# VoxeLibre Formspec API

## `mcl_formspec.label_color`

Contains the color used for formspec labels, currently `#313131`.

## Old formspec coordinate conversion

These helpers convert geometry from the old formspec coordinate system to the
real coordinate system enabled by formspec version 2 and newer:

- `mcl_formspec.old_to_real.position(x, y)`
- `mcl_formspec.old_to_real.spaced_geometry(w, h)`
- `mcl_formspec.old_to_real.button_geometry(w, h)`
- `mcl_formspec.old_to_real.button(x, y, w, h)`
- `mcl_formspec.old_to_real.label(x, y)`

They are intended for migrating APIs or forms that still accept old formspec
coordinates. New forms should use real coordinates directly.

## `mcl_formspec.get_itemslot_bg(x, y, w, h)`

Get the background of inventory slots (formspec version = 1)

ex:

```lua
local formspec = table.concat({
	mcl_formspec.get_itemslot_bg(0, 0, 5, 2),
	"list[current_player;super_inventory;0,0;5,2;]",
})
```

## `mcl_formspec.get_itemslot_bg_v4(x, y, w, h, size, texture)`

Get the background of inventory slots (formspec version > 1)

Works basically the same as `mcl_formspec.get_itemslot_bg(x, y, w, h)` but have more customisation options:

- `size`: allow you to customize the size of the slot borders, default is 0.05
- `texture`: allow you to specify a custom texture tu use instead of the default one

ex:

```lua
local formspec = table.concat({
	mcl_formspec.get_itemslot_bg_v4(0.375, 0.375, 5, 2, 0.1, "super_slot_background.png"),
	"list[current_player;super_inventory;0.375,0.375;5,2;]",
})
```

## `mcl_formspec.itemslot_border_size`

Contains the default item slot border size used by `mcl_formspec.get_itemslot_bg_v4`, currently 0.05
