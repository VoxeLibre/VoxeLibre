local S, charmap, utf8 = ...

local function table_merge(t, ...)
	local t2 = table.copy(t)
	return table.update(t2, ...)
end

local SIGN_WIDTH = 115

local LINE_LENGTH = 15
local NUMBER_OF_LINES = 4

local LINE_HEIGHT = 14
local CHAR_WIDTH = 5

local SIGN_GLOW_INTENSITY = 14

local NEWLINE = {
	[0x000A] = true,
	[0x000B] = true,
	[0x000C] = true,
	-- U+000D (CR) is dropped on U-string conversion
	[0x0085] = true,
	[0x2028] = true,
	[0x2029] = true,
}

local WHITESPACE = {
	[0x0009] = true,
	[0x0020] = true,
	-- U+00A0 is a whitespace, but a non-breaking one
	[0x1680] = true,
	[0x2000] = true,
	[0x2001] = true,
	[0x2002] = true,
	[0x2003] = true,
	[0x2004] = true,
	[0x2005] = true,
	[0x2006] = true,
	-- U+2007 is a whitespace, but a non-breaking one
	[0x2008] = true,
	[0x2009] = true,
	[0x200A] = true,
	-- U+202F is a whitespace, but a non-breaking one
	[0x205F] = true,
	[0x3000] = true,
}

local HYPHEN = {
	[0x002D] = true,
	[0x00AD] = true,
	[0x058A] = true,
	[0x05BE] = true,
	[0x1806] = true,
	[0x2010] = true,
	-- U+2011 is a hyphen, but a non-breaking one
	[0x2E17] = true,
	[0x2E5D] = true,
	[0x30FB] = true,
	[0xFE63] = true,
	[0xFF0D] = true,
	[0xFF65] = true,
}

local CR_CODEPOINT = utf8.codepoint("\r") -- ignored
local WRAP_CODEPOINT = utf8.codepoint("‐") -- default, ellipsis for "truncate"

local DEFAULT_COLOR = "#000000"
local DYE_TO_COLOR = {
	["white"] = "#d0d6d7",
	["grey"] = "#818177",
	["dark_grey"] = "#383c40",
	["black"] = "#080a10",
	["violet"] = "#6821a0",
	["blue"] = "#2e3094",
	["lightblue"] = "#258ec9",
	["cyan"] = "#167b8c",
	["dark_green"] = "#4b5e25",
	["green"] = "#60ac19",
	["yellow"] = "#f1b216",
	["brown"] = "#633d20",
	["orange"] = "#e26501",
	["red"] = "#912222",
	["magenta"] = "#ab31a2",
	["pink"] = "#d56791",
}

local F = core.formspec_escape

-- Template definition
local sign_tpl = {
	_tt_help = S("Can be written"),
	_doc_items_longdesc = S("Signs can be written and come in two variants: Wall sign and sign on a sign post. Signs can be placed on the top and the sides of other blocks, but not below them."),
	_doc_items_usagehelp = S("After placing the sign, you can write something on it. You have @1 lines of text with up to @2 characters for each line; anything beyond these limits is lost. Not all characters are supported. The text can be changed after it's written by rightclicking the sign. Can be colored and made to glow. Use bone meal to remove color and glow.", NUMBER_OF_LINES, LINE_LENGTH),
	use_texture_alpha = "opaque",
	sunlight_propagates = true,
	walkable = false,
	is_ground_content = false,
	paramtype2 = "degrotate",
	drawtype = "mesh",
	mesh = "mcl_signs_sign.obj",
	paramtype = "light",
	selection_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, -0.2, 0.2, 0.5, 0.2}
	},
	groups = {axey = 1, handy = 2, sign = 1, supported_node = 1, not_in_creative_inventory = 1},
	stack_max = 16,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	node_placement_prediction = "",
	_mcl_sign_type = "standing"
}

-- Signs data / meta
local function normalize_rotation(rot)
	return math.floor(0.5 + rot / 15) * 15
end

local function get_signdata(pos)
	local node = core.get_node(pos)
	local def = core.registered_nodes[node.name]
	if not def or core.get_item_group(node.name, "sign") < 1 then return end

	local meta = core.get_meta(pos)
	local text = core.deserialize(meta:get_string("utext"), true) or {}
	local color = meta:get_string("color")
	if color == "" then
		color = DEFAULT_COLOR
	end
	local glow = core.is_yes(meta:get_string("glow"))

	local yaw, spos
	local typ = "standing"
	if def.paramtype2  == "wallmounted" then
		typ = "wall"
		local dir = core.wallmounted_to_dir(node.param2)
		spos = vector.add(vector.offset(pos, 0, -0.25, 0), dir * 0.41)
		yaw = core.dir_to_yaw(dir)
	else
		yaw = math.rad(((node.param2 * 1.5) + 1) % 360)
		local dir = core.yaw_to_dir(yaw)
		spos = vector.add(vector.offset(pos, 0, 0.08, 0), dir * -0.05)
	end

	return {
		text = text,
		color = color,
		yaw = yaw,
		node = node,
		typ = typ,
		glow = glow,
		text_pos = spos,
	}
end

local function set_signmeta(pos, tbl)
	local meta = core.get_meta(pos)
	if tbl.text then meta:set_string("utext", core.serialize(tbl.text)) end
	if tbl.color then meta:set_string("color", tbl.color) end
	if tbl.glow then meta:set_string("glow", tbl.glow) end
end

-- Text processing
local function string_to_ustring(str, max_characters)
	-- limit saved text to 256 characters by default
	-- (4 lines x 15 chars = 60 so this should be more than is ever needed)
	max_characters = max_characters or 256

	local ustr = {}

	-- pcall wrapping to protect against invalid UTF-8
	local iter = utf8.codes(str)
	while true do
		local success, i, code = pcall(iter)
		if not success or not i or i >= max_characters
				or code == CR_CODEPOINT then
			break
		end
		table.insert(ustr, code)
	end

	return ustr
end
mcl_signs.string_to_ustring = string_to_ustring

local function ustring_to_string(ustr)
	local str = ""
	for _, code in ipairs(ustr) do
		str = str .. utf8.char(code)
	end
	return str
end
mcl_signs.ustring_to_string = ustring_to_string

-- TODO: make shared code as table.slice()?
local function subseq(ustr, s, e)
	local line = {}
	for i = s, e do
		line[#line+1] = ustr[i]
	end
	return line
end

local ustring_to_line_array
local wrap_mode = core.settings:get("mcl_signs_wrap_mode") or "word_wrap"
if wrap_mode == "word_break" then
	function ustring_to_line_array(ustr)
		local lines = {}
		local line = {}

		for _, code in ipairs(ustr) do
			if #lines >= NUMBER_OF_LINES then break end

			if NEWLINE[code]
					or WHITESPACE[code] and #line >= (LINE_LENGTH - 1) then
				table.insert(lines, line)
				line = {}
			elseif #line >= LINE_LENGTH then
				table.insert(line, WRAP_CODEPOINT)
				table.insert(lines, line)
				line = {code}
			else
				table.insert(line, code)
			end
		end
		if #line > 0 and #lines < NUMBER_OF_LINES then table.insert(lines, line) end

		return lines
	end
elseif wrap_mode == "word_wrap" then
	function ustring_to_line_array(ustr)
		local lines = {}
		local start, stop = 1, 1

		for cursor, code in ipairs(ustr) do
			if #lines >= NUMBER_OF_LINES then break end

			if WHITESPACE[code] or HYPHEN[code] then
				stop = cursor
			elseif NEWLINE[code] then
				table.insert(lines, subseq(ustr, start, cursor - 1))
				start, stop = cursor + 1, cursor + 1
			elseif cursor - start + 1 >= LINE_LENGTH then
				if stop <= start then -- forced break, no space in word
					local line = subseq(ustr, start, cursor)
					table.insert(line, WRAP_CODEPOINT)
					table.insert(lines, line)
					start, stop = cursor + 1, cursor + 1
				else
					table.insert(lines, subseq(ustr, start, stop + (HYPHEN[ustr[stop]] and 0 or -1)))
					start, stop = stop + 1, stop + 1
				end
			end
		end
		if #lines < NUMBER_OF_LINES and start <= #ustr then
			table.insert(lines, subseq(ustr, start, #ustr))
		end

		return lines
	end
elseif wrap_mode == "truncate" then
	WRAP_CODEPOINT = utf8.codepoint("…")
	function ustring_to_line_array(ustr)
		local lines = {}
		local line = {}

		for _, code in ipairs(ustr) do
			if #lines >= NUMBER_OF_LINES then break end

			if NEWLINE[code] then
				table.insert(lines, line)
				line = {}
			elseif #line == LINE_LENGTH then
				table.insert(line, WRAP_CODEPOINT)
			elseif #line < LINE_LENGTH then
				table.insert(line, code)
			end
		end
		if #line > 0 and #lines < NUMBER_OF_LINES then table.insert(lines, line) end

		return lines
	end
end
mcl_signs.ustring_to_line_array = ustring_to_line_array

local function generate_line(ustr, ypos)
	local parsed = {}
	local width = 0
	local printed_char_width = CHAR_WIDTH + 1

	for _, code in ipairs(ustr) do
		local file = "_rc"
		if charmap[code] then file = charmap[code] end

		width = width + printed_char_width
		table.insert(parsed, file)
	end

	width = width - 1
	local texture = ""
	local xpos = math.floor((SIGN_WIDTH - width) / 2) -- center with X offset

	for _, file in ipairs(parsed) do
		texture = texture .. ":" .. xpos .. "," .. ypos .. "=" .. file.. ".png"
		xpos = xpos + printed_char_width
	end
	return texture
end
mcl_signs.generate_line = generate_line

local function generate_texture(data)
	local lines = ustring_to_line_array(data.text)
	local texture = "[combine:" .. SIGN_WIDTH .. "x" .. SIGN_WIDTH
	local ypos = 0
	local letter_color = data.color or DEFAULT_COLOR

	for _, line in ipairs(lines) do
		texture = texture .. generate_line(line, ypos)
		ypos = ypos + LINE_HEIGHT
	end

	texture = "(" .. texture .. "^[multiply:" .. letter_color .. ")"
	return texture
end
mcl_signs.generate_texture = generate_texture

-- Text entity handling
local function get_text_entity(pos, force_remove)
	local objects = core.get_objects_inside_radius(pos, 0.5)
	local text_entity
	local i = 0
	for _, v in pairs(objects) do
		local ent = v:get_luaentity()
		if ent and ent.name == "mcl_signs:text" then
			i = i + 1
			if i > 1 or force_remove == true then
				v:remove()
			else
				text_entity = v
			end
		end
	end
	return text_entity
end
mcl_signs.get_text_entity = get_text_entity

-- Update the sign text entity (create if doesn't exist)
local function update_sign(pos)
	local data = get_signdata(pos)

	local text_entity = get_text_entity(pos)
	if text_entity and not data then
		text_entity:remove()
		return false
	elseif not data then
		return false
	elseif not text_entity then
		text_entity = core.add_entity(data.text_pos, "mcl_signs:text")
		if not text_entity or not text_entity:get_pos() then return end
	end

	text_entity:set_properties({
		textures = {generate_texture(data)},
		glow = data.glow and SIGN_GLOW_INTENSITY or 0,
	})
	text_entity:set_yaw(data.yaw)
	text_entity:set_armor_groups({immortal = 1})
	return true
end
mcl_signs.update_sign = update_sign

core.register_lbm({
	name = "mcl_signs:restore_entities",
	nodenames = {"group:sign"},
	label = "Restore sign text",
	run_at_every_load = true,
	action = update_sign,
})

-- Text entity definition
core.register_entity("mcl_signs:text", {
	initial_properties = {
		pointable = false,
		visual = "upright_sprite",
		physical = false,
		collide_with_objects = false,
	},
	on_activate = function(self)
		local pos = self.object:get_pos()
		update_sign(pos)
		local props = self.object:get_properties()
		local t = props and props.textures
		if type(t) ~= "table" or #t == 0 then self.object:remove() end
	end,
})

-- Formspec
local function show_formspec(player, pos, guest)
	if not pos then return end
	local meta = core.get_meta(pos)
	local old_text = ustring_to_string(core.deserialize(meta:get_string("utext"), true) or {})

	local fs
	if guest then
		fs = {
			"size[6,2.3]textarea[0.25,0.25;6,1.5;;",
			F(S("Sign text:")), ";", F(old_text), "]",
			"button_exit[0,1.7;6,1;submit;", F(S("Close")), "]"
		}
	else
		fs = {
			"size[6,3]textarea[0.25,0.25;6,1.5;text;",
			F(S("Enter sign text:")), ";", F(old_text), "]",
			"label[0,1.5;",
				F(S("Maximum line length: @1", LINE_LENGTH)), "\n",
				F(S("Maximum lines: @1", NUMBER_OF_LINES)),
			"]",
			"button_exit[0,2.4;6,1;submit;", F(S("Done")), "]"
		}
	end

	core.show_formspec(player:get_player_name(), "mcl_signs:set_text_"..pos.x.."_"..pos.y.."_"..pos.z, table.concat(fs))
end
mcl_signs.show_formspec = show_formspec

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname:find("mcl_signs:set_text_") == 1 then
		local x, y, z = formname:match("mcl_signs:set_text_(.-)_(.-)_(.*)")
		local pos = vector.new(tonumber(x), tonumber(y), tonumber(z))
		if not fields or not fields.text then return end
		if not mcl_util.check_position_protection(pos, player) then
			local utext = string_to_ustring(fields.text)
			set_signmeta(pos, {text = utext})
			update_sign(pos)
		end
	end
end)

local function make_placed_node_sign(placed_node, placer, dir, itemstack)
	local wdir = core.dir_to_wallmounted(dir)
	local def = itemstack:get_definition()
	if wdir == 1 then
		placed_node.name = "mcl_signs:standing_sign_"..def._mcl_sign_wood
		-- param2 value is degrees / 1.5
		placed_node.param2 = normalize_rotation(placer:get_look_horizontal() * 180 / math.pi / 1.5)
	else
		placed_node.name = "mcl_signs:wall_sign_"..def._mcl_sign_wood
	end
	return placed_node
end
sign_tpl._vl_attach_type = "sign"
vl_attach.set_default("sign",function(_, def, wdir)
	-- Don't allow ceiling signs until we have a hanging sign
	if wdir == 0 then return false end

	return (def.groups.solid or 0) ~= 0 and (def.groups.opaque or 0) ~= 0
end)

-- Node definition callbacks
function sign_tpl.on_place(itemstack, placer, pointed_thing)
	local pos
	itemstack, pos = vl_attach.place_attached(itemstack, placer, pointed_thing, nil, make_placed_node_sign)
	if not pos then return end

	show_formspec(placer, pos)
end

function sign_tpl.on_rightclick(pos, _, clicker, itemstack)
	if core.is_protected(pos, clicker:get_player_name()) then
		show_formspec(clicker, pos, true)
		return itemstack
	end

	local iname = itemstack:get_name()
	if iname == "mcl_mobitems:glow_ink_sac" then
		local data = get_signdata(pos)
		if data then
			if data.color == "#000000" then
				data.color = "#7e7e7e" -- black doesn't glow in the dark
			end
			set_signmeta(pos, {glow = "true", color = data.color})
			update_sign(pos)
			if not core.is_creative_enabled(clicker:get_player_name()) then
				itemstack:take_item()
			end
		end
	elseif iname == "mcl_bone_meal:bone_meal" then
		set_signmeta(pos, {
			glow = "false",
			color = DEFAULT_COLOR,
		})
		update_sign(pos)
		if not core.is_creative_enabled(clicker:get_player_name()) then
			itemstack:take_item()
		end
	elseif iname:sub(1, 8) == "mcl_dye:" then
		local dye = iname:sub(9)
		set_signmeta(pos, {color = DYE_TO_COLOR[dye]})
		update_sign(pos)
		if not core.is_creative_enabled(clicker:get_player_name()) then
			itemstack:take_item()
		end
	else
		show_formspec(clicker, pos)
	end

	return itemstack
end

function sign_tpl.on_destruct(pos)
	get_text_entity(pos, true)
end

-- TODO: reactivate when a good dyes API is finished
--function sign_tpl._on_dye_place(pos, color)
--	set_signmeta(pos, {
--		color = mcl_dyes.colors[color].rgb
--	})
--	mcl_signs.update_sign(pos)
--end

-- Wall sign definition
local sign_wall = table_merge(sign_tpl, {
	mesh = "mcl_signs_signonwallmount.obj",
	paramtype2 = "wallmounted",
	selection_box = {
		type = "wallmounted",
		wall_side = {-0.5, -7/28, -0.5, -23/56, 7/28, 0.5}
	},
	groups = {axey = 1, handy = 2, sign = 1, supported_node_wallmounted = 1, deco_block = 1, vl_attach = 1},
	_mcl_sign_type = "wall",
})

local function colored_texture(texture, color)
	return texture.."^[multiply:"..color
end

function mcl_signs.register_sign(name, color, def)
	local newfields = {
		tiles = {colored_texture("mcl_signs_sign_greyscale.png", color)},
		inventory_image = colored_texture("mcl_signs_default_sign_greyscale.png", color),
		wield_image = colored_texture("mcl_signs_default_sign_greyscale.png", color),
		drop = "mcl_signs:wall_sign_"..name,
		_mcl_sign_wood = name,
	}

	def = def or {}
	core.register_node(":mcl_signs:standing_sign_"..name, table_merge(sign_tpl, newfields, def))
	core.register_node(":mcl_signs:wall_sign_"..name, table_merge(sign_wall, newfields, def))
end
