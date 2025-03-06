## 0.88 – The Back on Track release

### Contributors
#### New Developer
* kno10

#### New Contributors
* 0ldude
* tacotexmex
* Pixel-Peter
* OgelGames
* blitzdoughnuts
* goodspeed
* Bloodaxe
* ClementMR
* THE-NERD2
* ethan
* villager8472
* ninjum

### Minecart update
Thanks to enormous efforts of teknomunk, minecart code is rewritten and better than ever! Minecarts that get off the rails behave predictably and can get *back on track*. They can move diagonally on zig-zag rails. Proper physics are employed. Command block minecarts have been added. Code quality is improved and further improvements and additions will be easier and more feasible. Countless bugs have been fixed and carts are finally quite reliable. Make sure to check them out and let us know what you think!

### Mob improvements
Mob AI has been massively improved by kno10, making then less likely to jump down from cliffs, finding paths better and not jumping pointlessly anymore. Door and gate interaction has also been improved. Zombies and skeletons, as undead mobs, don't try to swim and float and rather sink to the bottom of water bodies. Iron Golem attack animation looks better. Stalker textures and camouflage mechanics. Axolotl should attack the correct mobs and shouldn't jump out from the water anymore. Mob head movement (swivel) works better. A bug in the new code has been fixed by rudzik8.

### Mob spawning
Mob spawning space check has been greatly improved by teknomunk, reflecting the actual spatial size of a mob.

Mob spawning direction is now chosen properly and uniformly thanks to kno10, who also improved the spawning code in a few other ways, increasing its performance, and fixed some bugs.

Slime chunks logic has been changed by kno10, making them less predictable without changing frequency. Settings to change the frequency and to enable 3D slime chunks have been added.

### Projectiles update
Projectiles system has been also rewritten by teknomunk with some minor improvements from Herowl, which should improve all projectiles, including all types of arrows, snowballs and other throwables, mob ranged attacks and more, making them work better than before, being more reliable. This also makes it easier for us to add more projectiles and new types of arrows in the future, as well as mods adding such things should be quite simple to make.

On a related note, a bug causing chickens not to spawn from eggs hitting other chickens has been fixed by WillConker.

### Fireworks
Building upon this system, proper firework rockets have been added by Herowl and teknomunk. You can shoot them from the ground by placing them or shoot them in any direction with a dispenser. They're using the new aforementioned Projectiles API.

For now only "empty" and generic random ones are available, but soon more varieties are coming!

### Spears and Hammers
New weapons, spears and hammers, have been added by Herowl and teknomunk.

Spears have slightly less damage than swords, but reach farther and can be thrown (they're also making use of the new Projectiles API!).

Hammers have slightly more damage than swords, are slower, but also can dig various blocks that pickaxe and shovel could also dig, even though they're not as fast as specializes tools. However, they crush some blocks: for example, digging cobblestone with it drops gravel!

### Shield improvements
Shields are now more reliable and shouldn't cause any issues when interacting with containers or blocking arrows, all thanks to fixes from Loveaabb, rudzik8 and ryvnf.

### Mapgen
Mapgen code has been severely improved by kno10, fixing bugs and improving performance. Beyond that, it is now easier to handle, which will help us finally make a larger update to the mapgen. The Rail Corridor structures should now have more types of minecarts, including chest minecarts with loot.

Also a bug that caused some loot to not appear in some structures has been fixed by WillConker.

### Plant improvements
An update to the bonemeal API has been conducted by teknomunk, based on old code by kabou. Multiple bugs have been fixed. Plants work more consistently, and some more features of the WorldEdit mod are supported now.

Cane and bamboo no longer get broken by world loading thanks to teknomunk.

Plant growth code has been refactored, optimized and cleaned up by kno10. Various issues have been fixed. Cactus damage works better, its drops are now more reliable, generation is improved and dropping at mapgen fixed. Growth rate of various plants has been reduced. Plant growth rate now depends on its surroundings, you should mix different crops (eg. in rows). Plant response to hydration is improved. Nether fungi can now use any of the schematics when grown, instead of just one variant.

### Weather
Sky color handling works better now due to rework conducted by teknomunk. Some bugs have been fixed. Lightning won't strike where there is no rain.

Mobs interacting with weather do so more predictably, namely undead burning and Rover rain damage got some bug fixes from seventeenthShulker and teknomunk.

### Chest API
Chest code got refactored by rudzik8 and its API got exposed, making it easier for mods to add chest variants. Some bugs have been fixed, including chests turning invisible, and shulker boxes can now be rotated.

### TNT collision
TNT doesn't collide with entities anymore thanks to WillConker. While it isn't a big change, it's quite important, because it makes many TNT cannons viable. Bigger designs may still not work, because TNT is still stopped by unloaded chunks.

### Water freezing
Water freezing has been ported from Mineclonia (cora's solution) by WillConker, also fixing some minor issues in it.

### New blocks
Charcoal blocks have been added by blitzdoughnuts – similar to coal blocks, different in texture and material.

Grey sand blocks have been added by Herowl. For now you obtain them by crushing gravel with a hammer and they can be used in most generic sand recipes (like glass smelting), but in the future they will also appear in world generation.

### Map colors and tools
Map (from the map item) colors have been improved by kno10, who also added to the game some tools that make handling these easier.

### New Translations
* Italian by 0ldude
* Norwegian Bokmål by Bloodaxe
* Chinese simplified by ethan

### Translation updates
* German by kno10, Pixel-Peter, Laudrin and chmodsayshello
* Polish by Herowl
* Translation files updates by kno10, teknomunk, Bloodaxe and ClementMR
* Automatic translation file update tools inclusion and improvements by kno10

### Other changes
* Improved pumpkin descriptions – by SmokeyDope
* Hardness and blast resistance fixes – by seventeenthShulker
* XP orbs made persistent – by teknomunk
* Slab placement improvements – by JoseDouglas26
* Piglin brute fire immunity removed – by JoseDouglas26 and WillConker
* Enchantment movement speed boost calculation improvements - by WillConker
* Kelp growth water interaction bug fixed – by WillConker and cora
* Dragon regeneration slowed – by WillConker
* Minor settings fixes – by kno10
* Bed bounciness made more consistent – by kno10
* Removed a mobspawner warning – by WillConker
* Made item code more robust (prevents possible duplication bugs) – by OgelGames
* Mod load order fixes – by SmallJoker, teknomunk and rudzik8
* Horse riding bug fixed – by THE-NERD2
* Fixed crying obsidian particles – by kno10
* Stairs graphical bug fixed – by rudzik8
* Snow accumulation fixes – by goodspeed
* Fortune drops fixes – by JoseDouglas26
* Ladder placement fixes – by goodspeed
* Disabled absorption bar with damage disabled – by goodspeed
* Refactored head block code and fixed Stalker head conversion – by goodspeed and rudzik8
* Soul speed works with soul soil – by seventeenthShulker
* Fixed structure spawns not working in some cases – by kno10
* Added witch huts and some fish mobs to the rivers in Valleys mapgen – by kno10
* Fixed honeycomb block interaction – by teknomunk
* Fixed cauldron interaction – by teknomunk
* Fixed random number usage – by kno10
* Fixed a minor texture generation bug – by kno10
* Fixed bug allowing infinite cactus production – by rudzik8
* Fixed deepslate copper ore – by kno10
* Fixed meta string clearing – by rudzik8
* Removed bamboo double drop – by rudzik8
* Changed bamboo cap drawtype – by Herowl
* Fixed smithing table protection checks – by rudzik8 and cora
* Touchscreen fixes – by grorp
* Fixed experience requirements in creative mode – by THE-NERD2
* Fixed elytra enchantability – by THE-NERD2
* Stair placement improvements – by THE-NERD2
* Fixed a bug in the gamemode API – AFCMS
* Enabled craft guide for furnaces – by kno10
* Negative enchantment levels are treated as invalid now – by rudzik8
* Fixed hoglin drops – by villager8472
* Made screwdriver available in creative menu – by kno10
* Mending mends unbreaking items more – by Herowl
* Potions now appear properly in the search menu in the creative mode – by Herowl
* Utilize new Luanti bone APIs – by kno10
* Fix trees being cut in half by cavegen – by kno10
* Save world creation game version in the world – by kno10
* Fixed minor definition bugs concerning lighting – adapted from MCLA (goblin_mode)
* Optimized crying obsidian particles creation – by kno10
* Stonecutter GUI background texture – by SmokeyDope
* Documentation fixes – by tacotexmex, rudzik8, teknomunk, Nicu

### Special thanks
* To kno10, for refactoring many areas of code, fixing things nobody wanted to touch and in-depth reviews and testing.

### Crash fixes
* Fixed crash related to explosions and chests – by kno10
* Fixed crash related to effects that could happen with damage disabled – by goodspeed
* Fixed a very rare crash related to unknown items – by kno10
* Fixed unknown items related crash – by teknomunk
* Fixed a potential mob-related crash – by Herowl and kno10
* Fixed rare crashes related to dispensers/droppers interacting with unknown nodes – by rudzik8

## 0.88.1 hotfix
* Added Galician translation – by ninjum
* Updated translation files – by kno10
* Fixed a bug that derailed carts in some cases – by teknomunk
* Changed cart dismount to behind the cart – by teknomunk
* Mob movement logging disabled by default – by teknomunk
* Added map colors for new nodes – by kno10
* Fixed minor code quality issues – by kno10, rudzik8 and teknomunk
* Fixed bobber and throwables collision issues – by teknomunk
* Meshes for cocoa pods used properly – by rudzik8
* Fixed jockey mob spawn check – by rudzik8
* Added a cooldown for droppers and dispensers – by kno10
* Fixed node interaction with firework rocket in hand – by rudzik8
* Fixed bugs related to bonemealing sweetberry (including a crash) – by teknomunk
* Fixed a rare crash related to TNT minecarts – by teknomunk
* Fixed a fishing pole casting crash – by teknomunk
* Fixed a crash related to rocket usage – by teknomunk
* Fixed a crash related to ender pearls – by teonomunk
* Fixed a rare crash relates to droppers – by rudzik8
* Fixed a bug related to minecarts that may destroy items in transfer in rare cases – by teknomumk
* Fixed a crash when trying to strip hollow logs – by rudzik8
