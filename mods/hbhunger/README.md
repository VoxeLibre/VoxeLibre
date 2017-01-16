# Hunger with HUD bar [`hbhunger`]

* Version: 0.5.2

## Using the mod

This mod adds a mechanic for hunger.
This mod depends on the HUD bars mod [`hudbars`], version 1.4.1 or any later version
starting with “1.”.

## About hunger
This mod adds a hunger mechanic to the game. Players get a new attribute called “satiation”:

* A new player starts with 20 satiation points out of 30
* Actions like digging, placing and walking cause exhaustion, which lower the satiation
* Every 800 seconds you lose 1 satiation point without doing anything
* At 1 or 0 satiation you will suffer damage and die in case you don't eat something
* If your satiation is 16 or higher, you will slowly regenerate health points
* Eating food will increase your satiation (Duh!)

Important: Eating food will not directly increase your health anymore, as long as the food
item is supported by this mod (see below).

Careful! Some foods may be poisoned. If you eat a poisoned item, you may still get a satiation
boost, but for a brief period you lose health points because of food poisoning. However,
food poisoning can never kill you.

## Statbar mode
If you use the statbar mode of the HUD Bars mod, these things are important to know:
As with all mods using HUD Bars, the bread statbar symbols represent the rough percentage
out of 30 satiation points, in steps of 5%, so the symbols give you an estimate of your
satiation. This is different from the hunger mod by BlockMen.

You gain health at 5.5 symbols or more, as 5.5 symbols correspond to 16 satiation points.
You *may* lose health at exactly 0.5 symbols, as 0.5 symbols correspond to 1-2 satiation points.

## Supported food
All mods which add food through standard measures (`minetest.item_eat`) are already
supported automatically. Poisoned food needs special support.

### Known supported food mods
* Apple from Minetest Game [`default`]
* Red and brown mushroom from Minetest Game [`flowers`]
* Bread from Minetest Game [`farming`]
* [`animalmaterials`] (Mob Framework (`mobf` modpack))
* Bushes [`bushes`]
* [`bushes_classic`]
* Creatures [`creatures`]
* [`dwarves`] (beer and such)
* Docfarming [`docfarming`]
* Ethereal / Ethereal NG [`ethereal`]
* Farming Redo [`farming`] by TenPlus1
* Farming plus [`farming_plus`]
* Ferns [`ferns`]
* Fishing [`fishing`]
* [`fruit`]
* Glooptest [`glooptest`]
* JKMod ([`jkanimals`], [`jkfarming`], [`jkwine`])
* [`kpgmobs`]
* [`mobfcooking`]
* [`mooretrees`]
* [`mtfoods`]
* [`mushroom`]
* [`mush45`]
* Seaplants [`sea`]
* Simple mobs [`mobs`]
* Pizza [`pizza`]
* Not So Simple Mobs [`nssm`]

### Supported mods without optional dependency (mods provide their own support)

* Food ([`food`], [`food_basic`])
* Sweet Foods [`food_sweet`]

### Examples

* Eating an apple (from Minetest Game) increases your satiation by 2;
* eating a bread (from Minetest Game) increases your satiation by 4.

## Licensing
This mod is free software.

### Source code

* License: [LGPL v2.1](https://www.gnu.org/licenses/old-licenses/lgpl-2.1.en.html)
* Author: by Wuzzy (2015-2016)
* Forked from the “Better HUD (and hunger)” mod by BlockMen (2013-2015),
  most code comes from this mod.

### Textures

* `hbhunger_icon.png`—PilzAdam ([WTFPL](http://www.wtfpl.net/txt/copying/)), modified by BlockMen
* `hbhunger_bgicon.png`—PilzAdam (WTFPL), modified by BlockMen
* `hbhunger_bar.png—Wuzzy` (WTFPL)
* `hbhunger_icon_health_poison.png`—celeron55 ([CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/)), modified by BlockMen, modified again by Wuzzy
* Everything else: WTFPL, by BlockMen and Wuzzy

