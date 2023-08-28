### 0.84 - The Very Nice release

### Contributors
#### New contributors

* appgurueu
* kbundg
* megustanlosfrijoles
* Niterux
* seventeenthShulker
* Temak
* uqers

#### Returning contributors

* 3raven
* AncientMariner
* chmodsayshello
* cora
* epCode
* Exhale
* FlamingRCCars
* FossFanatic
* MrRar
* Nicu
* PrairieWind
* rudzik8
* SmokeyDope
* Wbjitscool

## Important Info

### New server commands

minetest.register_chatcommand("music", {
params = "[on|off|invert [<player name>]]",
description = S("Turns music for yourself or another player on or off."),


### New settings added

#Maximum amount of hostile mobs (default:300)
mcl_mob_cap_hostile (Global hostile mob cap) int 300 0 2048

#Maximum amount of non-hostile mobs (default:300)
mcl_mob_cap_non_hostile (Global non-hostile mob cap) int 300 0 2048

#Maximum amount of ambient water mobs that will spawn near a player (default:20)
mcl_mob_cap_water_ambient (Mob cap ambient water) int 20 0 1024

#Maximum amount of underground water mobs that will spawn near a player (default:5)
mcl_mob_cap_water_underground (Mob cap underground water) int 5 0 1024

#Maximum amount of axolotl mobs that will spawn near a player (default:5)
mcl_mob_cap_axolotl (Mob cap axolotl) int 5 0 1024

## Change Log

### Gameplay Improvements

* Cherry Blossoms - Saplings added as loot, and trees and craftables added. Initial changes to enable a Wood API. - PrairieWind, SmokeyDope, Wbjitscool
* Fix issue with drops turning black due to clipping into walls and floors and visually demonstrate drops merging - AncientMariner
* Hoglins attack frequency reduced now due to new attack_frequency mob setting - AncientMariner
* Hostile mobs should lose aggro if they cannot see their target - AncientMariner
* Nerf skeleton attack - AncientMariner
* Split global cap for peaceful and hostile. Introduce underground water, ambient water, axolotl cap. Slight peaceful spawn balancing. Mob spawning can have more density in some instances. Slightly less passive mob spawning. Some mobs were not counted in cap calculations. Refreshed cap space after spawning in cycle. - AncientMariner
* Prevent slime blocks from 'connecting' to honey blocks when pushing/pulling, like in Minecraft - seventeenthShulker
* Add support for external custom skins mod - MrRar
* Double doors fixed - FossFanatic
* Make elytra enchantable and the enchanted elytra usable - PrairieWind/FlamingRCCars/MrRar
* Remove slimes from mushroom islands - AncientMariner
* Remove Flower Forest Beaches from Wolf biome spawn list - PrairieWind
* Make Piglin Brutes drop golden axes = PrairieWind
* Make end crystals explode when nearby crystals are punched and explode - PrairieWind
* Improved pig riding - PrairieWind


### Visual Improvements

* Incorporate sheep eating animation. - epCode
* New textures for warped for Crimson Fungus, Crimson Fungus planks, Warped Hyphae planks - Exhale
* New sweet berry textures - SmokeyDope
* Add Piglin and Creeper description names to death message - AncientMariner
* Creeper should not walk to player if it does not have line of sight. Mob shouldn't look at player it does not have line of sight to. - AncientMariner
* Remove one cause of extra jittering in mobs - AncientMariner
* Update dead bush generation - PrairieWind
* Fix a typo in the Acquire Hardware achievement - uqers
* Clean-up mcl_bamboo text - rudzik8


### Sounds

* Add more fishing sounds! - Niterux
* Add max_hear_distance flag to composter sounds - SmokeyDope
* Add barrel sounds - SmokeyDope


### Translations

* Update russian translation - Temak
* (french) translation enhancements - 3raven
* Add spanish translations - megustanlosfrijoles


### Performance

* Reduce network activity for elytra flying rocket particles - AncientMariner
* Mapgen Performance Improvements - FossFanatic
* Migrate beacons back to abm - chmodsayshello
* Frequent danger checks and movement actions removed from non-moving and out of range mobs - AncientMariner
* Duplicate jump and danger checks removed from mob processing - AncientMariner
* Decreased frequency of processing for some mob actions - AncientMariner
* Only run certain checks if applicable for mob - AncientMariner


### Multiplayer

* Add global cooldown for the bed quick chat feature - chmodsayshello/AncientMariner
* Music toggle for players connecting to servers - chmodsayshello
* Make sure dying sign text respects protection - AncientMariner


### Code Quality

* Oxidation API - PrairieWind
* Fix sign color requirement and translation issue - PrairieWind
* Standardise despawn logic and add asserts. Add persistent flag for mobs that have been interacted with. - AncientMariner
* Replace the zombie pigman with the zombified piglin - AncientMariner
* Clean up crash code and convert to new style vectors - AncientMariner
* Fix png start warning and double slab description warning. - AncientMariner
* OptiPNG a bunch of textures - PrairieWind
* Beds mesecons dependency incorrectly named - AncientMariner
* Rename Bucket Textures - AncientMariner
* Fix global variable references and exit mob_step if missing pos - AncientMariner
* Fix texture modifiers relying on undocumented behavior - appgurueu


### Fixes

* Piglins no longer aggro for enchanted gold armour - AncientMariner
* Drop pumpkins, melons and buttons via piston or dirt next to piston - AncientMariner
* Llamas and other mobs change skin color - AncientMariner
* Mobs more easily jump from stationary up a block - epCode
* Fix waterlogged mangrove roots leaving water in the nether - AncientMariner
* Prevent ALL furnaces from being moved (xp dupe fix) - chmodsayshello
* Fix gilded blackstone fortune dupe - cora
* Lightning rod param2 is now saved upon being struck - AncientMariner
* Adjust hot stuff achievement to use new lava bucket texture name - SmokeyDope
* Fix dropped out bamboo lines from translation work - AncientMariner
* Zombie piglin no longer prevent sleep unless hostile. - AncientMariner


### Crashes

* Fix crash when creeper explodes in minecart - AncientMariner
* Fix crash when using a named spawn egg - cora
* Fix crash when parrot sits on shoulder - AncientMariner
* Fix 2 automated wool farm crash and elytra fly over unknown block crash - AncientMariner
* Change order of numbers passed into random that crash on some Lua versions - AncientMariner
* solar panels: No crash when minetest.get_natural_light() return nil - MrRar