# VoxeLibre Tools
This directory is for tools and scripts for VoxeLibre.
Currently, the only tool is Texture Converter.

## Texture Converter (EXPERIMENTAL)
This is a Python script which converts a resource pack for Minecraft to
a texture pack for Minetest so it can be used with VoxeLibre.

**WARNING**: This script is currently incomplete, not all textures will be
converted. Some texture conversions are even buggy!
Coverage is close to 100%, but it's not quite there yet.
For a 100% complete texture pack, a bit of manual work on the textures
will be required afterwards.

Modes of operation:
- Can create a Minetest texture pack (default)
- Can update the VoxeLibre textures

Requirements:
- Know how to use the console
- Python 3
- ImageMagick

Usage:
- Make sure the file “`Conversion_Table.csv`” is in the same directory as the script
- In the console, run `./Texture_Converter.py -h` to learn the available options
- Convert the textures
- Put the new texture directory in the Minetest texture pack directory, just like
  any other Minetest texture pack

## Luacheck Globals Generators
This is a Python script which list every single global tables in VoxeLibre source code.
It outputs a list to be used in luacheck conf files. 

Modes of operation:
- List global tables

Requirements:
- Know how to use the console
- Python 3

Usage:
- In the console, run `python3 ./tools/create_luacheck.py` in the MineClone2 directory
