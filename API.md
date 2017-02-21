# API
## Groups
MineClone 2 makes very extensive use of groups. Making sure your items and objects are members of the correct group is a good and easy way to ensure compability without using any function calls.
Groups are explained in `GROUPS.md`.

## APIs for adding simple things
You can add simple things by calling functions in the various MineClone 2 mods.

* Fences and fence gates: See `mods/ITEMS/mcl_fences/API.md`.
* Walls: See `mods/ITEMS/mcl_walls/API.md`

### Undocumented APIs
You can also add stuff for the following thins, but the APIs are currently undocumented. These mods are very similar to Minetest Game.

* Doors: See `mods/ITEMS/doors`
* Stairs and slabs: See `mods/ITEMS/stairs` and `mods/ITEMS/mcstair`
* Beds: See `mods/ITEMS/beds`
* Buckets (for new liquids): See `mods/ITEMS/bucket`
* Panes (like glass panes and iron bars): See `mods/ITEMS/xpanes`

WARNING! These 5 mods may be renamed or changed in future releases, and compability could be broken.

## Mobs
This mod uses Mobs Redo [`mobs`] by TenPlus1, a very powerful mod for adding mods of various kinds.
There are minor modificiations for MineClone 2 compability and some items have been removed or moved to other mods, but the API is identical to the original.
You can add your own mobs, spawn eggs and spawning rules with this mod.
API documnetation is included in `mods/ENTITIES/mobs/api.txt`.

Note that mobs in MineClone 2 are still very experimental, everything about mobs may change radically at any time!

## Other APIs
* Statbars / HUD bars: See `mods/HUD/hudbars`
* Hunger: See `mods/PLAYER/mcl_hunger/API.md`

## Other things of interest
Mods found in `mods/CORE` contain important core APIs and utility functions, used throughout the subgame.
