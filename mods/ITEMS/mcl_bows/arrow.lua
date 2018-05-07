local mod_mcl_hunger = minetest.get_modpath("mcl_hunger")
local mod_awards = minetest.get_modpath("awards") and minetest.get_modpath("mcl_achievements")

minetest.register_craftitem("mcl_bows:arrow", {
	description = "Arrow",
	_doc_items_longdesc = [[Arrows are ammunition for bows and dispensers.
An arrow fired from a bow has a regular damage of 1-9. At full charge, there's a 20% chance of a critical hit dealing 10 damage instead. An arrow fired from a dispenser always deals 3 damage.]],
	_doc_items_usagehelp = "To use arrows as ammunition for a bow, just put them anywhere in your inventory, they will be used up automatically. To use arrows as ammunition for a dispenser, place them in the dispenser's inventory.",
	inventory_image = "mcl_bows_arrow_inv.png",
	groups = { ammo=1, ammo_bow=1 },
	_on_dispense = function(itemstack, dispenserpos, droppos, dropnode, dropdir)
		-- Shoot arrow
		local shootpos = vector.add(dispenserpos, vector.multiply(dropdir, 0.51))
		local yaw = math.atan2(dropdir.z, dropdir.x) - math.pi/2
		mcl_bows.shoot_arrow(itemstack:get_name(), shootpos, dropdir, yaw, nil, 19, 3)
	end,
})

minetest.register_node("mcl_bows:arrow_box", {
	drawtype = "nodebox",
	is_ground_content = false,
	node_box = {
		type = "fixed",
		fixed = {
			-- Shaft
			{-6.5/17, -1.5/17, -1.5/17, 6.5/17, 1.5/17, 1.5/17},
			--Spitze
			{-4.5/17, 2.5/17, 2.5/17, -3.5/17, -2.5/17, -2.5/17},
			{-8.5/17, 0.5/17, 0.5/17, -6.5/17, -0.5/17, -0.5/17},
			--Federn
			{6.5/17, 1.5/17, 1.5/17, 7.5/17, 2.5/17, 2.5/17},
			{7.5/17, -2.5/17, 2.5/17, 6.5/17, -1.5/17, 1.5/17},
			{7.5/17, 2.5/17, -2.5/17, 6.5/17, 1.5/17, -1.5/17},
			{6.5/17, -1.5/17, -1.5/17, 7.5/17, -2.5/17, -2.5/17},
			
			{7.5/17, 2.5/17, 2.5/17, 8.5/17, 3.5/17, 3.5/17},
			{8.5/17, -3.5/17, 3.5/17, 7.5/17, -2.5/17, 2.5/17},
			{8.5/17, 3.5/17, -3.5/17, 7.5/17, 2.5/17, -2.5/17},
			{7.5/17, -2.5/17, -2.5/17, 8.5/17, -3.5/17, -3.5/17},
		}
	},
	tiles = {"mcl_bows_arrow.png^[transformFX", "mcl_bows_arrow.png^[transformFX", "mcl_bows_arrow_back.png", "mcl_bows_arrow_front.png", "mcl_bows_arrow.png", "mcl_bows_arrow.png^[transformFX"},
	groups = {not_in_creative_inventory=1},
})

local THROWING_ARROW_ENTITY={
	physical = false,
	visual = "wielditem",
	visual_size = {x=0.4, y=0.4},
	textures = {"mcl_bows:arrow_box"},
	collisionbox = {0,0,0,0,0,0},

	_lastpos={},
	_startpos=nil,
	_damage=1,	-- Damage on impact
	_shooter=nil,	-- ObjectRef of player or mob who shot it
}

THROWING_ARROW_ENTITY.on_step = function(self, dtime)
	local pos = self.object:getpos()
	local node = minetest.get_node(pos)

	-- Check for object collision. Done every tick (hopefully this is not too stressing)
	do
		local objs = minetest.get_objects_inside_radius(pos, 2)
		local closest_object
		local closest_distance
		local ok = false

		-- Iterate through all objects and remember the closest attackable object
		for k, obj in pairs(objs) do
			-- Arrows can only damage players and mobs
			if obj ~= self._shooter and obj:is_player() then
				ok = true
			elseif obj:get_luaentity() ~= nil then
				if obj ~= self._shooter and obj:get_luaentity()._cmi_is_mob then
					ok = true
				end
			end

			if ok then
				local dist = vector.distance(pos, obj:getpos())
				if not closest_object or not closest_distance then
					closest_object = obj
					closest_distance = dist
				elseif dist < closest_distance then
					closest_object = obj
					closest_distance = dist
				end
			end
		end

		-- If an attackable object was found, we will damage the closest one only
		if closest_object ~= nil then
			local obj = closest_object
			local is_player = obj:is_player()
			local lua = obj:get_luaentity()
			if obj ~= self._shooter and (is_player or (lua and lua._cmi_is_mob)) then
				obj:punch(self.object, 1.0, {
					full_punch_interval=1.0,
					damage_groups={fleshy=self._damage},
				}, nil)

				if is_player then
					if self._shooter and self._shooter:is_player() then
						-- “Ding” sound for hitting another player
						minetest.sound_play({name="mcl_bows_hit_player", gain=0.1}, {to_player=self._shooter})
					end
					if mod_mcl_hunger then
						mcl_hunger.exhaust(obj:get_player_name(), mcl_hunger.EXHAUST_DAMAGE)
					end
				end

				if lua then
					local entity_name = lua.name
					-- Achievement for hitting skeleton, wither skeleton or stray (TODO) with an arrow at least 50 meters away
					-- NOTE: Range has been reduced because mobs unload much earlier than that ... >_>
					-- TODO: This achievement should be given for the kill, not just a hit
					if self._shooter and self._shooter:is_player() and vector.distance(pos, self._startpos) >= 20 then
						if mod_awards and (entity_name == "mobs_mc:skeleton" or entity_name == "mobs_mc:stray" or entity_name == "mobs_mc:witherskeleton") then
							awards.unlock(self._shooter:get_player_name(), "mcl:snipeSkeleton")
						end
					end
				end
				self.object:remove()
			end
		end
	end

	-- Check for node collision
	if self._lastpos.x~=nil then
		local def = minetest.registered_nodes[node.name]
		if (def and def.walkable) or not def then
			if not minetest.settings:get_bool("creative_mode") then
				minetest.add_item(self._lastpos, 'mcl_bows:arrow')
			end
			self.object:remove()
		end
	end

	-- Update internal variable
	self._lastpos={x=pos.x, y=pos.y, z=pos.z}
end

minetest.register_entity("mcl_bows:arrow_entity", THROWING_ARROW_ENTITY)

if minetest.get_modpath("mcl_core") and minetest.get_modpath("mcl_mobitems") then
	minetest.register_craft({
		output = 'mcl_bows:arrow 4',
		recipe = {
			{'mcl_core:flint'},
			{'mcl_core:stick'},
			{'mcl_mobitems:feather'}
		}
	})
end
