-- TODO: improve support for larger zoom levels, benchmark raycasting, too?
-- TODO: only send texture to players that have the map
-- TODO: use ephemeral textures or base64 inline textures to eventually allow explorer maps?
-- TODO: show multiple players on the map
-- TODO: show banners on map
-- TODO: when the minimum supported Luanti version has core.get_node_raw, use it
-- Check for engine updates that allow improvements
mcl_maps = {}

mcl_maps.max_zoom = tonumber(core.settings:get("vl_maps_max_zoom")) or 3
mcl_maps.enable_maps = core.settings:get_bool("enable_real_maps", true)
mcl_maps.allow_nether_maps = core.settings:get_bool("vl_maps_allow_nether", true)
mcl_maps.map_allow_overlap = core.settings:get_bool("vl_maps_allow_overlap", true) -- 50% overlap allowed in each level
mcl_maps.map_update_rate = 1 / (tonumber(core.settings:get("vl_maps_map_update_rate")) or 15) -- invert for the globalstep check

local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local S = core.get_translator(modname)

local vector = vector
local table = table
local pairs = pairs
local min, max, round, floor, ceil, abs, pi = math.min, math.max, math.round, math.floor, math.ceil, math.abs, math.pi
local char = string.char
local concat = table.concat

local pos_to_string = core.pos_to_string
local string_to_pos = core.string_to_pos
local get_item_group = core.get_item_group
local dynamic_add_media = core.dynamic_add_media
local get_connected_players = core.get_connected_players
local get_node_light = core.get_node_light
local get_node_name_raw = mcl_vars.get_node_name_raw

local storage = core.get_mod_storage()
local worldpath = core.get_worldpath()
local map_textures_path = worldpath .. DIR_DELIM .. "mcl_maps" .. DIR_DELIM

core.mkdir(map_textures_path)

local function load_json_file(name)
	local file = assert(io.open(modpath .. DIR_DELIM .. name .. ".json", "r"))
	local data = core.parse_json(file:read("*all"))
	file:close()
	return data
end

local texture_colors = load_json_file("colors")

local maps_generating, maps_loading = {}, {}

-- Main map generation function, called from emerge
local function do_generate_map(id, minp, maxp, callback--[[, t1]])
	--local t2 = os.clock()
	-- Generate a (usually) 128x128 linear array for the image
	local pixels = {}
	local xsize, zsize = maxp.x - minp.x + 1, maxp.z - minp.z + 1
	-- Step size, for zoom levels > 1
	local xstep, zstep = ceil(xsize / 128), ceil(zsize / 128)
	for z = zsize, 1, -zstep do
		local map_z = minp.z + z - 1
		local last_height
		for x = 1, xsize, xstep do
			local map_x = minp.x + x - 1
			-- Color aggregate and height information (for 3D effect)
			local cagg, height = {0, 0, 0, 0}, nil
			local solid_under_air = -1 -- anything but air, actually
			for map_y = maxp.y, minp.y, -1 do
				local nodename, _, param2 = get_node_name_raw(map_x, map_y, map_z)
				if nodename ~= "air" then
					local color = texture_colors[nodename]
					-- Use param2 if available:
					if color and type(color[1]) == "table" then
						color = color[param2 + 1] or color[1]
					end
					if color then
						if solid_under_air == 0 then
							cagg, height = {0, 0, 0, 0}, nil -- reset
							solid_under_air = 1
						end
						local alpha = cagg[4] -- 0 (transparent) to 255 (opaque)
						if alpha < 255 then
							local a = (color[4] or 255) * (255 - alpha) / 255 -- 0 to 255
							local f = a / 255 -- 0 to 1, color contribution
							-- Alpha blend the colors:
							cagg[1] = cagg[1] + f * color[1]
							cagg[2] = cagg[2] + f * color[2]
							cagg[3] = cagg[3] + f * color[3]
							alpha = cagg[4] + a -- new alpha, 0 to 255
							cagg[4] = alpha
						end

						-- Ground estimate with transparent blocks
						if alpha > 140 and not height then height = map_y end
						if alpha >= 250 and solid_under_air > 0 then
							-- Adjust color to give a 3D effect
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
					solid_under_air = 0 -- first air
				end
			end
			-- Clamp colors values to 0..255 for PNG
			-- (because 3D height effect may exceed this range)
			cagg[1] = max(0, min(round(cagg[1]), 255))
			cagg[2] = max(0, min(round(cagg[2]), 255))
			cagg[3] = max(0, min(round(cagg[3]), 255))
			cagg[4] = max(0, min(round(cagg[4]), 255))
			pixels[#pixels + 1] = char(cagg[1], cagg[2], cagg[3], cagg[4])
			last_height = height
		end
	end
	-- Save as png texture
	--local t3 = os.clock()
	local filename = map_textures_path .. "mcl_maps_map_" .. id .. ".png"
	core.safe_file_write(filename, core.encode_png(xsize / xstep, zsize / zstep, concat(pixels)))
	--local t4 = os.clock()
	--core.log("action", string.format("Completed map %s after %.2fms (%.2fms emerge, %.2fms map, %.2fms png)", id, (os.clock()-t1)*1000, (t2-t1)*1000, (t3-t2)*1000, (t4-t3)*1000))
	maps_generating[id] = nil
	if callback then callback(id, filename) end
end

-- Trigger map generation
local function emerge_generate_map(id, minp, maxp, callback)
	if maps_generating[id] then return end
	maps_generating[id] = true
	--local t1 = os.clock()
	core.emerge_area(minp, maxp, function(blockpos, action, calls_remaining)
		if calls_remaining > 0 then return end
		-- Do a DOUBLE emerge to give mapgen the chance to place structures triggered by the initial emerge
		core.emerge_area(minp, maxp, function(blockpos, action, calls_remaining)
			if calls_remaining > 0 then return end
			do_generate_map(id, minp, maxp, callback--[[, t1]])
		end)
	end)
end

function mcl_maps.is_empty_map(itemstack)
	return itemstack:get_name() == "mcl_maps:empty_map"
end

---@param itemstack core.ItemStack
---@return boolean?
function mcl_maps.is_map(itemstack)
	local item_def = core.registered_items[itemstack:get_name()]
	return (item_def.groups.vl_map or 0) ~= 0
end

function mcl_maps.convert_legacy_map(itemstack, meta)
	meta = meta or itemstack:get_meta()
	tt.reload_itemstack_description(itemstack)

	local minp = string_to_pos(meta:get_string("mcl_maps:minp"))
	local maxp = string_to_pos(meta:get_string("mcl_maps:maxp"))
	local cx = minp.x + 64
	local cz = minp.z + 64
	meta:set_int("mcl_maps:cx", cx)
	meta:set_int("mcl_maps:cz", cz)
	meta:set_int("mcl_maps:zoom", 1)
	meta:set_string("mcl_maps:dim", mcl_worlds.pos_to_dimension(minp))

	tt.reload_itemstack_description(itemstack)
end

local function configure_map(itemstack, cx, dim, cz, zoom, callback)
	zoom = max(zoom or 1, 1)
	-- Texture size is 128
	local size = 64 * (2 ^ zoom)
	local halfsize = size / 2

	local meta = itemstack:get_meta()

	-- Legacy conversion
	if dim == "" then
		local fields = meta:to_table().fields
		local minp = string_to_pos(meta:get_string("mcl_maps:minp"))
		local maxp = string_to_pos(meta:get_string("mcl_maps:maxp"))
		dim = mcl_worlds.pos_to_dimension(minp)
		cx = minp.x + halfsize
		cz = minp.z + halfsize
	end

	-- If enabled, round to halfsize grid, otherwise to size grid
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
		miny, maxy = -32, 255
	else
		miny = tonumber(dim) - 32
		maxy = miny + 63
	end

	-- File name conventions, including a unique number in case someone maps the same area twice (old and new)
	local seq = storage:get_int("next_id")
	storage:set_int("next_id", seq + 1)
	local id = concat({cx, dim, cz, zoom, seq}, "_")
	local minp = vector.new(cx - halfsize, miny, cz - halfsize)
	local maxp = vector.new(cx + halfsize - 1, maxy, cz + halfsize - 1)

	meta:set_string("mcl_maps:id", id)
	meta:set_int("mcl_maps:cx", cx)
	meta:set_string("mcl_maps:dim", dim)
	meta:set_int("mcl_maps:cz", cz)
	meta:set_int("mcl_maps:zoom", zoom)
	meta:set_string("mcl_maps:minp", pos_to_string(minp))
	meta:set_string("mcl_maps:maxp", pos_to_string(maxp))
	tt.reload_itemstack_description(itemstack)

	emerge_generate_map(id, minp, maxp, callback)
	return itemstack
end

function mcl_maps.load_map(id, callback)
	if id == "" or maps_generating[id] then return false end

	-- Use a legacy TGA map texture if present
	local texture = "mcl_maps_map_texture_"..id..".tga"
	local f = io.open(map_textures_path .. texture, "r")
	if f then
		f:close()
	else
		texture = "mcl_maps_map_" .. id .. ".png"
	end

	if maps_loading[id] then
		if callback then callback(texture) end
		return texture
	end

	-- core.dynamic_add_media() never blocks in Luanti 5.5, callback runs after load
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
		mcl_title.set(placer, "actionbar", {text=S("It may take a moment for the map to be ready."), color="gold", stay=5*20})
		local new_map = mcl_maps.create_map(placer:get_pos(), 0, function(id, filename)
			mcl_title.set(placer, "actionbar", {text=S("The new map is now ready."), color="green", stay=3*20})
		end)

		local is_creative = core.is_creative_enabled(placer:get_player_name())
		if not is_creative then
			itemstack:take_item()
		end
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
	groups = {vl_map = 1},
})

core.register_craft({
	output = "mcl_maps:empty_map",
	recipe = {
		{"mcl_core:paper", "mcl_core:paper", "mcl_core:paper"},
		{"mcl_core:paper", "group:compass",  "mcl_core:paper"},
		{"mcl_core:paper", "mcl_core:paper", "mcl_core:paper"},
	},
})

local filled_def = {
	description = S("Map"),
	_tt_help = S("Shows a map image."),
	_doc_items_longdesc = S("When created, the map saves the nearby area as an image that can be viewed any time by holding the map."),
	_doc_items_usagehelp = S("Hold the map in your hand. This will display a map on your screen."),
	inventory_image = "mcl_maps_map_filled.png^(mcl_maps_map_filled_markings.png^[colorize:#000000)",
	groups = {not_in_creative_inventory = 1, filled_map = 1, tool = 1, vl_map = 1},
}

core.register_craftitem("mcl_maps:filled_map", filled_def)

-- Only nodes can have meshes, which means that all player hands are nodes
-- Thus, to render a map over a player hand, we have to register nodes for this too
local filled_wield_def = table.copy(filled_def)
filled_wield_def.visual_scale = 1
filled_wield_def.wield_scale = vector.new(1, 1, 1)
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
			female.tiles = {skin.texture}
			female.use_texture_alpha = "clip"
			core.register_node("mcl_maps:filled_map_"..skin.id, female)
		else
			local male = table.copy(filled_wield_def)
			male._mcl_hand_id = skin.id
			male.mesh = "mcl_meshhand.b3d"
			male.tiles = {skin.texture}
			male.use_texture_alpha = "clip"
			core.register_node("mcl_maps:filled_map_"..skin.id, male)
		end
	end
else
	filled_wield_def._mcl_hand_id = "hand"
	filled_wield_def.mesh = "mcl_meshhand.b3d"
	filled_wield_def.tiles = {"character.png"}
	filled_wield_def.use_texture_alpha = "clip"
	core.register_node("mcl_maps:filled_map_hand", filled_wield_def)
end

-- Avoid dropping detached hands with held maps
local old_add_item = core.add_item
function core.add_item(pos, stack)
	if not pos then
		core.log("warning", "Trying to add item with missing pos: " .. dump(stack))
		return
	end
	stack = ItemStack(stack)
	if get_item_group(stack:get_name(), "filled_map") > 0 then
		stack:set_name("mcl_maps:filled_map")
	end
	return old_add_item(pos, stack)
end

-- Zoom level tooltip
tt.register_priority_snippet(function(itemstring, _, itemstack)
	if itemstack and get_item_group(itemstring, "filled_map") > 0 then
		local zoom = itemstack:get_meta():get_string("mcl_maps:zoom")
		if zoom ~= "" then
			return S("Level @1", zoom), mcl_colors.GRAY
		end
	end
end)

-- Support copying maps as a crafting recipe
core.register_craft({
	type = "shapeless",
	output = "mcl_maps:filled_map 2",
	recipe = {"group:filled_map", "mcl_maps:empty_map"},
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

-- Render handheld maps as part of HUD overlay
local maps = {}
local huds = {}

core.register_on_joinplayer(function(player)
	local map_def = {
		[mcl_vars.hud_type_field] = "image",
		text = "blank.png",
		position = {x = 0.75, y = 0.8},
		alignment = {x = 0, y = -1},
		offset = {x = 0, y = 0},
		scale = {x = 2, y = 2},
	}
	local marker_def = table.copy(map_def)
	marker_def.alignment = {x = 0, y = 0}
	huds[player] = {
		map = player:hud_add(map_def),
		marker = player:hud_add(marker_def),
	}
end)

core.register_on_leaveplayer(function(player)
	maps[player] = nil
	huds[player] = nil
end)

local etime = 0
core.register_globalstep(function(dtime)
	etime = etime + dtime
	if etime < mcl_maps.map_update_rate then
		return
	end
	etime = 0

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

			local pos = player:get_pos() -- was: vector.round(player:get_pos())
			local light = get_node_light(vector.offset(pos, 0, 0.5, 0)) or 0

			-- Change map only when necessary
			if not maps[player] or texture ~= maps[player][1] or light ~= maps[player][4] then
				local light_overlay = "^[colorize:black:" .. 255 - (light * 17)
				player:hud_change(hud.map, "text", "[combine:140x140:0,0=mcl_maps_map_background.png:6,6=" .. texture .. light_overlay)
				local meta = wield:get_meta()
				local minp = string_to_pos(meta:get_string("mcl_maps:minp"))
				local maxp = string_to_pos(meta:get_string("mcl_maps:maxp"))
				maps[player] = {texture, minp, maxp, light}
			end

			-- Map overlay with player position
			local minp, maxp = maps[player][2], maps[player][3]

			-- Use dots when outside of map, indicate direction
			local marker
			if pos.x < minp.x then
				marker = abs(minp.x - pos.x) < 256 and "mcl_maps_player_dot_large.png" or "mcl_maps_player_dot.png"
				pos.x = minp.x
			elseif pos.x > maxp.x then
				marker = abs(pos.x - maxp.x) < 256 and "mcl_maps_player_dot_large.png" or "mcl_maps_player_dot.png"
				pos.x = maxp.x
			end

			-- Never override the small marker
			if pos.z < minp.z then
				marker = (abs(minp.z - pos.z) < 256 and marker ~= "mcl_maps_player_dot.png")
					and "mcl_maps_player_dot_large.png" or "mcl_maps_player_dot.png"
				pos.z = minp.z
			elseif pos.z > maxp.z then
				marker = (abs(pos.z - maxp.z) < 256 and marker ~= "mcl_maps_player_dot.png")
					and "mcl_maps_player_dot_large.png" or "mcl_maps_player_dot.png"
				pos.z = maxp.z
			end

			-- Default to yaw-based player arrow
			if not marker then
				local yaw = (floor(player:get_look_horizontal() * 180 / pi / 45 + 0.5) % 8) * 45
				if yaw == 0 or yaw == 90 or yaw == 180 or yaw == 270 then
					marker = "mcl_maps_player_arrow.png^[transformR" .. yaw
				else
					marker = "mcl_maps_player_arrow_diagonal.png^[transformR" .. (yaw - 45)
				end
			end

			-- Note the alignment and scale used above
			local f = 2 * 128 / (maxp.x - minp.x + 1)
			player:hud_change(hud.marker, "offset", {x = (pos.x - minp.x) * f - 128, y = (maxp.z - pos.z) * f - 256})
			player:hud_change(hud.marker, "text", marker)

		elseif maps[player] then -- disable map
			local hud = huds[player]
			player:hud_change(hud.map, "text", "blank.png")
			player:hud_change(hud.marker, "text", "blank.png")
			maps[player] = nil
		end
	end
end)
