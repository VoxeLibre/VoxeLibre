import shutil, csv, os, tempfile, sys, argparse, glob, re, zipfile
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

def find_highest_minecraft_version(home):
    version_pattern = re.compile(r"1\.20\.\d+")
    versions_dir = os.path.join(home, ".minecraft", "versions")
    highest_version = None
    if os.path.isdir(versions_dir):
        for folder in os.listdir(versions_dir):
            if version_pattern.match(folder):
                if not highest_version or folder > highest_version:
                    highest_version = folder
    return highest_version

def handle_default_minecraft_texture(home, output_dir):
    version = find_highest_minecraft_version(home)
    if not version:
        print("No suitable Minecraft version found.")
        sys.exit(1)

    jar_file = os.path.join(home, ".minecraft", "versions", version, f"{version}.jar")
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
    textures_directory = os.path.normpath(f"{extract_folder}/assets/minecraft/textures")

    # Using glob to find all files
    all_files = glob.glob(f"{extract_folder}/**/*.*", recursive=True)

    # Remove all non-png files except pack.mcmeta and pack.png in the root
    for file_path in all_files:
        if not file_path.endswith('.png') and not file_path.endswith('pack.mcmeta') and not file_path.endswith('pack.png'):
            #print(f"Removing file: {file_path}")
            os.remove(file_path)

    # Remove all directories in the root except 'assets'
    for item in os.listdir(extract_folder):
        item_path = os.path.join(extract_folder, item)
        if os.path.isdir(item_path) and item != "assets":
            #print(f"Removing directory: {item_path}")
            shutil.rmtree(item_path, ignore_errors=True)

    # Remove directories in 'minecraft' except for 'textures'
    minecraft_directory = os.path.normpath(f"{extract_folder}/assets/minecraft")
    for item in os.listdir(minecraft_directory):
        item_path = os.path.join(minecraft_directory, item)
        if os.path.isdir(item_path) and item != "textures":
            print(f"Removing directory: {item_path}")
            shutil.rmtree(item_path, ignore_errors=True)

    # Copy the textures directory to the output directory
    output_textures_directory = os.path.join(output_dir, 'assets/minecraft/textures')
    if os.path.exists(textures_directory) and not os.path.exists(output_textures_directory):
        os.makedirs(os.path.dirname(output_textures_directory), exist_ok=True)
        shutil.copytree(textures_directory, output_textures_directory, dirs_exist_ok=True)

    # Copy pack.mcmeta and pack.png file if exists
    for file_name in ['pack.mcmeta', 'pack.png']:
        file_path = os.path.join(extract_folder, file_name)
        if os.path.exists(file_path):
            shutil.copy(file_path, output_dir)

    print(f"Filtered and extracted to: {extract_folder}")
    return extract_folder
