local S = minetest.get_translator("mcl_death_messages")

mcl_death_messages = {}

-- Death messages
local msgs = {
	["arrow"] = {
		S("%s was fatally hit by an arrow."),
		S("%s has been killed with an arrow."),
	},
	["arrow_name"] = {
		S("%s was shot by an arrow from %s."),
	},
	["fire"] = {
		S("%s has been cooked crisp."),
		S("%s felt the burn."),
		S("%s died in the flames."),
		S("%s died in a fire."),
	},
	["lava"] = {
		S("%s melted in lava."),
		S("%s took a bath in a hot lava tub."),
		S("%s died in lava."),
		S("%s could not survive in lava."),
	},
	["drown"] = {
		S("%s forgot to breathe."),
		S("%s drowned."),
		S("%s ran out of oxygen."),
	},
	["starve"] = {
		S("%s starved."),
	},
	["murder"] = {
		S("%s was killed by %s."),
	},
	["mob_kill"] = {
		S("%s was killed by a mob."),
	},
	["blaze_fireball"] = {
		S("%s was burned to death by a blaze's fireball."),
		S("%s was killed by a fireball from a blaze."),
	},
	["fire_charge"] = {
		S("%s was hit by a fire charge."),
	},
	["ghast_fireball"] = {
		S("A ghast scared %s to death."),
		S("%s has been fireballed by a ghast."),
	},
	["fall_damage"] = {
		S("%s fell from a high cliff."),
		S("%s took fatal fall damage."),
		S("%s fell victim to gravity."),
	},
	["other"] = {
		S("%s died."),
	}
}

local mobkills = {
	["mobs_mc:zombie"] = S("%s was killed by a zombie."),
	["mobs_mc:baby_zombie"] = S("%s was killed by a baby zombie."),
	["mobs_mc:blaze"] = S("%s was killed by a blaze."),
	["mobs_mc:slime"] = S("%s was killed by a slime."),
	["mobs_mc:witch"] = S("%s was killed by a witch."),
	["mobs_mc:magma_cube_tiny"] = S("%s was killed by a magma cube."),
	["mobs_mc:magma_cube_small"] = S("%s was killed by a magma cube."),
	["mobs_mc:magma_cube_big"] = S("%s was killed by a magma cube."),
	["mobs_mc:wolf"] = S("%s was killed by a wolf."),
	["mobs_mc:cat"] = S("%s was killed by a cat."),
	["mobs_mc:ocelot"] = S("%s was killed by an ocelot."),
	["mobs_mc:ender_dragon"] = S("%s was killed by an ender dragon."),
	["mobs_mc:wither"] = S("%s was killed by a wither."),
	["mobs_mc:enderman"] = S("%s was killed by an enderman."),
	["mobs_mc:endermite"] = S("%s was killed by an endermite."),
	["mobs_mc:ghast"] = S("%s was killed by a ghast."),
	["mobs_mc:guardian_elder"] = S("%s was killed by an elder guardian."),
	["mobs_mc:guardian"] = S("%s was killed by a guardian."),
	["mobs_mc:iron_golem"] = S("%s was killed by an iron golem."),
	["mobs_mc:polar_bear"] = S("%s was killed by a polar_bear."),
	["mobs_mc:killer_bunny"] = S("%s was killed by a killer bunny."),
	["mobs_mc:shulker"] = S("%s was killed by a shulker."),
	["mobs_mc:silverfish"] = S("%s was killed by a silverfish."),
	["mobs_mc:skeleton"] = S("%s was killed by a skeleton."),
	["mobs_mc:stray"] = S("%s was killed by a stray."),
	["mobs_mc:slime_tiny"] = S("%s was killed by a slime."),
	["mobs_mc:slime_small"] = S("%s was killed by a slime."),
	["mobs_mc:slime_big"] = S("%s was killed by a slime."),
	["mobs_mc:spider"] = S("%s was killed by a spider."),
	["mobs_mc:cave_spider"] = S("%s was killed by a cave spider."),
	["mobs_mc:vex"] = S("%s was killed by a vex."),
	["mobs_mc:evoker"] = S("%s was killed by an evoker."),
	["mobs_mc:illusioner"] = S("%s was killed by an illusioner."),
	["mobs_mc:vindicator"] = S("%s was killed by a vindicator."),
	["mobs_mc:villager_zombie"] = S("%s was killed by a zombie villager."),
	["mobs_mc:husk"] = S("%s was killed by a husk."),
	["mobs_mc:baby_husk"] = S("%s was killed by a baby husk."),
	["mobs_mc:pigman"] = S("%s was killed by a zombie pigman."),
	["mobs_mc:baby_pigman"] = S("%s was killed by a baby zombie pigman."),
}

-- Select death message
local dmsg = function(mtype, ...)
	local r = math.random(1, #msgs[mtype])
	return string.format(msgs[mtype][r], ...)
end

-- Select death message for death by mob
local mmsg = function(mtype, ...)
	if mobkills[mtype] then
		return string.format(mobkills[mtype], ...)
	else
		return dmsg("mob_kill", ...)
	end
end

local last_damages = { }

minetest.register_on_dieplayer(function(player)
	-- Death message
	local message = minetest.settings:get_bool("mcl_showDeathMessages")
	if message == nil then message = true end
	if message then
		local name = player:get_player_name()
		if not name then
			return
		end

		local node = minetest.registered_nodes[minetest.get_node(player:get_pos()).name]
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
		-- Other
		else
			-- Killed by entity
			if last_damages[name] then
				-- Mob
				if last_damages[name].hittertype == "mob" then
					if last_damages[name].hittername then
						msg = dmsg("murder", name, last_damages[name].hittername)
					else
						msg = mmsg(last_damages[name].hittersubtype, name)
					end
				-- Player
				elseif last_damages[name].hittertype == "player" then
					if last_damages[name].hittername == name then
						-- Workaround when player somehow punches self. Caused by creeper explosions in mobs mod.
						-- FIXME: Remove when self-punching is no longer buggy.
						msg = dmsg("other", name)
					else
						msg = dmsg("murder", name, last_damages[name].hittername)
					end
				-- Arrow
				elseif last_damages[name].hittertype == "arrow" then
					if last_damages[name].shooter == nil then
						msg = dmsg("arrow", name)
					elseif last_damages[name].shooter:is_player() then
						msg = dmsg("arrow_name", name, last_damages[name].shooter:get_player_name())
					elseif last_damages[name].shooter:get_luaentity()._cmi_is_mob then
						if last_damages[name].shooter:get_luaentity().nametag ~= "" then
							msg = dmsg("arrow_name", name, last_damages[name].shooter:get_player_name())
						else
							msg = dmsg("arrow", name)
						end
					else
						msg = dmsg("arrow", name)
					end
				-- Fireball
				elseif last_damages[name].hittertype == "blaze_fireball" then
					msg = dmsg("blaze_fireball", name)
				elseif last_damages[name].hittertype == "ghast_fireball" then
					msg = dmsg("ghast_fireball", name)
				elseif last_damages[name].hittertype == "fire_charge" then
					msg = dmsg("fire_charge", name)
				-- Custom death message
				elseif last_damages[name].custom then
					msg = last_damages[name].message
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

local start_damage_reset_countdown = function (player)
	minetest.after(1, function(playername)
		last_damages[playername] = nil
	end, player:get_player_name())
end

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
	elseif hitter:get_luaentity().name == "mcl_bows:arrow_entity" or hitter:get_luaentity().name == "mobs_mc:arrow_entity" then
		hittertype = "arrow"
		if hitter:get_luaentity()._shooter then
			shooter = hitter:get_luaentity()._shooter
		end
	-- Blaze fireball
	elseif hitter:get_luaentity().name == "mobs_mc:blaze_fireball" then
		if hitter:get_luaentity()._shot_from_dispenser then
			hittertype = "fire_charge"
		else
			hittertype = "blaze_fireball"
		end
	-- Ghast fireball
	elseif hitter:get_luaentity().name == "mobs_monster:fireball" then
		hittertype = "ghast_fireball"
	else
		return
	end

	last_damages[player:get_player_name()] = { shooter = shooter, hittername = hittername, hittertype = hittertype, hittersubtype = hittersubtype }
	start_damage_reset_countdown(player)
end)

-- To be called BEFORE damaging a player. If the player died, then message will be used as the death message.
function mcl_death_messages.player_damage(player, message)
	last_damages[player:get_player_name()] = { custom = true, message = message }
	start_damage_reset_countdown(player)
end
