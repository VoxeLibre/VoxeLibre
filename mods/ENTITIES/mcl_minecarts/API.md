# Table of Contents
1. Useful Constants
2. Rail
3. [Cart functions](#cart-functions)
4. [Cart-Node Interactions](#cart-node-iteractions)

## Useful Constants

`mcl_minecarts.north`
`mcl_minecarts.south`
`mcl_minecarts.east`
`mcl_minecarts.west`

Human-readable names for the cardinal directions.

## Rail

### Constants

`mcl_minecarts.HORIZONTAL_CURVES_RULES`
`mcl_minecarts.HORIZONTAL_STANDARD_RULES`

Rail connection rules. Each rule is an table with the following indexes:

1. `node_name_suffix` - The suffix added to a node's `_mcl_minecarts.base_name` to
   get the name of the node to use for this connection.
2. `param2_value` - The value of the node's param2. Used to specify rotation.

and the following named options:

- `mask` - Directional connections mask
- `score` - priority of the rule. If more than one rule matches, the one with the
  highest store is selected.
- `can_slope` - true if the result of this rule can be converted into a slope.

### Functions

`mcl_minecarts.get_rail_connections(node_position, options)`

Calculate the rail adjacency information for rail placement. Arguments are:

- `node_position` - the location of the node to calculate adjacency for.
- `options` - A table containing any of these options:
  - `legacy`- if true, don't check that a connection proceeds out in a direction
    a cart can travel. Used for converting legacy rail to newer equivalents.
  - `ignore_neightbor_connections` - if true, don't check that a cart could leave
    the neighboring node from this direction.

`mcl_minecarts.update_rail_connections(node_position, options)`

Converts the rail at `node_position`, if possible, another variant (curve, etc.)
and rotates the node as needed so that rails connect together. `options` is
passed thru to `mcl_minecarts.get_rail_connections()`

`mcl_minecarts:get_rail_direction(rail_position, cart_direction)`

Returns the next direction a cart traveling in the direction specified in `cart_direction`
will travel from the rail located at `rail_position`.

## Cart functions <a name='#cart-functions'></a>

`mcl_minecarts.detach_minecart(cart_data)`

This detaches a minecart from any rail it is attached to and makes it start moving
as an entity affected by gravity. It will keep moving in the same direction and
at the same speed it was moving at before it detaches.

`mcl_minecarts.get_cart_position(cart_data)`

Compute the location of a minecart from its cart data. This works even when the entity
is unloaded.

`mcl_minecarts.reverse_cart_direction(cart_data)`

Force a minecart to start moving in the opposite direction of its current direction.

`mcl_minecarts.snap_direction(direction_vector)`

Returns a valid cart movement direction that has the smallest angle between it and `direction_vector`.

`mcl_minecarts:update_cart_orientation(cart)`

Updates the rotation of a cart entity to match the cart's data.

## Cart-Node interactions

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
