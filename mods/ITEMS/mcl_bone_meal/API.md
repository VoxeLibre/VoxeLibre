
# Bone meal API
Bonemealing callbacks and particle functions.


## _on_bone_meal(itemstack, placer, pointed_thing)
The bone meal API provides a callback definition that nodes can use to
register a handler that is executed when a bone meal item is used on it.

Nodes that wish to use the bone meal API should in their node registration
define a callback handler named `_on_bone_meal`.

Note that by registering the callback handler, the node declares that bone
meal can be used on it and as a result, when the user is not in creative
mode, the used bone meal is spent and taken from the itemstack passed to
the `on_place()` handler of the bone meal item used regardless of whether
the bone meal had an effect on the node and regardless of the result of
the callback handler.

It is for all intents and purposes up to the callback defined in the node to
decide how to handle the specific effect that bone meal has on that node.

The `_on_bone_meal` callback handler is a

  `function(itemstack, placer, pointed_thing)`

Its arguments are:
* `itemstack`: the stack of bonem eal being applied
* `placer`: ObjectRef of the player who aplied the bone meal, can be nil!
* `pointed_thing`: exact pointing location (see Luanti API), where the
	bone meal is applied

The return value of the handler function indicates if the bonemealing had
its intended effect.  If `true`, 'bone meal particles' are spawned at the
position of the bonemealed node.

The `on_place` code in the bone meal item will spawn bone meal particles and
decrease the bone meal itemstack if the handler returned `true` and the
`placer` is not in creative mode.


## mcl_bone_meal.add_bone_meal_particle(pos, def)
Spawns standard or custom bone meal particles.
* `pos`: position, is ignored if you define def.minpos and def.maxpos
* `def`: (optional) particle definition; see minetest.add_particlespawner()
	for more details.

## mcl_bone_meal.use_bone_meal(itemstack, placer, pointed_thing)
For use in on_rightclick handlers that need support bone meal processing in addition
to other behaviors. Before calling, verify that the player is wielding bone meal.
* `itemstack`: The stack of bone meal being used
* `placer`: ObjectRef of the player who aplied the bone meal, can be nil!
* `pointed_thing`: exact pointing location (see Luanti API), where the
	bone meal is applied

Returns itemstack with one bone meal consumed if not in creative mode.

# Legacy API
The bone meal API also provides a legacy compatibility function.  This
function is not meant to be continued and callers should migrate to the
newer bonemealing API.

## mcl_bone_meal.register_on_bone_meal_apply(function(pointed_thing, placer))
Called when the bone meal is applied anywhere.
* `pointed_thing`: exact pointing location (see Luanti API), where the
	bone meal is applied
* `placer`: ObjectRef of the player who aplied the bone meal, can be nil!
This function is deprecated and will be removed at some time in the future.
Bone meal is not consumed unless the provided function returns true.

## mcl_dye.add_bone_meal_particle(pos, def)
## mcl_dye.register_on_bone_meal_apply(function(pointed_thing, user))
These shims in mcl_dye that point to corresponding legacy compatibility
functions in mcl_bone_meal remain for legacy callers that have not yet been
updated to the new API.  These shims will be removed at some time in the
future.
