
minetest.register_chatcommand("night", {
    params = "",
    description = "Make the night",
    privs = {settime = true},
    func = function(name, param)
		local player = minetest.env:get_player_by_name(name)
		if not player then
			return
		end
       minetest.env:set_timeofday(0.22)
    end
})

minetest.register_chatcommand("day", {
    params = "",
    description = "Make the day wakeup",
    privs = {settime = true},
    func = function(name, param)
		local player = minetest.env:get_player_by_name(name)
		if not player then
			return
		end
		minetest.env:set_timeofday(0.6)
    end
})


