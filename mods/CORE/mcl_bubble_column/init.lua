local S = minetest.get_translator("mcl_bubble_column")

local WATER_ALPHA = 179
local WATER_VISC = 1
local LAVA_VISC = 7
local LIGHT_LAVA = minetest.LIGHT_MAX
local USE_TEXTURE_ALPHA
if minetest.features.use_texture_alpha_string_modes then
	USE_TEXTURE_ALPHA = "blend"
	WATER_ALPHA = nil
end

minetest.register_node("mcl_bubble_column:water_flowing", {
	description = S("Bubble Column Flowing Water"),
	_doc_items_create_entry = false,
	wield_image = "default_water_flowing_animated.png^[verticalframe:64:0",
	drawtype = "flowingliquid",
	tiles = {"default_water_flowing_animated.png^[verticalframe:64:0"},
	special_tiles = {
		{
			image="default_water_flowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=4.0}
		},
		{
			image="default_water_flowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=4.0}
		},
	},
	sounds = mcl_sounds.node_sound_water_defaults(),
	is_ground_content = false,
	alpha = WATER_ALPHA,
	use_texture_alpha = USE_TEXTURE_ALPHA,
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 4,
	liquidtype = "flowing",
	liquid_alternative_flowing = "mcl_bubble_column:water_flowing",
	liquid_alternative_source = "mcl_bubble_column:water_source",
	liquid_viscosity = WATER_VISC,
	liquid_range = 7,
	post_effect_color = {a=209, r=0x03, g=0x3C, b=0x5C},
	groups = { water=3, liquid=3, puts_out_fire=1, not_in_creative_inventory=1, freezes=1, melt_around=1, dig_by_piston=1},
	_mcl_blast_resistance = 100,
	-- Hardness intentionally set to infinite instead of 100 (Minecraft value) to avoid problems in creative mode
	_mcl_hardness = -1,
})

minetest.register_node("mcl_bubble_column:water_source", {
	description = S("Bubble Column Water Source"),
	_doc_items_entry_name = S("Water"),
	_doc_items_longdesc = S("Boosts you up"),
	_doc_items_hidden = false,
	drawtype = "liquid",
	tiles = {
		{name="default_water_source_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=5.0}}
	},
	special_tiles = {
		-- New-style water source material (mostly unused)
		{
			name="default_water_source_animated.png",
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=5.0},
			backface_culling = false,
		}
	},
	sounds = mcl_sounds.node_sound_water_defaults(),
	is_ground_content = false,
	alpha = WATER_ALPHA,
	use_texture_alpha = USE_TEXTURE_ALPHA,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 4,
	liquidtype = "source",
	liquid_alternative_flowing = "mcl_bubble_column:water_flowing",
	liquid_alternative_source = "mcl_bubble_column:water_source",
	liquid_viscosity = WATER_VISC,
	liquid_range = 7,
	post_effect_color = {a=209, r=0x03, g=0x3C, b=0x5C},
	stack_max = 64,
	groups = { water=3, liquid=3, puts_out_fire=1, not_in_creative_inventory=1, dig_by_piston=1},
	_mcl_blast_resistance = 100,
	-- Hardness intentionally set to infinite instead of 100 (Minecraft value) to avoid problems in creative mode
	_mcl_hardness = -1,
})


minetest.register_globalstep(function()
    for _,player in ipairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        local pos = player:get_pos()
        local node = minetest.get_node(pos)
        if node.name == "mcl_bubble_column:water_source" then
            local velocity = player:get_player_velocity()
            local velocityadd = {x = 0, y = 2, z = 0}
            player:add_player_velocity(velocityadd)
        end
    end
end)

minetest.register_abm{
    label = "bubbles go up",
    nodenames = {"mcl_bubble_column:water_source"},
    interval = 1,
    chance = 1,
    action = function(pos)
        local uppos = vector.add(pos, {x = 0, y = 1, z = 0})
        local upposnode = minetest.get_node(uppos)
        if upposnode.name == "mcl_core:water_source" then
            minetest.set_node(uppos, {name = "mcl_bubble_column:water_source"})
        end
    end,
}

minetest.register_abm{
    label = "start bubble column",
    nodenames = {"mcl_nether:soul_sand"},
    interval = 1,
    chance = 1,
    action = function(pos)
        local downpos = vector.add(pos, {x = 0, y = 1, z = 0})
        local downposnode = minetest.get_node(downpos)
        if downposnode.name == "mcl_core:water_source" then
            minetest.set_node(downpos, {name = "mcl_bubble_column:water_source"})
        end
    end,
}

minetest.register_abm{
    label = "stop bubble column",
    nodenames = {"mcl_bubble_column:water_source"},
    interval = 1,
    chance = 1,
    action = function(pos)
        local downpos = vector.add(pos, {x = 0, y = -1, z = 0})
        local downposnode = minetest.get_node(downpos)
        if downposnode.name == "mcl_core:water_source" then
            minetest.set_node(pos, {name = "mcl_core:water_source"})
        end
    end,
}
minetest.register_abm{
    label = "bubbles",
    nodenames = {"mcl_bubble_column:water_source"},
    interval = 1,
    chance = 1,
    action = function(pos)
        minetest.add_particlespawner({
			amount = 10,
			time = 0.15,
			minpos = vector.add(pos, { x = -0.25, y = 0, z = -0.25 }),
			maxpos = vector.add(pos, { x = 0.25, y = 0, z = 0.75 }),
			attached = player,
			minvel = {x = -0.2, y = 0, z = -0.2},
			maxvel = {x = 0.5, y = 0, z = 0.5},
			minacc = {x = -0.4, y = 4, z = -0.4},
			maxacc = {x = 0.5, y = 1, z = 0.5},
			minexptime = 0.3,
			maxexptime = 0.8,
			minsize = 0.7,
			maxsize = 2.4,
			texture = "mcl_particles_bubble.png"
		})
    end,
}
