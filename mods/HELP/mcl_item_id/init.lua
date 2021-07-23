mcl_item_id = {}

local game = "mineclone"

function mcl_item_id.set_mod_namespace(modname, namespace)
    local namespace = namespace or modname
    mcl_item_id[modname .. "_namespace"] = namespace
end

function mcl_item_id.get_mod_namespace(modname)
    local namespace = mcl_item_id[modname .. "_namespace"]
    if namespace then
        return namespace
    else
        return ""
    end
end

local same_id = {
    heads = { "skeleton", "zombie", "creeper", "wither_skeleton" },
    mobitems = { "rabbit", "chicken" },
    walls = {
        "andesite", "brick", "cobble", "diorite", "endbricks",
        "granite", "mossycobble", "netherbrick", "prismarine",
        "rednetherbrick", "redsandstone", "sandstone", 
        "stonebrick", "stonebrickmossy", 
    },
    wool = {
        "black", "blue", "brown", "cyan", "green",
        "grey", "light_blue", "lime", "magenta", "orange",
        "pink", "purple", "red", "silver", "white", "yellow",
    },
}

tt.register_snippet(function(itemstring)
    local def = minetest.registered_items[itemstring]
    local desc = def.description
    local item_split = itemstring:find(":")
    local id_part1 = itemstring:sub(1, item_split)
    local id_part2 = itemstring:sub(item_split)
    local modname = id_part1:gsub("%:", "")
    local new_id = game .. id_part2
    local mod_namespace = mcl_item_id.get_mod_namespace(modname)
    for mod, ids in pairs(same_id) do
        for _, id in pairs(ids) do
            if itemstring == "mcl_" .. mod .. ":" .. id  then
                new_id = game .. ":" .. id .. "_" .. mod:gsub("s", "")
            end
        end
    end
    
    if mod_namespace then
        new_id = mod_namespace .. id_part2
    end
    if new_id ~= game .. ":book_enchanted" then
        minetest.register_alias_force(new_id, itemstring)
    end
    if minetest.settings:get_bool("mcl_item_id_debug", false) then
        return new_id, "#555555"
    end
end)

minetest.register_alias_force(game .. ":book_enchanted", "mcl_enchanting:book_enchanted")
