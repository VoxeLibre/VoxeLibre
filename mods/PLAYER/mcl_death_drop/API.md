# mcl_death_drop
Drop registered inventories on player death.

## mcl_death_drop.register_dropped_list(inv, listname, drop)
* inv: can be:
    * "PLAYER": will be interpreted like player inventory (to avoid multiple calling to get_inventory())
    * function(player): must return inventory
* listname: string
* drop: bool
    * true: the list will be dropped
    * false: the list will only be cleared

## mcl_death_drop.registered_dropped_lists
Table containing dropped list inventory, name and drop state.

## mcl_death_drop.on_death_drop_per_stack
Table containing functions to handle a death event, called for each itemstack in dead player's inventory. Can be used just to skip dropping of an item or for something more complex, like altering metadata.

## mcl_death_drop.register_on_death_drop_per_stack(on_death_drop)
* on_death_drop: function(player, inv, listname, idx, stack)

### on_death_drop(player, inv, listname, idx, stack)
* returns: bool
    * true: event is considered handled, default dropping will be skipped
    * false: proceed to default behavior
* player: ObjectRef for dying player
* inv: InvRef for inventory, can be different from player inventory
* listname: string
* idx: int index of itemstack in list
* stack: ItemStack in question
