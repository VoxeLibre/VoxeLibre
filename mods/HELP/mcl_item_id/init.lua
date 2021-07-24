mcl_item_id = {
    mod_namespaces = {},
}

local game = "mineclone"

function mcl_item_id.set_mod_namespace(modname, namespace)
    local namespace = namespace or modname
    mcl_item_id.mod_namespaces[modname] = namespace
end

function mcl_item_id.get_mod_namespace(modname)
    local namespace = mcl_item_id.mod_namespaces[modname]
    if namespace then
        return namespace
    else
        return game
    end
end

local same_id = {
    enchanting = { "table" },
    experience = { "bottle" },
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
    local item_split = itemstring:find(":")
    local id_string = itemstring:sub(item_split)
    local id_modname = itemstring:sub(1, item_split - 1)
    local new_id = game .. id_string
    local mod_namespace = mcl_item_id.get_mod_namespace(id_modname)
    for mod, ids in pairs(same_id) do
        for _, id in pairs(ids) do
            if itemstring == "mcl_" .. mod .. ":" .. id  then
                new_id = game .. ":" .. id .. "_" .. mod:gsub("s", "")
            end
        end
    end
    if mod_namespace ~= game then
        new_id = mod_namespace .. id_string
    end
    if mod_namespace ~= id_modname then
        minetest.register_alias_force(new_id, itemstring)
    end
    if minetest.settings:get_bool("mcl_item_id_debug", false) then
        return new_id, "#555555"
    end
end)