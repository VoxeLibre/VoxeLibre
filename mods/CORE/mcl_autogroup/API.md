# `mcl_autogroup`
This mod adds an API that allows tools to have variable dig speeds and determine item drops based off the tools material level.

## `mcl_autogroup.can_harvest(nodename, toolname, player)`
Return true if `nodename` can be dug with `toolname` by `player`.

* `nodename`: string, valid nodename
* `toolname`: (optional) string, valid toolname
* `player`: (optinal) ObjectRef, valid player

## `mcl_autogroup.get_groupcaps(toolname, efficiency)`
This function is used to calculate diggroups for tools.
WARNING: This function can only be called after mod initialization.
* `toolname`: string, name of the tool being enchanted (like `"mcl_tools:diamond_pickaxe"`)
* `efficiency`: (optional) integer, the efficiency level the tool is enchanted with (default 0)

## `mcl_autogroup.get_wear(toolname, diggroup)`
Return the max wear of `toolname` with `diggroup`
WARNING: This function can only be called after mod initialization.
* `toolname`: string, name of the tool used
* `diggroup`: string, the name of the diggroup the tool is used on

## `mcl_autogroup.register_diggroup(group, def)`
* `group`: string, name of the group to register as a digging group
* `def`: (optional) table, table with information about the diggroup (defaults to `{}` if unspecified)
    * `level`: (optional) string, if specified it is an array containing the names of the different digging levels the digging group supports

## `mcl_autogroup.registered_diggroups`
List of registered diggroups, indexed by name.

## `mcl_autogroup.group_compatibility(groups, node_def)`
Adds VoxeLibre-equivalent groups to `node_def.groups`.
* `groups` - A list of groups to add compatiblity groups for. Normally this is a copy of `node_def.groups`.
* `node_def` - The node defintion to update groups for.
