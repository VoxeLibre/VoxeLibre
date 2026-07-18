# Banner patterns

Depend on `mcl_banners` and register patterns during mod initialization.
Namespaced pattern names are recommended for external mods.

```lua
mcl_banners.register_pattern("example:star", {
	description = S("@1 Star"),
	texture = "example_banner_star.png",
	loom = true, -- optional, defaults to true, let the pattern appear in the loom
	pattern_item = "example:star_pattern", -- optional and reusable, additional item required to craft the banner in the loom
})
```

A `pattern_item` must have the `banner_pattern=1` item group.
