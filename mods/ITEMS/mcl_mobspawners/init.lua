local S = minetest.get_translator(minetest.get_current_modname())

local math = math
local table = table

mcl_mobspawners = {}

local default_mob = "mobs_mc:pig"

-- Mob spawner
--local spawner_default = default_mob.." 0 15 4 15"

local function get_mob_textures(mob)
	local list = minetest.registered_entities[mob].texture_list
	if type(list[1]) == "table" then
		return list[1]
	else
		return list
	end
end

local function find_doll(pos)
	for  _,obj in pairs(minetest.get_objects_inside_radius(pos, 0.5)) do
		if not obj:is_player() then
			if obj and obj:get_luaentity().name == "mcl_mobspawners:doll" then
				return obj
			end
		end
	end
	return nil
end

local function spawn_doll(pos)
	return minetest.add_entity({x=pos.x, y=pos.y-0.3, z=pos.z}, "mcl_mobspawners:doll")
end

-- Manually set the doll sizes for large mobs
-- TODO: Relocate this code to mobs_mc
local doll_size_overrides = {
	["mobs_mc:guardian"] = { x = 0.6, y = 0.6 },
	["mobs_mc:guardian_elder"] = { x = 0.72, y = 0.72 },
	["mobs_mc:rover"] = { x = 0.8, y = 0.8 },
	["mobs_mc:iron_golem"] = { x = 0.9, y = 0.9 },
	["mobs_mc:ghast"] = { x = 1.05, y = 1.05 },
	["mobs_mc:wither"] = { x = 1.2, y = 1.2 },
	["mobs_mc:enderdragon"] = { x = 0.16, y = 0.16 },
	["mobs_mc:witch"] = { x = 0.95, y = 0.95 },
}
local spawn_count_overrides = {
	["mobs_mc:enderdragon"] = 1,
	["mobs_mc:wither"] = 1,
	["mobs_mc:ghast"] = 1,
	["mobs_mc:guardian_elder"] = 1,
	["mobs_mc:guardian"] = 2,
	["mobs_mc:iron_golem"] = 2,
}

local function set_doll_properties(doll, mob)
	local mobinfo = minetest.registered_entities[mob]
	if not mobinfo then return end
	local xs, ys
	if doll_size_overrides[mob] then
		xs = doll_size_overrides[mob].x
		ys = doll_size_overrides[mob].y
	else
		xs = (mobinfo.initial_properties.visual_size.x or 0) * 0.33333
		ys = (mobinfo.initial_properties.visual_size.y or 0) * 0.33333
	end
	local prop = {
		mesh = mobinfo.initial_properties.mesh,
		textures = get_mob_textures(mob),
		visual_size = {
			x = xs,
			y = ys,
		}
	}
	doll:set_properties(prop)
	doll:get_luaentity()._mob = mob
end

local function respawn_doll(pos)
	local meta = minetest.get_meta(pos)
	local mob = meta:get_string("Mob")
	local doll
	if mob and mob ~= "" then
		-- Handle conversion of mob spawners
		local convert_to = (minetest.registered_entities[mob] or {})._convert_to
		if convert_to then
			mob = convert_to
			meta:set_string("Mob", mob)
		end

		doll = find_doll(pos)
		if not doll then
			doll = spawn_doll(pos)
			set_doll_properties(doll, mob)
		end
	end
	return doll
end

--[[ Public function: Setup the spawner at pos.
This function blindly assumes there's actually a spawner at pos.
If not, then the results are undefined.
All the arguments are optional!

* Mob: ID of mob to spawn (default: mobs_mc:pig)
* MinLight: Minimum light to spawn (default: 0)
* MaxLight: Maximum light to spawn (default: 15)
* MaxMobsInArea: How many mobs are allowed in the area around the spawner (default: 4)
* PlayerDistance: Spawn mobs only if a player is within this distance; 0 to disable (default: 15)
* YOffset: Y offset to spawn mobs; 0 to disable (default: 0)
]]

function mcl_mobspawners.setup_spawner(pos, Mob, MinLight, MaxLight, MaxMobsInArea, PlayerDistance, YOffset)
	-- Activate mob spawner and disable editing functionality
	if Mob == nil then Mob = default_mob end
	if MinLight == nil then MinLight = 0 end
	if MaxLight == nil then MaxLight = 15 end
	if MaxMobsInArea == nil then MaxMobsInArea = 4  end
	if PlayerDistance == nil then PlayerDistance = 15 end
	if YOffset == nil then YOffset = 0 end
	local meta = minetest.get_meta(pos)
	meta:set_string("Mob", Mob)
	meta:set_int("MinLight", MinLight)
	meta:set_int("MaxLight", MaxLight)
	meta:set_int("MaxMobsInArea", MaxMobsInArea)
	meta:set_int("PlayerDistance", PlayerDistance)
	meta:set_int("YOffset", YOffset)

	-- Create doll or replace existing doll
	local doll = find_doll(pos)
	if not doll then
		doll = spawn_doll(pos)
	end
	set_doll_properties(doll, Mob)

	-- Start spawning very soon
	local t = minetest.get_node_timer(pos)
	t:start(2)
end

-- Spawn mobs around pos
-- NOTE: The node is timer-based, rather than ABM-based.
local function spawn_mobs(pos, elapsed)

	-- get meta
	local meta = minetest.get_meta(pos)

	-- if amount is 0 then do nothing
	local num = meta:get_int("MaxMobsInArea")
	if num == 0 then
		return
	end

	-- are we spawning a registered mob?
	local mob = meta:get_string("Mob")
	if not mcl_mobs.spawning_mobs[mob] then
		minetest.log("error", "[mcl_mobspawners] Mob Spawner: Mob doesn't exist: "..mob)
		return
	end

	-- check objects inside 8×8 area around spawner
	local objs = minetest.get_objects_inside_radius(pos, 8)
	local count = 0
	local ent

	local timer = minetest.get_node_timer(pos)

	-- spawn mob if player detected and in range
	local pla = meta:get_int("PlayerDistance")
	if pla > 0 then
		local in_range = 0
		local objs = minetest.get_objects_inside_radius(pos, pla)

		for _,oir in pairs(objs) do
			if oir:is_player() then
				in_range = 1
				break
			end
		end

		-- player not found
		if in_range == 0 then
			-- Try again quickly
			timer:start(2)
			return
		end
	end

	--[[ HACK!
	The doll may not stay spawned if the mob spawner is placed far away from
	players, so we will check for its existance periodically when a player is nearby.
	This would happen almost always when the mob spawner is placed by the mapgen.
	This is probably caused by a Luanti bug:
	https://github.com/minetest/minetest/issues/4759
	FIXME: Fix this horrible hack.
	]]
	local doll = find_doll(pos)
	if not doll then
		doll = spawn_doll(pos)
		set_doll_properties(doll, mob)
	end

	-- count mob objects of same type in area
	for k, obj in ipairs(objs) do
		ent = obj:get_luaentity()

		if ent and ent.name and ent.name == mob then
			count = count + 1
		end
	end

	-- Are there too many of same type? then fail
	if count >= num then
		timer:start(math.random(5, 20))
		return
	end

	-- find valid spawn nodes within 8×3×8 nodes of spawner
	local yof = meta:get_int("YOffset")
	local mobinfo = core.registered_entities[mob]
	local spawn_nodes = { "air" }

	if mobinfo and mobinfo.fly_in then
		spawn_nodes = {}
		for nodename, allowed in pairs(mobinfo.fly_in) do
			if allowed then
				table.insert(spawn_nodes, nodename)
			end
		end
	end

	local spawn_positions = core.find_nodes_in_area(
		{x = pos.x - 4, y = pos.y - 1 + yof, z = pos.z - 4},
		{x = pos.x + 4, y = pos.y + 1 + yof, z = pos.z + 4},
		spawn_nodes)

	-- Spawn mobs in random valid nodes. Default max of 4
	if spawn_positions then
		local num_to_spawn = spawn_count_overrides[mob] or 4
		local mlig = meta:get_int("MinLight")
		local xlig = meta:get_int("MaxLight")

		while #spawn_positions > 0 do
			local pos2 = table.remove_random_element(spawn_positions)
			if not pos2 then
				break
			end

			-- only if light levels are within range
			local lig = core.get_node_light(pos2) or 0
			if lig >= mlig and lig <= xlig then
				if mcl_mobs.spawn(pos2, mob) then
					num_to_spawn = num_to_spawn - 1
					if num_to_spawn == 0 then break end
				end
			end
		end
	end

	-- Spawn attempt done. Next spawn attempt much later
	timer:start(math.random() * 29.95 + 10)
end

-- The mob spawner node.
-- PLACEMENT INSTRUCTIONS:
-- If this node is placed by a player, minetest.item_place, etc. default settings are applied
-- automatially.
-- IF this node is placed by ANY other method (e.g. minetest.set_node, LuaVoxelManip), you
-- MUST call mcl_mobspawners.setup_spawner right after the spawner has been placed.
minetest.register_node("mcl_mobspawners:spawner", {
	tiles = {"mob_spawner.png"},
	drawtype = "glasslike",
	paramtype = "light",
	walkable = true,
	description = S("Mob Spawner"),
	_tt_help = S("Makes mobs appear"),
	_doc_items_longdesc = S("A mob spawner regularily causes mobs to appear around it while a player is nearby. Some mob spawners are disabled while in light."),
	_doc_items_usagehelp = S("If you have a spawn egg, you can use it to change the mob to spawn. Just place the item on the mob spawner. Player-set mob spawners always spawn mobs regardless of the light level."),
	groups = {pickaxey=1, material_stone=1, deco_block=1},
	is_ground_content = false,
	drop = "",

	-- If placed by player, setup spawner with default settings
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(pointed_thing.under)
		if placer and not placer:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
			end
		end

		local name = placer:get_player_name()
		local privs = minetest.get_player_privs(name)
		if not privs.maphack then
			minetest.chat_send_player(name, "Placement denied. You need the “maphack” privilege to place mob spawners.")
			return itemstack
		end
		local node_under = minetest.get_node(pointed_thing.under)
		local new_itemstack, success = minetest.item_place(itemstack, placer, pointed_thing)
		if success then
			local placepos
			local def = minetest.registered_nodes[node_under.name]
			if def and def.buildable_to then
				placepos = pointed_thing.under
			else
				placepos = pointed_thing.above
			end
			mcl_mobspawners.setup_spawner(placepos)
		end
		return new_itemstack
	end,

	on_destruct = function(pos)
		-- Remove doll (if any)
		local obj = find_doll(pos)
		if obj then
			obj:remove()
		end
		if not minetest.is_creative_enabled("") then
			mcl_experience.throw_xp(pos, math.random(15, 43))
		end
	end,

	on_punch = function(pos)
		respawn_doll(pos)
	end,

	on_timer = spawn_mobs,

	sounds = mcl_sounds.node_sound_metal_defaults(),

	_mcl_blast_resistance = 5,
	_mcl_hardness = 5,
})

-- Mob spawner doll (rotating icon inside cage)

local doll_def = {
	initial_properties = {
		hp_max = 1,
		physical = false,
		pointable = false,
		visual = "mesh",
		makes_footstep_sound = false,
		automatic_rotate = math.pi * 2.9,
	},
	timer = 0,

	_mob = default_mob, -- name of the mob this doll represents
}

doll_def.get_staticdata = function(self)
	return self._mob
end

doll_def.on_activate = function(self, staticdata, dtime_s)
	local mob = staticdata
	if mob == "" or mob == nil then
		mob = default_mob
	end

	-- Handle conversion of mob spawners
	local convert_to = (minetest.registered_entities[mob] or {})._convert_to
	if convert_to then mob = convert_to end

	set_doll_properties(self.object, mob)
	self.object:set_velocity({x=0, y=0, z=0})
	self.object:set_acceleration({x=0, y=0, z=0})
	self.object:set_armor_groups({immortal=1})
end

doll_def.on_step = function(self, dtime)
	-- Check if spawner is still present. If not, delete the entity
	self.timer = self.timer + dtime
	local n = minetest.get_node_or_nil(self.object:get_pos())
	if self.timer > 1 then
		if n and n.name and n.name ~= "mcl_mobspawners:spawner" then
			self.object:remove()
		end
	end
end

doll_def.on_punch = function(self, hitter) end

minetest.register_entity("mcl_mobspawners:doll", doll_def)

-- FIXME: Doll can get destroyed by /clearobjects
minetest.register_lbm({
	label = "Respawn mob spawner dolls",
	name = "mcl_mobspawners:respawn_entities",
	nodenames = { "mcl_mobspawners:spawner" },
	run_at_every_load = true,
	action = function(pos, node)
		respawn_doll(pos)
	end,
})

minetest.register_on_mods_loaded(function()
	for name,mobinfo in pairs(minetest.registered_entities) do
		if mobinfo.is_mob and not ( mobinfo.initial_properties.visual_size or mobinfo._convert_to ) then
			minetest.log("warning", "Definition for "..tostring(name).." is missing field 'visual_size', mob spawners will not work properly")
		end
	end
end)
