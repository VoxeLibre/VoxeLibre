# mcl_death_drop
Drop registered inventories on player death.

## mcl_death_drop.register_dropped_list(inv, listname, drop)
* inv: can be:
    * "PLAYER": will be interpreted like player inventory (to avoid multiple calling to get_inventory())
    * function(player): must return inventory
* listname: string
* drop: bool
    * true: the entire list will be dropped
    * false: items with curse_of_vanishing enchantement will be broken.

## mcl_death_drop.registered_dropped_lists
Table containing dropped list inventory, name and drop state.