local S = mobs.intllib

mcl_monster_spawner = {}

local default_mob = "mobs_mc:pig"

-- Monster spawner
local spawner_default = default_mob.." 0 15 4 15"

local function get_mob_textures(mob)
	-- FIXME: Ummm … wtf? Why isn't there a textures attribute?
	return minetest.registered_entities[mob].texture_list[1]
end

local function find_doll(pos)
	for  _,obj in ipairs(minetest.env:get_objects_inside_radius(pos, 1)) do
		if not obj:is_player() then
			if obj ~= nil and obj:get_luaentity().name == "mcl_monster_spawner:doll" then
				return obj
			end
		end
	end
	return nil
end

local function set_doll_properties(doll, mob)
	local mobinfo = minetest.registered_entities[mob]
	local prop = {
		mesh = mobinfo.mesh,
		textures = get_mob_textures(mob),
		visual_size = {
			x = mobinfo.visual_size.x * 0.33333,
			y = mobinfo.visual_size.y * 0.33333,
		}
	}
	doll:set_properties(prop)
	doll:get_luaentity()._mob = mob
end

--[[ Public function: Setup the spawner at pos.
This function blindly assumes there's actually a spawner at pos.
If not, then the results are undefined.

* Mob: ID of mob to spawn

All the following arguments are optional!

* MinLight: Minimum light to spawn (default: 0)
* MaxLight: Maximum light to spawn (default: 15)
* MaxMobsInArea: How many mobs are allowed in the area around the spawner (default: 4)
* PlayerDistance: Spawn mobs only if a player is within this distance; 0 to disable (default: 15)
* YOffset: Y offset to spawn mobs; 0 to disable (default: 0)
]]

function mcl_monster_spawner.setup_spawner(pos, Mob, MinLight, MaxLight, MaxMobsInArea, PlayerDistance, YOffset)
	-- Activate monster spawner and disable editing functionality
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

	meta:set_int("active", 1)
	meta:set_string("infotext", "")
	meta:set_string("formspec", "")
	meta:set_string("command", "")

	-- Create doll
	local doll = minetest.add_entity({x=pos.x, y=pos.y-0.3, z=pos.z}, "mcl_monster_spawner:doll")
	set_doll_properties(doll, Mob)
end

minetest.register_node("mcl_monster_spawner:spawner", {
	tiles = {"mob_spawner.png"},
	drawtype = "glasslike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = true,
	description = S("Monster Spawner"),
	_doc_items_longdesc = S("A monster spawner is a block which regularily causes monsters and animals to appear around it."),
	groups = {pickaxey=1, not_in_creative_inventory = 1, material_stone=1},
	is_ground_content = false,
	drop = "",

	on_construct = function(pos)

		local meta = minetest.get_meta(pos)

		-- text entry formspec
		meta:set_string("formspec",
			"field[text;" .. S("Mob MinLight MaxLight MaxMobsInArea PlayerDistance YOffset") .. ";${command}]")
		meta:set_string("infotext", S("Monster spawner not active (Rightclick to enter settings)"))
		meta:set_string("command", spawner_default)
		meta:set_int("active", 0)

	end,

	on_destruct = function(pos)
		local meta = minetest.get_meta(pos)
		if meta:get_int("active") == 1 then
			local obj = find_doll(pos)
			if obj then
				obj:remove()
			end
		end
	end,

	on_right_click = function(pos, placer)

		if minetest.is_protected(pos, placer:get_player_name()) then
			return
		end
	end,

	on_receive_fields = function(pos, formname, fields, sender)

		if not fields.text or fields.text == "" then
			return
		end

		local meta = minetest.get_meta(pos)
		local comm = fields.text:split(" ")
		local name = sender:get_player_name()

		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return
		end

		local mob = comm[1] -- mob to spawn
		local mlig = tonumber(comm[2]) -- min light
		local xlig = tonumber(comm[3]) -- max light
		local num = tonumber(comm[4]) -- total mobs in area
		local pla = tonumber(comm[5]) -- player distance (0 to disable)
		local yof = tonumber(comm[6]) or 0 -- Y offset to spawn mob

		if mob and mob ~= "" and mobs.spawning_mobs[mob] == true
		and num and num >= 0 and num <= 10
		and mlig and mlig >= 0 and mlig <= 15
		and xlig and xlig >= 0 and xlig <= 15
		and pla and pla >=0 and pla <= 20
		and yof and yof > -10 and yof < 10 then

			mcl_monster_spawner.setup_spawner(pos, mob, mlig, xlig, num, pla, yof)
		else
			minetest.chat_send_player(name, S("Mob Spawner settings failed!"))
			minetest.chat_send_player(name,
				S("Syntax: name min_light[0-14] max_light[0-14] max_mobs_in_area[0 to disable] distance[1-20] y_offset[-10 to 10]"))
		end
	end,
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_blast_resistance = 25,
	_mcl_hardness = 5,
})

-- Mob spawner doll (rotating icon inside cage)

local doll_def = {
	hp_max = 1,
	physical = true,
	collisionbox = {0,0,0,0,0,0},
	visual = "mesh",
	makes_footstep_sound = false,
	timer = 0,
	automatic_rotate = math.pi * 2.9,

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
	set_doll_properties(self.object, mob)
	self.object:setvelocity({x=0, y=0, z=0})
	self.object:setacceleration({x=0, y=0, z=0})
	self.object:set_armor_groups({immortal=1})

end

doll_def.on_step = function(self, dtime)
	-- Check if spawner is still present. If not, delete the entity
	self.timer = self.timer + 0.01
	local n = minetest.get_node_or_nil(self.object:getpos())
	if self.timer > 1 then
		if n and n.name and n.name ~= "mcl_monster_spawner:spawner" then
			self.object:remove()
		end
	end
end

doll_def.on_punch = function(self, hitter) end

minetest.register_entity("mcl_monster_spawner:doll", doll_def)



local max_per_block = tonumber(minetest.setting_get("max_objects_per_block") or 99)

-- spawner abm
minetest.register_abm({
	label = "Monster Spawner spawning a monster",
	nodenames = {"mcl_monster_spawner:spawner"},
	interval = 10,
	chance = 4,
	catch_up = false,

	action = function(pos, node, active_object_count, active_object_count_wider)

		-- return if too many entities already
		if active_object_count_wider >= max_per_block then
			return
		end

		-- get meta and command
		local meta = minetest.get_meta(pos)
		local active = meta:get_int("active")
		if active == 0 then
			-- Spawner not active yet, do nothing
			return
		end

		-- get settings
		local mob = meta:get_string("Mob")
		local mlig = meta:get_int("MinLight")
		local xlig = meta:get_int("MaxLight")
		local num = meta:get_int("MaxMobsInArea")
		local pla = meta:get_int("PlayerDistance")
		local yof = meta:get_int("YOffset")

		-- if amount is 0 then do nothing
		if num == 0 then
			return
		end

		-- are we spawning a registered mob?
		if not mobs.spawning_mobs[mob] then
			minetest.log("error", "[mobs] Monster Spawner: Mob doesn't exist: "..mob)
			return
		end

		-- check objects inside 8×8 area around spawner
		local objs = minetest.get_objects_inside_radius(pos, 8)
		local count = 0
		local ent = nil

		-- count mob objects of same type in area
		for k, obj in ipairs(objs) do

			ent = obj:get_luaentity()

			if ent and ent.name and ent.name == mob then
				count = count + 1
			end
		end

		-- is there too many of same type?
		if count >= num then
			return
		end

		-- spawn mob if player detected and in range
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
				return
			end
		end

		-- find air blocks within 8×3×8 nodes of spawner
		local air = minetest.find_nodes_in_area(
			{x = pos.x - 4, y = pos.y - 1 + yof, z = pos.z - 4},
			{x = pos.x + 4, y = pos.y + 1 + yof, z = pos.z + 4},
			{"air"})

		-- spawn up to 4 mobs in random air blocks
		if air then
			for a=1, 4 do
				if #air <= 0 then
					-- We're out of space! Stop spawning
					break
				end
				local air_index = math.random(#air)
				local pos2 = air[air_index]
				local lig = minetest.get_node_light(pos2) or 0

				pos2.y = pos2.y + 0.5

				-- only if light levels are within range
				if lig >= mlig and lig <= xlig then
					minetest.add_entity(pos2, mob)
				end
				table.remove(air, air_index)
			end
		end

	end
})
