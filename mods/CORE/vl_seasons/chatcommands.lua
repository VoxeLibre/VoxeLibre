local S = minetest.get_translator("vl_seasons")
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
-- season by itself displays the current season and the effective day of the year which should be set to the real day of the year unless otherwise overridden by manually setting it as an integer. To manually set as an integer do /season X where X is the day #. To reset back to real days for effective day, do /season reset. This will also be reset back to real days on server shutdown.

core.register_chatcommand("season", {
    description = S("Display or set the current season's effective day count."),
    func = function(name, param)

-- if the parameter is not equal to blank (a.k.a if theres some extra parameters included with /season then...)
        if param ~= "" then

-- user defines reset parameter to reset override back to real effective days. e.g /season reset 
           local lower_param = param:lower()
            if lower_param == "reset" then
                if minetest.check_player_privs(name, {server=true}) then -- Require server privilege to modify
                    seasons.effective_overridden = false
                    minetest.chat_send_player(name, S("Effective day count reset; now following real days."))
                else
                    minetest.chat_send_player(name, S("You lack the privilege to reset the effective day count."))
                end
            else

-- user defines integer value to manually set effective day count e.g /seasons 18
                local value = tonumber(param)
                if value then
                    if minetest.check_player_privs(name, {server=true}) then  -- Require server privilege to modify
                        if not seasons.set_effective_day_count(value) then
                            minetest.chat_send_player(name, S("Invalid number provided."))
                        else
                            minetest.chat_send_player(name, "Set effective day count to " .. value)
                        end
                    else
                        minetest.chat_send_player(name, S("You lack the privilege to set the effective day count."))
                    end
                else
                    minetest.chat_send_player(name, S("Invalid number provided."))
                end
            end
        else

-- otherwise if no extra params, just display the effective season and effective day as an informative string
            local get_season = seasons.get_season
            local get_effective_day = seasons.get_effective_day_count
            minetest.chat_send_player(name, string.format("%s is currently in %s! Day %d", name, get_season(), get_effective_day()))
        end
    end
})

