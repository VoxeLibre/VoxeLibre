seasons = {}
local S = minetest.get_translator("seasons")
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

seasons.effective_overridden = false  -- Track manual overrides

-- dynamic initialization of effective_day_count and minetest.get_day_count()to prevent nil that happens for some reason when calling the later without doing this.
local function update_effective_day_count()
    if not seasons.effective_overridden then
        local real_day_count = minetest.get_day_count()
        seasons.effective_day_count = real_day_count or -1  -- Default to real day count if not overridden, else default to -1 (winter) to prevent crash in case of nil.
    end
    if seasons.effective_day_count == -1 then
        minetest.log("warning", "[Seasons] Failed to initialize effective day count; using fallback.")
    end
end

-- Initial setup and periodic updates so real time based effective season updates. I put this in to fix regular real time season days not updating and staying as static integers. 
minetest.after(0.5, function()
    update_effective_day_count()  
    -- Start periodic updates every X seconds
    local UPDATE_INTERVAL = 1
    local function periodic_update()
        update_effective_day_count()
        minetest.after(UPDATE_INTERVAL, periodic_update)
    end
    minetest.after(0.5, periodic_update)  -- Delayed start after initialization
end)

-- set_effective_day_count allows for overriding the effective_day_count to user specified integer with chat command. This will permanently freeze the effective_day_count until reset with /seasons reset
function seasons.set_effective_day_count(value)
    if value then
        seasons.effective_overridden = true  -- Mark as overridden
        seasons.effective_day_count = tonumber(value)
        if not seasons.effective_day_count then return false end
    else
        return false
    end
    return true
end

-- get_effective_day_count allows users to call the integer value of effective_day_count. All external functions should use this for checks.
function seasons.get_effective_day_count()
    return seasons.effective_day_count  -- Retrieve from the seasons table
end

-- get_season defines the current season by taking the effective day and doing modulus operation + math flooring to map it to a cyclic year. There are currently 15 days in a year, four seasons. Should it be changable parameters? For now keep it simple and hardcoded. All extenal functions should use this to call the season as a string for checks.
-- TODO: 15 day seasons was an abritrary choice for toymodel dev purposes and ease of modulus operation calculation. Seasons based off moon cycle with three months per season makes sense. Instead of gregorian calandar months, we can use relative "early season", "mid season", "late season" to define the three months. It would be cool to have the seasons vary in length somehow if its not a massive increase in code complexity.
function seasons.get_season()
    local day_count = seasons.get_effective_day_count()
    local season_index = math.floor(day_count / 15) % 4
    if season_index == 0 then
        return "spring"
    elseif season_index == 1 then
        return "summer"
    elseif season_index == 2 then
        return "fall"
    elseif season_index == 3 then
        return "winter"
    end
end


