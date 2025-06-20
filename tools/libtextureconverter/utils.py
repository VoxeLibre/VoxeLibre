import shutil
import csv
import os
import tempfile
import sys
import argparse
import glob
import re
import zipfile
from .config import SUPPORTED_MINECRAFT_VERSION, home
from collections import Counter
import platform
try:
    from wand.image import Image
except:
    print("ERROR: Module \"Wand\" not found. You have to install it manually.\n")
    print("Use this command: pip install wand")
    exit(1)
from wand.color import Color
from wand.display import display
import warnings

def detect_pixel_size(directory):
    from PIL import Image
    sizes = []
    for filename in glob.glob(directory + '/**/*.png', recursive=True):
        with Image.open(filename) as img:
            sizes.append(img.size)
    if not sizes:
        return 16  # Default to 16x16 if no PNG files are found
    most_common_size = Counter(sizes).most_common(1)[0][0]
    print(
        f"Autodetected pixel size: {most_common_size[0]}x{most_common_size[1]}")
    return most_common_size[0]

def target_dir(
        directory,
        make_texture_pack,
        output_dir,
        output_dir_name,
        mineclone2_path):
    if make_texture_pack:
        return output_dir + "/" + output_dir_name
    else:
        return mineclone2_path + directory


def colorize(colormap, source, colormap_pixel, texture_size, destination, tempfile1_name):
    try:
        # Convert the colormap_pixel to integer coordinates
        x, y = map(int, colormap_pixel.split('+'))

        # Define texture size as integer
        texture_size = int(texture_size)

        with Image(filename=colormap) as img:
            # Crop the image
            img.crop(x, y, width=1, height=1)

            # Set depth (This might be ignored by Wand as it manages depth automatically)
            img.depth = 8

            # Resize the image
            img.resize(texture_size, texture_size)

            # Save the result
            img.save(filename=tempfile1_name)

    except Exception as e:
        warnings.warn(f"An error occurred during the first image processing operation: {e}")

    try:
        # Load the images
        with Image(filename=tempfile1_name) as top_image:
            with Image(filename=source) as bottom_image:
                # Perform composite operation with Multiply blend mode
                bottom_image.composite(top_image, 0, 0, operator='multiply')

                # Save the result
                bottom_image.save(filename=destination)

    except Exception as e:
        warnings.warn(f"An error occurred during the second image processing operation: {e}")


def colorize_alpha(
        colormap,
        source,
        colormap_pixel,
        texture_size,
        destination,
        tempfile2_name):
    colorize(colormap, source, colormap_pixel,
             texture_size, destination, tempfile2_name)
    try:
        with Image(filename=source) as source_image:
            with Image(filename=tempfile2_name) as tempfile2_image:
                # Perform composite operation with Dst_In blend mode
                tempfile2_image.composite(source_image, 0, 0, operator='dst_in')

                # Set alpha channel
                tempfile2_image.alpha_channel = 'set'

                # Save the result
                tempfile2_image.save(filename=destination)
    except Exception as e:
        warnings.warn(f"An error occurred during the second image processing operation: {e}")


def find_highest_minecraft_version(home, supported_version):
    version_pattern = re.compile(re.escape(supported_version) + r"\.\d+")
    versions_dir = os.path.join(home, ".minecraft", "versions")
    highest_version = None
    if os.path.isdir(versions_dir):
        for folder in os.listdir(versions_dir):
            if version_pattern.match(folder):
                if not highest_version or folder > highest_version:
                    highest_version = folder
    return highest_version


def find_all_minecraft_resourcepacks():
    resourcepacks_dir = os.path.join(home, '.minecraft', 'resourcepacks')

    if not os.path.isdir(resourcepacks_dir):
        print(f"Resource packs directory not found: {resourcepacks_dir}")
        return

    resourcepacks = []
    for folder in os.listdir(resourcepacks_dir):
        folder_path = os.path.join(resourcepacks_dir, folder)
        if os.path.isdir(folder_path):
            pack_png_path = os.path.join(folder_path, 'pack.png')
            if os.path.isfile(pack_png_path):
                print(f"Adding resourcepack '{folder}'")
                resourcepacks.append(folder_path)
            else:
                print(
                    f"pack.png not found in resourcepack '{folder}', not converting")

    return resourcepacks


def handle_default_minecraft_texture(home, output_dir):
    version = find_highest_minecraft_version(home, SUPPORTED_MINECRAFT_VERSION)
    if not version:
        print("No suitable Minecraft version found.")
        sys.exit(1)

    jar_file = os.path.join(
        home, ".minecraft", "versions", version, f"{version}.jar")
    if not os.path.isfile(jar_file):
        print("Minecraft JAR file not found.")
        sys.exit(1)

    temp_zip = f"/tmp/mc-default-{version.replace('.', '')}.zip"
    shutil.copy2(jar_file, temp_zip)

    extract_folder = temp_zip.replace(".zip", "")
    with zipfile.ZipFile(temp_zip, 'r') as zip_ref:
        zip_ref.extractall(extract_folder)

    if not os.path.exists(extract_folder):
        print(f"Extraction failed, folder not found: {extract_folder}")
        sys.exit(1)

    # Normalize the extract folder path
    extract_folder = os.path.normpath(extract_folder)

    # Define the textures directory and normalize it
    textures_directory = os.path.normpath(
        f"{extract_folder}/assets/minecraft/textures")

    # Using glob to find all files
    all_files = glob.glob(f"{extract_folder}/**/*.*", recursive=True)

    # Remove all non-png files except pack.mcmeta and pack.png in the root
    for file_path in all_files:
        if not file_path.endswith('.png') and not file_path.endswith(
                'pack.mcmeta') and not file_path.endswith('pack.png'):
            # print(f"Removing file: {file_path}")
            os.remove(file_path)

    # Remove all directories in the root except 'assets'
    for item in os.listdir(extract_folder):
        item_path = os.path.join(extract_folder, item)
        if os.path.isdir(item_path) and item != "assets":
            # print(f"Removing directory: {item_path}")
            shutil.rmtree(item_path, ignore_errors=True)

    # Remove directories in 'minecraft' except for 'textures'
    minecraft_directory = os.path.normpath(
        f"{extract_folder}/assets/minecraft")
    for item in os.listdir(minecraft_directory):
        item_path = os.path.join(minecraft_directory, item)
        if os.path.isdir(item_path) and item != "textures":
            print(f"Removing directory: {item_path}")
            shutil.rmtree(item_path, ignore_errors=True)

    # Copy the textures directory to the output directory
    output_textures_directory = os.path.join(
        output_dir, 'assets/minecraft/textures')
    if os.path.exists(textures_directory) and not os.path.exists(
            output_textures_directory):
        os.makedirs(os.path.dirname(output_textures_directory), exist_ok=True)
        shutil.copytree(textures_directory,
                        output_textures_directory, dirs_exist_ok=True)

    # Copy pack.mcmeta and pack.png file if exists
    for file_name in ['pack.mcmeta', 'pack.png']:
        file_path = os.path.join(extract_folder, file_name)
        if os.path.exists(file_path):
            shutil.copy(file_path, output_dir)

    print(f"Filtered and extracted to: {extract_folder}")
    return extract_folder
