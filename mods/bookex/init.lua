
-- Boilerplate to support localized strings if intllib mod is installed.
local S;
if (minetest.get_modpath("intllib")) then
    dofile(minetest.get_modpath("intllib").."/intllib.lua");
    S = intllib.Getter(minetest.get_current_modname());
else
    S = function ( s ) return s end;
end

local function deepcopy ( t )
    local nt = { };
    for k, v in pairs(t) do
        if (type(v) == "table") then
            nt[k] = deepcopy(v);
        else
            nt[k] = v;
        end
    end
    return nt;
end

local newbook = deepcopy(minetest.registered_items["default:book"]);

newbook.on_use = function ( itemstack, user, pointed_thing )

    local text = itemstack:get_metadata();

    local formspec = "size[8,9]"..
		"background[-0.5,-0.5;9,10;book_bg.png]"..
        "textarea[0.5,0.25;7.5,9.25;text;;"..minetest.formspec_escape(text).."]"..
        "button_exit[3,8.25;2,1;ok;Exit]";

    minetest.show_formspec(user:get_player_name(), "default:book", formspec);

end

minetest.register_craftitem(":default:book", newbook);

minetest.register_on_player_receive_fields(function ( player, formname, fields )
    if ((formname == "default:book") and fields and fields.text) then
        local stack = player:get_wielded_item();
        if (stack:get_name() and (stack:get_name() == "default:book")) then
            local t = stack:to_table();
            t.metadata = fields.text;
            player:set_wielded_item(ItemStack(t));
        end
    end
end);
