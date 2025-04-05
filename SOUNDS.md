# Sounds For VoxeLibre
This documentation explores the process behind making or editing sound asset files within VoxeLibre. 

## General Explaination
Sounds are an undervalued asset that enriches the in-game experience. From regular actions like digging and walking, to the most minor things like button pushes and compost bin filling. When sound is done right, your players will subconciously notice. Voxelibre uses .ogg sound files to play in-game noises to be triggered.

## Index of sound locations

### Music
.minetest/games/voxelibre/menu                                          = main menu theme
.minetest/games/voxelibre/mods/PLAYER/mcl_music/sounds                  = in-game music
.minetest/games/voxelibre/mods/ITEMS/mcl_jukebox/sounds                 = jukebox music
.minetest/games/voxelibre/mods/ITEMS/mcl_shepherd/sounds                = Shepards Midnight chorus

### Player related sound affects
.minetest/games/voxelibre/mods/HUD/mcl_experience/sounds                = experience orb pickup and level up
.minetest/games/voxelibre/mods/HUD/awards/sounds                        = achievement unlocked
.minetest/games/voxelibre/mods/ENTITIES/mcl_item_entity/sounds          = player dropping item and lava sizzling as it destroys items.
.minetest/games/voxelibre/mods/ENTITIES/mcl_mobs/sounds                 = player punching mob with hand and mob poofing on death
.minetest/games/voxelibre/mods/ITEMS/mcl_armor/sounds                   = armor equip and unequip
.minetest/games/voxelibre/mods/PLAYER/mcl_criticals/sounds              = critical hit
.minetest/games/voxelibre/mods/PLAYER/mcl_hunger/sounds                 = player eat and drink

### Tool use sounds
.minetest/games/voxelibre/mods/ITEMS/mcl_bows/sounds                    = bow draw and firing
.minetest/games/voxelibre/mods/ITEMS/mcl_end/sounds                     = chorus fruit teleportation
.minetest/games/voxelibre/mods/ITEMS/mcl_enchanting/sounds              = enchanting table
.minetest/games/voxelibre/mods/CORE/mcl_sounds/sounds                   = general digging, walking footstep, tool use, node breaking
.minetest/games/voxelibre/mods/ITEMS/mcl_fire/sounds                    = fire noises, flint and steel tool use
.minetest/games/voxelibre/mods/ITEMS/mcl_potions/sounds                 = potion bottle
.minetest/games/voxelibre/mods/ITEMS/mcl_tools/sounds                   = shear cutting 
.minetest/games/voxelibre/mods/ITEMS/mcl_fishing/sounds                 = fishing rod reel, bob, splash
.minetest/games/voxelibre/mods/ITEMS/mcl_shields/sounds                 = shield blocking 
.minetest/games/voxelibre/mods/ITEMS/mcl_throwing/sounds                = throwing egg and snowball
.minetest/games/voxelibre/mods/ITEMS/vl_fireworks/sounds                = fireworks rocket

### Enviromental sounds
.minetest/games/voxelibre/mods/ENVIRONMENT/lightning/sounds             = lightning
.minetest/games/voxelibre/mods/ENVIRONMENT/mcl_weather/sounds           = rain
.minetest/games/voxelibre/mods/ITEMS/mcl_portals/sounds                 = portal teleportation sounds, end portal awakening

### Node Sounds
.minetest/games/voxelibre/mods/ITEMS/REDSTONE/mesecons_button/sounds    = button pushing
.minetest/games/voxelibre/mods/ITEMS/REDSTONE/mesecons_noteblock/sounds = redstone noteblock
.minetest/games/voxelibre/mods/ITEMS/REDSTONE/mesecons_pistons/sounds   = piston extend and retract
.minetest/games/voxelibre/mods/ITEMS/mcl_amethyst/sounds                = amethyst node
.minetest/games/voxelibre/mods/ITEMS/mcl_barrels/sounds                 = barrel open and close
.minetest/games/voxelibre/mods/ITEMS/mcl_bells/sounds                   = bell ringing
.minetest/games/voxelibre/mods/ITEMS/mcl_brewing/sounds                 = brewing stand bubbling
.minetest/games/voxelibre/mods/ITEMS/mcl_chests/sounds                  = chest, ender chest, and shulker box open/close
.minetest/games/voxelibre/mods/ITEMS/mcl_core/sounds                    = slimeblock digging, placement, footstep
.minetest/games/voxelibre/mods/ITEMS/mcl_doors/sounds                   = door open and close
.minetest/games/voxelibre/mods/ITEMS/mcl_fences/sounds                  = fence gate open and close
.minetest/games/voxelibre/mods/ITEMS/mclx_fences/sounds                 = nether brick fence gate open/close
.minetest/games/voxelibre/mods/ITEMS/mcl_mud/sounds                     = mud block
.minetest/games/voxelibre/mods/ITEMS/mcl_tnt/sounds                     = tnt wind up hiss and explosion
.minetest/games/voxelibre/mods/ENTITIES/mcl_dripping/sounds             = dripstone

### Mob & Entity noises
.minetest/games/voxelibre/mods/ENTITIES/mobs_mc/sounds                  = Most animal and mob noises
.minetest/games/voxelibre/mods/ITEMS/mcl_sculk/sounds                   = skulk and skulk catalyst related

# Making sound files with Software (Audacity)
First you will need a program that can edit and export sound files. Audacity is a popular and free software that will be used as an example for this documentation.

## Step 0 Sourcing files
Audio for voxelibre must be released under a permissive copyleft license. Typically we accept CC0 and CC-BY-SA licensed audio files. These can be sourced from the following places:
* Option 1: freesounds.org
- freesound is an excellent resource and what is recommended as a first source when hunting for sounds. It does require a free account to be made.
=> https://www.freesound.org

* Option 2: Youtube (CC filter)
- Youtube with creative commons filter. All video audio released under a creative commons license are good to use. You will need some way to download and extract the video, yt-dlp is a great way to do this.
=> https://www.youtube.com/results?search_query=replace_this_with_query&sp=EgIwAQ%253D%253D

* Option 3: Self-Sourced & Licensed
You can record your own samples with any microphone, chances are your phone is within reach to do the job. You have full control to license as you please, preferably CC0.

## Step 1 Open audio files in Audacity
Open Audacity.
![Screenshot](https://i.ibb.co/0VhDPQbW/Screenshot-from-2025-02-15-21-05-44.webp)
Navigate to the top left and select >file > open then choose your high quality music file
This is what an imported audio file looks like.
![Screenshot](https://i.ibb.co/9kPg0kGT/Screenshot-from-2025-02-15-21-06-58.webp)
You can use ctrl+mousewheel to zoom in and out, and theres a little slider too that helps navigate the track horizontally.

## Step 2 Isolate the sample
Now we are going to find a good sound byte somewhere in this track and select its duration. Zoom in on portion you want to keep and select it by holding in left click.
![Screenshot](https://i.ibb.co/6ckL6FnN/Screenshot-from-2025-02-15-21-09-02.webp)
this gives a visual idea of where to cut around. Now, time to cut out everything else.
left click on another part of track to clear out that selection. Now select everything you want to cut.
![Screenshot](https://i.ibb.co/zH4759tS/Screenshot-from-2025-02-15-21-10-52.webp)
Now hit the delete button to cut it out.
![Screenshot](https://i.ibb.co/Pv0cP3qX/Screenshot-from-2025-02-15-21-11-38.webp)

Now you can zoom in to whats left, play it over a few times to trim further or undo and try again if you cut off too much.

### Further adjustments
using audacity you can manually change gain, pitch, and more. 

effect > amplify to change gain (volume)
effect > change pitch... to change pitch
effect > change speed... to speed up the sound.
effect > noise reduction can be helpful if your source has a lot of background static

## Step 3 Exporting
Now its time to export your audio file as a .ogg . This is a free open source format using vorbis audio codec. Navigate to top toolbar file>export>export as OGG
Name your ogg file and set the audio quality slider to around 5 then export.

### Best Practices
Always keep your original high quality source audio file. If you ever need to go back and re-edit the sound always use the lossless version. The newly generated .ogg will have lost some quality for the sake of optimization.

# How sounds are implimented in VoxeLibre
Adding in basic sounds can be easy. Lets take a look at some examples.

## Default Sound Tables
Many of the general sounds that nodes and items use are called on from the mcl_sounds tables located in (.minetest/games/voxelibre/mods/CORE/mcl_sounds)
LUA code for cobblestone (found in .minetest/games/voxelibre/mods/ITEMS/mcl_core/nodes_base.lua)
```
minetest.register_node("mcl_core:cobble", {
	description = S("Cobblestone"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	_doc_items_hidden = false,
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, building_block=1, material_stone=1, cobble=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 2,
})
```

The key line is sounds = mcl_sounds.node_sound_stone_defaults()

If we make our way over to mcl_sounds/init.lua we will find this function:
```
mcl_sounds = {}                                        -- makes it a global function which lets it be callable by any mod that uses mcl_sounds as a dependency
function mcl_sounds.node_sound_stone_defaults(table)   -- Defines the function
	table = table or {}
	table.footstep = table.footstep or
			{name="default_hard_footstep", gain=0.2}   -- defines sound made when walking over node, gain has been adjusted in-game
	table.dug = table.dug or
			{name="default_hard_footstep", gain=1.0}   -- defines sound made when the node is broken
	table.dig = table.dig or
			{name="default_dig_cracky", gain=0.5}      -- defines the sound made when node is being dug before broken 
	mcl_sounds.node_sound_defaults(table)
	return table
end
```
This table calls upon three audio files depending on whether the node is walked on, being dug, or broken. Those audio file .oggs exist in the mcl_sounds/sounds/ subfolder as default_hard_footstep.1,.2,.3.ogg, and default_dig_cracky.1,.2,.3.ogg . All nodes that call upon mcl_sounds.node_sound_stone_defaults() will use these sounds acording to the table. Most basic nodes will call upon one of the sound tables found here.

### Sound Groups
Several sounds may be randomly choosen to play if they are in the same sound group. To create a sound group simply give all sound files the same name plus a number such as example.1.ogg, example.2.ogg, example.3.ogg . All of these sounds will have an equal 1/X chance to be called upon.

## Directly calling upon a sound to play for items and nodes
At its most basic, an individual sound is called upon by the following
```
			minetest.sound_play({name="zap_on", pos=pos, gain=1}, true)
```
This is seen more in functions where you want a sound to play after something has happened. Here is an example in the composter code when changing composting level
```
local function composter_progress_chance(pos, node, chance)
	-- calculate leveling up chance
	local rand = math.random(0,100)
	if chance >= rand then
		-- get current compost level
		local level = registered_nodes[node.name]["_mcl_compost_level"]
		-- spawn green particles above new layer
		mcl_bone_meal.add_bone_meal_particle(vector_offset(pos, 0, level/8, 0))
		-- update composter block
		if level < 7 then
			level = level + 1
		else
			level = "ready"
		end
		swap_node(pos, {name = "mcl_composters:composter_" .. level})

		minetest.sound_play({name="default_grass_footstep", gain=0.4}, {            -- sound triggers after node swap
			pos = pos,                                                              -- sound plays at the position of the node(composter)
			gain= 0.4,                                                              -- the gain(volume) has been lowered
			max_hear_distance = 16,                                                 -- only players within 16 blocks can hear this sound
		}, true)

		-- a full composter becomes ready for harvest after one second
		-- the block will get updated by the node timer callback set in node reg def
		if level == 7 then
			local timer = get_node_timer(pos)
			if not timer:is_started() then
				timer:start(1)
			end
		end
	end
end
```
The sound triggers after the node is swapped.
### Sound Spec & Sound Table
The luanti game engine offers some advanced tools for in-game sound processing. Unfortunately these tools aren't comprehensively documented and good examples are hard to come by. Documentation can be found at https://api.luanti.org/sounds/ .

## Mob Sounds
Mobs handle sounds differently based on their own set of callable tables. Heres an example:
```
	sounds = {
		random = "mobs_mc_iron_golem_random",
		death = "mobs_mc_iron_golem_death",
		damage = "mobs_mc_iron_golem_clank_damage",
		distance = 16,
    },
```
In order to get mobs to play footstep sounds they must have both makes_footstep_sound = true, and walk_velocity = 1, set.
Most mob sounds are in .minetest/games/voxelibre_master-04-03/mods/ENTITIES/mobs_mc/sounds.

