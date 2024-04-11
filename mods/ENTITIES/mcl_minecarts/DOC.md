
## Organization
- [ init.lua](./init.lua) - module entrypoint. The other files are included from here
  and several constants are defined here

- [carts.lua](./carts/lua) - This file contains code related to cart entities, cart
  type registration,  creation, estruction and updating. The global step function
  responsible for updating attached carts is in this file. The various carts are
  referenced from this file but actually reside in the subdirectory [carts/](./carts/).

- [functions.lua](./functions.lua) - This file contains various minecart and rail
  utility functions used by the rest of the code.

- [movement.lua](./movement.lua) - This file contains the code related to cart
  movement physics.

- [rails.lua](./rails.lua) - This file contains code related to rail registation,
  placement, connection rules and cart direction selection. This contains the rail
  behaviors and the LBM code for updating legacy rail nodes to the new versions
  that don't use the railtype render type.

- [storage.lua](./storage.lua) - This file contains the code than manages minecart
  state data to allow processing minecarts while entities are unloaded.

- [train.lua](./train.lua) - This file contains code related to multi-car trains.

## On-rail Minecart Movement

Minecart movement is handled in two distinct regimes: on a rail and off. The
off-rail movement is handled with minetest's builtin entity movement handling.
The on-rail movement is handled with a custom algorithm. This section details
the latter.

The data for on-rail minecart movement is stored entirely inside mod storage
and indexed by a hex-encoded 128-bit universally-unique identifier (uuid). Minecart
entities store this uuid and a sequence identifier. The code for handling this
storage is in [storage.lua](./storage.lua). This was done so that minecarts can
still move while no players are connected or when out of range of players. Inspiration
for this was the [Advanced Trains mod](http://advtrains.de/). This is a behavior difference
when compared to minecraft, as carts there will stop movement when out of range of
players.

Processing for minecart movement is as follows:
1. In a globalstep handler in [carts.lua](./carts.lua), determine which carts are
   moving.
2. Call `do_movement` in [movement.lua](./movement.lua) to update
   each cart's location and handle interactions with the environment.
   1. Each movement is broken up into one or more steps that are completely
      contained inside a block. This prevents carts from ever jumping from
      one rail to another over a gap or thru solid blocks because of server
      lag. Each step is processed with `do_movement_step`
   2. Each step uses physically accurate, timestep-independent physics
      to move the cart. Calculating the acceleration to apply to a cart
      is broken out into its own function (`calculate_acceperation`).
   3. As the cart enters and leaves blocks, handlers in nearby blocks are called
      to allow the cart to efficiently interact with the environment. Handled by
      the functions `handle_cart_enter` and `handle_cart_leave`
   4. The cart checks for nearby carts and collides elastically with these. The
      calculations for these collisions are in the function `handle_cart_collision`
   5. If the cart enters a new block, determine the new direction the cart will
      move with `mcl_minecarts:get_rail_direction` in [functions.lua](./functions.lua).
      The rail nodes provide a hook `_mcl_minecarts.get_next_direction` that
      provides this information based on the previous movement direction.
3. If an entity exists for a given cart, the entity will update its position
   while loaded in.

Cart movement when on a rail occurs regarless of whether an entity for that
cart exists or is loaded into memory. As a consequence of this movement, it
is possible for carts with unloaded entities to enter range of a player.
To handle this, periodic checks are performed around players and carts that
are within range but don't have a cart have a new entity spawned.

Every time a cart has a new entity spawned, it increases a sequence number in
the cart data to allow removing old entities from the minetest engine. Any cart
entity that does not have the current sequence number for a minecart gets removed
once processing for that entity resumes.

