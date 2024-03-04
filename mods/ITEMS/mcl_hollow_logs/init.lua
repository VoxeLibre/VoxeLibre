local modpath = minetest.get_modpath(minetest.get_current_modname())
local S = minetest.get_translator(minetest.get_current_modname())

local core_logs = {"acacia", "birch", "dark_oak", "jungle", "oak", "spruce"}

local collisionbox = {
    type = "fixed",
    fixed = {
        {-0.5, -0.5, -0.5, 0.5, 0.5, -0.375},
        {-0.5, -0.5, -0.5, -0.375, 0.5, 0.5},
        {0.375, -0.5, -0.5, 0.5, 0.5, 0.5},
        {-0.5, -0.5, 0.375, 0.5, 0.5, 0.5},
    }
}

local function set_desc(name)
    return (name:gsub("_", " "):gsub("(%a)([%w_']*)", function (first, rest)
        return first:upper()..rest:lower()
    end))
end

for i = 1, #core_logs do
    local name = core_logs[i]
    local desc = set_desc(name)

    minetest.register_node(":mcl_core:"..name.."_log_hollow", {
        collision_box = collisionbox,
        description = S("Hollow @1", S(desc.." Log")),
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
        _mcl_stripped_variant = "mcl_core:stripped_"..name.."_log_hollow"
    })

    minetest.register_node(":mcl_core:stripped_"..name.."_log_hollow", {
        collision_box = collisionbox,
        description = S("Hollow @1", S(desc.." Log")),
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

if minetest.get_modpath("mcl_cherry_blossom") then
    minetest.register_node(":mcl_cherry_blossom:cherry_log_hollow", {
        collision_box = collisionbox,
        description = S("Hollow @1", S("Cherry Log")),
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
        tiles = {"mcl_hollow_logs_cherry.png"},
        _mcl_blast_resistance = 2,
        _mcl_hardness = 2,
       _mcl_stripped_variant = "mcl_cherry_blossom:stripped_cherry_log_hollow"
    })

    minetest.register_node(":mcl_cherry_blossom:stripped_cherry_log_hollow", {
        collision_box = collisionbox,
        description = S("Stripped @1", S("Hollow @1", S("Cherry Log"))),
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
        tiles = {"mcl_hollow_logs_stripped_cherry.png"},
        _mcl_blast_resistance = 2,
        _mcl_hardness = 2
    })
end

if minetest.get_modpath("mcl_crimson") then
    minetest.register_node(":mcl_crimson:crimson_stem_hollow", {
        collision_box = collisionbox,
        description = S("Hollow @1", S("Crimson Stem")),
        drawtype = "mesh",
        groups = {axey = 1, building_block = 1, handy = 1},
        mesh = "mcl_hollow_logs_log.obj",
        on_place = mcl_util.rotate_axis,
        paramtype = "light",
        paramtype2 = "facedir",
        sounds = mcl_sounds.node_sound_wood_defaults(),
        sunlight_propagates = true,
        tiles = {"mcl_hollow_logs_crimson.png"},
        _mcl_blast_resistance = 2,
        _mcl_hardness = 2,
       _mcl_stripped_variant = "mcl_crimson:stripped_crimson_stem_hollow"
    })

    minetest.register_node(":mcl_crimson:stripped_crimson_stem_hollow", {
        collision_box = collisionbox,
        description = S("Stripped @1", S("Hollow @1", S("Crimson Stem"))),
        drawtype = "mesh",
        groups = {axey = 1, building_block = 1, handy = 1},
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

    minetest.register_node(":mcl_crimson:warped_stem_hollow", {
        collision_box = collisionbox,
        description = S("Hollow @1", S("Warped Stem")),
        drawtype = "mesh",
        groups = {axey = 1, building_block = 1, handy = 1},
        mesh = "mcl_hollow_logs_log.obj",
        on_place = mcl_util.rotate_axis,
        paramtype = "light",
        paramtype2 = "facedir",
        sounds = mcl_sounds.node_sound_wood_defaults(),
        sunlight_propagates = true,
        tiles = {"mcl_hollow_logs_warped.png"},
        _mcl_blast_resistance = 2,
        _mcl_hardness = 2,
       _mcl_stripped_variant = "mcl_crimson:stripped_warped_stem_hollow"
    })

    minetest.register_node(":mcl_crimson:stripped_warped_stem_hollow", {
        collision_box = collisionbox,
        description = S("Stripped @1", S("Hollow @1", S("Warped Stem"))),
        drawtype = "mesh",
        groups = {axey = 1, building_block = 1, handy = 1},
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

if minetest.get_modpath("mcl_mangrove") then
    minetest.register_node(":mcl_mangrove:mangrove_log_hollow", {
        collision_box = collisionbox,
        description = S("Hollow @1", S("Mangrove Log")),
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
        tiles = {"mcl_hollow_logs_mangrove.png"},
        _mcl_blast_resistance = 2,
        _mcl_hardness = 2,
       _mcl_stripped_variant = "mcl_mangrove:stripped_mangrove_log_hollow"
    })

    minetest.register_node(":mcl_mangrove:stripped_mangrove_log_hollow", {
        collision_box = collisionbox,
        description = S("Stipped @1", S("Hollow @1", S("Mangrove Log"))),
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
        tiles = {"mcl_hollow_logs_stripped_mangrove.png"},
        _mcl_blast_resistance = 2,
        _mcl_hardness = 2
    })
end

dofile(modpath.."/recipes.lua")
