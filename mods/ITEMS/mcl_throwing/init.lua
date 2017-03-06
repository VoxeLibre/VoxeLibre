mcl_throwing = {}

dofile(minetest.get_modpath("mcl_throwing").."/arrow.lua")
dofile(minetest.get_modpath("mcl_throwing").."/throwable.lua")

local arrows = {
	["mcl_throwing:arrow"] = "mcl_throwing:arrow_entity",
}

local GRAVITY = 9.81

mcl_throwing.shoot_arrow = function(arrow_item, pos, dir, yaw, shooter, power, damage)
	local obj = minetest.add_entity({x=pos.x,y=pos.y,z=pos.z}, arrows[arrow_item])
	if power == nil then
		power = 19
	end
	if damage == nil then
		damage = 3
	end
	obj:setvelocity({x=dir.x*power, y=dir.y*power, z=dir.z*power})
	obj:setacceleration({x=dir.x*-3, y=-GRAVITY, z=dir.z*-3})
	obj:setyaw(yaw-math.pi/2)
	local le = obj:get_luaentity()
	le._shooter = shooter
	le._damage = damage
	le._startpos = pos
	minetest.sound_play("mcl_throwing_bow_shoot", {pos=pos})
	if shooter ~= nil then
		if obj:get_luaentity().player == "" then
			obj:get_luaentity().player = shooter
		end
		obj:get_luaentity().node = shooter:get_inventory():get_stack("main", 1):get_name()
	end
	return obj
end

local get_arrow = function(player)
	local inv = player:get_inventory()
	local arrow_stack, arrow_stack_id
	for i=1, inv:get_size("main") do
		local it = inv:get_stack("main", i)
		if not it:is_empty() and minetest.get_item_group(it:get_name(), "ammo_bow") ~= 0 then
			arrow_stack = it
			arrow_stack_id = i
			break
		end
	end
	return arrow_stack, arrow_stack_id
end

local player_shoot_arrow = function(itemstack, player, power, damage)
	local arrow_stack, arrow_stack_id = get_arrow(player)
	local arrow_itemstring
	if not minetest.setting_getbool("creative_mode") then
		if not arrow_stack then
			return false
		end
		arrow_itemstring = arrow_stack:get_name()
		arrow_stack:take_item()
		local inv = player:get_inventory()
		inv:set_stack("main", arrow_stack_id, arrow_stack)
	end
	local playerpos = player:getpos()
	local dir = player:get_look_dir()
	local yaw = player:get_look_horizontal()

	if not arrow_itemstring then
		arrow_itemstring = "mcl_throwing:arrow"
	end
	mcl_throwing.shoot_arrow(arrow_itemstring, {x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, dir, yaw, player, power, damage)
	return true
end

local powerup_function = function(nextbow)
	return function(itemstack, placer, pointed_thing)
		-- Use pointed node's on_rightclick function first, if present
		if pointed_thing.type == "node" then
			local node = minetest.get_node(pointed_thing.under)
			if placer and not placer:get_player_control().sneak then
				if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
					return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
				end
			end
		end

		if get_arrow(placer) ~= nil then
			local wear = itemstack:get_wear()
			itemstack:replace(nextbow)
			itemstack:set_wear(wear)
		end
		return itemstack
	end
end

minetest.register_tool("mcl_throwing:bow", {
	description = "Bow",
	inventory_image = "mcl_throwing_bow.png",
	stack_max = 1,
	on_place = powerup_function("mcl_throwing:bow_0"),
	on_secondary_use = powerup_function("mcl_throwing:bow_0"),
	groups = {weapon=1,weapon_ranged=1},
})

minetest.register_tool("mcl_throwing:bow_0", {
	description = "Bow",
	_doc_items_create_entry = false,
	inventory_image = "mcl_throwing_bow_0.png",
	stack_max = 1,
	groups = {not_in_creative_inventory=1, not_in_craft_guide=1},
	on_place = powerup_function("mcl_throwing:bow_1"),
	on_secondary_use = powerup_function("mcl_throwing:bow_1"),
	on_use = function(itemstack, user, pointed_thing)
		local wear = itemstack:get_wear()
		itemstack:replace("mcl_throwing:bow")
		itemstack:set_wear(wear)
		if player_shoot_arrow(itemstack, user, 4, 1) then
			if not minetest.setting_getbool("creative_mode") then
				itemstack:add_wear(65535/385)
			end
		end
		return itemstack
	end,
})

minetest.register_tool("mcl_throwing:bow_1", {
	description = "Bow",
	_doc_items_create_entry = false,
	inventory_image = "mcl_throwing_bow_1.png",
	stack_max = 1,
	groups = {not_in_creative_inventory=1, not_in_craft_guide=1},
	on_place = powerup_function("mcl_throwing:bow_2"),
	on_secondary_use = powerup_function("mcl_throwing:bow_2"),
	on_use = function(itemstack, user, pointed_thing)
		local wear = itemstack:get_wear()
		itemstack:replace("mcl_throwing:bow")
		itemstack:set_wear(wear)
		if player_shoot_arrow(itemstack, user, 16, 2) then
			if not minetest.setting_getbool("creative_mode") then
				itemstack:add_wear(65535/385)
			end
		end
		return itemstack
	end,
})

minetest.register_tool("mcl_throwing:bow_2", {
	description = "Bow",
	_doc_items_create_entry = false,
	inventory_image = "mcl_throwing_bow_2.png",
	stack_max = 1,
	groups = {not_in_creative_inventory=1, not_in_craft_guide=1},
	on_use = function(itemstack, user, pointed_thing)
		local wear = itemstack:get_wear()
		itemstack:replace("mcl_throwing:bow")
		itemstack:set_wear(wear)
		local r = math.random(1,5)
		local damage
		-- Damage and range have been nerfed because the arrow charges very quickly
		-- TODO: Use Minecraft damage and range (9-10 @ ca. 53 m/s)
		if r == 1 then
			-- 20% chance to do more damage
			damage = 5
		else
			damage = 4
		end
		if player_shoot_arrow(itemstack, user, 26, damage) then
			if not minetest.setting_getbool("creative_mode") then
				itemstack:add_wear(65535/385)
			end
		end
		return itemstack
	end,
})

minetest.register_craft({
	output = 'mcl_throwing:bow',
	recipe = {
		{'', 'mcl_core:stick', 'mcl_mobitems:string'},
		{'mcl_core:stick', '', 'mcl_mobitems:string'},
		{'', 'mcl_core:stick', 'mcl_mobitems:string'},
	}
})
minetest.register_craft({
	output = 'mcl_throwing:bow',
	recipe = {
		{'mcl_mobitems:string', 'mcl_core:stick', ''},
		{'mcl_mobitems:string', '', 'mcl_core:stick'},
		{'mcl_mobitems:string', 'mcl_core:stick', ''},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_throwing:bow",
	burntime = 15,
})
