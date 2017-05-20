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
		local itemname = itemstack:get_name()
		if itemstack:take_item() ~= nil and user ~= nil then
			local name = user:get_player_name()
			local hp = user:get_hp()

			local pos = user:getpos()
			-- player height
			pos.y = pos.y + 1.5
			local foodtype = minetest.get_item_group(itemname, "hunger")
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
				local saturation = math.floor(minetest.registered_items[itemname]._mcl_saturation * 10)
				if not saturation then
					saturation = 0
					minetest.log("warning", "[mcl_hunger] No saturation defined for item “"..itemname.."”!")
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
if minetest.get_modpath("mcl_farming") then
	mcl_hunger.register_food("mcl_farming:potato_item_poison", 1, "", 3)
end
if minetest.get_modpath("mcl_mobitems") then
	mcl_hunger.register_food("mcl_mobitems:rotten_flesh", 2, "", 8)
	mcl_hunger.register_food("mcl_mobitems:spider_eye", 0, "", 4)
end
if minetest.get_modpath("mcl_fishing") then
	mcl_hunger.register_food("mcl_fishing:pufferfish_raw", 0, "", 60)
end
