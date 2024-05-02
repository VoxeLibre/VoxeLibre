mcl_stonecutter
===============
Adds the stonecutter block. Used to cut stone like materials into stairs, slabs, etc. Also used as the Stone Mason Villager's jobsite.

### Adding recipes

* To add a new custom stonecutter recipe, use `mcl_stonecutter.register_recipe(input, output, count)`
* `input` must be a name of a registered item
* `output` must also be a name of a registered item
* `count` should be a number denoting output count, this defaults to 1 for `nil` and invalid values
    * a number with a fraction passed as count will be rounded down
* Stairs, slabs and walls get their recipes registered automatically
* Recipe chains are followed automatically, so any recipes taking `output` of another recipe as input will also be taking `input` of that recipe as their input

### Displaying the Stonecutter menu

* To display the stonecutter formspec to a player use `mcl_stonecutter.show_stonecutter_form(player)`

License of code
---------------
See the main VoxeLibre README.md file.
Author: PrairieWind, ChrisPHP, cora, Herowl, AFCMS

License of media
----------------
mcl_stonecutter_bottom.png
mcl_stonecutter_side.png
mcl_stonecutter_top.png
mcl_stonecutter_saw.png
License: CC0 1.0 Universal (CC0 1.0)
Author: RandomLegoBrick
