# vl_structures

Updated API for structure spawning, by kno10.

This module was developed with VoxeLibre and Mineclonia in mind, but means to be portable or at least easy to adapt to other games.

## structure definition

Structures in this API are defined using the following table:

```
{
    name =,                 -- structure identifier for logging
    priority = 100,         -- priority to make placement order more deterministic. Default 100 except for terrain features (900)
    chunk_probability =,    -- approx. probability (in 0:100) that a block spawns this structure if the other conditions hold
    fill_ratio = nil,       -- OR number of structure spawn attempts per map chunk, to allow multiple
    noise = nil,            -- OR specify noise parameters, as per core.register_decoration
    y_min =,                -- minimum depth
    y_max =,                -- maximum depth
    biomes = {},            -- biome restriction
    place_on = {},          -- if nil, the structure will not be automatically spawned
    spawn_by = {},          -- nodes required nearby, as in core.register_decoration
    num_spawn_by =,         -- number of nodes required nearby
    prepare =,              -- configure foundation and clearing, see vl_terraforming -- ignored for place_func
    flags =,                -- core.register_decoration placement flags, default: "place_center_x, place_center_z"
    y_offset =,             -- vertical placement offset, can be a number or a function(pr) returning a number
    filenames = {},         -- table of schematic filenames
    schematics = {},        -- OR table of preloaded schematics
    place_func = function(pos,def,pr,blockseed)
                            -- OR a function to place a structure
    after_place = function(pos,def,pr,pmin,pmax,size,rotation)
                            -- callback executed after successful placement
    loot =,                 -- a table of loot tables for mcl_loot indexed by node names -- ignored for place_func, to be removed
                            -- e.g. { ["mcl_chests:chest_small"] = {loot},... }
    terrain_feature =,      -- affects placement priority and disables logging for uninteresting structures
    no_registry =,          -- do not register the structure for the /locate command (implied for terrain features)
    daughters =,            -- substructures to spawn, unstable API
    hash_mindist =,         -- minimum distance for spawn attempts using minhash rule (3d version)
    hash_mindist_2d =,      -- minimum distance for spawn attempts using minhash rule (cylinder version)
    hash_seed =,            -- seed value for hashing, defaults to hash(name)
}
```

### MinHash to avoid neighboring structures

A structure spawn will only be attempted with a minimum distance of a few blocks.
To make this computationally cheap, deterministic, and independent of block generation order,
every chunk (usually 80 nodes, for smaller distances we can also use less) is assigned a pseudo-random
hash value, which is inexpensive to compute also for non-existant blocks.
Before spawning a structure, it is first checked that all blocks within a radius
have a higher minhash value, only then a structure spawn attempt will be performed.
By symmetry, this means that on all neighbor chunks, there exists a lower hash value,
and hence the structure is not spawned there.

Example:

For simplicity assume our hash values are two digit numbers, and we have a distance of 2, pretending 2D.
We check all chunks with a maximum distance of 2, so in 2D we check 12 neighbors, and compute 13 hash values
of block positions. Assuming we get the following hash values:
```
      42
   77 99 33
12  7  2 19 11
   23 21  8
       9
```
In this case, we would attempt a structure spawn, because 2 is the smallest number.
If we instead had obtained 10 (or 7) we would not attempt a structure spawn, because it is not the smallest.
Similarly, we will not attempt a spawn in the left neighbor, with hash 7, because it is larger than 2.

There are a number of challenges to handling spawn probabilities in this scheme, beginning with biome and
terrain limitations. Chunks are generated in 3d, and if terrain height crosses the y=48 border, we could get
two spawns in the same region if we really only use 2d. But just taking only one out of three y chunks
reduces the success rate to 1/3.

## vl_structures.register_structure(name,def)

Register a new structure spawn.

For extension modules, if you choose a larger (later) placement priority, this
should be less likely to change spawning of original structures and keep the
resulting maps more consistent across seeds.

## vl_structures.load_schematic(filename, name)

Load a schematic from a given file name, the name is used for error logging; otherwise it will be derived from the file name.

## vl_structures.place_structure(pos, def, pr, blockseed, rot)

Places structure defined by def at position pos, using the pseudorandom pr.

blockseed is only used by the place_func call, and unused for many simple structures.

rot is optional, it will then be chosen randomly.

This is usually called from the mapgen decoration gennotify mechanism, but can be used for substructure spawns.

## vl_structures.registered_structures

Table of the registered structure defintions indexed by name.

## vl_structures.place_schematic(pos, yoffset, schematic, rotation, def, pr)

Spawn a structure as defined by "def" at the given position, yoffset, schematic, and rotation.

This is primarily meant for substructure placement where size (and hence schematic and offsets) need to be fixed before computing the position.

## vl_structures.parse_rotation(rotation, pr)

Parse a rotation value (stirngs "0", "90", "180", "270" or "random"), or choosing a random rotation.

## vl_structures.size_rotated(size, rotation)

Return the size after rotation, i.e., if rotation is 90 or 270, the x and z sizes are swapped.

## vl_structures.top_left_from_flags(pos, size, flags)

Compute the top left corner from the flags, i.e., parse place_center_x, place_center_z etc.

## vl_structures.get_extends(pos, size, yoffset, rotation, flags)

Parse rotation and flags, and return the center, minimum corner, maximum corner, and size.

## vl_structures.init_node_construct(pos)

Call on_construct callbacks for the node at the given position.

## vl_structures.construct_nodes(p1,p2,nodes)

Find all nodes of the listed types in the area and call their on_construct callbacks.

## vl_structures.fill_chests(p1,p2,loot,pr)

Fill all loot containers in the area, requires mcl_loot and likely should be moved to the loot API.

## vl_structures.spawn_mobs(mob,spawnon,p1,p2,pr,n,water)

This function spawns the desired mobs in the given area. The function should move to the mobs API.

## vl_structures.register_structure_spawn(def)

This function creates a spawn ABM for the desired mobs. The function should move to the mobs API.

