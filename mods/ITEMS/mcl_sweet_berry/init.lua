minetest.register_craftitem("mcl_sweet_berry:sweet_berry", {
    description = "Sweet Berry",
    inventory_image = "sweet_berry.png",
    on_use = minetest.item_eat(2)
})
minetest.register_node("mcl_sweet_berry:sweet_berry_bush_0", {
    drawtype = "plantlike",
    tiles = {"sweet_berry_bush_0.png"},
    damage_per_second = 1,
    selection_box = {
        type = "fixed",
        fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, 0.5, 6 / 16},
    },
    drop = ""
})
minetest.register_node("mcl_sweet_berry:sweet_berry_bush_1", {
    drawtype = "plantlike",
    tiles = {"sweet_berry_bush_1.png"},
    damage_per_second = 1,
    selection_box = {
        type = "fixed",
        fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, 0.5, 6 / 16},
    },
    drop = ""
})
minetest.register_node("mcl_sweet_berry:sweet_berry_bush_2", {
    drawtype = "plantlike",
    tiles = {"sweet_berry_bush_2.png"},
    damage_per_second = 2,
    selection_box = {
        type = "fixed",
        fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, 0.5, 6 / 16},
    },
    drop = "mcl_sweet_berry:sweet_berry 2"
})
minetest.register_node("mcl_sweet_berry:sweet_berry_bush_3", {
    drawtype = "plantlike",
    tiles = {"sweet_berry_bush_3.png"},
    damage_per_second = 2,
    selection_box = {
        type = "fixed",
        fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, 0.5, 6 / 16},
    },
    drop = "mcl_sweet_berry:sweet_berry 3"
})
minetest.register_decoration({
    deco_type = "simple",
    place_on = {"mcl_core:dirt_with_grass"},
    sidelen = 16,
    fill_ratio = 0.1,
    biomes = {"Taiga","Forest"},
    y_max = mcl_vars.mg_overworld_max,
    y_min = mcl_vars.mg_overworld_min,
    decoration = "mcl_sweet_berry:sweet_berry_bush_2"
})
minetest.register_abm({
    nodenames = {"mcl_sweet_berry:sweet_berry_bush_0"},
    interval = 10.0,
    chance = 16,
    action = function(pos, node, active_object_count, active_object_count_wider)
        minetest.set_node(pos, {name = "mcl_sweet_berry:sweet_berry_bush_1"})
    end
})
minetest.register_abm({
    nodenames = {"mcl_sweet_berry:sweet_berry_bush_1"},
    interval = 10.0,
    chance = 16,
    action = function(pos, node, active_object_count, active_object_count_wider)
        minetest.set_node(pos, {name = "mcl_sweet_berry:sweet_berry_bush_2"})
    end
})
minetest.register_abm({
    nodenames = {"mcl_sweet_berry:sweet_berry_bush_2"},
    interval = 10.0,
    chance = 16,
    action = function(pos, node, active_object_count, active_object_count_wider)
        minetest.set_node(pos, {name = "mcl_sweet_berry:sweet_berry_bush_3"})
    end
})

--taken from mc modpack by TechDude/TechDudie








