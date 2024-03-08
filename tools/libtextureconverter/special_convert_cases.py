import os
from .utils import target_dir, colorize, colorize_alpha
import shutil
import csv
import tempfile
import sys
import argparse
import glob
from wand.image import Image
from wand.color import Color
from wand.display import display
from wand.drawing import Drawing
import warnings

# Conversion of map backgrounds
def convert_map_textures(
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
    # Convert map background
    map_background_file = tex_dir + "/map/map_background.png"
    if os.path.isfile(map_background_file):
        destination_path = target_dir("/mods/ITEMS/mcl_maps/textures", make_texture_pack, output_dir, output_dir_name, mineclone2_path) + "/mcl_maps_map_background.png"

        with Image(filename=map_background_file) as img:
            # Resize the image with 'point' filter
            img.resize(140, 140, filter='point')

            # Save the result
            img.save(filename=destination_path)


# Convert armor textures

def convert_armor_textures(
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
    # Convert armor textures (requires ImageMagick)
    armor_files = [[tex_dir + "/models/armor/leather_layer_1.png",
                    tex_dir + "/models/armor/leather_layer_2.png",
                    target_dir("/mods/ITEMS/mcl_armor/textures",
                               make_texture_pack,
                               output_dir,
                               output_dir_name,
                               mineclone2_path),
                    "mcl_armor_helmet_leather.png",
                    "mcl_armor_chestplate_leather.png",
                    "mcl_armor_leggings_leather.png",
                    "mcl_armor_boots_leather.png"],
                   [tex_dir + "/models/armor/chainmail_layer_1.png",
                    tex_dir + "/models/armor/chainmail_layer_2.png",
                    target_dir("/mods/ITEMS/mcl_armor/textures",
                               make_texture_pack,
                               output_dir,
                               output_dir_name,
                               mineclone2_path),
                    "mcl_armor_helmet_chain.png",
                    "mcl_armor_chestplate_chain.png",
                    "mcl_armor_leggings_chain.png",
                    "mcl_armor_boots_chain.png"],
                   [tex_dir + "/models/armor/gold_layer_1.png",
                    tex_dir + "/models/armor/gold_layer_2.png",
                    target_dir("/mods/ITEMS/mcl_armor/textures",
                               make_texture_pack,
                               output_dir,
                               output_dir_name,
                               mineclone2_path),
                    "mcl_armor_helmet_gold.png",
                    "mcl_armor_chestplate_gold.png",
                    "mcl_armor_leggings_gold.png",
                    "mcl_armor_boots_gold.png"],
                   [tex_dir + "/models/armor/iron_layer_1.png",
                    tex_dir + "/models/armor/iron_layer_2.png",
                    target_dir("/mods/ITEMS/mcl_armor/textures",
                               make_texture_pack,
                               output_dir,
                               output_dir_name,
                               mineclone2_path),
                    "mcl_armor_helmet_iron.png",
                    "mcl_armor_chestplate_iron.png",
                    "mcl_armor_leggings_iron.png",
                    "mcl_armor_boots_iron.png"],
                   [tex_dir + "/models/armor/diamond_layer_1.png",
                    tex_dir + "/models/armor/diamond_layer_2.png",
                    target_dir("/mods/ITEMS/mcl_armor/textures",
                               make_texture_pack,
                               output_dir,
                               output_dir_name,
                               mineclone2_path),
                    "mcl_armor_helmet_diamond.png",
                    "mcl_armor_chestplate_diamond.png",
                    "mcl_armor_leggings_diamond.png",
                    "mcl_armor_boots_diamond.png"],
                   [tex_dir + "/models/armor/netherite_layer_1.png",
                    tex_dir + "/models/armor/netherite_layer_2.png",
                    target_dir("/mods/ITEMS/mcl_armor/textures",
                               make_texture_pack,
                               output_dir,
                               output_dir_name,
                               mineclone2_path),
                    "mcl_armor_helmet_netherite.png",
                    "mcl_armor_chestplate_netherite.png",
                    "mcl_armor_leggings_netherite.png",
                    "mcl_armor_boots_netherite.png"]]
    for a in armor_files:
        APXSIZE = 16  # for some reason MineClone2 requires this
        layer_1 = a[0]
        layer_2 = a[1]
        adir = a[2]
        if os.path.isfile(layer_1):
            helmet = adir + "/" + a[3]
            chestplate = adir + "/" + a[4]
            boots = adir + "/" + a[6]
            # helmet
            os.system("convert -size " +
                      str(APXSIZE *
                          4) +
                      "x" +
                      str(APXSIZE *
                          2) +
                      " xc:none \\( " +
                      layer_1 +
                      " -scale " +
                      str(APXSIZE *
                          4) +
                      "x" +
                      str(APXSIZE *
                          2) +
                      " -geometry +" +
                      str(APXSIZE *
                          2) +
                      "+0 -crop " +
                      str(APXSIZE *
                          2) +
                      "x" +
                      str(APXSIZE) +
                      "+0+0 \\) -composite -channel A -fx \"(a > 0.0) ? 1.0 : 0.0\" " +
                      helmet)



            # chestplate
            with Image(width=APXSIZE * 4, height=APXSIZE * 2, background=Color('none')) as img:
                # Load layer_1 and scale
                with Image(filename=layer_1) as layer1:
                    layer1.resize(APXSIZE * 4, APXSIZE * 2)

                    # Define the crop geometry
                    crop_width = int(APXSIZE * 2.5)
                    crop_height = APXSIZE
                    crop_x = APXSIZE
                    crop_y = APXSIZE

                    # Crop the image
                    layer1.crop(crop_x, crop_y, width=crop_width, height=crop_height)

                    # Composite layer1 over the transparent image
                    img.composite(layer1, APXSIZE, APXSIZE)

                # Apply channel operation
                img.fx("a > 0.0 ? 1.0 : 0.0", channel='alpha')

                # Save the result
                img.save(filename=chestplate)
            with Image(width=APXSIZE * 4, height=APXSIZE * 2, background=Color('none')) as img:
                with Image(filename=layer_1) as layer1:
                    # Scale the image
                    layer1.resize(APXSIZE * 4, APXSIZE * 2)

                    # Crop the image
                    crop_x = 0
                    crop_y = APXSIZE
                    crop_width = APXSIZE
                    crop_height = APXSIZE
                    layer1.crop(crop_x, crop_y, width=crop_width, height=crop_height)

                    # Composite the cropped image over the transparent image
                    img.composite(layer1, 0, APXSIZE)

                # Apply the channel operation
                img.fx("a > 0.0 ? 1.0 : 0.0", channel='alpha')

                # Save the result
                img.save(filename=boots)

        if os.path.isfile(layer_2):
            leggings = adir + "/" + a[5]
            with Image(width=APXSIZE * 4, height=APXSIZE * 2, background=Color('none')) as img:
                with Image(filename=layer_2) as layer2:
                    # Scale the image
                    layer2.resize(APXSIZE * 4, APXSIZE * 2)

                    # Apply geometry and crop
                    crop_width = int(APXSIZE * 2.5)
                    crop_height = APXSIZE
                    crop_x = 0
                    crop_y = APXSIZE
                    layer2.crop(left=crop_x, top=crop_y, width=crop_width, height=crop_height)

                    # Composite the cropped image over the transparent image
                    img.composite(layer2, 0, APXSIZE)

                # Apply channel operation
                img.fx("a > 0.0 ? 1.0 : 0.0", channel='alpha')

                # Save the result
                img.save(filename=leggings)

# Convert chest textures


def convert_chest_textures(
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
    # Convert chest textures (requires ImageMagick)
    chest_files = [[tex_dir + "/entity/chest/normal.png",
                    target_dir("/mods/ITEMS/mcl_chests/textures",
                               make_texture_pack,
                               output_dir,
                               output_dir_name,
                               mineclone2_path),
                    "default_chest_top.png",
                    "mcl_chests_chest_bottom.png",
                    "default_chest_front.png",
                    "mcl_chests_chest_left.png",
                    "mcl_chests_chest_right.png",
                    "mcl_chests_chest_back.png"],
                   [tex_dir + "/entity/chest/trapped.png",
                    target_dir("/mods/ITEMS/mcl_chests/textures",
                               make_texture_pack,
                               output_dir,
                               output_dir_name,
                               mineclone2_path),
                    "mcl_chests_chest_trapped_top.png",
                    "mcl_chests_chest_trapped_bottom.png",
                    "mcl_chests_chest_trapped_front.png",
                    "mcl_chests_chest_trapped_left.png",
                    "mcl_chests_chest_trapped_right.png",
                    "mcl_chests_chest_trapped_back.png"],
                   [tex_dir + "/entity/chest/ender.png",
                    target_dir("/mods/ITEMS/mcl_chests/textures",
                               make_texture_pack,
                               output_dir,
                               output_dir_name,
                               mineclone2_path),
                    "mcl_chests_ender_chest_top.png",
                    "mcl_chests_ender_chest_bottom.png",
                    "mcl_chests_ender_chest_front.png",
                    "mcl_chests_ender_chest_left.png",
                    "mcl_chests_ender_chest_right.png",
                    "mcl_chests_ender_chest_back.png"]]

    for c in chest_files:
        chest_file = c[0]
        if os.path.isfile(chest_file):
            PPX = (PXSIZE / 16)
            CHPX = (PPX * 14)  # Chest width
            LIDPX = (PPX * 5)  # Lid height
            LIDLOW = (PPX * 10)  # Lower lid section height
            LOCKW = (PPX * 6)  # Lock width
            LOCKH = (PPX * 5)  # Lock height

            cdir = c[1]
            top = cdir + "/" + c[2]
            bottom = cdir + "/" + c[3]
            front = cdir + "/" + c[4]
            left = cdir + "/" + c[5]
            right = cdir + "/" + c[6]
            back = cdir + "/" + c[7]
            # Top
            os.system("convert " + chest_file + " \
\\( -clone 0 -crop " + str(CHPX) + "x" + str(CHPX) + "+" + str(CHPX) + "+0 \\) -geometry +0+0 -composite -extent " + str(CHPX) + "x" + str(CHPX) + " " + top)
            # Bottom
            os.system("convert " + chest_file + " \
\\( -clone 0 -crop " + str(CHPX) + "x" + str(CHPX) + "+" + str(CHPX * 2) + "+" + str(CHPX + LIDPX) + " \\) -geometry +0+0 -composite -extent " + str(CHPX) + "x" + str(CHPX) + " " + bottom)
            # Front
            os.system("convert " + chest_file + " \
\\( -clone 0 -crop " + str(CHPX) + "x" + str(LIDPX) + "+" + str(CHPX) + "+" + str(CHPX) + " \\) -geometry +0+0 -composite \
\\( -clone 0 -crop " + str(CHPX) + "x" + str(LIDLOW) + "+" + str(CHPX) + "+" + str(CHPX * 2 + LIDPX) + " \\) -geometry +0+" + str(LIDPX - PPX) + " -composite \
-extent " + str(CHPX) + "x" + str(CHPX) + " " + front)
            # TODO: Add lock

            # Left, right back (use same texture, we're lazy
            files = [left, right, back]
            for f in files:
                os.system("convert " + chest_file + " \
\\( -clone 0 -crop " + str(CHPX) + "x" + str(LIDPX) + "+" + str(0) + "+" + str(CHPX) + " \\) -geometry +0+0 -composite \
\\( -clone 0 -crop " + str(CHPX) + "x" + str(LIDLOW) + "+" + str(0) + "+" + str(CHPX * 2 + LIDPX) + " \\) -geometry +0+" + str(LIDPX - PPX) + " -composite \
-extent " + str(CHPX) + "x" + str(CHPX) + " " + f)

    # Double chests

    chest_files = [[tex_dir + "/entity/chest/normal_double.png",
                    target_dir("/mods/ITEMS/mcl_chests/textures",
                               make_texture_pack,
                               output_dir,
                               output_dir_name,
                               mineclone2_path),
                    "default_chest_front_big.png",
                    "default_chest_top_big.png",
                    "default_chest_side_big.png"],
                   [tex_dir + "/entity/chest/trapped_double.png",
                    target_dir("/mods/ITEMS/mcl_chests/textures",
                               make_texture_pack,
                               output_dir,
                               output_dir_name,
                               mineclone2_path),
                    "mcl_chests_chest_trapped_front_big.png",
                    "mcl_chests_chest_trapped_top_big.png",
                    "mcl_chests_chest_trapped_side_big.png"]]
    for c in chest_files:
        chest_file = c[0]
        if os.path.isfile(chest_file):
            PPX = (PXSIZE / 16)
            CHPX = (PPX * 14)  # Chest width (short side)
            CHPX2 = (PPX * 15)  # Chest width (long side)
            LIDPX = (PPX * 5)  # Lid height
            LIDLOW = (PPX * 10)  # Lower lid section height
            LOCKW = (PPX * 6)  # Lock width
            LOCKH = (PPX * 5)  # Lock height

            cdir = c[1]
            front = cdir + "/" + c[2]
            top = cdir + "/" + c[3]
            side = cdir + "/" + c[4]
            # Top
            os.system("convert " + chest_file + " \
\\( -clone 0 -crop " + str(CHPX2) + "x" + str(CHPX) + "+" + str(CHPX) + "+0 \\) -geometry +0+0 -composite -extent " + str(CHPX2) + "x" + str(CHPX) + " " + top)
            # Front
            # TODO: Add lock
            os.system("convert " + chest_file + " \
\\( -clone 0 -crop " + str(CHPX2) + "x" + str(LIDPX) + "+" + str(CHPX) + "+" + str(CHPX) + " \\) -geometry +0+0 -composite \
\\( -clone 0 -crop " + str(CHPX2) + "x" + str(LIDLOW) + "+" + str(CHPX) + "+" + str(CHPX * 2 + LIDPX) + " \\) -geometry +0+" + str(LIDPX - PPX) + " -composite \
-extent " + str(CHPX2) + "x" + str(CHPX) + " " + front)
            # Side
            os.system("convert " + chest_file + " \
\\( -clone 0 -crop " + str(CHPX) + "x" + str(LIDPX) + "+" + str(0) + "+" + str(CHPX) + " \\) -geometry +0+0 -composite \
\\( -clone 0 -crop " + str(CHPX) + "x" + str(LIDLOW) + "+" + str(0) + "+" + str(CHPX * 2 + LIDPX) + " \\) -geometry +0+" + str(LIDPX - PPX) + " -composite \
-extent " + str(CHPX) + "x" + str(CHPX) + " " + side)

# Generate railway crossings and t-junctions


def convert_rail_textures(
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
    # Generate railway crossings and t-junctions. Note: They may look strange.
    # Note: these may be only a temporary solution, as crossings and t-junctions do not occour in MC.
    # TODO: Curves
    rails = [
        # (Straigt src, curved src, t-junction dest, crossing dest)
        ("rail.png", "rail_corner.png",
         "default_rail_t_junction.png", "default_rail_crossing.png"),
        ("powered_rail.png", "rail_corner.png",
         "carts_rail_t_junction_pwr.png", "carts_rail_crossing_pwr.png"),
        ("powered_rail_on.png", "rail_corner.png", "mcl_minecarts_rail_golden_t_junction_powered.png",
         "mcl_minecarts_rail_golden_crossing_powered.png"),
        ("detector_rail.png", "rail_corner.png", "mcl_minecarts_rail_detector_t_junction.png",
         "mcl_minecarts_rail_detector_crossing.png"),
        ("detector_rail_on.png", "rail_corner.png", "mcl_minecarts_rail_detector_t_junction_powered.png",
         "mcl_minecarts_rail_detector_crossing_powered.png"),
        ("activator_rail.png", "rail_corner.png", "mcl_minecarts_rail_activator_t_junction.png",
         "mcl_minecarts_rail_activator_crossing.png"),
        ("activator_rail_on.png", "rail_corner.png", "mcl_minecarts_rail_activator_d_t_junction.png",
         "mcl_minecarts_rail_activator_powered_crossing.png"),
    ]
    for r in rails:
        os.system(
            "composite -compose Dst_Over " +
            tex_dir +
            "/block/" +
            r[0] +
            " " +
            tex_dir +
            "/block/" +
            r[1] +
            " " +
            target_dir(
                "/mods/ENTITIES/mcl_minecarts/textures",
                make_texture_pack,
                output_dir,
                output_dir_name,
                mineclone2_path) +
            "/" +
            r[2])
        os.system("convert " + tex_dir + "/block/" +
                  r[0] + " -rotate 90 " + tempfile1.name)
        os.system(
            "composite -compose Dst_Over " +
            tempfile1.name +
            " " +
            tex_dir +
            "/block/" +
            r[0] +
            " " +
            target_dir(
                "/mods/ENTITIES/mcl_minecarts/textures",
                make_texture_pack,
                output_dir,
                output_dir_name,
                mineclone2_path) +
            "/" +
            r[3])

# Convert banner overlays


def convert_banner_overlays(
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
            dest = target_dir(
                "/mods/ITEMS/mcl_banners/textures",
                make_texture_pack,
                output_dir,
                output_dir_name,
                mineclone2_path) + "/" + "mcl_banners_" + o + ".png"
            os.system(
                "convert " +
                orig +
                " -transparent-color white -background black -alpha remove -alpha copy -channel RGB -white-threshold 0 " +
                dest)

# Convert grass and related textures


def convert_grass_textures(
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
    # Convert grass
    grass_file = tex_dir + "/block/grass_block_top.png"
    if os.path.isfile(grass_file):
        FOLIAG = tex_dir + "/colormap/foliage.png"
        GRASS = tex_dir + "/colormap/grass.png"

        # Leaves
        colorize_alpha(
            FOLIAG,
            tex_dir +
            "/block/oak_leaves.png",
            "116+143",
            str(PXSIZE),
            target_dir(
                "/textures",
                make_texture_pack,
                output_dir,
                output_dir_name,
                mineclone2_path) +
            "/default_leaves.png",
            tempfile2.name)
        colorize_alpha(
            FOLIAG,
            tex_dir +
            "/block/dark_oak_leaves.png",
            "158+177",
            str(PXSIZE),
            target_dir(
                "/textures",
                make_texture_pack,
                output_dir,
                output_dir_name,
                mineclone2_path) +
            "/mcl_core_leaves_big_oak.png",
            tempfile2.name)
        colorize_alpha(
            FOLIAG,
            tex_dir +
            "/block/acacia_leaves.png",
            "40+255",
            str(PXSIZE),
            target_dir(
                "/textures",
                make_texture_pack,
                output_dir,
                output_dir_name,
                mineclone2_path) +
            "/default_acacia_leaves.png",
            tempfile2.name)
        colorize_alpha(
            FOLIAG,
            tex_dir +
            "/block/spruce_leaves.png",
            "226+230",
            str(PXSIZE),
            target_dir(
                "/textures",
                make_texture_pack,
                output_dir,
                output_dir_name,
                mineclone2_path) +
            "/mcl_core_leaves_spruce.png",
            tempfile2.name)
        colorize_alpha(
            FOLIAG,
            tex_dir +
            "/block/birch_leaves.png",
            "141+186",
            str(PXSIZE),
            target_dir(
                "/textures",
                make_texture_pack,
                output_dir,
                output_dir_name,
                mineclone2_path) +
            "/mcl_core_leaves_birch.png",
            tempfile2.name)
        colorize_alpha(
            FOLIAG,
            tex_dir +
            "/block/jungle_leaves.png",
            "16+39",
            str(PXSIZE),
            target_dir(
                "/textures",
                make_texture_pack,
                output_dir,
                output_dir_name,
                mineclone2_path) +
            "/default_jungleleaves.png",
            tempfile2.name)

        # Waterlily
        colorize_alpha(
            FOLIAG,
            tex_dir +
            "/block/lily_pad.png",
            "16+39",
            str(PXSIZE),
            target_dir(
                "/textures",
                make_texture_pack,
                output_dir,
                output_dir_name,
                mineclone2_path) +
            "/flowers_waterlily.png",
            tempfile2.name)

        # Vines
        colorize_alpha(
            FOLIAG,
            tex_dir +
            "/block/vine.png",
            "16+39",
            str(PXSIZE),
            target_dir(
                "/textures",
                make_texture_pack,
                output_dir,
                output_dir_name,
                mineclone2_path) +
            "/mcl_core_vine.png",
            tempfile2.name)

        # Tall grass, fern (inventory images)
        pcol = "50+173"  # Plains grass color
        # TODO: TALLGRASS.png does no longer exist
        colorize_alpha(
            GRASS,
            tex_dir +
            "/block/tallgrass.png",
            pcol,
            str(PXSIZE),
            target_dir(
                "/textures",
                make_texture_pack,
                output_dir,
                output_dir_name,
                mineclone2_path) +
            "/mcl_flowers_tallgrass_inv.png",
            tempfile2.name)
        colorize_alpha(
            GRASS,
            tex_dir +
            "/block/fern.png",
            pcol,
            str(PXSIZE),
            target_dir(
                "/textures",
                make_texture_pack,
                output_dir,
                output_dir_name,
                mineclone2_path) +
            "/mcl_flowers_fern_inv.png",
            tempfile2.name)
        colorize_alpha(
            GRASS,
            tex_dir +
            "/block/large_fern_top.png",
            pcol,
            str(PXSIZE),
            target_dir(
                "/textures",
                make_texture_pack,
                output_dir,
                output_dir_name,
                mineclone2_path) +
            "/mcl_flowers_double_plant_fern_inv.png",
            tempfile2.name)
        colorize_alpha(
            GRASS,
            tex_dir +
            "/block/tall_grass_top.png",
            pcol,
            str(PXSIZE),
            target_dir(
                "/textures",
                make_texture_pack,
                output_dir,
                output_dir_name,
                mineclone2_path) +
            "/mcl_flowers_double_plant_grass_inv.png",
            tempfile2.name)

        # Convert grass palette: https://minecraft.fandom.com/wiki/Tint
        grass_colors = [
            # [Coords or #Color, AdditionalTint], # Index - Minecraft biome name (MineClone2 biome names)
            # 0 - Plains (flat, Plains, Plains_beach, Plains_ocean, End)
            ["50+173"],
            # 1 - Savanna (Savanna, Savanna_beach, Savanna_ocean)
            ["0+255"],
            # 2 - Ice Spikes (IcePlainsSpikes, IcePlainsSpikes_ocean)
            ["255+255"],
            # 3 - Snowy Taiga (ColdTaiga, ColdTaiga_beach, ColdTaiga_beach_water, ColdTaiga_ocean)
            ["255+255"],
            # 4 - Giant Tree Taiga (MegaTaiga, MegaTaiga_ocean)
            ["178+193"],
            # 5 - Giant Tree Taiga (MegaSpruceTaiga, MegaSpruceTaiga_ocean)
            ["178+193"],
            # 6 - Montains (ExtremeHills, ExtremeHills_beach, ExtremeHills_ocean)
            ["203+239"],
            # 7 - Montains (ExtremeHillsM, ExtremeHillsM_ocean)
            ["203+239"],
            # 8 - Montains (ExtremeHills+, ExtremeHills+_snowtop, ExtremeHills+_ocean)
            ["203+239"],
            ["50+173"],  # 9 - Beach (StoneBeach, StoneBeach_ocean)
            ["255+255"],  # 10 - Snowy Tundra (IcePlains, IcePlains_ocean)
            # 11 - Sunflower Plains (SunflowerPlains, SunflowerPlains_ocean)
            ["50+173"],
            ["191+203"],  # 12 - Taiga (Taiga, Taiga_beach, Taiga_ocean)
            ["76+112"],  # 13 - Forest (Forest, Forest_beach, Forest_ocean)
            # 14 - Flower Forest (FlowerForest, FlowerForest_beach, FlowerForest_ocean)
            ["76+112"],
            # 15 - Birch Forest (BirchForest, BirchForest_ocean)
            ["101+163"],
            # 16 - Birch Forest Hills (BirchForestM, BirchForestM_ocean)
            ["101+163"],
            # 17 - Desert and Nether (Desert, Desert_ocean, Nether)
            ["0+255"],
            # 18 - Dark Forest (RoofedForest, RoofedForest_ocean)
            ["76+112", "#28340A"],
            ["#90814d"],  # 19 - Mesa (Mesa, Mesa_sandlevel, Mesa_ocean, )
            # 20 - Mesa (MesaBryce, MesaBryce_sandlevel, MesaBryce_ocean)
            ["#90814d"],
            # 21 - Mesa (MesaPlateauF, MesaPlateauF_grasstop, MesaPlateauF_sandlevel, MesaPlateauF_ocean)
            ["#90814d"],
            # 22 - Mesa (MesaPlateauFM, MesaPlateauFM_grasstop, MesaPlateauFM_sandlevel, MesaPlateauFM_ocean)
            ["#90814d"],
            # 23 - Shattered Savanna (or Savanna Plateau ?) (SavannaM, SavannaM_ocean)
            ["0+255"],
            ["12+36"],  # 24 - Jungle (Jungle, Jungle_shore, Jungle_ocean)
            # 25 - Modified Jungle (JungleM, JungleM_shore, JungleM_ocean)
            ["12+36"],
            ["12+61"],  # 26 - Jungle Edge (JungleEdge, JungleEdge_ocean)
            # 27 - Modified Jungle Edge (JungleEdgeM, JungleEdgeM_ocean)
            ["12+61"],
            # 28 - Swamp (Swampland, Swampland_shore, Swampland_ocean)
            ["#6A7039"],
            # 29 - Mushroom Fields and Mushroom Field Shore (MushroomIsland, MushroomIslandShore, MushroomIsland_ocean)
            ["25+25"],
        ]

        grass_palette_file = target_dir(
            "/textures",
            make_texture_pack,
            output_dir,
            output_dir_name,
            mineclone2_path) + "/mcl_core_palette_grass.png"
        os.system("convert -size 16x16 canvas:transparent " +
                  grass_palette_file)

        for i, color in enumerate(grass_colors):
            if color[0][0] == "#":
                os.system("convert -size 1x1 xc:\"" +
                          color[0] + "\" " + tempfile1.name + ".png")
            else:
                os.system("convert " + GRASS + " -crop 1x1+" +
                          color[0] + " " + tempfile1.name + ".png")

            if len(color) > 1:
                os.system(
                    "convert " +
                    tempfile1.name +
                    ".png \\( -size 1x1 xc:\"" +
                    color[1] +
                    "\" \\) -compose blend -define compose:args=50,50 -composite " +
                    tempfile1.name +
                    ".png")

            os.system("convert " +
                      grass_palette_file +
                      " \\( " +
                      tempfile1.name +
                      ".png -geometry +" +
                      str(i %
                          16) +
                      "+" +
                      str(int(i /
                              16)) +
                      " \\) -composite " +
                      grass_palette_file)
