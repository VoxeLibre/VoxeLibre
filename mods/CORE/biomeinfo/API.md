# Biome Info API
This document explains the API of this mod.

## v6 mapgen functions
These are functions for the v6 mapgen only.

Use these functions only in worlds in which the v6 mapgen is used.
If you use these in any other mapgen, bad things might happen.

### `biomeinfo.get_v6_humidity(pos)`
Get the biome humidity at pos (for v6 mapgen).

### `biomeinfo.get_v6_heat(pos)`
Get the biome heat/temperature at pos (for v6 mapgen).

### `biomeinfo.get_v6_biome(pos)`
Get the v6 biome at pos.
Returns a string, which is the unique biome name.

Note: This function currently ignores the `biomeblend` v6 mapgen flag,
it just pretends this setting is disabled.
This is normally not a problem, but at areas where biomes blend,
the result is not perfectly accurate and just an estimate.

### `biomeinfo.get_active_v6_biomes()`
Returns a table containing the names of all v6 biomes that are actively
used in the current world, e.g. those that have been activated
by the use of the mapgen v6 flags (`mgv6_spflags`).

### `biomeinfo.all_v6_biomes`
This is a table containing all v6 biomes (as strings), even those that
might not be used in the current world.

### v6 biome names

These are the biome names used in this mod:

* Normal
* Desert
* Jungle
* Tundra
* Taiga
