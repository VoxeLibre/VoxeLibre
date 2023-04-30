-- Tree Growth
-- TODO: Use better spawning behavior and wood api when wood api is finished.
function mcl_cherry_blossom.generate_cherry_tree(pos)
	local pr = PseudoRandom(pos.x+pos.y+pos.z)
	local r = pr:next(1,3)
	local modpath = minetest.get_modpath("mcl_cherry_blossom")
	local path = modpath.."/schematics/mcl_cherry_blossom_tree_"..tostring(r)..".mts"
	if mcl_core.check_growth_width(pos,7,8) then
		minetest.set_node(pos, {name = "air"})
		if r == 1 then
			minetest.place_schematic({x = pos.x-2, y = pos.y, z = pos.z-2}, path, "random", nil, false)
		elseif r == 2 then
			minetest.place_schematic({x = pos.x-2, y = pos.y, z = pos.z-2}, path, nil, nil, false)
		elseif r == 3 then
			minetest.place_schematic({x = pos.x-3, y = pos.y, z = pos.z-3}, path, nil, nil, false)
		end
	end
end

minetest.register_abm({
	label = "Cherry Tree Growth",
	nodenames = "mcl_cherry_blossom:cherrysapling",
	interval = 30,
	chance = 5,
	action = function(pos,node)
		mcl_cherry_blossom.generate_cherry_tree(pos)
	end,
})
