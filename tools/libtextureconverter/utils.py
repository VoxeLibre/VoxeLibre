import shutil, csv, os, tempfile, sys, argparse, glob
from PIL import Image
from collections import Counter

def detect_pixel_size(directory):
    sizes = []
    for filename in glob.glob(directory + '/**/*.png', recursive=True):
        with Image.open(filename) as img:
            sizes.append(img.size)
    if not sizes:
        return 16  # Default to 16x16 if no PNG files are found
    most_common_size = Counter(sizes).most_common(1)[0][0]
    print(f"Autodetected pixel size: {most_common_size[0]}x{most_common_size[1]}")
    return most_common_size[0]

def target_dir(directory, make_texture_pack, output_dir, output_dir_name, mineclone2_path):
	if make_texture_pack:
		return output_dir + "/" + output_dir_name
	else:
		return mineclone2_path + directory

def colorize(colormap, source, colormap_pixel, texture_size, destination, tempfile1_name):
	os.system("convert "+colormap+" -crop 1x1+"+colormap_pixel+" -depth 8 -resize "+texture_size+"x"+texture_size+" "+tempfile1_name)
	os.system("composite -compose Multiply "+tempfile1_name+" "+source+" "+destination)

def colorize_alpha(colormap, source, colormap_pixel, texture_size, destination, tempfile2_name):
	colorize(colormap, source, colormap_pixel, texture_size, destination, tempfile2_name)
	os.system("composite -compose Dst_In "+source+" "+tempfile2_name+" -alpha Set "+destination)
