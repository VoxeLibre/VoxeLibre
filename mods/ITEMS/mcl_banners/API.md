# Banner patterns

Depend on `mcl_banners` and register patterns during mod initialization.
Namespaced pattern names are recommended for external mods.

```lua
mcl_banners.register_pattern("example:star", {
	description = S("@1 Star"),
	texture = "example_banner_star.png",
	shield_texture = "example_shield_star.png",
	loom = true, -- optional, defaults to true, let the pattern appear in the loom
	pattern_item = "example:star_pattern", -- optional and reusable, additional item required to craft the banner in the loom
})
```

A `pattern_item` must have the `banner_pattern=1` item group.
Both `texture` and `shield_texture` are required masks (filenames or texture
expressions).

## Retired pattern migrations

Register replacement patterns first, then map a retired name to an ordered,
nonempty list of those patterns:

```lua
mcl_banners.register_pattern_migration("example:old_design", {
	"example:upper_square",
	"example:lower_rectangle",
})
```
