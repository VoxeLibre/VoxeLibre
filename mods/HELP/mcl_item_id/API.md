# mcl_item_id
Show the item ID of an item in the description.
With this API, you can register a different name space than "voxelibre" for your mod.

## mcl_item_id.set_mod_namespace(modname, namespace)
Set a name space for all items in a mod.

* param1: the modname
* param2: (optional) string of the desired name space, if nil, it is the name of the mod

## mcl_item_id.get_mod_namespace(modname)
Get the name space of a mod registered with mcl_item_id.set_mod_namespace(modname, namespace).

* param1: the modname

### Examples:

The name of the mod is "mod" which registered an item called "mod:itemname".

* mcl_item_id.set_mod_namespace("mod", "mymod") will show "mymod:itemname" in the description of "mod:itemname"
* mcl_item_id.set_mod_namespace(minetest.get_current_modname()) will show "mod:itemname" in the description of "mod:itemname"
* mcl_item_id.get_mod_namespace(minetest.get_current_modname()) will return "mod" 

(If no namespace is set by a mod, mcl_item_id.get_mod_namespace(minetest.get_current_modname()) will return "voxelibre")
