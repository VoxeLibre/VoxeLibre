# mcl_dye

# Bone meal API
Callback and particle functions.

## mcl_dye.add_bone_meal_particle(pos, def)
Spawns standard or custom bone meal particles.
* `pos`: position, is ignored if you define def.minpos and def.maxpos
* `def`: (optional) particle definition

## mcl_dye.register_on_bone_meal_apply(function(pointed_thing, user))
Called when the bone meal is applied anywhere.
* `pointed_thing`: exact pointing location (see Minetest API), where the bone meal is applied
* `user`: ObjectRef of the player who aplied the bone meal, can be nil!