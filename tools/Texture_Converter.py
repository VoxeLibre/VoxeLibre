#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Texture Converter.
# Converts Minecraft resource packs to Minetest texture packs.
# See README.md.

__author__ = "Wuzzy"
__license__ = "MIT License"
__status__ = "Development"

import shutil, csv, os, tempfile, sys, getopt

# Helper vars
home = os.environ["HOME"]
mineclone2_path = home + "/.minetest/games/mineclone2"
working_dir = os.getcwd()
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
-p <texture size>
	Specify the size (in pixels) of the original textures (default: 16)
-o <output directory>
	Directory in which to put the resulting Minetest texture pack
	(default: working directory)
-d
	Just pretend to convert textures and just print output, but do not actually
	change any files.
-v
	Print out all copying actions
-h
	Show this help and exit"""
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
a Minetest texture pack.

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
"""ERROR: You didn't tell me the path to the Minecraft resource pack.
Mind-reading has not been implemented yet.

Try this:
    """+appname+""" -i <path to resource pack> -p <texture size>

For the full help, use:
    """+appname+""" -h""")
	sys.exit(2);

### END OF SETTINGS ###

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

# FUNCTION DEFINITIONS
def colorize(colormap, source, colormap_pixel, texture_size, destination):
	os.system("convert "+colormap+" -crop 1x1+"+colormap_pixel+" -depth 8 -resize "+texture_size+"x"+texture_size+" "+tempfile1.name)
	os.system("composite -compose Multiply "+tempfile1.name+" "+source+" "+destination)

def colorize_alpha(colormap, source, colormap_pixel, texture_size, destination):
	colorize(colormap, source, colormap_pixel, texture_size, tempfile2.name)
	os.system("composite -compose Dst_In "+source+" "+tempfile2.name+" -alpha Set "+destination)

# This function is unused atm.
# TODO: Implemnt colormap extraction
def extract_colormap(colormap, colormap_pixel, positions):
	os.system("convert -size 16x16 canvas:black "+tempfile1.name)
	x=0
	y=0
	for p in positions:
		os.system("convert "+colormap+" -crop 1x1+"+colormap_pixel+" -depth 8 "+tempfile2.name)
		os.system("composite -geometry 16x16+"+x+"+"+y+" "+tempfile2.name)
		x = x+1

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

			if make_texture_pack == False and dst_dir == "":
				# If destination dir is empty, this texture is not supposed to be used in MCL2
				# (but maybe an external mod). It should only be used in texture packs.
				# Otherwise, it must be ignored.
				# Example: textures for mcl_supplemental
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
				if not dry_run:
					os.system("convert "+src_file+" -crop "+xl+"x"+yl+"+"+xs+"+"+ys+" "+dst_file)
				if verbose:
					print(src_file + " → " + dst_file)
			else:
				# Copy image verbatim
				if not dry_run:
					shutil.copy2(src_file, dst_file)
				if verbose:
					print(src_file + " → " + dst_file)

	# Convert armor textures (requires ImageMagick)
	armor_files = [
		[ tex_dir + "/models/armor/leather_layer_1.png", tex_dir + "/models/armor/leather_layer_2.png", target_dir("/mods/ITEMS/mcl_armor/textures"), "mcl_armor_helmet_leather.png", "mcl_armor_chestplate_leather.png", "mcl_armor_leggings_leather.png", "mcl_armor_boots_leather.png" ],
		[ tex_dir + "/models/armor/chainmail_layer_1.png", tex_dir + "/models/armor/chainmail_layer_2.png", target_dir("/mods/ITEMS/mcl_armor/textures"), "mcl_armor_helmet_chain.png", "mcl_armor_chestplate_chain.png", "mcl_armor_leggings_chain.png", "mcl_armor_boots_chain.png" ],
		[ tex_dir + "/models/armor/gold_layer_1.png", tex_dir + "/models/armor/gold_layer_2.png", target_dir("/mods/ITEMS/mcl_armor/textures"), "mcl_armor_helmet_gold.png", "mcl_armor_chestplate_gold.png", "mcl_armor_leggings_gold.png", "mcl_armor_boots_gold.png" ],
		[ tex_dir + "/models/armor/iron_layer_1.png", tex_dir + "/models/armor/iron_layer_2.png", target_dir("/mods/ITEMS/mcl_armor/textures"), "mcl_armor_helmet_iron.png", "mcl_armor_chestplate_iron.png", "mcl_armor_leggings_iron.png", "mcl_armor_boots_iron.png" ],
		[ tex_dir + "/models/armor/diamond_layer_1.png", tex_dir + "/models/armor/diamond_layer_2.png", target_dir("/mods/ITEMS/mcl_armor/textures"), "mcl_armor_helmet_diamond.png", "mcl_armor_chestplate_diamond.png", "mcl_armor_leggings_diamond.png", "mcl_armor_boots_diamond.png" ],
        [ tex_dir + "/models/armor/netherite_layer_1.png", tex_dir + "/models/armor/netherite_layer_2.png", target_dir("/mods/ITEMS/mcl_armor/textures"), "mcl_armor_helmet_netherite.png", "mcl_armor_chestplate_netherite.png", "mcl_armor_leggings_netherite.png", "mcl_armor_boots_netherite.png" ]
	]
	for a in armor_files:
		APXSIZE = 16	# for some reason MineClone2 requires this
		layer_1 = a[0]
		layer_2 = a[1]
		adir = a[2]
		if os.path.isfile(layer_1):
			helmet = adir + "/" + a[3]
			chestplate = adir + "/" + a[4]
			boots = adir + "/" + a[6]
			os.system("convert -size "+str(APXSIZE * 4)+"x"+str(APXSIZE * 2)+" xc:none \\( "+layer_1+" -scale "+str(APXSIZE * 4)+"x"+str(APXSIZE * 2)+" -geometry +"+str(APXSIZE * 2)+"+0 -crop "+str(APXSIZE * 2)+"x"+str(APXSIZE)+"+0+0 \) -composite -channel A -fx \"(a > 0.0) ? 1.0 : 0.0\" "+helmet)
			os.system("convert -size "+str(APXSIZE * 4)+"x"+str(APXSIZE * 2)+" xc:none \\( "+layer_1+" -scale "+str(APXSIZE * 4)+"x"+str(APXSIZE * 2)+" -geometry +"+str(APXSIZE)+"+"+str(APXSIZE)+" -crop "+str(APXSIZE * 2.5)+"x"+str(APXSIZE)+"+"+str(APXSIZE)+"+"+str(APXSIZE)+" \) -composite -channel A -fx \"(a > 0.0) ? 1.0 : 0.0\" "+chestplate)
			os.system("convert -size "+str(APXSIZE * 4)+"x"+str(APXSIZE * 2)+" xc:none \\( "+layer_1+" -scale "+str(APXSIZE * 4)+"x"+str(APXSIZE * 2)+" -geometry +0+"+str(APXSIZE)+" -crop "+str(APXSIZE)+"x"+str(APXSIZE)+"+0+"+str(APXSIZE)+" \) -composite -channel A -fx \"(a > 0.0) ? 1.0 : 0.0\" "+boots)
		if os.path.isfile(layer_2):
			leggings = adir + "/" + a[5]
			os.system("convert -size "+str(APXSIZE * 4)+"x"+str(APXSIZE * 2)+" xc:none \\( "+layer_2+" -scale "+str(APXSIZE * 4)+"x"+str(APXSIZE * 2)+" -geometry +0+"+str(APXSIZE)+" -crop "+str(APXSIZE * 2.5)+"x"+str(APXSIZE)+"+0+"+str(APXSIZE)+" \) -composite -channel A -fx \"(a > 0.0) ? 1.0 : 0.0\" "+leggings)

	# Convert chest textures (requires ImageMagick)
	chest_files = [
		[ tex_dir + "/entity/chest/normal.png", target_dir("/mods/ITEMS/mcl_chests/textures"), "default_chest_top.png", "mcl_chests_chest_bottom.png", "default_chest_front.png", "mcl_chests_chest_left.png", "mcl_chests_chest_right.png", "mcl_chests_chest_back.png" ],
		[ tex_dir + "/entity/chest/trapped.png", target_dir("/mods/ITEMS/mcl_chests/textures"), "mcl_chests_chest_trapped_top.png", "mcl_chests_chest_trapped_bottom.png", "mcl_chests_chest_trapped_front.png", "mcl_chests_chest_trapped_left.png", "mcl_chests_chest_trapped_right.png", "mcl_chests_chest_trapped_back.png" ],
		[ tex_dir + "/entity/chest/ender.png", target_dir("/mods/ITEMS/mcl_chests/textures"), "mcl_chests_ender_chest_top.png", "mcl_chests_ender_chest_bottom.png", "mcl_chests_ender_chest_front.png", "mcl_chests_ender_chest_left.png", "mcl_chests_ender_chest_right.png", "mcl_chests_ender_chest_back.png" ]
	]

	for c in chest_files:
		chest_file = c[0]
		if os.path.isfile(chest_file):
			PPX = (PXSIZE/16)
			CHPX = (PPX * 14) # Chest width
			LIDPX = (PPX * 5) # Lid height
			LIDLOW = (PPX * 10) # Lower lid section height
			LOCKW = (PPX * 6) # Lock width
			LOCKH = (PPX * 5) # Lock height

			cdir = c[1]
			top = cdir + "/" + c[2]
			bottom = cdir + "/" + c[3]
			front = cdir + "/" + c[4]
			left = cdir + "/" + c[5]
			right = cdir + "/" + c[6]
			back = cdir + "/" + c[7]
			# Top
			os.system("convert " + chest_file + " \
\( -clone 0 -crop "+str(CHPX)+"x"+str(CHPX)+"+"+str(CHPX)+"+0 \) -geometry +0+0 -composite -extent "+str(CHPX)+"x"+str(CHPX)+" "+top)
			# Bottom
			os.system("convert " + chest_file + " \
\( -clone 0 -crop "+str(CHPX)+"x"+str(CHPX)+"+"+str(CHPX*2)+"+"+str(CHPX+LIDPX)+" \) -geometry +0+0 -composite -extent "+str(CHPX)+"x"+str(CHPX)+" "+bottom)
			# Front
			os.system("convert " + chest_file + " \
\( -clone 0 -crop "+str(CHPX)+"x"+str(LIDPX)+"+"+str(CHPX)+"+"+str(CHPX)+" \) -geometry +0+0 -composite \
\( -clone 0 -crop "+str(CHPX)+"x"+str(LIDLOW)+"+"+str(CHPX)+"+"+str(CHPX*2+LIDPX)+" \) -geometry +0+"+str(LIDPX-PPX)+" -composite \
-extent "+str(CHPX)+"x"+str(CHPX)+" "+front)
			# TODO: Add lock

			# Left, right back (use same texture, we're lazy
			files = [ left, right, back ]
			for f in files:
				os.system("convert " + chest_file + " \
\( -clone 0 -crop "+str(CHPX)+"x"+str(LIDPX)+"+"+str(0)+"+"+str(CHPX)+" \) -geometry +0+0 -composite \
\( -clone 0 -crop "+str(CHPX)+"x"+str(LIDLOW)+"+"+str(0)+"+"+str(CHPX*2+LIDPX)+" \) -geometry +0+"+str(LIDPX-PPX)+" -composite \
-extent "+str(CHPX)+"x"+str(CHPX)+" "+f)

	# Double chests

	chest_files = [
		[ tex_dir + "/entity/chest/normal_double.png", target_dir("/mods/ITEMS/mcl_chests/textures"), "default_chest_front_big.png", "default_chest_top_big.png", "default_chest_side_big.png" ],
		[ tex_dir + "/entity/chest/trapped_double.png", target_dir("/mods/ITEMS/mcl_chests/textures"), "mcl_chests_chest_trapped_front_big.png", "mcl_chests_chest_trapped_top_big.png", "mcl_chests_chest_trapped_side_big.png" ]
	]
	for c in chest_files:
		chest_file = c[0]
		if os.path.isfile(chest_file):
			PPX = (PXSIZE/16)
			CHPX = (PPX * 14) # Chest width (short side)
			CHPX2 = (PPX * 15) # Chest width (long side)
			LIDPX = (PPX * 5) # Lid height
			LIDLOW = (PPX * 10) # Lower lid section height
			LOCKW = (PPX * 6) # Lock width
			LOCKH = (PPX * 5) # Lock height

			cdir = c[1]
			front = cdir + "/" + c[2]
			top = cdir + "/" + c[3]
			side = cdir + "/" + c[4]
			# Top
			os.system("convert " + chest_file + " \
\( -clone 0 -crop "+str(CHPX2)+"x"+str(CHPX)+"+"+str(CHPX)+"+0 \) -geometry +0+0 -composite -extent "+str(CHPX2)+"x"+str(CHPX)+" "+top)
			# Front
			# TODO: Add lock
			os.system("convert " + chest_file + " \
\( -clone 0 -crop "+str(CHPX2)+"x"+str(LIDPX)+"+"+str(CHPX)+"+"+str(CHPX)+" \) -geometry +0+0 -composite \
\( -clone 0 -crop "+str(CHPX2)+"x"+str(LIDLOW)+"+"+str(CHPX)+"+"+str(CHPX*2+LIDPX)+" \) -geometry +0+"+str(LIDPX-PPX)+" -composite \
-extent "+str(CHPX2)+"x"+str(CHPX)+" "+front)
			# Side
			os.system("convert " + chest_file + " \
\( -clone 0 -crop "+str(CHPX)+"x"+str(LIDPX)+"+"+str(0)+"+"+str(CHPX)+" \) -geometry +0+0 -composite \
\( -clone 0 -crop "+str(CHPX)+"x"+str(LIDLOW)+"+"+str(0)+"+"+str(CHPX*2+LIDPX)+" \) -geometry +0+"+str(LIDPX-PPX)+" -composite \
-extent "+str(CHPX)+"x"+str(CHPX)+" "+side)


	# Generate railway crossings and t-junctions. Note: They may look strange.
	# Note: these may be only a temporary solution, as crossings and t-junctions do not occour in MC.
	# TODO: Curves
	rails = [
		# (Straigt src, curved src, t-junction dest, crossing dest)
		("rail_normal.png", "rail_normal_turned.png", "default_rail_t_junction.png", "default_rail_crossing.png"),
		("rail_golden.png", "rail_normal_turned.png", "carts_rail_t_junction_pwr.png", "carts_rail_crossing_pwr.png"),
		("rail_golden_powered.png", "rail_normal_turned.png", "mcl_minecarts_rail_golden_t_junction_powered.png", "mcl_minecarts_rail_golden_crossing_powered.png"),
		("rail_detector.png", "rail_normal_turned.png", "mcl_minecarts_rail_detector_t_junction.png", "mcl_minecarts_rail_detector_crossing.png"),
		("rail_detector_powered.png", "rail_normal_turned.png", "mcl_minecarts_rail_detector_t_junction_powered.png", "mcl_minecarts_rail_detector_crossing_powered.png"),
		("rail_activator.png", "rail_normal_turned.png", "mcl_minecarts_rail_activator_t_junction.png", "mcl_minecarts_rail_activator_crossing.png"),
		("rail_activator_powered.png", "rail_normal_turned.png", "mcl_minecarts_rail_activator_d_t_junction.png", "mcl_minecarts_rail_activator_powered_crossing.png"),
	]
	for r in rails:
		os.system("composite -compose Dst_Over "+tex_dir+"/blocks/"+r[0]+" "+tex_dir+"/blocks/"+r[1]+" "+target_dir("/mods/ENTITIES/mcl_minecarts/textures")+"/"+r[2])
		os.system("convert "+tex_dir+"/blocks/"+r[0]+" -rotate 90 "+tempfile1.name)
		os.system("composite -compose Dst_Over "+tempfile1.name+" "+tex_dir+"/blocks/"+r[0]+" "+target_dir("/mods/ENTITIES/mcl_minecarts/textures")+"/"+r[3])

	# Convert banner overlays
	overlays = [
		"base",
		"border",
		"bricks",
		"circle",
		"creeper",
		"cross",
		"curly_border",
		"diagonal_left",
		"diagonal_right",
		"diagonal_up_left",
		"diagonal_up_right",
		"flower",
		"gradient",
		"gradient_up",
		"half_horizontal_bottom",
		"half_horizontal",
		"half_vertical",
		"half_vertical_right",
		"rhombus",
		"mojang",
		"skull",
		"small_stripes",
		"straight_cross",
		"stripe_bottom",
		"stripe_center",
		"stripe_downleft",
		"stripe_downright",
		"stripe_left",
		"stripe_middle",
		"stripe_right",
		"stripe_top",
		"square_bottom_left",
		"square_bottom_right",
		"square_top_left",
		"square_top_right",
		"triangle_bottom",
		"triangles_bottom",
		"triangle_top",
		"triangles_top",
	]
	for o in overlays:
		orig = tex_dir + "/entity/banner/" + o + ".png"
		if os.path.isfile(orig):
			if o == "mojang":
				o = "thing"
			dest = target_dir("/mods/ITEMS/mcl_banners/textures")+"/"+"mcl_banners_"+o+".png"
			os.system("convert "+orig+" -transparent-color white -background black -alpha remove -alpha copy -channel RGB -white-threshold 0 "+dest)

	# Convert grass
	grass_file = tex_dir + "/blocks/grass_top.png"
	if os.path.isfile(grass_file):
		FOLIAG = tex_dir+"/colormap/foliage.png"
		GRASS = tex_dir+"/colormap/grass.png"


		# Leaves
		colorize_alpha(FOLIAG, tex_dir+"/blocks/leaves_oak.png", "116+143", str(PXSIZE), target_dir("/mods/ITEMS/mcl_core/textures")+"/default_leaves.png")
		colorize_alpha(FOLIAG, tex_dir+"/blocks/leaves_big_oak.png", "158+177", str(PXSIZE), target_dir("/mods/ITEMS/mcl_core/textures")+"/mcl_core_leaves_big_oak.png")
		colorize_alpha(FOLIAG, tex_dir+"/blocks/leaves_acacia.png", "40+255", str(PXSIZE), target_dir("/mods/ITEMS/mcl_core/textures")+"/default_acacia_leaves.png")
		colorize_alpha(FOLIAG, tex_dir+"/blocks/leaves_spruce.png", "226+230", str(PXSIZE), target_dir("/mods/ITEMS/mcl_core/textures")+"/mcl_core_leaves_spruce.png")
		colorize_alpha(FOLIAG, tex_dir+"/blocks/leaves_birch.png", "141+186", str(PXSIZE), target_dir("/mods/ITEMS/mcl_core/textures")+"/mcl_core_leaves_birch.png")
		colorize_alpha(FOLIAG, tex_dir+"/blocks/leaves_jungle.png", "16+39", str(PXSIZE), target_dir("/mods/ITEMS/mcl_core/textures")+"/default_jungleleaves.png")

		# Waterlily
		colorize_alpha(FOLIAG, tex_dir+"/blocks/waterlily.png", "16+39", str(PXSIZE), target_dir("/mods/ITEMS/mcl_flowers/textures")+"/flowers_waterlily.png")

		# Vines
		colorize_alpha(FOLIAG, tex_dir+"/blocks/vine.png", "16+39", str(PXSIZE), target_dir("/mods/ITEMS/mcl_core/textures")+"/mcl_core_vine.png")

		# Tall grass, fern (inventory images)
		pcol = "49+172" # Plains grass color
		colorize_alpha(GRASS, tex_dir+"/blocks/tallgrass.png", pcol, str(PXSIZE), target_dir("/mods/ITEMS/mcl_flowers/textures")+"/mcl_flowers_tallgrass_inv.png")
		colorize_alpha(GRASS, tex_dir+"/blocks/fern.png", pcol, str(PXSIZE), target_dir("/mods/ITEMS/mcl_flowers/textures")+"/mcl_flowers_fern_inv.png")
		colorize_alpha(GRASS, tex_dir+"/blocks/double_plant_fern_top.png", pcol, str(PXSIZE), target_dir("/mods/ITEMS/mcl_flowers/textures")+"/mcl_flowers_double_plant_fern_inv.png")
		colorize_alpha(GRASS, tex_dir+"/blocks/double_plant_grass_top.png", pcol, str(PXSIZE), target_dir("/mods/ITEMS/mcl_flowers/textures")+"/mcl_flowers_double_plant_grass_inv.png")

		# TODO: Convert grass palette

		offset = [
			[ pcol, "", "grass" ], # Default grass: Plains
		]
		for o in offset:
			colorize(GRASS, tex_dir+"/blocks/grass_top.png", o[0], str(PXSIZE), target_dir("/mods/ITEMS/mcl_core/textures")+"/default_"+o[2]+".png")
			colorize_alpha(GRASS, tex_dir+"/blocks/grass_side_overlay.png", o[0], str(PXSIZE), target_dir("/mods/ITEMS/mcl_core/textures")+"/default_"+o[2]+"_side.png")

		# Metadata
		if make_texture_pack:
			# Create description file
			description = "Texture pack for MineClone 2. Automatically converted from a Minecraft resource pack by the MineClone 2 Texture Converter. Size: "+str(PXSIZE)+"×"+str(PXSIZE)
			description_file = open(target_dir("/") + "/description.txt", "w")
			description_file.write(description)
			description_file.close()

			# Create preview image (screenshot.png)
			os.system("convert -size 300x200 canvas:transparent "+target_dir("/") + "/screenshot.png")
			os.system("composite "+base_dir+"/pack.png "+target_dir("/") + "/screenshot.png -gravity center "+target_dir("/") + "/screenshot.png")

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
