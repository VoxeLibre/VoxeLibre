## 0.92 – The Undaunted Release

### Contributors
#### New Developers
* Delta
* CodingMantis

#### New Contributors
* rootkea
* Kaesual
* KutayX7
* jrwyant
* nerdspice
* r888800009
* este
* samir419
* Veselsem
* Cliffordius
* Litanys

### Witches
While keen-eyed players may know that we have had an unfinished mob called a "witch" for quite a time, it was now re-made thanks to work of Herowl, DarkReaven and ralisv. Entirely new graphics, sounds and mechanics are just a hint at what is to come. You can meet them in the wild and specifically on swamps... don't expect them to be friendly, though. Where do they come from? You may soon get to know...

### Scythes
A new tool and weapon in one added thanks to work of Herowl, Chiragon and CodingMantis. When used to cut crops, it hits a 3x3 area of them at once, which makes harvest more efficient... when used in combat it has slightly increased range and damage at the cost of speed. It's not the most powerful weapon, but soon there shall be uncovered unique magic that will show their full potential.

### Wielded lights
An in-house wielded lights system was built by Herowl with some fixes from CodingMantis, entirely different from solutions found elsewhere in Luanti modules. This uses a deeper level API and is in general very efficient, however due to unclear in-engine interactions you may run into terrain loading issues while using this. For that case, there are some new settings (in the main menu or minetest.conf for servers) that allow disabling it or adjusting some values that may improve performance.

### Offhand system
Thanks to changes by CodingMantis and Herowl, *any* item can now be equipped into offhand. For now, items that actually function in offhand are maps, compasses, clocks and all sorts of lights (when wielded lights are enabled, see above).

### Shepherd's Rod of Iron
An iron variant of the Shepherd Staff, Shepherd's Rod of Iron has been added by Herowl. This doesn't make sheep follow you, but instead allows picking specific animals to follow you, similarly to how the hamburger works on the villagers.

### Per-player settings
Per-player settings were added to the dynamic settings window by CodingMantis. These allow players to tune certain quality-of-life features impacting them directly even on servers, like music or inventory management. See below for descriptions of specific features that utilize it. More settings will be added in future releases.

### Music
A lot of new in-game music tracks by DarkReaven and one by Herowl were added, along with music volume rebalancing by Herowl.

Also, a music volume slider was added by Herowl and CodingMantis to the aforementioned brand-new per-player settings window, which allows anyone to tune own music volume independently of other sounds.

Added a /forcemusic debug command by Herowl, which allows forcing a certain track to play immediately (but may be suppressed by the built-in music scheduler).

### Decorations
Another decorative trophy was added by Delta in this update, the Scarab. You can find them in the desert pyramids. More decorations and ways to use them are planned.

More plants can now be placed in flower pots, thanks to CodingMantis.

### Mob improvements
Drops from mobs and after-death spawns now have more consistent timing and always work properly thanks to work of Andro, Herowl and CodingMantis.

Sleeping prevention now depends on mobs being aggro'ed at you instead of just being nearby, which allows you to sleep with monsters on the other side of the wall if they aren't actively looking for you, thanks to Delta.

Rover behavior was massively improved by ralisv. They avoid environmental dangers better and in general behave more logically. Their teleporting chances in various situations were rebalanced.

General mob interactions with environment also got fixes from ralisv. Things like fire and lava work on the whole mob and not just on their feet.

Mobs are also less likely to escape fences, particularly when growing up, thanks to Delta.

Horse feeding was fixed by samir419, and now depletes the food properly and produces a sound.

### Player mechanics
The player respawn system got a bunch of tweaks and fixes by TANGaming. It works better and has new chatcommands: /spawnpoint, /clearspawn and /setworldspawn

Creative mode now by default grants invincibility and lack of monster aggro, thanks to KutayX7. Gamemode code also got refactored and fixed in general, as well as made more configurable through gamerules.

Creative increased range works properly in combat thanks to Herowl.

Shift-clicking in player inventory was reworked by CodingMantis and can now equip armor and can be configured in the aforementioned per-player settings to allow shift-clicking between hotbar and the rest inventory instead of the crafting grid.

Shift-clicking in furnace inventory was also reworked by CodingMantis and can now tell apart fuel from other items.

Crosshair now turns red when the wielded weapon is not ready to strike with its full power yet, thanks to CodingMantis.

A clear inventory button was added to creative mode inventory by Litanys. It has a confirmation pop-up that can be disabled and reenabled in the aforementioned per-player settings.

### In-game release announcements
A system for in-game announcements was added by CodingMantis. It allows mods to register announcements with screenshots and detailed sections.

VoxeLibre makes use of this system for release announcements that inform about important changes of releases. A few example archive announcements were added for the last 3 releases by CodingMantis and Herowl. Making the next announcements will happen as part of the release process.

### Textures update
A bunch of textures were redrawn by Lifora. To accompany this, Herowl made light sensors glow slightly.

### Mobile compatibility
Eating and drinking on touchscreen devices should now work better thanks to Herowl.

### Translation updates
* Added Slovene translation – by Veselsem
* Updated Traditional Chinese translation – by r888800009
* Updated Polish translation – by SecretVoxelPlayer and Herowl

### Other changes
* Fixed rocket arrow crafting – by rootkea
* Fixed player movement bugs related to eating – by Delta
* Fixed berry eating – by Nicu
* Player arrow pickup improved – by ralisv
* Fixed vl_hudbars API proportional hudbar background handling – by Herowl
* Added per-item death drop API – by CodingMantis
* Fixed lookup tool behavior – by KutayX7
* Horse speed is now independent on yaw – by jrwyant
* Documentation updates – by Herowl, samir419, CodingMantis and LinkCodeDev
* Improved minecart positioning on slopes – by nerdspice
* Added smooth item sliding deceleration – by este
* Added item pickup API – by CodingMantis
* Block check fixes – by CodingMantis
* Removed placement rotation from deepslate – by Nicu
* Updated selection boxes of some underworld vegetation – by Nicu
* Buffed ore XP drops – by Nicu
* Fixed vines shearing durability depletion – by Herowl
* Fixed boat oar textures – by Cliffordius
* Added cocoa-bearing trees to bamboo jungle – by Cliffordius
* Rover graphical issue fixed – by Herowl
* Hoe API and crafts fixes – by Herowl
* Made boats slightly more resilient with flowing water – by Herowl
* Fixed book descriptions – by Herowl
* Fixed some log warnings – by Herowl
* Fixed leftover entities after rover despawn – by Herowl

### Crash fixes
* Fixed a rare spawn logging crash – by Kaesual
* Fixed crash when using bone mean in a protected area – by ralisv
* Fixed a rare crash related to potions – by Herowl
* Fixed a rare crash in mob activation code – by Herowl


## 0.92.1 hotfix
* Fixed a falling node crash – by Herowl
