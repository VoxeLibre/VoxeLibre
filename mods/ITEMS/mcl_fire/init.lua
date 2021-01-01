-- Global namespace for functions

mcl_fire = {}

local S = minetest.get_translator("mcl_fire")
local N = function(s) return s end

-- inverse pyramid pattern above lava source, floor 1 of 2:
local lava_fire=
{
	{ x =-1, y = 1, z =-1},
	{ x =-1, y = 1, z = 0},
	{ x =-1, y = 1, z = 1},
	{ x = 0, y = 1, z =-1},
	{ x = 0, y = 1, z = 0},
	{ x = 0, y = 1, z = 1},
	{ x = 1, y = 1, z =-1},
	{ x = 1, y = 1, z = 0},
	{ x = 1, y = 1, z = 1}
}
local alldirs=
{
	{ x =-1, y = 0, z = 0},
	{ x = 1, y = 0, z = 0},
	{ x = 0, y =-1, z = 0},
	{ x = 0, y = 1, z = 0},
	{ x = 0, y = 0, z =-1},
	{ x = 0, y = 0, z = 1}
}

local spawn_smoke = function(pos)
	mcl_particles.add_node_particlespawner(pos, {
		amount = 0.1,
		time = 0,
		minpos = vector.add(pos, { x = -0.45, y = -0.45, z = -0.45 }),
		maxpos = vector.add(pos, { x = 0.45, y = 0.45, z = 0.45 }),
		minvel = { x = 0, y = 0.5, z = 0 },
		maxvel = { x = 0, y = 0.6, z = 0 },
		minexptime = 2.0,
		maxexptime = 2.0,
		minsize = 3.0,
		maxsize = 4.0,
		texture = "mcl_particles_smoke_anim.png^[colorize:#000000:127",
		animation = {
			type = "vertical_frames",
			aspect_w = 8,
			aspect_h = 8,
			length = 2.1,
		},
	}, "high")
end

--
-- Items
--

-- Flame nodes

-- Fire settings

-- When enabled, fire destroys other blocks.
local fire_enabled = minetest.settings:get_bool("enable_fire", true)

-- Enable sound
local flame_sound = minetest.settings:get_bool("flame_sound", true)

-- Help texts
local fire_help, eternal_fire_help
if fire_enabled then
	fire_help = S("Fire is a damaging and destructive but short-lived kind of block. It will destroy and spread towards near flammable blocks, but fire will disappear when there is nothing to burn left. It will be extinguished by nearby water and rain. Fire can be destroyed safely by punching it, but it is hurtful if you stand directly in it. If a fire is started above netherrack or a magma block, it will immediately turn into an eternal fire.")
else
	fire_help = S("Fire is a damaging but non-destructive short-lived kind of block. It will disappear when there is no flammable block around. Fire does not destroy blocks, at least not in this world. It will be extinguished by nearby water and rain. Fire can be destroyed safely by punching it, but it is hurtful if you stand directly in it. If a fire is started above netherrack or a magma block, it will immediately turn into an eternal fire.")
end

if fire_enabled then
	eternal_fire_help = S("Eternal fire is a damaging block that might create more fire. It will create fire around it when flammable blocks are nearby. Eternal fire can be extinguished by punches and nearby water blocks. Other than (normal) fire, eternal fire does not get extinguished on its own and also continues to burn under rain. Punching eternal fire is safe, but it hurts if you stand inside.")
else
	eternal_fire_help = S("Eternal fire is a damaging block. Eternal fire can be extinguished by punches and nearby water blocks. Other than (normal) fire, eternal fire does not get extinguished on its own and also continues to burn under rain. Punching eternal fire is safe, but it hurts if you stand inside.")
end

local fire_death_messages = {
	N("@1 has been cooked crisp."),
	N("@1 felt the burn."),
	N("@1 died in the flames."),
	N("@1 died in a fire."),
}

local fire_timer = function(pos)
	minetest.get_node_timer(pos):start(math.random(3, 7))
end

local spawn_fire = function(pos, age)
	minetest.set_node(pos, {name="mcl_fire:fire", param2 = age})
	minetest.check_single_for_falling({x=pos.x, y=pos.y+1, z=pos.z})
end

minetest.register_node("mcl_fire:fire", {
	description = S("Fire"),
	_doc_items_longdesc = fire_help,
	drawtype = "firelike",
	tiles = {
		{
			name = "fire_basic_flame_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1
			},
		},
	},
	inventory_image = "fire_basic_flame.png",
	paramtype = "light",
	light_source = minetest.LIGHT_MAX,
	walkable = false,
	buildable_to = true,
	sunlight_propagates = true,
	damage_per_second = 1,
	_mcl_node_death_message = fire_death_messages,
	groups = {fire = 1, dig_immediate = 3, not_in_creative_inventory = 1, dig_by_piston=1, destroys_items=1, set_on_fire=8},
	floodable = true,
	on_flood = function(pos, oldnode, newnode)
		if minetest.get_item_group(newnode.name, "water") ~= 0 then
			minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
		end
	end,
	on_timer = function(pos)
		local node = minetest.get_node(pos)
		-- Age is a number from 0 to 15 and is increased every timer step.
		-- "old" fire is more likely to be extinguished
		local age = node.param2
		local flammables = minetest.find_nodes_in_area({x=pos.x-1, y=pos.y-1, z=pos.z-1}, {x=pos.x+1, y=pos.y+4, z=pos.z+1}, {"group:flammable"})
		local below = minetest.get_node({x=pos.x, y=pos.z-1, z=pos.z})
		local below_is_flammable = minetest.get_item_group(below.name, "flammable") > 0
		-- Extinguish fire
		if (not fire_enabled) and (math.random(1,3) == 1) then
			minetest.remove_node(pos)
			return
		end
		if age == 15 and not below_is_flammable then
			minetest.remove_node(pos)
			return
		elseif age > 3 and #flammables == 0 and not below_is_flammable and math.random(1,4) == 1 then
			minetest.remove_node(pos)
			return
		end
		local age_add = 1
		-- If fire spread is disabled, we have to skip the "destructive" code
		if (not fire_enabled) then
			if age + age_add <= 15 then
				node.param2 = age + age_add
				minetest.set_node(pos, node)
			end
			-- Restart timer
			fire_timer(pos)
			return
		end
		-- Spawn fire to nearby flammable nodes
		local is_next_to_flammable = minetest.find_node_near(pos, 2, {"group:flammable"}) ~= nil
		if is_next_to_flammable and math.random(1,2) == 1 then
			-- The fire we spawn copies the age of this fire.
			-- This prevents fire from spreading infinitely far as the fire fire dies off
			-- quicker the further it has spreaded.
			local age_next = math.min(15, age + math.random(0, 1))
			-- Select random type of fire spread
			local burntype = math.random(1,2)
			if burntype == 1 then
				-- Spawn fire in air
				local nodes = minetest.find_nodes_in_area({x=pos.x-1, y=pos.y-1, z=pos.z-1}, {x=pos.x+1, y=pos.y+4, z=pos.z+1}, {"air"})
				while #nodes > 0 do
					local r = math.random(1, #nodes)
					if minetest.find_node_near(nodes[r], 1, {"group:flammable"}) then
						spawn_fire(nodes[r], age_next)
						break
					else
						table.remove(nodes, r)
					end
				end
			else
				-- Burn flammable block
				local nodes = minetest.find_nodes_in_area({x=pos.x-1, y=pos.y-1, z=pos.z-1}, {x=pos.x+1, y=pos.y+4, z=pos.z+1}, {"group:flammable"})
				if #nodes > 0 then
					local r = math.random(1, #nodes)
					local nn = minetest.get_node(nodes[r]).name
					local ndef = minetest.registered_nodes[nn]
					local fgroup = minetest.get_item_group(nn, "flammable")
					if ndef and ndef._on_burn then
						ndef._on_burn(nodes[r])
					elseif fgroup ~= -1 then
						spawn_fire(nodes[r], age_next)
					end
				end
			end
		end
		-- Regular age increase
		if age + age_add <= 15 then
			node.param2 = age + age_add
			minetest.set_node(pos, node)
		end
		-- Restart timer
		fire_timer(pos)
	end,
	drop = "",
	sounds = {},
	-- Turn into eternal fire on special blocks, light Nether portal (if possible), start burning timer
	on_construct = function(pos)
		local bpos = {x=pos.x, y=pos.y-1, z=pos.z}
		local under = minetest.get_node(bpos).name

		local dim = mcl_worlds.pos_to_dimension(bpos)
		if under == "mcl_nether:magma" or under == "mcl_nether:netherrack" or (under == "mcl_core:bedrock" and dim == "end") then
			minetest.swap_node(pos, {name = "mcl_fire:eternal_fire"})
		end

		if minetest.get_modpath("mcl_portals") then
			mcl_portals.light_nether_portal(pos)
		end

		fire_timer(pos)
		spawn_smoke(pos)
	end,
	on_destruct = function(pos)
		mcl_particles.delete_node_particlespawners(pos)
	end,
	_mcl_blast_resistance = 0,
})

minetest.register_node("mcl_fire:eternal_fire", {
	description = S("Eternal Fire"),
	_doc_items_longdesc = eternal_fire_help,
	drawtype = "firelike",
	tiles = {
		{
			name = "fire_basic_flame_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1
			},
		},
	},
	inventory_image = "fire_basic_flame.png",
	paramtype = "light",
	light_source = minetest.LIGHT_MAX,
	walkable = false,
	buildable_to = true,
	sunlight_propagates = true,
	damage_per_second = 1,
	_mcl_node_death_message = fire_death_messages,
	groups = {fire = 1, dig_immediate = 3, not_in_creative_inventory = 1, dig_by_piston = 1, destroys_items = 1, set_on_fire=8},
	floodable = true,
	on_flood = function(pos, oldnode, newnode)
		if minetest.get_item_group(newnode.name, "water") ~= 0 then
			minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
		end
	end,
	on_timer = function(pos)
		if fire_enabled then
			local airs = minetest.find_nodes_in_area({x=pos.x-1, y=pos.y-1, z=pos.z-1}, {x=pos.x+1, y=pos.y+4, z=pos.z+1}, {"air"})
			while #airs > 0 do
				local r = math.random(1, #airs)
				if minetest.find_node_near(airs[r], 1, {"group:flammable"}) then
					local node = minetest.get_node(airs[r])
					local age = node.param2
					local age_next = math.min(15, age + math.random(0, 1))
					spawn_fire(airs[r], age_next)
					break
				else
					table.remove(airs, r)
				end
			end
		end
		-- Restart timer
		fire_timer(pos)
	end,
	-- Start burning timer and light Nether portal (if possible)
	on_construct = function(pos)
		fire_timer(pos)

		if minetest.get_modpath("mcl_portals") then
			mcl_portals.light_nether_portal(pos)
		end
		spawn_smoke(pos)
	end,
	on_destruct = function(pos)
		mcl_particles.delete_node_particlespawners(pos)
	end,
	sounds = {},
	drop = "",
	_mcl_blast_resistance = 0,
})

--
-- Sound
--

if flame_sound then

	local handles = {}
	local timer = 0

	-- Parameters

	local radius = 8 -- Flame node search radius around player
	local cycle = 3 -- Cycle time for sound updates

	-- Update sound for player

	function mcl_fire.update_player_sound(player)
		local player_name = player:get_player_name()
		-- Search for flame nodes in radius around player
		local ppos = player:get_pos()
		local areamin = vector.subtract(ppos, radius)
		local areamax = vector.add(ppos, radius)
		local fpos, num = minetest.find_nodes_in_area(
			areamin,
			areamax,
			{"mcl_fire:fire", "mcl_fire:eternal_fire"}
		)
		-- Total number of flames in radius
		local flames = (num["mcl_fire:fire"] or 0) +
			(num["mcl_fire:eternal_fire"] or 0)
		-- Stop previous sound
		if handles[player_name] then
			minetest.sound_fade(handles[player_name], -0.4, 0.0)
			handles[player_name] = nil
		end
		-- If flames
		if flames > 0 then
			-- Find centre of flame positions
			local fposmid = fpos[1]
			-- If more than 1 flame
			if #fpos > 1 then
				local fposmin = areamax
				local fposmax = areamin
				for i = 1, #fpos do
					local fposi = fpos[i]
					if fposi.x > fposmax.x then
						fposmax.x = fposi.x
					end
					if fposi.y > fposmax.y then
						fposmax.y = fposi.y
					end
					if fposi.z > fposmax.z then
						fposmax.z = fposi.z
					end
					if fposi.x < fposmin.x then
						fposmin.x = fposi.x
					end
					if fposi.y < fposmin.y then
						fposmin.y = fposi.y
					end
					if fposi.z < fposmin.z then
						fposmin.z = fposi.z
					end
				end
				fposmid = vector.divide(vector.add(fposmin, fposmax), 2)
			end
			-- Play sound
			local handle = minetest.sound_play(
				"fire_fire",
				{
					pos = fposmid,
					to_player = player_name,
					gain = math.min(0.06 * (1 + flames * 0.125), 0.18),
					max_hear_distance = 32,
					loop = true, -- In case of lag
				}
			)
			-- Store sound handle for this player
			if handle then
				handles[player_name] = handle
			end
		end
	end

	-- Cycle for updating players sounds

	minetest.register_globalstep(function(dtime)
		timer = timer + dtime
		if timer < cycle then
			return
		end

		timer = 0
		local players = minetest.get_connected_players()
		for n = 1, #players do
			mcl_fire.update_player_sound(players[n])
		end
	end)

	-- Stop sound and clear handle on player leave

	minetest.register_on_leaveplayer(function(player)
		local player_name = player:get_player_name()
		if handles[player_name] then
			minetest.sound_stop(handles[player_name])
			handles[player_name] = nil
		end
	end)
end


--
-- ABMs
--

-- Extinguish all flames quickly with water and such

minetest.register_abm({
	label = "Extinguish fire",
	nodenames = {"mcl_fire:fire", "mcl_fire:eternal_fire"},
	neighbors = {"group:puts_out_fire"},
	interval = 3,
	chance = 1,
	catch_up = false,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.remove_node(pos)
		minetest.sound_play("fire_extinguish_flame",
			{pos = pos, max_hear_distance = 16, gain = 0.15}, true)
	end,
})


-- Enable the following ABMs according to 'enable fire' setting

local function has_flammable(pos)
	local npos, node
	for n, v in ipairs(alldirs) do
		npos = vector.add(pos, v)
		node = minetest.get_node_or_nil(npos)
		if node and node.name and minetest.get_item_group(node.name, "flammable") ~= 0 then
			return npos
		end
	end
	return false
end

if not fire_enabled then

	-- Occasionally remove fire if fire disabled
	-- NOTE: Fire is normally extinguished in timer function
	minetest.register_abm({
		label = "Remove disabled fire",
		nodenames = {"mcl_fire:fire"},
		interval = 10,
		chance = 10,
		catch_up = false,
		action = minetest.remove_node,
	})

else -- Fire enabled

	-- Set fire to air nodes
	minetest.register_abm({
		label = "Ignite fire by lava",
		nodenames = {"group:lava"},
		neighbors = {"air"},
		interval = 7,
		chance = 3,
		catch_up = false,
		action = function(pos)
			local i, dir, target, node, i2, f
			i = math.random(1,9)
			dir = lava_fire[i]
			target = {x=pos.x+dir.x, y=pos.y+dir.y, z=pos.z+dir.z}
			node = minetest.get_node(target)
			if not node or node.name ~= "air" then
				i = ((i + math.random(0,7)) % 9) + 1
				dir = lava_fire[i]
				target = {x=pos.x+dir.x, y=pos.y+dir.y, z=pos.z+dir.z}
				node = minetest.get_node(target)
				if not node or node.name ~= "air" then
					return
				end
			end
			i2 = math.random(1,15)
			if i2 < 10 then
				local dir2, target2, node2
				dir2 = lava_fire[i2]
				target2 = {x=target.x+dir2.x, y=target.y+dir2.y, z=target.z+dir2.z}
				node2 = minetest.get_node(target2)
				if node2 and node2.name == "air" then
					f = has_flammable(target2)
					if f then
						minetest.after(1, spawn_fire, {x=target2.x, y=target2.y, z=target2.z})
						minetest.add_particle({
							pos = vector.new({x=pos.x, y=pos.y+0.5, z=pos.z}),
							velocity={x=f.x-pos.x, y=math.max(f.y-pos.y,0.7), z=f.z-pos.z},
							expirationtime=1, size=1.5, collisiondetection=false,
							glow=minetest.LIGHT_MAX, texture="mcl_particles_flame.png"
						})
						return
					end
				end
			end
			f = has_flammable(target)
			if f then
				minetest.after(1, spawn_fire, {x=target.x, y=target.y, z=target.z})
				minetest.add_particle({
					pos = vector.new({x=pos.x, y=pos.y+0.5, z=pos.z}),
					velocity={x=f.x-pos.x, y=math.max(f.y-pos.y,0.25), z=f.z-pos.z},
					expirationtime=1, size=1, collisiondetection=false,
					glow=minetest.LIGHT_MAX, texture="mcl_particles_flame.png"
				})
			end
		end,
	})

end

-- Set pointed_thing on (normal) fire.
-- * pointed_thing: Pointed thing to ignite
-- * player: Player who sets fire or nil if nobody
-- * allow_on_fire: If false, can't ignite fire on fire (default: true)
mcl_fire.set_fire = function(pointed_thing, player, allow_on_fire)
	local pname
	if player == nil then
		pname = ""
	else
		pname = player:get_player_name()
	end
	local n = minetest.get_node(pointed_thing.above)
	local nu = minetest.get_node(pointed_thing.under)
	if allow_on_fire == false and minetest.get_item_group(nu.name, "fire") ~= 0 then
		return
	end
	if minetest.is_protected(pointed_thing.above, pname) then
		minetest.record_protection_violation(pointed_thing.above, pname)
		return
	end
	if n.name == "air" then
		minetest.add_node(pointed_thing.above, {name="mcl_fire:fire"})
	end
end

minetest.register_lbm({
	label = "Smoke particles from fire",
	name = "mcl_fire:smoke",
	nodenames = {"group:fire"},
	run_at_every_load = true,
	action = function(pos, node)
		spawn_smoke(pos)
	end,
})

minetest.register_alias("mcl_fire:basic_flame", "mcl_fire:fire")
minetest.register_alias("fire:basic_flame", "mcl_fire:fire")
minetest.register_alias("fire:permanent_flame", "mcl_fire:eternal_fire")

dofile(minetest.get_modpath(minetest.get_current_modname()).."/flint_and_steel.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/fire_charge.lua")
