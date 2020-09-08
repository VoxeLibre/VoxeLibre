--Fishing Rod, Bobber, and Flying Bobber mechanics and Bobber artwork by Rootyjr.

local S = minetest.get_translator("mcl_fishing")
local mod_throwing = minetest.get_modpath("mcl_throwing")

local entity_mapping = {
	["mcl_fishing:bobber"] = "mcl_fishing:bobber_entity",
}

local bobber_ENTITY={
	physical = false,
	timer=0,
	textures = {"mcl_fishing_bobber.png"},
	visual_size = {x=0.5, y=0.5},
	collisionbox = {0.45,0.45,0.45,0.45,0.45,0.45},
	pointable = false,
	static_save = false,

	_lastpos={},
	_dive = false,
	_waittick = nil,
	_tick = 0,
	player=nil,
	_oldy = nil,
	objtype="fishing",
}

local fish = function(itemstack, player)
		local pos = player:get_pos()

		local objs = minetest.get_objects_inside_radius(pos, 125)
		local num = 0
		local ent = nil
		local noent = true

		--Check for bobber if so handle.
		for n = 1, #objs do
			ent = objs[n]:get_luaentity()
			if ent then
				if ent.player and ent.objtype=="fishing" then
					if (player:get_player_name() == ent.player) then
						noent = false
						if ent._dive == true then
							local itemname
							local items
							local itemcount = 1
							local itemwear = 0
							-- FIXME: Maybe use a better seeding
							local pr = PseudoRandom(os.time() * math.random(1, 100))
							local r = pr:next(1, 100)
							if r <= 85 then
								-- Fish
								items = mcl_loot.get_loot({
									items = {
										{ itemstring = "mcl_fishing:fish_raw", weight = 60 },
										{ itemstring = "mcl_fishing:salmon_raw", weight = 25 },
										{ itemstring = "mcl_fishing:clownfish_raw", weight = 2 },
										{ itemstring = "mcl_fishing:pufferfish_raw", weight = 13 },
									}
								}, pr)
							elseif r <= 95 then
								-- Junk
								items = mcl_loot.get_loot({
									items = {
										{ itemstring = "mcl_core:bowl", weight = 10 },
										{ itemstring = "mcl_fishing:fishing_rod", weight = 2, wear_min = 6554, wear_max = 65535 }, -- 10%-100% damage
										{ itemstring = "mcl_mobitems:leather", weight = 10 },
										{ itemstring = "mcl_armor:boots_leather", weight = 10, wear_min = 6554, wear_max = 65535 }, -- 10%-100% damage
										{ itemstring = "mcl_mobitems:rotten_flesh", weight = 10 },
										{ itemstring = "mcl_core:stick", weight = 5 },
										{ itemstring = "mcl_mobitems:string", weight = 5 },
										{ itemstring = "mcl_potions:water", weight = 10 },
										{ itemstring = "mcl_mobitems:bone", weight = 10 },
										{ itemstring = "mcl_dye:black", weight = 1, amount_min = 10, amount_max = 10 },
										{ itemstring = "mcl_mobitems:string", weight = 10 }, -- TODO: Tripwire Hook
									}
								}, pr)
							else
								-- Treasure
								items = mcl_loot.get_loot({
									items = {
										-- TODO: Enchanted Bow
										{ itemstring = "mcl_bows:bow", wear_min = 49144, wear_max = 65535 }, -- 75%-100% damage
										-- TODO: Enchanted Book
										{ itemstring = "mcl_books:book" },
										-- TODO: Enchanted Fishing Rod
										{ itemstring = "mcl_fishing:fishing_rod", wear_min = 49144, wear_max = 65535 }, -- 75%-100% damage
										{ itemstring = "mcl_mobs:nametag", },
										{ itemstring = "mcl_mobitems:saddle", },
										{ itemstring = "mcl_flowers:waterlily", },
									}
								}, pr)
							end
							local item
							if #items >= 1 then
								item = ItemStack(items[1])
							else
								item = ItemStack()
							end
							local inv = player:get_inventory()
							if inv:room_for_item("main", item) then
								inv:add_item("main", item)
							end

							if not minetest.is_creative_enabled(player:get_player_name()) then
								local idef = itemstack:get_definition()
								itemstack:add_wear(65535/65) -- 65 uses
								if itemstack:get_count() == 0 and idef.sound and idef.sound.breaks then
									minetest.sound_play(idef.sound.breaks, {pos=player:get_pos(), gain=0.5}, true)
								end
							end
						end
						--Check if object is on land.
						local epos = ent.object:get_pos()
						epos.y = math.floor(epos.y)
						local node = minetest.get_node(epos)
						local def = minetest.registered_nodes[node.name]
						if def.walkable then
							if not minetest.is_creative_enabled(player:get_player_name()) then
								local idef = itemstack:get_definition()
								itemstack:add_wear((65535/65)*2) -- if so and not creative then wear double like in MC.
								if itemstack:get_count() == 0 and idef.sound and idef.sound.breaks then
									minetest.sound_play(idef.sound.breaks, {pos=player:get_pos(), gain=0.5}, true)
								end
							end
						end
						--Destroy bobber.
						ent.object:remove()
						return itemstack
					end
				end
			end
		end
		--Check for flying bobber.
		for n = 1, #objs do
			ent = objs[n]:get_luaentity()
			if ent then
				if ent._thrower and ent.objtype=="fishing" then
					if player:get_player_name() == ent._thrower then
						noent = false
						break
					end
				end
			end
		end
		--If no bobber or flying_bobber exists then throw bobber.
		if noent == true then
			local playerpos = player:get_pos()
			local dir = player:get_look_dir()
			local obj = mcl_throwing.throw("mcl_throwing:flying_bobber", {x=playerpos.x, y=playerpos.y+1.5, z=playerpos.z}, dir, 15, player:get_player_name())
		end
end

-- Movement function of bobber
local bobber_on_step = function(self, dtime)
	self.timer=self.timer+dtime
	local epos = self.object:get_pos()
	epos.y = math.floor(epos.y)
	local node = minetest.get_node(epos)
	local def = minetest.registered_nodes[node.name]

	--If we have no player, remove self.
	if self.player == nil or self.player == "" then
		self.object:remove()
		return
	end
	local player = minetest.get_player_by_name(self.player)
	if not player then
		self.object:remove()
		return
	end

	--Check if player is nearby
	if self._tick % 5 == 0 and self.player ~= nil and player ~= nil then
		--Destroy bobber if item not wielded.
		local wield = player:get_wielded_item()
		if ((not wield) or (wield:get_name() ~= "mcl_fishing:fishing_rod")) then
			self.object:remove()
			return
		end

		--Destroy bobber if player is too far away.
		local objpos = self.object:get_pos()
		local playerpos = player:get_pos()
		if (((playerpos.y - objpos.y) >= 33) or ((playerpos.y - objpos.y) <= -33)) then
			self.object:remove()
			return
		elseif (((playerpos.x - objpos.x) >= 33) or ((playerpos.x - objpos.x) <= -33)) then
			self.object:remove()
			return
		elseif (((playerpos.z - objpos.z) >= 33) or ((playerpos.z - objpos.z) <= -33)) then
			self.object:remove()
			return
		elseif ((((playerpos.z + playerpos.x) - (objpos.z + objpos.x)) >= 33) or ((playerpos.z + playerpos.x) - (objpos.z + objpos.x)) <= -33) then
			self.object:remove()
			return
		elseif ((((playerpos.y + playerpos.x) - (objpos.y + objpos.x)) >= 33) or ((playerpos.y + playerpos.x) - (objpos.y + objpos.x)) <= -33) then
			self.object:remove()
			return
		elseif ((((playerpos.z + playerpos.y) - (objpos.z + objpos.y)) >= 33) or ((playerpos.z + playerpos.y) - (objpos.z + objpos.y)) <= -33) then
			self.object:remove()
			return
		end

	end
	-- If in water, then bob.
	if def.liquidtype == "source" and minetest.get_item_group(def.name, "water") ~= 0 then
		if self._oldy == nil then
			self.object:set_pos({x=self.object:get_pos().x,y=math.floor(self.object:get_pos().y)+.5,z=self.object:get_pos().z})
			self._oldy = self.object:get_pos().y
		end
		-- reset to original position after dive.
		if self.object:get_pos().y > self._oldy then
			self.object:set_pos({x=self.object:get_pos().x,y=self._oldy,z=self.object:get_pos().z})
			self.object:set_velocity({x=0,y=0,z=0})
			self.object:set_acceleration({x=0,y=0,z=0})
		end
		if self._dive then
			for i=1,2 do
					-- Spray bubbles when there's a fish.
					minetest.add_particle({
						pos = {x=epos["x"]+math.random(-1,1)*math.random()/2,y=epos["y"]+0.1,z=epos["z"]+math.random(-1,1)*math.random()/2},
						velocity = {x=0, y=4, z=0},
						acceleration = {x=0, y=-5, z=0},
						expirationtime = math.random(),
						size = math.random()+0.5,
						collisiondetection = true,
						vertical = false,
						texture = "mcl_particles_bubble.png",
					})
			end
			if self._tick ~= self._waittick then
				self._tick = self._tick + 1
			else
				self._waittick = nil
				self._tick = 0
				self._dive = false
			end
		else if self._waittick == nil then
			-- wait for random number of ticks.
			self._waittick = math.random(50,800)
		else
			if self._tick ~= self._waittick then
				self._tick = self._tick + 1
			else
				--wait time is over time to dive.
				self._dive = true
				self.object:set_velocity({x=0,y=-2,z=0})
				self.object:set_acceleration({x=0,y=5,z=0})
				self._waittick = 30
				self._tick = 0
			end
		end
	end
end

	-- TODO: Destroy when hitting a solid node
	--if self._lastpos.x~=nil then
	--	if (def and def.walkable) or not def then
			--self.object:remove()
		--	return
	--	end
	--end
	--self._lastpos={x=pos.x, y=pos.y, z=pos.z} -- Set lastpos-->Node will be added at last pos outside the node
end

bobber_ENTITY.on_step = bobber_on_step

minetest.register_entity("mcl_fishing:bobber_entity", bobber_ENTITY)

-- If player leaves area, remove bobber.
minetest.register_on_leaveplayer(function(player)
	local objs = minetest.get_objects_inside_radius(player:get_pos(), 250)
	local num = 0
	local ent = nil
	local noent = true

	for n = 1, #objs do
		ent = objs[n]:get_luaentity()
		if ent then
			if ent.player and ent.objtype=="fishing" then
				ent.object:remove()
			elseif ent._thrower and ent.objtype=="fishing" then
				ent.object:remove()
			end
		end
	end
end)

-- If player dies, remove bobber.
minetest.register_on_dieplayer(function(player)
	local objs = minetest.get_objects_inside_radius(player:get_pos(), 250)
	local num = 0
	local ent = nil
	local noent = true

	for n = 1, #objs do
		ent = objs[n]:get_luaentity()
		if ent then
			if ent.player and ent.objtype=="fishing" then
				ent.object:remove()
			elseif ent._thrower and ent.objtype=="fishing" then
				ent.object:remove()
			end
		end
	end
end)

-- Fishing Rod
minetest.register_tool("mcl_fishing:fishing_rod", {
	description = S("Fishing Rod"),
	_tt_help = S("Catches fish in water"),
	_doc_items_longdesc = S("Fishing rods can be used to catch fish."),
	_doc_items_usagehelp = S("Rightclick to launch the bobber. When it sinks right-click again to reel in an item. Who knows what you're going to catch?"),
	groups = { tool=1 },
	inventory_image = "mcl_fishing_fishing_rod.png",
	wield_image = "mcl_fishing_fishing_rod.png^[transformR270",
	wield_scale = { x = 1.5, y = 1.5, z = 1 },
	stack_max = 1,
	on_place = fish,
	on_secondary_use = fish,
	sound = { breaks = "default_tool_breaks" },
})

minetest.register_craft({
	output = "mcl_fishing:fishing_rod",
	recipe = {
		{'','','mcl_core:stick'},
		{'','mcl_core:stick','mcl_mobitems:string'},
		{'mcl_core:stick','','mcl_mobitems:string'},
	}
})
minetest.register_craft({
	output = "mcl_fishing:fishing_rod",
	recipe = {
		{'mcl_core:stick', '', ''},
		{'mcl_mobitems:string', 'mcl_core:stick', ''},
		{'mcl_mobitems:string','','mcl_core:stick'},
	}
})
minetest.register_craft({
	type = "fuel",
	recipe = "mcl_fishing:fishing_rod",
	burntime = 15,
})


-- Fish
minetest.register_craftitem("mcl_fishing:fish_raw", {
	description = S("Raw Fish"),
	_doc_items_longdesc = S("Raw fish is obtained by fishing and is a food item which can be eaten safely. Cooking it improves its nutritional value."),
	inventory_image = "mcl_fishing_fish_raw.png",
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
	stack_max = 64,
	groups = { food=2, eatable = 2 },
	_mcl_saturation = 0.4,
})

minetest.register_craftitem("mcl_fishing:fish_cooked", {
	description = S("Cooked Fish"),
	_doc_items_longdesc = S("Mmh, fish! This is a healthy food item."),
	inventory_image = "mcl_fishing_fish_cooked.png",
	on_place = minetest.item_eat(5),
	on_secondary_use = minetest.item_eat(5),
	stack_max = 64,
	groups = { food=2, eatable=5 },
	_mcl_saturation = 6,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_fishing:fish_cooked",
	recipe = "mcl_fishing:fish_raw",
	cooktime = 10,
})

-- Salmon
minetest.register_craftitem("mcl_fishing:salmon_raw", {
	description = S("Raw Salmon"),
	_doc_items_longdesc = S("Raw salmon is obtained by fishing and is a food item which can be eaten safely. Cooking it improves its nutritional value."),
	inventory_image = "mcl_fishing_salmon_raw.png",
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
	stack_max = 64,
	groups = { food=2, eatable = 2 },
	_mcl_saturation = 0.4,
})

minetest.register_craftitem("mcl_fishing:salmon_cooked", {
	description = S("Cooked Salmon"),
	_doc_items_longdesc = S("This is a healthy food item which can be eaten."),
	inventory_image = "mcl_fishing_salmon_cooked.png",
	on_place = minetest.item_eat(6),
	on_secondary_use = minetest.item_eat(6),
	stack_max = 64,
	groups = { food=2, eatable=6 },
	_mcl_saturation = 9.6,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_fishing:salmon_cooked",
	recipe = "mcl_fishing:salmon_raw",
	cooktime = 10,
})

-- Clownfish
minetest.register_craftitem("mcl_fishing:clownfish_raw", {
	description = S("Clownfish"),
	_doc_items_longdesc = S("Clownfish may be obtained by fishing (and luck) and is a food item which can be eaten safely."),
	inventory_image = "mcl_fishing_clownfish_raw.png",
	on_place = minetest.item_eat(1),
	on_secondary_use = minetest.item_eat(1),
	stack_max = 64,
	groups = { food=2, eatable = 1 },
	_mcl_saturation = 0.2,
})


minetest.register_craftitem("mcl_fishing:pufferfish_raw", {
	description = S("Pufferfish"),
	_tt_help = minetest.colorize("#FFFF00", S("Very poisonous")),
	_doc_items_longdesc = S("Pufferfish are a common species of fish and can be obtained by fishing. They can technically be eaten, but they are very bad for humans. Eating a pufferfish only restores 1 hunger point and will poison you very badly (which drains your health non-fatally) and causes serious food poisoning (which increases your hunger)."),
	inventory_image = "mcl_fishing_pufferfish_raw.png",
	on_place = minetest.item_eat(1),
	on_secondary_use = minetest.item_eat(1),
	stack_max = 64,
	groups = { food=2, eatable=1, brewitem = 1 },
	-- _mcl_saturation = 0.2,
})


minetest.register_on_item_eat(function (hp_change, replace_with_item, itemstack, user, pointed_thing)

	if itemstack:get_name() == "mcl_fishing:pufferfish_raw" then
		mcl_potions.poison_func(user, 1/3, 60)
	end

end )
