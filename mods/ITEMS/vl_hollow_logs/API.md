# ```vl_hollow_logs```

This mod registers hollow logs derived from normal logs.
Hollow logs mostly have a decorative function, but some of them can be used in recipes. Changes may appear soon.

## Functions:
### ```vl_hollow_logs.register_hollow_log(defs)```
This is the function that registers the hollow trunk.
For a hollow log to be registered, the <span style="color:firebrick"> defs </span> parameter must be a table that contains up to 5 values, which are, in this order, the <span style="color:firebrick"> itemstring </span>  of the hollow log, the <span style="color:firebrick"> itemstring </span>  of the stripped hollow log, the <span style="color:firebrick"> description </span>  of the hollow log, the <span style="color:firebrick"> description </span>  of the stripped hollow log and, optionally, a <span style="color:turquoise"> boolean </span>  to inform whether this trunk is NOT flammable. If the hollow log is defined as flammable, it becomes part of the <span style="color:springgreen"> hollow_log_burnable </span> group, which allows the log to be used as fuel for furnaces and also allows it to be an ingredient for chacoal.

Examples:
```lua
-- Flammable
{"tree", "stripped_oak", S("Hollow Oak Log"), S("Stripped Hollow Oak Log")}

-- Not flammable
{"crimson_hyphae", "stripped_crimson_hyphae", S("Hollow Crimson Stem"), S("Stripped Hollow Crimson Stem"), true}
```
### ```vl_hollow_logs.register_craft(material, result)```

This function records the crafting recipe for a hollow log based on its non-hollow variant.
This function also defines a recipe for the stonecutter. The <span style="color:firebrick"> material </span>  and <span style="color:firebrick"> result </span>  parameters must be, respectively, the <span style="color:firebrick"> complete itemstring </span>  of the source material and the (partial) <span style="color:firebrick"> itemstring </span>  of the result. See the following examples:

```lua
vl_hollow_logs.register_craft("mcl_core:tree", "tree")

vl_hollow_logs.register_craft("mcl_crimson:stripped_crimson_hyphae", "stripped_crimson_hyphae")
```
