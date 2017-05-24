-- FIXME: Rarely, dungoens can overlap and destroy each other

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

			if openings > 0 then
				--minetest.log("error", minetest.pos_to_string({x=x,y=y,z=z}).."; openings: "..openings)
			end
		end

		-- Check conditions. If okay, start generating

		if ceilingfloor_ok and openings >= 1 and openings <= 5 then
			-- Ceiling and floor
			local maxx, maxy, maxz = x+dim.x+1, y+dim.y+1, z+dim.z+1
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

							data[p_pos] = c_air
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

end)
