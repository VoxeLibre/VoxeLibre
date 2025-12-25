local S = minetest.get_translator(minetest.get_current_modname())

local mod_target = minetest.get_modpath("mcl_target")
local mod_campfire = minetest.get_modpath("mcl_campfires")
local enable_pvp = minetest.settings:get_bool("enable_pvp")

local math = math
local vector = vector

local YAW_OFFSET = -math.pi/2
local TRACER_THRESHOLD = 9

local mod_awards = minetest.get_modpath("awards") and minetest.get_modpath("mcl_achievements")
local mod_button = minetest.get_modpath("mesecons_button")

minetest.register_craftitem("mcl_bows:arrow", {
	description = S("Arrow"),
	_tt_help = S("Ammunition").."\n"..S("Damage from bow: 1-10").."\n"..S("Damage from dispenser: 3"),
	_doc_items_longdesc = S("Arrows are ammunition for bows and dispensers.").."\n"..
S("An arrow fired from a bow has a regular damage of 1-9. At full charge, there's a 20% chance of a critical hit dealing 10 damage instead. An arrow fired from a dispenser always deals 3 damage.").."\n"..
S("Arrows might get stuck on solid blocks and can be retrieved again. They are also capable of pushing wooden buttons."),
	_doc_items_usagehelp = S("To use arrows as ammunition for a bow, just put them anywhere in your inventory, they will be used up automatically. To use arrows as ammunition for a dispenser, place them in the dispenser's inventory. To retrieve an arrow that sticks in a block, simply walk close to it."),
	inventory_image = "mcl_bows_arrow_inv.png",
	groups = { ammo=1, ammo_bow=1, ammo_bow_regular=1, ammo_crossbow=1 },
	_on_dispense = function(itemstack, dispenserpos, droppos, dropnode, dropdir)
		-- Shoot arrow
		local shootpos = vector.add(dispenserpos, vector.multiply(dropdir, 0.51))
		local yaw = math.atan2(dropdir.z, dropdir.x) + YAW_OFFSET
		mcl_bows.shoot_arrow(itemstack:get_name(), shootpos, dropdir, yaw, nil, 19, 3)
	end,
})

-- Destroy arrow entity self at pos and drops it as an item
local arrow_entity = {
	initial_properties = {
		physical = true,
		pointable = false,
		visual = "mesh",
		mesh = "mcl_bows_arrow.obj",
		visual_size = {x=-1, y=1},
		textures = {"mcl_bows_arrow.png"},
		collisionbox = {-0.19, -0.125, -0.19, 0.19, 0.125, 0.19},
		collide_with_objects = false,
	},
	liquid_drag = true,
	_fire_damage_resistant = true,

	_save_fields = {
		"last_pos", "startpos", "damage", "is_critical", "stuck", "stuckin", "stuckin_player", "time_in_air", "collectable", "arrow_item", "itemstring"
	},

	_damage=1,	-- Damage on impact
	_is_critical=false, -- Whether this arrow would deal critical damage
	_stuck=false,   -- Whether arrow is stuck
	_stucktimer=nil,-- Amount of time (in seconds) the arrow has been stuck so far
	_stuckrechecktimer=nil,-- An additional timer for periodically re-checking the stuck status of an arrow
	_stuckin=nil,	--Position of node in which arow is stuck.
	_shooter=nil,	-- ObjectRef of player or mob who shot it
	_is_arrow = true,
	_in_player = false,
	_blocked = false,
	_viscosity=0,   -- Viscosity of node the arrow is currently in
	_deflection_cooloff=0, -- Cooloff timer after an arrow deflection, to prevent many deflections in quick succession

	_vl_projectile = {
		survive_collision = true,
		sticks_in_players = true,
		damages_players = true,
		maximum_time = 60,
		damage_groups = function(self)
			return {fleshy = self._damage}
		end,
		hide_tracer = function(self)
			return self._stuck or self._damage < TRACER_THRESHOLD or self._in_player
		end,
		tracer_texture = "mobs_mc_arrow_particle.png",
		behaviors = {
			vl_projectile.sticks,
			vl_projectile.burns,
			vl_projectile.has_tracer,
			vl_projectile.has_owner_grace_distance,

			-- Custom arrow behaviors
			function(self, dtime)
				if self._deflection_cooloff > 0 then
					self._deflection_cooloff = self._deflection_cooloff - dtime
				end
			end,

			vl_projectile.collides_with_solids,
			vl_projectile.raycast_collides_with_entities,
		},
		sounds = {
			on_entity_collision = function(self, _, _, _, obj)
				if obj:is_player() then
					return {{name="mcl_bows_hit_player", gain=0.1}, {to_player=obj:get_player_name()}, true}
				end

				return {{name="mcl_bows_hit_other", gain=0.3}, {pos=self.object:get_pos(), max_hear_distance=16}, true}
			end
		},
		on_collide_with_entity = function(self, pos, obj)
			local is_player = obj:is_player()
			local lua = obj:get_luaentity()

			-- Make sure collision is valid
			if not (is_player or (lua and (lua.is_mob or lua._hittable_by_projectile))) then
				return
			end

			if obj:get_hp() > 0 then
				if lua then
					local entity_name = lua.name
					-- Achievement for hitting skeleton, wither skeleton or stray (TODO) with an arrow at least 50
					-- meters away
					-- NOTE: Range has been reduced because mobs unload much earlier than that ... >_>
					-- TODO: This achievement should be given for the kill, not just a hit
					local shooter = self._vl_projectile.owner
					if shooter and shooter:is_player() and vector.distance(pos, self._startpos) >= 20 then
						if mod_awards and (entity_name == "mobs_mc:skeleton" or entity_name == "mobs_mc:stray"
						or entity_name == "mobs_mc:witherskeleton") then
							awards.unlock(shooter:get_player_name(), "mcl:snipeSkeleton")
						end
					end
				end
			end

			-- Item definition entity collision hook
			local item_def = core.registered_items[self._arrow_item]
			local hook = item_def and item_def._on_collide_with_entity
			if hook then hook(self, pos, obj) end

			if (self._piercing or 0) > 0 then
				self._piercing = self._piercing - 1
				return
			end

			-- Because arrows are flagged to survive collisions to allow sticking into blocks, manually remove it
			-- now that it has collided with an entity
			if not is_player then
				mcl_util.remove_entity(self)
			end
		end
	},

	-- Force recheck of stuck arrows when punched.
	-- Otherwise, punching has no effect.
	on_punch = function(self)
		if self._stuck then
			self._stuckrechecktimer = 5
		end
	end,
	get_staticdata = function(self)
		local out = {}
		local save_fields = self._save_fields
		for i = 1,#save_fields do
			local field = save_fields[i]
			local val = self["_"..field]
			if type(val) ~= "function" and type(val) ~= "userdata" then
				out[field] = val
			end
		end

		-- Preserve entity properties
		out.properties = self.object:get_properties()

		return core.serialize(out)
	end,
	on_activate = function(self, staticdata, dtime_s)
		self.object:set_armor_groups({immortal = 1})

		self._time_in_air = 1.0
		local data = core.deserialize(staticdata)
		if not data then return end

		-- Restore entity properties
		if data.properties then
			self.object:set_properties(data.properties)
			data.properties = nil
		end

		-- Restore arrow state
		local save_fields = self._save_fields
		for i = 1,#save_fields do
			local field = save_fields[i]
			self["_"..field] = data[field]
		end

		if not self._vl_projectile then
			self._vl_projetile = {}
		end

		if data.shootername then
			local shooter = core.get_player_by_name(data.shootername)
			if shooter and shooter:is_player() then
				self._shooter = shooter
			end
		end

		if data.stuckin_player then
			mcl_util.remove_entity(self)
		end
	end,
}

-- Make the arrow entity available to other mods as a template
mcl_bows.arrow_entity = table.copy(arrow_entity)

vl_projectile.register("mcl_bows:arrow_entity", arrow_entity)

core.register_on_respawnplayer(function(player)
	for _, obj in pairs(player:get_children()) do
		local ent = obj:get_luaentity()
		if ent and ent.name and string.find(ent.name, "mcl_bows:arrow_entity") then
			mcl_util.remove_entity(ent)
		end
	end
end)

if core.get_modpath("mcl_core") and core.get_modpath("mcl_mobitems") then
	core.register_craft({
		output = "mcl_bows:arrow 4",
		recipe = {
			{"mcl_core:flint"},
			{"mcl_core:stick"},
			{"mcl_mobitems:feather"}
		}
	})
end

if minetest.get_modpath("doc_identifier") then
	doc.sub.identifier.register_object("mcl_bows:arrow_entity", "craftitems", "mcl_bows:arrow")
end
