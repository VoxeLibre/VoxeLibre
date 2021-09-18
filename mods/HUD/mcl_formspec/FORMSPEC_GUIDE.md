Formspecs are an important part of game and mod development.

This guide will learn you rules about creation of formspecs for the MineClone2 game.

First of all, MineClone2 aims to support ONLY last formspec version. Many utility functions will not work with formspec v1 or v2.

Label font size should be 25 to be minecraft like. We arent modifying formspec prepend in order to not break existing mods.

Just use this code to apply it to your formspec:
```lua
"style_type[label;font_size=25]",
```

The typical width of an inventory formspec is `0.375 + 9 + ((9-1) * 0.25) + 0.375 = 11.75`

Margins is 0.375
Space between 1st inventory line and the rest of inventory is 0.45

Labels should have 0.375 space above if there is no other stuff above and 0.45 between content
+ 0.375 under

According to minetest modding book, table.concat is faster than string concatenation, so this method should be prefered (the code is also more clear)