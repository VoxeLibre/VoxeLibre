-- register extra flavours of a base nodedef

local get_connected_players = minetest.get_connected_players
local get_node = minetest.get_node
local vector_add = vector.add
local ceil = math.ceil

walkover = {}
walkover.registered_globals = {}

function walkover.register_global(func)
	table.insert(walkover.registered_globals, func)
end

local on_walk = {}
local registered_globals = {}

minetest.register_on_mods_loaded(function()
	for name,def in pairs(minetest.registered_nodes) do
		if def.on_walk_over then
			on_walk[name] = def.on_walk_over
		end
	end
	for _,func in ipairs(walkover.registered_globals) do --cache registered globals
		table.insert(registered_globals, func)
	end
end)

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 0.3 then
		for _,player in pairs(get_connected_players()) do
	    local pp = player:get_pos()
	    pp.y = ceil(pp.y)
            local loc = vector_add(pp, {x=0,y=-1,z=0})
            if loc ~= nil then
               
                local nodeiamon = get_node(loc)
                
                if nodeiamon ~= nil then
                    if on_walk[nodeiamon.name] then
                        on_walk[nodeiamon.name](loc, nodeiamon, player)
                    end
                    for i = 1, #registered_globals do
						registered_globals[i](loc, nodeiamon, player)
                    end
                end   
            end
        end
	 
		timer = 0
	end
end)
