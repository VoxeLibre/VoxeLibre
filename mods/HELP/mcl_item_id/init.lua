local game = "mineclone"

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
        "black", "blue",  "brown", "cyan", "green",
        "grey", "light_blue", "lime", "magenta", "orange",
        "pink", "purple", "red", "silver", "white", "yellow",
    },
}

tt.register_snippet(function(itemstring)
    local def = minetest.registered_items[itemstring]
    local desc = def.description
    local item_split = itemstring:find(":")
    local new_id = game .. itemstring:sub(item_split)
    for mod, ids in pairs(same_id) do
        for _, id in pairs(ids) do
            if itemstring == "mcl_" .. mod .. ":" .. id  then
                new_id = game .. ":" .. id .. "_" .. mod:gsub("s", "")
            end
        end
    end
    if new_id ~= game .. ":book_enchanted" then
        minetest.register_alias_force(new_id, itemstring)
    end
    if minetest.settings:get_bool("mcl_item_id_debug", false) then
        return new_id, "#555555"
    end
end)

minetest.register_alias_force(game .. ":book_enchanted", "mcl_enchanting:book_enchanted")
