-- register extra flavours of a base nodedef

local get_connected_players = minetest.get_connected_players
local get_node = minetest.get_node
local vector = vector
local ceil = math.ceil
local pairs = pairs

walkover = {}

local on_walk = {}
local registered_globals = {}

walkover.registered_globals = registered_globals

function walkover.register_global(func)
	table.insert(registered_globals, func)
end

minetest.register_on_mods_loaded(function()
	for name,def in pairs(minetest.registered_nodes) do
		if def.on_walk_over then
			on_walk[name] = def.on_walk_over
		end
	end
end)

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer >= 0.6 then
		for _, player in pairs(get_connected_players()) do
			local ppos = player:get_pos()
			local npos = vector.add(ppos, vector.new(0, -0.1, 0))
			if npos then
				local node = get_node(npos)
				if node then
					if on_walk[node.name] then
						on_walk[node.name](npos, node, player)
					end
					for i = 1, #registered_globals do
						registered_globals[i](npos, node, player)
					end
				end
			end
		end
		timer = 0
	end
end)
