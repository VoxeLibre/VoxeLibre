mcl_armor_trims = {
    overlays    = {"sentry","dune","coast","wild","tide","ward","vex","rib","snout","eye","spire"},
    colors      = {"bf352d"}
}


local function define_items()
    local register_list = {}
    for itemname, itemdef in pairs(minetest.registered_items) do
        if itemdef._mcl_armor_texture and type(itemdef._mcl_armor_texture) == "string" then
            for _, overlay in pairs(mcl_armor_trims.overlays) do
                local new_name = itemname .. "_trimmed_" .. overlay
                minetest.override_item(itemname, {_mcl_armor_trims_trim = new_name})
                local new_def = table.copy(itemdef)

                --TODO: inventory stuff

                new_def.groups.not_in_creative_inventory = 0 --set this to 1 later!
                new_def.groups.not_in_craft_guide = 1
                new_def._mcl_armor_texture = new_def._mcl_armor_texture .. "^" .. overlay .. ".png" .. "^[colorize:purple:50"

                new_def._mcl_armor_trims_trim = new_name

                register_list[":" .. new_name] = new_def
            end
        end
    end

    for new_name, new_def in pairs(register_list) do
        minetest.register_tool(new_name, new_def)
    end
end

minetest.register_on_mods_loaded(define_items)