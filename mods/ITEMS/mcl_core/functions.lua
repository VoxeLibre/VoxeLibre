--
-- Lavacooling
--

mcl_core.cool_lava_source = function(pos)
	minetest.set_node(pos, {name="mcl_core:obsidian"})
end

mcl_core.cool_lava_flowing = function(pos)
	minetest.set_node(pos, {name="mcl_core:stone"})
end

minetest.register_abm({
	nodenames = {"mcl_core:lava_flowing"},
	neighbors = {"group:water"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		mcl_core.cool_lava_flowing(pos, node, active_object_count, active_object_count_wider)
	end,
})

minetest.register_abm({
	nodenames = {"mcl_core:lava_source"},
	neighbors = {"group:water"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		mcl_core.cool_lava_source(pos, node, active_object_count, active_object_count_wider)
	end,
})

--
-- Papyrus and cactus growing
--

-- Functions
mcl_core.grow_cactus = function(pos, node)
	pos.y = pos.y-1
	local name = minetest.get_node(pos).name
	if minetest.get_item_group(name, "sand") ~= 0 then
		pos.y = pos.y+1
		local height = 0
		while minetest.get_node(pos).name == "mcl_core:cactus" and height < 4 do
			height = height+1
			pos.y = pos.y+1
		end
		if height < 3 then
			if minetest.get_node(pos).name == "air" then
				minetest.set_node(pos, {name="mcl_core:cactus"})
			end
		end
	end
end

mcl_core.grow_reeds = function(pos, node)
	pos.y = pos.y-1
	local name = minetest.get_node(pos).name
	if minetest.get_node_group(name, "soil_sugarcane") ~= 0 then
		if minetest.find_node_near(pos, 1, {"group:water"}) == nil and minetest.find_node_near(pos, 1, {"group:frosted_ice"}) == nil then
			return
		end
		pos.y = pos.y+1
		local height = 0
		while minetest.get_node(pos).name == "mcl_core:reeds" and height < 3 do
			height = height+1
			pos.y = pos.y+1
		end
		if height < 3 then
			if minetest.get_node(pos).name == "air" then
				minetest.set_node(pos, {name="mcl_core:reeds"})
			end
		end
	end
end

-- ABMs


local function drop_attached_node(p)
	local nn = minetest.get_node(p).name
	minetest.remove_node(p)
	for _, item in pairs(minetest.get_node_drops(nn, "")) do
		local pos = {
			x = p.x + math.random()/2 - 0.25,
			y = p.y + math.random()/2 - 0.25,
			z = p.z + math.random()/2 - 0.25,
		}
		minetest.add_item(pos, item)
	end
end

-- Remove attached nodes next to flowing water
minetest.register_abm({
	nodenames = {"group:dig_by_water"},
	neighbors = {"group:water"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		for xp=-1,1 do
			for zp=-1,1 do
				local p = {x=pos.x+xp, y=pos.y, z=pos.z+zp}
				local n = minetest.get_node(p)
				local d = minetest.registered_nodes[n.name]
				if (d.groups.water and d.liquidtype == "flowing") then
					drop_attached_node(pos)
					minetest.dig_node(pos)
					break
				end
			end
		end
		for yp=-1,1 do
			local p = {x=pos.x, y=pos.y+yp, z=pos.z}
			local n = minetest.get_node(p)
			local d = minetest.registered_nodes[n.name]
			if (d.groups.water and d.liquidtype == "flowing") then
				drop_attached_node(pos)
				minetest.dig_node(pos)
				break
			end
		end
		
	end,
})

minetest.register_abm({
	nodenames = {"mcl_core:cactus"},
	neighbors = {"group:sand"},
	interval = 25,
	chance = 10,
	action = function(pos)
		mcl_core.grow_cactus(pos)
	end,
})

minetest.register_abm({
	nodenames = {"mcl_core:reeds"},
	neighbors = {"group:soil_sugarcane"},
	interval = 25,
	chance = 10,
	action = function(pos)
		mcl_core.grow_reeds(pos)
	end,
})

--
-- Papyrus and cactus drop
--

local timber_nodenames={"mcl_core:reeds", "mcl_core:cactus"}

minetest.register_on_dignode(function(pos, node)
	local i=1
	while timber_nodenames[i]~=nil do
		if node.name==timber_nodenames[i] then
			local np={x=pos.x, y=pos.y+1, z=pos.z}
			while minetest.get_node(np).name==timber_nodenames[i] do
				minetest.remove_node(np)
				if not minetest.setting_getbool("creative_mode") then
					minetest.add_item(np, timber_nodenames[i])
				end
				np={x=np.x, y=np.y+1, z=np.z}
			end
		end
		i=i+1
	end
end)

local function air_leave()
	if math.random(0, 50) == 3 then
		return {name = "air"}
	else
		return {name = "mcl_core:leaves"}
	end
end

function mcl_core.generate_tree(pos, trunk, leaves, typearbre)
	pos.y = pos.y-1
	local nodename = minetest.get_node(pos).name
		
	pos.y = pos.y+1
	if not minetest.get_node_light(pos) then
		return
	end
	local node
	if typearbre == nil or typearbre == 1 then
		node = {name = ""}
		for dy=1,4 do
			pos.y = pos.y+dy
			if minetest.get_node(pos).name ~= "air" then
				return
			end
			pos.y = pos.y-dy
		end
		node = {name = trunk}
		for dy=0,4 do
			pos.y = pos.y+dy
			if minetest.get_node(pos).name == "air" then
				minetest.add_node(pos, node)
			end
			pos.y = pos.y-dy
		end

		node = {name = leaves}
		pos.y = pos.y+3
		local rarity = 0
		if math.random(0, 10) == 3 then
			rarity = 1
		end
		for dx=-2,2 do
			for dz=-2,2 do
				for dy=0,3 do
					pos.x = pos.x+dx
					pos.y = pos.y+dy
					pos.z = pos.z+dz

					if dx == 0 and dz == 0 and dy==3 then
						if minetest.get_node(pos).name == "air" and math.random(1, 5) <= 4 then
							minetest.add_node(pos, node)
							minetest.add_node(pos, air_leave())
						end
					elseif dx == 0 and dz == 0 and dy==4 then
						if minetest.get_node(pos).name == "air" and math.random(1, 5) <= 4 then
							minetest.add_node(pos, node)
							minetest.add_node(pos, air_leave())
						end
					elseif math.abs(dx) ~= 2 and math.abs(dz) ~= 2 then
						if minetest.get_node(pos).name == "air" then
							minetest.add_node(pos, node)
							minetest.add_node(pos, air_leave())
						end
					else
						if math.abs(dx) ~= 2 or math.abs(dz) ~= 2 then
							if minetest.get_node(pos).name == "air" and math.random(1, 5) <= 4 then
								minetest.add_node(pos, node)
								minetest.add_node(pos, air_leave())
							end
						end
					end
					pos.x = pos.x-dx
					pos.y = pos.y-dy
					pos.z = pos.z-dz
				end
			end
		end
	elseif typearbre == 2 then
		node = {name = ""}
		
		-- can place big tree ?
		local tree_size = math.random(15, 25)
		for dy=1,4 do
			pos.y = pos.y+dy
			if minetest.get_node(pos).name ~= "air" then
				return
			end
			pos.y = pos.y-dy
		end
		
		--Cheak for placing big tree
		pos.y = pos.y-1
			for dz=0,1 do
					pos.z = pos.z + dz
					--> 0
					if minetest.get_node(pos).name == "mcl_core:dirt_with_grass" 
					or  minetest.get_node(pos).name == "mcl_core:dirt" then else
							return
					end
					pos.x = pos.x+1
					--> 1
					if minetest.get_node(pos).name == "mcl_core:dirt_with_grass" 
					or  minetest.get_node(pos).name == "mcl_core:dirt" then else
							return
					end
					pos.x = pos.x-1
					pos.z = pos.z - dz
			end
		pos.y = pos.y+1
		
		
		-- Make tree with vine
		node = {name = trunk}
		for dy=0,tree_size do
			pos.y = pos.y+dy
			
			for dz=-1,2 do
				if dz == -1 then
					pos.z = pos.z + dz
					if math.random(1, 3) == 1 and minetest.get_node(pos).name == "air" then
						minetest.add_node(pos, {name = "mcl_core:vine", param2 = 4})
					end
					pos.x = pos.x+1
					if math.random(1, 3) == 1 and  minetest.get_node(pos).name == "air" then
						minetest.add_node(pos, {name = "mcl_core:vine", param2 = 4})
					end
					pos.x = pos.x-1
					pos.z = pos.z - dz
				elseif dz == 2 then
					pos.z = pos.z + dz
					if math.random(1, 3) == 1 and  minetest.get_node(pos).name == "air"then
						minetest.add_node(pos, {name = "mcl_core:vine", param2 = 5})
					end
					pos.x = pos.x+1
					if math.random(1, 3) == 1 and minetest.get_node(pos).name == "air" then
						minetest.add_node(pos, {name = "mcl_core:vine", param2 = 5})
					end
					pos.x = pos.x-1
					pos.z = pos.z - dz
				else
					pos.z = pos.z + dz
					pos.x = pos.x-1
					if math.random(1, 3) == 1  and minetest.get_node(pos).name == "air" then
						minetest.add_node(pos, {name = "mcl_core:vine", param2 = 2})
					end
					pos.x = pos.x+1
					if minetest.get_node(pos).name == "air" then
						minetest.add_node(pos, {name = trunk, param2=2})
					end
					pos.x = pos.x+1
					if minetest.get_node(pos).name == "air" then
						minetest.add_node(pos, {name = trunk, param2=2})
					end
					pos.x = pos.x+1
					if math.random(1, 3) == 1 and minetest.get_node(pos).name == "air" then
						minetest.add_node(pos, {name = "mcl_core:vine", param2 = 3})
					end
					pos.x = pos.x-2
					pos.z = pos.z - dz
				end
			end
			
			pos.y = pos.y-dy
		end

		-- make leaves
		node = {name = leaves}
		pos.y = pos.y+tree_size-4
		for dx=-5,5 do
			for dz=-5,5 do
				for dy=0,3 do
					pos.x = pos.x+dx
					pos.y = pos.y+dy
					pos.z = pos.z+dz

					if dx == 0 and dz == 0 and dy==3 then
						if minetest.get_node(pos).name == "air" or minetest.get_node(pos).name == "mcl_core:vine" and math.random(1, 2) == 1 then
							minetest.add_node(pos, node)
							end
					elseif dx == 0 and dz == 0 and dy==4 then
						if minetest.get_node(pos).name == "air" or minetest.get_node(pos).name == "mcl_core:vine"  and math.random(1, 5) == 1 then
							minetest.add_node(pos, node)
								minetest.add_node(pos, air_leave())
						end
					elseif math.abs(dx) ~= 2 and math.abs(dz) ~= 2 then
						if minetest.get_node(pos).name == "air" or minetest.get_node(pos).name == "mcl_core:vine"  then
							minetest.add_node(pos, node)
						end
					else
						if math.abs(dx) ~= 2 or math.abs(dz) ~= 2 then
							if minetest.get_node(pos).name == "air" or minetest.get_node(pos).name == "mcl_core:vine" and math.random(1, 3) == 1 then
								minetest.add_node(pos, node)
							end
						else
							if math.random(1, 5) == 1 and minetest.get_node(pos).name == "air" then
								minetest.add_node(pos, node)
							end
						end
					end
					pos.x = pos.x-dx
					pos.y = pos.y-dy
					pos.z = pos.z-dz
				end
			end
		end
	end
end

------------------------------
-- Try generate grass dirt ---
------------------------------
-- turn dirt to dirt with grass
minetest.register_abm({
	nodenames = {"mcl_core:dirt"},
	neighbors = {"air"},
	interval = 30,
	chance = 20,
	action = function(pos)
	if pos == nil then 
		return 
	end
	local can_change = 0
	for i=1,4 do
			local p = {x=pos.x, y=pos.y+i, z=pos.z}
			local n = minetest.get_node(p)
			-- On verifie si il y a de l'air
			if (n.name=="air") then
				can_change = can_change + 1
			end
	end
		if can_change > 3 then
			local light = minetest.get_node_light(pos)
			if light or light > 10 then
				minetest.add_node(pos, {name="mcl_core:dirt_with_grass"})
			end
			
		end
	end,
})



--------------------------
-- Try generate tree   ---
--------------------------
-- TODO: Acacia, dark oak, spruce, birch

-- Normal tree
minetest.register_abm({
	nodenames = {"mcl_core:sapling"},
	neighbors = {"group:soil_sapling"},
	interval = 30,
	chance = 15,
	action = function(pos)
		local light = minetest.get_node_light(pos)
		local soilnode = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})
		local soiltype = minetest.get_item_group(soilnode.name, "soil_sapling")
		if soiltype >= 1 and light and light >= 9 then
			minetest.add_node(pos, {name="air"})
			mcl_core.generate_tree(pos, "mcl_core:tree", "mcl_core:leaves", 1)
		end
	end,
})

-- Jungle Tree
minetest.register_abm({
	nodenames = {"mcl_core:junglesapling"},
	neighbors = {"group:soil_sapling"},
	interval = 30,
	chance = 15,
	action = function(pos)
		local light = minetest.get_node_light(pos)
		local soilnode = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})
		local soiltype = minetest.get_item_group(soilnode.name, "soil_sapling")
		if soiltype == 2 and light and light >= 9 then
			minetest.add_node(pos, {name="air"})
			mcl_core.generate_tree(pos, "mcl_core:jungletree", "mcl_core:jungleleaves", 2)
		end
	end,
})

---------------------
-- Vine generating --
---------------------
minetest.register_abm({
	nodenames = {"mcl_core:vine"},
	interval = 80,
	chance = 5,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local newpos = {x=pos.x, y=pos.y-1, z=pos.z}
		local n = minetest.get_node(newpos)
		if n.name == "air" then
			local walldir = node.param2
			minetest.add_node(newpos, {name = "mcl_core:vine", param2 = walldir})
		end
	end
})



-- Leaf Decay

-- To enable leaf decay for a node, add it to the "leafdecay" group.
--
-- The rating of the group determines how far from a node in the group "tree"
-- the node can be without decaying.
--
-- If param2 of the node is ~= 0, the node will always be preserved. Thus, if
-- the player places a node of that kind, you will want to set param2=1 or so.
--
-- If the node is in the leafdecay_drop group then the it will always be dropped
-- as an item

mcl_core.leafdecay_trunk_cache = {}
mcl_core.leafdecay_enable_cache = true
-- Spread the load of finding trunks
mcl_core.leafdecay_trunk_find_allow_accumulator = 0

minetest.register_globalstep(function(dtime)
	local finds_per_second = 5000
	mcl_core.leafdecay_trunk_find_allow_accumulator =
			math.floor(dtime * finds_per_second)
end)

minetest.register_abm({
	nodenames = {"group:leafdecay"},
	neighbors = {"air", "group:liquid"},
	-- A low interval and a high inverse chance spreads the load
	interval = 2,
	chance = 5,

	action = function(p0, node, _, _)
		--print("leafdecay ABM at "..p0.x..", "..p0.y..", "..p0.z..")")
		local do_preserve = false
		local d = minetest.registered_nodes[node.name].groups.leafdecay
		if not d or d == 0 then
			--print("not groups.leafdecay")
			return
		end
		local n0 = minetest.get_node(p0)
		if n0.param2 ~= 0 then
			--print("param2 ~= 0")
			return
		end
		local p0_hash = nil
		if mcl_core.leafdecay_enable_cache then
			p0_hash = minetest.hash_node_position(p0)
			local trunkp = mcl_core.leafdecay_trunk_cache[p0_hash]
			if trunkp then
				local n = minetest.get_node(trunkp)
				local reg = minetest.registered_nodes[n.name]
				-- Assume ignore is a trunk, to make the thing work at the border of the active area
				if n.name == "ignore" or (reg and reg.groups.tree and reg.groups.tree ~= 0) then
					--print("cached trunk still exists")
					return
				end
				--print("cached trunk is invalid")
				-- Cache is invalid
				table.remove(mcl_core.leafdecay_trunk_cache, p0_hash)
			end
		end
		if mcl_core.leafdecay_trunk_find_allow_accumulator <= 0 then
			return
		end
		mcl_core.leafdecay_trunk_find_allow_accumulator =
				mcl_core.leafdecay_trunk_find_allow_accumulator - 1
		-- Assume ignore is a trunk, to make the thing work at the border of the active area
		local p1 = minetest.find_node_near(p0, d, {"ignore", "group:tree"})
		if p1 then
			do_preserve = true
			if mcl_core.leafdecay_enable_cache then
				--print("caching trunk")
				-- Cache the trunk
				mcl_core.leafdecay_trunk_cache[p0_hash] = p1
			end
		end
		if not do_preserve then
			-- Drop stuff other than the node itself
			local itemstacks = minetest.get_node_drops(n0.name)
			for _, itemname in ipairs(itemstacks) do
				if minetest.get_item_group(n0.name, "leafdecay_drop") ~= 0 or
						itemname ~= n0.name then
					local p_drop = {
						x = p0.x - 0.5 + math.random(),
						y = p0.y - 0.5 + math.random(),
						z = p0.z - 0.5 + math.random(),
					}
					minetest.add_item(p_drop, itemname)
				end
			end
			-- Remove node
			minetest.remove_node(p0)
			core.check_for_falling(p0)
		end
	end
})

------------------------
-- Create Color Glass -- 
------------------------
function mcl_core.add_glass(desc, recipeitem, color)

	minetest.register_node("mcl_core:glass_"..color, {
		description = desc,
		drawtype = "glasslike",
		is_ground_content = false,
		tiles = {"xpanes_pane_glass_"..color..".png"},
		inventory_image = minetest.inventorycube("xpanes_pane_glass_"..color..".png"),
		paramtype = "light",
		use_texture_alpha = true,
		stack_max = 64,
		groups = {cracky=3,oddly_breakable_by_hand=3, building_block=1},
		sounds = mcl_sounds.node_sound_glass_defaults(),
		drop = "",
		_mcl_blast_resistance = 1.5,
		_mcl_hardness = 0.3,
	})
	
	minetest.register_craft({
		output = 'mcl_core:glass_'..color..' 8',
		recipe = {
			{'mcl_core:glass','mcl_core:glass','mcl_core:glass'},
			{'mcl_core:glass','group:dye,'..recipeitem,'mcl_core:glass'},
			{'mcl_core:glass','mcl_core:glass','mcl_core:glass'},
		}
	})
end


