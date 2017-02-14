dofile(minetest.get_modpath("mcl_throwing").."/arrow.lua")
dofile(minetest.get_modpath("mcl_throwing").."/throwable.lua")

mcl_throwing = {}

local arrows = {
	["mcl_throwing:arrow"] = "mcl_throwing:arrow_entity",
}

local GRAVITY = 9.81

mcl_throwing.shoot_arrow = function(arrow_item, pos, dir, yaw, shooter)
	local obj = minetest.add_entity({x=pos.x,y=pos.y,z=pos.z}, arrows[arrow_item])
	obj:setvelocity({x=dir.x*19, y=dir.y*19, z=dir.z*19})
	obj:setacceleration({x=dir.x*-3, y=-GRAVITY, z=dir.z*-3})
	obj:setyaw(yaw+math.pi/2)
	minetest.sound_play("mcl_throwing_bow_shoot", {pos=pos})
	if shooter ~= nil then
		if obj:get_luaentity().player == "" then
			obj:get_luaentity().player = shooter
		end
		obj:get_luaentity().node = shooter:get_inventory():get_stack("main", 1):get_name()
	end
	return obj
end

local player_shoot_arrow = function(itemstack, player)
	for arrow_item, arrow_entity in pairs(arrows) do
		if player:get_inventory():get_stack("main", player:get_wield_index()+1):get_name() == arrow_item then
			if not minetest.setting_getbool("creative_mode") then
				player:get_inventory():remove_item("main", arrow_item)
			end
			local playerpos = player:getpos()
			local dir = player:get_look_dir()
			local yaw = player:get_look_horizontal()

			mcl_throwing.shoot_arrow(arrow_item, {x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, dir, yaw, player)
			return true
		end
	end
	return false
end

minetest.register_tool("mcl_throwing:bow", {
	description = "Bow",
	inventory_image = "mcl_throwing_bow.png",
    stack_max = 1,
	on_place = function(itemstack, placer, pointed_thing)
		local wear = itemstack:get_wear()
		itemstack:replace("mcl_throwing:bow_0")
		itemstack:add_wear(wear)
		return itemstack
	end,
	groups = {weapon=1,weapon_ranged=1},
	on_use = function(itemstack, user, pointed_thing)
		local wear = itemstack:get_wear()
		itemstack:add_wear(wear)
		if player_shoot_arrow(itemstack, user, pointed_thing) then
			if not minetest.setting_getbool("creative_mode") then
				itemstack:add_wear(65535/385)
			end
		end
	return itemstack
	end,
})

minetest.register_tool("mcl_throwing:bow_0", {
	description = "Bow",
	inventory_image = "mcl_throwing_bow_0.png",
    stack_max = 1,
	groups = {not_in_creative_inventory=1, not_in_craft_guide=1},
	on_place = function(itemstack, placer, pointed_thing)
		local wear = itemstack:get_wear()
		itemstack:replace("mcl_throwing:bow_1")
		itemstack:add_wear(wear)
		return itemstack
	end,
		on_use = function(itemstack, user, pointed_thing)
		local wear = itemstack:get_wear()
		itemstack:add_wear(wear)
		if player_shoot_arrow(itemstack, user, pointed_thing) then
			if not minetest.setting_getbool("creative_mode") then
				itemstack:add_wear(65535/385)
			end
		end
	return itemstack
	end,
})

minetest.register_tool("mcl_throwing:bow_1", {
	description = "Bow",
	inventory_image = "mcl_throwing_bow_1.png",
    stack_max = 1,
	groups = {not_in_creative_inventory=1, not_in_craft_guide=1},
	on_place = function(itemstack, placer, pointed_thing)
		local wear = itemstack:get_wear()
		itemstack:replace("mcl_throwing:bow_2")
		itemstack:add_wear(wear)
		return itemstack
	end,
	on_use = function(itemstack, user, pointed_thing)
		local wear = itemstack:get_wear()
		itemstack:add_wear(wear)
		if player_shoot_arrow(itemstack, user, pointed_thing) then
			if not minetest.setting_getbool("creative_mode") then
				itemstack:add_wear(65535/385)
			end
		end
	return itemstack
	end,
})

minetest.register_tool("mcl_throwing:bow_2", {
	description = "Bow",
	inventory_image = "mcl_throwing_bow_2.png",
    stack_max = 1,
	groups = {not_in_creative_inventory=1, not_in_craft_guide=1},
	on_use = function(itemstack, user, pointed_thing)
		local wear = itemstack:get_wear()
		itemstack:replace("mcl_throwing:bow")
		itemstack:add_wear(wear)
		if player_shoot_arrow(itemstack, user, pointed_thing) then
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
