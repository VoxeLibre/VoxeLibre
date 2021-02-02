# MineClone 2
An unofficial Minecraft-like game for Minetest. Forked from MineClone by davedevils.
Developed by many people. Not developed or endorsed by Mojang AB.

Version: 0.70.0

### Gameplay
You start in a randomly-generated world made entirely of cubes. You can explore
the world and dig and build almost every block in the world to create new
structures. You can choose to play in a “survival mode” in which you have to
fight monsters and hunger for survival and slowly progress through the
various other aspects of the game, such as mining, farming, building machines, and so on
Or you can play in “creative mode” in which you can build almost anything instantly.

#### Gameplay summary

* Sandbox-style gameplay, no goals
* Survive: Fight against hostile monsters and hunger
* Mine for ores and other treasures
* Magic: Gain experience and enchant your tools
* Use the collected blocks to create great buildings, your imagination is the limit
* Collect flowers (and other dye sources) and colorize your world
* Find some seeds and start farming
* Find or craft one of hundreds of items
* Build a railway system and have fun with minecarts
* Build complex machines with redstone circuits
* In creative mode you can build almost anything for free and without limits

## How to play (quick start)
### Getting started
* **Punch a tree** trunk until it breaks and collect wood
* Place the **wood into the 2×2 grid** (your “crafting grid” in your inventory menu and craft 4 wood planks
* Place the 4 wood planks in a 2×2 shape in the crafting grid to **make a crafting table**
* **Rightclick the crafting table** for a 3×3 crafting grid to craft more complex things
* Use the **crafting guide** (book icon) to learn all the possible crafting recipes
* **Craft a wooden pickaxe** so you can dig stone
* Different tools break different kinds of blocks. Try them out!
* Continue playing as you wish. Have fun!

### Farming
* Find seeds
* Craft hoe
* Rightclick dirt or similar block with hoe to create farmland
* Place seeds on farmland and watch them grow
* Collect plant when fully grown
* If near water, farmland becomes wet and speeds up growth

### Furnace
* Craft furnace
* Furnace allows you to obtain more items
* Upper slot must contain a smeltable item (example: iron ore)
* Lower slot must contain a fuel item (example: coal)
* See tooltips in crafting guide to learn about fuels and smeltable items

### Additional help
More help about the gameplay, blocks items and much more can be found from inside
the game. You can access the help from your inventory menu.

### Special items
The following items are interesting for Creative Mode and for adventure
map builders. They can not be obtained in-game or in the creative inventory.

* Barrier: `mcl_core:barrier`

Use the `/giveme` chat command to obtain them. See the in-game help for
an explanation.

#### Incomplete items
These items do not work yet, but you can get them with `/giveme` for testing:

* Minecart with Chest: `mcl_minecarts:chest_minecart`
* Minecart with Furnace: `mcl_minecarts:furnace_minecart`
* Minecart with Hopper: `mcl_minecarts:hopper_minecart`
* Minecart with Command Block: `mcl_minecarts:command_block_minecart`

## Installation
This game requires [Minetest](http://minetest.net) to run (version 5.0.0 or
later). So you need to install Minetest first. Only stable versions of Minetest
are officially supported.
There is no support for running MineClone 2 in development versions of Minetest.

To install MineClone 2 (if you haven't already), move this directory into the
“games” directory of your Minetest data directory. Consult the help of
Minetest to learn more.

## Project description
The main goal of **MineClone 2** is to be a clone of Minecraft and to be released as free software.

* **Target of development: Minecraft, PC Edition, version 1.11** (later known as “Java Edition”)
* Features of later Minecraft versions might sneak in, but they have a low priority
* In general, Minecraft is aimed to be cloned as good as Minetest currently permits (no hacks)
* Cloning the gameplay has highest priority
* MineClone 2 will use different graphics and sounds, but with a similar style
* Cloning the interface has no priority. It will only be roughly imitated
* Limitations found in Minetest will be written down and reported in the course of development

## Completion status
This game is currently in **alpha** stage.
It is playable, but unfinished, many bugs are to be expected.
Backwards-compability is *not* guaranteed, updating your world might cause small and
big bugs (such as “missing node” errors or even crashes).

The following main features are available:

* Tools, weapons
* Armor
* Crafting system: 2×2 grid, crafting table (3×3 grid), furnace, including a crafting guide
* Chests, large chests, ender chests, shulker boxes
* Furnaces, hoppers
* Hunger
* Most monsters and animals
* All ores from Minecraft
* Most blocks in the overworld
* Water and lava
* Weather
* 28 biomes
* The Nether, a fiery underworld in another dimension
* Redstone circuits (partially)
* Minecarts (partial)
* Status effects (partial)
* Experience
* Enchanting
* Brewing, potions, tipped arrow (partial)
* Boats
* Fire
* Buidling blocks: Stairs, slabs, doors, trapdoors, fences, fence gates, walls
* Clock
* Compass
* Sponge
* Slime block (does not interact with redstone)
* Small plants and saplings
* Dyes
* Banners
* Deco blocks: Glass, stained glass, glass panes, iron bars, hardened clay (and colors), heads and more
* Item frames
* Jukeboxes
* Beds
* Inventory menu
* Creative inventory
* Farming
* Writable books
* A few server commands
* And more!

The following features are incomplete:

* Generated structures (especially villages)
* Some monsters and animals
* Redstone-related things
* The End
* Special minecarts
* A couple of non-trivial blocks and items

Bonus features (not found in Minecraft 1.11):

* Built-in crafting guide which shows you crafting and smelting recipes
* In-game help system containing extensive help about gameplay basics, blocks, items and more
* Temporary crafting recipes. They only exist to make some otherwise unaccessible items available when you're not in creative mode. These recipes will be removed as development goes on an more features become available
* Saplings in chests in mapgen v6
* Fully moddable (thanks to Minetest's powerful Lua API)
* New blocks and items:
    * Lookup tool, shows you the help for whatever it touches
    * More slabs and stairs
    * Nether Brick Fence Gate
    * Red Nether Brick Fence
    * Red Nether Brick Fence Gate

Technical differences from Minecraft:

* Height limit of ca. 31000 blocks (much higher than in Minecraft)
* Horizontal world size is ca. 62000×62000 blocks (much smaller than in Minecraft, but it is still very large)
* Still very incomplete and buggy
* Blocks, items, enemies and other features are missing
* A few items have slightly different names to make them easier to distinguish
* Different music for jukebox
* Different textures (Pixel Perfection)
* Different sounds (various sources)
* Different engine (Minetest)

… and finally, MineClone 2 is free software (“free” as in “freedom”)!

## Reporting bugs
Please report all bugs and missing Minecraft features here:

<https://git.minetest.land/MineClone2/MineClone2/issues>

## Other readme files

* `LICENSE.txt`: The GPLv3 license text
* `CONTRIBUTING.md`: Information for those who want to contribute
* `MISSING_ENGINE_FEATURES.md`: List of missing features in Minetest which MineClone 2 would need for improvement
* `API.md`: For Minetest modders who want to mod this game

## Credits
There are so many people to list (sorry). Check out the respective mod directories for details. This section is only a rough overview of the core authors of this game.

### Coding
* [Wuzzy](https://forum.minetest.net/memberlist.php?mode=viewprofile&u=3082): Main programmer of most mods (retired)
* davedevils: Creator of MineClone on which MineClone 2 is based on
* [ex-bart](https://github.com/ex-bart): Redstone comparators
* [Rootyjr](https://github.com/Rootyjr): Fishing rod and bugfixes
* [aligator](https://github.com/aligator): Improvement of doors
* [ryvnf](https://github.com/ryvnf): Explosion mechanics
* MysticTempest: Bugfixes
* [bzoss](https://github.com/bzoss): Status effects, potions, brewing stand
* kay27 <kay27@bk.ru>: Experience system, bugfixes, optimizations (Current maintainer)
* [EliasFleckenstein03](https://github.com/EliasFleckenstein03): End crystals, enchanting, burning mobs / players, animated chests, bugfixes (Current maintainer)
* 2mac: Fix bug with powered rail
* Lots of other people: TO BE WRITTEN (see mod directories for details)

#### Mod credits (summary)

* `controls`: Arcelmi
* `flowlib`: Qwertymine13
* `walkover`: lordfingle
* `drippingwater`: kddekadenz
* `mobs_mc`: maikerumine, 22i and others
* `awards`: rubenwardy
* `screwdriver`: RealBadAngel, Maciej Kastakin, Minetest contributors
* `xpanes`: Minetest contributors
* `mesecons` mods: Jeija and contributors
* `wieldview`: Stuart Jones
* `mcl_meshhand`: Based on `newhand` by jordan4ibanez
* `mcl_mobs`: Based on Mobs Redo [`mobs`] by TenPlus1 and contributors
* Most other mods: Wuzzy

Detailed credits for each mod can be found in the individual mod directories.

### Graphics
* [XSSheep](http://www.minecraftforum.net/members/XSSheep): Main author; creator of the Pixel Perfection resource pack of Minecraft 1.11
* [Wuzzy](https://forum.minetest.net/memberlist.php?mode=viewprofile&u=3082): Main menu imagery and various edits and additions of texture pack
* [kingoscargames](https://github.com/kingoscargames): Various edits and additions of existing textures
* [leorockway](https://github.com/leorockway): Some edits of mob textures
* [xMrVizzy](https://minecraft.curseforge.com/members/xMrVizzy): Glazed terracotta (textures are subject to be replaced later)
* yutyo <tanakinci2002@gmail.com>: MineClone 2 logo
* Other authors: GUI images

### Translations
* Wuzzy: German
* Rocher Laurent <rocherl@club-internet.fr>: French
* wuniversales: Spanish
* kay27 <kay27@bk.ru>: Russian

### Models
* [22i](https://github.com/22i): Creator of all models
* [tobyplowy](https://github.com/tobyplowy): UV-mapping fixes to said models

### Sounds and music
Various sources. See the respective mod directories for details.

### Special thanks

* davedevils for starting MineClone, the original version of this game
* Wuzzy for starting and maintaining MineClone2 for several years
* celeron55 for creating Minetest
* Minetest's modding community for providing a huge selection of mods, some of which ended up in MineClone 2
* Jordach for the jukebox music compilation from Big Freaking Dig
* The workaholics who spent way too much time writing for the Minecraft Wiki. It's an invaluable resource for creating this game
* Notch and Jeb for being the major forces behind Minecraft
* XSSheep for creating the Pixel Perfection resource pack
* [22i](https://github.com/22i) for providing great models and support
* [maikerumine](http://github.com/maikerumine) for kicking off mobs and biomes

## Info for programmers
You find interesting and useful infos in `API.md`.

## Legal information
This is a fan game, not developed or endorsed by Mojang AB.

Copying is an act of love. Please copy and share! <3
Here's the detailed legalese for those who need it:

### License of source code
MineClone 2 (by kay27, EliasFleckenstein, Wuzzy, davedevils and countless others)
is an imitation of Minecraft.

MineClone 2 is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License (in the LICENSE.txt file) for more
details.

In the mods you might find in the read-me or license
text files a different license. This counts as dual-licensing.
You can choose which license applies to you: Either the
license of MineClone 2 (GNU GPLv3) or the mod's license.

MineClone 2 is a direct continuation of the discontinued MineClone
project by davedevils.

Mod credits:
See `README.txt` or `README.md` in each mod directory for information about other authors.
For mods that do not have such a file, the license is the source code license
of MineClone 2 and the author is Wuzzy.

### License of media (textures and sounds)
No non-free licenses are used anywhere.

The textures, unless otherwise noted, are based on the Pixel Perfection resource pack for Minecraft 1.11,
authored by XSSheep. Most textures are verbatim copies, while some textures have been changed or redone
from scratch.
The glazed terracotta textures have been created by (MysticTempest)[https://github.com/MysticTempest].
Source: <https://www.planetminecraft.com/texture_pack/131pixel-perfection/>
License: [CC BY-SA 4.0](http://creativecommons.org/licenses/by-sa/4.0/)

The main menu images are release under: [CC0](https://creativecommons.org/publicdomain/zero/1.0/)

All other files, unless mentioned otherwise, fall under:
Creative Commons Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)
http://creativecommons.org/licenses/by-sa/3.0/

See README.txt in each mod directory for detailed information about other authors.
