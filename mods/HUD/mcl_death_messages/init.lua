local S = minetest.get_translator("mcl_death_messages")
local N = function(s) return s end

local function get_tool_name(item)
	local name = item:get_meta():get_string("name")
	if name ~= "" then
	  return name
	end
	local def = item:get_definition()
	return def._tt_original_description or def.description
  end

mcl_death_messages = {}

-- Death messages
local msgs = {
	["arrow"] = {
		N("@1 was fatally hit by an arrow."),
		N("@1 has been killed by an arrow."),
	},
	["arrow_name"] = {
		N("@1 was shot by @2 using [@3]"),
	},
	["arrow_skeleton"] = {
		N("@1 was shot by Skeleton."),
	},
	["arrow_stray"] = {
		N("@1 was shot by Stray."),
	},
	["arrow_illusioner"] = {
		N("@1 was shot by Illusioner."),
	},
	["arrow_mob"] = {
		N("@1 was shot."),
	},
	["drown"] = {
		N("@1 forgot to breathe."),
		N("@1 drowned."),
		N("@1 ran out of oxygen."),
	},
	["murder"] = {
		N("@1 was slain by @2 using [@3]"),
	},
	["murder_any"] = {
		N("@1 was killed."),
	},
	["mob_kill"] = {
		N("@1 was slain by a mob."),
	},
	["blaze_fireball"] = {
		N("@1 was burned to death by a Blaze's fireball."),
		N("@1 was fireballed by a Blaze"),
	},
	["fire_charge"] = {
		N("@1 was burned by a fire charge."),
	},
	["ghast_fireball"] = {
		N("A Ghast scared @1 to death."),
		N("@1 has been fireballed by a Ghast."),
	},
	["fall"] = {
		N("@1 fell from a high cliff."),
		N("@1 took fatal fall damage."),
		N("@1 fell victim to gravity."),
		N("@1 hit the ground too hard.")
	},

	["other"] = {
		N("@1 died."),
	}
}

local mobkills = {
	["mobs_mc:zombie"] = N("@1 was slain by Zombie."),
	["mobs_mc:baby_zombie"] = N("@1 was slain by Baby Zombie."),
	["mobs_mc:blaze"] = N("@1 was burnt to a crisp while fighting Blaze."),
	["mobs_mc:slime"] = N("@1 was slain by Slime."),
	["mobs_mc:witch"] = N("@1 was slain by Witch using magic."),
	["mobs_mc:magma_cube_tiny"] = N("@1 was slain by Magma Cube."),
	["mobs_mc:magma_cube_small"] = N("@1 was slain by Magma Cube."),
	["mobs_mc:magma_cube_big"] = N("@1 was slain by Magma Cube."),
	["mobs_mc:wolf"] = N("@1 was slain by Wolf."),
	["mobs_mc:cat"] = N("@1 was slain by Cat."),
	["mobs_mc:ocelot"] = N("@1 was slain by Ocelot."),
	["mobs_mc:enderdragon"] = N("@1 was slain by Enderdragon."),
	["mobs_mc:wither"] = N("@1 was slain by Wither."),
	["mobs_mc:enderman"] = N("@1 was slain by Enderman."),
	["mobs_mc:endermite"] = N("@1 was slain by Endermite."),
	["mobs_mc:ghast"] = N("@1 was fireballed by a Ghast."),
	["mobs_mc:guardian_elder"] = N("@1 was slain by Elder Guardian."),
	["mobs_mc:guardian"] = N("@1 was slain by Guardian."),
	["mobs_mc:iron_golem"] = N("@1 was slain by Iron Golem."),
	["mobs_mc:polar_bear"] = N("@1 was slain by Polar Bear."),
	["mobs_mc:killer_bunny"] = N("@1 was slain by Killer Bunny."),
	["mobs_mc:shulker"] = N("@1 was slain by Shulker."),
	["mobs_mc:silverfish"] = N("@1 was slain by Silverfish."),
	["mobs_mc:skeleton"] = N("@1 was shot by Skeleton."),
	["mobs_mc:stray"] = N("@1 was shot by Stray."),
	["mobs_mc:slime_tiny"] = N("@1 was slain by Slime."),
	["mobs_mc:slime_small"] = N("@1 was slain by Slime."),
	["mobs_mc:slime_big"] = N("@1 was slain by Slime."),
	["mobs_mc:spider"] = N("@1 was slain by Spider."),
	["mobs_mc:cave_spider"] = N("@1 was slain by Cave Spider."),
	["mobs_mc:vex"] = N("@1 was slain by Vex."),
	["mobs_mc:evoker"] = N("@1 was slain by Evoker."),
	["mobs_mc:illusioner"] = N("@1 was slain by Illusioner."),
	["mobs_mc:vindicator"] = N("@1 was slain by Vindicator."),
	["mobs_mc:villager_zombie"] = N("@1 was slain by Zombie Villager."),
	["mobs_mc:husk"] = N("@1 was slain by Husk."),
	["mobs_mc:baby_husk"] = N("@1 was slain by Baby Husk."),
	["mobs_mc:pigman"] = N("@1 was slain by Zombie Pigman."),
	["mobs_mc:baby_pigman"] = N("@1 was slain by Baby Zombie Pigman."),
}

-- Select death message
local dmsg = function(mtype, ...)
	local r = math.random(1, #msgs[mtype])
	return S(msgs[mtype][r], ...)
end

-- Select death message for death by mob
local mmsg = function(mtype, ...)
	if mobkills[mtype] then
		return S(mobkills[mtype], ...)
	else
		return dmsg("mob_kill", ...)
	end
end

local last_damages = { }

minetest.register_on_dieplayer(function(player, reason)
	-- Death message
	local message = minetest.settings:get_bool("mcl_showDeathMessages")
	if message == nil then
		message = true
	end
	if message then
		local name = player:get_player_name()
		if not name then
			return
		end
		local msg
		if last_damages[name] then
			-- custom message
			msg = last_damages[name].message
		elseif reason.type == "node_damage" then
			local pos = player:get_pos()
			-- Check multiple nodes because players occupy multiple nodes
			-- (we add one additional node because the check may fail if the player was
			-- just barely touching the node with the head)
			local posses = { pos, {x=pos.x,y=pos.y+1,z=pos.z}, {x=pos.x,y=pos.y+2,z=pos.z}}
			local highest_damage = 0
			local highest_damage_def = nil
			-- Show message for node that dealt the most damage
			for p=1, #posses do
				local def = minetest.registered_nodes[minetest.get_node(posses[p]).name]
				local dmg = def.damage_per_second
				if dmg and dmg > highest_damage then
					highest_damage = dmg
					highest_damage_def = def
				end
			end
			if highest_damage_def and highest_damage_def._mcl_node_death_message then
				local field = highest_damage_def._mcl_node_death_message
				local field_msg
				if type(field) == "table" then
					field_msg = field[math.random(1, #field)]
				else
					field_msg = field
				end
				local textdomain
				if highest_damage_def.mod_origin then
					textdomain = highest_damage_def.mod_origin
				else
					textdomain = "mcl_death_messages"
				end
				-- We assume the textdomain of the death message in the node definition
				-- equals the modname.
				msg = minetest.translate(textdomain, field_msg, name)
			end
		elseif reason.type == "drown" then
			msg = dmsg("drown", name)
		elseif reason.type == "punch" then
		-- Punches
			local hitter = reason.object

			-- Player was slain by potions
			if not hitter then return end
			
			local hittername, hittertype, hittersubtype, shooter
			local hitter_toolname  = get_tool_name(hitter:get_wielded_item())

			-- Custom message
			if last_damages[name] then
				msg = last_damages[name].message
			-- Unknown hitter
			elseif hitter == nil then
				msg = dmsg("murder_any", name)
			-- Player
			elseif hitter:is_player() then
				hittername = hitter:get_player_name()
				if hittername ~= nil then
					msg = dmsg("murder", name, hittername, minetest.colorize("#00FFFF", hitter_toolname))
				else
					msg = dmsg("murder_any", name)
				end
			-- Mob (according to Common Mob Interface)
			elseif hitter:get_luaentity()._cmi_is_mob then
				if hitter:get_luaentity().nametag and hitter:get_luaentity().nametag ~= "" then
					hittername = hitter:get_luaentity().nametag
				end
				hittersubtype = hitter:get_luaentity().name
				if hittername then
					msg = dmsg("murder", name, hittername)
				elseif hittersubtype ~= nil and hittersubtype ~= "" then
					msg = mmsg(hittersubtype, name)
				else
					msg = dmsg("murder_any", name)
				end
			-- Arrow
			elseif hitter:get_luaentity().name == "mcl_bows:arrow_entity" or hitter:get_luaentity().name == "mobs_mc:arrow_entity" and not killed_by_potion then
				local shooter
				if hitter:get_luaentity()._shooter then
					shooter = hitter:get_luaentity()._shooter
				end
				local is_mob = false
				local s_ent = shooter and shooter:get_luaentity()
				if shooter == nil then
					msg = dmsg("arrow", name)
				elseif shooter:is_player() then
					msg = dmsg("arrow_name", name, shooter:get_player_name(), minetest.colorize("#00FFFF", get_tool_name(shooter:get_wielded_item())))
				elseif s_ent and s_ent._cmi_is_mob then
					if s_ent.nametag ~= "" then
						msg = dmsg("arrow_name", name, shooter:get_player_name(), get_tool_name(shooter:get_wielded_item()))
					elseif s_ent.name == "mobs_mc:skeleton" then
						msg = dmsg("arrow_skeleton", name)
					elseif s_ent.name == "mobs_mc:stray" then
						msg = dmsg("arrow_stray", name)
					elseif s_ent.name == "mobs_mc:illusioner" then
						msg = dmsg("arrow_illusioner", name)
					else
						msg = dmsg("arrow_mob", name)
					end
				else
					msg = dmsg("arrow", name)
				end
			-- Blaze fireball
			elseif hitter:get_luaentity().name == "mobs_mc:blaze_fireball" then
				if hitter:get_luaentity()._shot_from_dispenser then
					msg = dmsg("fire_charge", name)
				else
					msg = dmsg("blaze_fireball", name)
				end
			-- Ghast fireball
			elseif hitter:get_luaentity().name == "mobs_monster:fireball" then
				msg = dmsg("ghast_fireball", name)
			end
		-- Falling
		elseif reason.type == "fall" then
			msg = dmsg("fall", name)
		-- Other
		elseif reason.type == "set_hp" then
			if last_damages[name] then
				msg = last_damages[name].message
			end
		end
		if not msg then
			msg = dmsg("other", name)
		end
		minetest.chat_send_all(msg)
		last_damages[name] = nil
	end
end)

-- dmg_sequence_number is used to discard old damage events
local dmg_sequence_number = 0
local start_damage_reset_countdown = function (player, sequence_number)
	minetest.after(1, function(playername, sequence_number)
		if last_damages[playername] and last_damages[playername].sequence_number == sequence_number then
			last_damages[playername] = nil
		end
	end, player:get_player_name(), sequence_number)
end

-- Send a custom death mesage when damaging a player via set_hp or punch.
-- To be called directly BEFORE damaging a player via set_hp or punch.
-- The next time the player dies due to a set_hp, the message will be shown.
-- The player must die via set_hp within 0.1 seconds, otherwise the message will be discarded.
function mcl_death_messages.player_damage(player, message)
	last_damages[player:get_player_name()] = { message = message, sequence_number = dmg_sequence_number }
	start_damage_reset_countdown(player, dmg_sequence_number)
	dmg_sequence_number = dmg_sequence_number + 1
	if dmg_sequence_number >= 65535 then
		dmg_sequence_number = 0
	end
end