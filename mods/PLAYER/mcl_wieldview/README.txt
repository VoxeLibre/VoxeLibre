[mod] visible wielded items [wieldview]
=======================================

Makes hand wielded items visible to other players.


Info for modders
################

Add an item to the "no_wieldview" group with a rating of 1 and it will not be shown by the wieldview.
If an item has the "no_wieldview" group rating of 1, the item definition can specify the property "_wieldview_item".
"_wieldview_item" should be set to an item name that will be shown by the wieldview instead of the item.
