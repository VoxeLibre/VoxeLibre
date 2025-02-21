# `vl_terraforming` -- Terraforming module

Terraforming module built with VoxeLibre and MineClonia in mind, but also useful for other games.

This module provides the following key functionalities:

- given a position, find the ground surface
- given a position and size, find a balanced height (trimmed median height)
- build a baseplate for a building
- clear the area above a building

All methods have a `_vm` version to work with Lua Voxel Manipulators

## Rounded corners support

To get nicer looking baseplates, the code supports rounded corners.

These are obtained by intersecting the square with an ellipse.
At zero rounding, we want the line go through the corner, at sx/2, sz/2.

For this, we need to make ellipse sized $2a=\sqrt{2} sx$, $2b=\sqrt{2} sz$,
Which yields $a = sx/\sqrt{2}$, $b=sz/\sqrt{2}$ and $a^2=0.5 sx^2$, $b^2=0.5 sz^2$
To get corners, we decrease $a$ and $b$ by the corners parameter each
The ellipse condition $dx^2/a^2+dz^2/b^2 \leq 1$ then yields $dx^2/(0.5 sx^2) + dz^2/(0.5 sz^2) \leq 1$
We use $wx2=2 sx^-2$, $wz2=2 sz^-2$ and then $dx^2 wx2 + dz^2 wz2 \leq 1$.


## `vl_terraforming.find_ground(pos)`

Find ground starting at the given position. When in a solid area, moves up; otherwise searches downwards.

This will ignore trees, mushrooms, and similar surface decorations.


## `vl_terraforming.find_under_air(pos)`

Find ground or liquid surface, starting at the given position. When in a solid or liquid area, moves up; otherwise searches downwards.

This will ignore trees, mushrooms, and similar surface decorations.


## `vl_terraforming.find_liquid_surface(pos)`

Find a liquid surface starting at the given position. When in a solid or liquid area, moves up; otherwise searches downwards.

This will ignore trees, mushrooms, and similar surface decorations.


## `vl_terraforming.find_under_water_surface(pos)`

Find a solid surface covered by water starting at the given position. When in a solid area, moves up; otherwise searches downwards.

This will ignore trees, mushrooms, and similar surface decorations.


## `vl_terraforming.find_level(cpos, miny, maxy, size, tolerance, surface, mode)`

Find "level" (sufficiently even) ground for a structure, centered at the given position, and of the given size.

For this, five samples are taken: center, top left, top right, bottom left, and bottom right.

One of these values may be "extreme", and tolerance specifies the maximum height difference of the remaining four values.

The `surface` can be set to:
- `"solid"` (default, i.e., solid under air)
- `"liquid"` (liquid under air)
- `"under_air"` (both liquid and solid surfaces)
- `"under_water"` (solid under water)

The `mode` can be set to:
- `"median"` (default, use the median height, rounded)
- `"min"` (use the lowest support coordinate)
- `"max"` (use the highest support coordinate)


## `vl_terraforming.foundation(px, py, pz, sx, sy, sz, corners, surface_mat, platform_mat, stone_mat, dust_mat, pr)`

The position `(px, py, pz)` and the size `(sx, sy, sz)` give the volume of the main base plate,
where `sy < 0`, so that you can later place the structure at `(px, py, pz)`.

The baseplate will be grown by 1 in the level below, to allow mobs to enter, then randomly fade away below.
The negative depth `sy` can be used to control a minimum depth.

Corners specifies how much to cut the corners, use 0 for a square baseplate.

The materials specified (as lua nodes, to have `param2` coloring support) are used a follows:

- `surface_mat` for surface nodes
- `platform_mat` below surface nodes
- `stone_mat` randomly used below `platform_mat`
- `dust_mat` on top of surface nodes (snow cover, optional)

`pr` is a PcgRandom random generator


## `vl_terraforming.clearance(px, py, pz, sx, sy, sz, corners, surface_mat, dust_mat, pr)`

The position `(px, py, pz)` and the size `(sx, sy, sz)` give the volume overhead to clear.

The area will be grown by 1 above, to allow mobs to enter, then randomly fade away as height increases beyond `sy`.

`corners` specifies how much to cut the corners, use 0 for a square area.

`surface_mat` is the node used to turn nodes into surface nodes when widening the area. If set, the `dust_mat` will be sprinkled on top.

`pr` is a PcgRandom random generator


## TODO

- [ ] make even more configurable
- [ ] add ceiling placement
- [ ] underground support (no surface material)
- [ ] improve tree and snow removal
