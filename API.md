# API
## Groups
VoxeLibre makes very extensive use of groups. Making sure your items and objects have the correct group memberships is very important.
Groups are explained in `GROUPS.md`.

## Mod naming convention
Mods mods in VoxeLibre follow a simple naming convention: Mods with the prefix "`vl_`" and “`mcl_`” are specific to VoxeLibre (formerly known as MineClone2), although they may be based on an existing standalone. Mods which lack this prefix are *usually* verbatim copies of a standalone mod. Some modifications may still have been applied, but the APIs are held compatible.

## Adding items
### Special fields

Items can have these fields:
* `_mcl_generate_description(itemstack)`: Required for any items which manipulate their
   description in any way. This function takes an itemstack of its own type and must set
   the proper advanced description for this itemstack. If you don't do this, anvils will
   fail at properly restoring the description when their custom name gets cleared at an
   anvil.
   See `mcl_banners` for an example.

Tools can have these fields:
* `_mcl_diggroups`: Specifies the digging groups that a tool can dig and how
  efficiently.  See `_mcl_autogroup` for more information.

All nodes can have these fields:

* `_mcl_hardness`: Hardness of the block, ranges from 0 to infinity (represented by -1). Determines digging times. Default: 0
* `_mcl_blast_resistance`: How well this block blocks and resists explosions. Default: 0
* `_mcl_falling_node_alternative`: If set to an itemstring, the node will turn into this node before it starts to fall.
* `_mcl_after_falling(pos)`: Called after a falling node finished falling and turned into a node.

Use the `mcl_sounds` mod for the sounds.

## APIs
A lot of things are possible by using one of the APIs in the mods. Many of them are documented in `API.md` files located in the directories of the specific mods. Some use `.txt` files or have some documentation in the comments along the code. Note that not all APIs are documented yet, but it is planned. The following APIs should be more or less stable but keep in mind that VoxeLibre is still unfinished. All directory names are relative to `mods/`

### Items
* Doors: `ITEMS/mcl_doors`
* Fences and fence gates: `ITEMS/mcl_fences`
* Stairs and slabs: `ITEM/mcl_stairs`
* Walls: `ITEMS/mcl_walls`
* Beds: `ITEMS/mcl_beds`
* Buckets: `ITEMS/mcl_buckets`
* Dispenser support: `ITEMS/REDSTONE/mcl_dispensers`
* Campfires: `ITEMS/mcl_campfires`

### Mobs
* Mobs: `ENTITIES/mcl_mobs`

VoxeLibre uses its own mobs framework, which is a fork of Mobs Redo [`mobs`] by TenPlus1.

You can add your own mobs, spawn eggs and spawning rules with this mod.
API documnetation is included in `ENTITIES/mcl_mobs/api.txt`.

This mod includes modificiations from the original Mobs Redo. Some items have been removed or moved to other mods.
The API is mostly identical, but a few features have been added. Compability is not really a goal,
but function and attribute names of Mobs Redo 1.41 are kept.
If you have code for a mod which works fine under Mobs Redo, it should be easy to make it work in VoxeLibre.
chances are good that it works out of the box.

### Help
* Item help texts: `HELP/doc/doc_items`
* Low-level help entry and category framework: `HELP/doc/doc`
* Support for lookup tool (required for all entities): `HELP/doc/doc_identifier`

### HUD
* Statbars: `HUD/hudbars`

### Utility APIs
* Change player physics: `PLAYER/playerphysics`
* Change player FOV: `PLAYER/mcl_fovapi`
* Select random treasures: `CORE/mcl_loot`
* Get flowing direction of liquids: `CORE/flowlib`
* `on_walk_over` callback for nodes: `CORE/walkover` 
* Get node names close to player (to reduce constant querying): `PLAYER/mcl_playerinfo`
* Explosion API
* Music discs API
* Flowers and flower pots

### Unstable APIs
The following APIs may be subject to change in the future. You could already use these APIs but there will probably be breaking changes in the future, or the API is not as fleshed out as it should be. Use at your own risk!

* Panes (like glass panes and iron bars): `ITEMS/xpanes`
* `_on_ignite` callback: `ITEMS/mcl_fire`
* Farming: `ITEMS/mcl_farming`
* Anything related to redstone: Don't touch (yet)
* Any other mod not explicitly mentioned above

### Planned APIs

* Saplings and trees
* Custom banner patterns
* Custom dimensions
* Custom portals
* Dispenser and dropper support
* Proper sky and weather APIs

