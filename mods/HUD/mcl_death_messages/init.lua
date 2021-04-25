local S = minetest.get_translator("mcl_death_messages")

mcl_death_messages = {
	messages = {
		in_fire = {
			_translator = S,
			plain = "@1 went up in flames",
			escape = "@1 walked into fire whilst fighting @2",
		},
		lightning_bolt = {
			_translator = S,
			plain = "@1 was struck by lightning",
			escape = "@1 was struck by lightning whilst fighting @2",
		},
		on_fire = {
			_translator = S,
			plain = "@1 burned to death",
			escape = "@1 was burnt to a crisp whilst fighting @2",
		},
		lava = {
			_translator = S,
			plain = "@1 tried to swim in lava",
			escape = "@1 tried to swim in lava to escape @2"
		},
		hot_floor = {
			_translator = S,
			plain = "@1 discovered the floor was lava",
			escape = "@1 walked into danger zone due to @2",
		},
		in_wall = {
			_translator = S,
			plain = "@1 suffocated in a wall",
			escape = "@1 suffocated in a wall whilst fighting @2",
		},
		drown = {
			_translator = S,
			plain = "@1 drowned",
			escape = "@1 drowned whilst trying to escape @2",
		},
		starve = {
			_translator = S,
			plain = "@1 starved to death",
			escape = "@1 starved to death whilst fighting @2",
		},
		cactus = {
			_translator = S,
			plain = "@1 was pricked to death",
			escape = "@1 walked into a cactus whilst trying to escape @2",
		},
		fall = {
			_translator = S,
			plain = "@1 hit the ground too hard",
			escape = "@1 hit the ground too hard whilst trying to escape @2",
			-- "@1 fell from a high place" -- for fall distance > 5 blocks
			-- "@1 fell while climbing"
			-- "@1 fell off some twisting vines"
			-- "@1 fell off some weeping vines"
			-- "@1 fell off some vines"
			-- "@1 fell off scaffolding"
			-- "@1 fell off a ladder"
		},
		fly_into_wall = {
			_translator = S,
			plain = "@1 experienced kinetic energy",
			escape = "@1 experienced kinetic energy whilst trying to escape @2",
		},
		out_of_world = {
			_translator = S,
			plain = "@1 fell out of the world",
			escape = "@1 didn't want to live in the same world as @2",
		},
		generic = {
			_translator = S,
			plain = "@1 died",
			escape = "@1 died because of @2",
		},
		magic = {
			_translator = S,
			plain = "@1 was killed by magic",
			escape = "@1 was killed by magic whilst trying to escape @2",
			killer = "@1 was killed by @2 using magic",
			item = "@1 was killed by @2 using @3",
		},
		dragon_breath = {
			_translator = S,
			plain = "@1 was roasted in dragon breath",
			killer = "@1 was roasted in dragon breath by @2",
		},
		wither = {
			_translator = S,
			plain = "@1 withered away",
			escape = "@1 withered away whilst fighting @2",
		},
		wither_skull = {
			_translator = S,
			plain = "@1 was killed by magic",
			killer = "@1 was shot by a skull from @2",
		},
		anvil = {
			_translator = S,
			plain = "@1 was squashed by a falling anvil",
			escape = "@1 was squashed by a falling anvil whilst fighting @2",
		},
		falling_node = {
			_translator = S,
			plain = "@1 was squashed by a falling block",
			escape = "@1 was squashed by a falling block whilst fighting @2",
		},
		mob = {
			_translator = S,
			killer = "@1 was slain by @2",
			item = "@1 was slain by @2 using @3",
		},
		player = {
			_translator = S,
			killer = "@1 was slain by @2",
			item = "@1 was slain by @2 using @3"
		},
		arrow = {
			_translator = S,
			killer = "@1 was shot by @2",
			item = "@1 was shot by @2 using @3",
		},
		fireball = {
			_translator = S,
			killer = "@1 was fireballed by @2",
			item = "@1 was fireballed by @2 using @3",
		},
		thorns = {
			_translator = S,
			killer = "@1 was killed trying to hurt @2",
			item = "@1 was killed by @3 trying to hurt @2", -- yes, the order is intentional: @1 @3 @2
		},
		explosion = {
			_translator = S,
			plain = "@1 blew up",
			killer = "@1 was blown up by @2",
			item = "@1 was blown up by @2 using @3",
			-- "@1 was killed by [Intentional Game Design]" -- for exploding bed in nether or end
		},
		cramming = {
			_translator = S,
			plain = "@1 was squished too much",
			escape = "@1 was squashed by @2",	-- surprisingly "escape" is actually the correct subtype
		},
		fireworks = {
			_translator = S,
			plain = "@1 went off with a bang",
			item = "@1 went off with a bang due to a firework fired from @3 by @2", -- order is intentional
		},
		-- Missing snowballs: The Minecraft wiki mentions them but the MC source code does not.
	},
}
--[[
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
]]--

local function get_item_killer_message(obj, messages, reason)
	if messages.item then
		local wielded = mcl_util.get_wielded_item(reason.source)
		local itemname = wielded:get_meta():get_string("name")
		if itemname ~= "" then
			itemname = "[" .. itemname .. "]"
			if mcl_enchanting.is_enchanted(wielded:get_name()) then
				itemname = minetest.colorize(mcl_colors.AQUA, itemname)
			end
			return messages._translator(messages.item, mcl_util.get_object_name(obj), mcl_util.get_object_name(reason.source), itemname)
		end
	end
end

local function get_plain_killer_message(obj, messages, reason)
	return messages.killer and messages._translator(messages.killer, mcl_util.get_object_name(obj), mcl_util.get_object_name(reason.source))
end

local function get_killer_message(obj, messages, reason)
	return reason.source and (get_item_killer_message(obj, messages, reason) or get_plain_killer_message(obj, messages, reason))
end

local function get_escaped_message(obj, messages, reason)
	return nil -- ToDo
end

local function get_plain_message(obj, messages, reason)
	if messages.plain then
		return messages._translator(messages.plain, mcl_util.get_object_name(obj))
	end
end

local function get_fallback_message(obj, messages, reason)
	return "mcl_death_messages.messages." .. reason.type .. " " .. mcl_util.get_object_name(obj)
end

local function fallback_translator(s)
	return s
end

mcl_damage.register_on_death(function(obj, reason)
	if not minetest.settings:get_bool("mcl_showDeathMessages", true) then
		return
	end

	local send_to

	if obj:is_player() then
		send_to = true
	end -- ToDo: add mob death messages for owned mobs, only send to owner (sent_to = "player name")


	if send_to then
		local messages = mcl_death_messages.messages[reason.type] or {}
		messages._translator = messages._translator or fallback_translator

		local message =
			get_killer_message(obj, messages, reason) or
			get_escaped_message(obj, messages, reason) or
			get_plain_message(obj, messages, reason) or
			get_fallback_message(obj, messages, reason)

		if send_to == true then
			minetest.chat_send_all(message)
		else
			minetest.chat_send_player(send_to, message)
		end
	end
end)
