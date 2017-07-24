minetest.register_craftitem("mcl_throwing:arrow", {
	description = "Arrow",
	_doc_items_longdesc = "Arrows are ammunition for bows and dispensers.",
	_doc_items_usagehelp = "To use arrows as ammunition for a bow, just put them anywhere in your inventory, they will be used up automatically. To use arrows as ammunition for a dispenser, place them in the dispenser's inventory.",
	inventory_image = "mcl_throwing_arrow_inv.png",
	groups = { ammo=1, ammo_bow=1 },
})

minetest.register_node("mcl_throwing:arrow_box", {
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
	tiles = {"mcl_throwing_arrow.png^[transformFX", "mcl_throwing_arrow.png^[transformFX", "mcl_throwing_arrow_back.png", "mcl_throwing_arrow_front.png", "mcl_throwing_arrow.png", "mcl_throwing_arrow.png^[transformFX"},
	groups = {not_in_creative_inventory=1},
})

local THROWING_ARROW_ENTITY={
	physical = false,
	visual = "wielditem",
	visual_size = {x=0.4, y=0.4},
	textures = {"mcl_throwing:arrow_box"},
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
					mcl_hunger.exhaust(obj:get_player_name(), mcl_hunger.EXHAUST_DAMAGE)
				end

				if lua then
					local entity_name = lua.name
					-- Achievement for hitting skeleton, wither skeleton or stray (TODO) with an arrow at least 50 meters away
					-- NOTE: Range has been reduced because mobs unload much earlier than that ... >_>
					-- TODO: This achievement should be given for the kill, not just a hit
					if self._shooter and self._shooter:is_player() and vector.distance(pos, self._startpos) >= 20 then
						if (entity_name == "mobs_mc:skeleton" or entity_name == "mobs_mc:stray" or entity_name == "mobs_mc:witherskeleton") then
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
			if not minetest.setting_getbool("creative_mode") then
				minetest.add_item(self._lastpos, 'mcl_throwing:arrow')
			end
			self.object:remove()
		end
	end

	-- Update internal variable
	self._lastpos={x=pos.x, y=pos.y, z=pos.z}
end

minetest.register_entity("mcl_throwing:arrow_entity", THROWING_ARROW_ENTITY)

minetest.register_craft({
	output = 'mcl_throwing:arrow 4',
	recipe = {
		{'mcl_core:flint'},
		{'mcl_core:stick'},
		{'mcl_mobitems:feather'}
	}
})
