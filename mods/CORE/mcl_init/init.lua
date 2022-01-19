-- Some global variables (don't overwrite them!)
mcl_vars = {}

mcl_vars.redstone_tick = 0.1

--- GUI / inventory menu settings
mcl_vars.gui_slots = "listcolors[#9990;#FFF7;#FFF0;#000;#FFF]"
-- nonbg is added as formspec prepend in mcl_formspec_prepend
mcl_vars.gui_nonbg = mcl_vars.gui_slots ..
	"style_type[image_button;border=false;bgimg=mcl_inventory_button9.png;bgimg_pressed=mcl_inventory_button9_pressed.png;bgimg_middle=2,2]"..
	"style_type[button;border=false;bgimg=mcl_inventory_button9.png;bgimg_pressed=mcl_inventory_button9_pressed.png;bgimg_middle=2,2]"..
	"style_type[field;textcolor=#323232]"..
	"style_type[label;textcolor=#323232]"..
	"style_type[textarea;textcolor=#323232]"..
	"style_type[checkbox;textcolor=#323232]"

-- Background stuff must be manually added by mods (no formspec prepend)
mcl_vars.gui_bg_color = "bgcolor[#00000000]"
mcl_vars.gui_bg_img = "background9[1,1;1,1;mcl_base_textures_background9.png;true;7]"

-- Legacy
mcl_vars.inventory_header = ""

-- Tool wield size
mcl_vars.tool_wield_scale = { x = 1.8, y = 1.8, z = 1 }

-- Set default stack sizes
minetest.nodedef_default.stack_max = 64
minetest.craftitemdef_default.stack_max = 64

-- Set random seed for all other mods (Remember to make sure no other mod calls this function)
math.randomseed(os.time())
