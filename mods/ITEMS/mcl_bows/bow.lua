local S = core.get_translator(core.get_current_modname())

local BOW_DURABILITY = 385

-- Charging time in microseconds
local BOW_CHARGE_TIME_HALF = 200000 -- bow level 1
local BOW_CHARGE_TIME_FULL = 500000 -- bow level 2 (full charge)

-- Factor to multiply with player speed while player uses bow
-- This emulates the sneak speed.
local PLAYER_USE_BOW_SPEED = tonumber(minetest.settings:get("movement_speed_crouch")) / tonumber(minetest.settings:get("movement_speed_walk"))

-- TODO: Use Minecraft speed (ca. 53 m/s)
-- Currently nerfed because at full speed the arrow would easily get out of the range of the loaded map.
local BOW_MAX_SPEED = 40

--[[ Store the charging state of each player.
keys: player name
value:
nil = not charging or player not existing
number: currently charging, the number is the time from minetest.get_us_time
             in which the charging has started
]]
local bow_load = {}

-- Another player table, this one stores the wield index of the bow being charged
local bow_index = {}

-- And yet another player table, this one stores the load level of the bow
local bow_load_level = {}

-- define FOV modifier(s)
mcl_fovapi.register_modifier({
	name = "bowcomplete",
	fov_factor = 0.8,
	time = 1,
	reset_time = 0.3,
	is_multiplier = true,
})

function mcl_bows.shoot_arrow(arrow_item, pos, dir, yaw, shooter, power, damage, is_critical, bow_stack, collectable)
	power = power or BOW_MAX_SPEED
	damage = damage or 3

	local obj = vl_projectile.create(arrow_item.."_entity", {
		pos = pos,
		dir = dir,
		velocity = power,
		owner = shooter,
	})

	local knockback
	if bow_stack then
		local enchantments = mcl_enchanting.get_enchantments(bow_stack)
		if enchantments.power then
			damage = damage + (enchantments.power + 1) / 4
		end
		if enchantments.punch then
			knockback = enchantments.punch * 3
		else
			knockback = 1
		end
		if enchantments.flame then
			mcl_burning.set_on_fire(obj, math.huge)
		end
	end
	local le = obj:get_luaentity()
	le._source_object = shooter
	le._damage = damage
	le._is_critical = is_critical
	le._knockback = knockback
	le._collectable = collectable
	le._arrow_item = arrow_item
	local item_def = core.registered_items[le._arrow_item]
	if item_def and item_def._arrow_image then
		obj:set_properties({textures = item_def._arrow_image})
	end
	core.sound_play("mcl_bows_bow_shoot", {pos=pos, max_hear_distance=16}, true)
	if shooter and shooter:is_player() then
		if le.player == "" then
			le.player = shooter
		end
		le.node = shooter:get_inventory():get_stack("main", 1):get_name()
	end
	return obj
end

local function get_arrow(player)
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

local function player_shoot_arrow(itemstack, player, power, damage, is_critical)
	local arrow_stack, arrow_stack_id = get_arrow(player)
	local arrow_itemstring
	local has_infinity_enchantment = mcl_enchanting.has_enchantment(player:get_wielded_item(), "infinity")
	local infinity_used = false

	if minetest.is_creative_enabled(player:get_player_name()) then
		if arrow_stack then
			arrow_itemstring = arrow_stack:get_name()
		else
			arrow_itemstring = "mcl_bows:arrow"
		end
		infinity_used = true
	else
		if not arrow_stack then
			return false
		end
		arrow_itemstring = arrow_stack:get_name()
		if has_infinity_enchantment and minetest.get_item_group(arrow_itemstring, "ammo_bow_regular") > 0 then
			infinity_used = true
		else
			arrow_stack:take_item()
		end
		local inv = player:get_inventory()
		inv:set_stack("main", arrow_stack_id, arrow_stack)
	end
	if not arrow_itemstring then
		return false
	end
	local playerpos = player:get_pos()
	local dir = player:get_look_dir()
	local yaw = player:get_look_horizontal()

	mcl_bows.shoot_arrow(arrow_itemstring, {x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, dir, yaw, player, power, damage, is_critical, player:get_wielded_item(), not infinity_used)
	return true
end

-- Bow item, uncharged state
minetest.register_tool("mcl_bows:bow", {
	description = S("Bow"),
	_tt_help = S("Launches arrows"),
	_doc_items_longdesc = S("Bows are ranged weapons to shoot arrows at your foes.").."\n"..
S("The speed and damage of the arrow increases the longer you charge. The regular damage of the arrow is between 1 and 9. At full charge, there's also a 20% of a critical hit, dealing 10 damage instead."),
	_doc_items_usagehelp = S("To use the bow, you first need to have at least one arrow anywhere in your inventory (unless in Creative Mode). Hold down the right mouse button (or the zoom key) to charge, release to shoot."),
	_doc_items_durability = BOW_DURABILITY,
	inventory_image = "mcl_bows_bow.png",
	wield_scale = mcl_vars.tool_wield_scale,
	stack_max = 1,
	range = 4,
	-- Trick to disable digging as well
	on_use = function() return end,
	on_place = function(itemstack, player, pointed_thing)
		if pointed_thing and pointed_thing.type == "node" then
			-- Call on_rightclick if the pointed node defines it
			local node = minetest.get_node(pointed_thing.under)
			if player and not player:get_player_control().sneak then
				if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
					return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, player, itemstack) or itemstack
				end
			end
		end

		itemstack:get_meta():set_string("active", "true")
		return itemstack
	end,
	on_secondary_use = function(itemstack)
		itemstack:get_meta():set_string("active", "true")
		return itemstack
	end,
	groups = {weapon=1,weapon_ranged=1,bow=1,cannot_block=1,enchantability=1},
	touch_interaction = "short_dig_long_place",
	_mcl_uses = 385,
})

-- Iterates through player inventory and resets all the bows in "charging" state back to their original stage
local function reset_bows(player)
	local inv = player:get_inventory()
	local list = inv:get_list("main")
	for place, stack in pairs(list) do
		if stack:get_name() == "mcl_bows:bow" or stack:get_name() == "mcl_bows:bow_enchanted" then
			stack:get_meta():set_string("active", "")
			stack:get_meta():set_string("inventory_image", "")
		elseif stack:get_name()=="mcl_bows:bow_0" or stack:get_name()=="mcl_bows:bow_1" or stack:get_name()=="mcl_bows:bow_2" then
			stack:set_name("mcl_bows:bow")
			stack:get_meta():set_string("active", "")
			list[place] = stack
		elseif stack:get_name()=="mcl_bows:bow_0_enchanted" or stack:get_name()=="mcl_bows:bow_1_enchanted" or stack:get_name()=="mcl_bows:bow_2_enchanted" then
			stack:set_name("mcl_bows:bow_enchanted")
			stack:get_meta():set_string("active", "")
			list[place] = stack
		end
	end
	inv:set_list("main", list)
end

-- Resets the bow charging state and player speed. To be used when the player is no longer charging the bow
local function reset_bow_state(player, also_reset_bows)
	-- clear the FOV change from the player.
	mcl_fovapi.remove_modifier(player, "bowcomplete") -- for the complete zoom in FOV Modifier.

	bow_load[player:get_player_name()] = nil
	bow_index[player:get_player_name()] = nil
	bow_load_level[player:get_player_name()] = nil
	if minetest.get_modpath("playerphysics") then
		playerphysics.remove_physics_factor(player, "speed", "mcl_bows:use_bow")
	end
	if also_reset_bows then
		reset_bows(player)
	end
end

-- Old Bows in charging state, purely for conversion if some accidentally stayed behind
for level=0, 2 do
	minetest.register_tool("mcl_bows:bow_"..level, {
		description = S("Bow"),
		_doc_items_create_entry = false,
		inventory_image = "mcl_bows_bow.png^vl_unknown.png",
		wield_scale = mcl_vars.tool_wield_scale,
		stack_max = 1,
		range = 0, -- Pointing range to 0 to prevent punching with bow :D
		groups = {not_in_creative_inventory=1, not_in_craft_guide=1, bow=1, cannot_block=1, enchantability=1},
		-- Trick to disable digging as well
		on_use = function(_, user) reset_bow_state(user, true) return end,
		on_drop = function(itemstack, dropper, pos)
			reset_bow_state(dropper)
			itemstack:get_meta():set_string("active", "")
			if mcl_enchanting.is_enchanted(itemstack:get_name()) then
				itemstack:set_name("mcl_bows:bow_enchanted")
			else
				itemstack:set_name("mcl_bows:bow")
			end
			minetest.item_drop(itemstack, dropper, pos)
			itemstack:take_item()
			return itemstack
		end,
		-- Prevent accidental interaction with itemframes and other nodes
		on_place = function(itemstack, placer)
			reset_bow_state(placer, true)
			return itemstack
		end,
		touch_interaction = "short_dig_long_place",
		_mcl_uses = 385,
	})
end


controls.register_on_release(function(player, key, time)
	if key~="RMB" and key~="zoom" then return end
	local wielditem = player:get_wielded_item()
	local name = wielditem:get_name()
	if name == "mcl_bows:bow" or name == "mcl_bows:bow_enchanted" then
		local meta = wielditem:get_meta()
		if not core.is_yes(meta:get("active")) then
			reset_bow_state(player)
			return
		end
		local enchanted = mcl_enchanting.is_enchanted(name)
		local speed, damage
		local p_load = bow_load[player:get_player_name()]
		local charge
		-- Type sanity check
		if type(p_load) == "number" then
			charge = minetest.get_us_time() - p_load
		else
			-- In case something goes wrong ...
			-- Just assume minimum charge.
			charge = 0
			minetest.log("warning", "[mcl_bows] Player "..player:get_player_name().." fires arrow with non-numeric bow_load!")
		end
		charge = math.max(math.min(charge, BOW_CHARGE_TIME_FULL), 0)

		local charge_ratio = charge / BOW_CHARGE_TIME_FULL
		charge_ratio = math.max(math.min(charge_ratio, 1), 0)

		-- Calculate damage and speed
		-- Fully charged
		local is_critical = false
		if charge >= BOW_CHARGE_TIME_FULL then
			speed = BOW_MAX_SPEED
			local r = math.random(1,5) + mcl_luck.get_luck(player:get_player_name())
			if r > 4 then
				-- 20% chance for critical hit (by default)
				damage = 10 + math.floor((r-5)/5) -- mega crit (over crit) with high luck
				is_critical = true
			else
				damage = 9
			end
		-- Partially charged
		else
			-- Linear speed and damage increase
			speed = math.max(4, BOW_MAX_SPEED * charge_ratio)
			damage = math.max(1, math.floor(9 * charge_ratio))
		end

		local has_shot = player_shoot_arrow(wielditem, player, speed, damage, is_critical)

		if has_shot and not minetest.is_creative_enabled(player:get_player_name()) then
			local durability = BOW_DURABILITY
			local unbreaking = mcl_enchanting.get_enchantment(wielditem, "unbreaking")
			if unbreaking > 0 then
				durability = durability * (unbreaking + 1)
			end
			wielditem:add_wear(65535/durability)
			tt.reload_itemstack_description(wielditem) -- update tooltip
		end
		player:set_wielded_item(wielditem)
		reset_bow_state(player, true)
	end
end)

controls.register_on_hold(function(player, key, time)
	local name = player:get_player_name()
	local creative = minetest.is_creative_enabled(name)
	if (key ~= "RMB" and key ~= "zoom") or not (creative or get_arrow(player)) then
		return
	end
	local wielditem = player:get_wielded_item()
	local meta = wielditem:get_meta()
	if bow_load[name] == nil
		and (wielditem:get_name()=="mcl_bows:bow" or wielditem:get_name()=="mcl_bows:bow_enchanted")
		and (core.is_yes(meta:get("active")) or key == "zoom") and (creative or get_arrow(player)) then
			local enchanted = mcl_enchanting.is_enchanted(wielditem:get_name())
			local im_string = "mcl_bows_bow_0.png"
			if enchanted then im_string = im_string .. mcl_enchanting.overlay end
			meta:set_string("inventory_image", im_string)
			player:set_wielded_item(wielditem)
			if minetest.get_modpath("playerphysics") then
				-- Slow player down when using bow
				playerphysics.add_physics_factor(player, "speed", "mcl_bows:use_bow", PLAYER_USE_BOW_SPEED)
			end
			bow_load[name] = minetest.get_us_time()
			bow_load_level[name] = 0
			bow_index[name] = player:get_wield_index()

			-- begin Bow Zoom.
			mcl_fovapi.apply_modifier(player, "bowcomplete")
	else
		if player:get_wield_index() == bow_index[name] then
			if type(bow_load[name]) == "number" then
				local level = 0
				if minetest.get_us_time() - bow_load[name] >= BOW_CHARGE_TIME_FULL then
					if bow_load_level[name] == 2 then return end
					level = 2
					bow_load_level[name] = 2
				elseif minetest.get_us_time() - bow_load[name] >= BOW_CHARGE_TIME_HALF then
					if bow_load_level[name] == 1 then return end
					level = 1
					bow_load_level[name] = 1
				else return end
				local im_string = "mcl_bows_bow_"..level..".png"
				if wielditem:get_name() == "mcl_bows:bow_enchanted" then
					im_string = im_string .. mcl_enchanting.overlay
				end
				meta:set_string("inventory_image", im_string)
			else
				meta:set_string("inventory_image", "")
				bow_load_level[name] = nil
			end
			player:set_wielded_item(wielditem)
		elseif bow_load[name] then
			reset_bow_state(player, true)
		end
	end
end)

minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local wielditem = player:get_wielded_item()
		local wieldindex = player:get_wield_index()
		if type(bow_load[name]) == "number"
				and ((wielditem:get_name()~="mcl_bows:bow" and wielditem:get_name()~="mcl_bows:bow_enchanted")
				or wieldindex ~= bow_index[name]) then
			reset_bow_state(player, true)
		end
	end
end)

minetest.register_on_joinplayer(function(player)
	reset_bows(player)
end)

minetest.register_on_leaveplayer(function(player)
	reset_bow_state(player, true)
end)

if minetest.get_modpath("mcl_core") and minetest.get_modpath("mcl_mobitems") then
	minetest.register_craft({
		output = "mcl_bows:bow",
		recipe = {
			{"", "mcl_core:stick", "mcl_mobitems:string"},
			{"mcl_core:stick", "", "mcl_mobitems:string"},
			{"", "mcl_core:stick", "mcl_mobitems:string"},
		}
	})
	minetest.register_craft({
		output = "mcl_bows:bow",
		recipe = {
			{"mcl_mobitems:string", "mcl_core:stick", ""},
			{"mcl_mobitems:string", "", "mcl_core:stick"},
			{"mcl_mobitems:string", "mcl_core:stick", ""},
		}
	})
end

minetest.register_craft({
	type = "fuel",
	recipe = "group:bow",
	burntime = 15,
})
