-- TODO: improve support for larger zoom levels, maybe by NOT using vmanip but rather raycasting?
-- TODO: only send texture to players that have the map
-- TODO: use ephemeral textures or base64 inline textures to eventually allow explorer maps?
-- TODO: show multiple players on the map
-- TODO: show banners on map
-- Check for engine updates that allow improvements
mcl_maps = {}

mcl_maps.max_zoom = 2 -- level 3 already may take some 20 minutes...
mcl_maps.enable_maps = core.settings:get_bool("enable_real_maps", true)
mcl_maps.allow_nether_maps = core.settings:get_bool("vl_maps_allow_nether", true)
mcl_maps.map_allow_overlap = core.settings:get_bool("vl_maps_allow_overlap", true) -- 50% overlap allowed in each level

local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local S = core.get_translator(modname)

local vector = vector
local table = table
local pairs = pairs
local min, max, round, floor, ceil = math.min, math.max, math.round, math.floor, math.ceil
local HALF_PI = math.pi * 0.5

local pos_to_string = core.pos_to_string
local string_to_pos = core.string_to_pos
local get_item_group = core.get_item_group
local dynamic_add_media = core.dynamic_add_media
local get_connected_players = core.get_connected_players

local storage = core.get_mod_storage()
local worldpath = core.get_worldpath()
local map_textures_path = worldpath .. "/mcl_maps/"

core.mkdir(map_textures_path)

local function load_json_file(name)
	local file = assert(io.open(modpath .. "/" .. name .. ".json", "r"))
	local data = core.parse_json(file:read("*all"))
	file:close()
	return data
end

local texture_colors = load_json_file("colors")

local maps_generating, maps_loading = {}, {}

local c_air = core.get_content_id("air")

local function generate_map(id, minp, maxp, callback)
	if maps_generating[id] then return end
	maps_generating[id] = true
	-- FIXME: reduce resolution when zoomed out
	local t1 = os.clock()
	core.emerge_area(minp, maxp, function(blockpos, action, calls_remaining)
		if calls_remaining > 0 then return end
		-- do a DOUBLE emerge to give mapgen the chance to place structures triggered by the initial emerge
		core.emerge_area(minp, maxp, function(blockpos, action, calls_remaining)
			if calls_remaining > 0 then return end

			-- Load voxelmanip, measure time as this is fairly expensive
			local t2 = os.clock()
			local vm = core.get_voxel_manip()
			local emin, emax = vm:read_from_map(minp, maxp)
			local data = vm:get_data()
			local param2data = vm:get_param2_data()
			local t3 = os.clock()

			-- Generate a (usually) 128x128 linear array for the image
			local pixels = {}
			local area = VoxelArea:new({ MinEdge = emin, MaxEdge = emax })
			local xsize, zsize = maxp.x - minp.x + 1, maxp.z - minp.z + 1
			-- Step size, for zoom levels > 0
			local xstep, zstep = ceil(xsize / 128), ceil(zsize / 128)
			local ystride = area.ystride
			for z = zsize, 1, -zstep do
				local map_z = minp.z  + z - 1
				local last_height
				for x = 1, xsize, xstep do
					local map_x = minp.x + x - 1

					-- color aggregate and height information (for 3D effect)
					local cagg, height = { 0, 0, 0, 0 }, nil
					local solid_under_air = -1 -- anything but air, actually
					local index = area:index(map_x, maxp.y, map_z) + ystride
					for map_y = maxp.y, minp.y, -1 do
						index = index - ystride -- vertically down until we are opaque

						local c_id = data[index]
						if c_id ~= c_air then
							local color = texture_colors[core.get_name_from_content_id(c_id)]
							-- use param2 if available:
							if color and type(color[1]) == "table" then
								color = color[param2data[index] + 1] or color[1]
							end
							if color then
								if solid_under_air == 0 then
									cagg = { 0, 0, 0, 0 } -- reset
									solid_under_air = 1
								end
								local alpha = cagg[4] -- 0 (transparent) to 255 (opaque)
								local a = (color[4] or 255) * (255 - alpha) / 255 -- 0 to 255
								local f = a / 255 -- 0 to 1, color contribution
								-- Alpha blend the colors:
								cagg[1] = cagg[1] + f * color[1]
								cagg[2] = cagg[2] + f * color[2]
								cagg[3] = cagg[3] + f * color[3]
								alpha = cagg[4] + a -- new alpha, 0 to 255
								cagg[4] = alpha

								-- ground estimate with transparent blocks
								if alpha > 140 and not height then height = map_y end
								if alpha >= 250 then
									-- adjust color to give a 3d effect
									if last_height and height then
										local dheight = max(-48, min((height - last_height) * 8, 48))
										cagg[1] = cagg[1] + dheight
										cagg[2] = cagg[2] + dheight
										cagg[3] = cagg[3] + dheight
									end
									cagg[4] = 255 -- make fully opaque
									break
								end
							end
						elseif solid_under_air == -1 then
							solid_under_air = 0
						end
					end
					-- clamp colors values to 0:255 for PNG
					-- because 3d height effect may exceed this range
					cagg[1] = max(0, min(round(cagg[1]), 255))
					cagg[2] = max(0, min(round(cagg[2]), 255))
					cagg[3] = max(0, min(round(cagg[3]), 255))
					cagg[4] = max(0, min(round(cagg[4]), 255))
					pixels[#pixels + 1] = string.char(cagg[1], cagg[2], cagg[3], cagg[4])
					last_height = height
				end
			end
			-- Save as png texture
			local filename = map_textures_path .. "mcl_maps_map_" .. id .. ".png"
			local data = core.encode_png(xsize / xstep, zsize / zstep, table.concat(pixels))
			local f = assert(io.open(filename, "wb"))
			f:write(data)
			f:close()
			-- core.log("action", string.format("Completed map %s after %.2fms (%.2fms emerge, %.2fms LVM, %.2fms map)", id, (os.clock()-t1)*1000, (t2-t1)*1000, (t3-t2)*1000, (os.clock()-t3)*1000))
			maps_generating[id] = nil
			if callback then callback(id, filename) end
		end)
	end)
end

local function configure_map(itemstack, cx, dim, cz, zoom, callback)
	zoom = zoom or 0
	-- Texture size is 128
	local size = 128 * (2^zoom)
	local halfsize = size / 2
	-- If enabled, round to halfsize grid, otherwise to size grid.
	if mcl_maps.map_allow_overlap then
		cx, cz = (floor(cx / halfsize) + 0.5) * halfsize, (floor(cz / halfsize) + 0.5) * halfsize
	else
		cx, cz = (floor(cx / size) + 0.5) * size, (floor(cz / size) + 0.5) * size
	end
	-- Y range to use for mapping. In nether, if we begin above bedrock, maps will be bedrock only, similar to MC
	-- Prefer smaller ranges for performance!
	local miny, maxy
	if dim == "end" then
		miny, maxy = mcl_vars.mg_end_min + 48, mcl_vars.mg_end_min + 127
	elseif dim == "nether" then
		if mcl_maps.allow_nether_maps then
			miny, maxy = mcl_vars.mg_nether_min + 16, mcl_vars.mg_nether_deco_max
		else
			miny, maxy = mcl_vars.mg_nether_max, mcl_vars.mg_nether_max -- map the nether roof...
		end
	elseif dim == "overworld" then
		miny, maxy = -32, 63
	else
		miny = tonumber(dim) - 32
		maxy = miny + 63
	end

	-- File name conventions, including a unique number in case someone maps the same area twice (old and new)
	local seq = storage:get_int("next_id")
	storage:set_int("next_id", seq + 1)
	local id = table.concat({cx, dim, cz, zoom, seq}, "_")
	local minp = vector.new(cx - halfsize, miny, cz - halfsize)
	local maxp = vector.new(cx + halfsize - 1, maxy, cz + halfsize - 1)

	local meta = itemstack:get_meta()
	meta:set_string("mcl_maps:id", id)
	meta:set_int("mcl_maps:cx", cx)
	meta:set_string("mcl_maps:dim", dim)
	meta:set_int("mcl_maps:cz", cz)
	meta:set_int("mcl_maps:zoom", zoom)
	meta:set_string("mcl_maps:minp", pos_to_string(minp))
	meta:set_string("mcl_maps:maxp", pos_to_string(maxp))
	tt.reload_itemstack_description(itemstack)

	generate_map(id, minp, maxp, callback)
	return itemstack
end

function mcl_maps.load_map(id, callback)
	if id == "" or maps_generating[id] then return false end

	local texture = "mcl_maps_map_" .. id .. ".png"
	if maps_loading[id] then
		if callback then callback(texture) end
		return texture
	end

	-- core.dynamic_add_media() never blocks in Minetest 5.5, callback runs after load
	-- TODO: send only to the player that needs it!
	dynamic_add_media(map_textures_path .. texture, function()
		if not maps_loading[id] then -- avoid repeated callbacks
			maps_loading[id] = true
			if callback then callback(texture) end
		end
	end)
end

function mcl_maps.create_map(pos, zoom, callback)
	local dim = mcl_worlds.pos_to_dimension(pos)
	if dim == "overworld" and pos.y >= 48 then dim = tostring(round(pos.y/64)*64) end -- for float islands
	local itemstack = ItemStack("mcl_maps:filled_map")
	configure_map(itemstack, pos.x, dim, pos.z, zoom, callback)
	return itemstack
end

function mcl_maps.load_map_item(itemstack, callback)
	return mcl_maps.load_map(itemstack:get_meta():get_string("mcl_maps:id"), callback)
end

function mcl_maps.regenerate_map(itemstack, callback)
	local meta = itemstack:get_meta()
	local cx, cz = meta:get_int("mcl_maps:cx"), meta:get_int("mcl_maps:cz")
	local dim = meta:get_string("mcl_maps:dim")
	local zoom = meta:get_int("mcl_maps:zoom")
	if mcl_maps.enable_maps then
		configure_map(itemstack, cx, dim, cz, zoom, callback)
	end
end

local function fill_map(itemstack, placer, pointed_thing)
	local new_stack = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if new_stack then return new_stack end

	if mcl_maps.enable_maps then
		local pname = placer:get_player_name()
		core.chat_send_player(pname, S("It may take a moment for the map to be ready."))
		local callback = function(id, filename) core.chat_send_player(pname, S("The new map is now ready.")) end
		local new_map = mcl_maps.create_map(placer:get_pos(), 0, callback)
		itemstack:take_item()
		if itemstack:is_empty() then return new_map end
		local inv = placer:get_inventory()
		if inv:room_for_item("main", new_map) then
			inv:add_item("main", new_map)
		else
			core.add_item(placer:get_pos(), new_map)
		end
		return itemstack
	end
end

core.register_craftitem("mcl_maps:empty_map", {
	description = S("Empty Map"),
	_doc_items_longdesc = S("Empty maps are not useful as maps, but they can be stacked and turned to maps which can be used."),
	_doc_items_usagehelp = S("Rightclick to create a filled map (which cannot be stacked anymore)."),
	inventory_image = "mcl_maps_map_empty.png",
	on_place = fill_map,
	on_secondary_use = fill_map,
	stack_max = 64,
})

local filled_def = {
	description = S("Map"),
	_tt_help = S("Shows a map image."),
	_doc_items_longdesc = S("When created, the map saves the nearby area as an image that can be viewed any time by holding the map."),
	_doc_items_usagehelp = S("Hold the map in your hand. This will display a map on your screen."),
	inventory_image = "mcl_maps_map_filled.png^(mcl_maps_map_filled_markings.png^[colorize:#000000)",
	stack_max = 64,
	groups = { not_in_creative_inventory = 1, filled_map = 1, tool = 1 },
}

core.register_craftitem("mcl_maps:filled_map", filled_def)

local filled_wield_def = table.copy(filled_def)
filled_wield_def.use_texture_alpha = core.features.use_texture_alpha_string_modes and "opaque" or false
filled_wield_def.visual_scale = 1
filled_wield_def.wield_scale = { x = 1, y = 1, z = 1 }
filled_wield_def.paramtype = "light"
filled_wield_def.drawtype = "mesh"
filled_wield_def.node_placement_prediction = ""
filled_wield_def.on_place = mcl_util.call_on_rightclick
filled_wield_def._mcl_wieldview_item = "mcl_maps:filled_map"

local mcl_skins_enabled = core.global_exists("mcl_skins")

if mcl_skins_enabled then
	-- Generate a node for every skin
	local list = mcl_skins.get_skin_list()
	for _, skin in pairs(list) do
		if skin.slim_arms then
			local female = table.copy(filled_wield_def)
			female._mcl_hand_id = skin.id
			female.mesh = "mcl_meshhand_female.b3d"
			female.tiles = { skin.texture }
			core.register_node("mcl_maps:filled_map_" .. skin.id, female)
		else
			local male = table.copy(filled_wield_def)
			male._mcl_hand_id = skin.id
			male.mesh = "mcl_meshhand.b3d"
			male.tiles = { skin.texture }
			core.register_node("mcl_maps:filled_map_" .. skin.id, male)
		end
	end
else
	filled_wield_def._mcl_hand_id = "hand"
	filled_wield_def.mesh = "mcl_meshhand.b3d"
	filled_wield_def.tiles = { "character.png" }
	core.register_node("mcl_maps:filled_map_hand", filled_wield_def)
end

local old_add_item = core.add_item
function core.add_item(pos, stack)
	if not pos then
		core.log("warning", "Trying to add item with missing pos: " .. tostring(stack))
		return
	end
	stack = ItemStack(stack)
	if get_item_group(stack:get_name(), "filled_map") > 0 then
		stack:set_name("mcl_maps:filled_map")
	end
	return old_add_item(pos, stack)
end

tt.register_priority_snippet(function(itemstring, _, itemstack)
	if itemstack and get_item_group(itemstring, "filled_map") > 0 then
		local zoom = itemstack:get_meta():get_string("mcl_maps:zoom")
		if zoom ~= "" then
			return S("Level @1", zoom), mcl_colors.GRAY
		end
	end
end)

core.register_craft({
	output = "mcl_maps:empty_map",
	recipe = {
		{ "mcl_core:paper", "mcl_core:paper", "mcl_core:paper" },
		{ "mcl_core:paper", "group:compass",  "mcl_core:paper" },
		{ "mcl_core:paper", "mcl_core:paper", "mcl_core:paper" },
	}
})

core.register_craft({
	type = "shapeless",
	output = "mcl_maps:filled_map 2",
	recipe = { "group:filled_map", "mcl_maps:empty_map" },
})

local function on_craft(itemstack, player, old_craft_grid, craft_inv)
	if itemstack:get_name() == "mcl_maps:filled_map" then
		for _, stack in pairs(old_craft_grid) do
			if get_item_group(stack:get_name(), "filled_map") > 0 then
				itemstack:get_meta():from_table(stack:get_meta():to_table())
				return itemstack
			end
		end
	end
end

core.register_on_craft(on_craft)
core.register_craft_predict(on_craft)

local maps = {}
local huds = {}

core.register_on_joinplayer(function(player)
	local map_def = {
		hud_elem_type = "image",
		text = "blank.png",
		position = { x = 0.75, y = 0.8 },
		alignment = { x = 0, y = -1 },
		offset = { x = 0, y = 0 },
		scale = { x = 2, y = 2 },
	}
	local marker_def = table.copy(map_def)
	marker_def.alignment = { x = 0, y = 0 }
	huds[player] = {
		map = player:hud_add(map_def),
		marker = player:hud_add(marker_def),
	}
end)

core.register_on_leaveplayer(function(player)
	maps[player] = nil
	huds[player] = nil
end)

core.register_globalstep(function(dtime)
	for _, player in pairs(get_connected_players()) do
		local wield = player:get_wielded_item()
		local texture = mcl_maps.load_map_item(wield)
		if texture then
			local hud = huds[player]
			local wield_def = wield:get_definition()
			local hand_def = player:get_inventory():get_stack("hand", 1):get_definition()

			if hand_def and wield_def and hand_def._mcl_hand_id ~= wield_def._mcl_hand_id then
				wield:set_name("mcl_maps:filled_map_" .. hand_def._mcl_hand_id)
				player:set_wielded_item(wield)
			end

			-- change map only when necessary
			if not maps[player] or texture ~= maps[player][1] then
				player:hud_change(hud.map, "text", "[combine:140x140:0,0=mcl_maps_map_background.png:6,6=" .. texture)
				local meta = wield:get_meta()
				local minp = string_to_pos(meta:get_string("mcl_maps:minp"))
				local maxp = string_to_pos(meta:get_string("mcl_maps:maxp"))
				maps[player] = {texture, minp, maxp}
			end

			-- ,ap overlay with player position
			local pos = player:get_pos() -- was: vector.round(player:get_pos())
			local minp, maxp = maps[player][2], maps[player][3]

			-- Use dots when outside of map, indicate direction
			local marker = "mcl_maps_player_arrow.png"
			if pos.x < minp.x then
				marker = "mcl_maps_player_dot.png"
				pos.x = minp.x
			elseif pos.x > maxp.x then
				marker = "mcl_maps_player_dot.png"
				pos.x = maxp.x
			end

			if pos.z < minp.z then
				marker = "mcl_maps_player_dot.png"
				pos.z = minp.z
			elseif pos.z > maxp.z then
				marker = "mcl_maps_player_dot.png"
				pos.z = maxp.z
			end

			if marker == "mcl_maps_player_arrow.png" then
				local yaw = (floor(player:get_look_horizontal() / HALF_PI + 0.5) % 4) * 90
				marker = marker .. "^[transformR" .. yaw
			end

			-- Note the alignment and scale used above
			local f = 2 * 128 / (maxp.x - minp.x + 1)
			player:hud_change(hud.marker, "offset", { x = (pos.x - minp.x) * f - 128, y = (maxp.z - pos.z) * f - 256 })
			player:hud_change(hud.marker, "text", marker)

		elseif maps[player] then -- disable map
			local hud = huds[player]
			player:hud_change(hud.map, "text", "blank.png")
			player:hud_change(hud.marker, "text", "blank.png")
			maps[player] = nil
		end
	end
end)
