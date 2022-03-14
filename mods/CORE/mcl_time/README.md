# mcl_time v2.2
## by kay27 for MineClone 5
---------------------------
This mod counts time when all players sleep or some area is inactive.

It depends very much on `time_speed` configuration variable, which could be changed 'on the fly' by a chat command:
 * `/set time_speed 72`

If `time_speed` set to 0, this mod logs warnings and returns zeroes.

### mcl_time.get_seconds_irl()
------------------------------
Returns: Integer value of realtime (not in-game) seconds since world creation.

Usually this value grow smoothly. But when you skip the night being in the bed, or leave some area for some time, you may experience value jumps. That's basically the idea of this mod.

### mcl_time.get_number_of_times(last_time, interval, chance)
-------------------------------------------------------------
Returns the number of how many times something would probably happen if the area was active and we didn't skip the nights.

Arguments:
 * `last_time` - you pass last known for you value of `seconds_irl`
 * `interval` and `chance` - interval and chance like from ABM setup

Returns:
 * Integer number of how many times something would probably happen if the area was active all the time and we didn't skip the nights.
 * Integer value of in-real-life (not in-game) seconds since world creation.

### mcl_time.touch(pos)
-----------------------
This function 'toches' node at position `pos` by writing `_t` meta variable of `seconds_irl`.

### mcl_time.get_number_of_times_at_pos(pos, interval, chance)
--------------------------------------------------------------
Returns the number of how many times something would probably happen for node at pos `pos` if the area was active and we didn't skip the nights.
It reads and updates meta variable `_t` from position `pos` and uses it as previous `seconds_irl`, so we don't need to remember it.

Argunments:
 * `pos` - node position
 * `interval` and `chance` - interval and chance like from ABM setup

Returns:
 * Integer number of how many times something would happen to the node at position `pos` if the area was active all the time and we didn't skip the nights.
 * For unclear conditions, like missing meta or zero `time_speed`, this function will return `0`.

### mcl_time.get_number_of_times_at_pos_or_1(pos, interval, chance)
-------------------------------------------------------------------
Returns the number of how many times something would probably happen for node at pos `pos` if the area was active and we didn't skip the nights.
It reads and updates meta variable `_t` from position `pos` and uses it as previous `seconds_irl`, so we don't need to remember it.

Argunments:
 * `pos` - node position
 * `interval` and `chance` - interval and chance like from ABM setup

Returns:
 * Integer number of how many times something would happen to the node at position `pos` if the area was active all the time and we didn't skip the nights.
 * For unclear conditions, like missing meta or zero `time_speed`, this function will return `1`.

### mcl_time.get_number_of_times_at_pos_or_nil(pos, interval, chance)
---------------------------------------------------------------------
Returns the number of how many times something would probably happen for node at pos `pos` if the area was active and we didn't skip the nights.
It reads and updates meta variable `_t` from position `pos` and uses it as previous `seconds_irl`, so we don't need to remember it.

Argunments:
 * `pos` - node position
 * `interval` and `chance` - interval and chance like from ABM setup

Returns:
 * Integer number of how many times something would happen to the node at position `pos` if the area was active all the time and we didn't skip the nights.
 * For unclear conditions, like missing meta or zero `time_speed`, this function will return `nil`.

### mcl_time.get_irl_seconds_passed_at_pos(pos)
-----------------------------------------------
Returns the number of how many in-real-life seconds would be passed for the node at position `pos`, if the area was active all the time and we didn't skip the nights.
It uses node meta variable `_t` to calculate this value.

Argunments:
 * `pos` - node position

Returns:
 * Integer number of how many in-real-life seconds would be passed for the node at position `pos, if the area was active all the time and we didn't skip the nights.
 * For unclear conditions, like missing meta or zero `time_speed`, this function will return `0`.

### mcl_time.get_irl_seconds_passed_at_pos_or_1(pos)
----------------------------------------------------
Returns the number of how many in-real-life seconds would be passed for the node at position `pos`, if the area was active all the time and we didn't skip the nights.
It uses node meta variable `_t` to calculate this value.

Argunments:
 * `pos` - node position

Returns:
 * Integer number of how many in-real-life seconds would be passed for the node at position `pos, if the area was active all the time and we didn't skip the nights.
 * For unclear conditions, like missing meta or zero `time_speed`, this function will return `1`.

### mcl_time.get_irl_seconds_passed_at_pos_or_nil(pos)
----------------------------------------------------
Returns the number of how many in-real-life seconds would be passed for the node at position `pos`, if the area was active all the time and we didn't skip the nights.
It uses node meta variable `_t` to calculate this value.

Argunments:
 * `pos` - node position

Returns:
 * Integer number of how many in-real-life seconds would be passed for the node at position `pos, if the area was active all the time and we didn't skip the nights.
 * For unclear conditions, like missing meta or zero `time_speed`, this function will return `nil`.

