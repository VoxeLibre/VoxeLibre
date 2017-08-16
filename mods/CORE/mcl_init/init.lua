-- Some global variables (don't overwrite them!)
mcl_vars = {}

--- GUI / inventory menu colors
mcl_vars.gui_slots = "listcolors[#9990;#FFF7;#FFF0;#000;#FFF]"
mcl_vars.gui_bg = "bgcolor[#080808BB;true]"
mcl_vars.gui_bg_img = ""

mcl_vars.inventory_header = mcl_vars.gui_slots .. mcl_vars.gui_bg

-- Mapgen variables
local mg_name = minetest.get_mapgen_setting("mg_name")
local minecraft_height_limit = 256
if mg_name ~= "flat" then
	--[[ Realm stacking (h is for height)
	- Overworld (h>=256)
	- Void (h>=1000)
	- Realm Barrier (h=11), to allow escaping the End
	- End (h>=256)
	- Void (h>=1000)
	- Nether (h=128)
	- Void (h>=1000)
	]]

	-- Overworld
	mcl_vars.mg_overworld_min = -62
	mcl_vars.mg_overworld_max_official = mcl_vars.mg_overworld_min + minecraft_height_limit
	mcl_vars.mg_bedrock_overworld_min = mcl_vars.mg_overworld_min
	mcl_vars.mg_bedrock_overworld_max = mcl_vars.mg_bedrock_overworld_min + 4
	mcl_vars.mg_lava_overworld_max = mcl_vars.mg_overworld_min + 10
	mcl_vars.mg_lava = true
	mcl_vars.mg_bedrock_is_rough = true

else
	local ground = minetest.get_mapgen_setting("mgflat_ground_level")
	ground = tonumber(ground)
	if not ground then
		ground = 8
	end
	-- 1 perfectly flat bedrock layer
	if minetest.get_mapgen_setting("mcl_superflat_classic") == "false" then
		mcl_vars.mg_overworld_min = -30912
	else
		mcl_vars.mg_overworld_min = ground - 3
	end
	mcl_vars.mg_overworld_max_official = mcl_vars.mg_overworld_min + minecraft_height_limit
	mcl_vars.mg_bedrock_overworld_min = mcl_vars.mg_overworld_min
	mcl_vars.mg_bedrock_overworld_max = mcl_vars.mg_bedrock_overworld_min
	mcl_vars.mg_lava = false
	mcl_vars.mg_bedrock_is_rough = false
end

mcl_vars.mg_overworld_max = math.huge

-- The Nether
mcl_vars.mg_nether_min = -29000
mcl_vars.mg_nether_max = mcl_vars.mg_nether_min + 128
mcl_vars.mg_bedrock_nether_bottom_min = mcl_vars.mg_nether_min
mcl_vars.mg_bedrock_nether_bottom_max = mcl_vars.mg_bedrock_nether_bottom_min + 4
mcl_vars.mg_bedrock_nether_top_max = mcl_vars.mg_nether_max
mcl_vars.mg_bedrock_nether_top_min = mcl_vars.mg_bedrock_nether_top_max - 4
mcl_vars.mg_lava_nether_max = mcl_vars.mg_nether_min + 31

-- The End
mcl_vars.mg_end_min = mcl_vars.mg_nether_max + 2000
mcl_vars.mg_end_max_official = mcl_vars.mg_end_min + minecraft_height_limit
mcl_vars.mg_end_max = mcl_vars.mg_overworld_min - 2000

-- Set default stack sizes
minetest.nodedef_default.stack_max = 64
minetest.craftitemdef_default.stack_max = 64

-- Set random seed for all other mods (Remember to make sure no other mod calls this function)
math.randomseed(os.time())


