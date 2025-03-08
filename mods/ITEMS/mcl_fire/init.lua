-- Global namespace for functions

mcl_fire = {}
local DEBUG = false

---@class core.NodeDef
---@field _on_burn? fun(pos : vector.Vector)
---@field _on_ignite? fun(user : core.PlayerObjectRef, pointed_thing : core.PointedThing) : boolean|nil

local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local S = core.get_translator(modname)
local has_mcl_portals = core.get_modpath("mcl_portals")

-- Localized functions
local set_node = core.set_node
local get_node = core.get_node
local add_node = core.add_node
local swap_node = core.swap_node
local get_node_or_nil = core.get_node_or_nil
local find_nodes_in_area = core.find_nodes_in_area
local get_item_group = core.get_item_group
local get_connected_players = core.get_connected_players
local vector_new = vector.new
local vector_offset = vector.offset
local vector_zero = vector.zero
local min = math.min
local random = math.random

local log_10 = math.log(10)

local difficulty_levels = {
	{
		-- Spread
		K1 = math.log(0.0075) / log_10 / 255,

		-- Extinguish parameters
		-- p(0) = 2.5%, p(255) = 100%
		C2 = -1.3010, -- log10(1/20)
		K2 = -5.102e-3, -- log10(1/20) / 255,

		age_min = 0,
		age_max = 5,
		humidity_factor = 1/10,

		burn_age_min = 0,
		burn_age_max = 2,
		burn_humidity_factor = 1/25,
	}, {
		-- Spread
		K1 = math.log(0.0005) / log_10 / 255,

		-- Extinguish parameters
		-- p(0) = 1%, p(255) = 5%
		C2 = -2, -- log10(0.01)
		K2 = 2.741e-3, -- (log10(0.05) + 2) / 255

		age_min = 0,
		age_max = 2,
		humidity_factor = 1/10,

		burn_age_min = 0,
		burn_age_max = 1,
		burn_humidity_factor = 1/50,
	},
}
local consts = difficulty_levels[2]

local adjacents = {
	vector_new(-1,  0,  0),
	vector_new( 1,  0,  0),
	vector_new( 0,  1,  0),
	vector_new( 0, -1,  0),
	vector_new( 0,  0, -1),
	vector_new( 0,  0,  1),
}

table.shuffle(adjacents)

local function has_flammable(pos)
	local p = vector_zero() -- Only allocate one new table
	for _,v in pairs(adjacents) do
		p.x, p.y, p.z = pos.x + v.x, pos.y + v.y, pos.z + v.z
		local n = get_node_or_nil(p)
		if n and get_item_group(n.name, "flammable") ~= 0 then
			return p
		end
	end
end

local smoke_pdef = {
	amount = 0.009,
	maxexptime = 4.0,
	minvel = { x = -0.1, y = 0.3, z = -0.1 },
	maxvel = { x = 0.1, y = 1.6, z = 0.1 },
	minsize = 4.0,
	maxsize = 4.5,
	minrelpos = { x = -0.45, y = -0.45, z = -0.45 },
	maxrelpos = { x = 0.45, y = 0.45, z = 0.45 },
}

--
-- Items
--

-- Flame nodes

-- Fire settings

-- When enabled, fire destroys other blocks.
local fire_enabled = core.settings:get_bool("enable_fire", true)

-- Enable sound
local flame_sound = core.settings:get_bool("flame_sound", true)

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


---@param pos vector.Vector
---@param age integer
---@param force? boolean
local function spawn_fire(pos, age, force)
	if DEBUG and age <= 1 then
		core.log("warning","new flash point at "..vector.to_string(pos).." age="..tostring(age)..",backtrace = "..debug.traceback())
	end
	age = min(age, 255)

	local node = get_node(pos)
	local node_is_flammable = get_item_group(node.name, "flammable")

	-- Limit fire spread
	local probability_age = age
	if node_is_flammable then
		probability_age = probability_age * 0.80
	end
	local probability = 10 ^ (consts.K1 * probability_age)
	if not force and random() >= probability then
		return
	end

	-- Node catches fire
	set_node(pos, {name="mcl_fire:fire", param2 = age})
	core.check_single_for_falling(vector_offset(pos,0,1,0))
end

core.register_node("mcl_fire:fire", {
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
	light_source = core.LIGHT_MAX,
	walkable = false,
	buildable_to = true,
	sunlight_propagates = true,
	damage_per_second = 1,
	groups = {fire = 1, dig_immediate = 3, not_in_creative_inventory = 1, dig_by_piston=1, destroys_items=1, set_on_fire=8},
	floodable = true,
	on_flood = function(pos, _, newnode)
		if get_item_group(newnode.name, "water") ~= 0 then
			core.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
		end
	end,
	drop = "",
	sounds = {},
	-- Turn into eternal fire on special blocks, light Nether portal (if possible), start burning timer
	on_construct = function(pos)
		local bpos = {x=pos.x, y=pos.y-1, z=pos.z}
		local under = get_node(bpos).name

		local dim = mcl_worlds.pos_to_dimension(bpos)
		if under == "mcl_nether:magma" or under == "mcl_nether:netherrack" or (under == "mcl_core:bedrock" and dim == "end") then
			swap_node(pos, {name = "mcl_fire:eternal_fire"})
		end

		if has_mcl_portals then
			mcl_portals.light_nether_portal(pos)
		end

		mcl_particles.spawn_smoke(pos, "fire", smoke_pdef)
	end,
	on_destruct = function(pos)
		mcl_particles.delete_node_particlespawners(pos)
	end,
	_mcl_blast_resistance = 0,
})

core.register_node("mcl_fire:eternal_fire", {
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
	light_source = core.LIGHT_MAX,
	walkable = false,
	buildable_to = true,
	sunlight_propagates = true,
	damage_per_second = 1,
	groups = {fire = 1, dig_immediate = 3, not_in_creative_inventory = 1, dig_by_piston = 1, destroys_items = 1, set_on_fire=8},
	floodable = true,
	on_flood = function(pos, _, newnode)
		if get_item_group(newnode.name, "water") ~= 0 then
			core.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
		end
	end,
	-- Start burning timer and light Nether portal (if possible)
	on_construct = function(pos)
		if has_mcl_portals then --Calling directly core.get_modpath consumes 4x more compute time
			mcl_portals.light_nether_portal(pos)
		end
		mcl_particles.spawn_smoke(pos, "fire", smoke_pdef)
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
		local areamin = vector_offset(ppos, -radius, -radius, -radius)
		local areamax = vector_offset(ppos,  radius,  radius,  radius)
		local fpos, num = find_nodes_in_area(
			areamin, areamax,
			{"mcl_fire:fire", "mcl_fire:eternal_fire"}
		)
		-- Total number of flames in radius
		local flames = (num["mcl_fire:fire"] or 0) +
			(num["mcl_fire:eternal_fire"] or 0)
		-- Stop previous sound
		if handles[player_name] then
			core.sound_fade(handles[player_name], -0.4, 0.0)
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
				fposmid = (fposmin + fposmax) / 2
			end

			-- Play sound
			local handle = core.sound_play(
				"fire_fire",
				{
					pos = fposmid,
					to_player = player_name,
					gain = min(0.06 * (1 + flames * 0.125), 0.18),
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
	core.register_globalstep(function(dtime)
		timer = timer + dtime
		if timer < cycle then
			return
		end

		timer = 0
		for _,player in ipairs(get_connected_players()) do
			mcl_fire.update_player_sound(player)
		end
	end)

	-- Stop sound and clear handle on player leave
	core.register_on_leaveplayer(function(player)
		local player_name = player:get_player_name()
		if handles[player_name] then
			core.sound_stop(handles[player_name])
			handles[player_name] = nil
		end
	end)
end

-- [...]a fire that is not adjacent to any flammable block does not spread, even to another flammable block within the normal range.
-- https://minecraft.fandom.com/wiki/Fire#Spread

local function check_aircube(p1,p2)
	local nds=core.find_nodes_in_area(p1,p2,{"air"})
	table.shuffle(nds)
	for _,v in pairs(nds) do
		if has_flammable(v) then return v end
	end
end

-- [...] a fire block can turn any air block that is adjacent to a flammable block into a fire block. This can happen at a distance of up to one block downward, one block sideways (including diagonals), and four blocks upward of the original fire block (not the block the fire is on/next to).
local function get_ignitable(pos)
	return check_aircube(vector_offset(pos, -1, -1, -1), vector_offset(pos, 1, 4, 1))
end
-- Fire spreads from a still lava block similarly: any air block one above and up to one block sideways (including diagonals) or two above and two blocks sideways (including diagonals) that is adjacent to a flammable block may be turned into a fire block.
local function get_ignitable_by_lava(pos)
	return check_aircube(
		vector_offset(pos, -1, 1, -1), vector_offset(pos, 1, 1, 1)
	) or check_aircube(
		vector_offset(pos, -2, 2, -2), vector_offset(pos, 2, 2, 2)
	)
end

--
-- ABMs
--

-- Extinguish all flames quickly with water and such
core.register_abm({
	label = "Extinguish fire",
	nodenames = {"mcl_fire:fire", "mcl_fire:eternal_fire"},
	neighbors = {"group:puts_out_fire"},
	interval = 3,
	chance = 1,
	catch_up = false,
	action = function(pos)
		core.remove_node(pos)
		core.sound_play("fire_extinguish_flame",
			{pos = pos, max_hear_distance = 16, gain = 0.15}, true)
	end,
})

-- Enable the following ABMs according to 'enable fire' setting
if not fire_enabled then

	-- Occasionally remove fire if fire disabled
	-- NOTE: Fire is normally extinguished in timer function
	core.register_abm({
		label = "Remove disabled fire",
		nodenames = {"mcl_fire:fire"},
		interval = 10,
		chance = 10,
		catch_up = false,
		action = core.remove_node,
	})
else -- Fire enabled

	-- Fire Spread
	core.register_abm({
		label = "Ignite flame",
		nodenames ={"mcl_fire:fire","mcl_fire:eternal_fire"},
		interval = 1,
		chance = 5,
		catch_up = false,
		action = function(pos)
			local node = get_node(pos)
			local age = node.param2

			-- Always age the source fire
			local humidity_factor = consts.humidity_factor * core.get_humidity(pos)
			age = min(255, age + random(consts.age_min, humidity_factor + consts.age_max))
			node.param2 = age

			if node.name ~= "mcl_fire:eternal_fire" then
				-- Randomly extinguish fires with increasing probability the older they are
				local extinguish_probability = 10 ^ (consts.K2 * age + consts.C2)
				if random() <= extinguish_probability then
					node.name = "air"
					node.param2 = 0
				-- Extinguish fires not adjacent to flammable materials
				elseif not has_flammable(pos) then
					node.name = "air"
					node.param2 = 0
				end
			end
			set_node(pos, node)
			if node.name == "air" then return end

			-- Fire spread
			if age == 255 then return end
			local p = get_ignitable(pos)
			if p then
				-- Spawn new fire with an age based on this node's age
				spawn_fire(p, min(255, age + random(humidity_factor) + 1))
				table.shuffle(adjacents)
			end
		end
	})

	--lava fire spread
	core.register_abm({
		label = "Ignite fire by lava",
		nodenames = {"mcl_core:lava_source","mcl_nether:nether_lava_source"},
		neighbors = {"group:flammable"},
		interval = 15,
		chance = 9,
		catch_up = false,
		action = function(pos)
			local p=get_ignitable_by_lava(pos)
			if p then
				spawn_fire(p, 0)
			end
		end,
	})

	-- Remove flammable nodes around basic flame
	core.register_abm({
		label = "Remove flammable nodes",
		nodenames = {"mcl_fire:fire","mcl_fire:eternal_fire"},
		neighbors = {"group:flammable"},
		interval = 1,
		chance = 6,
		catch_up = false,
		action = function(pos)
			local p = has_flammable(pos)
			if not p then return end

			local def = core.registered_nodes[get_node(p).name]
			local fgroup = def and def.groups.flammable or 0

			if def and def._on_burn then
				def._on_burn(p)
			elseif fgroup ~= -1 then
				local source_node = get_node(pos)
				local age = source_node.param2

				local humidity_factor = consts.burn_humidity_factor * core.get_humidity(pos)
				age = min(255, age + random(consts.burn_age_min, humidity_factor + consts.burn_age_max))
				if age == 255 then return end

				spawn_fire(p, age + 1, true)
				core.check_for_falling(p)

				if source_node.name == "mcl_fire:fire" then
					-- Always age the source fire
					age = min(255, age + random(consts.age_min, consts.age_max + humidity_factor))
					source_node.param2 = age
					set_node(pos, source_node)
				end
			end
		end
	})
end

-- Set pointed_thing on (normal) fire.
-- * pointed_thing: Pointed thing to ignite
-- * player: Player who sets fire or nil if nobody
-- * allow_on_fire: If false, can't ignite fire on fire (default: true)
function mcl_fire.set_fire(pointed_thing, player, allow_on_fire)
	if mcl_util.check_position_protection(pointed_thing.above, player) then return end

	if allow_on_fire == false then
		local n_pointed = get_node(pointed_thing.under)
		if get_item_group(n_pointed.name, "fire") ~= 0 then return end
	end

	local n_fire_pos = get_node(pointed_thing.above)
	if n_fire_pos.name ~= "air" then
		return
	end

	local n_below = get_node(vector_offset(pointed_thing.above, 0, -1, 0))
	if core.get_item_group(n_below.name, "water") ~= 0 then
		return
	end

	return add_node(pointed_thing.above, {name="mcl_fire:fire"})
end

core.register_lbm({
	label = "Smoke particles from fire",
	name = "mcl_fire:smoke",
	nodenames = {"group:fire"},
	run_at_every_load = true,
	action = function(pos)
		mcl_particles.spawn_smoke(pos, "fire", smoke_pdef)
	end,
})

core.register_alias("mcl_fire:basic_flame", "mcl_fire:fire")
core.register_alias("fire:basic_flame", "mcl_fire:fire")
core.register_alias("fire:permanent_flame", "mcl_fire:eternal_fire")

dofile(modpath..DIR_DELIM.."flint_and_steel.lua")
dofile(modpath..DIR_DELIM.."fire_charge.lua")
