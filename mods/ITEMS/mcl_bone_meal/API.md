
# Bone meal API
Bonemealing callbacks and particle functions.


## _mcl_on_bonemealing(pointed_thing, placer)
The bone meal API provides a callback definition that nodes can use to
register a handler that is executed when a bone meal item is used on it.

Nodes that wish to use the bone meal API should in their node registration
define a callback handler named `_mcl_on_bonemealing`.  This handler is a

  `function(pointed_thing, placer)`

Its arguments are:
* `pointed_thing`: exact pointing location (see Minetest API), where the
	bone meal is applied
* `placer`: ObjectRef of the player who aplied the bone meal, can be nil!

The function should return `true` if the bonemealing was succesful.

It is for all intents and purposes up to the callback defined in the node to
decide how to handle the effect that bone meal has on that particular node.

The `on_place` code in the bone meal item will spawn bone meal particles and
decrease the bone meal itemstack if the handler returned `true` and the
`placer` is not in creative mode.


## mcl_bone_meal.add_bone_meal_particle(pos, def)
Spawns standard or custom bone meal particles.
* `pos`: position, is ignored if you define def.minpos and def.maxpos
* `def`: (optional) particle definition; see minetest.add_particlespawner()
	for more details.


# Legacy API
The bone meal API also provides a legacy compatibility function.  This
function is not meant to be continued and callers should migrate to the
newer bonemealing API.

## mcl_bone_meal.register_on_bone_meal_apply(function(pointed_thing, placer))
Called when the bone meal is applied anywhere.
* `pointed_thing`: exact pointing location (see Minetest API), where the
	bone meal is applied
* `placer`: ObjectRef of the player who aplied the bone meal, can be nil!
This function is deprecated and will be removed at some time in the future.

## mcl_dye.add_bone_meal_particle(pos, def)
## mcl_dye.register_on_bone_meal_apply(function(pointed_thing, user))
These shims in mcl_dye that point to corresponding legacy compatibility
functions in mcl_bone_meal remain for legacy callers that have not yet been
updated to the new API.  These shims will be removed at some time in the
future.
