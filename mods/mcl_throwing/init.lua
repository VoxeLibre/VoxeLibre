
dofile(minetest.get_modpath("mcl_throwing").."/arrow.lua")
dofile(minetest.get_modpath("mcl_throwing").."/throwable.lua")

local arrows = {
	{"mcl_throwing:arrow", "mcl_throwing:arrow_entity"},
}

local GRAVITY = 9.81

local mcl_throwing_shoot_arrow = function(itemstack, player)
	for _,arrow in ipairs(arrows) do
		if player:get_inventory():get_stack("main", player:get_wield_index()+1):get_name() == arrow[1] then
			if not minetest.setting_getbool("creative_mode") then
				player:get_inventory():remove_item("main", arrow[1])
			end
			local playerpos = player:getpos()
			local obj = minetest.add_entity({x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, arrow[2])
			local dir = player:get_look_dir()
			obj:setvelocity({x=dir.x*19, y=dir.y*19, z=dir.z*19})
			obj:setacceleration({x=dir.x*-3, y=-GRAVITY, z=dir.z*-3})
			obj:setyaw(player:get_look_yaw()+math.pi)
			minetest.sound_play("mcl_throwing_bow_shoot", {pos=playerpos})
			if obj:get_luaentity().player == "" then
				obj:get_luaentity().player = player
			end
			obj:get_luaentity().node = player:get_inventory():get_stack("main", 1):get_name()
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
		if mcl_throwing_shoot_arrow(itemstack, user, pointed_thing) then
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
	groups = {not_in_creative_inventory=1},
	on_place = function(itemstack, placer, pointed_thing)
		local wear = itemstack:get_wear()
		itemstack:replace("mcl_throwing:bow_1")
		itemstack:add_wear(wear)
		return itemstack
	end,
		on_use = function(itemstack, user, pointed_thing)
		local wear = itemstack:get_wear()
		itemstack:add_wear(wear)
		if mcl_throwing_shoot_arrow(itemstack, user, pointed_thing) then
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
	groups = {not_in_creative_inventory=1},
	on_place = function(itemstack, placer, pointed_thing)
		local wear = itemstack:get_wear()
		itemstack:replace("mcl_throwing:bow_2")
		itemstack:add_wear(wear)
		return itemstack
	end,
	on_use = function(itemstack, user, pointed_thing)
		local wear = itemstack:get_wear()
		itemstack:add_wear(wear)
		if mcl_throwing_shoot_arrow(itemstack, user, pointed_thing) then
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
	groups = {not_in_creative_inventory=1},
	on_use = function(itemstack, user, pointed_thing)
		local wear = itemstack:get_wear()
		itemstack:replace("mcl_throwing:bow")
		itemstack:add_wear(wear)
		if mcl_throwing_shoot_arrow(itemstack, user, pointed_thing) then
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
