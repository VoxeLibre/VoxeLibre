minetest.register_craft({
    output = "mcl_core:acacia_log_hollow 4",
    recipe = {
        {"", "mcl_core:acaciatree", ""},
        {"mcl_core:acaciatree", "", "mcl_core:acaciatree"},
        {"", "mcl_core:acaciatree", ""}
    }
})

minetest.register_craft({
    output = "mcl_core:stripped_acacia_log_hollow 4",
    recipe = {
        {"", "mcl_core:stripped_acacia", ""},
        {"mcl_core:stripped_acacia", "", "mcl_core:stripped_acacia"},
        {"", "mcl_core:stripped_acacia", ""}
    }
})

minetest.register_craft({
    output = "mcl_core:birch_log_hollow 4",
    recipe = {
        {"", "mcl_core:birchtree", ""},
        {"mcl_core:birchtree", "", "mcl_core:birchtree"},
        {"", "mcl_core:birchtree", ""}
    }
})

minetest.register_craft({
    output = "mcl_core:stripped_birch_log_hollow 4",
    recipe = {
        {"", "mcl_core:stripped_birch", ""},
        {"mcl_core:stripped_birch", "", "mcl_core:stripped_birch"},
        {"", "mcl_core:stripped_birch", ""}
    }
})

minetest.register_craft({
    output = "mcl_core:dark_oak_log_hollow 4",
    recipe = {
        {"", "mcl_core:darktree", ""},
        {"mcl_core:darktree", "", "mcl_core:darktree"},
        {"", "mcl_core:darktree", ""}
    }
})

minetest.register_craft({
    output = "mcl_core:stripped_dark_oak_log_hollow 4",
    recipe = {
        {"", "mcl_core:stripped_dark_oak", ""},
        {"mcl_core:stripped_dark_oak", "", "mcl_core:stripped_dark_oak"},
        {"", "mcl_core:stripped_dark_oak", ""}
    }
})

minetest.register_craft({
    output = "mcl_core:jungle_log_hollow 4",
    recipe = {
        {"", "mcl_core:jungletree", ""},
        {"mcl_core:jungletree", "", "mcl_core:jungletree"},
        {"", "mcl_core:jungletree", ""}
    }
})

minetest.register_craft({
    output = "mcl_core:stripped_jungle_log_hollow 4",
    recipe = {
        {"", "mcl_core:stripped_jungle", ""},
        {"mcl_core:stripped_jungle", "", "mcl_core:stripped_jungle"},
        {"", "mcl_core:stripped_jungle", ""}
    }
})

minetest.register_craft({
    output = "mcl_core:spruce_log_hollow 4",
    recipe = {
        {"", "mcl_core:sprucetree", ""},
        {"mcl_core:sprucetree", "", "mcl_core:sprucetree"},
        {"", "mcl_core:sprucetree", ""}
    }
})

minetest.register_craft({
    output = "mcl_core:stripped_spruce_log_hollow 4",
    recipe = {
        {"", "mcl_core:stripped_spruce", ""},
        {"mcl_core:stripped_spruce", "", "mcl_core:stripped_spruce"},
        {"", "mcl_core:stripped_spruce", ""}
    }
})

minetest.register_craft({
    output = "mcl_core:oak_log_hollow 4",
    recipe = {
        {"", "mcl_core:tree", ""},
        {"mcl_core:tree", "", "mcl_core:tree"},
        {"", "mcl_core:tree", ""}
    }
})

minetest.register_craft({
    output = "mcl_core:stripped_oak_log_hollow 4",
    recipe = {
        {"", "mcl_core:stripped_oak", ""},
        {"mcl_core:stripped_oak", "", "mcl_core:stripped_oak"},
        {"", "mcl_core:stripped_oak", ""}
    }
})

if minetest.get_modpath("mcl_cherry_blossom") then
    minetest.register_craft({
        output = "mcl_cherry_blossom:cherry_log_hollow 4",
        recipe = {
            {"", "mcl_cherry_blossom:cherrytree", ""},
            {"mcl_cherry_blossom:cherrytree", "", "mcl_cherry_blossom:cherrytree"},
            {"", "mcl_cherry_blossom:cherrytree", ""}
        }
    })

    minetest.register_craft({
        output = "mcl_cherry_blossom:stripped_cherry_log_hollow 4",
        recipe = {
            {"", "mcl_cherry_blossom:stripped_cherrytree", ""},
            {"mcl_cherry_blossom:stripped_cherrytree", "", "mcl_cherry_blossom:stripped_cherrytree"},
            {"", "mcl_cherry_blossom:stripped_cherrytree", ""}
        }
    })
end

if minetest.get_modpath("mcl_crimson") then
    minetest.register_craft({
        output = "mcl_crimson:crimson_stem_hollow 4",
        recipe = {
            {"", "mcl_crimson:crimson_hyphae", ""},
            {"mcl_crimson:crimson_hyphae",  "", "mcl_crimson:crimson_hyphae"},
            {"", "mcl_crimson:crimson_hyphae", ""}
        }
    })

    minetest.register_craft({
        output = "mcl_crimson:stripped_crimson_stem_hollow 4",
        recipe = {
            {"", "mcl_crimson:stripped_crimson_hyphae", ""},
            {"mcl_crimson:stripped_crimson_hyphae",  "", "mcl_crimson:stripped_crimson_hyphae"},
            {"", "mcl_crimson:stripped_crimson_hyphae", ""}
        }
    })

    minetest.register_craft({
        output = "mcl_crimson:warped_stem_hollow 4",
        recipe = {
            {"", "mcl_crimson:warped_hyphae", ""},
            {"mcl_crimson:warped_hyphae",  "", "mcl_crimson:warped_hyphae"},
            {"", "mcl_crimson:warped_hyphae", ""}
        }
    })

    minetest.register_craft({
        output = "mcl_crimson:stripped_warped_stem_hollow 4",
        recipe = {
            {"", "mcl_crimson:stripped_warped_hyphae", ""},
            {"mcl_crimson:stripped_warped_hyphae",  "", "mcl_crimson:stripped_warped_hyphae"},
            {"", "mcl_crimson:stripped_warped_hyphae", ""}
        }
    })
end

if minetest.get_modpath("mcl_mangrove") then
    minetest.register_craft({
        output = "mcl_mangrove:mangrove_log_hollow 4",
        recipe = {
            {"", "mcl_mangrove:mangrove_tree", ""},
            {"mcl_mangrove:mangrove_tree", "", "mcl_mangrove:mangrove_tree"},
            {"", "mcl_mangrove:mangrove_tree", ""}
        }
    })

    minetest.register_craft({
        output = "mcl_mangrove:stripped_mangrove_log_hollow 4",
        recipe = {
            {"", "mcl_mangrove:mangrove_stripped", ""},
            {"mcl_mangrove:mangrove_stripped", "", "mcl_mangrove:mangrove_stripped"},
            {"", "mcl_mangrove:mangrove_stripped", ""}
        }
    })
end

minetest.register_craft({
    burntime = 10,
    recipe = "group:hollow_log",
    type = "fuel",
})

minetest.register_craft({
    cooktime = 5,
    output = "mcl_core:charcoal_lump",
    recipe = "group:hollow_log",
    type = "cooking"
})
