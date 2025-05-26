local S = core.get_translator(core.get_current_modname())
local tellplayer = core.chat_send_player
local get_season = seasons.get_season

core.register_chatcommand("season", {
    description = S("Display or set the current season's effective day count."),
    func = function(name, param)
        -- Check if no parameter is provided (display current info)
        if param == "" then
            local get_effective_day = seasons.get_effective_day_count
            tellplayer(name, string.format("The current season is %s, today is %d", get_season(), get_effective_day()))
            return
        end

        -- Process non-empty parameters
        local lower_param = param:lower()

        -- First check if the player has server privileges for actions requiring it
        local has_privileges = core.check_player_privs(name, {server=true})
        if not has_privileges then
            tellplayer(name, S("You lack the privilege to perform this action."))
            return  
        end

        -- Handle "/season reset"
        if lower_param == "reset" then
            seasons.effective_overridden = false
            tellplayer(name, S("Effective day count reset; now following real days."))
            return  
        end

		-- Handle "/season <season>"
        -- Get season names and starting days
        local season_names = seasons.get_season_names()
        local season_starting_days = seasons.get_starting_days()

        -- Check if param is a valid season name
        local index = nil
        for i, name in ipairs(season_names) do
            if name == lower_param then
                index = i
                break
            end
        end

        if index then
            local start_day = season_starting_days[index]
            seasons.set_effective_day_count(start_day)
            tellplayer(name, string.format(S("Set effective day count to %d (the current season is %s)."),start_day,get_season()))
            return
        else

			-- Handle /season <int>
            -- Check if param is a valid integer (including negative)
            local value = tonumber(param)
            if value ~= nil then
                -- Ensure it's an exact integer
                local int_value = math.floor(value)
                if int_value == value then
                    seasons.set_effective_day_count(int_value)
                    tellplayer(name, "Set effective day count to " .. int_value)
                    return
                end
            end
            -- If neither season nor valid integer, show error
            tellplayer(name, S("Invalid parameter provided."))
        end
    end
})