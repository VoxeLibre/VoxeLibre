## 0.87 – The Prismatic release

### Contributors
#### New Developers
* rudzik8
* teknomunk

#### New Contributors
* PrWalterB
* michaljmalinowski
* nixnoxus
* Potiron
* Tuxilio
* Impulse
* Doods
* SOS-Games
* Bram
* qoheniac
* WillConker

### Game rename
Based on months of collecting suggestions, analysis and vetting of possible names, community voting and discussion between developers, the rename of the game has reached its conclusion! The project has been renamed to **VoxeLibre**.

Along with this, a documentation update has been conducted by Herowl, teknomunk and rudzik8. Make sure to check out the updated Contributing Guidelines!

### Potions and Effects redo
After more than half a year of work, it is finally here! The whole system has been rewritten from the ground up by Herowl. New effects, potions and brewing recipes have been added. Potion tooltips have been reworked. In the HUD you can now see more information about what effects you have at the moment, including level and duration. Beacon has also received more effects and is now quite functional.

A few new items to be used as brewing ingredients have been added. For now you can obtain them from fishing and trading with villagers. Those items will be made obtainable from other sources and will get more uses, hopefully in the next release. The functionality of some effects is not complete and they are also not obtainable yet (hero of the village and conduit power).

Some of the old potions and tipped arrows don't work with the new API and have to be converted. To avoid constant rechecking of all inventories, they have been bound to placeholder definitions. What this means is that if you notice weird potions or arrows marked with question marks, you will have to right-click them to run the conversion. A small price to pay for less lag, right?

Improved support of mobs by the effects and potions, including effects being properly saved on mobs. Despite that, some effects still don't work with mobs, because the mobs' code doesn't support them properly:

* the following effects don't work with mobs at all: water breathing, dolphin's grace, leaping, swiftness, slowness, slow falling, night vision, darkness, frost, health boost, absorption, fire resistance, resistance, luck, bad luck, blindness, nausea, food poisoning, saturation, haste, fatigue, conduit power
* the following effects should work with mobs: invisibility, regeneration, poison, withering, strength, weakness, levitation, glowing
* the following effects have no effect on mobs (but can be applied with the API): bad omen, hero of the village

While not everything is available in game, a great API (documented in the module) has been exposed for modders, allowing adding new effects and potions. Potions can now have all sorts of custom effects and multiple effects at once. Effects and potions can now have indefinitely many levels and potentially infinite duration, available with the `/effect` command and the modding API. Effects can still (and even more so than before!) be fine-tuned with factors and abnormal levels, which can sometimes give unexpected results, but it's all left up to modders.

### Nether Portals rewrite
Another large rework! Thanks to emptyshore, portals to (and from) the Nether now work better than ever, connecting properly to each other. They shouldn't cause unwelcome surprises either, stranding you where you never expected to go, and shouldn't teleport you up into the skies.

### Mob spawning system
An update by Bakawun improved the mob spawning, optimizing it and making the randomness work better, as well as properly taking into account set spawn chances. This update also changed the mob spawn chances and ratios.

Another improvement to the system was made by teknomunk, who wrote a new system for spawn position calculation. This enables overhead spawning, among other things allowing for some mob farms to work.

Also, light and height checking of Slimes has been fixed by Codiac, so they should no longer spawn in large numbers in inappropriate places.

### Mob improvements
Not only did mob spawning get improved, but mobs themselves did too.

Rover is a new mob, replacing the enderman. Along with this rework by Herowl and teknomunk, node picking code was refactored and generalized, paving the way for more mobs visibly holding actual items in the future.

Stalker is another new mob, replacing the creeper. This rework completed by Herowl contains a new camouflage mechanic and otherwise a new look at a well-known concept.

Ghast received a great update by Bakawun and Herowl. Its hitbox should now work properly, and deflecting the fireballs should work properly again too. Also the achievement for killing a Ghast with a ghast fireball should now be granted properly.

Sounds for Hoglin/Zoglin, Piglin and skeletons have been updated by Bakawun and should now be used properly.

Strider received a few fixes by nixnoxus. Breeding, attracting and riding should now work.

### Eating animation
Eating is no longer instant in survival mode, but delayed instead with the new system designed by Eliy21.

To signify it properly, Herowl added an animation visible in the first-person mode.

### New blocks
* Colored End Rod variants by Herowl.
* Colored Redstone Lamps by Herowl.
* Glazed Terracotta Pillars by Potiron.
* Compressed Cobblestone by SmokeyDope.
* Clovers and Four-leaf Clovers by Herowl.
* Hollow logs by JoseDouglas26 and Herowl

### Capes
Thanks to the changes by chmodsayshello and rudzik8, you can now pick a cape in the character skin customization UI. Thanks for the "Minetest" cape texture to QwertyDragon.

### Colored leather armor
Leather armor can now be colored (and washed) thanks to AFCMS and Herowl. Aside of the crafting recipes, this added a command and a modding API for this.

### Cherry blossom particles
The particles of the cherry blossom, which fall from the cherry leaves, have been vastly improved by Wbjitscool and Herowl. Plant some cherry trees and behold the new animation and the wind direction changing 3 times a game day.

### Signs text editing
Now you can edit the text on signs by right-clicking ("place") on a sign placed in the world, all thanks to Araca.

### Tool durability tooltips
Yet another feature from Araca, tooltips for tools (and weapons) will now display how much durability they have remaining. Now you have more precise info than just the wearbar!

### Creative inventory fixes
Items can't be moved around in the creative inventory, tabs there have proper tooltips and searching works on Android with Minetest 5.8+ – all thanks to rudzik8.

### Help UI – Mobs section
A "Mobs" section added to the Help UI by SOS-Games. Translations may be missing.

### Texture pack converter
One of our tools, the Python script allowing conversion of Minecraft resource packs (texture-wise) to the Minetest format to work with our game, has received a great update by Impulse and Doods. It should now work with packs from newer versions, but keep in mind that not everything can be automated and the packs may still require some manual fixes (and additions, if you want to cover all of our own features that have no equivalents in Minecraft).

### New Translation
* Occitan by PrWalterB

### Translation updates
* Spanish by megustanlosfrijoles
* French by syl
* Polish by Herowl
* German by Tuxilio, Herowl and qoheniac
* Syntax fixes in translation files by megustanlosfrijoles

### Other changes
* Melon and pumpkin generation – by michaljmalinowski
* Golden rails accelerate carts properly – by nixnoxus
* Elytra Animation works again – by MrRar
* Mobs aggro disabled when damage is disabled – by emptyshore
* Fortune enchantment on hoes works – by JoseDouglas26
* Typo in pumpkin.lua fixed – by SmokeyDope
* Node rotation at placement improvements – by JoseDouglas26
* Nylium reverting to netherrack – by JoseDouglas26
* Hunger debug setting exposed properly – by SmokeyDope
* Nether vine placement fixes – by SmokeyDope
* Survival inventory tabs API fixes – by Impulse
* Cactus damaging mobs – by Eliy21
* Sweet berry bush slowdown decreased – by Eliy21
* Fixed scaffolding placement replacing other blocks without a trace – by JoseDouglas26
* Nodes fireproofing and missing plank recipes added – by Doods
* End Rods now use a proper mesh model – by Herowl
* Piglin bartering improvements – by nixnoxus
* Hopper item movement improved – by teknomunk
* Partial item stack pickup – by teknomunk
* Bone meal node protection check – by CyberMango
* Undeclared variable usage fixed – by nixnoxus
* Biome check when spawning override (API, Skyblock support) – by AncientMariner
* Reimported tga_encoder as subtree (this allows support of some mods) – by Herowl
* Bed placement and destruction fixes – by teknomunk
* Item tooltip shouldn't be modified needlessly (this fixes some bugs causing items to not stack properly) – by Herowl
* Beds now properly ignore players in other dimensions – by nixnoxus
* Stray pixels in leather cap texture removed – by SmokeyDope
* Allow lecterns to be placed on sides of blocks – by JoseDouglas26
* Fix warnings – by JoseDouglas26
* Experience from trading – by nixnoxus
* Boats easier to destroy with punching – by Eliy21
* Horse and Donkey animation fix – by Bakawun
* Villagers won't eat shulker boxes (independent of their food content) anymore – by teknomunk
* Beds now properly ignore players in the wrong dimensions when counting – by nixnoxus
* Shears now wear properly when harvesting comb from a beehive – by teknomunk
* Improved compatibility with mapgen mods – by Bram
* Item frame attachment fixed – by rudzik8
* Stray pixels in sweet berry textures removed – by rudzik8
* Warning related to milk bucket fixed – by teknomunk
* Seed is now logged when entering a world – by Nicu
* Startup warnings from mcl_stonecutter fixed – by Herowl
* Sleeping GUI improved – by Nicu
* Description capitalization fix – by syl

### Special thanks
* To emptyshore, for the in-depth research and testing of the Mob Spawning System rework, as well as his aforementioned Nether Portals system rework.

### Crash fixes
* Damage animation related crash – by Herowl
* Shields-related crash – by Impulse
* Elytra-related crash – by Herowl
* Damage animation and player invulnerability related crash – by Eliy21
* Rocket explosion related crash – by Herowl
* New game load crash – by AncientMariner
* XP orbs related crash – by teknomunk
* Ghast fireball related crash – by Araca
* Crash related to server restart while a player is dead – by teknomunk
* Crashes related to the new effects API – by teknomunk and Herowl

## 0.87.1 hotfix
* Fixed crash when shooting potions from a dispenser – by teknomunk
* Fixed crash related to custom mobspawners – by teknomunk
* Fixed beacon crash – by teknomunk
* Fixed eye of ender crash – by Herowl
* Fixed Stalker texture generation – by teknomunk
* Correctly refresh enchanted tool capabilities – by teknomunk
* Fixed creative inventory misbehaving – by Herowl
* Fixed variable definition in mob spawning code – by teknomunk
* Updated documentation – by Herowl and teknomunk
* Increased stack size for snowballs and eggs – by JoseDouglas26

## 0.87.2 hotfix
* Zombie texture improvements – by SmokeyDope
* Wrong name of diorite stairs fixed – by qoheniac
* Fixed flint and steel wearing down when not placing fire – by JoseDouglas26 and WillConker
* Fixed brewing stands' rotation – by JoseDouglas26 and WillConker
* Fixed beacon formspec – by teknomunk
* Made all hollow logs breakable properly – by teknomunk
* Instructions on how to eat added to the help menu – by teknomunk
* Potion conversion fixed – by Herowl
* Fixed some node names – by seventeenthShulker
* Fixed anvil and craftguide formspecs on mobile – by Herowl
* Fixed effect loading – by Herowl
* Fixed crash while fighting wither – by teknomunk
* Fixed crash when bonemealing sweet berry bushes – by teknomunk
* Fixed some mob conversion crashes – by teknomunk
* Fixed crash related to the frost walker enchantment – by WillConker
* Fixed some mob-related crashes – by Herowl
