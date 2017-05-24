-- FIXME: Rarely, dungoens can overlap and destroy each other

local pr = PseudoRandom(os.time())

-- Get loot for dungeon chests
local get_loot = function()
	local items = mcl_loot.get_multi_loot({
	{
		stacks_min = 1,
		stacks_max = 3,
		items = {
			{ itemstring = "mobs:nametag", weight = 20 },
			{ itemstring = "mcl_mobitems:saddle", weight = 20 },
			{ itemstring = "mcl_jukebox:record_1", weight = 15 },
			{ itemstring = "mcl_jukebox:record_4", weight = 15 },
			-- TODO: Iron Horse Armor
			{ itemstring = "mcl_core:iron_ingot", weight = 15 },
			{ itemstring = "mcl_core:apple_gold", weight = 15 },
			-- TODO: Enchanted Book
			{ itemstring = "mcl_books:book", weight = 10 },
			-- TODO: Gold Horse Armor
			{ itemstring = "mcl_core:gold_ingot", weight = 5 },
			-- TODO: Diamond Horse Armor
			{ itemstring = "mcl_core:diamond", weight = 5 },
			-- TODO: Enchanted Golden Apple
			{ itemstring = "mcl_core:apple_gold", weight = 2 },
		}
	},
	{
		stacks_min = 1,
		stacks_max = 4,
		items = {
			{ itemstring = "mcl_farming:wheat_item", weight = 20, amount_min = 1, amount_max = 4 },
			{ itemstring = "mcl_farming:bread", weight = 20 },
			{ itemstring = "mcl_core:coal_lump", weight = 15, amount_min = 1, amount_max = 4 },
			{ itemstring = "mesecons:redstone", weight = 15, amount_min = 1, amount_max = 4 },
			{ itemstring = "mcl_farming:beetroot_seeds", weight = 10, amount_min = 2, amount_max = 4 },
			{ itemstring = "mcl_farming:melon_seeds", weight = 10, amount_min = 2, amount_max = 4 },
			{ itemstring = "mcl_farming:pumpkin_seeds", weight = 10, amount_min = 2, amount_max = 4 },
			{ itemstring = "mcl_core:iron_ingot", weight = 10, amount_min = 1, amount_max = 4 },
			{ itemstring = "bucket:bucket_empty", weight = 10 },
			{ itemstring = "mcl_core:gold_ingot", weight = 5, amount_min = 1, amount_max = 4 },
		},
	},
	{
		stacks_min = 3,
		stacks_max = 3,
		items = {
			{ itemstring = "mcl_mobitems:bone", weight = 10, amount_min = 1, amount_max = 8 },
			{ itemstring = "mcl_mobitems:gunpowder", weight = 10, amount_min = 1, amount_max = 8 },
			{ itemstring = "mcl_mobitems:rotten_flesh", weight = 10, amount_min = 1, amount_max = 8 },
			{ itemstring = "mcl_mobitems:string", weight = 10, amount_min = 1, amount_max = 8 },
		},
	}}, pr)

	return items
end


-- Buffer for LuaVoxelManip
local lvm_buffer = {}

-- Below the bedrock, generate air/void
minetest.register_on_generated(function(minp, maxp)
	if maxp.y < mcl_vars.mg_overworld_min or minp.y > mcl_vars.mg_overworld_max then
		return
	end

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local data = vm:get_data(lvm_buffer)
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	local lvm_used = false

	local c_air = minetest.get_content_id("air")
	local c_cobble = minetest.get_content_id("mcl_core:cobble")
	local c_mossycobble = minetest.get_content_id("mcl_core:mossycobble")

	-- Remember chest positions to set metadata later
	local chest_posses = {}

	-- Calculate the number of dungeon spawn attempts
	local sizevector = vector.subtract(maxp, minp)
	sizevector = vector.add(sizevector, 1)
	local chunksize = sizevector.x * sizevector.y * sizevector.z

	-- In Minecraft, there 8 dungeon spawn attempts Minecraft chunk (16*256*16 = 65536 blocks).
	-- Minetest chunks don't have this size, so scale the number accordingly.
	local attempts = math.ceil(chunksize / 65536 * 8)

	for a=1, attempts do
		local x, y, z
		local b = 7 -- buffer
		x = math.random(minp.x+b, maxp.x-b)

		local ymin = math.min(mcl_vars.mg_overworld_max, math.max(minp.y, mcl_vars.mg_bedrock_overworld_max) + 7)
		local ymax = math.min(mcl_vars.mg_overworld_max, math.max(maxp.y, mcl_vars.mg_bedrock_overworld_max) - 4)

		y = math.random(ymin, ymax)
		z = math.random(minp.z+b, maxp.z-b)

		local dungeonsizes = {
			{ x=5, y=4, z=5},
			{ x=5, y=4, z=7},
			{ x=7, y=4, z=5},
			{ x=7, y=4, z=7},
		}
		local dim = dungeonsizes[math.random(1, #dungeonsizes)]

		-- Check floor and ceiling: Must be *completely* solid
		local ceilingfloor_ok = true
		for tx = x, x+dim.x do
			for tz = z, z+dim.z do
				local floor = minetest.get_name_from_content_id(data[area:index(tx, y, tz)])
				local ceiling = minetest.get_name_from_content_id(data[area:index(tx, y+dim.y+1, tz)])
				if (not minetest.registered_nodes[floor].walkable) or (not minetest.registered_nodes[ceiling].walkable) then
					ceilingfloor_ok = false
					break
				end
			end
			if not ceilingfloor_ok then break end
		end

		-- Check for air openings (2 stacked air at ground level) in wall positions
		local openings = 0
		if ceilingfloor_ok then

			local walls = {
				{ x, x+dim.x+1, "x", "z", z },
				{ x, x+dim.x+1, "x", "z", z+dim.z+1 },
				{ z+1, z+dim.z, "z", "x", x },
				{ z+1, z+dim.z, "z", "x", x+dim.x+1 },
			}

			for w=1, #walls do
				local wall = walls[w]
				for iter = wall[1], wall[2] do
					local pos = {}
					pos[wall[3]] = iter
					pos[wall[4]] = wall[5]
					pos.y = y+1

					local door1 = area:index(pos.x, pos.y, pos.z)
					pos.y = y+2
					local door2 = area:index(pos.x, pos.y, pos.z)
					local doorname1 = minetest.get_name_from_content_id(data[door1])
					local doorname2 = minetest.get_name_from_content_id(data[door2])
					if doorname1 == "air" and doorname2 == "air" then
						openings = openings + 1
					end
				end
			end

		end

		-- Check conditions. If okay, start generating
		if ceilingfloor_ok and openings >= 1 and openings <= 5 then
			-- Okay! Spawning starts!

			-- First prepare random chest positions.
			-- Chests spawn at wall

			-- We assign each position at the wall a number and each chest gets one of these numbers randomly
			local totalChests = 2
			local totalChestSlots = (dim.x-1) * (dim.z-1)
			local chestSlots = {}
			-- There is a small chance that both chests have the same slot.
			-- In that case, we give a 2nd chance for the 2nd chest to get spawned.
			-- If it failed again, tough luck! We stick with only 1 chest spawned.
			local lastRandom
			local secondChance = true -- second chance is still available
			for i=1, totalChests do
				local r = math.random(1, totalChestSlots)
				if r == lastRandom and secondChance then
					-- Oops! Same slot selected. Try again.
					r = math.random(1, totalChestSlots)
					secondChance = false
				end
				lastRandom = r
				table.insert(chestSlots, r)
			end
			table.sort(chestSlots)
			local currentChest = 1

			-- Ceiling and floor
			local maxx, maxy, maxz = x+dim.x+1, y+dim.y+1, z+dim.z+1
			local chestSlotCounter = 1
			for tx = x, maxx do
				for tz = z, maxz do
					for ty = y, maxy do
						local p_pos = area:index(tx, ty, tz)

						-- Floor
						if ty == y then
							if math.random(1,4) == 1 then
								data[p_pos] = c_cobble
							else
								data[p_pos] = c_mossycobble
							end

						-- Wall or ceiling
						elseif ty == maxy or (ty > y and (tx == x or tx == maxx) or (tz == z or tz == maxz)) then
							data[p_pos] = c_cobble

						-- Room interiour
						else
							local forChest = ty==y+1 and (tx==x+1 or tx==maxx-1 or tz==z+1 or tz==maxz-1)

							-- Place next chest at the wall (if it was its chosen wall slot)
							if forChest and (currentChest < totalChests + 1) and (chestSlots[currentChest] == chestSlotCounter) then
								local p2

								-- Select rotation so the chest faces away from wall
								if (tx==x+1) then p2 = 3
								elseif (tx==maxx-1) then p2 = 1
								elseif (tz==z+1) then p2 = 2
								else p2 = 0 end
								table.insert(chest_posses, {pos={x=tx, y=ty, z=tz}, param2=p2})
								currentChest = currentChest + 1
							else
								data[p_pos] = c_air
							end
							if forChest then
								chestSlotCounter = chestSlotCounter + 1
							end
						end
					end
				end
			end
		end

		lvm_used = true
	end

	if lvm_used then
		vm:set_data(data)
		vm:calc_lighting()
		vm:update_liquids()
		vm:write_to_map()
	end

	for c=1, #chest_posses do
		local cpos = chest_posses[c].pos
		minetest.set_node(cpos, {name="mcl_chests:chest", param2=chest_posses[c].param2})
		local meta = minetest.get_meta(cpos)
		local inv = meta:get_inventory()
		local items = get_loot()
		for i=1, math.min(#items, inv:get_size("main")) do
			inv:set_stack("main", i, ItemStack(items[i]))
		end
	end

end)
