local S = minetest.get_translator(minetest.get_current_modname())

mcl_torches.register_torch({
	name = "torch",
	description = S("Torch"),
	doc_items_longdesc = S("Torches are light sources which can be placed at the side or on the top of most blocks."),
	doc_items_hidden = false,
	icon = "default_torch_on_floor.png",
	tiles = {{
		name = "default_torch_on_floor_animated.png",
		animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
	}},
	-- this is 15 in minecraft
	light = 14,
	groups = {dig_immediate = 3, deco_block = 1},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	particles = true,
	flame_type = 1,
})

minetest.register_craft({
	output = "mcl_torches:torch 4",
	recipe = {
		{"group:coal"},
		{"mcl_core:stick"},
	}
})

-- Fake light nodes for held-torch lighting
for i = 1, core.LIGHT_MAX do
	core.register_node("mcl_torches:light_" .. i, {
		drawtype = "airlike",
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		pointable = false,
		buildable_to = true,
		floodable = true,
		light_source = i,
		groups = {not_in_creative_inventory = 1, fake_torch_light = i},
	})
end

local player_light = {} -- player_name -> {pos, level}

local function remove_player_light(player_name)
	local data = player_light[player_name]
	if not data then return end
	local node = core.get_node(data.pos)
	if node.name == "mcl_torches:light_" .. data.level then
		core.remove_node(data.pos)
	end
	player_light[player_name] = nil
end

core.register_on_leaveplayer(function(player)
	remove_player_light(player:get_player_name())
end)

local function get_torch_light(itemstack)
	local def = core.registered_nodes[itemstack:get_name()]
	if def and (def.light_source or 0) > 0 then
		return def.light_source or 0
	end
	return 0
end

local held_light_timer = 0
core.register_globalstep(function(dtime)
	held_light_timer = held_light_timer + dtime
	if held_light_timer < 0.1 then return end
	held_light_timer = 0

	for _, player in pairs(core.get_connected_players()) do
		local name = player:get_player_name()
		local inv = player:get_inventory()
		local level = math.max(
			get_torch_light(player:get_wielded_item()),
			get_torch_light(inv:get_stack("offhand", 1))
		)

		if level > 0 then
			local pos = vector.round(vector.offset(player:get_pos(), 0, 1, 0))
			local data = player_light[name]

			-- Otherwise no change needed
			if not data or not vector.equals(pos, data.pos) or data.level ~= level then
				if data then
					local old = core.get_node(data.pos)
					if old.name == "mcl_torches:light_" .. data.level then
						core.remove_node(data.pos)
					end
					player_light[name] = nil
				end
				if core.get_node(pos).name == "air" then
					core.set_node(pos, {name = "mcl_torches:light_" .. level})
					player_light[name] = {pos = pos, level = level}
				end
			end
		else
			remove_player_light(name)
		end
	end
end)

