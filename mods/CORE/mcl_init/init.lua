-- Some global variables (don't overwrite them!)
mcl_vars = {}
local modpath = core.get_modpath(core.get_current_modname())

minetest.log("action", "World seed = " .. minetest.get_mapgen_setting("seed"))
dofile(modpath.."/versioning.lua")

mcl_vars.redstone_tick = 0.1

-- GUI / inventory menu settings
mcl_vars.gui_slots = "listcolors[#9990;#FFF7;#FFF0;#000;#FFF]"

-- nonbg is added as formspec prepend in mcl_formspec_prepend
mcl_vars.gui_nonbg = table.concat({
	mcl_vars.gui_slots,
	"style_type[image_button;border=false;bgimg=mcl_inventory_button9.png;bgimg_pressed=mcl_inventory_button9_pressed.png;bgimg_middle=2,2]",
	"style_type[button;border=false;bgimg=mcl_inventory_button9.png;bgimg_pressed=mcl_inventory_button9_pressed.png;bgimg_middle=2,2]",
	"style_type[field;textcolor=#323232]",
	"style_type[label;textcolor=#323232]",
	"style_type[textarea;textcolor=#323232]",
	"style_type[checkbox;textcolor=#323232]",
})

-- Background stuff must be manually added by mods (no formspec prepend)
mcl_vars.gui_bg_color = "bgcolor[#00000000]"
mcl_vars.gui_bg_img = "background9[1,1;1,1;mcl_base_textures_background9.png;true;7]"

-- HUD element type field, stored separately to avoid deprecation warnings (5.9+)
mcl_vars.hud_type_field = core.features["hud_def_type_field"] and "type" or "hud_elem_type"

-- Tool wield size
mcl_vars.tool_wield_scale = vector.new(1.8, 1.8, 1)

-- Use VoxeLibre-style dungeons
mcl_vars.mg_dungeons = true

-- Set default stack sizes
minetest.nodedef_default.stack_max = 64
minetest.craftitemdef_default.stack_max = 64

-- Set random seed for all other mods (Remember to make sure no other mod calls this function)
math.randomseed(os.time())

---DEPRECATED. If you need to ensure the area is emerged, use LVM.
---"Trivial" (actually NOT) function to just read the node and some stuff to not just return "ignore", like mt 5.4 does.
---@param pos Vector Position, if it's wrong, `{name="error"}` node will return.
---@param force? boolean Optional (default: `false`), Do the maximum to still read the node within us_timeout.
---@param us_timeout? number Optional (default: `244 = 0.000244 s = 1/80/80/80`), set it at least to `3000000` to let mapgen to finish its job
---@return node # Node definition, eg. `{name="air"}`. Unfortunately still can return `{name="ignore"}`.
---@nodiscard
function mcl_vars.get_node(pos, force, us_timeout)
	-- check initial circumstances
	if not pos or not pos.x or not pos.y or not pos.z then return { name = "error" } end

	-- try common way
	local node = minetest.get_node(pos)
	if node.name ~= "ignore" then
		return node
	end

	-- try LVM
	minetest.get_voxel_manip():read_from_map(pos, pos)
	node = minetest.get_node(pos)
	if node.name ~= "ignore" or not force then
		return node
	end

	-- try async emerge + BUSY wait (a really BAD idea, you should rather accept failure)
	minetest.emerge_area(pos, pos) -- runs async!

	local t = minetest.get_us_time()
	node = minetest.get_node(pos)
	while (not node or node.name == "ignore") and (minetest.get_us_time() - t < (us_timeout or 244)) do
		node = minetest.get_node(pos)
	end

	return node
	-- it still can return "ignore", LOL, even if force = true, but only after time out
end

dofile(modpath.."/tune_jit.lua")
dofile(modpath.."/get_node_name.lua")

