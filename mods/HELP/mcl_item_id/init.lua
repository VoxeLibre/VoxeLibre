local game = "mineclone"
local mcl_mods = {}

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

local worldmt = io.open(minetest.get_worldpath() .. "/world.mt", "r")
local gameid = worldmt:read("*a"):match("gameid%s*=%s*(%S+)\n")
worldmt:close()

for _, mod in pairs(minetest.get_modnames()) do
    if minetest.get_modpath(mod):match("/games/" .. gameid .. "/") then
        table.insert(mcl_mods, mod)
    end
end

local function item_id(id)
    if minetest.settings:get_bool("mcl_item_id_debug", false) then
        return id, "#555555"
    end
end

tt.register_snippet(function(itemstring)
    local def = minetest.registered_items[itemstring]
    local desc = def.description
    local item_split = itemstring:find(":")
    local new_id = game .. itemstring:sub(item_split)
    local mcl_mod = itemstring:sub(1, item_split)
    for mod, ids in pairs(same_id) do
        for _, id in pairs(ids) do
            if itemstring == "mcl_" .. mod .. ":" .. id  then
                new_id = game .. ":" .. id .. "_" .. mod:gsub("s", "")
            end
        end
    end
    for _, modname in pairs(mcl_mods) do
        if modname .. ":" == mcl_mod then
            if new_id ~= game .. ":book_enchanted" and new_id ~= itemstring then
                minetest.register_alias_force(new_id, itemstring)
            end
            return item_id(new_id)
        end
    end
    return item_id(itemstring)
end)

minetest.register_alias_force(game .. ":book_enchanted", "mcl_enchanting:book_enchanted")
