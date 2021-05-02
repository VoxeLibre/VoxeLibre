mcl_maps = {}

local S = minetest.get_translator("mcl_maps")
local storage = minetest.get_mod_storage()
local modpath = minetest.get_modpath("mcl_maps")
local worldpath = minetest.get_worldpath()
local map_textures_path = worldpath .. "/mcl_maps/"
local last_finished_id = storage:get_int("next_id") - 1

dofile(modpath .. "/bit32.lua") -- taken from http://gitea.minetest.one/minetest-mods/turtle/src/branch/master/bit32.lua

bit = bit32
pngencoder = dofile(modpath .. "/pngencoder.lua") -- taken from https://github.com/wyozi/lua-pngencoder/blob/master/pngencoder.lua

minetest.mkdir(map_textures_path)

local function load_json_file(name)
	local file = assert(io.open(modpath .. "/" .. name .. ".json", "r"))
	local data = minetest.parse_json(file:read())
	file:close()
	return data
end

local texture_colors = load_json_file("colors")
local palettes = load_json_file("palettes")

local color_cache = {}

local creating_maps = {}
local loading_maps = {}
local loaded_maps = {}

local c_air = minetest.get_content_id("air")

function mcl_maps.create_map(pos)
	local itemstack = ItemStack("mcl_maps:filled_map")
	local meta = itemstack:get_meta()
	local id = storage:get_int("next_id")
	storage:set_int("next_id", id + 1)
	local texture_file = "mcl_maps_map_texture_" .. id .. ".png"
	local texture_path = map_textures_path .. texture_file
	local texture = "[combine:140x140:0,0=mcl_maps_map_background.png:6,6=" .. texture_file
	meta:set_int("mcl_maps:id", id)
	meta:set_string("mcl_maps:texture", texture)
	meta:set_string("mcl_maps:texture_path", texture_path)
	tt.reload_itemstack_description(itemstack)
	creating_maps[texture] = true
	local minp = vector.multiply(vector.floor(vector.divide(pos, 128)), 128)
	local maxp = vector.add(minp, vector.new(127, 127, 127))
	minetest.emerge_area(minp, maxp, function(blockpos, action, calls_remaining)
		if calls_remaining > 0 then
			return
		end
		local vm = minetest.get_voxel_manip()
		local emin, emax = vm:read_from_map(minp, maxp)
		local data = vm:get_data()
		local param2data = vm:get_param2_data()
		local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
		local pixels = {}
		local last_heightmap
		for x = 1, 128 do
			local map_x = minp.x - 1 + x
			local heightmap = {}
			for z = 1, 128 do
				local map_z = minp.z - 1 + z
				local color
				for map_y = maxp.y, minp.y, -1 do
					local index = area:index(map_x, map_y, map_z)
					local c_id = data[index]
					if c_id ~= c_air then
						color = color_cache[c_id]
						if color == nil then
							local nodename = minetest.get_name_from_content_id(c_id)
							local def = minetest.registered_nodes[nodename]
							if def then
								local texture
								if def.palette then
									texture = def.palette
								elseif def.tiles then
									texture = def.tiles[1]
									if type(texture) == "table" then
										texture = texture.name
									end
								end
								if texture then
									texture = texture:match("([^=^%^]-([^.]+))$"):split("^")[1]
								end
								if def.palette then
									local palette = palettes[texture]
									color = palette and {palette = palette}
								else
									color = texture_colors[texture]
								end
							end
						end

						if color and color.palette then
							color = color.palette[param2data[index] + 1]
						else
							color_cache[c_id] = color or false
						end

						if color and last_heightmap then
							local last_height = last_heightmap[z]
							if last_height < map_y then
								color = {
									math.min(255, color[1] + 16),
									math.min(255, color[2] + 16),
									math.min(255, color[3] + 16),
								}
							elseif last_height > map_y then
								color = {
									math.max(0, color[1] - 16),
									math.max(0, color[2] - 16),
									math.max(0, color[3] - 16),
								}
							end
						end
							height = map_y
						break
					end
				end
				heightmap[z] = height
				pixels[z] = pixels[z] or {}
				pixels[z][x] = color or {0, 0, 0}
			end
			last_heightmap = heightmap
		end
		local image = pngencoder(128, 128, "rgb")
		for _, row in ipairs(pixels) do
			for _, pixel in ipairs(row) do
				image:write(pixel)
			end
		end
		assert(image.done)
		local f = assert(io.open(texture_path, "w"))
		f:write(table.concat(image.output))
		f:close()
		creating_maps[texture] = false
	end)
	return itemstack
end

-- Turn empty map into filled map by rightclick
local make_filled_map = function(itemstack, placer, pointed_thing)
	if minetest.settings:get_bool("enable_real_maps", true) then
		local new_map = mcl_maps.create_map(placer:get_pos())
		itemstack:take_item()
		if itemstack:is_empty() then
			return new_map
		else
			local inv = placer:get_inventory()
			if inv:room_for_item("main", new_map) then
				inv:add_item("main", new_map)
			else
				minetest.add_item(placer:get_pos(), new_map)
			end
			return itemstack
		end
	end
end

minetest.register_craftitem("mcl_maps:empty_map", {
	description = S("Empty Map"),
	_doc_items_longdesc = S("Empty maps are not useful as maps, but they can be stacked and turned to maps which can be used."),
	_doc_items_usagehelp = S("Rightclick to create a filled map (which can't be stacked anymore)."),
	inventory_image = "mcl_maps_map_empty.png",
	on_place = make_filled_map,
	on_secondary_use = make_filled_map,
	stack_max = 64,
})

minetest.register_craftitem("mcl_maps:filled_map", {
	description = S("Map"),
	_tt_help = S("Shows a map image."),
	_doc_items_longdesc = S("When created, the map saves the nearby area as an image that can be viewed any time by holding the map."),
	_doc_items_usagehelp = S("Hold the map in your hand. This will display a map on your screen."),
	groups = {tool = 1, not_in_creative_inventory = 1},
	inventory_image = "mcl_maps_map_filled.png^(mcl_maps_map_filled_markings.png^[colorize:#000000)",
	stack_max = 64,
})

tt.register_priority_snippet(function(itemstring, _, itemstack)
	if itemstack and itemstring == "mcl_maps:filled_map" then
		local id = itemstack:get_meta():get_string("mcl_maps:id")
		if id ~= "" then
			return "#" .. id, mcl_colors.GRAY
		end
	end
end)

minetest.register_craft({
	output = "mcl_maps:empty_map",
	recipe = {
		{ "mcl_core:paper", "mcl_core:paper", "mcl_core:paper" },
		{ "mcl_core:paper", "group:compass", "mcl_core:paper" },
		{ "mcl_core:paper", "mcl_core:paper", "mcl_core:paper" },
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_maps:filled_map 2",
	recipe = {"mcl_maps:filled_map", "mcl_maps:empty_map"},
})

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if itemstack:get_name() == "mcl_maps:filled_map" then
		for _, stack in pairs(old_craft_grid) do
			if stack:get_name() == "mcl_maps:filled_map" then
				itemstack:get_meta():from_table(stack:get_meta():to_table())
				return itemstack
			end
		end
	end
end)

local maps = {}
local huds = {}

minetest.register_on_joinplayer(function(player)
	huds[player] = player:hud_add({
		hud_elem_type = "image",
		text = "blank.png",
		position = {x = 1, y = 1},
		alignment = {x = -1, y = -1},
		offset = {x = -125, y = -50},
		scale = {x = 2, y = 2},
	})
end)

minetest.register_on_leaveplayer(function(player)
	maps[player] = nil
	huds[player] = nil
end)

local function is_holding_map(player)
	local wield = player:get_wielded_item()
	if wield:get_name() ~= "mcl_maps:filled_map" then
		return
	end
	local meta = wield:get_meta()
	local texture = meta:get_string("mcl_maps:texture")
	if texture == "" then
		return
	end
	if loaded_maps[texture] then
		return texture
	end
	local path = meta:get_string("mcl_maps:texture_path")
	if not creating_maps[texture] and not loading_maps[texture] then
		loading_maps[texture] = true
		local player_name = player:get_player_name()
		minetest.dynamic_add_media(path, function(finished_name)
			if player_name == finished_name then
				loading_maps[texture] = false
				loaded_maps[texture] = true
			end
		end)
	end
end

minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local texture = is_holding_map(player)
		if texture then
			if texture ~= maps[player] then
				player:hud_change(huds[player], "text", texture)
				maps[player] = texture
			end
		elseif maps[player] then
			player:hud_change(huds[player], "text", "blank.png")
			maps[player] = nil
		end
	end
end)
