-- Some global variables (don't overwrite them!)
mcl_vars = {}

--- GUI / inventory menu colors
mcl_vars.gui_slots = "listcolors[#9990;#FFF7;#FFF0;#000;#FFF]"
mcl_vars.gui_bg = "bgcolor[#080808BB;true]"
mcl_vars.gui_bg_img = ""

mcl_vars.inventory_header = mcl_vars.gui_slots .. mcl_vars.gui_bg

mcl_vars.bedrock_overworld_min = -62
mcl_vars.bedrock_overworld_max = -58

-- Set default stack sizes
minetest.nodedef_default.stack_max = 64
minetest.craftitemdef_default.stack_max = 64

-- Set random seed for all other mods (Remember to make sure no other mod calls this function)
math.randomseed(os.time())


