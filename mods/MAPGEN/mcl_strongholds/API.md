# Strongholds API
The API provides one function:

## `mcl_strongholds.get_stronghold_positions()`
Returns a table of the positions of all strongholds, centered at the end portal room.
This includes strongholds which have not been generated yet.
This table is a copy, changes to the table will have no effect on the stronghold generation.

Format of the returned table:
{
	{ pos = <position>, generated = <true/false> }, -- first stronghold
	{ pos = <position>, generated = <true/false> }, -- second stronghold
	-- and so on …
}

* pos: Position of stronghold, centered at the end portal room
* generated: `true` if this stronghold has already been generated
