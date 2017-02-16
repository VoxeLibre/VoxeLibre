# API information (WIP)
This API information is WIP. The mod API is still pretty much unofficial;
this mod is mostly seen as standalone for now.
This may change in the future development of MineClone 2. Hopefully.

## Groups
Items in group `food=3` will make a drinking sound and no particles.
Items in group `food` with any other rating will make an eating sound and particles,
based on the inventory image or wield image (whatever is available first).

## Suppressing food particles
Normally, all food items considered food (not drinks) make food particles.
You can suppress the food particles by adding the field
`_food_particles=false` to the item definition.
