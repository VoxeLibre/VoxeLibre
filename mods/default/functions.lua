--
-- On Die
--
--if minetest.setting_get("keepInventory") == false then
	minetest.register_on_dieplayer(function(player)
		local inv = player:get_inventory()
		local pos = player:getpos()
		for i,stack in ipairs(inv:get_list("main")) do
			local x = math.random(0, 9)/3
			local z = math.random(0, 9)/3
			pos.x = pos.x + x
			pos.z = pos.z + z
			minetest.env:add_item(pos, stack)
			stack:clear()
			inv:set_stack("main", i, stack)
			pos.x = pos.x - x
			pos.z = pos.z - z
		end
	end)
--end

--
-- Lavacooling
--

default.cool_lava_source = function(pos)
	minetest.env:set_node(pos, {name="default:obsidian"})
end

default.cool_lava_flowing = function(pos)
	minetest.env:set_node(pos, {name="default:stone"})
end

minetest.register_abm({
	nodenames = {"default:lava_flowing"},
	neighbors = {"group:water"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		default.cool_lava_flowing(pos, node, active_object_count, active_object_count_wider)
	end,
})

minetest.register_abm({
	nodenames = {"default:lava_source"},
	neighbors = {"group:water"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		default.cool_lava_source(pos, node, active_object_count, active_object_count_wider)
	end,
})

--
-- Papyrus and cactus growing
--

-- Functions
grow_cactus = function(pos, node)
	pos.y = pos.y-1
	local name = minetest.env:get_node(pos).name
	if minetest.get_item_group(name, "sand") ~= 0 then
		pos.y = pos.y+1
		local height = 0
		while minetest.env:get_node(pos).name == "default:cactus" and height < 4 do
			height = height+1
			pos.y = pos.y+1
		end
		if height < 4 then
			if minetest.env:get_node(pos).name == "air" then
				minetest.env:set_node(pos, {name="default:cactus"})
			end
		end
	end
end

grow_reeds = function(pos, node)
	pos.y = pos.y-1
	local name = minetest.env:get_node(pos).name
	if name == "default:dirt" or name == "default:dirt_with_grass" then
		if minetest.env:find_node_near(pos, 3, {"group:water"}) == nil then
			return
		end
		pos.y = pos.y+1
		local height = 0
		while minetest.env:get_node(pos).name == "default:reeds" and height < 3 do
			height = height+1
			pos.y = pos.y+1
		end
		if height < 3 then
			if minetest.env:get_node(pos).name == "air" then
				minetest.env:set_node(pos, {name="default:reeds"})
			end
		end
	end
end

-- ABMs
minetest.register_abm({
	nodenames = {"default:cactus"},
	neighbors = {"group:sand"},
	interval = 25,
	chance = 10,
	action = function(pos)
		grow_cactus(pos)
	end,
})

minetest.register_abm({
	nodenames = {"default:reeds"},
	neighbors = {"default:dirt", "default:dirt_with_grass"},
	interval = 25,
	chance = 10,
	action = function(pos)
		grow_reeds(pos)
	end,
})

--
-- Papyrus and cactus drop
--

local timber_nodenames={"default:reeds", "default:cactus"}

minetest.register_on_dignode(function(pos, node)
	local i=1
	while timber_nodenames[i]~=nil do
		if node.name==timber_nodenames[i] then
			np={x=pos.x, y=pos.y+1, z=pos.z}
			while minetest.env:get_node(np).name==timber_nodenames[i] do
				minetest.env:remove_node(np)
				minetest.env:add_item(np, timber_nodenames[i])
				np={x=np.x, y=np.y+1, z=np.z}
			end
		end
		i=i+1
	end
end)

--
-- Flint and Steel
--

function get_nodedef_field(nodename, fieldname)
    if not minetest.registered_nodes[nodename] then
        return nil
    end
    return minetest.registered_nodes[nodename][fieldname]
end

function set_fire(pointed_thing)
		local n = minetest.env:get_node(pointed_thing.above)
		if n.name ~= ""  and n.name == "air" and not minetest.is_protected(pointed_thing.above, "fire") then
			minetest.env:add_node(pointed_thing.above, {name="fire:basic_flame"})
		end
end

--
-- Fire Particles
--

function add_fire(pos)
	local null = {x=0, y=0, z=0}
	pos.y = pos.y+0.19
	minetest.add_particle(pos, null, null, 1.1,
   					1.5, true, "default_fire_particle"..tostring(math.random(1,2)) ..".png")
	pos.y = pos.y +0.01
	minetest.add_particle(pos, null, null, 0.8,
   					1.5, true, "default_fire_particle"..tostring(math.random(1,2)) ..".png")
end

--
-- Bone Meal
--

local n
local n2
local pos

function apple_leave()
	if math.random(0, 10) == 3 then
		return {name = "default:apple"}
	else
		return {name = "default:leaves"}
	end
end

function air_leave()
	if math.random(0, 50) == 3 then
		return {name = "air"}
	else
		return {name = "default:leaves"}
	end
end

function generate_tree(pos, trunk, leaves, typearbre)
	pos.y = pos.y-1
	local nodename = minetest.env:get_node(pos).name
		
	pos.y = pos.y+1
	if not minetest.env:get_node_light(pos) then
		return
	end
	if typearbre == nil or typearbre == 1 then
		node = {name = ""}
		for dy=1,4 do
			pos.y = pos.y+dy
			if minetest.env:get_node(pos).name ~= "air" then
				return
			end
			pos.y = pos.y-dy
		end
		node = {name = trunk}
		for dy=0,4 do
			pos.y = pos.y+dy
			if minetest.env:get_node(pos).name == "air" then
				minetest.env:add_node(pos, node)
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
						if minetest.env:get_node(pos).name == "air" and math.random(1, 5) <= 4 then
							minetest.env:add_node(pos, node)
							if rarity == 1 then
								minetest.env:add_node(pos, apple_leave())
							else
								minetest.env:add_node(pos, air_leave())
							end
						end
					elseif dx == 0 and dz == 0 and dy==4 then
						if minetest.env:get_node(pos).name == "air" and math.random(1, 5) <= 4 then
							minetest.env:add_node(pos, node)
							if rarity == 1 then
								minetest.env:add_node(pos, apple_leave())
							else
								minetest.env:add_node(pos, air_leave())
							end
						end
					elseif math.abs(dx) ~= 2 and math.abs(dz) ~= 2 then
						if minetest.env:get_node(pos).name == "air" then
							minetest.env:add_node(pos, node)
							if rarity == 1 then
								minetest.env:add_node(pos, apple_leave())
							else
								minetest.env:add_node(pos, air_leave())
							end
						end
					else
						if math.abs(dx) ~= 2 or math.abs(dz) ~= 2 then
							if minetest.env:get_node(pos).name == "air" and math.random(1, 5) <= 4 then
								minetest.env:add_node(pos, node)
							if rarity == 1 then
								minetest.env:add_node(pos, apple_leave())
							else
								minetest.env:add_node(pos, air_leave())
							end
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
			if minetest.env:get_node(pos).name ~= "air" then
				return
			end
			pos.y = pos.y-dy
		end
		
		--Cheak for placing big tree
		pos.y = pos.y-1
			for dz=0,1 do
					pos.z = pos.z + dz
					--> 0
					if minetest.env:get_node(pos).name == "default:dirt_with_grass" 
					or  minetest.env:get_node(pos).name == "default:dirt" then else
							return
					end
					pos.x = pos.x+1
					--> 1
					if minetest.env:get_node(pos).name == "default:dirt_with_grass" 
					or  minetest.env:get_node(pos).name == "default:dirt" then else
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
					if math.random(1, 3) == 1 and minetest.env:get_node(pos).name == "air" then
						minetest.env:add_node(pos, {name = "default:vine", param2 = 4})
					end
					pos.x = pos.x+1
					if math.random(1, 3) == 1 and  minetest.env:get_node(pos).name == "air" then
						minetest.env:add_node(pos, {name = "default:vine", param2 = 4})
					end
					pos.x = pos.x-1
					pos.z = pos.z - dz
				elseif dz == 2 then
					pos.z = pos.z + dz
					if math.random(1, 3) == 1 and  minetest.env:get_node(pos).name == "air"then
						minetest.env:add_node(pos, {name = "default:vine", param2 = 5})
					end
					pos.x = pos.x+1
					if math.random(1, 3) == 1 and minetest.env:get_node(pos).name == "air" then
						minetest.env:add_node(pos, {name = "default:vine", param2 = 5})
					end
					pos.x = pos.x-1
					pos.z = pos.z - dz
				else
					pos.z = pos.z + dz
					pos.x = pos.x-1
					if math.random(1, 3) == 1  and minetest.env:get_node(pos).name == "air" then
						minetest.env:add_node(pos, {name = "default:vine", param2 = 2})
					end
					pos.x = pos.x+1
					if minetest.env:get_node(pos).name == "air" then
						minetest.env:add_node(pos, {name = trunk, param2=2})
					end
					pos.x = pos.x+1
					if minetest.env:get_node(pos).name == "air" then
						minetest.env:add_node(pos, {name = trunk, param2=2})
					end
					pos.x = pos.x+1
					if math.random(1, 3) == 1 and minetest.env:get_node(pos).name == "air" then
						minetest.env:add_node(pos, {name = "default:vine", param2 = 3})
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
						if minetest.env:get_node(pos).name == "air" or minetest.env:get_node(pos).name == "default:vine" and math.random(1, 2) == 1 then
							minetest.env:add_node(pos, node)
							end
					elseif dx == 0 and dz == 0 and dy==4 then
						if minetest.env:get_node(pos).name == "air" or minetest.env:get_node(pos).name == "default:vine"  and math.random(1, 5) == 1 then
							minetest.env:add_node(pos, node)
								minetest.env:add_node(pos, air_leave())
						end
					elseif math.abs(dx) ~= 2 and math.abs(dz) ~= 2 then
						if minetest.env:get_node(pos).name == "air" or minetest.env:get_node(pos).name == "default:vine"  then
							minetest.env:add_node(pos, node)
						end
					else
						if math.abs(dx) ~= 2 or math.abs(dz) ~= 2 then
							if minetest.env:get_node(pos).name == "air" or minetest.env:get_node(pos).name == "default:vine" and math.random(1, 3) == 1 then
								minetest.env:add_node(pos, node)
							end
						else
							if math.random(1, 5) == 1 and minetest.env:get_node(pos).name == "air" then
								minetest.env:add_node(pos, node)
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

local plant_tab = {}
local rnd_max = 5
minetest.after(0.5, function()
	plant_tab[0] = "air"
	plant_tab[1] = "default:grass"
	plant_tab[2] = "default:grass"
	plant_tab[3] = "default:grass"
	plant_tab[4] = "default:grass"
	plant_tab[5] = "default:grass"

if minetest.get_modpath("flowers") ~= nil then
	rnd_max = 16
	plant_tab[6] = "flowers:dandelion_yellow"
	plant_tab[7] = "flowers:rose"
	plant_tab[8] = "flowers:oxeye_daisy"
	plant_tab[9] = "flowers:tulip_orange"
	plant_tab[10] = "flowers:tulip_red"
	plant_tab[11] = "flowers:tulip_white"
	plant_tab[12] = "flowers:tulip_pink"
	plant_tab[13] = "flowers:allium"
	plant_tab[14] = "flowers:paeonia"
	plant_tab[15] = "flowers:houstonia"
	plant_tab[16] = "flowers:blue_orchid"
end

end)

function duengen(pointed_thing)
	pos = pointed_thing.under
	n = minetest.env:get_node(pos)
	if n.name == "" then return end
	local stage = ""
	if n.name == "default:sapling" then
		minetest.env:add_node(pos, {name="air"})
		generate_tree(pos, "default:tree", "default:leaves", 1)
	elseif string.find(n.name, "farming:wheat_") ~= nil then
		stage = string.sub(n.name, 15)
		if stage == "3" then
			minetest.env:add_node(pos, {name="farming:wheat"})
		elseif math.random(1,5) < 3 then
			minetest.env:add_node(pos, {name="farming:wheat"})
		else
			minetest.env:add_node(pos, {name="farming:wheat_"..math.random(2,3)})
		end
	elseif string.find(n.name, "farming:potato_") ~= nil then
		stage = tonumber(string.sub(n.name, 16))
		if stage == 1 then
			minetest.env:add_node(pos, {name="farming:potato_"..math.random(stage,2)})
		else
			minetest.env:add_node(pos, {name="farming:potato"})
		end
	elseif string.find(n.name, "farming:carrot_") ~= nil then
		stage = tonumber(string.sub(n.name, 16))
		if stage == 1 then
			minetest.env:add_node(pos, {name="farming:carrot_"..math.random(stage,2)})
		else
			minetest.env:add_node(pos, {name="farming:carrot"})
		end
	elseif string.find(n.name, "farming:pumpkin_") ~= nil then
		stage = tonumber(string.sub(n.name, 17))
		if stage == 1 then
			minetest.env:add_node(pos, {name="farming:pumpkin_"..math.random(stage,2)})
		else
			minetest.env:add_node(pos, {name="farming:pumpkintige_unconnect"})
		end
	elseif string.find(n.name, "farming:melontige_") ~= nil then
		stage = tonumber(string.sub(n.name, 18))
		if stage == 1 then
			minetest.env:add_node(pos, {name="farming:melontige_"..math.random(stage,2)})
		else
			minetest.env:add_node(pos, {name="farming:melontige_unconnect"})
		end
	elseif n.name ~= ""  and n.name == "default:junglesapling" then
		minetest.env:add_node(pos, {name="air"})
		generate_tree(pos, "default:jungletree", "default:jungleleaves", 2)
	elseif n.name ~="" and n.name == "default:reeds" then
		grow_reeds(pos)
	elseif n.name ~="" and n.name == "default:cactus" then
		grow_cactus(pos)
	elseif n.name == "default:dirt_with_grass" then
		for i = -2, 3, 1 do
			for j = -3, 2, 1 do
				pos = pointed_thing.above
				pos = {x=pos.x+i, y=pos.y, z=pos.z+j}
				n = minetest.env:get_node(pos)
				n2 = minetest.env:get_node({x=pos.x, y=pos.y-1, z=pos.z})

				if n.name ~= ""  and n.name == "air" and n2.name == "default:dirt_with_grass" then
					if math.random(0,5) > 3 then
						minetest.env:add_node(pos, {name=plant_tab[math.random(0, rnd_max)]})
					else
						minetest.env:add_node(pos, {name=plant_tab[math.random(0, 5)]})
					end

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
	nodenames = {"default:dirt"},
	neighbors = {"air"},
	interval = 30,
	chance = 20,
	action = function(pos)
	local can_change = 0
	for i=1,4 do
			p = {x=pos.x, y=pos.y+i, z=pos.z}
			n = minetest.env:get_node(p)
			-- On verifie si il y a de l'air
			if (n.name=="air") then
				can_change = can_change + 1
			end
	end
		if can_change > 3 then
			local light = minetest.get_node_light(pos)
			if light or light > 10 then
				minetest.env:add_node(pos, {name="default:dirt_with_grass"})
			end
			
		end
	end,
})



--------------------------
-- Try generate tree   ---
--------------------------
-- Normal tree
minetest.register_abm({
	nodenames = {"default:sapling"},
	neighbors = {"default:dirt", "default:dirt_with_grass"},
	interval = 30,
	chance = 15,
	action = function(pos)
		local light = minetest.get_node_light(pos)
		if light or light > 10 then
		minetest.env:add_node(pos, {name="air"})
		generate_tree(pos, "default:tree", "default:leaves", 1)
		end
	end,
})

-- Jungle Tree
minetest.register_abm({
	nodenames = {"default:junglesapling"},
	neighbors = {"default:dirt", "default:dirt_with_grass"},
	interval = 30,
	chance = 15,
	action = function(pos)
		local light = minetest.get_node_light(pos)
		if light or light > 10 then
			minetest.env:add_node(pos, {name="air"})
			generate_tree(pos, "default:jungletree", "default:jungleleaves", 2)
		end
	end,
})

---------------------
-- Vine generating --
---------------------
minetest.register_abm({
	nodenames = {"default:vine"},
	interval = 80,
	chance = 5,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local newpos = {x=pos.x, y=pos.y-1, z=pos.z}
		local n = minetest.env:get_node(newpos)
		if n.name == "air" then
			walldir = node.param2
			minetest.env:add_node(newpos, {name = "default:vine", param2 = walldir})
		end
	end
})


-- 
-- Snowballs
--

snowball_GRAVITY=9
snowball_VELOCITY=19

--Shoot snowball.
snow_shoot_snowball=function (item, player, pointed_thing)
	local playerpos=player:getpos()
	local obj=minetest.env:add_entity({x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, "default:snowball_entity")
	local dir=player:get_look_dir()
	obj:setvelocity({x=dir.x*snowball_VELOCITY, y=dir.y*snowball_VELOCITY, z=dir.z*snowball_VELOCITY})
	obj:setacceleration({x=dir.x*-3, y=-snowball_GRAVITY, z=dir.z*-3})
	item:take_item()
	return item
end

--The snowball Entity
snowball_ENTITY={
	physical = false,
	timer=0,
	textures = {"default_snowball.png"},
	lastpos={},
	collisionbox = {0,0,0,0,0,0},
}

--Snowball_entity.on_step()--> called when snowball is moving.
snowball_ENTITY.on_step = function(self, dtime)
	self.timer=self.timer+dtime
	local pos = self.object:getpos()
	local node = minetest.env:get_node(pos)

	--Become item when hitting a node.
	if self.lastpos.x~=nil then --If there is no lastpos for some reason.
		if node.name ~= "air" then
			self.object:remove()
		end
	end
	self.lastpos={x=pos.x, y=pos.y, z=pos.z} -- Set lastpos-->Node will be added at last pos outside the node
end

minetest.register_entity("default:snowball_entity", snowball_ENTITY)

-- Global environment step function
function on_step(dtime)
	-- print("on_step")
end
minetest.register_globalstep(on_step)

function on_placenode(p, node)
	--print("on_placenode")
end
minetest.register_on_placenode(on_placenode)

function on_dignode(p, node)
	--print("on_dignode")
end
minetest.register_on_dignode(on_dignode)

function on_punchnode(p, node)
end
minetest.register_on_punchnode(on_punchnode)

-- END

-- Support old code
function default.spawn_falling_node(p, nodename)
	spawn_falling_node(p, nodename)
end

-- Horrible crap to support old code
-- Don't use this and never do what this does, it's completely wrong!
-- (More specifically, the client and the C++ code doesn't get the group)
function default.register_falling_node(nodename, texture)
	minetest.log("error", debug.traceback())
	minetest.log('error', "WARNING: default.register_falling_node is deprecated")
	if minetest.registered_nodes[nodename] then
		minetest.registered_nodes[nodename].groups.falling_node = 1
	end
end

--Sounds


--
-- Sounds
--

function default.node_sound_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="", gain=1.0}
	table.dug = table.dug or
			{name="default_dug_node", gain=0.25}
	table.place = table.place or
			{name="default_place_node_hard", gain=1.0}
	return table
end

function default.node_sound_stone_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="default_hard_footstep", gain=0.5}
	table.dug = table.dug or
			{name="default_hard_footstep", gain=1.0}
	default.node_sound_defaults(table)
	return table
end

function default.node_sound_dirt_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="default_dirt_footstep", gain=1.0}
	table.dug = table.dug or
			{name="default_dirt_footstep", gain=1.5}
	table.place = table.place or
			{name="default_place_node", gain=1.0}
	default.node_sound_defaults(table)
	return table
end

function default.node_sound_sand_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="default_sand_footstep", gain=0.5}
	table.dug = table.dug or
			{name="default_sand_footstep", gain=1.0}
	table.place = table.place or
			{name="default_place_node", gain=1.0}
	default.node_sound_defaults(table)
	return table
end

function default.node_sound_wood_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="default_wood_footstep", gain=0.5}
	table.dug = table.dug or
			{name="default_wood_footstep", gain=1.0}
	default.node_sound_defaults(table)
	return table
end

function default.node_sound_leaves_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="default_grass_footstep", gain=0.35}
	table.dug = table.dug or
			{name="default_grass_footstep", gain=0.85}
	table.dig = table.dig or
			{name="default_dig_crumbly", gain=0.4}
	table.place = table.place or
			{name="default_place_node", gain=1.0}
	default.node_sound_defaults(table)
	return table
end

function default.node_sound_glass_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="default_glass_footstep", gain=0.5}
	table.dug = table.dug or
			{name="default_break_glass", gain=1.0}
	default.node_sound_defaults(table)
	return table
end

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

default.leafdecay_trunk_cache = {}
default.leafdecay_enable_cache = true
-- Spread the load of finding trunks
default.leafdecay_trunk_find_allow_accumulator = 0

minetest.register_globalstep(function(dtime)
	local finds_per_second = 5000
	default.leafdecay_trunk_find_allow_accumulator =
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
		if default.leafdecay_enable_cache then
			p0_hash = minetest.hash_node_position(p0)
			local trunkp = default.leafdecay_trunk_cache[p0_hash]
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
				table.remove(default.leafdecay_trunk_cache, p0_hash)
			end
		end
		if default.leafdecay_trunk_find_allow_accumulator <= 0 then
			return
		end
		default.leafdecay_trunk_find_allow_accumulator =
				default.leafdecay_trunk_find_allow_accumulator - 1
		-- Assume ignore is a trunk, to make the thing work at the border of the active area
		local p1 = minetest.find_node_near(p0, d, {"ignore", "group:tree"})
		if p1 then
			do_preserve = true
			if default.leafdecay_enable_cache then
				--print("caching trunk")
				-- Cache the trunk
				default.leafdecay_trunk_cache[p0_hash] = p1
			end
		end
		if not do_preserve then
			-- Drop stuff other than the node itself
			itemstacks = minetest.get_node_drops(n0.name)
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
			nodeupdate(p0)
		end
	end
})

------------------------
-- Create Color Glass -- 
------------------------
function AddGlass(desc, recipeitem, color)

	minetest.register_node("default:glass"..color, {
		description = desc,
		drawtype = "glasslike",
		tile_images = {"xpanes_pane_glass"..color..".png"},
		inventory_image = minetest.inventorycube("xpanes_pane_glass"..color..".png"),
		paramtype = "light",
		use_texture_alpha = true,
		stack_max = 64,
		groups = {cracky=3,oddly_breakable_by_hand=3},
		sounds = default.node_sound_glass_defaults(),
		drop = "",
	})
	
	minetest.register_craft({
		output = 'default:glass_'..color..'',
		recipe = {
			{'default:glass', 'group:dye,'..recipeitem}
		}
	})
end


