--TODO: put this mod entirely into mcl_armor

mcl_armor_trims = {
    blacklisted     = {["mcl_farming:pumpkin_face"]=true, ["mcl_armor:elytra"]=true, ["mcl_armor:elytra_enchanted"]=true},
    overlays        = {"sentry","dune","coast","wild","tide","ward","vex","rib","snout","eye","spire"},
    colors          = {["amethyst"]="#8246a5",["gold"]="#ce9627",["emerald"]="#1b9958",["copper"]="#c36447",["diamond"]="#5faed8",["iron"]="#938e88",["lapis"]="#1c306b",["netherite"]="#302a26",["quartz"]="#c9bcb9",["redstone"]="#af2c23"},
    old_textures    = {}
}

local function override_items()
    for itemname, itemdef in pairs(minetest.registered_tools) do
        if itemdef._mcl_armor_texture and type(itemdef._mcl_armor_texture) == "string" and not mcl_armor_trims.blacklisted[itemname] then
            mcl_armor_trims.old_textures[itemname] = itemdef._mcl_armor_texture
            minetest.override_item(itemname, {
                _mcl_armor_texture = function(obj, itemstack)
                    local overlay = itemstack:get_meta():get_string("mcl_armor_trims:trim_overlay")
                    local old_armor_texture = mcl_armor_trims.old_textures[itemstack:get_name()]
                    if type(old_armor_texture) == "function" then
                        old_armor_texture = old_armor_texture(obj, itemstack)
                    end

                    if overlay == "" then -- key not present; armor not trimmed
                        return old_armor_texture
                    end

                    return old_armor_texture .. overlay
                end
            })
        end
    end
end

function mcl_armor_trims.trim(itemstack, overlay, color_string)
    local def = itemstack:get_definition()
    if not def._mcl_armor_texture and not mcl_armor_trims.blacklisted[itemstack:get_name()] then
        return
    end
    local meta = itemstack:get_meta()

    local piece_overlay = overlay
    local inv_overlay = ""
    local piece_type = def._mcl_armor_element

    if piece_type == "head" then --helmet
        inv_overlay = "^(helmet_trim.png"
        piece_overlay = piece_overlay .. "_helmet"
    elseif piece_type == "torso" then --chestplate
        inv_overlay = "^(chestplate_trim.png"
        piece_overlay = piece_overlay .. "_chestplate"
    elseif piece_type == "legs" then --leggings
        inv_overlay = "^(leggings_trim.png"
        piece_overlay = piece_overlay .. "_leggings"
    elseif piece_type == "feet" then --boots
        inv_overlay = "^(boots_trim.png"
        piece_overlay = piece_overlay .. "_boots"
    end
    local color = mcl_armor_trims.colors[color_string]
    inv_overlay = inv_overlay .. "^[colorize:" .. color .. ":150)"
    piece_overlay = piece_overlay .. ".png"

    piece_overlay = "^(" .. piece_overlay .. "^[colorize:" .. color .. ":150)"

    meta:set_string("mcl_armor_trims:trim_overlay" , piece_overlay) -- set textures to render on the player, will work for clients below 5.8 as well
    meta:set_string("mcl_armor_trims:inv", inv_overlay) -- make 5.8+ clients display the fancy inv image, older ones will see no change in the *inventory* image
    meta:set_string("inventory_image", def.inventory_image .. inv_overlay) -- dont use reload_inv_image as it's a one liner in this enviorment
end

function mcl_armor_trims.reload_inv_image(itemstack)
    local meta = itemstack:get_meta()
    local inv_overlay = meta:get_string("mcl_armor_trims:inv")
    local def = itemstack:get_definition()
    if inv_overlay == "" then return end
    meta:set_string("inventory_image", def.inventory_image .. inv_overlay)
end

minetest.register_on_mods_loaded(override_items)
dofile(minetest.get_modpath(minetest.get_current_modname()).."/templates.lua")