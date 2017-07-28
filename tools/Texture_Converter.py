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
# - Make sure the file “Texture_Conversion_Table.csv” is in the same directory as the script
# - Run the script in its directory

__author__ = "Wuzzy"
__license__ = "WTFPL"
__status__ = "Development"

### SETTINGS ###
# If True, will only make console output but not convert anything.
dry_run = False

# If True, textures will be put into a texture pack directory structure.
# If False, textures will be put into MineClone 2 directories.
make_texture_pack = True

### END OF SETTINGS ###

import shutil, csv, os
from PIL import Image

# Helper variables
home = os.environ["HOME"]
mineclone2_path = home + "/.minetest/games/mineclone2"
working_dir = os.getcwd()
base_dir = home + "/tmp/pp"
tex_dir = base_dir + "/assets/minecraft/textures"

def convert_alphatex(one, two, three, four, five):
	os.system("convert "+one+" -crop 1x1+"+three+" -depth 8 -resize "+four+"x"+four+" "+base_dir+"/__TEMP__.png")
	os.system("composite -compose Multiply "+base_dir+"/__TEMP__.png "+two+" "+base_dir+"/__TEMP2__.png")
	os.system("composite -compose Dst_In "+two+" "+base_dir+"/__TEMP2__.png -alpha Set "+five)

def target_dir(directory):
	if make_texture_pack:
		return working_dir + "/texture_pack"
	else:
		return mineclone2_path + directory

# Copy texture files
def convert_textures():
	with open("Texture_Conversion_Table.csv", newline="") as csvfile:
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

			src_file = base_dir + src_dir + "/" + src_filename # source file
			src_file_exists = os.path.isfile(src_file)
			dst_file = target_dir(dst_dir) + "/" + dst_filename # destination file

			if src_file_exists == False:
				print("WARNING: Source file does not exist: "+src_file)
				continue

			if xs != None:
				# Crop and copy images
				image = Image.open(src_file)
				if not dry_run:
					region = image.crop((xs, ys, xs+xl, ys+yl))
					region.load()
					region.save(dst_file)
				print(src_file + " → " + dst_file)
			else:
				# Copy image verbatim
				if not dry_run:
					shutil.copy2(src_file, dst_file)
				print(src_file + " → " + dst_file)

	# Convert chest textures (requires ImageMagick)
	PXSIZE = 16
	chest_file = tex_dir + "/entity/chest/normal.png"

	if os.path.isfile(chest_file):
		CHPX=((PXSIZE / 16 * 14)) # Chests in MC are 2/16 smaller!

		os.system("convert " + chest_file + " \
\( -clone 0 -crop "+str(CHPX)+"x"+str(CHPX)+"+"+str(CHPX)+"+0 \) -geometry +0+0 -composite -extent "+str(CHPX)+"x"+str(CHPX)+" "+target_dir("/mods/ITEMS/mcl_chests/textures")+"/default_chest_top.png")

		os.system("convert " + chest_file + " \
\( -clone 0 -crop "+str(CHPX)+"x"+str((PXSIZE/16)*5)+"+"+str(CHPX)+"+"+str(CHPX)+" \) -geometry +0+0 -composite \
\( -clone 0 -crop "+str(CHPX)+"x"+str((PXSIZE/16)*10)+"+"+str(CHPX)+"+"+str((2*CHPX) + ((PXSIZE/16)*5))+" \) -geometry +0+"+str((PXSIZE/16)*5)+" -composite \
-extent "+str(CHPX)+"x"+str(CHPX)+" "+target_dir("/mods/ITEMS/mcl_chests/textures")+"/default_chest_front.png")

		# TODO: Convert other chest sides

	# Convert grass
	grass_file = tex_dir + "/blocks/grass_top.png"
	if os.path.isfile(grass_file):
		FOLIAG = tex_dir+"/colormap/foliage.png"
		GRASS = tex_dir+"/colormap/grass.png"

		os.system("convert "+GRASS+" -crop 1x1+70+120 -depth 8 -resize "+str(PXSIZE)+"x"+str(PXSIZE)+" "+base_dir+"/__TEMP__.png")
		os.system("composite -compose Multiply "+base_dir+"/__TEMP__.png "+tex_dir+"/blocks/grass_top.png "+target_dir("/mods/ITEMS/mcl_core/textures")+"/default_grass.png")


		convert_alphatex(GRASS, tex_dir+"/blocks/grass_side_overlay.png", "70+120", str(PXSIZE), target_dir("/mods/ITEMS/mcl_core/textures")+"/default_grass_side.png")

	
		# Leaves
		convert_alphatex(FOLIAG, tex_dir+"/blocks/leaves_oak.png", "70+120", str(PXSIZE), target_dir("/mods/ITEMS/mcl_core/textures")+"/default_leaves.png")
		convert_alphatex(FOLIAG, tex_dir+"/blocks/leaves_big_oak.png", "70+120", str(PXSIZE), target_dir("/mods/ITEMS/mcl_core/textures")+"/mcl_core_leaves_big_oak.png")
		convert_alphatex(FOLIAG, tex_dir+"/blocks/leaves_acacia.png", "16+240", str(PXSIZE), target_dir("/mods/ITEMS/mcl_core/textures")+"/default_acacia_leaves.png")
		convert_alphatex(FOLIAG, tex_dir+"/blocks/leaves_spruce.png", "226+240", str(PXSIZE), target_dir("/mods/ITEMS/mcl_core/textures")+"/mcl_core_leaves_spruce.png")
		convert_alphatex(FOLIAG, tex_dir+"/blocks/leaves_birch.png", "70+120", str(PXSIZE), target_dir("/mods/ITEMS/mcl_core/textures")+"/mcl_core_leaves_birch.png")
		convert_alphatex(FOLIAG, tex_dir+"/blocks/leaves_jungle.png", "16+32", str(PXSIZE), target_dir("/mods/ITEMS/mcl_core/textures")+"/default_jungleleaves.png")

		# Waterlily
		convert_alphatex(FOLIAG, tex_dir+"/blocks/waterlily.png", "16+32", str(PXSIZE), target_dir("/mods/ITEMS/mcl_flowers/textures")+"/flowers_waterlily.png")

		# Vines
		convert_alphatex(FOLIAG, tex_dir+"/blocks/vine.png", "16+32", str(PXSIZE), target_dir("/mods/ITEMS/mcl_core/textures")+"/mcl_core_vine.png")

		# Tall grass, fern
		convert_alphatex(GRASS, tex_dir+"/blocks/tallgrass.png", "70+120", str(PXSIZE), target_dir("/mods/ITEMS/mcl_flowers/textures")+"/mcl_flowers_tallgrass.png")
		convert_alphatex(GRASS, tex_dir+"/blocks/fern.png", "70+120", str(PXSIZE), target_dir("/mods/ITEMS/mcl_flowers/textures")+"/mcl_flowers_fern.png")
		convert_alphatex(GRASS, tex_dir+"/blocks/double_plant_fern_bottom.png", "70+120", str(PXSIZE), target_dir("/mods/ITEMS/mcl_flowers/textures")+"/mcl_flowers_double_plant_fern_bottom.png")
		convert_alphatex(GRASS, tex_dir+"/blocks/double_plant_fern_top.png", "70+120", str(PXSIZE), target_dir("/mods/ITEMS/mcl_flowers/textures")+"/mcl_flowers_double_plant_fern_top.png")
		convert_alphatex(GRASS, tex_dir+"/blocks/double_plant_grass_bottom.png", "70+120", str(PXSIZE), target_dir("/mods/ITEMS/mcl_flowers/textures")+"/mcl_flowers_double_plant_grass_bottom.png")
		convert_alphatex(GRASS, tex_dir+"/blocks/double_plant_grass_top.png", "70+120", str(PXSIZE), target_dir("/mods/ITEMS/mcl_flowers/textures")+"/mcl_flowers_double_plant_grass_top.png")

#	TODO: Convert banner masks
#	if os.path.isdir(tex_dir + "/entity/banner"):
# These are the ImageMagick commands needed to convert the mask images
#		os.system("mogrify -transparent-color "+filename)
#		os.system("mogrify -clip-mask "+tex_dir+"/entity/banner/base.png"+" -alpha Copy "+filename)
#		os.system("mogrify -fill white -colorize 100 "+filename)

if make_texture_pack and not os.path.isdir("./texture_pack"):
	os.mkdir("texture_pack")

convert_textures()
