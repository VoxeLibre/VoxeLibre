# mcl_mapgen
============
Helps to avoid problems caused by 'chunk-in-shell' feature of mapgen.cpp.
It also queues your generators to run them in proper order:

## mcl_mapgen.register_chunk_generator(chunk_callback_function, priority)
=========================================================================
Registers callback function to be called when current chunk generation is finished.
	`callback_function`: chunk callback function definition:
		`function(minp, maxp, seed)`:
			`minp` & `maxp`: minimum and maximum chunk position;
			`seed`: seed of this mapchunk;
	`priority` (optional): order number - the less, the earlier,
		e.g. `mcl_mapgen.priorities.BUILDINGS` or `mcl_mapgen.priorities.LARGE_BUILDINGS`

## mcl_mapgen.register_block_generator(callback_function, priority)
===================================================================
Registers callback function to be called when block (usually 16x16x16 nodes) generation is finished.
	`callback_function`: block callback function definition, see below;
	`priority` (optional): order number - the less, the earlier,
		e.g. `mcl_mapgen.priorities.BUILDINGS` or `mcl_mapgen.priorities.LARGE_BUILDINGS`

## mcl_mapgen.register_block_generator_lvm(callback_function, priority)
=======================================================================
Registers callback function to be called when block (usually 16x16x16 nodes) generation is finished.
`vm_context` passes into callback function and should be returned back.
	`callback_function`: block callback LVM function definition, see below;
	`priority` (optional): order number - the less, the earlier,
		e.g. `mcl_mapgen.priorities.BUILDINGS` or `mcl_mapgen.priorities.LARGE_BUILDINGS`

## mcl_mapgen.register_chunk_generator_lvm(callback_function, priority)
=======================================================================
UNSAFE! See https://git.minetest.land/MineClone2/MineClone2/issues/1395
Registers callback function to be called when current chunk generation is finished.
IT IS UNSAFE! GROUND CONTENT YOU PLACE (INCLUDING WATER AND AIR) CAN BE OVERWRITTEN BY cavegen.
ALL OTHER API FUNCTIONS ARE SAFE! USE THEM PLEASE! BUT WE NEED THIS FUNCTION STILL SOMETIMES,
WHEN WE NEED TO ACCESS MAPGEN OBJECTS like `heightmap`, `biomemap`, ETC.
	`callback_function`: chunk callback LVM function definition, see below;
		`function(vm_context)`:
			Function MUST RETURN `vm_context` back anyway! It will passed into next callback function from the queue.
			`vm_context`: a table which already contains some LVM data if the fields, and some of them can be added right in callback function:
				`vm`: curent voxel manipulator object itself;
				`blockseed`: seed of this mapchunk;
				`minp` & `maxp`: minimum and maximum chunk position;
				`emin` & `emax`: minimum and maximum chunk position WITH SHELL AROUND IT;
				`area`: voxel area, can be helpful to access data;
				`data`: LVM buffer data array, data loads into it before the callbacks;
				`write`: set it to true in yout callback functionm, if you changed `data` and want to write it;
				`data2`: LVM buffer data array of `param2`, !NO ANY DATA LOADS INTO IT BEFORE THE CALLBACKS! - you load it yourfels:
					`vm_context.data2 = vm_context.data2 or vm_context.vm.get_param2_data(vm_context.lvm_param2_buffer)`
				`write_param2`: set it to true in yout callback functionm, if you used `data2` and want to write it;
				`lvm_param2_buffer`: static `param2` buffer pointer, used to load `data2` array;
				`shadow`: set it to false to disable shadow propagation;
				`heightmap`: mapgen object contanting y coordinates of ground level,
					!NO ANY DATA LOADS INTO IT BEFORE THE CALLBACKS! - you load it yourfels:
					`vm_context.heightmap = vm_context.heightmap or minetest.get_mapgen_object('heightmap')`
				`biomemap`: mapgen object contanting biome IDs of nodes,
					!NO ANY DATA LOADS INTO IT BEFORE THE CALLBACKS! - you load it yourfels:
					`vm_context.biomemap = vm_context.biomemap or minetest.get_mapgen_object('biomemap')`
				`heatmap`: mapgen object contanting temperature values of nodes,
					!NO ANY DATA LOADS INTO IT BEFORE THE CALLBACKS! - you load it yourfels:
					`vm_context.heatmap = vm_context.heatmap or minetest.get_mapgen_object('heatmap')`
				`humiditymap`: mapgen object contanting humidity values of nodes,
					!NO ANY DATA LOADS INTO IT BEFORE THE CALLBACKS! - you load it yourfels:
					`vm_context.humiditymap = vm_context.humiditymap or minetest.get_mapgen_object('humiditymap')`
				`gennotify`: mapgen object contanting mapping table of structures, see Minetest Lua API for explanation,
					!NO ANY DATA LOADS INTO IT BEFORE THE CALLBACKS! - you load it yourfels:
					`vm_context.gennotify = vm_context.gennotify or minetest.get_mapgen_object('gennotify')`
	`priority` (optional): order number - the less, the earlier,
		e.g. `mcl_mapgen.priorities.BUILDINGS` or `mcl_mapgen.priorities.LARGE_BUILDINGS`

## mcl_mapgen.get_far_node(pos)
===============================
Returns node if it is generated. Otherwise returns `{name = "ignore"}`.
