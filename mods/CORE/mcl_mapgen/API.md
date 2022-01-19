# mcl_mapgen
------------
Helps to avoid problems caused by 'chunk-in-shell' feature of mapgen.cpp.

It also queues your generators to run them in proper order:

### mcl_mapgen.register_on_generated(lvm_callback_function, order_number)
-------------------------------------------------------------------------
Replacement of engine API function `minetest.register_on_generated(function(vm_context))`

It is still unsafe. Cavegen part can and will overwrite outer 1-block layer of the chunk which is expected to be generated.

Nodes marked as `is_ground_content` could be overwritten. Air and water are usually 'ground content' too.
For Minetest 5.4 it doesn't recommended to place blocks within lvm callback function.

See https://git.minetest.land/MineClone2/MineClone2/issues/1395

 * `lvm_callback_function`: chunk callback LVM function definition:
    * `function(vm_context)`:
        * `vm_context` will pass into next lvm callback function from the queue!
        * `vm_context`: a table which already contains some LVM data as the fields, and some of them can be added in your lvm callback function:
            * `vm`: curent voxel manipulator object itself;
            * `chunkseed`: seed of this mapchunk;
            * `minp` & `maxp`: minimum and maximum chunk position;
            * `emin` & `emax`: minimum and maximum chunk position WITH SHELL AROUND IT;
            * `area`: voxel area, can be helpful to access data;
            * `data`: LVM buffer data array, data loads into it before the callbacks;
            * `write`: set it to true in your lvm callback functionm, if you changed `data` and want to write it;
            * `param2_data`: LVM buffer data array of `param2`, *NO ANY DATA LOADS INTO IT BEFORE THE CALLBACKS* - you load it yourself:
                * `vm_context.param2_data = vm_context.param2_data or vm_context.vm:get_param2_data(vm_context.lvm_param2_buffer)`
            * `write_param2`: set it to true in your lvm callback function, if you used `param2_data` and want to write it;
            * `light`: LVM buffer data array of light, *NO ANY DATA LOADS INTO IT BEFORE THE CALLBACKS* - you load it yourself:
                * `vm_context.light = vm_context.light or vm_context.vm.get_light_data(vm_context.lvm_light_buffer)`
            * `write_light`: set it to true in your lvm callback function, if you used `light` and want to write it;
            * `lvm_param2_buffer`: static `param2` buffer pointer, used to load `param2_data` array;
            * `shadow`: set it to false to disable shadow propagation;
            * `heightmap`: mapgen object contanting y coordinates of ground level,
                * *NO ANY DATA LOADS INTO IT BEFORE THE CALLBACKS* - load it yourself:
                * `vm_context.heightmap = vm_context.heightmap or minetest.get_mapgen_object('heightmap')`
            * `biomemap`: mapgen object contanting biome IDs of nodes,
                * *NO ANY DATA LOADS INTO IT BEFORE THE CALLBACKS* - load it yourself:
                * `vm_context.biomemap = vm_context.biomemap or minetest.get_mapgen_object('biomemap')`
            * `heatmap`: mapgen object contanting temperature values of nodes,
                * *NO ANY DATA LOADS INTO IT BEFORE THE CALLBACKS* - load it yourself:
                * `vm_context.heatmap = vm_context.heatmap or minetest.get_mapgen_object('heatmap')`
            * `humiditymap`: mapgen object contanting humidity values of nodes,
                * *NO ANY DATA LOADS INTO IT BEFORE THE CALLBACKS* - load it yourself:
                * `vm_context.humiditymap = vm_context.humiditymap or minetest.get_mapgen_object('humiditymap')`
            * `gennotify`: mapgen object contanting mapping table of structures, see Minetest Lua API for explanation,
                * *NO ANY DATA LOADS INTO IT BEFORE THE CALLBACKS* - load it yourself:
                * `vm_context.gennotify = vm_context.gennotify or minetest.get_mapgen_object('gennotify')`
 * `order_number` (optional): the less, the earlier,
    * e.g. `mcl_mapgen.order.BUILDINGS` or `mcl_mapgen.order.LARGE_BUILDINGS`

### mcl_mapgen.register_mapgen_block_lvm(lvm_callback_function, order_number)
-----------------------------------------------------------------------------
Registers lvm callback function to be called when current block (usually 16x16x16 nodes) generation is REALLY 100% finished.

`vm_context` passes into lvm callback function.
 * `lvm_callback_function`: the block callback LVM function definition - same as for chunks - see definition example above;
 * `order_number` (optional): the less, the earlier,
    * e.g. `mcl_mapgen.order.BUILDINGS` or `mcl_mapgen.order.LARGE_BUILDINGS`

### mcl_mapgen.register_mapgen_block(node_callback_function, order_number)
--------------------------------------------------------------------------
Registers node_callback function to be called when current block (usually 16x16x16 nodes) generation is REALLY 100% finished.
 * `node_callback_function`: node callback function definition:
    * `function(minp, maxp, seed)`:
        * `minp` & `maxp`: minimum and maximum block position;
        * `seed`: seed of this mapblock;
 * `order_number` (optional): the less, the earlier,
    * e.g. `mcl_mapgen.order.BUILDINGS` or `mcl_mapgen.order.LARGE_BUILDINGS`

### mcl_mapgen.register_mapgen(callback_function, order_number)
---------------------------------------------------------------
Registers callback function to be called when current chunk generation is REALLY 100% finished.

For LVM it's the most frustrating function from this mod.

It can't provide you access to mapgen objects. They are probably gone long ago.

Don't use it for accessing mapgen objects please.

To use VM you have to run `vm_context.vm = mcl_mapgen.get_voxel_manip(vm_context.emin, vm_context.emax)`.
 * `callback_function`: callback function definition:
    * `function(minp, maxp, seed, vm_context)`:
        * `minp` & `maxp`: minimum and maximum block position;
        * `seed`: seed of this mapblock;
        * `vm_context`: a table - see description above.
 * `order_number` (optional): the less, the earlier.

### mcl_mapgen.register_mapgen_lvm(lvm_callback_function, order_number)
-----------------------------------------------------------------------
Registers lvm callback function to be called when current chunk generation is REALLY 100% finished.

It's the most frustrating function from this mod. It can't provide you access to mapgen objects. They are probably gone long ago.

Don't use it for accessing mapgen objects please.

`vm_context` passes into lvm callback function.
 * `lvm_callback_function`: the block callback LVM function definition - same as above;
 * `order_number` (optional): the less, the earlier.

### mcl_mapgen.get_far_node(pos)
--------------------------------
Returns node if it is generated, otherwise returns `{name = "ignore"}`.

### mcl_mapgen.clamp_to_chunk(x, size)
--------------------------------------
Returns new `x`, slighty tuned to make structure of size `size` be within single chunk side of 80 nodes.

### function mcl_mapgen.get_chunk_beginning(x)
----------------------------------------------
Returns chunk beginning of `x`. It is the same as `minp.axis` for per-chunk callbacks, but we don't always have `minp`.

## Constants:
 * `mcl_mapgen.EDGE_MIN`, `mcl_mapgen.EDGE_MAX` - world edges, min & max.
 * `mcl_mapgen.seed`, `mcl_mapgen.name` - mapgen seed & name.
 * `mcl_mapgen.v6`, `mcl_mapgen.superflat`, `mcl_mapgen.singlenode` - is mapgen v6, superflat, singlenode.
 * `mcl_mapgen.normal` is mapgen normal (not superflat or singlenode).
