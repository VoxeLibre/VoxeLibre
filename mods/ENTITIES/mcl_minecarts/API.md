== Cart-Node interactions

As the cart moves thru the environment, it can interact with the surrounding blocks
thru a number of handlers in the block definitions. All these handlers are defined
as:

`function(node_position, cart_luaentity, cart_direction, cart_position)`

Arguments:
`node_position` - position of the node the cart is interacting with
`cart_luaentity` - The luaentity of the cart that is entering this block. Will
   be nil for minecarts moving thru unloaded blocks
`cart_direction` - The direction the cart is moving
`cart_position` - The location of the cart
`cart_data` - Information about the cart. This will always be defined.

There are several variants of this handler:
`_mcl_minecarts_on_enter` - The cart enters this block
`_mcl_minecarts_on_enter_below` - The cart enters above this block
`_mcl_minecarts_on_enter_above` - The cart enters below this block
`_mcl_minecarts_on_enter_side` - The cart enters beside this block

Mods can also define global handlers that are called for every node. These
handlers are defined as:

`function(node_position, cart_luaentity, cart_direction, node_definition, cart_data)`

Arguments:
`node_position` - position of the node the cart is interacting with
`cart_luaentity` - The luaentity of the cart that is entering this block. Will
   be nil for minecarts moving thru unloaded blocks
`cart_direction` - The direction the cart is moving
`cart_position` - The location of the cart
`cart_data` - Information about the cart. This will always be defined.
`node_definition` - The definition of the node at `node_position`

The available hooks are:
`_mcl_minecarts.on_enter` - The cart enters this block
`_mcl_minecarts.on_enter_below` - The cart enters above this block
`_mcl_minecarts.on_enter_above` - The cart enters below this block
`_mcl_minecarts.on_enter_side` - The cart enters beside this block

Only a single function can be installed in each of these handlers. Before installing,
preserve the existing handler and call it from inside your handler if not `nil`.
