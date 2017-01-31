--[[
	PlayerPlus by TenPlus1
]]

playerplus = {}

-- get node but use fallback for nil or unknown
local function node_ok(pos, fallback)

	fallback = fallback or "air"

	local node = minetest.get_node_or_nil(pos)

	if not node then
		return fallback
	end

	if minetest.registered_nodes[node.name] then
		return node.name
	end

	return fallback
end

local armor_mod = minetest.get_modpath("3d_armor")
local def = {}
local time = 0

minetest.register_globalstep(function(dtime)

	time = time + dtime

	-- every 0.5 seconds
	if time < 0.5 then
		return
	end

	-- reset time for next check
	-- FIXME: Make sure a regular check interval applies
	time = 0

	-- check players
	for _,player in pairs(minetest.get_connected_players()) do

		-- who am I?
		local name = player:get_player_name()

		-- where am I?
		local pos = player:getpos()

		-- what is around me?
		pos.y = pos.y - 0.1 -- standing on
		playerplus[name].nod_stand = node_ok(pos)

		pos.y = pos.y + 1.5 -- head level
		playerplus[name].nod_head = node_ok(pos)
	
		pos.y = pos.y - 1.2 -- feet level
		playerplus[name].nod_feet = node_ok(pos)

		pos.y = pos.y - 0.2 -- reset pos

		-- set defaults
		def.speed = 1
		def.jump = 1
		def.gravity = 1

		-- is 3d_armor mod active? if so make armor physics default
		if armor_mod and armor and armor.def then
			-- get player physics from armor
			def.speed = armor.def[name].speed or 1
			def.jump = armor.def[name].jump or 1
			def.gravity = armor.def[name].gravity or 1
		end

		-- standing on soul sand? if so walk slower
--		if playerplus[name].nod_stand == "mcl_nether:soul_sand" then
			-- TODO: Fix walk speed
--			def.speed = def.speed - 0.4
--		end

		-- set player physics
		-- TODO: Resolve conflict
		player:set_physics_override(def.speed, def.jump, def.gravity)

		-- Is player suffocating inside node? (Only for solid full cube type nodes without damage
		-- and without group disable_suffocation=1.)
		local ndef = minetest.registered_nodes[playerplus[name].nod_head]

		if (ndef.walkable == nil or ndef.walkable == true)
		and (ndef.drowning == nil or ndef.drowning == 0)
		and (ndef.damage_per_second == nil or ndef.damage_per_second <= 0)
		and (ndef.collision_box == nil or ndef.collision_box.type == "regular")
		and (ndef.node_box == nil or ndef.node_box.type == "regular")
		and (ndef.groups.disable_suffocation ~= 1)
		-- Check privilege, too
		and (not minetest.check_player_privs(name, {noclip = true})) then
			if player:get_hp() > 0 then
				player:set_hp(player:get_hp() - 1)
			end
		end

		-- am I near a cactus?
		local near = minetest.find_node_near(pos, 1, "mcl_core:cactus")

		if near then
			-- am I touching the cactus? if so it hurts
			for _,object in pairs(minetest.get_objects_inside_radius(near, 1.1)) do
				if object:get_hp() > 0 then
					object:set_hp(object:get_hp() - 1)
				end
			end

		end

	end

end)

-- set to blank on join (for 3rd party mods)
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()

	playerplus[name] = {}
	playerplus[name].nod_head = ""
	playerplus[name].nod_feet = ""
	playerplus[name].nod_stand = ""
end)

-- clear when player leaves
minetest.register_on_leaveplayer(function(player)

	playerplus[ player:get_player_name() ] = nil
end)
