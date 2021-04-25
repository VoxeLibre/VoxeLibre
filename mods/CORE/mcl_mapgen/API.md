# mcl_mapgen
============
This mod helps to avoid problems caused by Minetest's 'chunk-in-shell' feature of mapgen.cpp.
It also queues your generators to run them in proper order.


=========================================================================
## mcl_mapgen.register_chunk_generator(chunk_callback_function, priority)
=========================================================================
UNSAFE! See below. Registers callback function to be called when current chunk generation is finished.
	`callback_function`: chunk callback function definition, see below;
	`priority`: order number - the less, the earlier.
### Chunk callback function definition:
	`function(minp, maxp, seed)`:
		`minp` & `maxp`: minimum and maximum chunk position;
		`seed`: seed of this mapchunk.


=======================================================================
## mcl_mapgen.register_chunk_generator_lvm(callback_function, priority)
=======================================================================
UNSAFE! See below. Registers callback function to be called when current chunk generation is finished.
`vm_context` passes into callback function and should be returned back.
	`callback_function`: chunk callback LVM function definition, see below;
	`priority`: order number - the less, the earlier.
### Chunk callback LVM function definition:
	Function MUST RETURN `vm_context`. It passes into next callback function from the queue.
	`function(vm_context)`:
		`vm_context` is a table which already contains some LVM data and some of them can be added in callback function:
			`minp` & `maxp`: minimum and maximum chunk position;
			`seed`: seed of this mapchunk.


===================================================================
## mcl_mapgen.register_block_generator(callback_function, priority)
===================================================================
Registers callback function to be called when block (usually 16x16x16 nodes) generation is finished.
	`callback_function`: block callback function definition, see below;
	`priority`: order number - the less, the earlier.


=======================================================================
## mcl_mapgen.register_block_generator_lvm(callback_function, priority)
=======================================================================
Registers callback function to be called when block (usually 16x16x16 nodes) generation is finished.
`vm_context` passes into callback function and should be returned back.
	`callback_function`: block callback LVM function definition, see below;
	`priority`: order number - the less, the earlier.


===============================
## mcl_mapgen.get_far_node(pos)
===============================
Returns node if it is generated. Otherwise returns `{name = "ignore"}`.
