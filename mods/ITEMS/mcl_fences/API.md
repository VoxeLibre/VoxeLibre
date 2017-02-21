# API for adding MineClone 2 fences
This API allows you to add fences and fence gates.
The recommended function is `mcl_fences.register_fence_and_fence_gate`.

## ` mcl_fences.register_fence = function(id, fence_name, texture, fence_image, groups, connects_to, sounds)`
Adds a fence without crafting recipe. A single node is created.

### Parameter
* `id`: A part of the itemstring of the node to create. The node name will be “`<modname>:<id>`”
* `fence_name`: User-visible name (`description`)
* `texture`: Texture to apply on the fence (all sides)
* `fence_image`: Inventory image
* `groups`: Table of groups to which the fence belongs to
* `connects_to`: Table of nodes (itemstrings) to which the fence will connect to. Use `group:<groupname>` for all members of the group `<groupname>`
* `sounds`: Node sound table for the fence

### Return value
The full itemstring of the new fence node.

Notes: Fences will always have the group `fence=1`. They will always connect to solid nodes (group `solid=1`).

## `mcl_fences.register_fence_gate = function(id, fence_gate_name, texture, gate_image, groups, connects_to, sounds)`
Adds a fence gate without crafting recipe. This will create 2 nodes.

### Parameters
* `id`: A part of the itemstring of the nodes to create. The node names will be “`<modname>:<id>_gate`” and “`<modname>:<id>_gate_open`”
* `fence_gate_name`: User-visible name (`description`)
* `texture`: Texture to apply on the fence gate (all sides)
* `gate_image`: Inventory image
* `groups`: Table of groups to which the fence gate belongs to
* `connects_to`: Table of nodes (itemstrings) to which the fence will connect to. Use `group:<groupname>` for all members of the group `<groupname>`
* `sounds`: Node sound table for the fence gate

Notes: Fence gates will always have the group `fence_gate=1`. The open fence gate will always have the group `not_in_creative_inventory=1`.

### Return value
This function returns 2 values, in the following order:

1. Itemstring of the closed fence gate
2. Itemstring of the open fence gate

## `mcl_fences.register_fence_and_fence_gate = function(id, fence_name, fence_gate_name, texture, fence_image, gate_image, groups, connects_to, sounds)`
Registers a fence and fence gate. This is basically a combination of the two functions above. This is the recommended way to add a fence / fence gate pair.
This will register 3 nodes in total without crafting recipes.

* `id`: A part of the itemstring of the nodes to create.
* `fence_name`: User-visible name (`description`) of the fence
* `fence_gate_name`: User-visible name (`description`) of the fence gate
* `texture`: Texture to apply on the fence and fence gate (all sides)
* `fence_image`: Inventory image of the fence
* `gate_image`: Inventory image of the fence gate
* `groups`: Table of groups to which the fence and fence gate belong to
* `connects_to`: Table of nodes (itemstrings) to which the fence and fence gate will connect to. Use `group:<groupname>` for all members of the group `<groupname>`
* `sounds`: Node sound table for the fence and the fence gate

### Return value
This function returns 3 values, in this order:

1. Itemstring of the fence
2. Itemstring of the closed fence gate
3. Itemstring of the open fence gate

