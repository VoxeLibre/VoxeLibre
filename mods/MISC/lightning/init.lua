
--[[

Copyright (C) 2016 - Auke Kok <sofar@foo-projects.org>

"lightning" is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as
published by the Free Software Foundation; either version 2.1
of the license, or (at your option) any later version.

--]]

lightning = {}

lightning.interval_low = 17
lightning.interval_high = 503
lightning.range_h = 100
lightning.range_v = 50
lightning.size = 100
-- disable this to stop lightning mod from striking
lightning.auto = true

local rng = PcgRandom(32321123312123)

local ps = {}
local ttl = 1

local revertsky = function()
	if ttl == 0 then
		return
	end
	ttl = ttl - 1
	if ttl > 0 then
		return
	end

	for key, entry in pairs(ps) do
		local sky = entry.sky
		entry.p:set_sky(sky.bgcolor, sky.type, sky.textures)
	end

	ps = {}
end

minetest.register_globalstep(revertsky)

-- select a random strike point, midpoint
local function choose_pos(pos)
	if not pos then
		local playerlist = minetest.get_connected_players()
		local playercount = table.getn(playerlist)

		-- nobody on
		if playercount == 0 then
			return nil, nil
		end

		local r = rng:next(1, playercount)
		local randomplayer = playerlist[r]
		pos = randomplayer:getpos()

		-- avoid striking underground
		if pos.y < -20 then
			return nil, nil
		end

		pos.x = math.floor(pos.x - (lightning.range_h / 2) + rng:next(1, lightning.range_h))
		pos.y = pos.y + (lightning.range_v / 2)
		pos.z = math.floor(pos.z - (lightning.range_h / 2) + rng:next(1, lightning.range_h))
	end

	local b, pos2 = minetest.line_of_sight(pos, {x = pos.x, y = pos.y - lightning.range_v, z = pos.z}, 1)

	-- nothing but air found
	if b then
		return nil, nil
	end

	local n = minetest.get_node({x = pos2.x, y = pos2.y - 1/2, z = pos2.z})
	if n.name == "air" or n.name == "ignore" then
		return nil, nil
	end

	return pos, pos2
end

-- lightning strike API
-- * pos: optional, if not given a random pos will be chosen
-- * returns: bool - success if a strike happened
lightning.strike = function(pos)
	if lightning.auto then
		minetest.after(rng:next(lightning.interval_low, lightning.interval_high), lightning.strike)
	end

	local pos2
	pos, pos2 = choose_pos(pos)

	if not pos then
		return false
	end

	minetest.add_particlespawner({
		amount = 1,
		time = 0.2,
		-- make it hit the top of a block exactly with the bottom
		minpos = {x = pos2.x, y = pos2.y + (lightning.size / 2) + 1/2, z = pos2.z },
		maxpos = {x = pos2.x, y = pos2.y + (lightning.size / 2) + 1/2, z = pos2.z },
		minvel = {x = 0, y = 0, z = 0},
		maxvel = {x = 0, y = 0, z = 0},
		minacc = {x = 0, y = 0, z = 0},
		maxacc = {x = 0, y = 0, z = 0},
		minexptime = 0.2,
		maxexptime = 0.2,
		minsize = lightning.size * 10,
		maxsize = lightning.size * 10,
		collisiondetection = true,
		vertical = true,
		-- to make it appear hitting the node that will get set on fire, make sure
		-- to make the texture lightning bolt hit exactly in the middle of the
		-- texture (e.g. 127/128 on a 256x wide texture)
		texture = "lightning_lightning_" .. rng:next(1,3) .. ".png",
	})

	minetest.sound_play({ pos = pos, name = "lightning_thunder", gain = 10, max_hear_distance = 500 })

	-- damage nearby objects, player or not
	for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 5)) do
		-- nil as param#1 is supposed to work, but core can't handle it.
		obj:punch(obj, 1.0, {full_punch_interval = 1.0, damage_groups = {fleshy=8}}, nil)
	end

	local playerlist = minetest.get_connected_players()
	for i = 1, #playerlist do
		local player = playerlist[i]
		local sky = {}

		sky.bgcolor, sky.type, sky.textures = player:get_sky()

		local name = player:get_player_name()
		if ps[name] == nil then
			ps[name] = {p = player, sky = sky}
			player:set_sky(0xffffff, "plain", {})
		end
	end

	-- trigger revert of skybox
	ttl = 5

	-- set the air node above it on fire
	pos2.y = pos2.y + 1/2
	if minetest.get_item_group(minetest.get_node({x = pos2.x, y = pos2.y - 1, z = pos2.z}).name, "liquid") < 1 then
		if minetest.get_node(pos2).name == "air" then
			-- Rarely cause a fire
			-- TODO: Always cause a fire, but the rain should put out fires then
			if rng:next(1, 100) == 1 then
				minetest.set_node(pos2, {name = "mcl_fire:fire"})
			end
		end
	end

end

-- if other mods disable auto lightning during initialization, don't trigger the first lightning.
minetest.after(5, function(dtime)
	if lightning.auto then
		minetest.after(rng:next(lightning.interval_low,
			lightning.interval_high), lightning.strike)
	end
end)
