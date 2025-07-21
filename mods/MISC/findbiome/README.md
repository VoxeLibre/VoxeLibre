# Luanti mod: findbiome

## Description
This is a mod to help with mod/game development for Luanti.
It adds a command (“findbiome”) to find a biome nearby and teleport you to it
and another command (“listbiomes”) to list biomes.

Version: 1.1.1

## Known limitations
There's no guarantee you will always find the biome, even if it exists in the world.
This can happen if the biome is very obscure or small, but usually you should be
able to find the biome.

If the biome could not be found, just move to somewhere else and try again.

## Modding info

For modders, this mod offers a single function to search biomes via code.
See `API.md` for details.

## Authors
- paramat (MIT License)
- Wuzzy (MIT License)
- Jacob Lifshay (MIT License, bugfix)

This mod is free software. See `license.txt` for license information.

This mod is based on the algorithm of the "spawn" mod from Minetest Game 5.0.0.
