local S = minetest.get_translator(minetest.get_current_modname())

local math = math
local vector = vector

-- Time in seconds after which a stuck arrow is deleted
local ROCKET_TIMEOUT = 1

local YAW_OFFSET = -math.pi/2

local particle_explosion = vl_fireworks.generic_particle_explosion

local function damage_explosion(self, damagemulitplier, pos)
	if self._harmless then return end

	local p = pos or self.object:get_pos()
	if not p then return end
	mcl_explosions.explode(p, 3, {})
	local objects = core.get_objects_inside_radius(p, 8)
	for _,obj in pairs(objects) do
		if obj:is_player() then
			mcl_util.deal_damage(obj, damagemulitplier - vector.distance(p, obj:get_pos()), {type = "explosion"})
		elseif obj:get_luaentity() and obj:get_luaentity().is_mob then
			obj:punch(self.object, 1.0, {
				full_punch_interval=1.0,
				damage_groups={fleshy=damagemulitplier - vector.distance(p, obj:get_pos())},
			}, self.object:get_velocity()) -- TODO possibly change the punch dir to be outwards instead of rocket velocity
		end
	end
end

core.register_craftitem("mcl_bows:rocket", {
	description = S("Arrow"),
	_tt_help = S("Ammunition").."\n"..S("Damage from bow: 1-10").."\n"..S("Damage from dispenser: 3"),
	_doc_items_longdesc = S("Arrows are ammunition for bows and dispensers.").."\n"..
		S("An arrow fired from a bow has a regular damage of 1-9. At full charge, there's a 20% chance of a critical hit dealing 10 damage instead. An arrow fired from a dispenser always deals 3 damage.").."\n"..
		S("Arrows might get stuck on solid blocks and can be retrieved again. They are also capable of pushing wooden buttons."),
	_doc_items_usagehelp = S("To use arrows as ammunition for a bow, just put them anywhere in your inventory, they will be used up automatically. To use arrows as ammunition for a dispenser, place them in the dispenser's inventory. To retrieve an arrow that sticks in a block, simply walk close to it."),
	inventory_image = "mcl_bows_rocket.png",
	groups = {ammo=1, ammo_crossbow=1, ammo_bow_regular=1},
	_on_dispense = function(itemstack, dispenserpos, droppos, dropnode, dropdir)
		-- Shoot arrow
		local shootpos = vector.add(dispenserpos, vector.multiply(dropdir, 0.51))
		local yaw = math.atan2(dropdir.z, dropdir.x) + YAW_OFFSET
		mcl_bows.shoot_arrow(itemstack:get_name(), shootpos, dropdir, yaw, nil, 19, 3)
	end,
	_on_collide_with_entity = function(self, _, obj)
		if self._in_player == false then
			local pos = self.object:get_pos()
			obj:punch(self.object, 1.0, {
				full_punch_interval=1.0,
				damage_groups={fleshy=self._damage},
			}, self.object:get_velocity())

			if particle_explosion then
				local eploded_particle = particle_explosion(pos)
				damage_explosion(self, eploded_particle * 17, pos)
			end
			mcl_burning.extinguish(self.object)
			mcl_util.remove_entity(self)
		end
	end,
})

local arrow_entity = mcl_bows.arrow_entity
local rocket_entity = table.copy(arrow_entity)
table.update(rocket_entity,{
	mesh = "mcl_bows_rocket.obj",
	textures = {"mcl_bows_rocket.png"},
	visual_size = {x=2.5, y=2.5},
	save_fields = {
		"stuck", "fuse", "stuckin", "lastpos", "startpos", "damage", "is_critical", "shootername",
	},
	_fuse=nil,-- Amount of time (in seconds) the arrow has been stuck so far
	_fuserechecktimer=nil,-- An additional timer for periodically re-checking the stuck status of an arrow
})
rocket_entity.on_step = function(self, dtime)
	self._fuse = (self._fuse or 0) + dtime

	if self._fuse > ROCKET_TIMEOUT then
		self._stuck = true
	end
	if self._stuck and self._fuse > ROCKET_TIMEOUT then
		if particle_explosion then
			local eploded_particle = particle_explosion(self)
			damage_explosion(self, eploded_particle * 17)
		end
		mcl_burning.extinguish(self.object)
		mcl_util.remove_entity(self)
		return
	end

	-- Perform normal projectile behaviors
	vl_projectile.update_projectile(self, dtime)
end

vl_projectile.register("mcl_bows:rocket_entity", rocket_entity)

if core.get_modpath("mcl_core") and core.get_modpath("mcl_mobitems") and core.get_modpath("vl_fireworks") then
	core.register_craft({
		output = "mcl_bows:rocket 1",
		recipe = {
			{"mcl_core:paper"},
			{"vl_fireworks:rocket_2"},
			{"mcl_bows:arrow"},
		}
	})
end

if minetest.get_modpath("doc_identifier") then
	doc.sub.identifier.register_object("mcl_bows:rocket_entity", "craftitems", "mcl_bows:rocket")
end
