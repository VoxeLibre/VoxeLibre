mcl_worlds = {}

-- For a given position, returns a 2-tuple:
-- 1st return value: true if pos is in void
-- 2nd return value: true if it is in the deadly part of the void
function mcl_worlds.is_in_void(pos)
	local void =
		not ((pos.y < mcl_vars.mg_overworld_max and pos.y > mcl_vars.mg_overworld_min) or
		(pos.y < mcl_vars.mg_nether_max and pos.y > mcl_vars.mg_nether_min) or
		(pos.y < mcl_vars.mg_end_max and pos.y > mcl_vars.mg_end_min))

	local void_deadly = false
	local deadly_tolerance = 64 -- the player must be this many nodes “deep” into the void to be damaged
	if void then
		-- Overworld → Void → End → Void → Nether → Void
		if pos.y < mcl_vars.mg_overworld_min and pos.y > mcl_vars.mg_end_max then
			void_deadly = pos.y < mcl_vars.mg_overworld_min - deadly_tolerance
		elseif pos.y < mcl_vars.mg_end_min and pos.y > mcl_vars.mg_nether_max then
			void_deadly = pos.y < mcl_vars.mg_end_min - deadly_tolerance
		elseif pos.y < mcl_vars.mg_nether_min then
			void_deadly = pos.y < mcl_vars.mg_nether_min - deadly_tolerance
		end
	end
	return void, void_deadly
end

-- Takes an Y coordinate as input and returns:
-- 1) The corresponding Minecraft layer (can be nil if void)
-- 2) The corresponding Minecraft dimension ("overworld", "nether" or "end") or "void" if it is in the void
-- If the Y coordinate is not located in any dimension, it will return:
--     nil, "void"
function mcl_worlds.y_to_layer(y)
       if y >= mcl_vars.mg_overworld_min then
               return y - mcl_vars.mg_overworld_min, "overworld"
       elseif y >= mcl_vars.mg_nether_min and y <= mcl_vars.mg_nether_max then
               return y - mcl_vars.mg_nether_min, "nether"
       elseif y >= mcl_vars.mg_end_min and y <= mcl_vars.mg_end_max then
               return y - mcl_vars.mg_end_min, "end"
       else
               return nil, "void"
       end
end

-- Takes a pos and returns the dimension it belongs to (same as above)
function mcl_worlds.pos_to_dimension(pos)
	local _, dim = mcl_worlds.y_to_layer(pos.y)
	return dim
end

-- Takes a Minecraft layer and a “dimension” name
-- and returns the corresponding Y coordinate for
-- MineClone 2.
-- mc_dimension is one of "overworld", "nether", "end" (default: "overworld").
function mcl_worlds.layer_to_y(layer, mc_dimension)
       if mc_dimension == "overworld" or mc_dimension == nil then
               return layer + mcl_vars.mg_overworld_min
       elseif mc_dimension == "nether" then
               return layer + mcl_vars.mg_nether_min
       elseif mc_dimension == "end" then
               return layer + mcl_vars.mg_end_min
       end
end

-- Takes a position and returns true if this position can have weather
function mcl_worlds.has_weather(pos)
       -- Weather in the Overworld and the high part of the void below
       return pos.y <= mcl_vars.mg_overworld_max and pos.y >= mcl_vars.mg_overworld_min - 64
end

-- Takes a position (pos) and returns true if compasses are working here
function mcl_worlds.compass_works(pos)
       -- It doesn't work in Nether and the End, but it works in the Overworld and in the high part of the void below
       local _, dim = mcl_worlds.y_to_layer(pos.y)
       if dim == "nether" or dim == "end" then
               return false
       elseif dim == "void" then
               return pos.y <= mcl_vars.mg_overworld_max and pos.y >= mcl_vars.mg_overworld_min - 64
       else
               return true
       end
end

-- Takes a position (pos) and returns true if clocks are working here
mcl_worlds.clock_works = mcl_worlds.compass_works

