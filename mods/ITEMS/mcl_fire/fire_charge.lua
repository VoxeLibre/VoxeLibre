local S = minetest.get_translator("mcl_fire")

local get_node = minetest.get_node
local add_entity = minetest.add_entity

-- Fire Charge
minetest.register_craftitem("mcl_fire:fire_charge", {
	description = S("Fire Charge"),
	_tt_help = S("Dispenser projectile").."\n"..S("Starts fires and ignites blocks"), 
	_doc_items_longdesc = S("Fire charges are primarily projectiles which can be launched from dispensers, they will fly in a straight line and burst into a fire on impact. Alternatively, they can be used to ignite fires directly."),
	_doc_items_usagehelp = S("Put the fire charge into a dispenser and supply it with redstone power to launch it. To ignite a fire directly, simply place the fire charge on the ground, which uses it up."),
	inventory_image = "mcl_fire_fire_charge.png",
	liquids_pointable = false,
	stack_max = 64,
	on_place = function(itemstack, user, pointed_thing)
		-- Use pointed node's on_rightclick function first, if present
		local node = get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
			end
		end

		-- Check protection
		local protname = user:get_player_name()
		if minetest.is_protected(pointed_thing.under, protname) then
			minetest.record_protection_violation(pointed_thing.under, protname)
			return itemstack
		end

		-- Ignite/light fire
		if pointed_thing.type == "node" then
			local nodedef = minetest.registered_nodes[node.name]
			if nodedef and nodedef._on_ignite then
				local overwrite = nodedef._on_ignite(user, pointed_thing)
				if not overwrite then
					mcl_fire.set_fire(pointed_thing, user, false)
				end
			else
				mcl_fire.set_fire(pointed_thing, user, false)
			end
			if not minetest.is_creative_enabled(user:get_player_name()) then
				itemstack:take_item()
			end
		end
		return itemstack
	end,
	_on_dispense = function(stack, pos, droppos, dropnode, dropdir)
		-- Throw fire charge
		local shootpos = vector.add(pos, vector.multiply(dropdir, 0.51))
		local fireball = add_entity(shootpos, "mobs_mc:blaze_fireball")
		local ent = fireball:get_luaentity()
		ent._shot_from_dispenser = true
		local v = ent.velocity or 1
		fireball:set_velocity(vector.multiply(dropdir, v))
		ent.switch = 1
		stack:take_item()
	end,
})

minetest.register_craft({
	type = 'shapeless',
	output = 'mcl_fire:fire_charge 3',
	recipe = { 'mcl_mobitems:blaze_powder', 'group:coal', 'mcl_mobitems:gunpowder' },
})
