
## On-rail Minecart Movement

Minecart movement is handled in two distinct regimes: on a rail and off. The
off-rail movement is handled with minetest's builtin entity movement handling.
The on-rail movement is handled with a custom algorithm. This section details
the latter.

The data for on-rail minecart movement is stored entirely inside mod storage
and indexed by a hex-encoded 128-bit universally-unique identifier (uuid). The
code for handling this storage is in [storage.lua](./storage.lua). This was
done so that minecarts can still move while no players are connected or
when out of range of players. Inspiration for this was the [Adv Trains mod](http://advtrains.de/).
This is a behavior difference when compared to minecraft, as carts there will
stop movement when out of range of players.

Processing for minecart movement is as follows:
1. In a globalstep handler, determine which carts are moving.
2. Call `do_movement` in [movement.lua](./movement.lua) to update
   the cart's location and handle interactions with the environment.
   1. Each movement is broken up into one or more steps that are completely
      contained inside a block. This prevents carts from ever jumping from
      one rail to another over a gap or thru solid blocks because of server
      lag.
   2. Each step uses physically accurate, timestep-independent physics
      to move the cart.
   3. As the cart enters and leaves blocks, handlers in nearby blocks are called
      to allow the cart to efficiently interact with the environment.
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
