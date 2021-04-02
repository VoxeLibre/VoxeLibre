# controls

## controls.players
Table containing player controls at runtime.
WARNING: Never use this table in writing

## controls.register_on_press(func)
Register a function that will be executed with (player, keyname) every time a player press a key.

## controls.registered_on_press
Table containing functions registered with controls.register_on_press().

## controls.register_on_release(func)
Register a function that will be executed with (player, keyname, clock_from_last_press) every time a player release a key.

## controls.registered_on_release
Table containing functions registered with controls.register_on_release().

## controls.register_on_hold(func)
Register a function that will be executed with (player, keyname, clock_from_start_hold) every time a player hold a key.

## controls.registered_on_hold
Table containing functions registered with controls.register_on_hold().