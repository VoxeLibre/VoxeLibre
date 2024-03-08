### FOV API

<!-- TOC -->
* [FOV API](#fov-api)
    * [Description](#description)
    * [Troubleshooting](#troubleshooting)
    * [Modifier Definition](#modifier-definition-)
    * [Global MCL_FOVAPI Tables](#global-mclfovapi-tables)
    * [Namespaces](#namespaces)
    * [Functions](#functions)
<!-- TOC -->

#### Description
This API defines and applies different Field Of View effects to players via MODIFIERS.

#### Troubleshooting
In the `init.lua` file for this module, there is a `DEBUG` variable at the top that will turn on logging. 
Use it to see what is going on.

#### Modifier Definition 
```lua 
def = {
    name = name,
    fov_factor = fov_factor,
    time = time,
    reset_time = reset_time,
    is_multiplier = is_multiplier,
    exclusive = exclusive,
    on_start = on_start,
    on_end = on_end,
}
```
* Name: The name of the Modifier, used to identify the specific modifier. Case sensitive.
* FOV Factor: A float value defining the FOV to apply. Can be an absolute or percentage, depending on Exclusive and 
    Is_Multiplier.
* Time: A float value defining the number of seconds to take when applying the FOV Factor. 
    Used to smoothly move between FOVs. Use 0 for an immediate FOV Shift. (Transition time.)
* Reset Time: A float value defining the number of seconds to take when removing the FOV Factor.
    Used to smoothly move between FOVs. Use 0 for an immediate FOV Shift. (Reset transition time.)
    Defaults to `time` if not defined.
* Is Multiplier: A bool value used to specify if the FOV Factor is an absolute FOV value or if it should be a percentage 
    of the current FOV. Defaults to `true` if not defined.
* Exclusive: A bool value used to specify whether the modifier will override all other FOV modifiers. An example of this 
    is how the spy glass sets the FOV to be a specific value regardless of any other FOV effects applied. Defaults to 
    `false` if not defined. 
* On Start: the `on_start` is a callback function `on_start(player)` that is called if defined. The parameter `player` 
    is a ref to the player that had the modifier applied. Called from `mcl_fovapi.apply_modifier` immediately after 
    the FOV Modifier has been applied.
* On End: the `on_end` is a callback function `on_end(player)` that is called if defined. The parameter `player`
  is a ref to the player that had the modifier applied. Called from `mcl_fovapi.remove_modifier` immediately after
  the FOV Modifier has been removed.

Note: passing incorrect values in the definition will have unintended consequences.

#### Global MCL_FOVAPI Tables
There are three tables that are accessible via the API. They are `registered_modifiers` and `applied_modifiers`.  

`mcl_fovapi.registered_modifiers` has the definitions of all the registered FOV Modifiers. Indexed by Modifier Name. 
And, `mcl_fovapi.applied_modifiers` is indexed by the Player Name. It contains the names of all the modifiers applied to the 
player.

#### Namespaces
`mcl_fovapi` is the default API Namespace.

#### Functions
`mcl_fovapi.register_modifier(def)`

Used to register a new FOV Modifier for use. Must be called before applying said modifier to a player.
See Modifier Definition for what the parameters are.

`mcl_fovapi.apply_modifier(player, modifier_name)`

Used to apply a registered FOV modifier to a player. Takes a reference to the player and the modifier's name (string).

`mcl_fovapi.remove_modifier(player, modifier_name)`

Used to remove a specific FOV modifier from a Player. Takes a reference to the player and the modifier's name (string).
Removed immediately.

`mcl_fovapi.remove_all_modifiers(player)`

Used to remove all FOV modifiers from a Player. Takes a reference to the Player. FOV change is instantaneous.
