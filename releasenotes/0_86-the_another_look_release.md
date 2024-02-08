## 0.86 – The Another Look release

### Contributors
#### New contributors
* JoseDouglas26
* Zasco

### FOV API
Field of Vision control now goes through a new API using a modifier system, made by Michieal and Herowl. With these changes, sprint, bow drawing and spyglass should alter the FOV properly, as well as take into account the FOV set in Minetest settings. This also paves the way to more mechanics changing FOV in future updates.

### Mob improvements
Shulker received an update by Bakawun (pulling some of the Mineclonia changes by cora). Animation usage got some fixes, and bullets are now slower but homing. Also it's fire rate is now variable.

With the shulker update, other mobs (including those from mods) can now have homing bullets added with ease, as well as do custom things after each attack (like change the fire rate, which shulker now does).

Slimes and Magma Cubes got rebalanced by Herowl, to make them work better with the player attack reach changes from the previous update (0.85 – Fire and Stone).

Vexes and Evokers got some changes and fixes by Herowl to make them more manageable to fight while still being formidable enemies.

### Shepherd functionality
A shepherd staff was added by Herowl, which allows you to lead your sheep without the risk of them eating the item you're luring them with. It can also serve as a weak weapon (to defend your sheep, of course). You can now collect sheep easier while travelling. Remember to take care of your sheep, also at night, and especially during the Christmastide. Speaking of Christmas, I've heard something changed about the moon. If you have trouble noticing that, maybe use the dedicated tools to take a closer look up.

### Sunflower update
Sunflower now has a custom mesh by JoseDouglas26 (with minor tweaks from Herowl), which means it looks better and is oriented towards East properly. Thanks to the changes, it is also easier to make more mesh-based tall flowers in the future.

### Animation updates
Animations of Stonecutter and Campfires were made more dynamic by Wbjitscool.

### Mapgen settings
The setting disabling deepslate generation now works properly thanks to Zasco.

### Translation updates
* Spanish by megustanlosfrijoles
* Brazilian Portuguese by JoseDouglas26
* Syntax fixes in various translation-related files by megustanlosfrijoles

### Crash fixes
* Villager trading UI crash by JoseDouglas26
* Piston related crash by cora

## 0.86.1 hotfix
* Implemented a fix to a graphical glitch regression introduced in release 0.86, which had been fixed but wasn't loaded into the tag.
* Added a workaround to enable mobile players to use bows, crossbows and spyglasses by using zoom key (they can't *hold* `place`).
(both fixes by Herowl)

## 0.86.2 hotfix
* Implemented refactorization of player-related combat code by Eliy21. This fixes a critical bug which can cause players to become invulnerable indefinitely.
* Optimized some textures for size.
* Fixed XP orbs breaking randomly (by Herowl).
* Fixed a cryptic error message (by Herowl).
