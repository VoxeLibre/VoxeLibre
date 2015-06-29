Minetest mod "Better HUD"
=========================
version: 1.1

License of source code: WTFPL
-----------------------------
(c) Copyright BlockMen (2013)


This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public License, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtfpl/COPYING for more details.


Using the mod:
--------------

This mod changes the HUD of Minetest. 
It improves the apperance of the health and breath bar and adds a more fancy hotbar. Furthermore it adds a 
costum crosshair, an armor bar (only for 3darmor mod) and a hunger bar. It includes also a mechanic for hunger.


You can create a "hud.conf" to costumize the positions of health, hunger, armor and breath bar. Take a look at "hud.conf.example" to get more infos.

!!NOTICE: Keep in mind if running a server with this mod, that the costum position should be displayed correct on every screen size!!


Hunger:
This mod adds hunger to the game. You can disable this by setting "HUD_HUNGER_ENABLE = false" in "hud.conf", or "hud_hunger_enable = false" in minetest.conf. In case of conflict hud.conf configuration is dominant.

Currently supported food:
- Apples (default)
- Bread (default)
- Drawves (beer and such)
- Mooretrees
- Simple mobs
- Animalmaterials (mobf modpack)
- Fishing
- Glooptest
- Bushes
- Docfarming
- Farming plus
- Mtfoods

Example: 1 apple fills up the hunger bar by 1 bread, 1 bread (from farming) 2 breads in bar.

Altough it show 20 hunger points (10 breads) in hunger bar you can fill it up to 30 points. (5 breads not shown then)
