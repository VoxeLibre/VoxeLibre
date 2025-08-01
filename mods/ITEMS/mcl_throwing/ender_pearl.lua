local modname = core.get_current_modname()
local S = core.get_translator(modname)

local math = math
local vector = vector

local mod_target = core.get_modpath("mcl_target")
local how_to_throw = S("Use the punch key to throw.")

-- Ender Pearl
core.register_craftitem("mcl_throwing:ender_pearl", {
	description = S("Ender Pearl"),
	_tt_help = S("Throwable").."\n"..core.colorize(mcl_colors.YELLOW, S("Teleports you on impact for cost of 5 HP")),
	_doc_items_longdesc = S("An ender pearl is an item which can be used for teleportation at the cost of health. It can be thrown and teleport the thrower to its impact location when it hits a solid block or a plant. Each teleportation hurts the user by 5 hit points."),
	_doc_items_usagehelp = how_to_throw,
	wield_image = "mcl_throwing_ender_pearl.png",
	inventory_image = "mcl_throwing_ender_pearl.png",
	stack_max = 16,
	on_use = mcl_throwing.get_player_throw_function("mcl_throwing:ender_pearl_entity"),
	groups = {transport = 1},
})

function on_collide(self, pos, node)
	if mod_target and node.name == "mcl_target:target_off" then
		mcl_target.hit(vector.round(pos), 0.4) --4 redstone ticks
	end

	if node.name == "ignore" or mcl_worlds.is_in_void(pos) then
		-- FIXME: This also means the player loses an ender pearl for throwing into unloaded areas
		return
	end

	-- Make sure we have a reference to the player
	local player = self._owner and core.get_player_by_name(self._owner)
	if not player then return end

	-- Teleport and hurt player

	-- First determine good teleport position
	local dir = vector.zero()

	local v = self.object:get_velocity()
	local node_def = core.registered_nodes[node.name]
	if node_def and node_def.walkable then
		local vc = vector.normalize(v) -- vector for calculating
		-- Node is walkable, we have to find a place somewhere outside of that node

		-- Zero-out the two axes with a lower absolute value than the axis with the strongest force
		local lv, ld = math.abs(vc.y), "y"
		if math.abs(vc.x) > lv then
			lv, ld = math.abs(vc.x), "x"
		end
		if math.abs(vc.z) > lv then
			ld = "z" --math.abs(vc.z)
		end
		if ld ~= "x" then vc.x = 0 end
		if ld ~= "y" then vc.y = 0 end
		if ld ~= "z" then vc.z = 0 end

		-- Final tweaks to the teleporting pos, based on direction
		-- Impact from the side
		dir.x = vc.x * -1
		dir.z = vc.z * -1

		-- Special case: top or bottom of node
		if vc.y > 0 then
			-- We need more space when impact is from below
			dir.y = -2.3
		elseif vc.y < 0 then
			-- Standing on top
			dir.y = 0.5
		end
	end
	-- If node was not walkable, no modification to pos is made.

	-- Final teleportation position
	local telepos = vector.add(pos, dir)
	local telenode = core.get_node(telepos)

	--[[ It may be possible that telepos is walkable due to the algorithm.
	Especially when the ender pearl is faster horizontally than vertical.
	This applies final fixing, just to be sure we're not in a walkable node ]]
	if not core.registered_nodes[telenode.name] or core.registered_nodes[telenode.name].walkable then
		if v.y < 0 then
			telepos.y = telepos.y + 0.5
		else
			telepos.y = telepos.y - 2.3
		end
	end

	local oldpos = player:get_pos()
	-- Teleport and hurt player
	player:set_pos(telepos)
	player:set_hp(player:get_hp() - 5, {type = "fall", from = "mod"})

	-- 5% chance to spawn endermite at the player's origin
	if math.random(1,20) == 1 then
		core.add_entity(oldpos, "mobs_mc:endermite")
	end
end

-- Ender pearl entity
vl_projectile.register("mcl_throwing:ender_pearl_entity",{
	initial_properties = {
		physical = true,
		collisionbox = {-0.1,-0.1,-0.1,0.1,0.1,0.1},
		pointable = false,
		visual_size = {x=0.9, y=0.9},
		textures = {"mcl_throwing_ender_pearl.png"},
	},
	timer=0,

	get_staticdata = mcl_throwing.get_staticdata,
	on_activate = mcl_throwing.on_activate,

	on_step = vl_projectile.update_projectile,
	_lastpos={},
	_vl_projectile = {
		behaviors = {
			vl_projectile.collides_with_solids,
			vl_projectile.collides_with_entities,
		},
		collides_with = {
			"mcl_core:vine", "mcl_core:deadbush",
			"group:flower", "group:sapling",
			"group:plant", "group:mushroom",
		},
		allow_punching = function(self, _, _, object)
			if self.timer < 1 and self._owner == mcl_util.get_entity_id(object) then return false end

			local le = object:get_luaentity()
			return le and (le.is_mob or le._hittable_by_projectile) or object:is_player()
		end,
		on_collide_with_entity = function(self, pos, entity)
			on_collide(self, pos, core.get_node(pos))
		end,
		on_collide_with_solid = on_collide,
	},
})
mcl_throwing.register_throwable_object("mcl_throwing:ender_pearl", "mcl_throwing:ender_pearl_entity", mcl_throwing.default_velocity)

