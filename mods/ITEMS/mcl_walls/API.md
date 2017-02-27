# API for MineClone 2 walls

This API allows you to add more walls (like the cobblestone wall) to MineClone 2.

## `mcl_walls.register_wall(nodename, description, craft_material, tiles, invtex, groups, sounds)`

Adds a new wall type. This is optimized for stone-based walls, but other materials are theoretically possible, too.

The current implementation registers a couple of nodes for the different nodeboxes.
All walls connect to solid nodes and all other wall nodes.

If `craft_material` is not `nil` it also adds a crafting recipe of the following form:

    CCC
    CCC
    
    Yields 6 walls
    C = craft_material (can be group)

### Parameters
* `nodename`: Full itemstring of the new wall node (base node only). ***Must not have an underscore!***
* `description`: Item description of item (tooltip), visible to user
* `craft_material`: Item to be used in the crafting recipe. If `nil`, no crafting recipe will be added
* `tiles`: Wall textures table, same syntax as for `minetest.register_node`
* `inventory_image`: Inventory image (optional, default is an ugly 3D image)
* `groups`: Base group memberships (optional, default is `{pickaxey=1}`)
* `sounds`: Sound table (optional, by default default uses stone sounds)

The following groups will automatically be added to the nodes (where applicable), you do not need to add them
to the `groups` table:

* `deco_block=1`
* `not_in_creative_inventory=1` (except for the base node which the player can take)
* `wall=1`

### Example

    mcl_walls.register_wall("mymod:granitewall", "Granite Wall", {"mymod_granite.png"}, "mymod_granite_wall_inv.png")
