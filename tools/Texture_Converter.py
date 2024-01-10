#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Texture Converter.
# Converts Minecraft resource packs to Minetest texture packs.
# See README.md.

__author__ = "Wuzzy"
__license__ = "MIT License"
__status__ = "Development"

import shutil, csv, os, tempfile, sys, argparse, glob
from PIL import Image
from collections import Counter

from libtextureconverter.utils import detect_pixel_size, target_dir, colorize, colorize_alpha, handle_default_minecraft_texture, find_all_minecraft_resourcepacks
from libtextureconverter.convert import convert_textures
from libtextureconverter.config import SUPPORTED_MINECRAFT_VERSION, working_dir, mineclone2_path, appname, home
from libtextureconverter.gui import main as launch_gui

# Argument parsing
description_text = f"""This is the official MineClone 2 Texture Converter.
                   This will convert textures from Minecraft resource packs to
                   a Minetest texture pack.

                   Supported Minecraft version: {SUPPORTED_MINECRAFT_VERSION} (Java Edition)
				   """
parser = argparse.ArgumentParser(description=description_text)
parser.add_argument("-i", "--input", help="Directory of Minecraft resource pack to convert")
parser.add_argument("-o", "--output", default=working_dir, help="Directory in which to put the resulting Minetest texture pack")
parser.add_argument("-p", "--pixelsize", type=int, help="Size (in pixels) of the original textures")
parser.add_argument("-d", "--dry_run", action="store_true", help="Pretend to convert textures without changing any files")
parser.add_argument("-v", "--verbose", action="store_true", help="Print out all copying actions")
parser.add_argument("-def", "--default", action="store_true", help="Use the default Minecraft texture pack")
parser.add_argument("-a", "--all", action="store_true", help="Convert all known Minecraft texturepacks")
args = parser.parse_args()

### SETTINGS ###
base_dir = args.input
output_dir = args.output
PXSIZE = args.pixelsize
# If True, will only make console output but not convert anything.
dry_run = args.dry_run
# If True, prints all copying actions
verbose = args.verbose
# If True, textures will be put into a texture pack directory structure.
# If False, textures will be put into MineClone 2 directories.
make_texture_pack = True  # Adjust as needed

if __name__ == "__main__":
    if len(sys.argv) == 1:
        # No arguments supplied, launch the GUI
        launch_gui()
    else:
        if args.default:
            base_dir = handle_default_minecraft_texture(home, output_dir)

        if base_dir == None and not args.all:
        	print(
        """ERROR: You didn't tell me the path to the Minecraft resource pack.
        Mind-reading has not been implemented yet.

        Try this:
            """+appname+""" -i <path to resource pack>

        For the full help, use:
            """+appname+""" -h""")
        	sys.exit(2);

        ### END OF SETTINGS ###


        resource_packs = []

        if args.all:
            for resource_path in find_all_minecraft_resourcepacks():
                resource_packs.append(resource_path)

        if make_texture_pack and args.input:
            resource_packs.append(args.input)

        for base_dir in resource_packs:
            tex_dir = base_dir + "/assets/minecraft/textures"

            # Get texture pack name (from directory name)
            bdir_split = base_dir.split("/")
            output_dir_name = bdir_split[-1]
            if len(output_dir_name) == 0:
            	if len(bdir_split) >= 2:
            		output_dir_name = base_dir.split("/")[-2]
            	else:
            		# Fallback
            		output_dir_name = "New_MineClone_2_Texture_Pack"

            # ENTRY POINT
            if make_texture_pack and not os.path.isdir(output_dir+"/"+output_dir_name):
            	os.mkdir(output_dir+"/"+output_dir_name)

            # If, set to convert all resourcepacks, then autodetect pixel size
            if args.all:
                PXSIZE = None

            if PXSIZE is None:
                PXSIZE = detect_pixel_size(base_dir)
            tempfile1 = tempfile.NamedTemporaryFile()
            tempfile2 = tempfile.NamedTemporaryFile()

            convert_textures(make_texture_pack, dry_run, verbose, base_dir, tex_dir, tempfile1, tempfile2, output_dir, output_dir_name, mineclone2_path, PXSIZE)

            tempfile1.close()
            tempfile2.close()
