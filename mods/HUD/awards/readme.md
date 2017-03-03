# Awards

by Andrew "Rubenwardy" Ward, LGPL 2.1 or later.

This mod adds achievements to Minetest.

Majority of awards are back ported from Calinou's
old fork in Carbone, under same license.


# Basic API

* awards.register_achievement(name, def)
	* name
	* desciption
	* sound [optional] - set a custom sound (SimpleSoundSpec) or `false` to play no sound.
          If not specified, a default sound is played
	* image [optional] - texture name, eg: award_one.png
	* background [optional] - texture name, eg: award_one.png
	* trigger [optional] [table]
		* type - "dig", "place", "craft", "death", "chat", "join" or "eat"
		* dig type: Dig a node.
			* node: the dug node type. If nil, all dug nodes are counted
		* place type: Place a node.
			* node: the placed node type. If nil, all placed nodes are counted
		* eat type: Eat an item.
			* item: the eaten item type. If nil, all eaten items are counted
		* craft type: Craft something.
			* item: the crafted item type. If nil, all crafted items are counted
		* death type: Die.
		* chat type: Write a chat message.
		* join type: Join the server.
		* (for all types) target - how many times to dig/place/craft/etc.
		* See Triggers
	* secret [optional] - if true, then player needs to unlock to find out what it is.
	* on_unlock [optional] - func(name, def)
		* name is player name
		* return true to cancel register_on_unlock callbacks and HUD
* awards.register_trigger(name, func(awardname, def))
	* Note: awards.on[name] is automatically created for triggers
* awards.run_trigger_callbacks(player, data, trigger, table_func(entry))
	* Goes through and checks all triggers registered to a trigger type,
	  unlocking the award if conditions are met.
	* data is the player's award data, ie: awards.players[player_name]
	* trigger is the name of the trigger type. Ie: awards.on[trigger]
	* table_func is called if the trigger is a table - simply return an
	  award name to unlock it
	* See triggers.lua for examples
* awards.increment_item_counter(data, field, itemname)
	* add to an item's statistic count
	* for example, (data, "place", "default:stone") will add 1 to the number of
	  times default:stone has been placed.
	* data is the player's award data, ie: awards.players[player_name]
	* returns true on success, false on failure (eg: cannot get modname and item from itemname)
* awards.register_on_unlock(func(name, def))
	* name is the player name
	* def is the award def.
	* return true to cancel HUD
* awards.unlock(name, award)
	* gives an award to a player
	* name is the player name

# Included in the Mod

The API, above, allows you to register awards
and triggers (things that look for events and unlock awards, they need
to be registered in order to get details from award_def.trigger).

However, all awards and triggers are separate from the API.
They can be found in init.lua and triggers.lua

## Triggers

Callbacks (register a function to be run)

### dig

	trigger = {
		type = "dig",
		node = "default:dirt",
		target = 50
	}

### place

	trigger = {
		type = "place",
		node = "default:dirt",
		target = 50
	}

### death

	trigger = {
		type = "death",
		target = 5
	}

### chat

	trigger = {
		type = "chat",
		target = 100
	}

### join

	trigger = {
		type = "join",
		target = 100
	}

### eat

	trigger = {
		type = "eat",
		item = "default:apple",
		target = 100
	}

## Callbacks relating to triggers

* awards.register_on_dig(func(player, data))
	* data is player data (see below)
	* return award name or null
* awards.register_on_place(func(player, data))
	* data is player data (see below)
	* return award name or null
* awards.register_on_eat(func(player, data))
	* data is player data (see below)
	* return award name or null
* awards.register_on_death(func(player, data))
	* data is player data (see below)
	* return award name or null
* awards.register_on_chat(func(player, data))
	* data is player data (see below)
	* return award name or null
* awards.register_on_join(func(player, data)
	* data is player data (see below)
	* return award name or null


# Player Data

A list of data referenced/hashed by the player's name.
* player name
	* name [string]
	* count [table] - dig counter
		* modname [table]
			* itemname [int]
	* place [table] - place counter
		* modname [table]
			* itemname [int]
	* craft [table] - craft counter
		* modname [table]
			* itemname [int]
	* eat [table] - eat counter
		* modname [table]
			* itemname [int]
	* deaths
	* chats
	* joins
