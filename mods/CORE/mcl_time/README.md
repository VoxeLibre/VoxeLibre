# mcl_time
## by kay27 for MineClone 5
---------------------------
This mod counts time when all players sleep or some area is inactive.

It depends very much on `time_speed` configuration variable, which could be changed 'on the fly' by a chat command.

If `time_speed` set to 0, this mod logs warnings and returns zeroes.

### mcl_time.get_seconds_irl()
------------------------------
Returns: Integer value of realtime (not in-game) seconds since world creation.

Usually this value grow smoothly. But when you skip the night being in the bed, or leave some area for some time, you may experience value jumps. That's basically the idea of this mod.

### mcl_time.get_number_of_times(last_time, interval, chance)
-------------------------------------------------------------
Handy to process AMBs.

You pass `last_time` - last known value of `seconds_irl`, also ABM `interval` and ABM `chance`.

Returns:
 * Integer number of how many times ABM function should be called if the area was active all the time and you didn't skip the night.
 * Integer value of realtime (not in-game) seconds since world creation.

### mcl_time.touch(pos)
-----------------------
This function 'toches' node at position `pos` by writing `_t` meta variable of `seconds_irl`.

### mcl_time.get_number_of_times_at_pos(pos, interval, chance)
--------------------------------------------------------------
Much more handy to call from LBM on area load, than `mcl_time.get_number_of_times()`!

It reads meta variable `_t` from position `pos` and uses it as previous `seconds_irl`, which then pass as first argument into `mcl_time.get_number_of_times()`.
After calling this, it also 'touches' the node at `pos` by writing `seconds_irl` into meta variable `_t`.

Returns:
 * Integer number of how many times ABM function should be called if the area was active all the time and you didn't skip the night.
 * Integer value of realtime (not in-game) seconds since world creation.

*Warning!* This function can return 0. So it's better not to use it for regular ABMs - use `mcl_time.get_number_of_times_at_pos_or_1()` instead.

### mcl_time.get_number_of_times_at_pos_or_1(pos, interval, chance)
-------------------------------------------------------------------
Much more handy to process ABMs than `mcl_time.get_number_of_times()` and `mcl_time.get_number_of_times_at_pos()`!

It just calls `mcl_time.get_number_of_times_at_pos()` but doesn't return 0, the minimum number it can return is 1,
which is the most suitable for regular ABM processing function.

Returns:
 * Integer number of how many times ABM function should be called if the area was active all the time and you didn't skip the night.
 * Integer value of realtime (not in-game) seconds since world creation.
