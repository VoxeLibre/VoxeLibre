# Making Textures In VoxeLibre

Textures are a crucial asset for all items, nodes, and models in VoxeLibre. This document is for artist who would like to make and modify textures for VoxeLibre. While no means comprehensive, this document contains the basic important information for beginners to get started with texture curation and optimization.

## Minetest Wiki
For more detailed information on creating and modifing texture packs for Minetest/VoxeLibre, please visit the Minetest wiki's page on creating a texture pack. Click [here](https://wiki.minetest.net/Creating_texture_packs) to view the wiki page on creating texture packs.

## GIMP Tutorials Pixel Art Guide
GIMP Tutorials has an excellent guide to making pixel art in GIMP. If you would like further clarification as well as screenshots for what we are about to cover, it is an excellent resource to turn to. Click [here](https://thegimptutorials.com/how-to-make-pixel-art/) to view the guide

## Recommended Software

### GIMP

GIMP (GNU Image Manipulation Program) is a very popular and free image editing software supported on Windows, MacOS, and most Linux distributions. It is recommended to use GIMP to create and modify textures within the minetest engine. 

Download GIMP [here](http://gimp.org/)

# Getting Started
## Creating a new file
the first thing to do is open GIMP and create a new file to work in by opening the File menu and choosing "New".

Choose width of 16 and height of 16 for the image size. While higher resolution textures are possible, The default size is 16x16. It is recommended you use this size as well, as it is universally supported on all systems.

## Zoom In
Next, you'll want to zoom in as the canvas is very small at the default zoom level. To do this either use CTRL + mousewheel, +/-, or navigate to the View menu > zoom > zoom in

## Configure Grid
Now, we'll want to turn on the grid. Open the edit menu and enable the 'show grid' option.

The default grid size is 10 pixels, we want to change it to a 1 pixel grid. Go to the Image menu and choose 'configure grid.

In the Spacing section, change both the Horizontal and Vertical pixel settings to 1.00 then click ok and the grid will update.

## Pencil Tool & Color Picking
The most useful brush type for pixel art is the Pencil tool. Its nested under the paintbrush tool in the toolbox, or you can use the keyboard shortcut 'N'.

Once the pencil tool is selected, navigate to the sliders on the left side of the canvas and change brush size to 1 pixel.

Now choose a color! You can do this by clicking on the two colored squares under the toolbox. The Color Picker tool is also a good option if you already have a reference image for color palette.

## How to export optimally

Once you have finished up a texture and are ready to export it, navigate to the file menu > export as... and make sure the file name extention is .png

After clicking 'Export', a menu will appear with a bunch of options checked. Make sure to uncheck all of these options!!! This will drastically reduce the file size from multiple kilobytes to a couple of hundred bytes. Finally click 'Export' one more time.

### Further optimization with OptiPNG
For those running a GNU/linux distribution, you most likely have the 'optipng' command available to you. If it does not come with your system by default, the software homepage can be found [here](https://optipng.sourceforge.net/) where you can download and install from source.

First, Open up the terminal in the directory where your exported texture is located (or navigate to the directory with the 'cd your/directory/path/to/textures'), then run this command
```
optipng -o7 -zm1-9 -nc -clobber -strip all *.png
```
This will further optimize all the textures in the directory.

NOTE: If you would like to further edit a texture that has been optipng'd in GIMP, you must manually set the color palette back to RBG after opening. Navigate to Image menu > Mode > select RGB
