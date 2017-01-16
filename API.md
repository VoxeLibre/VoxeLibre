# API

This document is a WORK IN PROGRESS. Currently, it only contains some information about the used groups.

## Groups
This section explains all the used groups in this subgame.

### Groups for interactions

* `dig_by_water=1`: Blocks with this group will drop when they are near flowing water
* `cultivatable=2`: Block will be turned into Farmland by using a hoe on it
* `cultivatable=1`: Block will be turned into Dirt by using a hoe on it
* `flammable`: Block helps spreading fire and gets destroyed by nearby fire (rating doesn't matter)
* `soil=1`: Saplings and other small plants can grow on it
* `soil_sapling=2`: Soil for saplings. Intended to be natural soil. All saplings will grow on this
* `soil_sapling=1`: Artificial soil (such as farmland) for saplings. Some saplings will not grow on this
* `soil_sugarcane=1`: Sugar canes will grow on this near water
* `disable_suffocation=1`: Disables suffocation for full solid cubes (1)
* `food`: Item is a comestible item which can be consumed (healthy or unhealthy)
    * `food=2`: Food
    * `food=3`: Drink
    * `food=1`: Other/unsure
* `eatable`: Item can be *directly* eaten by wielding + left click (`on_use=item_eat`). Rating is the satiation gain
* `ammo=1`: Item is used as ammo for a weapon
* `ammo_bow=1`: Item is used as ammo for bows
* `weapon_ranged=1`: Item is a ranged weapon

### Footnotes

1. Normally, all walkable blocks with the default 1×1×1 cube as a collision box (e.g. sand,
   gravel, stone, but not fences) will damage the players while their head is inside. This
   is called “suffocation”. Setting this group disables this behaviour

### Groups (mostly) used for crafting recipes

* `sand=1`: Sand (any color)
* `sandstone=1`: (Yellow) sandstone and related nodes (chiseled and the like) (only full blocks)
* `redsandstone=1`: Red sandstone and related nodes (chiseled and the like) (only full blocks)
* `quartz_block=1`: Quartz Block and variants (chiseled, pillar, etc.) (only full blocks)
* `stonebrick=1`: Stone Bricks and related nodes (only full blocks)
* `tree=1`: Oak Wood, Birch Wood, etc. (tree trunks)
* `wood=1`: Oak Wood Planks, Birch Wood Planks, etc. (only full blocks)
* `wood_slab=1`: Slabs made out of a kind of wooden planks
* `wood_stairs=1`: Stairs made out of a kind of wooden planks
* `coal=1`: Coal of any kind (lumps only, not blocks)
* `boat=1`: Boat
* `wool=1`: Wool (only full blocks)
* `carpet=1:` (Wool) carpet

### Other groups

* `water=1`: Water
* `lava=1`: Lava
* `liquid`: Block is a liquid
    * `liquid=1`: Unspecified type
    * `liquid=2`: Water
    * `liquid=3`: Lava
* `clock=1`: Clock
* `compass`: Compass (rating doesn't matter)
* `rail=1`: Rail
* `music_record`: Music Disc (rating is track ID)
