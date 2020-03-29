[mod] visible wielded items [wieldview]
=======================================

Makes hand wielded items visible to other players.

default settings: [minetest.conf]

# Set number of seconds between visible wielded item updates.
wieldview_update_time = 2

# Show nodes as tiles, disabled by default
wieldview_node_tiles = false


Info for modders
################

Wield image transformation: To apply a simple transformation to the item in
hand, add the group “wieldview_transform” to the item definition. The group
rating equals one of the numbers used for the [transform texture modifier
of the Lua API.
