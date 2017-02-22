-- Some global variables (don't overwrite them!)
mcl_vars = {}

--- GUI / inventory menu colors
mcl_vars.gui_slots = "listcolors[#9990;#FFF7;#FFF0;#000;#FFF]"
mcl_vars.gui_bg = "bgcolor[#080808BB;true]"
mcl_vars.gui_bg_img = ""

mcl_vars.inventory_header = mcl_vars.gui_slots .. mcl_vars.gui_bg

local mg_name = minetest.get_mapgen_setting("mg_name")
if mg_name ~= "flat" then
	-- 1 flat bedrock layer with 4 rough layers above
	mcl_vars.bedrock_overworld_min = -62
	mcl_vars.bedrock_overworld_max = mcl_vars.bedrock_overworld_min + 4
	mcl_vars.bedrock_is_rough = true
else
	-- 1 perfectly flat bedrock layer
	local ground = minetest.get_mapgen_setting("mgflat_ground_level")
	mcl_vars.bedrock_overworld_min = ground - 3
	mcl_vars.bedrock_overworld_max = mcl_vars.bedrock_overworld_min
	mcl_vars.bedrock_is_rough = false
end

-- Set default stack sizes
minetest.nodedef_default.stack_max = 64
minetest.craftitemdef_default.stack_max = 64

-- Set random seed for all other mods (Remember to make sure no other mod calls this function)
math.randomseed(os.time())


