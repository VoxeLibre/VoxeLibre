local S = core.get_translator(core.get_current_modname())

local mod_target = core.get_modpath("mcl_target")
local enable_pvp = core.settings:get_bool("enable_pvp")

local YAW_OFFSET = -math.pi/2
local TRACER_THRESHOLD = 9

core.register_craftitem("vl_tridents:trident", {
	description = S("Trident"),
	_tt_help = S("Throwable").."\n"..S("Damage from trident: 1-9"),
	_doc_items_longdesc = S(""),
	_doc_items_usagehelp = S("Use the punch key to throw."),
	inventory_image = "vl_tridents_inv.png",
	stack_max = 1,
	on_use = mcl_throwing.get_player_throw_function("vl_tridents:trident_entity"),
})

vl_projectile.register("vl_tridents:trident_entity", {
	initial_properties = {
		physical = true,
		pointable = false,
		visual = "mesh",
		mesh = "vl_tridents.obj",
		visual_size = {x=-1, y=1},
		textures = {"vl_tridents.png"},
		collisionbox = {-.1, -.1, -1, .1, .1, 0.5},
		collide_with_objects = true,
	},

	liquid_drag = true,
	_fire_damage_resistant = true,

	_damage=9,
	_deflection_cooloff=0,

	get_staticdata = mcl_throwing.get_staticdata,
	on_activate = mcl_throwing.on_activate,
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

			vl_projectile.collides_with_solids,
			vl_projectile.raycast_collides_with_entities,
		},

		sounds = {
			-- TODO
		},

		on_collide_with_solid = function(self, pos, node)
			if mod_target and node.name == "mcl_target:target_off" then
				mcl_target.hit(vector.round(pos), 0.4) --4 redstone ticks
			end
		end,

		on_collide_with_entity = function(self, pos, obj)
			-- TODO
		end,
	},
})

mcl_throwing.register_throwable_object("vl_tridents:trident", "vl_tridents:trident_entity", 22)
