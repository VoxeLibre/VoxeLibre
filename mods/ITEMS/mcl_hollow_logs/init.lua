local modpath = minetest.get_modpath(minetest.get_current_modname())
local S = minetest.get_translator(minetest.get_current_modname())

logs = {
    {"acaciatree", "Hollow Acacia Log", "Stripped Hollow Acacia Log"},
    {"birchtree", "Hollow Birch Log", "Stripped Hollow Birch Log"},
    {"darktree", "Hollow Dark Oak Log", "Stripped Hollow Dark Oak Log"},
    {"jungletree", "Hollow Jungle Log", "Stripped Hollow Jungle Log"},
    {"sprucetree", "Hollow Spruce Log", "Stripped Hollow Spruce Log"},
    {"tree", "Hollow Oak Log", "Stripped Hollow Oak Log"}
}

if minetest.get_modpath("mcl_cherry_blossom") then
    table.insert(logs, {"cherrytree", "Hollow Cherry Log", "Stripped Hollow Cherry Log"})
end

if minetest.get_modpath("mcl_mangrove") then
    table.insert(logs, {"mangrove_tree", "Hollow Mangrove Log", "Stripped Hollow Mangrove Log"})
end

local collisionbox = {
    type = "fixed",
    fixed = {
        {-0.5, -0.5, -0.5, 0.5, 0.5, -0.375},
        {-0.5, -0.5, -0.5, -0.375, 0.5, 0.5},
        {0.375, -0.5, -0.5, 0.5, 0.5, 0.5},
        {-0.5, -0.5, 0.375, 0.5, 0.5, 0.5},
    }
}

for i = 1, #logs do
    local name = logs[i][1]
    local normal_desc = logs[i][2]
    local stripped_desc = logs[i][3]

    minetest.register_node("mcl_hollow_logs:"..name.."_hollow", {
        collision_box = collisionbox,
        description = S(normal_desc),
        drawtype = "mesh",
        groups = {
            axey = 1, building_block = 1, fire_encouragement = 5, fire_flammability = 5, flammable = 2,
            handy = 1, hollow_log = 1
        },
        mesh = "mcl_hollow_logs_log.obj",
        on_place = mcl_util.rotate_axis,
        paramtype = "light",
        paramtype2 = "facedir",
        sounds = mcl_sounds.node_sound_wood_defaults(),
        sunlight_propagates = true,
        tiles = {"mcl_hollow_logs_"..name..".png"},
        _mcl_blast_resistance = 2,
        _mcl_hardness = 2,
        _mcl_stripped_variant = "mcl_hollow_logs:stripped_"..name.."_hollow"
    })

    minetest.register_node("mcl_hollow_logs:stripped_"..name.."_hollow", {
        collision_box = collisionbox,
        description = S(stripped_desc),
        drawtype = "mesh",
        groups = {
            axey = 1, building_block = 1, fire_encouragement = 5, fire_flammability = 5, flammable = 2,
            handy = 1, hollow_log = 1
        },
        mesh = "mcl_hollow_logs_log.obj",
        on_place = mcl_util.rotate_axis,
        paramtype = "light",
        paramtype2 = "facedir",
        sounds = mcl_sounds.node_sound_wood_defaults(),
        sunlight_propagates = true,
        tiles = {"mcl_hollow_logs_stripped_"..name..".png"},
        _mcl_blast_resistance = 2,
        _mcl_hardness = 2
    })
end

if minetest.get_modpath("mcl_crimson") then
    minetest.register_node("mcl_hollow_logs:crimson_hyphae_hollow", {
        collision_box = collisionbox,
        description = S("Hollow Crimson Stem"),
        drawtype = "mesh",
        groups = {axey = 1, building_block = 1, handy = 1, hollow_stem = 1},
        mesh = "mcl_hollow_logs_log.obj",
        on_place = mcl_util.rotate_axis,
        paramtype = "light",
        paramtype2 = "facedir",
        sounds = mcl_sounds.node_sound_wood_defaults(),
        sunlight_propagates = true,
        tiles = {"mcl_hollow_logs_crimson.png"},
        _mcl_blast_resistance = 2,
        _mcl_hardness = 2,
       _mcl_stripped_variant = "mcl_hollow_logs:stripped_crimson_hyphae_hollow"
    })

    minetest.register_node("mcl_hollow_logs:stripped_crimson_hyphae_hollow", {
        collision_box = collisionbox,
        description = S("Stripped Hollow Crimson Stem"),
        drawtype = "mesh",
        groups = {axey = 1, building_block = 1, handy = 1, hollow_stem = 1},
        mesh = "mcl_hollow_logs_log.obj",
        on_place = mcl_util.rotate_axis,
        paramtype = "light",
        paramtype2 = "facedir",
        sounds = mcl_sounds.node_sound_wood_defaults(),
        sunlight_propagates = true,
        tiles = {"mcl_hollow_logs_stripped_crimson.png"},
        _mcl_blast_resistance = 2,
        _mcl_hardness = 2
    })

    minetest.register_node("mcl_hollow_logs:warped_hyphae_hollow", {
        collision_box = collisionbox,
        description = S("Hollow Warped Stem"),
        drawtype = "mesh",
        groups = {axey = 1, building_block = 1, handy = 1, hollow_stem = 1},
        mesh = "mcl_hollow_logs_log.obj",
        on_place = mcl_util.rotate_axis,
        paramtype = "light",
        paramtype2 = "facedir",
        sounds = mcl_sounds.node_sound_wood_defaults(),
        sunlight_propagates = true,
        tiles = {"mcl_hollow_logs_warped.png"},
        _mcl_blast_resistance = 2,
        _mcl_hardness = 2,
       _mcl_stripped_variant = "mcl_hollow_logs:stripped_warped_hyphae_hollow"
    })

    minetest.register_node("mcl_hollow_logs:stripped_warped_hyphae_hollow", {
        collision_box = collisionbox,
        description = S("Stripped Hollow Warped Stem"),
        drawtype = "mesh",
        groups = {axey = 1, building_block = 1, handy = 1, hollow_stem = 1},
        mesh = "mcl_hollow_logs_log.obj",
        on_place = mcl_util.rotate_axis,
        paramtype = "light",
        paramtype2 = "facedir",
        sounds = mcl_sounds.node_sound_wood_defaults(),
        sunlight_propagates = true,
        tiles = {"mcl_hollow_logs_stripped_warped.png"},
        _mcl_blast_resistance = 2,
        _mcl_hardness = 2
    })
end

dofile(modpath.."/recipes.lua")
