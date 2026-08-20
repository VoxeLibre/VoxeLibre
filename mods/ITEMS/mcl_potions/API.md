## Potions and Effects API

<!-- TOC -->
- [Potions and Effects API](#potions-and-effects-api)
  - [Namespace](#namespace)
  - [Effects](#effects)
    - [Functions](#functions)
    - [Deprecated functions](#deprecated-functions)
    - [Tables](#tables)
    - [Internally registered effects](#internally-registered-effects)
    - [Constants](#constants)
    - [Effect Definition](#effect-definition)
  - [HP Hudbar Modifiers](#hp-hudbar-modifiers)
    - [Functions](#functions-1)
    - [HP Hudbar Modifier Definition](#hp-hudbar-modifier-definition)
  - [Potions](#potions)
    - [Functions](#functions-2)
    - [Tables](#tables-1)
    - [Constants](#constants-1)
    - [Potion Definition](#potion-definition)
  - [Brewing](#brewing)
    - [Functions](#functions-3)
  - [Miscellaneous Functions](#miscellaneous-functions)
<!-- TOC -->

### Namespace
All of the API is defined in the `mcl_potions` namespace.

### Effects
This section describes parts of the API related to defining and managing effects on players and entities. The mod defines a bunch of effects internally using the same API as described below.

#### Functions
`mcl_potions.register_effect(def)` – takes an effect definition (`def`) and registers an effect if the definition is valid, and adds the known parts of the definition as well as the outcomes of processing of some parts of the definition to the `mcl_potions.registered_effects` table. This should only be used at load time.


`mcl_potions.apply_haste_fatigue(toolcaps, h_fac, f_fac)` – takes a table of tool capabilities (`toolcaps`) and modifies it using the provided haste factor (`h_fac`) and fatigue factor (`f_fac`). The factors default to no-op values.


`mcl_potions.hf_update_internal(hand, object)` – returns the `hand` of the `object` updated according to their combined haste and fatigue. **This doesn't change anything by itself!** Manual update of the hand with the hand returned by this function has to be done. This should only be called in situations that are *directly* impacted by haste and/or fatigue, and therefore require an update of the hand.


`mcl_potions.update_haste_and_fatigue(player)` – updates haste and fatigue on a `player` (described by an ObjectRef). This should be called whenever an update of the haste-type and fatigue-type effects is desired.


`mcl_potions._reset_haste_fatigue_item_meta(player)` – resets the item meta changes caused by haste-type and fatigue-type effects throughout the inventory of the `player` described by an ObjectRef.


`mcl_potions._clear_cached_effect_data(object)` – clears cashed effect data for the `object`. This shouldn't be used for resetting effects.


`mcl_potions._reset_effects(object, set_hud)` – actually resets the effects for the `object`. It also updates HUD if `set_hud` is `true` or undefined (`nil`).


`mcl_potions._save_player_effects(player)` – saves all effects of the `player` described by an ObjectRef to metadata.


`mcl_potions._load_player_effects(player)` – loads all effects from the metadata of the `player` described by an ObjectRef.


`mcl_potions._load_entity_effects(entity)` – loads all effects from the `entity` (a LuaEntity).


`mcl_potions.has_effect(object, effect_name)` – returns `true` if `object` (described by an ObjectRef) has the effect of the ID `effect_name`, `false` otherwise.


`mcl_potions.get_effect(object, effect_name)` - returns a table containing values of the effect of the ID `effect_name` on the `object` if the object has the named effect, `false` otherwise.

* table returned by the above function is like this:
```lua
    effect = {
        dur = float -- duration of the effect in seconds, may be infinite
        timer = float -- how much of the duration (in seconds) has already elapsed
        no_particles = bool -- if this is true, no particles signifying this effect will appear

        -- player-only fields
        hud_index = int -- position in the HUD used by this effect (icon, level, timer) - probably meaningless outside mcl_potions

        -- optional fields
        factor = float -- power of the effect if the effect uses factor; this may mean different things depending on the effect
        step = float -- how often (in seconds) the on_step() function of the effect is executed, if it exists
        hit_timer = float -- how much of the step (in seconds) has already elapsed

        -- effect-specific fields
            -- effects in mcl_potions have their own fields here, for now external effects can't add any here
        blocked = bool -- used by conduit power
        high = bool -- used by nausea
        vignette = int -- handle to the HUD vignette of the effect, used by effects that use one
        absorb = float -- "HP" of the absorption effect
        waypoints = table -- used by glowing, indexed by player ObjectRef, contains HUD handles for the glowing waypoints
        flash = float -- used by darkness, denotes vision range modifier
        flashdir = bool -- used by darkness, denotes whether vision range is increasing (or decreasing)
    }
```


`mcl_potions.get_effect_level(object, effect_name)` – returns the level of the effect of the ID `effect_name` on the `object`. If the effect has no levels, returns `1`. If the object doesn't have the effect, returns `0`. If the effect is not registered, returns `nil`.


`mcl_potions.get_total_haste(object)` – returns the total haste of the `object` (from all haste-type effects).


`mcl_potions.get_total_fatigue(object)` – returns the total fatigue of the `object` (from all fatigue-type effects).


`mcl_potions.clear_effect(object, effect)` – attempts to remove the effect of the ID `effect` from the `object`. If the effect is not registered, logs a warning and returns `false`. Otherwise, returns `nil`.


`mcl_potions.make_invisible(obj_ref, hide)` – makes the object going by the `obj_ref` invisible if `hide` is true, visible otherwise.


`mcl_potions.register_generic_resistance_predicate(predicate)` – registers an arbitrary effect resistance predicate. This can be used e.g. to make some entity resistant to all (or some) effects under specific conditions.

* `predicate` – `function(object, effect_name)` - return `true` if `object` resists effect of the ID `effect_name`


`mcl_potions.give_effect(name, object, factor, duration, no_particles)` – attempts to give effect of the ID `name` to the `object` with the provided `factor` and `duration`. If `no_particles` is `true`, no particles will be emitted from the object when under the effect. If the effect is not registered, target is invalid (or resistant), or the same effect with more potency is already applied to the target, this function does nothing and returns `false`. On success, this returns `true`.


`mcl_potions.give_effect_by_level(name, object, level, duration, no_particles)` – attempts to give effect of the ID `name` to the `object` with the provided `level` and `duration`. If `no_particles` is `true`, no particles will be emitted from the object when under the effect. This converts `level` to factor and calls `mcl_potions.give_effect()` internally, returning the return value of that function. `level` equal to `0` is no-op.


`mcl_potions.healing_func(object, hp)` – attempts to heal the `object` by `hp`. Negative `hp` harms magically instead.

`mcl_potions.get_lingering_clouds_at(check_pos)` - returns a table of lingering effects at pos of shape: {pos, color, timer, def, is_water, potency, plus, radius}

#### Deprecated functions
**Don't use the following functions, use the above API instead!** The following are only provided for backwards compatibility and will be removed later. They all call `mcl_potions.give_effect()` internally.

* `mcl_potions.strength_func(object, factor, duration)`
* `mcl_potions.leaping_func(object, factor, duration)`
* `mcl_potions.weakness_func(object, factor, duration)`
* `mcl_potions.swiftness_func(object, factor, duration)`
* `mcl_potions.slowness_func(object, factor, duration)`
* `mcl_potions.withering_func(object, factor, duration)`
* `mcl_potions.poison_func(object, factor, duration)`
* `mcl_potions.regeneration_func(object, factor, duration)`
* `mcl_potions.invisiblility_func(object, null, duration)`
* `mcl_potions.water_breathing_func(object, null, duration)`
* `mcl_potions.fire_resistance_func(object, null, duration)`
* `mcl_potions.night_vision_func(object, null, duration)`
* `mcl_potions.bad_omen_func(object, factor, duration)`



#### Tables
`mcl_potions.registered_effects` – contains all effects that have been registered. You can read from it various data about the effects. You can overwrite the data and alter the effects' definitions too, but this is discouraged, i.e. only do this if you really know what you are doing. You shouldn't add effects directly to this table, as this would skip important setup; instead use the `mcl_potions.register_effect()` function, which is described above.

#### Internally registered effects
You can't register effects going by these names, because they are already used:

* `invisibility`
* `poison`
* `regeneration`
* `strength`
* `weakness`
* `weakness`
* `dolphin_grace`
* `leaping`
* `slow_falling`
* `swiftness`
* `slowness`
* `levitation`
* `night_vision`
* `darkness`
* `glowing`
* `health_boost`
* `absorption`
* `fire_resistance`
* `resistance`
* `luck`
* `bad_luck`
* `bad_omen`
* `hero_of_village`
* `withering`
* `frost`
* `blindness`
* `nausea`
* `food_poisoning`
* `saturation`
* `haste`
* `fatigue`
* `conduit_power`

#### Constants
`mcl_potions.LONGEST_MINING_TIME` – longest mining time of one block that can be achieved by slowing down the mining by fatigue-type effects.

`mcl_potions.LONGEST_PUNCH_INTERVAL` – longest punch interval that can be achieved by slowing down the punching by fatigue-type effects.

#### Effect Definition
```lua
def = {
-- required parameters in def:
    name = string -- effect name in code (unique ID) - can't be one of the reserved words ("list", "heal", "remove", "clear")
    description = S(string) -- actual effect name in game
-- optional parameters in def:
    get_tt = function(factor) -- returns tooltip description text for use with potions
    icon = string -- file name of the effect icon in HUD - defaults to one based on name
    res_condition = function(object) -- returning true if target is to be resistant to the effect
    on_start = function(object, factor) -- called when dealing the effect
    on_load = function(object, factor) -- called on_joinplayer and on_activate
    on_step = function(dtime, object, factor, duration) -- running every step for all objects with this effect
    on_hit_timer = function(object, factor, duration) -- if defined runs a hit_timer depending on timer_uses_factor value
    on_end = function(object) -- called when the effect wears off
    after_end = function(object) -- called when the effect wears off, after purging the data of the effect
    on_save_effect = function(object -- called when the effect is to be serialized for saving (supposed to do cleanup)
    particle_color = string -- colorstring for particles - defaults to #3000EE
    uses_factor = bool -- whether factor affects the effect
    lvl1_factor = number -- factor for lvl1 effect - defaults to 1 if uses_factor
    lvl2_factor = number -- factor for lvl2 effect - defaults to 2 if uses_factor
    timer_uses_factor = bool -- whether hit_timer uses factor (uses_factor must be true) or a constant value (hit_timer_step must be defined)
    hit_timer_step = float -- interval between hit_timer hits
    damage_modifier = string -- damage flag of which damage is changed as defined by modifier_func, pass empty string for all damage
    dmg_mod_is_type = bool -- damage_modifier string is used as type instead of flag of damage, defaults to false
    modifier_func = function(damage, effect_vals) -- see damage_modifier, if not defined damage_modifier defaults to 100% resistance
    modifier_priority = integer -- priority passed when registering damage_modifier - defaults to -50
    affects_item_speed = table
-- -- if provided, effect gets added to the item_speed_effects table, this should be true if the effect affects item speeds,
-- -- otherwise it won't work properly with other such effects (like haste and fatigue)
-- -- -- factor_is_positive - bool - whether values of factor between 0 and 1 should be considered +factor% or speed multiplier
-- -- --   - obviously +factor% is positive and speed multiplier is negative interpretation
-- -- --   - values of factor higher than 1 will have a positive effect regardless
-- -- --   - values of factor lower than 0 will have a negative effect regardless
}
```

### HP Hudbar Modifiers
This part of the API allows complex modification of the HP hudbar. It is mainly required here, so it is defined here. It may be moved to a different mod in the future.

#### Functions
`mcl_potions.register_hp_hudbar_modifier(def)` – this function takes a modifier definition (`def`, described below) and registers a HP hudbar modifier if the definition is valid.

#### HP Hudbar Modifier Definition
```lua
def = {
-- required parameters in def:
    predicate = function(player) -- returns true if player fulfills the requirements (eg. has the effects) for the hudbar look
    icon = string -- name of the icon to which the modifier should change the HP hudbar heart
    priority = signed_int -- lower gets checked first, and first fulfilled predicate applies its modifier
}
```

### Potions
Magic!

#### Functions
`mcl_potions.register_potion(def)` – takes a potion definition (`def`) and registers a potion if the definition is valid, and adds the known parts of the definition as well as the outcomes of processing of some parts of the definition to the `mcl_potions.registered_effects` table. This, depending on some fields of the definition, may as well register the corresponding splash potion, lingering potion and tipped arrow. This should only be used at load time.

`mcl_potions.register_splash(name, descr, color, def)` – registers a splash potion (item and entity when thrown). This is mostly part of the internal API and probably shouldn't be used from outside, therefore not providing exact description. This is used by `mcl_potions.register_potion()`.

`mcl_potions.register_lingering(name, descr, color, def)` – registers a lingering potion (item and entity when thrown). This is mostly part of the internal API and probably shouldn't be used from outside, therefore not providing exact description. This is used by `mcl_potions.register_potion()`.

`mcl_potions.register_arrow(name, desc, color, def)` – registers a tipped arrow (item and entity when shot). This is mostly part of the internal API and probably shouldn't be used from outside, therefore not providing exact description. This is used by `mcl_potions.register_potion()`.

#### Tables
`mcl_potions.registered_potions` – contains all potions that have been registered. You can read from it various data about the potions. You can overwrite the data and alter the definitions too, but this is discouraged, i.e. only do this if you really know what you are doing. You shouldn't add potions directly to this table, because they have to be registered as items too; instead use the `mcl_potions.register_potion()` function, which is described above. Some brewing recipes are autofilled based on this table after the loading of all the mods is done.

#### Constants
* `mcl_potions.POTENT_FACTOR = 2`
* `mcl_potions.PLUS_FACTOR = 8/3`
* `mcl_potions.INV_FACTOR = 0.50`
* `mcl_potions.DURATION = 180`
* `mcl_potions.DURATION_INV = mcl_potions.DURATION * mcl_potions.INV_FACTOR`
* `mcl_potions.DURATION_POISON = 45`
* `mcl_potions.II_FACTOR = mcl_potions.POTENT_FACTOR` – **DEPRECATED**
* `mcl_potions.DURATION_PLUS = mcl_potions.DURATION * mcl_potions.PLUS_FACTOR` – **DEPRECATED**
* `mcl_potions.DURATION_2 = mcl_potions.DURATION / mcl_potions.II_FACTOR` – **DEPRECATED**
* `mcl_potions.SPLASH_FACTOR = 0.75`
* `mcl_potions.LINGERING_FACTOR = 0.25`

#### Potion Definition
```lua
def = {
-- required parameters in def:
    name = string, -- potion name in code
-- optional parameters in def:
    desc_prefix = S(string), -- part of visible potion name, comes before the word "Potion"
    desc_suffix = S(string), -- part of visible potion name, comes after the word "Potion"
    _tt = S(string), -- custom tooltip text
    _dynamic_tt = function(level), -- returns custom tooltip text dependent on potion level
    _longdesc = S(string), -- text for in=game documentation
    stack_max = int, -- max stack size -  defaults to 1
    image = string, -- name of a custom texture of the potion icon
    color = string, -- colorstring for potion icon when image is not defined - defaults to #0000FF
    groups = table, -- item groups definition for the regular potion, not splash or lingering -
--   - must contain _mcl_potion=1 for tooltip to include dynamic_tt and effects
--   - defaults to {brewitem=1, food=3, can_eat_when_full=1, _mcl_potion=1}
    nocreative = bool, -- adds a not_in_creative_inventory=1 group - defaults to false
    _effect_list = {, -- all the effects dealt by the potion in the format of tables
-- -- the name of each sub-table should be a name of a registered effect, and fields can be the following:
        uses_level = bool, -- whether the level of the potion affects the level of the effect -
-- -- --   - defaults to the uses_factor field of the effect definition
        level = int, -- used as the effect level if uses_level is false and for lvl1 potions - defaults to 1
        level_scaling = int, -- used as the number of effect levels added per potion level - defaults to 1 -
-- -- --   - this has no effect if uses_level is false
        dur = float, -- duration of the effect in seconds - defaults to mcl_potions.DURATION
        dur_variable = bool, -- whether variants of the potion should have the length of this effect changed -
-- -- --   - defaults to true
-- -- --   - if at least one effect has this set to true, the potion has a "plus" variant
        effect_stacks = bool, -- whether the effect stacks - defaults to false
    }
    uses_level = bool, -- whether the potion should come at different levels -
--   - defaults to true if uses_level is true for at least one effect, else false
    drinkable = bool, -- defaults to true
    has_splash = bool, -- defaults to true
    has_lingering = bool, -- defaults to true
    has_arrow = bool, -- defaults to false
    has_potent = bool, -- whether there is a potent (e.g. II) variant - defaults to the value of uses_level
    default_potent_level = int, -- potion level used for the default potent variant - defaults to 2
    default_extend_level = int, -- extention level (amount of +) used for the default extended variant - defaults to 1
    custom_on_use = function(user, level), -- called when the potion is drunk, returns true on success
    custom_effect = function(object, level, plus), -- called when the potion effects are applied, returns true on success
    custom_splash_effect = function(pos, level), -- called when the splash potion explodes, returns true on success
    custom_linger_effect = function(pos, radius, level), -- called on the lingering potion step, returns true on success
}
```

### Brewing
Functions supporting brewing potions, used by the `mcl_brewing` module, which calls `mcl_potions.get_alchemy()`.

#### Functions
`mcl_potions.register_ingredient_potion(input, out_table)` – registers a potion (`input`, item string) that can be combined with multiple ingredients for different outcomes; `out_table` contains the recipes for those outcomes

`mcl_potions.register_water_brew(ingr, potion)` – registers a `potion` (item string) brewed from water with a specific ingredient (`ingr`)

`mcl_potions.register_awkward_brew(ingr, potion)` – registers a `potion` (item string) brewed from an awkward potion with a specific ingredient (`ingr`)

`mcl_potions.register_mundane_brew(ingr, potion)` – registers a `potion` (item string) brewed from a mundane potion with a specific ingredient (`ingr`)

`mcl_potions.register_thick_brew(ingr, potion)` – registers a `potion` (item string) brewed from a thick potion with a specific ingredient (`ingr`)

`mcl_potions.register_table_modifier(ingr, modifier)` – registers a brewing recipe altering the potion using a table; this is supposed to substitute one item with another

`mcl_potions.register_inversion_recipe(input, output)` – what it says

`mcl_potions.register_meta_modifier(ingr, mod_func)` – registers a brewing recipe altering the potion using a function; this is supposed to be a recipe that changes metadata only

`mcl_potions.get_alchemy(ingr, pot)` – finds an alchemical recipe for given ingredient and potion; returns outcome

### Miscellaneous Functions
`mcl_potions._extinguish_nearby_fire(pos, radius)` – attempts to extinguish fires in an area, both on objects and nodes.

`mcl_potions._add_spawner(obj, color)` – adds a particle spawner denoting an effect being in action.

`mcl_potions._use_potion(obj, color)` – visual and sound effects of drinking a potion.

`mcl_potions.is_obj_hit(self, pos)` – determines if an object is hit (by a thrown potion).
