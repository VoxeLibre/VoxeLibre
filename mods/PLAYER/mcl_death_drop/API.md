# mcl_death_drop
Drop registered inventories on player death.

## mcl_death_drop.register_dropped_list(inv, listname, drop)
* inv: string of function returning a string
* listname: string
* drop: bool
-- if true the entire list will be dropped
-- if false, items with curse_of_vanishing enchantement will be broken.

## mcl_death_drop.registered_dropped_lists
Table containing dropped list definition.