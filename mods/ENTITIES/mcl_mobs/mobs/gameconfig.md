# Game integration help

This mod has been designed to make game integration rather easy. Ideally, it should be possible to include this mod verbatim in your game, with modifications only done by an external mod.

To integrate this mod in a game, you have to do 2 things: Adding the mod, and adding another mod which tells `mobs_mc` which items to use. The idea is that `mobs_mc` should work with any items. Specifically, these are the steps you need to follow:

* Add the `mobs_mc` mod and its dependencies
* Add a mod with name “`mobs_mc_gameconfig`”
* In this mod, do this:
    * Do *not* depend on `mobs_mc`
    * Create the table `mobs_mc`
    * Create the table `mobs_mc.override`
    * In `mobs_mc.override`, create subtables (`items`, `spawn`, etc.) like in `0_gameconfig.lua`, defining the na
    * Read `0_gameconfig.lua` to see which items you can override (and more explanations)
* In `on_construct` of a pumpkin or jack'o lantern node, call:
    * `mobs_mc.tools.check_iron_golem_summon(pos)`
    * `mobs_mc.tools.check_snow_golem_summon(pos)`
    * For more information, see `snowman.lua` and `iron_golem.lua`

Some things to note:

* Every override is optional, but explicitly setting all the item overrides is strongly recommended
* `mobs_mc` ships many (but not all) items on its own. If not item name override is set, the `mobs_mc` item is used
    * You decide whether your game defines its own items, outside of `mobs_mc` or if you let `mobs_mc` do the work.
* Make sure to avoid duplicate items!
* After finishing this, throughly test this
* Without `mobs_mc_gameconfig`, the mod assumes Minetest Game items
* `mobs_mc` optionally depends on `mobs_mc_gameconfig`

## Example `init.lua` in `mobs_mc_gameconfig`
```
mobs_mc = {}

mobs_mc.override = {}

-- Set the item names here
mobs_mc.override.items = {
	blaze_rod = "mcl_mobitems:blaze_rod",
	blaze_powder = "mcl_mobitems:blaze_powder",
	chicken_raw = "mcl_mobitems:chicken",
	-- And so on ...
}

-- Set the “follow” field of mobs (used for attracting mob, feeding and breeding)
mobs_mc.override.follow = {
	chicken = { "mcl_farming:wheat_seeds", "mcl_farming:melon_seeds", "mcl_farming:pumpkin_seeds", "mcl_farming:beetroot_seeds", },
	horse = { "mcl_core:apple", mobs_mc.override.items.wheat }, -- TODO
	pig = { "mcl_farming:potato", mobs_mc.override.items.carrot, mobs_mc.override.items.carrot_on_a_stick},
	-- And so on ...
}

-- Custom spawn nodes
mobs_mc.override.spawn = {
	snow = { "example:snow", "example:snow2" },
	-- And so on ...
}

-- Take a look at the other possible tables, see 0_gameconfig.lua
```
