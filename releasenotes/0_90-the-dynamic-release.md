## 0.90 – The Dynamic Release

### Contributors
#### New Contributors
* HalfShadow111
* cyberonkel
* oku
* fancyfinn9
* Chiragon
* Archie
* newrizen
* wrrrzr
* antimundo

### Dynamic settings
A new dynamic settings and game rules tuning system has been built by teknomunk with some fixes from Herowl, allowing you (as long as you have the "server" privilege) to change various aspects of the game while playing, both with commands and from a handy GUI accessible from inventory (when you have the privilege). Now that the system is up, you can expect more settings and rules to come in future updates!

Similar changes have been conducted by Archie in the hunger system, allowing it to be enabled and disabled on the fly with commands. Likewise, you can enable and disable the debug hunger HUD, which displays saturation and exhaustion bars.

In the same spirit, the /gamemode command now accepts mode abbreviations (eg. /gamemode s, /gamemode surv), and the /effect command now can have any player target (name appended to the end), thanks to changes by Herowl with a minor fix by wrrrzr.

### Enchantment-item compatiblity
More items can be enchanted with more enchantments now. In particular, axes, hammers and spears are compatible with more combat enchantments, hammers can have efficiency and crossbows can have unbreaking, thanks to Herowl and seventeenthShulker.

### Deepslate tools
...have been created by kno10, further rebalanced and refactored by Michieal. They are enchanted on craft with a 50% chance with a random common level 1 enchantment, thanks to work of Herowl. You can combine them on an anvil to get stronger tools, but in this case, the enchantments won't reach level higher than 2.

### Armor rebalancing
That's not the end of the new gear you will be able to craft. Thanks to changes by Herowl, chainmail armor is now craftable from chains, which are also crafted now in batches of 2 to make it worth using – which will probably also come in handy when building. Iron armor durability has been increased as well. All metallic armor when smelted gives more (usually a lot more) of the metal back, depending on remaining durability, up to 75% of material required to craft it. Rabbit hide has been renamed to Leather piece, which can be crafted back from leather in batch of 4, and is now the ingredient to craft leather armor, which is thus cheaper and worth the while. Besides, now mobs that pick up armor from the ground (eg. your armor when you die) will drop it back when you kill them, and will render properly even if the armor was enchanted.

### Golden decorations
The above is not the end of new chain goodies: thanks to TomCon, we now have golden chains too. These can't be used for armor crafting, but they are an interesting decoration. There are some other new decorative golden blocks too, including gold bars – see them all yourself! A small fix to these got applied by teknomunk.

### Creative inventory re-sorted
Thanks to work of TomCon with further tweaks by teknomunk and Herowl, creative inventory item order makes more sense now, and you should be able to find most popular items easily without using the search bar.

### Fire spreading rework
A new system of fire spreading has been created by teknomunk. Now fire spreading is slightly more predictable and a single starting point can't burn too large an area – although they can still go quite far.

### Elementals teaser
Speaking of fire, we now have Fire Elementals (formerly known as Blazes). Their behavior was also improved. This rework conducted by Herowl is an introduction to a full new class of mobs. Expect new elemental mobs in the upcoming releases.

### Effect source items
The suspicious stews' API was reworked by WillConker, who also added some new stews. The changes were further adopted, expanded, refactored and got bug fixes by Herowl, who also increased duration of some effects from stews to make them more viable.

Also, Herowl increased duration and power of some potions and made all potions stackable up to 16, in order to make them more useful. Brewing stand works better now as well, thanks to changes by Herowl and teknomunk.

### Combat rebalancing
The above changes in potions and stews apply to combat as well, but that's not all. Strays have been nerfed, and their frost effect lasts only about 5 seconds. Knockback against mobs works better now, wither works properly again, explosions damage mobs and criticals work too, thanks to changes by Herowl with some fixes from teknomunk.

Spawning system has been rebalanced by teknomunk, which should guarantee a more refined PvE experience with less explosive player deaths.

Ghast has been reworked by Herowl, with new model and texture, new ghast fireball texture, improved ghast (and fireball) visibility in darkness, and improved ghast behavior, involving avoiding the player more.

### Texture changes
* New stone tools textures – by Chiragon
* New campfire model and texture – by Chiragon
* New skeleton texture – by XSSheep, inc. by Herowl
* New wither skeleton texture, based on the new skeleton texture – by Herowl

### Translation updates
* Translation markers in scripts improved – by Sab Pyrope
* Updated translation files – by Herowl
* Updated Polish translation – by Herowl
* Updated Chinese translation – by HalfShadow111
* Updated Brazilian Portuguese translation – by newrizen
* Updated Spanish translation – by antimundo
* Updated Norwegian Bokmål translation – by Bloodaxe

### Other changes
* Removed mgv6 support which didn't work anymore anyway – by kno10
* Updated alpha modes API usage – by teknomunk
* Improved map version checks – by kno10
* Added more special sheep names – by TomCon
* Clearer errors when libraries used by texture converter tool are missing – by Nicu
* Minor documentation updates – by Herowl and TomCon
* Conversion of legacy item entities added – by teknomunk
* Bamboo blocks can now be made into charcoal – by TomCon
* Fixed glowing squids not spawning – by cyberonkel
* Minor ladder fixes – by teknomunk
* Fixed item duplication bug – by oku
* Minor map version checks' fixes – by Herowl
* Fixed end portal frames being breakable in survival – by teknomunk
* Village creation tool is now always available in creative mode – by teknomunk
* Fixed spear texture not showing when thrown – by fancyfinn9
* Fixed adding more capes not working – by fancyfinn9
* Fixed some warnings with newer Luanti versions – by teknomunk and Herowl
* Fixed projectiles not sticking to blocks – by teknomunk
* Fixed dragon flying away – by TomCon
* Fixed numerous issues related to haste and haste-like effects – by Herowl
* Increased knockback against mobs – by Herowl
* Disabled mobs opening gates, added a setting to allow enabling it – by Herowl
* Fixed edible items working improperly with damage disabled – by Archie
* Added more dye recipes and removed legacy dye conversion recipes – by Herowl
* Fixed chorus fruit teleportation not working in survival mode – by TomCon
* Fixed attack range being vastly miscalculated – by Herowl
* Fixed a rare bug with entities not getting removed when dead –by teknomunk
* Fixed tooltips not being loaded in some cases – by Herowl
* Updated findbiome module – by Skivling, including changes by himself, and by Wuzzy, Jacob Lifshay, GLOCKrzmitz, and SkyBuilder1717
* Fixed campfire timer restarting – by Herowl
* Enforced proper mob API usage with an assertion – by Herowl
* Added underworld vine growth – by Herowl
* Improved sheep colors – by Herowl
* Added a defensive check (may fix some extremely rare crashes) – by Herowl
* Allow players to sleep slightly earlier – by Herowl
* Fixed some log warnings – by Nicu

### Crash fixes
* Fixed a crash when entering a world with corrupted entities – by teknomunk
* Fixed a rare crash and a few related bugs when placing underworld vines – by teknomunk
