-- Death messages
local msgs = {
	["arrow"] = {
		"%s was fatally hit by an arrow.",
		"%s has been killed with an arrow.",
	},
	["cactus"] = {
		"%s was killed by a cactus.",
		"%s was pricked to death.",
	},
	["fire"] = {
		"%s has been cooked crisp.",
		"%s felt the burn.",
		"%s died in the flames.",
		"%s died in a fire.",
	},
	["explosion"] = {
		"%s was caught in an explosion.",
	},
	["lava"] = {
		"%s melted in lava.",
		"%s took a bath in a hot lava tub.",
		"%s died in lava.",
		"%s could not survive in lava.",
	},
	["drown"] = {
		"%s forgot to breathe.",
		"%s drowned.",
		"%s ran out of oxygen.",
	},
	["void"] = {
		"%s fell into the endless void.",
	},
	["suffocation"] = {
		"%s suffocated to death.",
	},
	["starve"] = {
		"%s starved.",
	},
	["murder"] = {
		"%s was killed by %s.",
	},
	["mob_kill"] = {
		"%s was killed by a mob.",
	},
	["falling_anvil"] = {
		"%s was smashed by a falling anvil!",
	},
	["falling_block"] = {
		"%s was smashed by a falling block.",
		"%s was buried under a falling block.",
	},
	["fall_damage"] = {
		"%s fell from a high cliff.",
		"%s took fatal fall damage.",
		"%s fell victim to gravity.",
	},
	["other"] = {
		"%s died.",
	}
}

mobkills = {
	["mobs_mc:zombie"] = "%s was killed by a zombie.",
	["mobs_mc:blaze"] = "%s was killed by a blaze.",
	["mobs_mc:slime"] = "%s was killed by a slime.",
	["mobs_mc:witch"] = "%s was killed by a witch.",
	["mobs_mc:magma_cube_tiny"] = "%s was killed by a magma cube.",
	["mobs_mc:magma_cube_small"] = "%s was killed by a magma cube.",
	["mobs_mc:magma_cube_big"] = "%s was killed by a magma cube.",
	["mobs_mc:wolf"] = "%s was killed by a wolf.",
	["mobs_mc:cat"] = "%s was killed by a cat.",
	["mobs_mc:ocelot"] = "%s was killed by an ocelot.",
	["mobs_mc:ender_dragon"] = "%s was killed by an ender dragon.",
	["mobs_mc:wither"] = "%s was killed by a wither.",
	["mobs_mc:blaze"] = "%s was killed by a blaze.",
	["mobs_mc:enderman"] = "%s was killed by an enderman.",
	["mobs_mc:endermite"] = "%s was killed by an endermite.",
	["mobs_mc:ghast"] = "%s was killed by a ghast.",
	["mobs_mc:guardian_elder"] = "%s was killed by an elder guardian.",
	["mobs_mc:guardian"] = "%s was killed by a guardian.",
	["mobs_mc:iron_golem"] = "%s was killed by an iron golem.",
	["mobs_mc:polar_bear"] = "%s was killed by a polar_bear.",
	["mobs_mc:killer_bunny"] = "%s was killed by a killer bunny.",
	["mobs_mc:shulker"] = "%s was killed by a shulker.",
	["mobs_mc:silverfish"] = "%s was killed by a silverfish.",
	["mobs_mc:skeleton"] = "%s was killed by a skeleton.",
	["mobs_mc:stray"] = "%s was killed by a stray.",
	["mobs_mc:slime_tiny"] = "%s was killed by a slime.",
	["mobs_mc:slime_small"] = "%s was killed by a slime.",
	["mobs_mc:slime_big"] = "%s was killed by a slime.",
	["mobs_mc:spider"] = "%s was killed by a spider.",
	["mobs_mc:cave_spider"] = "%s was killed by a cave spider.",
	["mobs_mc:vex"] = "%s was killed by a vex.",
	["mobs_mc:evoker"] = "%s was killed by an evoker.",
	["mobs_mc:illusioner"] = "%s was killed by an illusioner.",
	["mobs_mc:vindicator"] = "%s was killed by a vindicator.",
	["mobs_mc:villager_zombie"] = "%s was killed by a zombie villager.",
	["mobs_mc:husk"] = "%s was killed by a husk.",
	["mobs_mc:zombiepig"] = "%s was killed by a zombie pigman.",
}

-- Select death message
local dmsg = function(mtype, ...)
	local r = math.random(1, #msgs[mtype])
	return string.format(msgs[mtype][r], ...)
end

-- Select death message for death by mob
local mmsg = function(mtype, ...)
	minetest.log("error", dump(mtype))
	if mobkills[mtype] then
		return string.format(mobkills[mtype], ...)
	else
		return dmsg("mob_kill", ...)
	end
end

local last_punches = { }

minetest.register_on_dieplayer(function(player)
	local keep = minetest.setting_getbool("mcl_keepInventory") or false
	if keep == false then
		-- Drop inventory, crafting grid and armor
		local inv = player:get_inventory()
		local pos = player:getpos()
		local name, player_armor_inv, armor_armor_inv, pos = armor:get_valid_player(player, "[on_dieplayer]")
		local lists = {
			{ inv = inv, listname = "main", drop = true },
			{ inv = inv, listname = "craft", drop = true },
			{ inv = player_armor_inv, listname = "armor", drop = true },
			{ inv = armor_armor_inv, listname = "armor", drop = false },
		}
		for l=1,#lists do
			local inv = lists[l].inv
			local listname = lists[l].listname
			local drop = lists[l].drop
			if inv ~= nil then
				for i, stack in ipairs(inv:get_list(listname)) do
					local x = math.random(0, 9)/3
					local z = math.random(0, 9)/3
					pos.x = pos.x + x
					pos.z = pos.z + z
					if drop then
						minetest.add_item(pos, stack)
					end
					stack:clear()
					inv:set_stack(listname, i, stack)
					pos.x = pos.x - x
					pos.z = pos.z - z
				end
			end
		end
		armor:set_player_armor(player)
		armor:update_inventory(player)
	end

	-- Death message
	local message = minetest.setting_getbool("mcl_showDeathMessages")
	if message == nil then message = true end
	if message then
		local name = player:get_player_name()
		if not name then
			return
		end

		local node = minetest.registered_nodes[minetest.get_node(player:getpos()).name]
		local msg
		-- Lava
		if minetest.get_item_group(node.name, "lava") ~= 0 then
			msg = dmsg("lava", name)
		-- Drowning
		elseif player:get_breath() == 0 then
			msg = dmsg("drown", name)
		-- Fire
		elseif minetest.get_item_group(node.name, "fire") ~= 0 then
			msg = dmsg("fire", name)
		-- Void
		elseif node.name == "mcl_core:void" then
			msg = dmsg("void", name)
		-- Cactus
		elseif node.name == "mcl_core:cactus" then
			msg = dmsg("cactus", name)
		-- Other
		else
			-- Killed by entity
			if last_punches[name] then
				-- Mob
				if last_punches[name].hittertype == "mob" then
					if last_punches[name].hittername then
						msg = dmsg("murder", name, last_punches[name].hittername)
					else
						msg = mmsg(last_punches[name].hittersubtype, name)
					end
				-- Player
				elseif last_punches[name].hittertype == "player" then
					msg = dmsg("murder", name, last_punches[name].hittername)
				-- Arrow
				elseif last_punches[name].hittertype == "arrow" then
					msg = dmsg("arrow", name)
				end
			-- Other reason
			else
				msg = dmsg("other", name)
			end
		end
		if msg then
			minetest.chat_send_all(msg)
		end
	end
end)


minetest.register_on_punchplayer(function(player, hitter)
	if not player or not player:is_player() or not hitter then
		return
	end
	local msg
	local hittername, hittertype, hittersubtype, shooter
	-- Player
	if hitter:is_player() then
		hittername = hitter:get_player_name()
		hittertype = "player"
	-- Mob (according to Common Mob Interface)
	elseif hitter:get_luaentity()._cmi_is_mob then
		if hitter:get_luaentity().nametag and hitter:get_luaentity().nametag ~= "" then
			hittername = hitter:get_luaentity().nametag
		end
		hittertype = "mob"
		hittersubtype = hitter:get_luaentity().name
	-- Arrow
	elseif hitter:get_luaentity().name == "mcl_throwing:arrow_entity" or hitter:get_luaentity().name == "mobs_mc:arrow_entity" then
		hittertype = "arrow"
		if hitter:get_luaentity()._shooter then
			shooter = hitter:get_luaentity()._shooter
		end
	else
		return
	end

	last_punches[player:get_player_name()] = { shooter = shooter, hittername = hittername, hittertype = hittertype, hittersubtype = hittersubtype }
	minetest.after(1, function(playername)
		last_punches[playername] = nil
	end, player:get_player_name())
end)
