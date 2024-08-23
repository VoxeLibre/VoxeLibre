# vl_terraforming
Terraforming module for VoxeLibre and MineClonia

This module provides the following key functionalities:

- given a position, find the ground surface
- given a position and size, find a balanced height (trimmed median height)
- build a baseplate for a building
- clear the area above a building


## Rounded corners support

To get nicer looking baseplates, the code supports rounded corners.

These are obtained by intersecting the square with an ellipse.
At zero rounding, we want the line go through the corner, at sx/2, sz/2.

For this, we need to make ellipse sized $2a=\sqrt{2} sx$, $2b=\sqrt{2} sz$,
Which yields $a = sx/\sqrt{2}$, $b=sz/\sqrt{2}$ and $a^2=0.5 sx^2$, $b^2=0.5 sz^2$
To get corners, we decrease $a$ and $b$ by the corners parameter each
The ellipse condition $dx^2/a^2+dz^2/b^2 \leq 1$ then yields $dx^2/(0.5 sx^2) + dz^2/(0.5 sz^2) \leq 1$
We use $wx2=2 sx^-2$, $wz2=2 sz^-2$ and then $dx^2 wx2 + dz^2 wz2 \leq 1$.


## vl_terraforming.find_ground_vm(vm, pos)

Find ground starting at the given position. When in a solid area, moves up; otherwise searches downwards.

This will ignore trees, mushrooms, and similar surface decorations.


## vl_terraforming.find_under_air_vm(vm, pos)

Find ground or liquid surface, starting at the given position. When in a solid or liquid area, moves up; otherwise searches downwards.

This will ignore trees, mushrooms, and similar surface decorations.


## vl_terraforming.find_liquid_surface_vm(vm, pos)

Find a liquid surface starting at the given position. When in a solid or liquid area, moves up; otherwise searches downwards.

This will ignore trees, mushrooms, and similar surface decorations.



## vl_terraforming.find_level_vm(vm, cpos, size, tolerance, mode)

Find "level" ground for a building, centered at the given position, and of the given size.

For this, five samples are taken: center, top left, top right, bottom left, and bottom right.

One of these values may be "extreme", and tolerance specifies the maximum height difference of the remaining four values.

The (rounded) median of these values is used, unless tolerance is set to "min" or "max".

The "mode" can be set to "solid" (default), "liquid" (liquid surfaces only), "under_air" (both liquid and solid surfaces).


## vl_terraforming.foundation_vm(vm, px, py, pz, sx, sy, sz, corners, surface_mat, platform_mat, stone_mat, dust_mat, pr)

The position (px, py, pz) and the size (sx, sy, sz) give the volume of the main base plate,
where sy < 0, so that you can later place the structure at (px, py, pz).

The baseplate will be grown by 1 in the level below, to allow mobs to enter, then randomly fade away below.
-sy can be used to control a minimum depth.

Corners specifies how much to cut the corners, use 0 for a square baseplate.

The materials specified (as lua nodes, to have param2 support) are used a follows:

- surface_mat for surface nodes
- platform_mat below surface nodes
- stone_mat randomly used below platform_mat
- dust_mat on top of surface nodes (snow cover, optional)

pr is a PcgRandom random generator


## vl_terraforming.clearance_vm(vm, px, py, pz, sx, sy, sz, corners, surface_mat, dust_mat, pr)

The position (px, py, pz) and the size (sx, sy, sz) give the volume overhead to clear.

The area will be grown by 1 above, to allow mobs to enter, then randomly fade away as height increases beyond sy.

Corners specifies how much to cut the corners, use 0 for a square area.

The surface_mat will be used to turn nodes into surface nodes when widening the area.

pr is a PcgRandom random generator

## TODO

- [ ] add an API that works on VM buffers
- [ ] add an API version working on the non-VM API
- [ ] benchmark if VM is actually faster than not using VM (5.9 has some optimizations not in VM)
- [ ] improve tree removal

