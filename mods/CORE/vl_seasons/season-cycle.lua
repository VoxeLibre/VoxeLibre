seasons = {}
local S = minetest.get_translator("seasons")
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

-- === Part 1a: Defining day count ===
-- Day count is a settable parameter that by default is tied to the real time based minetest.get_day_count() in which worlds begin at day 0 and count up by 1 as time goes on. After day count is defined and tracked, we can then define a seasonal cycle around it.

seasons.effective_overridden = false  -- Track manual overrides in case day count is set by user commands.

-- Dynamic initialization of effective_day_count and minetest.get_day_count() to prevent nil that happens for some reason when calling the later without doing this.
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

-- Modular retrieval functions to help external mods retrieve or set otherwise difficult to obtain local values.

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

-- === Part 2a: Defining Cyclic Seasons ===

-- Configuration table for defining seasons. Allows arbitrary number of seasons and variable days in season length.
local seasons_config = {
    {name="spring", days=4},
    {name="summer", days=15},
    {name="fall", days=6},
    {name="winter", days=10}
}

-- Precompute seasonal data once during mod initialization
local sum_total = 0
local cumulative_days = {}
local season_names = {}
local season_starting_days = {}

for _, season in ipairs(seasons_config) do
    table.insert(season_starting_days, sum_total)        -- Start of current season
    sum_total = sum_total + season.days                 -- Update total
    table.insert(cumulative_days, sum_total)             -- End of current season (used for comparison)
    table.insert(season_names, season.name)              -- Store season name
end

seasons.sum_total = sum_total
seasons.cumulative_days = cumulative_days
seasons.season_names = season_names
seasons.season_starting_days = season_starting_days

-- Modular retrieval functions for get_season() parameters
function seasons.get_cumulative_days()
    return seasons.cumulative_days
end

function seasons.get_sum_total()
    return seasons.sum_total
end

function seasons.get_starting_days()
    return seasons.season_starting_days
end

function seasons.get_season_names()
    return seasons.season_names
end

function seasons.get_season_cycle_day()
    local effective_day_count = seasons.get_effective_day_count()
    local sum_total = seasons.get_sum_total()
    return effective_day_count % sum_total
end

-- get_season defines the current season by taking the effective day count and doing modulus operations to map it to a cyclic year defined by the seasons_config table.
function seasons.get_season()
    local cycle_day = seasons.get_season_cycle_day()
    local cumulative_days = seasons.get_cumulative_days()
    local season_names = seasons.get_season_names()

    for i = 1, #cumulative_days do
        if cycle_day < cumulative_days[i] then
            return season_names[i]
        end
    end

    error("Invalid configuration or day count")
end
