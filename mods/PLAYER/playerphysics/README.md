# Player Physics API.

This mod simplifies the setting of player physics (speed, jumping height, gravity).

The problem with `set_physics_override` is that is sets a raw value.
As soon as two independent mods want to mess with player physics, this is a problem.

This has a different approach in that you add and remove an arbitrary number of factors for each attribute.
The actual player attribute will be the product of all factors which have been added.

## Preconditions
There is only one precondition to using this mod, but it is important:
Mods *MUST NOT* call `set_physics_override` directly! Instead, to modify player physics, use this API.

## Functions
### `playerphysics.add_physics_factor(player, physic, id, value)`
Adds a factor for a player physic and updates the player physics immeiately.

#### Parameters
* `player`: Player object
* `physic`: Type of player physic to change. Any of the numeric values of `set_physics_override` (e.g. `speed`, `jump`, `gravity`)
* `id`: Unique identifier for this factor. Identifiers are stored on a per-player per-physics type basis
* `value`: The factor to add to the list of products

### `playerphysics.remove_physics_factor(player, physic, id)`
Removes the physics factor of the given ID and updates the player's physics.

#### Parameters
* `player`: Player object
* `physic`: Type of player physic to change. Any of the numeric values of `set_physics_override` (e.g. `speed`, `jump`, `gravity`)
* `id`: Unique identifier for the factor to remove

## Examples
### Speed changes
Let's assume this mod is used by multiple different mods all trying to change the speed.
Here's what it could look like:

Potions mod:
```
playerphysics.add_physics_factor(player, "speed", "run_potion", 2)
```

Exhaustion mod:
```
playerphysics.add_physics_factor(player, "jump", "exhausted", 0.75)
```

Electrocution mod:
```
playerphysics.add_physics_factor(player, "jump", "shocked", 0.9)
```

When the 3 mods have done their change, the real player speed is simply the product of all factors, that is:

2 * 0.75 * 0.9 = 1.35

The final player speed is thus 135%.

### Speed changes, part 2

Let's take the example above.
Now if the Electrocution mod is done with shocking the player, it just needs to call:

```
playerphysics.remove_physics_factor(player, "jump", "shocked")
```

The effect is now gone, so the new player speed will be:

2 * 0.75 = 1.5

### Sleeping
To simulate sleeping by preventing all player movement, this can be done with this easy trick:

```
playerphysics.add_physics_factor(player, "speed", "sleeping", 0)
playerphysics.add_physics_factor(player, "jump", "sleeping", 0)
```

This works regardless of the other factors because mathematics tell us that the factor 0 forces the product to be 0.
