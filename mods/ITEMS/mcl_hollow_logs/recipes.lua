for i = 1, #mcl_hollow_logs.logs do
    local mod, material, stripped_material
    local name = mcl_hollow_logs.logs[i][1]

    if name:find("cherry") then
        mod = "mcl_cherry_blossom:"
    elseif name:find("mangrove") then
        mod = "mcl_mangrove:"
    else
        mod = "mcl_core:"
    end

    material = mod..name
    stripped_material = mod.."stripped_"..name

    if name:find("mangrove") then
        stripped_material = "mcl_mangrove:mangrove_stripped"
    end

    minetest.register_craft({
        output = "mcl_hollow_logs:"..name.."_hollow 4",
        recipe = {
            {"", material, ""},
            {material, "", material},
            {"", material, ""}
        }
    })

    minetest.register_craft({
        output = "mcl_hollow_logs:stripped_"..name.."_hollow 4",
        recipe = {
            {"", stripped_material, ""},
            {stripped_material, "", stripped_material},
            {"", stripped_material, ""}
        }
    })
end

if minetest.get_modpath("mcl_crimson") then
    minetest.register_craft({
        output = "mcl_crimson:crimson_hyphae_hollow 4",
        recipe = {
            {"", "mcl_crimson:crimson_hyphae", ""},
            {"mcl_crimson:crimson_hyphae",  "", "mcl_crimson:crimson_hyphae"},
            {"", "mcl_crimson:crimson_hyphae", ""}
        }
    })

    minetest.register_craft({
        output = "mcl_crimson:stripped_crimson_hyphae_hollow 4",
        recipe = {
            {"", "mcl_crimson:stripped_crimson_hyphae", ""},
            {"mcl_crimson:stripped_crimson_hyphae",  "", "mcl_crimson:stripped_crimson_hyphae"},
            {"", "mcl_crimson:stripped_crimson_hyphae", ""}
        }
    })

    minetest.register_craft({
        output = "mcl_crimson:warped_hyphae_hollow 4",
        recipe = {
            {"", "mcl_crimson:warped_hyphae", ""},
            {"mcl_crimson:warped_hyphae",  "", "mcl_crimson:warped_hyphae"},
            {"", "mcl_crimson:warped_hyphae", ""}
        }
    })

    minetest.register_craft({
        output = "mcl_crimson:stripped_warped_hyphae_hollow 4",
        recipe = {
            {"", "mcl_crimson:stripped_warped_hyphae", ""},
            {"mcl_crimson:stripped_warped_hyphae",  "", "mcl_crimson:stripped_warped_hyphae"},
            {"", "mcl_crimson:stripped_warped_hyphae", ""}
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
