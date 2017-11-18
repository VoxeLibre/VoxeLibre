#!/usr/bin/env python
# EXPERIMENTAL texture pack copying utility.
# This Python script helps in converting Minecraft texture packs. It has 2 main features:
# - Can create a Minetest texture pack (default)
# - Can update the MineClone 2 textures
# This script is currently incomplete, not all textures are converted.
#
# Requirements:
# - Python 3
# - Python Library: Pillow
# - ImageMagick
#
# Usage (to be simplified later):
# - Put extracted texture pack into $HOME/tmp/pp
# - Make sure the file “Conversion_Table.csv” is in the same directory as the script
# - Run the script in its directory
# - If everything worked, retrieve texture pack in New_MineClone_2_Texture_Pack/

__author__ = "Wuzzy"
__license__ = "MIT License"
__status__ = "Development"

import shutil, csv, os, tempfile, sys, getopt
from PIL import Image

# Helper vars
home = os.environ["HOME"]
mineclone2_path = home + "/.minetest/games/mineclone2"
working_dir = os.getcwd()
output_dir_name = "New_MineClone_2_Texture_Pack"
appname = "Texture_Converter.py"

### SETTINGS ###
output_dir = working_dir

base_dir = None

# If True, will only make console output but not convert anything.
dry_run = False

# If True, textures will be put into a texture pack directory structure.
# If False, textures will be put into MineClone 2 directories.
make_texture_pack = True

# If True, prints all copying actions
verbose = False

PXSIZE = 16

syntax_help = appname+""" -i <input dir> [-o <output dir>] [-d] [-v|-q] [-h]
Mandatory argument:
-i <input directory>
	Directory of Minecraft resource pack to convert

Optional arguments:
-p <size>
	Specify the size of the original textures (default: 16)
-o <output directory>
	Directory in which to put the resulting MineClone 2 texture pack
	(default: working directory)
-d
	The script will only pretend to convert textures by writing
	to the console only, but not changing any files.
-v
	Prints out all copying actions
-h
	Shows this help an exits"""
try:
	opts, args = getopt.getopt(sys.argv[1:],"hi:o:p:dv")
except getopt.GetoptError:
	print(
"""ERROR! The options you gave me make no sense!

Here's the syntax reference:""")
	print(syntax_help)
	sys.exit(2)
for opt, arg in opts:
	if opt == "-h":
		print(
"""This is the official MineClone 2 Texture Converter.
This will convert textures from Minecraft resource packs to
a MineClone 2 texture pack.

Supported Minecraft version: 1.12 (Java Edition)

Syntax:""")
		print(syntax_help)
		sys.exit()
	elif opt == "-d":
		dry_run = True
	elif opt == "-v":
		verbose = True
	elif opt == "-i":
		base_dir = arg
	elif opt == "-o":
		output_dir = arg
	elif opt == "-p":
		PXSIZE = int(arg)

if base_dir == None:
	print(
"""ERROR: You forgot to tell me the path to the Minecraft resource pack.
Mind-reading has not been implemented yet.

Try this:
    """+appname+""" -i <path to resource pack>

For the full help, use:
    """+appname+""" -h""")
	sys.exit(2);

### END OF SETTINGS ###

tex_dir = base_dir + "/assets/minecraft/textures"

# FUNCTION DEFINITIONS

def convert_alphatex(colormap, source, colormap_pixel, texture_size, destination):
	os.system("convert "+colormap+" -crop 1x1+"+colormap_pixel+" -depth 8 -resize "+texture_size+"x"+texture_size+" "+tempfile1.name)
	os.system("composite -compose Multiply "+tempfile1.name+" "+source+" "+tempfile2.name)
	os.system("composite -compose Dst_In "+source+" "+tempfile2.name+" -alpha Set "+destination)

def target_dir(directory):
	if make_texture_pack:
		return output_dir + "/" + output_dir_name
	else:
		return mineclone2_path + directory

# Copy texture files
def convert_textures():
	failed_conversions = 0
	print("Texture conversion BEGINS NOW!")
	with open("Conversion_Table.csv", newline="") as csvfile:
		reader = csv.reader(csvfile, delimiter=",", quotechar='"')
		first_row = True
		for row in reader:
			# Skip first row
			if first_row:
				first_row = False
				continue

			src_dir = row[0]
			src_filename = row[1]
			dst_dir = row[2]
			dst_filename = row[3]
			if row[4] != "":
				xs = int(row[4])
				ys = int(row[5])
				xl = int(row[6])
				yl = int(row[7])
				xt = int(row[8])
				yt = int(row[9])
			else:
				xs = None
			blacklisted = row[10]

			if blacklisted == "y":
				# Skip blacklisted files
				continue

			src_file = base_dir + src_dir + "/" + src_filename # source file
			src_file_exists = os.path.isfile(src_file)
			dst_file = target_dir(dst_dir) + "/" + dst_filename # destination file

			if src_file_exists == False:
				print("WARNING: Source file does not exist: "+src_file)
				failed_conversions = failed_conversions + 1
				continue

			if xs != None:
				# Crop and copy images
				image = Image.open(src_file)
				if not dry_run:
					region = image.crop((xs, ys, xs+xl, ys+yl))
					region.load()
					region.save(dst_file)
				if verbose:
					print(src_file + " → " + dst_file)
			else:
				# Copy image verbatim
				if not dry_run:
					shutil.copy2(src_file, dst_file)
				if verbose:
					print(src_file + " → " + dst_file)

	# Convert chest textures (requires ImageMagick)
	chest_file = tex_dir + "/entity/chest/normal.png"

	if os.path.isfile(chest_file):
		CHPX=((PXSIZE / 16 * 14)) # Chests in MC are 2/16 smaller!
# Chests are currently blacklisted

#		os.system("convert " + chest_file + " \
#\( -clone 0 -crop "+str(CHPX)+"x"+str(CHPX)+"+"+str(CHPX)+"+0 \) -geometry +0+0 -composite -extent "+str(CHPX)+"x"+str(CHPX)+" "+target_dir("/mods/ITEMS/mcl_chests/textures")+"/default_chest_top.png")

#		os.system("convert " + chest_file + " \
#\( -clone 0 -crop "+str(CHPX)+"x"+str((PXSIZE/16)*5)+"+"+str(CHPX)+"+"+str(CHPX)+" \) -geometry +0+0 -composite \
#\( -clone 0 -crop "+str(CHPX)+"x"+str((PXSIZE/16)*10)+"+"+str(CHPX)+"+"+str((2*CHPX) + ((PXSIZE/16)*5))+" \) -geometry +0+"+str((PXSIZE/16)*5)+" -composite \
#-extent "+str(CHPX)+"x"+str(CHPX)+" "+target_dir("/mods/ITEMS/mcl_chests/textures")+"/default_chest_front.png")

		# TODO: Convert other chest sides

	# Convert grass
	grass_file = tex_dir + "/blocks/grass_top.png"
	if os.path.isfile(grass_file):
		FOLIAG = tex_dir+"/colormap/foliage.png"
		GRASS = tex_dir+"/colormap/grass.png"

	
		# Leaves
		convert_alphatex(FOLIAG, tex_dir+"/blocks/leaves_oak.png", "116+143", str(PXSIZE), target_dir("/mods/ITEMS/mcl_core/textures")+"/default_leaves.png")
		convert_alphatex(FOLIAG, tex_dir+"/blocks/leaves_big_oak.png", "158+177", str(PXSIZE), target_dir("/mods/ITEMS/mcl_core/textures")+"/mcl_core_leaves_big_oak.png")
		convert_alphatex(FOLIAG, tex_dir+"/blocks/leaves_acacia.png", "40+255", str(PXSIZE), target_dir("/mods/ITEMS/mcl_core/textures")+"/default_acacia_leaves.png")
		convert_alphatex(FOLIAG, tex_dir+"/blocks/leaves_spruce.png", "226+230", str(PXSIZE), target_dir("/mods/ITEMS/mcl_core/textures")+"/mcl_core_leaves_spruce.png")
		convert_alphatex(FOLIAG, tex_dir+"/blocks/leaves_birch.png", "141+186", str(PXSIZE), target_dir("/mods/ITEMS/mcl_core/textures")+"/mcl_core_leaves_birch.png")
		convert_alphatex(FOLIAG, tex_dir+"/blocks/leaves_jungle.png", "16+39", str(PXSIZE), target_dir("/mods/ITEMS/mcl_core/textures")+"/default_jungleleaves.png")

		# Waterlily
		convert_alphatex(FOLIAG, tex_dir+"/blocks/waterlily.png", "16+39", str(PXSIZE), target_dir("/mods/ITEMS/mcl_flowers/textures")+"/flowers_waterlily.png")

		# Vines
		convert_alphatex(FOLIAG, tex_dir+"/blocks/vine.png", "16+39", str(PXSIZE), target_dir("/mods/ITEMS/mcl_core/textures")+"/mcl_core_vine.png")

		# Tall grass, fern (inventory images)
		pcol = "49+172" # Plains grass color
		convert_alphatex(GRASS, tex_dir+"/blocks/tallgrass.png", pcol, str(PXSIZE), target_dir("/mods/ITEMS/mcl_flowers/textures")+"/mcl_flowers_tallgrass_inv.png")
		convert_alphatex(GRASS, tex_dir+"/blocks/fern.png", pcol, str(PXSIZE), target_dir("/mods/ITEMS/mcl_flowers/textures")+"/mcl_flowers_fern_inv.png")
		convert_alphatex(GRASS, tex_dir+"/blocks/double_plant_fern_top.png", pcol, str(PXSIZE), target_dir("/mods/ITEMS/mcl_flowers/textures")+"/mcl_flowers_double_plant_fern_inv.png")
		convert_alphatex(GRASS, tex_dir+"/blocks/double_plant_grass_top.png", pcol, str(PXSIZE), target_dir("/mods/ITEMS/mcl_flowers/textures")+"/mcl_flowers_double_plant_grass_inv.png")

		# TODO: Convert grass palette

		offset = [
			[ pcol, "", "grass" ], # Default grass: Plains
			[ "40+255", "_dry", "dry_grass" ], # Dry grass: Savanna, Mesa Plateau F, Nether, …
		]
		for o in offset:

			os.system("convert "+GRASS+" -crop 1x1+"+o[0]+" -depth 8 -resize "+str(PXSIZE)+"x"+str(PXSIZE)+" "+tempfile1.name)
			os.system("composite -compose Multiply "+tempfile1.name+" "+tex_dir+"/blocks/grass_top.png "+target_dir("/mods/ITEMS/mcl_core/textures")+"/default_"+o[2]+".png")
			convert_alphatex(GRASS, tex_dir+"/blocks/grass_side_overlay.png", o[0], str(PXSIZE), target_dir("/mods/ITEMS/mcl_core/textures")+"/default_"+o[2]+"_side.png")



#	TODO: Convert banner masks
#	if os.path.isdir(tex_dir + "/entity/banner"):
# These are the ImageMagick commands needed to convert the mask images
#		os.system("mogrify -transparent-color "+filename)
#		os.system("mogrify -clip-mask "+tex_dir+"/entity/banner/base.png"+" -alpha Copy "+filename)
#		os.system("mogrify -fill white -colorize 100 "+filename)

		print("Textures conversion COMPLETE!")
		if failed_conversions > 0:
			print("WARNING: Number of missing files in original resource pack: "+str(failed_conversions))
		print("NOTE: Please keep in mind this script does not reliably convert all the textures yet.")
		if make_texture_pack:
			print("You can now retrieve the texture pack in "+output_dir+"/"+output_dir_name+"/")

# ENTRY POINT
if make_texture_pack and not os.path.isdir(output_dir+"/"+output_dir_name):
	os.mkdir(output_dir+"/"+output_dir_name)

tempfile1 = tempfile.NamedTemporaryFile()
tempfile2 = tempfile.NamedTemporaryFile()

convert_textures()

tempfile1.close()
tempfile2.close()
