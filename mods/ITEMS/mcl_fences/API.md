# API for adding MineClone 2 fences
This API allows you to add fences and fence gates.
The recommended function is `mcl_fences.register_fence_and_fence_gate`.

## ` mcl_fences.register_fence = function(id, fence_name, texture, groups, connects_to, sounds)`
Adds a fence without crafting recipe. A single node is created.

### Parameter
* `id`: A part of the itemstring of the node to create. The node name will be “`<modname>:<id>`”
* `fence_name`: User-visible name (`description`)
* `texture`: Texture to apply on the fence (all sides)
* `groups`: Table of groups to which the fence belongs to
* `connects_to`: Table of nodes (itemstrings) to which the fence will connect to. Use `group:<groupname>` for all members of the group `<groupname>`
* `sounds`: Node sound table for the fence

### Return value
The full itemstring of the new fence node.

Notes: Fences will always have the group `fence=1`. They will always connect to solid nodes (group `solid=1`).

## `mcl_fences.register_fence_gate = function(id, fence_gate_name, texture, groups, sounds, sound_open, sound_close)`
Adds a fence gate without crafting recipe. This will create 2 nodes.

### Parameters
* `id`: A part of the itemstring of the nodes to create. The node names will be “`<modname>:<id>_gate`” and “`<modname>:<id>_gate_open`”
* `fence_gate_name`: User-visible name (`description`)
* `texture`: Texture to apply on the fence gate (all sides)
* `groups`: Table of groups to which the fence gate belongs to
* `sounds`: Node sound table for the fence gate
* `sound_open`: Sound to play when opening fence gate (optional, default is wooden sound)
* `sound_close`: Sound to play when closing fence gate (optional, default is wooden sound)

Notes: Fence gates will always have the group `fence_gate=1`. The open fence gate will always have the group `not_in_creative_inventory=1`.

### Return value
This function returns 2 values, in the following order:

1. Itemstring of the closed fence gate
2. Itemstring of the open fence gate

## `mcl_fences.register_fence_and_fence_gate = function(id, fence_name, fence_gate_name, texture, groups, connects_to, sounds, sound_open, sound_close)`
Registers a fence and fence gate. This is basically a combination of the two functions above. This is the recommended way to add a fence / fence gate pair.
This will register 3 nodes in total without crafting recipes.

* `id`: A part of the itemstring of the nodes to create.
* `fence_name`: User-visible name (`description`) of the fence
* `fence_gate_name`: User-visible name (`description`) of the fence gate
* `texture`: Texture to apply on the fence and fence gate (all sides)
* `groups`: Table of groups to which the fence and fence gate belong to
* `connects_to`: Table of nodes (itemstrings) to which the fence will connect to. Use `group:<groupname>` for all members of the group `<groupname>`
* `sounds`: Node sound table for the fence and the fence gate
* `sound_open`: Sound to play when opening fence gate (optional, default is wooden sound)
* `sound_close`: Sound to play when closing fence gate (optional, default is wooden sound)

### Return value
This function returns 3 values, in this order:

1. Itemstring of the fence
2. Itemstring of the closed fence gate
3. Itemstring of the open fence gate

