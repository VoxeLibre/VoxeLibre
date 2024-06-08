# mcl_sus_stew
Registering suspicious stews and their effects

## mcl_sus_stew.register_sus_effect(effect_name, effect_func)
Register a sus stew effect.
* effect_name: name of sus stew effect
* effect_func: function to be called when sus stew effect is activated
It is a mcl_hunger _custom_func and so takes arguments <itemstack>, <placer>, <pointed_thing>.

## mcl_sus_stew.register_sus_potion_effect(potion_name, factor, duration, effect_name)
Conveniently register a sus stew effect which gives the eater a status effect.
* potion_name: name of status effect to be given
* factor: factor of status effect
* duration: duration of status effect
* effect_name: name of sus stew effect; if nil, then <potion_name> is used

## mcl_sus_stew.register_sus_stew(secret_ingredient, effect_name)
Register a suspicious stew crafted with a bowl, red mushroom, brown mushroom and <secret_ingredient>.
* secret_ingredient: itemstring of the fourth ingredient
* effect_name: the name of the sus stew effect to be activated when the sus stew is eaten
