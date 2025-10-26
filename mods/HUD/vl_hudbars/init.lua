local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local math_min = math.min
local math_max = math.max
local math_ceil = math.ceil
local math_floor = math.floor

vl_hudbars = {
	hudbar_defs = {},
	players = {},
	settings = {},
}

table.update(vl_hudbars.settings, {
	start_offset_left = {x = -16, y = -90},
	start_offset_right = {x = 16, y = -90},
	scale_x = 24,
	hudbar_height_gap = 4,
	bar_length = 20,
	base_pos = {x=0.5, y=1},
	max_rendered_layers = 100, -- per part, to prevent lag due to too many layers rendered
								--Only applies to absolute hudbars

	-- Squish settings
	min_layer_offset = 8, -- 'most squished possible' offset from layer below
	max_unsquished_layers = 3, -- number of layers allowed before squishing kicks in
	squish_duration = 12, -- number of layers to squish over before reaching max squish

	forceload_default_hudbars = true,
	autohide_breath = true,
	tick = 0.1,
})

if minetest.get_modpath("mcl_experience") and not minetest.is_creative_enabled("") then
	-- reserve some space for experience bar:
	vl_hudbars.settings.start_offset_left.y = vl_hudbars.settings.start_offset_left.y - 20
	vl_hudbars.settings.start_offset_right.y = vl_hudbars.settings.start_offset_right.y - 20
end

-- Add player `name` to the players with tracked hudbars in vl_hudbars.players, if not already tracked
local function init_player_hudtracking(name)
	if vl_hudbars.players[name] == nil then
		vl_hudbars.players[name] = {
			hudbar_order_left = {},
			hudbar_order_right = {},
			hudbar_states = {},
		}
	end
end


-- This is a bad function for this as it squishes faster at more layers
local function get_squished_layer_gap(max_gap, texture_height_y, layers)
	local min_gap = vl_hudbars.settings.min_layer_offset - texture_height_y
	-- work out proportion to squish by
	local squish_proportion = (layers - vl_hudbars.settings.max_unsquished_layers)/vl_hudbars.settings.squish_duration
	-- clamp between 0 and 1 so there is a maximum squish
	squish_proportion = math_min(math_max(squish_proportion, 0), 1)
	-- linear interpolate squishage
	return max_gap - (max_gap - min_gap) * squish_proportion
end

-- Inserts a new hudbar `identifier` into the order array `hudbar_order` of a column of hudbars for a player
-- Position will be based on hudbar's sort_index
local function insert_hudbar(hudbar_order, identifier)
	local hudbar_defs = vl_hudbars.hudbar_defs
	local sort_index = hudbar_defs[identifier].sort_index

	for i, other_identifier in pairs(hudbar_order) do
		local other_sort_index = hudbar_defs[other_identifier].sort_index

		-- If the hudbar is already in the order array, return
		-- We can do this in this loop because if they are the same bar they will have the same sort_index
		if identifier == other_identifier then return end

		if other_sort_index < sort_index then
			table.insert(hudbar_order, i, identifier)
			return
		end
	end
	-- Lowest sort_index so far, add to end of hudbar_order
	table.insert(hudbar_order, identifier)
end

-- Translates a hudbar up or down vertically by `translate_amount` pixels (down is positive)
local function translate_hudbar(player, hudbar_state, translate_amount, is_compound)
	if is_compound then
		for _, part_id in pairs(hudbar_state.parts) do
			local part_state = hudbar_state.parts[part_id]
			for _, layer_id in pairs(part_state.layer_ids) do
				local offset = player:hud_get(layer_id).offset
				offset.y = offset.y + translate_amount
				player:hud_change(layer_id, "offset", offset)
			end
		end
	else
		for _, layer_id in pairs(hudbar_state.layer_ids) do
			local offset = player:hud_get(layer_id).offset
			offset.y = offset.y + translate_amount
			player:hud_change(layer_id, "offset", offset)
		end
	end
end


local function get_bar_length_pixels()
	-- Divide by 2 because scale_x is for whole texture but bar_length is in half-textures
	return vl_hudbars.settings.scale_x * vl_hudbars.settings.bar_length / 2
end

-- Add a new layer of a proportional hudbar because it didn't already exist
local function add_new_proportional_layer(player, hudbar_def, part_state,
										offset_y, offset_x_left, offset_x_right,
										value, texture_height_y, z_index)
	local bar_length = vl_hudbars.settings.bar_length
	local alignment, offset_x
	if hudbar_def.direction == 0 then
		alignment = {x=-1, y=-1}
		offset_x = offset_x_left
	else
		alignment = {x=1, y=-1}
		offset_x = offset_x_right
	end

	-- Minetest changed the name of the 'hud_elem_type' field for 5.9.0
	local type_field_name
	if minetest.features.hud_def_type_field then
		type_field_name = "type"
	else
		type_field_name = "hud_elem_type"
	end

	local layer_id = player:hud_add({
		[type_field_name] = "statbar",
		position = vl_hudbars.settings.base_pos,
		text = part_state.icon,
		text2 = part_state.bgicon,
		number = value,
		item = bar_length,
		alignment = alignment,
		offset = {x = offset_x, y = offset_y},
		direction = hudbar_def.direction,
		size = {x = vl_hudbars.settings.scale_x, y = texture_height_y},
		z_index = z_index,
	})
	return layer_id
end

-- Draws a part of (for compound) or a whole (for simple) proportional hudbar
local function draw_proportional_hudbar_part(player, part_state, part_def,
											hudbar_def, offset_y, offset_x_left,
											offset_x_right, texture_height_y, z_index,
											squished_layer_gap)
	local bar_length = vl_hudbars.settings.bar_length
	-- Record the old y-offset in case this part shouldn't take up space
	local old_offset_y = offset_y

	if not part_state.state.hidden then
		-- Work out total 'on' parts
		local total_parts = part_def.layers * bar_length
		local value_parts = total_parts * part_state.state.value / part_state.state.max_val
		-- Use ceil so that a value of 0 is only displayed when value is actually 0
		value_parts = math_ceil(value_parts)

		for i=1,part_def.layers do
			local current_layer_value = math_min(math_max(value_parts, 0), bar_length)
			value_parts = value_parts - current_layer_value
			-- Reuse existing layers if possible
			if part_state.layer_ids[i] ~= nil then
				local layer_id = part_state.layer_ids[i]
				-- Change layer value and offset
				player:hud_change(layer_id, "number", current_layer_value)
				local offset_old = player:hud_get(layer_id).offset
				player:hud_change(layer_id, "offset", {x = offset_old.x, y = offset_y})
			else
				-- Need to make new layer
				part_state.layer_ids[i] = add_new_proportional_layer(player, hudbar_def, part_state,
				offset_y, offset_x_left, offset_x_right,
				current_layer_value, texture_height_y, z_index)
			end
			-- Change z_index by step for next layer
			z_index = z_index + part_def.z_index_step
			-- Update y-offset for next layer
			offset_y = offset_y - texture_height_y - squished_layer_gap
		end

		-- Remove now-unused layers
		for i=part_def.layers+1,#part_state.layer_ids do
			player:hud_remove(part_state.layer_ids[i])
			part_state.layer_ids[i] = nil
		end
	else
		-- If part is hidden, set the value and max_val of its layers to 0
		for i=1,#part_state.layer_ids do
			local layer_id = part_state.layer_ids[i]
			-- Change layer value and max_val
			player:hud_change(layer_id, "number", 0)
			player:hud_change(layer_id, "item", 0)
		end
	end
	-- Return the offset and z-index to start drawing the next layer at
	if part_def.take_up_space then
		return offset_y, z_index
	else
		return old_offset_y, z_index
	end
end

-- Draws a whole proportional hudbar
local function draw_proportional_hudbar(player, hudbar_state, hudbar_def,
										offset_y, offset_x_left, offset_x_right)
	local scale_x = vl_hudbars.settings.scale_x
	local texture_height_y = math_floor((hudbar_def.scale_y) * scale_x + 0.5)
	local z_index = hudbar_def.z_index

	local old_offset_y = offset_y
	-- If all of the parts are hidden then this hudbar will be hidden
	local is_hidden = true
	local squished_layer_gap

	if hudbar_def.is_compound then
		-- work out number of layers in hudbar (for squishing)
		local total_layers = 0
		for _, part_id in pairs(hudbar_state.parts_order) do
			local part_def = hudbar_def.parts[part_id]
			if not part_def.hidden and part_def.take_up_space then
				total_layers = total_layers + part_def.layers
			end
		end
		-- work out how much to squish
		squished_layer_gap = get_squished_layer_gap(hudbar_def.layer_gap, texture_height_y, total_layers)

		for _, part_id in pairs(hudbar_state.parts_order) do
			local part_def = hudbar_def.parts[part_id]
			local part_state = hudbar_state.parts[part_id]
			offset_y, z_index = draw_proportional_hudbar_part(player, part_state, part_def,
			hudbar_def, offset_y, offset_x_left,
			offset_x_right, texture_height_y, z_index,
			squished_layer_gap)
			z_index = z_index + part_def.z_index_offset
			-- If wasn't hidden, move up for next part
			if not part_state.state.hidden then
				is_hidden = false
				offset_y = offset_y - texture_height_y - squished_layer_gap
			end
		end

	else
		-- Only has one part
		is_hidden = hudbar_state.state.hidden

		-- work out how much to squish
		squished_layer_gap = get_squished_layer_gap(hudbar_def.layer_gap, texture_height_y, hudbar_def.layers)

		offset_y = draw_proportional_hudbar_part(player, hudbar_state, hudbar_def,
		hudbar_def, offset_y, offset_x_left,
		offset_x_right, texture_height_y, z_index,
		squished_layer_gap)
	end
	if not is_hidden then
		-- We added another gap, but we don't want one above the bar
		offset_y = offset_y + squished_layer_gap
	end
	-- Return y-offset of top of hudbar
	if hudbar_def.take_up_space then
		return offset_y
	else
		return old_offset_y
	end
end

-- Gets the x-offset at which to draw the continuation part of a compound hudbar
local function get_continuation_offset_x(direction, below_layer_parts, offset_x_left, offset_x_right)
	local scale_x = vl_hudbars.settings.scale_x
	if direction == 0 then -- left-to-right
		return offset_x_left + below_layer_parts * scale_x / 2
	else -- right-to-left
		return offset_x_right - below_layer_parts * scale_x / 2
	end
end

-- Add a new layer of an absolute hudbar because it didn't already exist
local function add_new_absolute_layer(player, hudbar_def, part_state,
									offset_y, offset_x, value, max_val,
									texture_height_y, z_index)
	local alignment
	if hudbar_def.direction == 0 then
		alignment = {x=-1, y=-1}
	else
		alignment = {x=1, y=-1}
	end

	-- Minetest changed the name of the 'hud_elem_type' field for 5.9.0
	local type_field_name
	if minetest.features.hud_def_type_field then
		type_field_name = "type"
	else
		type_field_name = "hud_elem_type"
	end

	local layer_id = player:hud_add({
		[type_field_name] = "statbar",
		position = vl_hudbars.settings.base_pos,
		text = part_state.icon,
		text2 = part_state.bgicon,
		number = value,
		item = max_val,
		alignment = alignment,
		offset = {x = offset_x, y = offset_y},
		direction = hudbar_def.direction,
		size = {x = vl_hudbars.settings.scale_x, y = texture_height_y},
		z_index = z_index,
	})
	return layer_id
end

-- Draws a part of (for compound) or a whole (for simple) absolute hudbar
-- `offset_y` is the y-offset of the potentially incomplete layer below
local function draw_absolute_hudbar_part(player, part_state, part_def,
										hudbar_def, offset_y, offset_x_left,
										offset_x_right, texture_height_y, z_index,
										below_layer_parts, squished_layer_gap)
	local bar_length = vl_hudbars.settings.bar_length
	local value_parts = part_state.state.value / hudbar_def.value_scale
	local max_val_parts = part_state.state.max_val / hudbar_def.value_scale
	-- Passed as `below_layer_parts` to next hudbar part
	local top_layer_parts = below_layer_parts
	local old_offset_y = offset_y

	-- Check for too many layers to prevent game crashing on high values
	local max_allowed_parts = vl_hudbars.settings.max_rendered_layers * vl_hudbars.settings.bar_length
	if max_val_parts > max_allowed_parts then
		max_val_parts = max_allowed_parts
		value_parts = math_min(value_parts, max_allowed_parts)
	end

	if not part_state.state.hidden then
		local layer_index = 1
		-- Draw continuation layer if applicable
		if below_layer_parts and below_layer_parts < bar_length then
			-- Calculate value, max_val for continuation layer
			local current_max_val_parts = math_min(max_val_parts, bar_length - below_layer_parts)
			if hudbar_def.round_to_full_texture and current_max_val_parts % 2 == 1 then
				current_max_val_parts = current_max_val_parts + 1
			end
			max_val_parts = max_val_parts - current_max_val_parts
			local current_value_parts = math_min(value_parts, current_max_val_parts)
			value_parts = value_parts - current_value_parts
			top_layer_parts = below_layer_parts + current_max_val_parts

			-- Draw continuation layer
			local layer_id = part_state.layer_ids[1]
			local offset_x = get_continuation_offset_x(hudbar_def.direction, below_layer_parts, offset_x_left, offset_x_right)
			if layer_id ~= nil then
				-- Reuse old first layer: change value, max_val and offset
				player:hud_change(layer_id, "number", current_value_parts)
				player:hud_change(layer_id, "item", current_max_val_parts)
				player:hud_change(layer_id, "offset", {x = offset_x, y = offset_y})
			else
				-- Have to make a new layer
				part_state.layer_ids[1] = add_new_absolute_layer(player, hudbar_def, part_state,
				offset_y, offset_x, current_value_parts,
				current_max_val_parts, texture_height_y, z_index)
			end


			if max_val_parts <= 0 then
				-- This continuation layer was the only layer necessary!
				-- Remove now-unused layers
				for i=layer_index+1,#part_state.layer_ids do
					player:hud_remove(part_state.layer_ids[i])
				end

				-- Move up a layer if this layer is full
				return offset_y, z_index, top_layer_parts
			end
			-- Otherwise keep going: draw next layers
			-- Change z_index by step for next layer
			z_index = z_index + part_def.z_index_step
			layer_index = layer_index + 1
		end
		if top_layer_parts ~= nil and max_val_parts > 0 then
			-- Update y-offset for next layer, only if this is not the first part drawn or the last layer
			offset_y = offset_y - texture_height_y - squished_layer_gap
		end

		while max_val_parts > 0 do
			-- Calculate value, max_val for layer
			local current_max_val_parts = math_min(max_val_parts, bar_length)
			if hudbar_def.round_to_full_texture and current_max_val_parts % 2 == 1 then
				current_max_val_parts = current_max_val_parts + 1
			end
			max_val_parts = max_val_parts - current_max_val_parts
			local current_value_parts = math_min(math_max(value_parts, 0), current_max_val_parts)
			value_parts = value_parts - current_value_parts
			-- Store the max number of parts in this layer
			top_layer_parts = current_max_val_parts

			-- Draw layer
			local layer_id = part_state.layer_ids[layer_index]
			local offset_x
			if hudbar_def.direction == 0 then
				offset_x = offset_x_left
			else
				offset_x = offset_x_right
			end
			if layer_id ~= nil then
				-- Reuse old first layer: change value, max_val and offset
				player:hud_change(layer_id, "number", current_value_parts)
				player:hud_change(layer_id, "item", current_max_val_parts)
				player:hud_change(layer_id, "offset", {x = offset_x, y = offset_y})
			else
				-- Have to make a new layer
				part_state.layer_ids[layer_index] = add_new_absolute_layer(player, hudbar_def, part_state,
					offset_y, offset_x, current_value_parts,
					current_max_val_parts, texture_height_y, z_index
				)
			end
			-- Update y-offset for next layer, unless this is the last layer
			if max_val_parts > 0 then
				offset_y = offset_y - texture_height_y - squished_layer_gap
			end
			-- Change z_index by step for next layer
			z_index = z_index + part_def.z_index_step
			layer_index = layer_index + 1
		end
		-- Remove old layers which are now unused
		for i=layer_index,#part_state.layer_ids do
			player:hud_remove(part_state.layer_ids[i])
			part_state.layer_ids[i] = nil
		end

		if part_def.take_up_space then
			return offset_y, z_index, top_layer_parts
		else
			return old_offset_y, z_index, top_layer_parts
		end
	else
		-- If part is hidden, set the value and max_val of its layers to 0
		for i=1,#part_state.layer_ids do
			local layer_id = part_state.layer_ids[i]
			-- Change layer value and max_val
			player:hud_change(layer_id, "number", 0)
			player:hud_change(layer_id, "item", 0)
		end
		-- Return same stuff to start drawing next part with as this part was hidden
		return offset_y, z_index, below_layer_parts
	end
end

-- Draws a whole absolute hudbar
local function draw_absolute_hudbar(player, hudbar_state, hudbar_def, offset_y, offset_x_left, offset_x_right)
	local bar_length = vl_hudbars.settings.bar_length
	local scale_x = vl_hudbars.settings.scale_x
	local texture_height_y = math_floor((hudbar_def.scale_y) * scale_x + 0.5)
	local z_index = hudbar_def.z_index

	-- If all of the parts are hidden then this hudbar will be hidden
	local is_hidden = true

	local squished_layer_gap
	-- Stores the number of max parts in the last layer drawn
	local below_layer_parts = nil
	if hudbar_def.is_compound then
		-- work out how much to squish by
		local total_parts = 0
		for _, part_id in pairs(hudbar_state.parts_order) do
			local part_state = hudbar_state.parts[part_id]
			total_parts = total_parts + part_state.state.max_val
		end
		local total_layers = math_ceil(total_parts / hudbar_def.value_scale / bar_length)
		squished_layer_gap = get_squished_layer_gap(hudbar_def.layer_gap, texture_height_y, total_layers)

		for _, part_id in pairs(hudbar_state.parts_order) do
			local part_def = hudbar_def.parts[part_id]
			local part_state = hudbar_state.parts[part_id]
			offset_y, z_index, below_layer_parts = draw_absolute_hudbar_part(player, part_state, part_def,
				hudbar_def, offset_y, offset_x_left,
				offset_x_right, texture_height_y, z_index,
				below_layer_parts, squished_layer_gap
			)
			z_index = z_index + part_def.z_index_offset
			if not part_state.state.hidden then
				is_hidden = false
			end
		end
	else
		is_hidden = hudbar_state.state.hidden

		-- work out how much to squish by
		local total_layers = math_ceil(hudbar_state.state.max_val / hudbar_def.value_scale / bar_length)
		squished_layer_gap = get_squished_layer_gap(hudbar_def.layer_gap, texture_height_y, total_layers)
		offset_y = draw_absolute_hudbar_part(player, hudbar_state, hudbar_def,
			hudbar_def, offset_y, offset_x_left,
			offset_x_right, texture_height_y, z_index,
			below_layer_parts, squished_layer_gap)
	end
	if not is_hidden then
		-- Move to top of hudbar so update_hudbar_display can get height
		offset_y = offset_y - texture_height_y
	end
	return offset_y
end

-- Updates or creates HUD layers for hudbar `identifier` for player `player`
-- Also moves any hudbars above the bar being updated up or down if the height changed
-- This function must be called when an absolute hudbar changes height or a new hudbar is added
local function update_hudbar_display(player, identifier)
	local name = player:get_player_name()
	local hudstate = vl_hudbars.players[name]
	local hudbar_defs = vl_hudbars.hudbar_defs

	local hudbar_state = hudstate.hudbar_states[identifier]
	local hudbar_def = hudbar_defs[identifier]

	-- Get order table and starting offset based on which side of the screen the hudbar is on
	local hudbar_order
	local bar_length_pixels = get_bar_length_pixels()
	local offset_y, offset_x_left, offset_x_right
	if hudbar_def.on_right then
		hudbar_order = hudstate.hudbar_order_right
		offset_y = vl_hudbars.settings.start_offset_right.y
		-- The start_offset setting is for the offset on the side closer to screen centre
		offset_x_left = vl_hudbars.settings.start_offset_right.x
		offset_x_right = offset_x_left + bar_length_pixels
	else
		hudbar_order = hudstate.hudbar_order_left
		offset_y = vl_hudbars.settings.start_offset_left.y
		-- The start_offset setting is for the offset on the side closer to screen centre
		offset_x_right = vl_hudbars.settings.start_offset_left.x
		offset_x_left = offset_x_right - bar_length_pixels
	end
	if hudbar_def.direction == 1 then
		-- I don't know why we need to offset by 1 texture when drawing right-to-left, but we do
		offset_x_right = offset_x_right - vl_hudbars.settings.scale_x
	end

	-- Loop through the hudbars until we find the relevant one, then update it and reposition all above
	local is_above_updated = false
	local hudbar_translation_amount
	for _, other_identifier in pairs(hudbar_order) do
		if other_identifier == identifier then
			local above_offset_y
			if hudbar_def.value_type == "proportional" then
				above_offset_y = draw_proportional_hudbar(player, hudbar_state, hudbar_def, offset_y, offset_x_left, offset_x_right)
			else
				above_offset_y = draw_absolute_hudbar(player, hudbar_state, hudbar_def, offset_y, offset_x_left, offset_x_right)
			end
			is_above_updated = true
			-- Calculate amount to translate above hudbars by
			-- Positive y-offset is down!
			local new_height = (offset_y - above_offset_y)

			local old_height = hudbar_state.current_height_pixels
			local was_hidden = old_height == 0
			local is_hidden = new_height == 0

			hudbar_state.current_height_pixels = new_height
			hudbar_translation_amount = old_height - new_height
			if was_hidden and not is_hidden then
				-- The previous bottom hudbar doesn't have a gap beneath it, so we need push it up a bit extra
				-- OR this bar was hidden and now it isn't, so we need to add a gap above
				hudbar_translation_amount = hudbar_translation_amount - vl_hudbars.settings.hudbar_height_gap
			elseif is_hidden and not was_hidden then
				-- We just hid it, so there shouldn't be a gap above
				hudbar_translation_amount = hudbar_translation_amount + vl_hudbars.settings.hudbar_height_gap
			end
		elseif is_above_updated then -- above updated: update position by translation
			if hudbar_translation_amount ~= 0 then
				-- update position
				translate_hudbar(player, hudstate.hudbar_states[other_identifier], hudbar_translation_amount, hudbar_defs[other_identifier].is_compound)
			end
		else -- below updated: do not update, just add height to offset
			-- add height to offset
			local hudbar_height = hudstate.hudbar_states[other_identifier].current_height_pixels
			offset_y = offset_y - hudbar_height
			if hudbar_height ~= 0 then -- only add gap if hudbar is displayed/takes up space
				offset_y = offset_y - vl_hudbars.settings.hudbar_height_gap
			end
		end
	end
end

local default_hudbar_params = {
	identifier = nil, -- required field
	sort_index = 0,
	on_right = false,
	direction = 0,
	layer_gap = 4, -- in pixels
	scale_y = 1, -- aspect ratio (height/width) of displayed texture
	value_type = "absolute", -- 'absolute' or 'proportional'
	is_compound = false,
	take_up_space = true, -- whether to reserve height space for this hudbar
	value_scale = 1, -- for absolute how much value one half-texture represents
	round_to_full_texture = true,
	z_index = 99, -- starting z-index of hudbar
}

local default_simple_hudbar_params = {
	default_max_val = 1, -- don't make 0 for proportional hudbar! div0 error...
	default_value = 0,
	default_hidden = false,
	icon = nil, -- required field
	bgicon = nil, -- required field
	layers = 1,
	z_index_step = -1,
}

local default_compound_part_params = {
	default_value = 0,
	default_max_val = 1,
	default_hidden = false,
	icon = nil, -- required field
	bgicon = nil, -- required field
	layers = 1,
	part_sort_index = 0,
	take_up_space = true,
	z_index_offset = 0,
	z_index_step = -1,
}

local function populate_from_defaults(params, defaults)
	for k, v in pairs(defaults) do
		if params[k] == nil then
			params[k] = v
		end
	end
end

function vl_hudbars.register_hudbar(hudbar_params)
	populate_from_defaults(hudbar_params, default_hudbar_params)

	local identifier = hudbar_params.identifier
	local hudtable = {
		identifier = hudbar_params.identifier,
		sort_index = hudbar_params.sort_index,
		on_right = hudbar_params.on_right,
		direction = hudbar_params.direction,
		layer_gap = hudbar_params.layer_gap, -- in pixels
		scale_y = hudbar_params.scale_y, -- aspect ratio (height/width) of displayed texture
		value_type = hudbar_params.value_type, -- 'absolute' or 'proportional'
		is_compound = hudbar_params.is_compound,
		take_up_space = hudbar_params.take_up_space, -- whether to reserve height space for this hudbar
		value_scale = hudbar_params.value_scale, -- for absolute how much value one half-texture represents
		round_to_full_texture = hudbar_params.round_to_full_texture,
		z_index = hudbar_params.z_index, -- starting z-index of hudbar
	}
	if not hudbar_params.is_compound then
		populate_from_defaults(hudbar_params, default_simple_hudbar_params)
		hudtable.default_max_val = hudbar_params.default_max_val
		hudtable.default_value = hudbar_params.default_value
		hudtable.default_hidden = hudbar_params.default_hidden
		hudtable.icon = hudbar_params.icon
		hudtable.bgicon = hudbar_params.bgicon
		hudtable.layers = hudbar_params.layers -- for proportional how many layers
		hudtable.z_index_step = hudbar_params.z_index_step -- step for each new layer in hudbar
	else
		-- Compound bars have their parts stored in hudbar_def.parts[part_name]
		hudtable.parts = {}
		for id, def in pairs(hudbar_params.parts) do
			populate_from_defaults(def, default_compound_part_params)
			hudtable.parts[id] = {
				default_value = def.default_value,
				default_max_val = def.default_max_val,
				default_hidden = def.default_hidden,
				icon = def.icon,
				bgicon = def.bgicon,
				layers = def.layers, -- for proportional how many layers
				part_sort_index = def.part_sort_index,
				take_up_space = def.take_up_space, -- whether to reserve space for this part
				z_index_offset = def.z_index_offset, -- relative z-index of part to previous
				z_index_step = def.z_index_step, -- step for each new layer in part
			}
		end
	end

	-- Record passed parameters in vl_hudbars.hudbar_defs
	vl_hudbars.hudbar_defs[identifier] = hudtable
end

-- Should be callable even if hudbar has already been inited, used to reset hudbar
function vl_hudbars.init_hudbar(player, identifier)
	if not (player ~= nil and player:is_player()) then return end
	local name = player:get_player_name()
	init_player_hudtracking(name)

	-- Get the player's current hudstate and the new hudbar's definition
	local player_hudstate = vl_hudbars.players[name]
	local hudbar_def = vl_hudbars.hudbar_defs[identifier]

	-- Work out sorting based on hudbar's sort_index
	if hudbar_def.on_right then
		insert_hudbar(player_hudstate.hudbar_order_right, identifier)
	else
		insert_hudbar(player_hudstate.hudbar_order_left, identifier)
	end

	if player_hudstate.hudbar_states[identifier] ~= nil then
		vl_hudbars.remove_hudbar(player, identifier)
	end

	-- Initialise hudbar state for this player and hudbar
	if hudbar_def.is_compound then
		local hudbar_state = {
			current_height_pixels = 0,
			parts_order = {},
			parts = {}
		}
		for id, def in pairs(hudbar_def.parts) do
			hudbar_state.parts[id] = {
				layer_ids = {},
				state = {},
				icon = def.icon,
				base_icon = def.icon, -- icon to use when no modifiers apply
				bgicon = def.bgicon,
			}
			local inserted = false
			for i, other_partid in pairs(hudbar_state.parts_order) do
				if hudbar_def.parts[other_partid].part_sort_index < def.part_sort_index then
					table.insert(hudbar_state.parts_order, i, id)
					inserted = true
					break
				end
			end
			if not inserted then
				-- This part has lowest priority: put it at the end
				table.insert(hudbar_state.parts_order, id)
			end

			-- Initialise starting values from defaults
			hudbar_state.parts[id].state.value = def.default_value
			hudbar_state.parts[id].state.max_val = def.default_max_val
			hudbar_state.parts[id].state.hidden = def.default_hidden
		end
		player_hudstate.hudbar_states[identifier] = hudbar_state

	else
		player_hudstate.hudbar_states[identifier] = {
			layer_ids = {},
			state = {},
			current_height_pixels = 0,
			icon = hudbar_def.icon,
			base_icon = hudbar_def.icon, -- icon to use when no modifiers apply
			bgicon = hudbar_def.bgicon,
		}
		local hudbar_state = player_hudstate.hudbar_states[identifier]

		-- Initialise starting values from defaults
		hudbar_state.state.value = hudbar_def.default_value
		hudbar_state.state.max_val = hudbar_def.default_max_val
		hudbar_state.state.hidden = hudbar_def.default_hidden
	end

	-- Update this hudbar on the player's screen
	update_hudbar_display(player, identifier)
end

function vl_hudbars.remove_hudbar(player, identifier)
	if not vl_hudbars.has_hudbar(player, identifier) then return end
	local name = player:get_player_name()
	local hudbar_states = vl_hudbars.players[name].hudbar_states
	local hudbar_state = hudbar_states[identifier]
	local hudbar_def = vl_hudbars.hudbar_defs[identifier]

	local hudbar_order
	if hudbar_def.on_right then
		hudbar_order = hudbar_states.hudbar_order_right
	else
		hudbar_order = hudbar_states.hudbar_order_left
	end

	for i, other_identifier in pairs(hudbar_order) do
		if identifier == other_identifier then
			table.remove(hudbar_order, i)
		end
	end

	if hudbar_def.is_compound then
		for _, part_state in pairs(hudbar_state.parts) do
			for _, layer_id in pairs(part_state.layer_ids) do
				player:hud_remove(layer_id)
			end
		end
	else
		for _, layer_id in pairs(hudbar_state.layer_ids) do
			player:hud_remove(layer_id)
		end
	end
	hudbar_states[identifier] = nil

	update_hudbar_display(player, identifier)
end

function vl_hudbars.change_value(player, identifier, value, max_val, part)
	if not vl_hudbars.has_hudbar(player, identifier) then return end
	local name = player:get_player_name()
	local hudbar_state = vl_hudbars.players[name].hudbar_states[identifier]
	local hudbar_def = vl_hudbars.hudbar_defs[identifier]

	if hudbar_def.is_compound then
		hudbar_state = hudbar_state.parts[part]
	end
	-- Don't update display if nothing changed
	if value == hudbar_state.state.value and max_val == hudbar_state.state.max_val then return end

	if value == nil then value = hudbar_state.state.value end
	if max_val == nil then max_val = hudbar_state.state.max_val end
	hudbar_state.state.value = value
	hudbar_state.state.max_val = max_val
	update_hudbar_display(player, identifier)
end

function vl_hudbars.hide(player, identifier, part)
	if not vl_hudbars.has_hudbar(player, identifier) then return end
	local name = player:get_player_name()
	local hudbar_state = vl_hudbars.players[name].hudbar_states[identifier]
	local hudbar_def = vl_hudbars.hudbar_defs[identifier]

	local state_changed = false
	if hudbar_def.is_compound then
		if part == nil then
			-- Hide every part
			for _, part_state in pairs(hudbar_state.parts) do
				if part_state.state.hidden ~= true then
					part_state.state.hidden = true
					state_changed = true
				end
			end
		else
			local part_state = hudbar_state.parts[part]
			if part_state.state.hidden ~= true then
				part_state.state.hidden = true
				state_changed = true
			end
		end
	else
		if hudbar_state.state.hidden ~= true then
			hudbar_state.state.hidden = true
			state_changed = true
		end
	end

	-- Only update display if hudbar wasn't already hidden
	if state_changed then
		update_hudbar_display(player, identifier)
	end
end

function vl_hudbars.show(player, identifier, part)
	if not vl_hudbars.has_hudbar(player, identifier) then return end
	local name = player:get_player_name()
	local hudbar_state = vl_hudbars.players[name].hudbar_states[identifier]
	local hudbar_def = vl_hudbars.hudbar_defs[identifier]
	local state_changed = false
	if hudbar_def.is_compound then
		if part == nil then
			-- Show every part
			for _, part_state in pairs(hudbar_state.parts) do
				if part_state.state.hidden ~= false then
					part_state.state.hidden = false
					state_changed = true
				end
			end
		else
			local part_state = hudbar_state.parts[part]
			if part_state.state.hidden ~= false then
				part_state.state.hidden = false
				state_changed = true
			end
		end
	else
		if hudbar_state.state.hidden ~= false then
			hudbar_state.state.hidden = false
			state_changed = true
		end
	end

	-- Only update display if hudbar wasn't already shown
	if state_changed then
		update_hudbar_display(player, identifier)
	end
end

function vl_hudbars.set_icon(player, identifier, new_icon, part)
	if not vl_hudbars.has_hudbar(player, identifier) then return end
	local name = player:get_player_name()
	local hudbar_state = vl_hudbars.players[name].hudbar_states[identifier]
	local hudbar_def = vl_hudbars.hudbar_defs[identifier]

	if hudbar_def.is_compound then
		hudbar_state = hudbar_state.parts[part]
	end
	hudbar_state.icon = new_icon

	-- Don't need to update_hudbar_display as nothing is moving
	for _, layer_id in pairs(hudbar_state.layer_ids) do
		player:hud_change(layer_id, "text", new_icon)
	end
end

-- resets icon to default
function vl_hudbars.reset_icon(player, identifier, part)
	if not vl_hudbars.has_hudbar(player, identifier) then return end
	local name = player:get_player_name()
	local hudbar_state = vl_hudbars.players[name].hudbar_states[identifier]
	local hudbar_def = vl_hudbars.hudbar_defs[identifier]

	if hudbar_def.is_compound then
		hudbar_state = hudbar_state.parts[part]
	end
	hudbar_state.icon = hudbar_state.base_icon

	-- Don't need to update_hudbar_display as nothing is moving
	for _, layer_id in pairs(hudbar_state.layer_ids) do
		player:hud_change(layer_id, "text", hudbar_state.base_icon)
	end
end


function vl_hudbars.set_bgicon(player, identifier, new_bgicon, part)
	if not vl_hudbars.has_hudbar(player, identifier) then return end
	local name = player:get_player_name()
	local hudbar_state = vl_hudbars.players[name].hudbar_states[identifier]
	local hudbar_def = vl_hudbars.hudbar_defs[identifier]

	if hudbar_def.is_compound then
		hudbar_state = hudbar_state.parts[part]
	end
	hudbar_state.bgicon = new_bgicon

	-- Don't need to update_hudbar_display as nothing is moving
	for _, layer_id in pairs(hudbar_state.layer_ids) do
		player:hud_change(layer_id, "text2", new_bgicon)
	end
end

function vl_hudbars.has_hudbar(player, identifier)
	local name = player:get_player_name()
	local hudbar_states = vl_hudbars.players[name].hudbar_states
	return hudbar_states[identifier] ~= nil
end

local hudbar_modifiers = {}

function vl_hudbars.register_hudbar_modifier(def)
	if type(def.predicate) ~= "function" then error("Predicate must be a function") end
	if not def.icon then error("No icon provided") end
	if not def.identifier then error("No hudbar identifier provided") end
	if not def.priority then error("No priority provided") end
	hudbar_modifiers[def.identifier] = hudbar_modifiers[def.identifier] or {}
	if def.part ~= nil then
		hudbar_modifiers[def.identifier][def.part] = hudbar_modifiers[def.identifier][def.part] or {}
		table.insert(hudbar_modifiers[def.identifier][def.part], {
			predicate = def.predicate,
			icon = def.icon,
			priority = def.priority,
		})
		table.sort(hudbar_modifiers[def.identifier][def.part], function(a, b) return a.priority <= b.priority end)
	else
		table.insert(hudbar_modifiers[def.identifier], {
			predicate = def.predicate,
			icon = def.icon,
			priority = def.priority,
		})
		table.sort(hudbar_modifiers[def.identifier], function(a, b) return a.priority <= b.priority end)
	end
end

function vl_hudbars.update_hudbar_modifiers(player, identifier, part)
	local modifiers = hudbar_modifiers[identifier]
	if part ~= nil and modifiers ~= nil then
		modifiers = modifiers[part]
	end
	-- If no modifiers have been registered then this variable will be nil
	if modifiers == nil then return end
	for _, mod in pairs(modifiers) do
		if mod.predicate(player) then
			vl_hudbars.set_icon(player, identifier, mod.icon, part)
			return
		end
	end
	vl_hudbars.reset_icon(player, identifier, part)
end

minetest.register_on_leaveplayer(function(player)
	vl_hudbars.players[player:get_player_name()] = nil
end)

dofile(modpath .. "/builtins.lua")
