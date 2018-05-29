# API for `mcl_stairs`

Register your own stairs and slabs!

## Quick start

Register platinum stair and slab based on node `example:platinum`:

```
mcl_stairs.register_stair_and_slab_simple("platinum", "example:platinum", "Platinum Stair", "Platinum Slab", "Double Platinum Slab")
```

## `mcl_stairs.register_stair_and_slab_simple(subname, sourcenode, desc_stair, desc_slab, double_description, corner_stair_texture_override)`
Register a simple stair and a slab. The stair and slab will inherit all attributes from `sourcenode`. The `sourcenode` is also used as the item for crafting recipes.

This function is meant for simple nodes; if you need more flexibility, use one of the other functions instead.

See `register_stair` and `register_slab` for the itemstrings of the registered nodes.

### Parameters
* `subname`: Name fragment for node itemstrings (see `register_stair` and `register_slab`)
* `sourcenode`: The node on which this stair is based on
* `desc_stair`: Description of stair node
* `desc_slab`: Description of slab node
* `double_description`: Description of double slab node
* `corner_stair_texture_override`: Optional, see `register_stair`

## `mcl_stairs.register_stair_and_slab(subname, recipeitem, groups, images, desc_stair, desc_slab, sounds, hardness, double_description, corner_stair_texture_override)`
Register a simple stair and a slab, plus crafting recipes. In this function, you need to specify most things explicitly.

### Parameters
* `desc_stair`: Description of stair node
* `desc_slab`: Description of slab node
* Other parameters: Same as for `register_stair` and `register_slab`

## `mcl_stairs.register_stair(subname, recipeitem, groups, images, description, sounds, hardness, corner_stair_texture_override)`
Registers a stair. This also includes the inner and outer corner stairs, they are added automatically. Also adds crafting recipes.

The itemstrings for the registered nodes will be of the form:

* `mcl_stairs:stair_<subname>`: Normal stair
* `mcl_stairs:stair_<subname>_inner`: Inner stair
* `mcl_stairs:stair_<subname>_outer`: Outer stair

### Parameters
* `subname`: Name fragment for node itemstrings (see above)
* `recipeitem`: Item for crafting recipe. Use `group:` prefix to use a group instead
* `groups`: Groups used for stair
* `images`: Textures
* `description`: Stair description/tooltip
* `sounds`: Sounds table
* `hardness`: MCL2 block hardness value
* `corner_stair_texture_override`: Optional. Custom textures for corner stairs, see below

`groups`, `images`, `sounds` or `hardness` can be `nil`, in which case the value is inhereted from the `recipeitem`.

#### `corner_stair_texture_override`
This optional parameter specifies the textures to be used for corner stairs. 

It can be one of the following data types:

* string: one of:
    * "default": Use same textures as original node
    * "woodlike": Take first frame of the original tiles, then take a triangle piece
                  of the texture, rotate it by 90° and overlay it over the original texture
* table: Specify textures explicitly. Table of tiles to override textures for
         inner and outer stairs. Table format:
             { tiles_def_for_outer_stair, tiles_def_for_inner_stair }
* nil: Equivalent to "default"

## `mcl_stairs.register_slab(subname, recipeitem, groups, images, description, sounds, hardness, double_description)`
Registers a slab and a corresponding double slab. Also adds crafting recipe.

The itemstrings for the registered nodes will be of the form:

* `mcl_stairs:slab_<subname>`: Slab
* `mcl_stairs:slab_<subname>_top`: Upper slab, used internally
* `mcl_stairs:slab_<subname>_double`: Double slab

### Parameters
* `double_description`: Node description/tooltip for double slab
* Other parameters: Same as for `register_stair`

