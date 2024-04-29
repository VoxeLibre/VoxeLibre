from .special_convert_cases import convert_map_textures, convert_armor_textures, convert_chest_textures, convert_rail_textures, convert_banner_overlays, convert_grass_textures
from .utils import target_dir, colorize, colorize_alpha
import shutil
import csv
import os
import tempfile
import sys
import argparse
import glob


def convert_standard_textures(
    make_texture_pack,
    dry_run,
    verbose,
    base_dir,
    tex_dir,
    tempfile1,
    tempfile2,
    output_dir,
    output_dir_name,
    mineclone2_path,
     PXSIZE):
    failed_conversions = 0
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
            dst_dir = './textures'
            dst_filename = row[2]
            if row[4] != "":
                xs = int(row[3])
                ys = int(row[4])
                xl = int(row[5])
                yl = int(row[6])
                xt = int(row[7])
                yt = int(row[8])
            else:
                xs = None
            blacklisted = row[9]

            if blacklisted == "y":
                # Skip blacklisted files
                continue

            if make_texture_pack == False and dst_dir == "":
                # If destination dir is empty, this texture is not supposed to be used in MCL2
                # (but maybe an external mod). It should only be used in texture packs.
                # Otherwise, it must be ignored.
                # Example: textures for mcl_supplemental
                continue

            src_file = base_dir + src_dir + "/" + src_filename  # source file
            src_file_exists = os.path.isfile(src_file)
            dst_file = target_dir(dst_dir, make_texture_pack, output_dir, output_dir_name,
			                      mineclone2_path) + "/" + dst_filename  # destination file

            if src_file_exists == False:
                print("WARNING: Source file does not exist: " + src_file)
                failed_conversions = failed_conversions + 1
                continue
            if xs != None:
                # Crop and copy images
                if not dry_run:
                    crop_width = int(xl)
                    crop_height = int(yl)
                    offset_x = int(xs)
                    offset_y = int(ys)
                    with Image(filename=src_file) as img:
                        # Crop the image
                        img.crop(left=offset_x, top=offset_y, width=crop_width, height=crop_height)
                        # Save the result
                        img.save(filename=dst_file)
                if verbose:
                    print(src_file + " → " + dst_file)
            else:
				# Copy image verbatim
                if not dry_run:
                    shutil.copy2(src_file, dst_file)
                if verbose:
                    print(src_file + " → " + dst_file)
    return failed_conversions


def convert_textures(make_texture_pack, dry_run, verbose, base_dir, tex_dir, tempfile1, tempfile2, output_dir, output_dir_name, mineclone2_path, PXSIZE):
	print("Texture conversion BEGINS NOW!")

	# Convert textures listed in the Conversion_Table.csv
	failed_conversions = convert_standard_textures(make_texture_pack, dry_run, verbose, base_dir, tex_dir,
	                          tempfile1, tempfile2, output_dir, output_dir_name, mineclone2_path, PXSIZE)

	# Conversion of map backgrounds
	convert_map_textures(make_texture_pack, dry_run, verbose, base_dir, tex_dir,
	                     tempfile1, tempfile2, output_dir, output_dir_name, mineclone2_path, PXSIZE)

    # Convert armor textures
	convert_armor_textures(make_texture_pack, dry_run, verbose, base_dir, tex_dir, tempfile1, tempfile2,output_dir, output_dir_name, mineclone2_path, PXSIZE)

    # Convert chest textures
	convert_chest_textures(make_texture_pack, dry_run, verbose, base_dir, tex_dir, tempfile1, tempfile2,output_dir, output_dir_name, mineclone2_path, PXSIZE)

    # Generate railway crossings and t-junctions
	convert_rail_textures(make_texture_pack, dry_run, verbose, base_dir, tex_dir, tempfile1, tempfile2,output_dir, output_dir_name, mineclone2_path, PXSIZE)

    # Convert banner overlays
	convert_banner_overlays(make_texture_pack, dry_run, verbose, base_dir, tex_dir, tempfile1, tempfile2,output_dir, output_dir_name, mineclone2_path, PXSIZE)

    # Convert grass and related textures
	convert_grass_textures(make_texture_pack, dry_run, verbose, base_dir, tex_dir, tempfile1, tempfile2,output_dir, output_dir_name, mineclone2_path, PXSIZE)

	# Metadata
	if make_texture_pack:
		# Create description file
		description = "Texture pack for MineClone 2. Automatically converted from a Minecraft resource pack by the MineClone 2 Texture Converter. Size: "+str(PXSIZE)+"×"+str(PXSIZE)
		description_file = open(target_dir("/", make_texture_pack, output_dir, output_dir_name, mineclone2_path) + "/description.txt", "w")
		description_file.write(description)
		description_file.close()

		# Create override file
		shutil.copyfile("override.txt", target_dir("/", make_texture_pack, output_dir, output_dir_name, mineclone2_path) + "/override.txt")

		# Create preview image (screenshot.png)
		os.system("convert -size 300x200 canvas:transparent "+target_dir("/", make_texture_pack, output_dir, output_dir_name, mineclone2_path) + "/screenshot.png")
		os.system("composite "+base_dir+"/pack.png "+target_dir("/", make_texture_pack, output_dir, output_dir_name, mineclone2_path) + "/screenshot.png -gravity center "+target_dir("/", make_texture_pack, output_dir, output_dir_name, mineclone2_path) + "/screenshot.png")

	print("Textures conversion COMPLETE!")
	if failed_conversions > 0:
		print("WARNING: Number of missing files in original resource pack: " + str(failed_conversions))
	print("NOTE: Please keep in mind this script does not reliably convert all the textures yet.")
	if make_texture_pack:
		print("You can now retrieve the texture pack in " + output_dir + "/" + output_dir_name + "/")
