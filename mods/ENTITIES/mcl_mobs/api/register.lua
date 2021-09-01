function mcl_mobs.register_mob(name, def)
	mcl_mobs.registered_mobs[name] = def

	def = table.copy(def)

	def.health_min = mcl_mobs.util.scale_difficulty(def.health_min, 5, 1)
	def.health_max = mcl_mobs.util.scale_difficulty(def.health_max, 10, 1)
	def.breath_max = def.breath_max or mcl_mobs.const.breath_max

	def.damage = mcl_mobs.util.scale_difficulty(def.damage, 0, 0)

	def.fear_height = def.fear_height or 0
	def.view_range = def.view_range or mcl_mobs.const.VIEW_RANGE

	def.armor_groups = def.armor_groups or {fleshy = 100}
	def.knockback_multiplier = def.knockback_multiplier or 1

	def.sounds = def.sounds or {}

	def.gravity = def.gravity or mcl_mobs.const.gravity

	if def.group_attack then
		if def.group_attack == true then
			def.group_attack = {[name] = true}
		else
			def.group_attack = mcl_mobs.util.list_to_set(def.group_attack)
		end
	end

	def.get_with = mcl_mobs.util.list_to_set(def.feed_with)

	local feed_with = mcl_mobs.util.list_to_set(def.feed_with)

	def.boost_with = def.boostable and (def.boost_with and mcl_mobs.util.list_to_set(def.boost_with) or feed_with)
	def.heal_with  = def.healable  and (def.heal_with  and mcl_mobs.util.list_to_set(def.heal_with)  or feed_with)
	def.breed_with = def.breedable and (def.breed_with and mcl_mobs.util.list_to_set(def.breed_with) or feed_with)
	def.tame_with  = def.tameable  and (def.tame_with  and mcl_mobs.util.list_to_set(def.tame_with)  or feed_with)

	if type(def.visual_size) == "number" then
		def.visual_size = {x = def.visual_size, y = def.visual_size}
	end

	def.driver_offset     = def.driver_offset     or vector.new(0, 0, 0)
	def.driver_eye_offset = def.driver_eye_offset or vector.new(0, 0, 0)

	def.stepheight = def.stepheight or mcl_mobs.const.stepheight

	def.float_in_air   = def.float_in_air   == true and mcl_mobs.const.float_in_air   or def.float_in_air
	def.float_in_water = def.float_in_water == true and mcl_mobs.const.float_in_water or def.float_in_water
	def.float_in_lava  = def.float_in_lava  == true and mcl_mobs.const.float_in_lava  or def.float_in_lava

	mcl_mobs.mob_defititions[name] = def

	local entity_def = {
		initial_properties = {
			physical = true,
			collide_with_objects = false, -- custom magnetic object collision handling
			collisionbox = def.collisionbox, -- no default collisionbox, there are some basic traits the mob def **needs** to have, there is no such thing as a generic mob
			pointable = true,
			visual = "mesh", -- all mobs have models
			mesh = def.model,
			visual_size = def.visual_size or {x = 1, y = 1},
			textures = def.textures, -- maybe introduce a better concept to automatically handle textures (to avoid problems with armor and wielditems once they are added)
			use_texture_alpha = def.use_texture_alpha, -- for e.g. slimes
			is_visible = true, -- always visible
			makes_footstep_sound = def.makes_footstep_sound, -- play the footstep sounds of the nodes the mob is walking over (maybe this should be enabled by default?)
			automatic_rotate = 0,
			stepheight = def.stepheight, -- is this needed? mobs have custom movement functions, don't they? Or is this useful for client side prediction?
			automatic_face_movement_dir = def.rotate or 0,
			automatic_face_movement_max_rotation_per_sec = 360,
			glow = def.glow, -- Some mobs glow. Could also be used for spectral arrows in the future
			static_save = true, -- persistent mobs
			damage_texture_modifier = "^blank.png", -- damage is handled customly, don't show the damage overlay client-side
			show_on_minimap = def.show_on_minimap, -- nice to have feature for bosses
		},
	}
	setmetatable(entity_def, {__index = mcl_mobs.mob})

	minetest.register_entity(name, entity_def)

	if minetest.get_modpath("doc_identifier") ~= nil then
		doc.sub.identifier.register_object(name, "basics", "mobs")
	end
end
