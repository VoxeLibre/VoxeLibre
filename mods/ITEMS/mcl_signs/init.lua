-- Font: 04.jp.org

-- load characters map
local chars_file = io.open(minetest.get_modpath("mcl_signs").."/characters", "r")
local charmap = {}
if not chars_file then
	minetest.log("error", "[mcl_signs] : character map file not found")
else
	while true do
		local char = chars_file:read("*l")
		if char == nil then
			break
		end
		local img = chars_file:read("*l")
		chars_file:read("*l")
		charmap[char] = img
	end
end

-- CONSTANTS
local SIGN_WIDTH = 115

local LINE_LENGTH = 15
local NUMBER_OF_LINES = 4

local LINE_HEIGHT = 14
local CHAR_WIDTH = 5

local string_to_array = function(str)
	local tab = {}
	for i=1,string.len(str) do
		table.insert(tab, string.sub(str, i,i))
	end
	return tab
end

local string_to_line_array = function(str)
	local tab = {}
	local current = 1
	local linechar = 1
	tab[1] = ""
	for _,char in ipairs(string_to_array(str)) do
		-- New line
		if char == "\n" then
			current = current + 1
			tab[current] = ""
			linechar = 1
		-- This check cuts off overlong lines
		elseif linechar <= LINE_LENGTH then
			tab[current] = tab[current]..char
			linechar = linechar + 1
		end
	end
	return tab
end

local create_lines = function(text)
	local line_num = 1
	local tab = {}
	for _, line in ipairs(string_to_line_array(text)) do
		if line_num > NUMBER_OF_LINES then
			break
		end
		table.insert(tab, line)
		line_num = line_num + 1
	end
	return tab
end

local generate_line = function(s, ypos)
	local i = 1
	local parsed = {}
	local width = 0
	local chars = 0
	local printed_char_width = CHAR_WIDTH + 1
	while chars <= LINE_LENGTH and i <= #s do
		local file = nil
		if charmap[s:sub(i, i)] ~= nil then
			file = charmap[s:sub(i, i)]
			i = i + 1
		elseif i < #s and charmap[s:sub(i, i + 1)] ~= nil then
			file = charmap[s:sub(i, i + 1)]
			i = i + 2
		else
			minetest.log("warning", "[mcl_signs] Unknown symbol in '"..s.."' at "..i.." (probably "..s:sub(i, i)..")")
			i = i + 1
		end
		if file ~= nil then
			width = width + printed_char_width
			table.insert(parsed, file)
			chars = chars + 1
		end
	end
	width = width - 1

	local texture = ""
	local xpos = math.floor((SIGN_WIDTH - width) / 2)
	for i = 1, #parsed do
		texture = texture..":"..xpos..","..ypos.."="..parsed[i]..".png"
		xpos = xpos + printed_char_width
	end
	return texture
end

local generate_texture = function(lines)
	local texture = "[combine:"..SIGN_WIDTH.."x"..SIGN_WIDTH
	local ypos = 9
	for i = 1, #lines do
		texture = texture..generate_line(lines[i], ypos)
		ypos = ypos + LINE_HEIGHT
	end
	return texture
end

local n = 7/16 - 1/128

local signs = {
	{delta = {x = 0, y = 0, z = n}, yaw = 0},
	{delta = {x = n, y = 0, z = 0}, yaw = math.pi / -2},
	{delta = {x = 0, y = 0, z = -n}, yaw = math.pi},
	{delta = {x = -n, y = 0, z = 0}, yaw = math.pi / 2},
}

local m = 1/32 + 1/128

local signs_yard = {
	{delta = {x = 0, y = 0, z = -m}, yaw = 0},
	{delta = {x = -m, y = 0, z = 0}, yaw = math.pi / -2},
	{delta = {x = 0, y = 0, z = m}, yaw = math.pi},
	{delta = {x = m, y = 0, z = 0}, yaw = math.pi / 2},
}

local sign_groups = {handy=1,axey=1, flammable=1, deco_block=1, material_wood=1, attached_node=1}

local destruct_sign = function(pos)
	local objects = minetest.get_objects_inside_radius(pos, 0.5)
	for _, v in ipairs(objects) do
		if v:get_entity_name() == "mcl_signs:text" then
			v:remove()
		end
	end
end

local update_sign = function(pos, fields, sender)
	local meta = minetest.get_meta(pos)
	if not meta then
		return
	end
	local text = meta:get_string("text")
	if fields and (text == "" and fields.text) then
		meta:set_string("text", fields.text)
		text = fields.text
	end
	if text == nil then
		text = ""
	end
	local objects = minetest.get_objects_inside_radius(pos, 0.5)
	for _, v in ipairs(objects) do
		if v:get_entity_name() == "mcl_signs:text" then
			v:set_properties({textures={generate_texture(create_lines(text))}})
			return
		end
	end
	
	-- if there is no entity
	local sign_info
	if minetest.get_node(pos).name == "mcl_signs:standing_sign" then
		sign_info = signs_yard[minetest.get_node(pos).param2 + 1]
	elseif minetest.get_node(pos).name == "mcl_signs:wall_sign" then
		sign_info = signs[minetest.get_node(pos).param2 + 1]
	end
	if sign_info == nil then
		return
	end
	local text_entity = minetest.add_entity({x = pos.x + sign_info.delta.x,
										y = pos.y + sign_info.delta.y,
										z = pos.z + sign_info.delta.z}, "mcl_signs:text")
	text_entity:setyaw(sign_info.yaw)
end

local show_formspec = function(player, pos)
	minetest.show_formspec(
		player:get_player_name(),
		"mcl_signs:set_text_"..pos.x.."_"..pos.y.."_"..pos.z,
		"size[6,3]textarea[0.25,0.25;6,1.5;text;Edit sign text:;]label[0,1.5;Maximum line length: 15\nMaximum lines: 4]button_exit[0,2.5;6,1;submit;Done]"
	)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname:find("mcl_signs:set_text_") == 1 then
		local x, y, z = formname:match("mcl_signs:set_text_(.-)_(.-)_(.*)")
		local pos = {x=tonumber(x), y=tonumber(y), z=tonumber(z)}
		if not pos or not pos.x or not pos.y or not pos.z then return end
		update_sign(pos, fields, player)
	end
end)



minetest.register_node("mcl_signs:wall_sign", {
	description = "Sign",
	_doc_items_longdesc = "Signs can be written and come in two variants: Wall sign and sign on a sign post. Signs can be placed on the top and the sides of other blocks, but not below them.",
	_doc_items_usagehelp = "Place the sign at the side to build a wall sign, place it on top of another block to build a sign with a sign post.\nAfter placing the sign, you can write something on it. You have 4 lines of text with up to 15 characters for each line; anything beyond these limits is lost. The text can not be changed once it has been written; you have to break and place the sign again.",
	inventory_image = "default_sign.png",
	walkable = false,
	is_ground_content = false,
	wield_image = "default_sign.png",
	node_placement_prediction = "",
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "wallmounted",
	drawtype = "nodebox",
	node_box = {type = "wallmounted", wall_side = {-0.499, -1/16, -7/16, -7/16, 7/16, 7/16}},
	tiles = {"signs_wall.png"},
	groups = sign_groups,
	stack_max = 16,
	sounds = mcl_sounds.node_sound_wood_defaults(),

	on_place = function(itemstack, placer, pointed_thing)
		local above = pointed_thing.above
		local under = pointed_thing.under

		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(under)
		if placer and not placer:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
			end
		end

		local dir = {x = under.x - above.x,
					 y = under.y - above.y,
					 z = under.z - above.z}

		-- Only build when it's legal
		local abovenodedef = minetest.registered_nodes[minetest.get_node(above).name]
		if not abovenodedef or abovenodedef.buildable_to == false then
			return itemstack
		end

		local wdir = minetest.dir_to_wallmounted(dir)

		local placer_pos = placer:getpos()
		if placer_pos then
			dir = {
				x = above.x - placer_pos.x,
				y = above.y - placer_pos.y,
				z = above.z - placer_pos.z
			}
		end

		local fdir = minetest.dir_to_facedir(dir)

		local sign_info
		local place_pos
		if wdir == 0 then
			--how would you add sign to ceiling?
			return itemstack
		elseif wdir == 1 then
			place_pos = above
			local stand = ItemStack(itemstack)
			stand:set_name("mcl_signs:standing_sign")
			local _, success = minetest.item_place_node(stand, placer, pointed_thing, fdir)
			if not success then
				return itemstack
			end
			sign_info = signs_yard[fdir + 1]
		else
			place_pos = above
			local _, success = minetest.item_place_node(itemstack, placer, pointed_thing, wdir)
			if not success then
				return itemstack
			end
			sign_info = signs[fdir + 1]
		end

		local text = minetest.add_entity({
			x = place_pos.x + sign_info.delta.x,
			y = place_pos.y + sign_info.delta.y,
			z = place_pos.z + sign_info.delta.z}, "mcl_signs:text")
		text:setyaw(sign_info.yaw)

		if not minetest.setting_getbool("creative_mode") then
			itemstack:take_item()
		end
		minetest.sound_play({name="default_place_node_hard", gain=1.0}, {pos = place_pos})

		show_formspec(placer, place_pos)
		return itemstack
	end,
	on_destruct = destruct_sign,
	on_receive_fields = function(pos, formname, fields, sender)
		update_sign(pos, fields, sender)
	end,
	on_punch = function(pos, node, puncher)
		update_sign(pos)
	end,
	_mcl_hardness = 1,
	_mcl_blast_resistance = 5,
})

minetest.register_node("mcl_signs:standing_sign", {
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	is_ground_content = false,
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {type = "fixed", fixed = {
		{-7/16, -1/16, -1/32, 7/16, 7/16, 1/32},
		{-1/16, -0.5, -1/32, 1/16, -1/16, 1/32},
	}},
	selection_box = {type = "fixed", fixed = {-7/16, -0.5, -1/32, 7/16, 7/16, 1/32}},
	tiles = {"signs_top.png", "signs_bottom.png", "signs_side.png", "signs_side.png", "signs_back.png", "signs_front.png"},
	groups = sign_groups,
	drop = "mcl_signs:wall_sign",
	stack_max = 16,
	sounds = mcl_sounds.node_sound_wood_defaults(),

	on_destruct = destruct_sign,
	on_receive_fields = function(pos, formname, fields, sender)
		update_sign(pos, fields, sender)
	end,
	on_punch = function(pos, node, puncher)
		update_sign(pos)
	end,
	_mcl_hardness = 1,
	_mcl_blast_resistance = 5,
})

minetest.register_entity("mcl_signs:text", {
	collisionbox = { 0, 0, 0, 0, 0, 0 },
	visual = "upright_sprite",
	textures = {},
	physical = false,
	collide_with_objects = false,

	on_activate = function(self)
		local meta = minetest.get_meta(self.object:getpos())
		local text = meta:get_string("text")
		self.object:set_properties({
			textures={generate_texture(create_lines(text))},
		})
		self.object:set_armor_groups({ immortal = 1 })
	end
})

if minetest.setting_get("log_mods") then
	minetest.log("action", "[mcl_signs] loaded")
end

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_signs:wall_sign",
	burntime = 10,
})

minetest.register_craft({
	output = 'mcl_signs:wall_sign 3',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'group:wood', 'group:wood', 'group:wood'},
		{'', 'mcl_core:stick', ''},
	}
})

if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mcl_signs:wall_sign", "nodes", "mcl_signs:standing_sign")
end

minetest.register_alias("signs:sign_wall", "mcl_signs:wall_sign")
minetest.register_alias("signs:sign_yard", "mcl_signs:standing_sign")
