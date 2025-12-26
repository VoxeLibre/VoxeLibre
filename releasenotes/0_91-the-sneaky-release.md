## 0.90 – The Sneaky Release

### Contributors
#### New Developers
* Archie / andro
* ralisv

#### New Contributors
* WolfySoy
* sled314
* Skivling
* Delta
* TANGaming
* SecretVoxelPlayer
* olivia-may

### Tridents
After a long time of work, they are finally here thanks to Tuxilio, Herowl and epCode. They are a special powerful spear with custom model when thrown and fly underwater as well as in the air. For now they can be found as rare loot in some structures, but the future will bring more ways to obtain them. Rumors also say potent magic is contained in these weapons, and you might be able to unleash it one day...

### Enchantments changes
Swift sneak was added by WillConker and Herowl, and can be applied to leggings to increase movement speed when sneaking.

Impaling was added by Herowl, and can be applied to tridents. It increases damage dealt to water creatures.

Bane of Arthropods was fixed by Herowl and now it works properly.

### Decorations
A new decorative trophy, the decorative star, has been added by Herowl. Craftable from glowstone and a nether star, can light your hall and top a tree!

### Sounds
Environmental sounds of water and lava were added by TomCon. Now you can detect the proximity of lava and flowing water by their sounds.

Fire extinguishing and sculk sounds were fixed by TANGaming.

Eating sound was quietened by Delta.

Music fading and handling was improved by Delta.

A cave sounds system was added by Delta, playing ambient sounds when spending time underground in darkness.

### Horse armor changes
Leather horse armor was added by WolfySoy and TomCon and was accompanied by some rebalancing to horse armor in general. Now you can armor a horse even when you're out of the more expensive materials!

### Mob changes
Thanks to changes by teknomunk, mobs that die when not fighting a player will not drop experience and will not drop some items. This reduces the amount of drops appearing in detached places without player knowledge, which decreases lag.

Chickens were improved by andro, now their jumping works and looks better.

Stalkers also got improvements and refactoring by andro. Now you can get music discs by having skeletons kill them, and their look now properly reflects their state. Explosions of overloaded ones now guarantee head drops. Thanks to Herowl they also flee from felines properly.

Sheep now are properly afraid of wolves, and so are rabbits (which are now also attacked by wolves) and all sorts of skeletons – all thanks to changes by Herowl and Nicu.

Mobs that are supposed to shake now do so properly thanks to Herowl, who also fixed a few bugs that caused despawning of mobs that should not despawn.

Mob vision system got improved by ralisv, rebalancing monsters chasing player and fixing them seeing through walls.

Mobs now spawn properly in bamboo jungle variants thanks to Nicu.

Code related to mob activation (chunk reloading) was improved by Herowl, which fixes mob interactions with potion effects and potentially other bugs.

Mob spawn eggs now work better and can be used in more places, thanks to andro too.

Mob spawners set to mobs that should spawn in liquids (spawners like that don't exist naturally yet) now work properly thanks to ralisv.

### Hudbars update
Hudbars system was reworked by WillConker and Herowl, which makes them work and look better in general, along with improved API for mods and future changes and other fixes under the hood.

### Farming refactor
Refactoring of some modules centered on the farming system was conducted by sled314. Hoes got also rebalanced, and their speed and melee damage is now higher.

### Mobile compatibility
Shields can now be used with zoom key too, thanks to Herowl, to support their usage with touchscreens.

### Translation updates
* Updated Brazilian Portuguese translation – by newrizen
* Updated Galician translation – by ninjum
* Updated French translation – by syl
* Updated Polish translation – by Herowl

### Other changes
* Fixed handling of crafting result on inventory close and death – by farfind
* Fixed a broken part of awards API – by Skivling
* Fixed fish buckets bypassing protection – by andro
* Fixed liquid buckets range – by andro
* Fixed texture alpha usage definitions – by Nicu
* Fixed campfires not being extinguished by water – by andro
* Added sculk spreading game rule – by TANGaming
* Fixed recovery compass recipe – by fancyfinn9
* Fixed campfires failing after world reload – by andro
* Fixed item frames glitching and destroying items when supporting block is broken – by andro
* Water bottles fixes – by Herowl and ralisv
* Fixed shulker boxes not dropping in creative mode – by andro
* Fixed piston pushed being diggable – by teknomunk
* Fixed some startup warnings – by teknomunk
* Crossbows can now be burnt in furnaces – by SecretVoxelPlayer
* Improved cactus damage mechanics – by Delta
* Fixed dogs taking fall damage when teleporting – by Delta
* Darkened view when GUI is open – by andro
* Improved lodestone tooltip and help – by Delta
* Fixed itemframe screwdriver interaction – by Michieal
* Reverted lakes to regular water – by Nicu
* Buffed sweet berries – by Nicu
* Fixed smithing table iten recognition – by ralisv
* Fixed gateway portal and pearl interaction – by ralisv
* Exposed some bucket handling functions as API – by olivia-may
* Fixed /effect command rejecting some valid input – by Herowl

### Crash fixes
* Fixed a crash when shooting TNT with a flaming projectile – by Herowl
* Fixed a few rare crashes related to campfires – by andro
* Fixed a crash when throwing a broken spear – by TANGaming
* Fixed crashes when entering world with Luanti version without JIT – by teknomunk
* Fixed a crash when disabling some mods – by teknomunk
* Fixed a crash during combat with infinite-power attack speed effects (like haste) – by Herowl


## 0.91.1 hotfix
* Fixed a crash when punching mobs – by Herowl
* Fixed an undeclared variable warning – by Herowl
