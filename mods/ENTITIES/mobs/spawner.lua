local S = mobs.intllib

local default_mob = "mobs_mc:chicken"

-- mob spawner
local spawner_default = default_mob.." 10 15 3 0"

local function get_mob_textures(mob)
	-- FIXME: Ummm … wtf? Why isn't there a textures attribute?
	return minetest.registered_entities[mob].texture_list[1]
end

-- Find doll entity at pos
local function find_doll(pos)
	for  _,obj in ipairs(minetest.env:get_objects_inside_radius(pos, 1)) do
		if not obj:is_player() then
			if obj ~= nil and obj:get_luaentity().name == "mobs:spawner_mob_doll" then
				return obj
			end
		end
	end
	return nil
end

local function set_doll_properties(doll, mob)
	local mobinfo = minetest.registered_entities[mob]
	local prop = {
		_mob = mob,
		mesh = mobinfo.mesh,
		textures = get_mob_textures(mob),
		visual_size = {
			x = mobinfo.visual_size.x * 0.5,
			y = mobinfo.visual_size.y * 0.5,
		}
	}
	doll:set_properties(prop)
end

minetest.register_node("mobs:spawner", {
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
			"field[text;" .. S("Mob MinLight MaxLight Amount PlayerDist") .. ";${command}]")
		meta:set_string("infotext", S("Spawner Not Active (enter settings)"))
		meta:set_string("command", spawner_default)

	end,

	on_destruct = function(pos)
		local obj = find_doll(pos)
		obj:remove()
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

			meta:set_string("command", fields.text)
			meta:set_string("infotext", S("Spawner Active (@1)", mob))

			-- Create or update doll
			local doll = find_doll(pos)
			if not doll then
				doll = minetest.add_entity({x=pos.x, y=pos.y-0.3, z=pos.z}, "mobs:spawner_mob_doll")
			end
			set_doll_properties(doll, mob)
		else
			minetest.chat_send_player(name, S("Mob Spawner settings failed!"))
			minetest.chat_send_player(name,
				S("> name min_light[0-14] max_light[0-14] max_mobs_in_area[0 to disable] distance[1-20] y_offset[-10 to 10]"))
		end
	end,
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_blast_resistance = 25,
	_mcl_hardness = 5,
})

-- Mob spawner doll (rotating icon inside cage)

local spawner_mob_doll_def = {
	hp_max = 1,
	physical = true,
	collisionbox = {0,0,0,0,0,0},
	visual = "mesh",
	makes_footstep_sound = false,
	timer = 0,
	automatic_rotate = math.pi * 2.9,

	_mob = default_mob, -- name of the mob this doll represents
}

spawner_mob_doll_def.get_staticdata = function(self)
	return self._mob
end

spawner_mob_doll_def.on_activate = function(self, staticdata, dtime_s)
	local mob = staticdata
	if mob == "" or mob == nil then
		mob = default_mob
	end
	set_doll_properties(self.object, mob)
	self.object:setvelocity({x=0, y=0, z=0})
	self.object:setacceleration({x=0, y=0, z=0})
	self.object:set_armor_groups({immortal=1})

end

spawner_mob_doll_def.on_step = function(self, dtime)
	-- Check if spawner is still present. If not, delete the entity
	self.timer = self.timer + 0.01
	local n = minetest.get_node_or_nil(self.object:getpos())
	if self.timer > 1 then
		if n and n.name and n.name ~= "mobs:spawner" then
			self.object:remove()
		end
	end
end

spawner_mob_doll_def.on_punch = function(self, hitter) end

minetest.register_entity("mobs:spawner_mob_doll", spawner_mob_doll_def)



local max_per_block = tonumber(minetest.setting_get("max_objects_per_block") or 99)

-- spawner abm
minetest.register_abm({
	label = "Monster Spawner spawning a monster",
	nodenames = {"mobs:spawner"},
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
		local comm = meta:get_string("command"):split(" ")

		-- get settings from command
		local mob = comm[1]
		local mlig = tonumber(comm[2])
		local xlig = tonumber(comm[3])
		local num = tonumber(comm[4])
		local pla = tonumber(comm[5]) or 0
		local yof = tonumber(comm[6]) or 0

		-- if amount is 0 then do nothing
		if num == 0 then
			return
		end

		-- are we spawning a registered mob?
		if not mobs.spawning_mobs[mob] then
			minetest.log("error", "[mobs] Monster Spawner: Mob doesn't exist: "..mob)
			return
		end

		-- check objects inside 9x9 area around spawner
		local objs = minetest.get_objects_inside_radius(pos, 9)
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

		-- find air blocks within 5 nodes of spawner
		local air = minetest.find_nodes_in_area(
			{x = pos.x - 5, y = pos.y + yof, z = pos.z - 5},
			{x = pos.x + 5, y = pos.y + yof, z = pos.z + 5},
			{"air"})

		-- spawn in random air block
		if air and #air > 0 then

			local pos2 = air[math.random(#air)]
			local lig = minetest.get_node_light(pos2) or 0

			pos2.y = pos2.y + 0.5

			-- only if light levels are within range
			if lig >= mlig and lig <= xlig then
				minetest.add_entity(pos2, mob)
			end
		end

	end
})
