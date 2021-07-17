mcl_worlds = {}

local get_connected_players = minetest.get_connected_players

-- For a given position, returns a 2-tuple:
-- 1st return value: true if pos is in void
-- 2nd return value: true if it is in the deadly part of the void
local min1, min2, min3 = mcl_mapgen.overworld.min, mcl_mapgen.end_.min, mcl_mapgen.nether.min
local max1, max2, max3 = mcl_mapgen.overworld.max, mcl_mapgen.end_.max, mcl_mapgen.nether.max+128
function mcl_worlds.is_in_void(pos)
	local y = pos.y
	local void = not ((y < max1 and y > min1) or (y < max2 and y > min2) or (y < max3 and y > min3))

	local void_deadly = false
	local deadly_tolerance = 64 -- the player must be this many nodes “deep” into the void to be damaged
	if void then
		-- Overworld → Void → End → Void → Nether → Void
		if y < min1 and y > max2 then
			void_deadly = y < min1 - deadly_tolerance
		elseif y < min2 and y > max3 then
			-- The void between End and Nether. Like usual, but here, the void
			-- *above* the Nether also has a small tolerance area, so player
			-- can fly above the Nether without getting hurt instantly.
			void_deadly = (y < min2 - deadly_tolerance) and (y > max3 + deadly_tolerance)
		elseif y < min3 then
			void_deadly = y < min3 - deadly_tolerance
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
       if y >= min1 then
               return y - min1, "overworld"
       elseif y >= min3 and y <= max3 then
               return y - min3, "nether"
       elseif y >= min2 and y <= max2 then
               return y - min2, "end"
       else
               return nil, "void"
       end
end

local y_to_layer = mcl_worlds.y_to_layer

-- Takes a pos and returns the dimension it belongs to (same as above)
function mcl_worlds.pos_to_dimension(pos)
	local _, dim = y_to_layer(pos.y)
	return dim
end

local pos_to_dimension = mcl_worlds.pos_to_dimension

-- Takes a Minecraft layer and a “dimension” name
-- and returns the corresponding Y coordinate for
-- MineClone 2.
-- mc_dimension is one of "overworld", "nether", "end" (default: "overworld").
function mcl_worlds.layer_to_y(layer, mc_dimension)
       if mc_dimension == "overworld" or mc_dimension == nil then
               return layer + min1
       elseif mc_dimension == "nether" then
               return layer + min3
       elseif mc_dimension == "end" then
               return layer + min2
       end
end

-- Takes a position and returns true if this position can have weather
function mcl_worlds.has_weather(pos)
       -- Weather in the Overworld and the high part of the void below
       return pos.y <= max1 and pos.y >= min1 - 64
end

-- Takes a position and returns true if this position can have Nether dust
function mcl_worlds.has_dust(pos)
       -- Weather in the Overworld and the high part of the void below
       return pos.y <= max3 + 138 and pos.y >= min3 - 10
end

-- Takes a position (pos) and returns true if compasses are working here
function mcl_worlds.compass_works(pos)
       -- It doesn't work in Nether and the End, but it works in the Overworld and in the high part of the void below
       local _, dim = mcl_worlds.y_to_layer(pos.y)
       if dim == "nether" or dim == "end" then
               return false
       elseif dim == "void" then
               return pos.y <= max1 and pos.y >= min1 - 64
       else
               return true
       end
end

-- Takes a position (pos) and returns true if clocks are working here
mcl_worlds.clock_works = mcl_worlds.compass_works

--------------- CALLBACKS ------------------
mcl_worlds.registered_on_dimension_change = {}

-- Register a callback function func(player, dimension).
-- It will be called whenever a player changes between dimensions.
-- The void counts as dimension.
-- * player: The player who changed the dimension
-- * dimension: The new dimension of the player ("overworld", "nether", "end", "void").
function mcl_worlds.register_on_dimension_change(func)
	table.insert(mcl_worlds.registered_on_dimension_change, func)
end

-- Playername-indexed table containig the name of the last known dimension the
-- player was in.
local last_dimension = {}

-- Notifies this mod about a dimension change of a player.
-- * player: Player who changed the dimension
-- * dimension: New dimension ("overworld", "nether", "end", "void")
function mcl_worlds.dimension_change(player, dimension)
	local playername = player:get_player_name()
	for i=1, #mcl_worlds.registered_on_dimension_change do
		mcl_worlds.registered_on_dimension_change[i](player, dimension, last_dimension[playername])
	end
	last_dimension[playername] = dimension
end

local dimension_change = mcl_worlds.dimension_change

----------------------- INTERNAL STUFF ----------------------

-- Update the dimension callbacks every DIM_UPDATE seconds
local DIM_UPDATE = 1
local dimtimer = 0

minetest.register_on_joinplayer(function(player)
	last_dimension[player:get_player_name()] = pos_to_dimension(player:get_pos())
end)

minetest.register_globalstep(function(dtime)
	-- regular updates based on iterval
	dimtimer = dimtimer + dtime;
	if dimtimer >= DIM_UPDATE then
		local players = get_connected_players()
		for p = 1, #players do
			local dim = pos_to_dimension(players[p]:get_pos())
			local name = players[p]:get_player_name()
			if dim ~= last_dimension[name] then
				dimension_change(players[p], dim)
			end
		end
		dimtimer = 0
	end
end)
