-- Keep these for backwards compatibility
function mcl_hunger.save_hunger(player)
	mcl_hunger.set_hunger_raw(player)
end
function mcl_hunger.load_hunger(player)
	mcl_hunger.get_hunger_raw(player)
end

-- wrapper for minetest.item_eat (this way we make sure other mods can't break this one)
local org_eat = core.do_item_eat
core.do_item_eat = function(hp_change, replace_with_item, itemstack, user, pointed_thing)
	local old_itemstack = itemstack
	itemstack = mcl_hunger.eat(hp_change, replace_with_item, itemstack, user, pointed_thing)
	for _, callback in pairs(core.registered_on_item_eats) do
		local result = callback(hp_change, replace_with_item, itemstack, user, pointed_thing, old_itemstack)
		if result then
			return result
		end
	end
	return itemstack
end

-- food functions
local food = mcl_hunger.food

function mcl_hunger.register_food(name, hunger_change, replace_with_item, poisen, heal, sound)
	food[name] = {}
	food[name].saturation = hunger_change	-- hunger points added
	food[name].replace = replace_with_item	-- what item is given back after eating
	food[name].poisen = poisen				-- time its poisening
	food[name].healing = heal				-- amount of HP
	food[name].sound = sound				-- special sound that is played when eating
end

function mcl_hunger.eat(hp_change, replace_with_item, itemstack, user, pointed_thing)
	local item = itemstack:get_name()
	local def = food[item]
	if not def then
		def = {}
		if type(hp_change) ~= "number" then
			hp_change = 1
			core.log("error", "Wrong on_use() definition for item '" .. item .. "'")
		end
		def.saturation = hp_change
		def.replace = replace_with_item
	end
	local func = mcl_hunger.item_eat(def.saturation, def.replace, def.poisen, def.healing, def.sound)
	return func(itemstack, user, pointed_thing)
end

-- Poison player
local function poisenp(tick, time, time_left, player)
	-- First check if player is still there
	if not player:is_player() then
		return
	end
	time_left = time_left + tick
	if time_left < time then
		minetest.after(tick, poisenp, tick, time, time_left, player)
	else
		mcl_hunger.poisonings[player:get_player_name()] = mcl_hunger.poisonings[player:get_player_name()] - 1
		if mcl_hunger.poisonings[player:get_player_name()] <= 0 then
			-- Reset HUD bar color
			hb.change_hudbar(player, "health", nil, nil, "hudbars_icon_health.png", nil, "hudbars_bar_health.png")
		end
	end
	if player:get_hp()-1 > 0 then
		player:set_hp(player:get_hp()-1)
	end
	
end

function mcl_hunger.item_eat(hunger_change, replace_with_item, poisen, heal, sound)
	return function(itemstack, user, pointed_thing)
		if itemstack:take_item() ~= nil and user ~= nil then
			local name = user:get_player_name()
			local h = tonumber(mcl_hunger.hunger[name])
			local hp = user:get_hp()
			minetest.sound_play({name = sound or "mcl_hunger_eat_generic", gain = 1}, {pos=user:getpos(), max_hear_distance = 16})

			-- Saturation
			if h < 20 and hunger_change then
				h = h + hunger_change
				if h > 20 then h = 20 end
				mcl_hunger.hunger[name] = h
				mcl_hunger.set_hunger_raw(user)
			end
			-- Healing
			if hp < 20 and heal then
				hp = hp + heal
				if hp > 20 then hp = 20 end
				user:set_hp(hp)
			end
			-- Poison
			if poisen then
				-- Set poison bar
				hb.change_hudbar(user, "health", nil, nil, "hbhunger_icon_health_poison.png", nil, "hbhunger_bar_health_poison.png")
				mcl_hunger.poisonings[name] = mcl_hunger.poisonings[name] + 1
				poisenp(1, poisen, 0, user)
			end

			--sound:eat
			itemstack:add_item(replace_with_item)
		end
		return itemstack
	end
end

-- player-action based hunger changes
function mcl_hunger.handle_node_actions(pos, oldnode, player, ext)
	-- is_fake_player comes from the pipeworks, we are not interested in those
	if not player or not player:is_player() or player.is_fake_player == true then
		return
	end
	local name = player:get_player_name()
	local exhaus = mcl_hunger.exhaustion[name]
	if exhaus == nil then return end
	local new = mcl_hunger.EXHAUST_PLACE
	-- placenode event
	if not ext then
		new = mcl_hunger.EXHAUST_DIG
	end
	-- assume its send by main timer when movement detected
	if not pos and not oldnode then
		new = mcl_hunger.EXHAUST_MOVE
	end
	exhaus = exhaus + new
	if exhaus > mcl_hunger.EXHAUST_LVL then
		exhaus = 0
		local h = tonumber(mcl_hunger.hunger[name])
		h = h - 1
		if h < 0 then h = 0 end
		mcl_hunger.hunger[name] = h
		mcl_hunger.set_hunger_raw(player)
	end
	mcl_hunger.exhaustion[name] = exhaus
end

minetest.register_on_placenode(mcl_hunger.handle_node_actions)
minetest.register_on_dignode(mcl_hunger.handle_node_actions)
