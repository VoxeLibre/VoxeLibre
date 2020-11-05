-- register extra flavours of a base nodedef
walkover = {}
walkover.registered_globals = {}

function walkover.register_global(func)
	table.insert(walkover.registered_globals, func)
end

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 0.3 then
		for _,player in pairs(minetest.get_connected_players()) do
	    local pp = player:get_pos()
	    pp.y = math.ceil(pp.y)
            local loc = vector.add(pp, {x=0,y=-1,z=0})
            if loc ~= nil then
               
                local nodeiamon = minetest.get_node(loc)
                
                if nodeiamon ~= nil then
                    local def = minetest.registered_nodes[nodeiamon.name]
                    if def ~= nil and def.on_walk_over ~= nil then
                        def.on_walk_over(loc, nodeiamon, player)
                    end
                    for _, func in ipairs(walkover.registered_globals) do
						func(loc, nodeiamon, player)
                    end
                end   
            end
        end
	 
		timer = 0
	end
end)
