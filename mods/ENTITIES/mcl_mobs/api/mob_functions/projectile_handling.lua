local GRAVITY             = minetest.settings:get("movement_gravity")-- + 9.81

mobs.shoot_projectile_handling = function(arrow_item, pos, dir, yaw, shooter, power, damage, is_critical, bow_stack, collectable, gravity)
	local obj = minetest.add_entity({x=pos.x,y=pos.y,z=pos.z}, arrow_item.."_entity")
	if power == nil then
		power = 19
	end
	if damage == nil then
		damage = 3
	end

    gravity = gravity or -GRAVITY

	local knockback
	if bow_stack then
		local enchantments = mcl_enchanting.get_enchantments(bow_stack)
		if enchantments.power then
			damage = damage + (enchantments.power + 1) / 4
		end
		if enchantments.punch then
			knockback = enchantments.punch * 3
		end
		if enchantments.flame then
			mcl_burning.set_on_fire(obj, math.huge)
		end
	end
	obj:set_velocity({x=dir.x*power, y=dir.y*power, z=dir.z*power})
	obj:set_acceleration({x=0, y=gravity, z=0})
	obj:set_yaw(yaw-math.pi/2)
	local le = obj:get_luaentity()
	le._shooter = shooter
	le._damage = damage
	le._is_critical = is_critical
	le._startpos = pos
	le._knockback = knockback
	le._collectable = collectable

    --play custom shoot sound
    if shooter ~= nil and shooter.shoot_sound then
        minetest.sound_play(shooter.shoot_sound, {pos=pos, max_hear_distance=16}, true)
    end

	return obj
end