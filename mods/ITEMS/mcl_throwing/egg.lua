local modname = core.get_current_modname()
local S = core.get_translator(modname)

local mod_target = core.get_modpath("mcl_target")
local how_to_throw = S("Use the punch key to throw.")

-- Egg
core.register_craftitem("mcl_throwing:egg", {
	description = S("Egg"),
	_tt_help = S("Throwable").."\n"..S("Chance to hatch chicks when broken"),
	_doc_items_longdesc = S("Eggs can be thrown or launched from a dispenser and breaks on impact. There is a small chance that 1 or even 4 chicks will pop out of the egg."),
	_doc_items_usagehelp = how_to_throw,
	inventory_image = "mcl_throwing_egg.png",
	stack_max = 64,
	on_use = mcl_throwing.get_player_throw_function("mcl_throwing:egg_entity"),
	_on_dispense = mcl_throwing.dispense_function,
	groups = {craftitem = 1},
})

local function egg_spawn_chicks(pos)
	-- 1/8 chance to spawn a chick
	if math.random(1,8) ~= 1 then return end

	mcl_mobs.spawn_child(pos, "mobs_mc:chicken")

	-- BONUS ROUND: 1/32 chance to spawn 3 additional chicks
	if math.random(1,32) ~= 1 then return end

	mcl_mobs.spawn_child(vector.offset(pos,  0.7, 0,  0  ), "mobs_mc:chicken")
	mcl_mobs.spawn_child(vector.offset(pos, -0.7, 0, -0.7), "mobs_mc:chicken")
	mcl_mobs.spawn_child(vector.offset(pos, -0.7, 0,  0.7), "mobs_mc:chicken")
end

vl_projectile.register("mcl_throwing:egg_entity",{
	initial_properties = {
		physical = true,
		collisionbox = {-0.1,-0.1,-0.1,0.1,0.1,0.1},
		pointable = false,
		visual_size = {x=0.45, y=0.45},
		textures = {"mcl_throwing_egg.png"},
	},
	timer=0,

	get_staticdata = mcl_throwing.get_staticdata,
	on_activate = mcl_throwing.on_activate,

	on_step = vl_projectile.update_projectile,
	_lastpos={},
	_thrower = nil,
	_vl_projectile = {
		behaviors = {
			vl_projectile.collides_with_solids,
			vl_projectile.collides_with_entities,
		},
		allow_punching = function(self, _, _, object)
			if self.timer < 1 and self._owner == mcl_util.get_entity_id(object) then return false end

			local le = object:get_luaentity()
			return le and (le.is_mob or le._hittable_by_projectile) or object:is_player()
		end,
		on_collide_with_solid = function(self, pos, node)
			if mod_target and node.name == "mcl_target:target_off" then
				mcl_target.hit(vector.round(pos), 0.4) --4 redstone ticks
			end

			local vel = self.object:get_velocity()
			pos = vector.round(pos + vector.normalize(vel) * -0.35)

			egg_spawn_chicks(pos)
		end,
		on_collide_with_entity = function(self, pos, obj)
			local vel = self.object:get_velocity()
			pos = vector.round(pos + vector.normalize(vel) * -0.35)

			egg_spawn_chicks(pos)
		end,
		sounds = {
			on_collision = {"mcl_throwing_egg_impact", {max_hear_distance=10, gain=0.5}, true}
		},
	},
})
mcl_throwing.register_throwable_object("mcl_throwing:egg", "mcl_throwing:egg_entity", mcl_throwing.default_velocity)

