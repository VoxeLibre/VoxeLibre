# Table of Contents
1. [Useful Constants](#useful-constants)
2. [Rail](#rail)
   1. [Constants](#constants)
   2. [Functions](#functions)
   3. [Node Definition Options](#node-definition-options)
3. [Cart Functions](#cart-functions)
4. [Cart Data Functions](#cart-data-functions)
5. [Cart-Node Interactions](#cart-node-interactions)
6. [Train Functions](#train-functions)

## Useful Constants

- `mcl_minecarts.north`
- `mcl_minecarts.south`
- `mcl_minecarts.east`
- `mcl_minecarts.west`

Human-readable names for the cardinal directions.

- `mcl_minecarts.SPEED_MAX`

Maximum speed that minecarts will be accelerated to with powered rails, in blocks per
second. Defined as 10 blocks/second.

- `mcl_minecarts.CART_BLOCKS_SIZE`

The size of blocks to use when searching for carts to respawn. Defined as is 64 blocks.

- `mcl_minecarts.FRICTION`

Rail friction. Defined as is 0.4 blocks/second^2.

- `mcl_minecarts.MAX_TRAIN_LENGTH`

The maximum number of carts that can be in a single train. Defined as 4 carts.

- `mcl_minecarts.PASSENGER_ATTACH_POSITION`

Where to attach passengers to the minecarts.

## Rail

### Constants

`mcl_minecarts.HORIZONTAL_CURVES_RULES`
`mcl_minecarts.HORIZONTAL_STANDARD_RULES`

Rail connection rules. Each rule is a table with the following indexes:

1. `node_name_suffix` - The suffix added to a node's `_mcl_minecarts.base_name` to
   get the name of the node to use for this connection.
2. `param2_value` - The value of the node's param2. Used to specify rotation.

and the following named options:

- `mask` - Directional connections mask
- `score` - priority of the rule. If more than one rule matches, the one with the
  highest store is selected.
- `can_slope` - true if the result of this rule can be converted into a slope.

`mcl_minecarts.RAIL_GROUPS.STANDARD`
`mcl_minecarts.RAIL_GROUPS.CURVES`

These constants are used to specify a rail node's `group.rail` value.

### Functions

`mcl_minecarts.get_rail_connections(node_position, options)`

Calculate the rail adjacency information for rail placement. Arguments are:

- `node_position` - the location of the node to calculate adjacency for.
- `options` - A table containing any of these options:
  - `legacy`- if true, don't check that a connection proceeds out in a direction
    a cart can travel. Used for converting legacy rail to newer equivalents.
  - `ignore_neightbor_connections` - if true, don't check that a cart could leave
    the neighboring node from this direction.

`mcl_minecarts.is_rail(position, railtype)`

Determines if the node at `position` is a rail. If `railtype` is provided,
determine if the node at `position` is that type of rail.

`mcl_minecarts.register_rail(itemstring, node_definition)`

Registers a rail with a few sensible defaults and if a craft recipe was specified,
register that as well.

`mcl_minecarts.register_straight_rail(base_name, tiles, node_definition)`

Registers a rail with only straight and sloped variants.

`mcl_minecarts.register_curves_rail(base_name, tiles, node_definition)`

Registers a rail with straight, sloped, curved, tee and cross variants.

`mcl_minecarts.update_rail_connections(node_position, options)`

Converts the rail at `node_position`, if possible, another variant (curve, etc.)
and rotates the node as needed so that rails connect together. `options` is
passed thru to `mcl_minecarts.get_rail_connections()`

`mcl_minecarts.get_rail_direction(rail_position, cart_direction)`

Returns the next direction a cart traveling in the direction specified in `cart_direction`
will travel from the rail located at `rail_position`.

### Node Definition Options

`_mcl_minecarts.railtype`

This declares the variant type of the rail. This will be one of the following:

- "straight" - two connections opposite each other and no vertical change.
- "sloped" - two connections opposite each other with one of these connections
   one block higher.
- "corner" - two connections at 90 degrees from each other.
- "tee" - three connections
- "cross" - four connections allowing only straight-thru movement

#### Hooks
`_mcl_minecarts.get_next_dir = function(node_position, current_direction, node)`

Called to get the next direction a cart will travel after passing thru this node.

## Cart Functions

`mcl_minecarts.attach_driver(cart, player)`

This attaches (ObjectRef) `player` to the (LuaEntity) `cart`.

`mcl_minecarts.detach_minecart(cart_data)`

This detaches a minecart from any rail it is attached to and makes it start moving
as an entity affected by gravity. It will keep moving in the same direction and
at the same speed it was moving at before it detaches.

`mcl_minecarts.get_cart_position(cart_data)`

Compute the location of a minecart from its cart data. This works even when the entity
is unloaded.

`mcl_minecarts.kill_cart(cart_data)`

Kills a cart and drops it as an item, even if the cart entity is unloaded.

`mcl_minecarts.place_minecart(itemstack, pointed_thing, placer)`

Places a minecart at the location specified by `pointed_thing`

`mcl_minecarts.register_minecart(minecart_definition)`

Registers a minecart. `minecart_definition` defines the entity. All the options supported by
normal minetest entities are supported, with a few additions:

- `craft` - Crafting recipe for this cart.
- `drop` - List of items to drop when the cart is killed. (required)
- `entity_id` - The entity id of the cart. (required)
- `itemstring` - This is the itemstring to use for this entity. (required)

`mcl_minecarts.reverse_cart_direction(cart_data)`

Force a minecart to start moving in the opposite direction of its current direction.

`mcl_minecarts.snap_direction(direction_vector)`

Returns a valid cart movement direction that has the smallest angle between it and `direction_vector`.

`mcl_minecarts.update_cart_orientation(cart)`

Updates the rotation of a cart entity to match the cart's data.

## Cart Data Functions

`mcl_minecarts.destroy_cart_data(uuid)`

Destroys the data for the cart with the identitfier in `uuid`.

`mcl_minecarts.find_carts_by_block_map(block_map)`

Returns a list of cart data for carts located in the blocks specified in `block_map`. Used
to respawn carts entering areas around players.

`mcl_minecarts.add_blocks_to_map(block_map, min_pos, max_pos)`

Add blocks that fully contain `min_pos` and `max_pos` to `block_map` for use by
 `mcl_minecarts.find_cart_by_block_map`.

`mcl_minecarts.get_cart_data(uuid)`

Loads the data for the cart with the identitfier in `uuid`.

`mcl_minecarts.save_cart_data(uuid)`

Saves the data for the cart with the identifier in `uuid`.

`mcl_minecart.update_cart_data(data)`

Replaces the cart data for the cart with the identifier in `data.uuid`, then saves
the data.

## Cart-Node Interactions

As the cart moves thru the environment, it can interact with the surrounding blocks
thru a number of handlers in the block definitions. All these handlers are defined
as:

`function(node_position, cart_luaentity, cart_direction, cart_position)`

Arguments:
- `node_position` - position of the node the cart is interacting with
- `cart_luaentity` - The luaentity of the cart that is entering this block. Will
   be nil for minecarts moving thru unloaded blocks
- `cart_direction` - The direction the cart is moving
- `cart_position` - The location of the cart
- `cart_data` - Information about the cart. This will always be defined.

There are several variants of this handler:
- `_mcl_minecarts_on_enter` - The cart enters this block
- `_mcl_minecarts_on_enter_below` - The cart enters above this block
- `_mcl_minecarts_on_enter_above` - The cart enters below this block
-  `_mcl_minecarts_on_enter_side` - The cart enters beside this block

Mods can also define global handlers that are called for every node. These
handlers are defined as:

`function(node_position, cart_luaentity, cart_direction, node_definition, cart_data)`

Arguments:
- `node_position` - position of the node the cart is interacting with
- `cart_luaentity` - The luaentity of the cart that is entering this block. Will
   be nil for minecarts moving thru unloaded blocks
- `cart_direction` - The direction the cart is moving
- `cart_position` - The location of the cart
- `cart_data` - Information about the cart. This will always be defined.
- `node_definition` - The definition of the node at `node_position`

The available hooks are:
- `_mcl_minecarts.on_enter` - The cart enters this block
- `_mcl_minecarts.on_enter_below` - The cart enters above this block
- `_mcl_minecarts.on_enter_above` - The cart enters below this block
- `_mcl_minecarts.on_enter_side` - The cart enters beside this block

Only a single function can be installed in each of these handlers. Before installing,
preserve the existing handler and call it from inside your handler if not `nil`.

## Train Functions

`mcl_minecarts.break_train_at(cart_data)`

Splits a train apart at the specified cart.

`mcl_minecarts.distance_between_cars(cart1_data, cart2_data)`

Returns the distance between two carts even if both entities are unloaded, or nil if either
cart is not on a rail.

`mcl_minecarts.is_in_same_train(cart1_data, cart2_data)`

Returns true if cart1 and cart2 are a part of the same train and false otherwise.

`mcl_minecarts.link_cart_ahead(cart_data, cart_ahead_data)`

Given two carts, link them together into a train, with the second cart ahead of the first.

`mcl_minecarts.train_cars(cart_data)`

Use to iterate over all carts in a train. Expected usage:

`for cart in mcl_minecarts.train_cars(cart) do --[[ code ]] end`

`mcl_minecarts.reverse_train(cart)`

Make all carts in a train reverse and start moving in the opposite direction.

`mcl_minecarts.train_length(cart_data)`

Compute the current length of the train containing the cart whose data is `cart_data`.

`mcl_minecarts.update_train(cart_data)`

When provided with the rear-most cart of a tain, update speeds of all carts in the train
so that it holds together and moves as a unit.
