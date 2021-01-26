# Missing features in Minetest to recreate Minecraft features

A side goal of the MineClone 2 project is to find any shortcomings of Minetest which make it impossible to recreate a Minecraft feature exactly.
This file lists some of the missing features in Minetest which MineClone 2 would require.

## No workaround possible
For these features, no easy Lua workaround could be found.

### Lua API
#### Tools/wielded item
- “Lock” hotbar for a brief time after using an item, making it impossible to switch item or to attach/mine/build until the delay is over (For eating with delay)
- Tool charging: Holding down the mouse and releasing it, applying a “power level” (For bow and arrows, more charge = higher arrow range) ([issue 5212](https://github.com/minetest/minetest/issues/5212))
- [Dual Wielding](http://minecraft.gamepedia.com/Dual_wield)
- Eating/drinking animation ([issue 2811](https://github.com/minetest/minetest/issues/2811))

#### Nodes
- Light level 15 for nodes (not sunlight)
- Nodes makes light level drop by 2 or or more per node ([issue 5209](https://github.com/minetest/minetest/issues/5209))

## Interface
- Inventory: Hold down right mouse button while holding an item stack to drop items into the slots as you move the mouse. Makes crafting MUCH faster
- Sneak+Leftclick on crafting output crafts as many items as possible and immediately puts it into the player inventory ([issue 5211](https://github.com/minetest/minetest/issues/5211))
- Sneak+click puts items in different inventories depending on the item type (maybe group-based)? Required for sneak-clicking to armor slots

## Workaround theoretically possible
For these features, a workaround (or hack ;-)) by using Lua is theoretically possible. But engine support would be clearly better, more performant, more reliable, etc.

### Lua API
#### Nodes
- Change walking speed on block (soul sand)
- Change jumping height on block (soul sand), 
- Change object movement speed *through* a block, but for non-liquids (for cobweb)
- Add `on_walk_over` event
- Set frequency in which players lose breath. 2 seconds are hardcoded in Minetest, in Minecraft it's 1 second
- Set damage frequency of `damage_per_second`. In Minecraft many things damage players every half-second rather than every second
- Possible to damage players directly when they are with the head inside. This allows to add Minecraft-like suffocation
- Sneak+click on inventory slot should be able to put items into additional “fallback inventories” if the first inventory is full. Useful for large chests

#### Nice-to-haye
- Utility function to rotate pillar-like nodes, requiring only 3 possible orientations (X, Y, Z). Basically this is `minetest.rotate_node` but with less orientations; the purpur pillar would mess up if a mirrored rotation would be possible. This is already implemented in MCL2, See `mcl_util` for more infos
