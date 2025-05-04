local S = minetest.get_translator("vl_seasons")
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

core.register_chatcommand("season", {
    description = S("Display or set the current season's effective day count."),
    func = function(name, param)
        if param ~= "" then
            local lower_param = param:lower()

            -- Handle "/season reset" to revert to real-time days
            if lower_param == "reset" then
                if minetest.check_player_privs(name, {server=true}) then
                    seasons.effective_overridden = false
                    minetest.chat_send_player(name, S("Effective day count reset; now following real days."))
                else
                    minetest.chat_send_player(name, S("You lack the privilege to reset the effective day count."))
                end
            else
                -- Handle "/season <season>" to set the effective day to the season's starting day
                local season_names = seasons.get_season_names()
                local season_starting_days = seasons.get_starting_days()

                -- Find the index of the given season name in the list
                local index = nil
                for i, name in ipairs(season_names) do
                    if name == lower_param then
                        index = i
                        break
                    end
                end

                if index then
                    local start_day = season_starting_days[index]

                    if minetest.check_player_privs(name, {server=true}) then
                        if not seasons.set_effective_day_count(start_day) then
                            minetest.chat_send_player(name, S("Invalid number provided."))
                        else
                            local current_season = seasons.get_season()
                            minetest.chat_send_player(name, string.format(
                                S("Set effective day count to %d (the current season is %s)."),
                                start_day,
                                current_season
                            ))
                        end
                    else
                        minetest.chat_send_player(name, S("You lack the privilege to set the effective day count."))
                    end
                else
                    -- Check if extra param is a numeric value
                    local value = tonumber(param)
                    if value then
                        if minetest.check_player_privs(name, {server=true}) then
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
            end
        else
            -- Display current season and effective day count
            local get_season = seasons.get_season
            local get_effective_day = seasons.get_effective_day_count
            minetest.chat_send_player(name, string.format("Player %s is currently in %s! Day %d", name, get_season(), get_effective_day()))
        end
    end
})
