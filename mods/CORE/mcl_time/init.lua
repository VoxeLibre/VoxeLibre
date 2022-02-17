mcl_time = {}

local time_update_interval = 2
local retry_on_fail_interval = 500
local default_time_speed = 72
local save_to_storage_interval = 600
local meta_name = "_t"

local current_time_update_interval = time_update_interval

local storage = minetest.get_mod_storage()
local seconds_irl_public = tonumber(storage:get_string("seconds_irl")) or -2
local last_save_seconds_irl = seconds_irl_public
local next_save_seconds_irl = last_save_seconds_irl + save_to_storage_interval

local previous_seconds_irl = -2
local function get_seconds_irl()
	local time_speed = tonumber(minetest.settings:get("time_speed") or default_time_speed)
	if time_speed < 1 then
		minetest.log("warning", "[mcl_time] time_speed < 1 - please increase to make mcl_time api work (default: " .. default_time_speed .. ")")
		return 0
	end
	local irl_multiplier = 86400 / time_speed
	local day_count = minetest.get_day_count()
	local timeofday = minetest.get_timeofday()
	local seconds_irl
	if not day_count or not timeofday then
		seconds_irl = seconds_irl_public
	else
		local days_ig = 0.0 + day_count + timeofday
		seconds_irl = days_ig * irl_multiplier
	end

	if previous_seconds_irl == seconds_irl then
		current_time_update_interval = math.min(current_time_update_interval * 2, retry_on_fail_interval)
		minetest.log("warning", "[mcl_time] Time doesn't change! seconds_irl=" .. tostring(seconds_irl)
			.. ", day_count = " .. tostring(day_count) .. ", timeofday=" .. tostring(timeofday)
			.. " - increasing update interval to " .. tostring(current_time_update_interval))
	else
		previous_seconds_irl = seconds_irl
		if current_time_update_interval ~= time_update_interval then
			current_time_update_interval = time_update_interval
			minetest.log("action", "[mcl_time] Time is changing again: seconds_irl=" .. tostring(seconds_irl)
				.. ", day_count = " .. tostring(day_count) .. ", timeofday=" .. tostring(timeofday)
				.. ", update_interval=" .. tostring(current_time_update_interval))
		end
	end

	if last_save_seconds_irl >= next_save_seconds_irl then
		storage:set_string("seconds_irl", tostring(seconds_irl))
		next_save_seconds_irl = seconds_irl + save_to_storage_interval
	end

	return seconds_irl
end

local seconds_irl_public = get_seconds_irl()

function mcl_time.get_seconds_irl()
	return seconds_irl_public
end

local function time_runner()
	seconds_irl_public = get_seconds_irl()
	minetest.after(current_time_update_interval, time_runner)
end

function mcl_time.get_number_of_times(last_time, interval, chance)
	if not last_time then return 0 end
	if seconds_irl_public < 2 then return 0 end
	if not interval then return 0 end
	if not chance then return 0 end
	if interval < 1 then return 0 end
	if chance < 1 then return 0 end
	local number_of_intervals = (seconds_irl_public - last_time) / interval
	if number_of_intervals < 1 then return 0 end
	local average_chance = (1 + chance) / 2
	local number_of_times = math.floor(number_of_intervals / average_chance)
	return number_of_times, seconds_irl_public
end

local get_number_of_times = mcl_time.get_number_of_times

function mcl_time.touch(pos)
	local meta = minetest.get_meta(pos)
	meta:set_int(meta_name, seconds_irl_public)
end

local touch = mcl_time.touch

function mcl_time.get_number_of_times_at_pos(pos, interval, chance)
	if not pos then return 0 end
	local meta = minetest.get_meta(pos)
	local last_time = meta:get_int(meta_name)
	local number_of_times = (last_time == 0) and 0 or get_number_of_times(last_time, interval, chance)
	touch(pos)
	return number_of_times, seconds_irl_public
end

local get_number_of_times_at_pos = mcl_time.get_number_of_times_at_pos

function mcl_time.get_number_of_times_at_pos_or_1(pos, interval, chance)
	return math.max(get_number_of_times_at_pos(pos, interval, chance), 1), seconds_irl_public
end

function mcl_time.get_irl_seconds_passed_at_pos(pos)
	if not pos then return 0 end
	local meta = minetest.get_meta(pos)
	local last_time = meta:get_int(meta_name)
	local irl_seconds_passed = (last_time == 0) and 0 or (seconds_irl_public - last_time)
	return irl_seconds_passed
end

function mcl_time.get_irl_seconds_passed_at_pos_or_1(pos)
	if not pos then return 1 end
	local meta = minetest.get_meta(pos)
	local last_time = meta:get_int(meta_name)
	local irl_seconds_passed = (last_time == 0) and 1 or (seconds_irl_public - last_time)
	return irl_seconds_passed
end

function mcl_time.get_irl_seconds_passed_at_pos_or_nil(pos)
	if not pos then return end
	local meta = minetest.get_meta(pos)
	local last_time = meta:get_int(meta_name)
	if last_time == 0 then return end
	local delta_time = seconds_irl_public - last_time
	if delta_time <= 0 then return end
	return delta_time
end

time_runner()
local day_count = minetest.get_day_count()
local timeofday = minetest.get_timeofday()
minetest.log("action", "[mcl_time] time runner started, current in-real-life seconds: " .. seconds_irl_public
	.. ", time_speed: " .. tostring(minetest.settings:get("time_speed"))
	.. ", day_count: " .. tostring(day_count)
	.. ", timeofday: " .. tostring(timeofday)
	.. ", update_interval=" .. tostring(current_time_update_interval)
)
