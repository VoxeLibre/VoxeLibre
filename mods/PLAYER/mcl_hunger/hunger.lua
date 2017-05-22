-- wrapper for minetest.item_eat (this way we make sure other mods can't break this one)
local org_eat = core.do_item_eat
core.do_item_eat = function(hp_change, replace_with_item, itemstack, user, pointed_thing)
	-- Call on_rightclick if the pointed node defines it
	if pointed_thing.type == "node" then
		local node = minetest.get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
			end
		end
	end

	local old_itemstack = itemstack

	local name = user:get_player_name()

	-- Special foodstuffs like the cake may disable the eating delay
	local no_eat_delay = minetest.get_item_group(itemstack:get_name(), "no_eat_delay") == 1

	-- Allow eating only after a delay of 2 seconds. This prevents eating as an excessive speed.
	-- FIXME: time() is not a precise timer, so the actual delay may be +- 1 second, depending on which fraction
	-- of the second the player made the first eat.
	-- FIXME: In singleplayer, there's a cheat to circumvent this, simply by pausing the game between eats.
	-- This is because os.time() obviously does not care about the pause. A fix needs a different timer mechanism.
	if no_eat_delay or (mcl_hunger.last_eat[name] < 0) or (os.difftime(os.time(), mcl_hunger.last_eat[name]) >= 2)  then
		itemstack = mcl_hunger.eat(hp_change, replace_with_item, itemstack, user, pointed_thing)
		for _, callback in pairs(core.registered_on_item_eats) do
			local result = callback(hp_change, replace_with_item, itemstack, user, pointed_thing, old_itemstack)
			if result then
				return result
			end
		end
		mcl_hunger.last_eat[name] = os.time()
	end

	return itemstack
end

-- food functions
local food = {}

function mcl_hunger.register_food(name, hunger_change, replace_with_item, poisontime, poison, exhaust, poisonchance, sound)
	food[name] = {}
	food[name].saturation = hunger_change	-- hunger points added
	food[name].replace = replace_with_item	-- what item is given back after eating
	food[name].poisontime = poisontime	-- time it is poisoning. If this is set, this item is considered poisonous,
						-- otherwise the following poison/exhaust fields are ignored
	food[name].poison = poison		-- poison damage per tick for poisonous food
	food[name].exhaust = exhaust		-- exhaustion per tick for poisonous food
	food[name].poisonchance = poisonchance	-- chance percentage that this item poisons the player (default: 100% if poisoning is enabled)
	food[name].sound = sound		-- special sound that is played when eating
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
	local func = mcl_hunger.item_eat(def.saturation, def.replace, def.poisontime, def.poison, def.exhaust, def.poisonchance, def.sound)
	return func(itemstack, user, pointed_thing)
end

-- Reset HUD bars after poisoning
local function reset_bars(player)
	hb.change_hudbar(player, "health", nil, nil, "hudbars_icon_health.png", nil, "hudbars_bar_health.png")
	hb.change_hudbar(player, "hunger", nil, nil, "hbhunger_icon.png", nil, "hbhunger_bar.png")
	if mcl_hunger.debug then
		hb.change_hudbar(player, "exhaustion", nil, nil, nil, nil, "mcl_hunger_bar_exhaustion.png")
	end
end

-- Poison player
local function poisonp(tick, time, time_left, damage, exhaustion, player)
	-- First check if player is still there
	if not player:is_player() then
		return
	end
	-- Abort if poisonings have been stopped
	if mcl_hunger.poisonings[player:get_player_name()] == 0 then
		return
	end
	time_left = time_left + tick
	if time_left < time then
		minetest.after(tick, poisonp, tick, time, time_left, damage, exhaustion, player)
	else
		mcl_hunger.poisonings[player:get_player_name()] = mcl_hunger.poisonings[player:get_player_name()] - 1
		if mcl_hunger.poisonings[player:get_player_name()] <= 0 then
			reset_bars(player)
		end
	end

	-- Deal damage and exhaust player
	if player:get_hp()-damage > 0 then
		player:set_hp(player:get_hp()-damage)
	end
	mcl_hunger.exhaust(player:get_player_name(), exhaustion)

end

-- Immediately stop all poisonings for this player
function mcl_hunger.stop_poison(player)
	mcl_hunger.poisonings[player:get_player_name()] = 0
	reset_bars(player)
end

local poisonrandomizer = PseudoRandom(os.time())

function mcl_hunger.item_eat(hunger_change, replace_with_item, poisontime, poison, exhaust, poisonchance, sound)
	return function(itemstack, user, pointed_thing)
		local itemname = itemstack:get_name()

		if itemstack:take_item() ~= nil and user ~= nil then
			local name = user:get_player_name()
			local hp = user:get_hp()

			local pos = user:getpos()
			-- player height
			pos.y = pos.y + 1.5
			local foodtype = minetest.get_item_group(itemname, "food")
			if foodtype == 3 then
				-- Item is a drink, only play drinking sound (no particle)
				minetest.sound_play("survival_thirst_drink", {
					pos = pos,
					max_hear_distance = 12,
					gain = 1.0,
				})
			else
				-- Assume the item is a food
				-- Add eat particle effect and sound
				local def = minetest.registered_items[itemname]
				local texture = def.inventory_image
				if not texture or texture == "" then
					texture = def.wield_image
				end
				-- Special item definition field: _food_particles
				-- If false, force item to not spawn any food partiles when eaten
				if def._food_particles ~= false and texture and texture ~= "" then
					local v = user:get_player_velocity()
					local minvel = vector.add(v, {x=-1, y=1, z=-1})
					local maxvel = vector.add(v, {x=1, y=2, z=1})

					minetest.add_particlespawner({
						amount = math.min(math.max(8, hunger_change*2), 25),
						time = 0.1,
						minpos = {x=pos.x, y=pos.y, z=pos.z},
						maxpos = {x=pos.x, y=pos.y, z=pos.z},
						minvel = minvel,
						maxvel = maxvel,
						minacc = {x=0, y=-5, z=0},
						maxacc = {x=0, y=-9, z=0},
						minexptime = 1,
						maxexptime = 1,
						minsize = 1,
						maxsize = 2,
						collisiondetection = true,
						vertical = false,
						texture = texture,
					})
				end
				minetest.sound_play("mcl_hunger_bite", {
					pos = pos,
					max_hear_distance = 12,
					gain = 1.0,
				})
			end

			if hunger_change then
				-- Add saturation (must be defined in item table)
				local _mcl_saturation = minetest.registered_items[itemname]._mcl_saturation
				local saturation
				if not _mcl_saturation then
					saturation = 0
				else
					saturation = math.floor(minetest.registered_items[itemname]._mcl_saturation * 10)
				end
				mcl_hunger.saturate(name, saturation, false)

				-- Add food points
				local h = mcl_hunger.get_hunger(user)
				if h < 20 and hunger_change then
					h = h + hunger_change
					if h > 20 then h = 20 end
					mcl_hunger.set_hunger(user, h, false)
				end

				hb.change_hudbar(user, "hunger", h)
				mcl_hunger.update_saturation_hud(user, mcl_hunger.get_saturation(user), h)
			end
			-- Poison
			if poisontime then
				local do_poison = false
				if poisonchance then
					if poisonrandomizer:next(0,100) < poisonchance then
						do_poison = true
					end
				else
					do_poison = true
				end
				if do_poison then
					-- Set poison bars
					if poison and poison > 0 then
						hb.change_hudbar(user, "health", nil, nil, "hbhunger_icon_health_poison.png", nil, "hbhunger_bar_health_poison.png")
					end
					if exhaust and exhaust > 0 then
						hb.change_hudbar(user, "hunger", nil, nil, "mcl_hunger_icon_foodpoison.png", nil, "mcl_hunger_bar_foodpoison.png")
						if mcl_hunger.debug then
							hb.change_hudbar(user, "exhaustion", nil, nil, nil, nil, "mcl_hunger_bar_foodpoison.png")
						end
					end
					mcl_hunger.poisonings[name] = mcl_hunger.poisonings[name] + 1
					poisonp(1, poisontime, 0, poison, exhaust, user)
				end
			end

			--sound:eat
			itemstack:add_item(replace_with_item)
		end
		return itemstack
	end
end

-- player-action based hunger changes
minetest.register_on_dignode(function(pos, oldnode, player)
	-- is_fake_player comes from the pipeworks, we are not interested in those
	if not player or not player:is_player() or player.is_fake_player == true then
		return
	end
	local name = player:get_player_name()
	-- dig event
	mcl_hunger.exhaust(name, mcl_hunger.EXHAUST_DIG)
end)

-- Apply simple poison effect as long there are no real status effect
-- TODO: Remove this when status effects are in place

mcl_hunger.register_food("mcl_farming:potato_item_poison",	2, "",  4, 1,   0, 60)

mcl_hunger.register_food("mcl_mobitems:rotten_flesh",		4, "", 30, 0, 100, 80)
mcl_hunger.register_food("mcl_mobitems:chicken",		2, "", 30, 0, 100, 30)
mcl_hunger.register_food("mcl_mobitems:spider_eye",		2, "", 4,  1,   0)

mcl_hunger.register_food("mcl_fishing:pufferfish_raw",		1, "", 60, 1, 300)
