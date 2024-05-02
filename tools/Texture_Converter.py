#!/usr/bin/env python
# -*- coding: utf-8 -*-
# cli.py

import argparse
import sys
from libtextureconverter.gui import main as launch_gui
from libtextureconverter.config import SUPPORTED_MINECRAFT_VERSION, working_dir, appname, home
from libtextureconverter.utils import handle_default_minecraft_texture, find_all_minecraft_resourcepacks
from libtextureconverter.common import convert_resource_packs

def main():
    make_texture_pack = True
    parser = argparse.ArgumentParser(description=f"This is the official VoxeLibre Texture Converter. This will convert textures from Minecraft resource packs to a Minetest texture pack. Supported Minecraft version: {SUPPORTED_MINECRAFT_VERSION} (Java Edition)")
    parser.add_argument("-i", "--input", help="Directory of Minecraft resource pack to convert")
    parser.add_argument("-o", "--output", default=working_dir, help="Directory in which to put the resulting Minetest texture pack")
    parser.add_argument("-p", "--pixel-size", type=int, help="Size (in pixels) of the original textures")
    parser.add_argument("-d", "--dry-run", action="store_true", help="Pretend to convert textures without changing any files")
    parser.add_argument("-v", "--verbose", action="store_true", help="Print out all copying actions")
    parser.add_argument("-def", "--default", action="store_true", help="Use the default Minecraft texture pack")
    parser.add_argument("-a", "--all", action="store_true", help="Convert all known Minecraft texturepacks")
    args = parser.parse_args()

    if len(sys.argv) == 1:
        launch_gui()
    else:
        resource_packs = []
        if args.default:
            resource_packs.append(handle_default_minecraft_texture(home, args.output))
        elif args.all:
            resource_packs.extend(find_all_minecraft_resourcepacks())
        elif args.input:
            resource_packs.append(args.input)

        if not resource_packs:
            print(f"ERROR: No valid resource packs specified. Use '{appname} -h' for help.")
            sys.exit(2)

        convert_resource_packs(resource_packs, args.output, args.pixel_size, args.dry_run, args.verbose, make_texture_pack)

if __name__ == "__main__":
    main()
