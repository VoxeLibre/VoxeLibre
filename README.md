# MineClone 2
A Minecraft-like game for Minetest. Forked from MineClone by daredevils.

### Gameplay
You start in a randomly-generated world made entirely of cubes. You can explore
the world and dig and build almost every block in the world to create new
structures. You can choose to play in a “survival mode” in which you have to
fight monsters and hunger for survival and slowly progress through the
various other aspects of the game, such as mining, farming, building machines, and so on
Or you can play in “creative mode” in which you can build almost anything instantly.

Gameplay summary:
* Sandbox-style gameplay, no goals (for now)
* Survive: Fight against hostile monsters and hunger
* Mine for ores and other treasures
* Use the collected blocks to create great buildings, your imagination is the limit
* Collect flowers (and other dye sources) and colorize your world
* Find some seeds and start farming
* Find or craft one of hundreds of items
* Build a railway system and have fun with minecarts
* Build complex machines with redstone circuits
* In creative mode you can build almost anything for free and without limits

## How to play (quick start)
### Getting started
* **Use the world generator “v6”!**
* Find punch a tree trunk until it breaks. It gives you wood
* Place the wood into the 2×2 grid (your “crafting grid” in your inventory menu and craft 4 wood planks
* Place the 4 wood planks in a 2×2 shape in the crafting grid to make a crafting table
* Rightclick the crafting table for a 3×3 crafting grid to craft more complex things
* Use the crafting guide (book icon) to learn all the possible crafting recipes
* Craft a wooden pickaxe so you can dig stone
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
To learn more about the blocks in MineClone 2, see the Minecraft Wiki for now.
It is planned to eventually add a sophisticated in-game help system.

## Installation
This game requires Minetest 0.4.15 (or later) to run, so you need to install
Minetest first. To install MineClone 2, move this directory into the “games”
directory of your Minetest data directory. Consult the help of Minetest to
learn more.

The logo of MineClone 2 has two grass blocks.

## Completion status
This game is very unfinished at this moment. Expect bugs! Expect chaos
and destruction to rain down on your worlds whenever you update! ;-)

The following main features are available:

* Tools, weapons and armor
* Crafting system: 2×2 grid, crafting table (3×3 grid), furnace, including a crafting guide
* Chests, large chests, ender chests, shulker boxes
* Hunger (incomplete)
* All ores from Minecraft
* Most blocks in the overworld
* Water and lava
* Redstone circuits (partially): Redstone ore, redstone, redstone repeater, levers, buttons, redstone blocks, redstone lamps
* Minecarts (partial)
* Fire
* Buidling blocks: Stairs, slabs, doors, trapdoors, fences, fence gates, walls
* Clock
* Compass
* Sponge
* Slime block (incomplete)
* A variety of flowers
* Dyes
* Deco blocks: Glass, stained glass, glass panes, iron bars, hardened clay (and colors), heads and more
* Item frames
* Jukeboxes
* Beds
* Inventory menu
* Creative inventory
* Farming (needs balancing)
* Bookshelves
* Books (partial)
* More server commands
* 3D torch
* And more!

The following features are incomplete:
* Monsters and NPCs
* Digging times
* Some redstone-related things
* The Nether
* The End
* Enchanting
* Experience
* Status effects
* Brewing, potions, tipped arrows
* Anvil
* Trees, biomes, generated structures
* A couple of non-trivial blocks and items

Additional features:
* Built-in crafting guide which shows you crafting and smelting recipes
* New temporary crafting recipes. For example, you can craft ender pearls (impossible in Minecraft). They only exist to make some otherwise unaccessible items available when you're not in creative mode. These recipes will be removed as development goes on an more features become available

Technical differences from Minecraft:
* Still very, very incomplete and buggy
* Many blocks, items, enemies and other features are missing
* A few items have slightly different names to make them easier to distinguish
* Free software (“free” as in freedom *and* free beer)
* Different music for jukebox
* Different textures (Faithful 1.11)
* Different engine
* Height limit of ca. 31000 blocks
* Horizontal world size is ca. 62000×62000 blocks


## Project description
The main goal of **MineClone 2** is to be a clone of Minecraft and to be released as free software.
The focus on this clone lies especially on gameplay and to reflect it as good as possible.
Ideally, no gameplay features will be added or removed.
A secondary goal is to make modding easy as pie. Minetest is of great help here!
Trying to stay faithful to the original look and feel is a side goal, but not an important one.
If deemed neccessary, MineClone 2 *will* deviate from Minecraft in interface issues.
There's already a built-in crafting guide. And a full-blown in-game help system is a planned
core feature.
Finally, any limitations found in Minetest (the game engine) will be written down in the course
of development.

## Credits
There are so many people to list (sorry).

### Mods
TO BE WRITTEN.

### Special thanks

* daredevils for starting this project
* Tox82, MinetestForFun & Calinou for help in dev
* GravGun & Obani for Help in Build struct
* celeron55 for creating Minetest
* Bob Lennon because it's a pyro-barbare
* Minetest's modding community for providing a huge selection of mods, some of which ended up in MineClone 2
* Jordach for the jukebox music compilation from Big Freaking Dig
* The workaholics who spent hours writing for the Minecraft Wiki. It's an invaluable resource for creating this game
* Notch and Jeb for being the bigg

## Info for programmers
You find interesting and useful infos in API.md.
This project is currently mostly a one-person project.

## Legal information
Copying is an act of love. Please copy and share! <3
But, oh well, if you insist, here is the legalese for you:

### License of source code
MineClone source code:
LGPL v2.1 (daredevils and others) (see LICENSE.txt)

Mods credit:
See README.txt in each mod directory for information about other authors.

### License of media (textures and sounds)
The textures, unless otherwise noted, are taken from the Faithful 1.11 resource pack for Minecraft,
authored by Vattic, xMrVizzy and many others.

Source:
http://www.minecraftforum.net/topic/72747-/

The license of this texture pack is the MIT license.

License of all main menu images: WTFPL

All other files fall under:
Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)
http://creativecommons.org/licenses/by-sa/3.0/

See README.txt in each mod directory for information about other authors.
