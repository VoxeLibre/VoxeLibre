## 0.89 – The On Display release

### Contributors
#### New Contributors
* OpenSauce04
* grillo-delmal
* Yoric
* potatoalienof13

### Map item expansion
Map items finally can be zoomed-out with the cartographer table, thanks to work of kno10, mirqf, AFCMS. Further fixes improvements to the system have been carried out by teknomunk and rudzik8. Map graphics when it is held in hand are now better thanks to work of rudzik8 and erle.

### Mob spawning
The system of mob spawns got another large batch of improvements by teknomunk and kno10. It should work better, more reliably and more efficiently.

### Structure generation
...is now finally more deterministic, thanks to kno10. This means that a new world generated with the same mapgen and field now should look way more similar, especially in terms of structures. Future mapgen changes will obviously still change the way the world looks, but on the same version, it should be actually predictable.

### Sitting and more
The well-known `mcl_cozy` mod has been integrated into the base game by its author, rudzik8. Now you will be able to sit on stairs, slabs and blocks from mods supporting this feature (like chairs), and sit and lay anywhere with commands.

### Node reworks
Signs got a grand rework by rudzik8 with assist of kno10, building upon work of cora, ryvnf, j-r, ellesheepy and goblin_mode. Now there's a partial UTF-8 support (Latin diacritics, Greek and Cyrillic), sign cleaning and other features, on top of more reliability!

A new climbable hollow logs' variant with a ladder inside was added by Herowl, along with improvements to the hollow logs' code.

Item frames got a large update by rudzik8, based on work of cora and Freedom, making them placeable on floors and ceilings, as well as adding new invisible frames to the creative menu.

Tree growth code has been improved by kno10 and rudzik8, making tree growth a bit slower and more uniform.

### Textures improvements
* Stone and wooden hoe textures improvements – by kno10
* Cherry leaves, wood and some other items made from it got their textures remastered – by rudzik8 and NovaWostra
* Hammer textures improvements – by rudzik8
* Redstone dust updated – by SmokeyDope
* Hollow oak log texture fixed – by kno10
* Spider, squid and chicken got better textures – by XSSheep and rudzik8
* Raw ore items tweaks and crystalline drop rework – by rudzik8

### Sounds improvements
* Sound volume adjustments – by ryvnf and rudzik8
* Scaffolding placement sounds – by SmokeyDope
* Bamboo placement and digging sounds – by SmokeyDope
* More sheep, skeleton and iron golem sounds, along with sound usage fixes – by SmokeyDope
* Sheep grazing sound volume increased – by Nicu

### Performance optimizations
Lightning attractor search has been optimized by teknomunk, which should decrease lag during thunderstorms if you were experiencing it.

Complex player spawn position search code removed by kno10, because it caused unnecessary load and lag on certain seeds. Based on cora's work.

Floating kelp appearing in water during generation has been fixed by teknomunk and kno10. The amount of dropped items would severely hamper performance, now it works properly at last!

Various code related to mapgen and node manipulation improved by kno10. It may not bring significant performance improvements, but it should get easier to further work with.

LuaJIT parameters setting and an optional core function extraction optimization (*requires `vl_trusted` being set as a trusted mod*) conducted by kno10.

New hashing functions have been added by kno10, along with improvements to how randomness is being used and how seeds and UUIDs are being generated. It should be more robust, even if performance gains aren't noticed.

### Bone overrides
Bone control code, which had workarounds incompatible with 5.11+ Luanti versions that would cause weird model poses, has been improved and cleaned up by appgurueu, rudzik8 and teknomunk.

### Translation updates
* Polish by Herowl
* German by kno10 and Herowl
* Translation file fixes by kno10

### Other changes
* Blocks from mods are now properly destructible – by teknomunk
* Inventory player model is now always standing – by kno10
* Improved steps sound on grass – by OpenSauce04
* Added a setting to control Christmastide decorations – by rudzik8
* Documentation updates – by rudzik8 and kno10
* Fixed a spear duplication bug – by teknomunk
* Fixed hopper minecart interaction with large chests – by teknomunk
* Fixed bow and spear being used when interacting with a node – by grillo-delmal
* Fixed uphill minecart acceleration – by rdeforest and teknomunk
* Portal code cleanup – by kno10
* Removed the possibility to trigger pressure plates by clicking on them – by Yoric
* Fixed kelp base (ocean floor) passing light through – by kno10
* Playerphysics module – by Wuzzy – has been updated (changes pulled by rudzik8)
* Minor layered snow fix – by kno10
* Fixed minecarts being placeable mid-air – by teknomunk
* Fixed piston interaction with rails – by teknomunk
* Minor mob pathfinding fix – by kno10
* In-game documentation display improvements – by kno10
* Removed unnecessary mob jumping on breeding – by kno10
* Decreased log spam – by teknomunk and rudzik8
* Fixed sheep head position – by Nicu
* Fixed some deepslate crafting recipes – by teknomunk
* Fixed bonemeal interaction with netherrack – by teknomunk
* Fixed shield blocking not working properly – by rudzik8
* Fixed shroomlights' generation – by kno10
* Unnecessary grass block overlay removed – by kno10
* Knockback and critical hit issues fixed – by potatoalienof13
* Ancient debris generates more often now – by kno10
* Fixed chest animation and code improved – by rudzik8
* Removed unused files – by rudzik8
* Correct invisibility handling – by Herowl

### Crash fixes
* Extremely rare crashes related to minecarts and boats – by teknomunk
* Fixed a crash with the Skyblock mod installed – by teknomunk


## 0.89.1 hotfix
* Moved some properties from mob definition to initial_properties (fixes some bugs and warning spam) – by teknomunk and Impulse
* Minor structure fixes – by kno10
* Improvements to mcl_cozy, disabled stair and slab interaction by default – by rudzik8
* Fixed seagrass floor passing light – by kno10
* Improved fallen log and lake generation – by kno10
* Guard against horse texture-related crash – by teknomunk
* Fixed liquids being diggable in some cases – by teknomunk
* Fixed legacy mob conversion-related crash – by teknomunk
* Fixed wrong Luanti sound API usage in sheep code – by rudzik8
* Localized some functions (fixes an item duplication bug) – by teknomunk
* Fixed incompatibility with PUC Lua (non-JIT crashed) – by kno10
* Fixed an infinite loop causing a rare freeze – by kno10
* Fixed item aliases being registered after game start – by teknomunk
* Made zombie hitbox slightly taller (allows some mob spawning filters) – by Nicu

## 0.89.2 hotfix
* Made flowers buildable to – rudzik8
* Fixed some logged warnings – by teknomunk
* Fixed bitmask meaning – by kno10
* Copy potion legacy shim item defs properly – by teknomunk
* Removed a nonexistant item from loot lists – by kno10
* Forced saving minecart inventories in some cases – by teknomunk
* Fixed node interaction (including a duplication bug) – by teknomunk
* Fixed weather particles – by teknomunk
* Fixed exposed bedrock bug – by kno10
* Offset most structures y+1 – by kno10
* Prevent teleportation into void – by Herowl
* Fixed crash related to cartography table – by teknomunk
* Fixed a mapgen crash on 5.9 – by teknomunk
* Fixed a rare kelp related crash – by teknomunk
* Fixed a snowman related crash – by teknomunk
* Fixed a boss related crash – by kno10

## 0.89.3 patch
* Fixed infested blocks not using spawning API properly – by teknomunk
* Fixed XP magnet malfunctioning – by teknomunk
* Fixed one letter signs not working – by kno10
* Fixed undefined variable regression – by teknomunk
* Fixed a few bugs in cartography table interface, including a crash – by teknomunk and Herowl

## 0.89.4 hotfix
* Fixed a crash occuring with new Luanti 5.12.0 release – by teknomunk
