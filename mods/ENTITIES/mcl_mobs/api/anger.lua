--[[
Implementation of the Minecraft 1.16 Anger System (copied from https://www.minecraft.net/ru-ru/article/nether-update-java, with modifications):

Forgive dead players

    If this gamerule is disabled, then angered mobs will stay angry even if the targeted player dies
    If both forgiveDeadPlayers and universalAnger are enabled, an angered neutral mob will stop being angry when their target dies. They won't seek any new targets after that

Neutral mob anger

    When hurt by a player, the neutral mob will target that player and try to kill it
    The mob will stay angry until the player is dead or out of sight for a while
    Anger is persistent, so a player can't escape by temporarily logging out or switching dimension
    If a targeted player dies near the angered mob, it will stop being angry (unless forgiveDeadPlayers is disabled)
    Neutral mobs also get angry at other mobs who hurt them. However, that anger is not persistent
    Angered neutral mobs will only attack the offending player, not innocent bystanders
    Some mobs spread anger (wolf, Zombie Pigman). If a player attacks one, all nearby mobs of the same type will get angry at that player

Universal anger

Universal anger is basically guilt by association. A neutral mob attacked by players will be angry at players in general, regardless of who attacked them. More specifically:

    A neutral mob attacked by a player will target the nearest player, even if that player wasn't the attacker
    Every time the neutral mob is hit by a player it will update its attack target to the nearest player
    Players can use this to make neutral mobs attack other players. Who would ever do something that devious?
    Universal anger does not apply when a neutral mob is attacked by another mob - only when it is attacked by a player
    Universal anger is persistent. The angered mob will stay angry even if the player logs out and logs in, or jumps through a portal and back
    mcl_mobs.mobs that spread anger will also spread universal anger. So if a player attacks a Zombie Pigman, all other Zombie Pigmen within sight will be universally angry and attack their nearest player
    An angered neutral mob will stop being angry if it can't see any eligible target for a while
--]]

function mcl_mobs.mob:anger_on_staticdata()
	if self.anger_persistent then
		self.data.anger_target_name = self.anger_target_name
		self.data.anger_hurt_timestamp = self.anger_hurt_timestamp
	end
end

function mcl_mobs.mob:anger_on_activate()
	if self.data.anger_target_name then
		self.anger = true
		self.anger_persistent = true
		self.anger_target_name = self.data.anger_target_name
		self.anger_hurt_timestamp = self.data.anger_hurt_timestamp

		self.data.anger_target_name = nil
		self.data.anger_hurt_timestamp = nil
	end
end

function mcl_mobs.mob:get_anger_attack_target()
	if not self.anger then
		return
	end

	-- if the mob is universally angry and the current target is unreachable, search a new one
	local search_new_target = self.anger_universal and (
		not self.anger_current_target -- does a current target even exist?
		or not self.anger_current_target:is_player() -- universal anger only applies to players, so this is just a check whether the ObjectRef is still valid
		or not self:can_see(self.anger_current_target) -- dimension check is not done since it is covered by the view distance check
	)

	if search_new_target then
		self.anger_current_target = self:get_player_in_sight()
		if self.anger_current_target then
			self:debug("found new universal anger target: " .. self.anger_current_target:get_player_name())
		end
	end

	-- if the anger is not persistant (e.g. enderman provocation, angry at mobs)
	if not self.anger_persistent then
		-- calm down if either the target ObjectRef is invalid or changed its dimension
		if not self.anger_target:is_player() and not self.anger_target:get_luaentity() or not self:same_dimension_as(self.anger_target) then
			self:debug("non persistent anger target unreachable, calming down" .. (self.anger_target_name and "[anger_target_name = " .. self.anger_target_name .. "]" or ""))
			return nil, true
		end
	end

	-- if this is a player, special rules apply (don't use anger_target:is_player() since the player may have logged out so it's not a valid check)
	if self.anger_target_name then
		-- check if player logged out (if the player had already logged out in the last step anger_target will be nil, else it will be a dangling ObjectRef that can be validated by calling is_player())
		if not self.anger_target or not self.anger_target:is_player() then
			if self.anger_target then
				self:debug("anger target logged out: " .. self.anger_target_name)
			end
			-- in case the player relogged (if the player did not relog anger_target becomes nil and this is run in the next step as well)
			self.anger_target = minetest.get_player_by_name(self.anger_target_name)
			if self.anger_target then
				self:debug("anger target relogged: " .. self.anger_target_name)
			end
		end
		-- if forgiveDeadPlayers is true (it is by default)
		if self.anger_target and minetest.settings:get_bool("mclForgiveDeadPlayers", true) then
			-- check death timestamp of player and forget about the player in case it was killed
			if self.anger_target:get_meta():get_int("mcl_mobs:last_death") >= self.hurt_timestamp then
				self:debug("forgave " .. self.anger_target_name .. " since they died")
				return nil, true
			end
		end
	end

	-- the actual target we want to attack
	local target

	-- note: dont use a selfmade ternary expression (v = x and a or b, in other languages that have real ternary expressions this would be v = x ? a : b) here
	-- because anger_current_target might be nil and we don't care about the original player if they are not in the area (anger_current_target is only nil if there is absolutely no player in the area)
	if self.anger_universal then
		target = self.anger_current_target
	else
		target = self.anger_target
		-- if the target is out of reach, it counts as not existant in terms of the reset timer
		if target and not self:can_see(target) then
			target = nil
			if not self.anger_calm_timer then
				self:debug("cannot see anger target " .. self.anger_target_name .. " anymore")
			end
		end
	end

	if not target and not self.anger_calm_timer then
		-- start to calm down if noone to attack in sight
		self:debug("anger target " .. (self.anger_universal and self.anger_target_name .. " " or "") .. "is not reachable anymore, starting calm timer")
		self.anger_calm_timer = mcl_mobs.const.calm_down_timer
	elseif target and self.anger_calm_timer then
		-- stop calming down if there is someone in sight again
		self:debug("anger target " .. (self.anger_universal and self.anger_target_name .. " " or "") .. "is reachable again, resetting calm timer")
		self.anger_calm_timer = nil
	end

	if target then
		return target
	end

	-- wait for the mob to calm down if there is no target, then clear variables
	-- do_timer returns true if the timer has not elapsed yet
	if not self:do_timer("anger_calm") then
		self:debug("calmed down")
		self.anger = nil
		self.anger_target = nil
		self.anger_target_name = nil
		self.anger_universal = nil
		self.anger_current_target = nil
		self.anger_persistent = nil
		self.anger_hurt_timestamp = nil
	end
end

function mcl_mobs.mob:get_angry_raw(target, target_name, timestamp, universal, persistent)
	if self.owner == target_name then
		return false
	end

	self:debug("getting angry at " .. (target_name or tostring(target))
		.. " persistent: " .. (persistent and "yes" or "no")
		.. " universal: " .. (universal and "yes" or "no")
	)

	self.anger = true
	self.anger_target = target -- even if universally angry, still remember the actual cause to apply forgiveDeadPlayers properly. anger_current_target is used to get the actual attack target
	self.anger_target_name = target_name -- remember player name separately to work around the ObjectRef becoming invalid when the player logs out
	-- the persistent field is used to optionally forget about the player when they log out or change dimension (e.g. provoking endermen by looking at them) or for when attacked by another mob
	self.anger_persistent = persistent
	self.anger_hurt_timestamp = timestamp

	if universal then
		self.anger_universal = true
		 -- set this to nil because then universal anger is enabled every mob will look for a new target everytime a provocation happens
		self.anger_current_target = nil
	end

	return true
end

function mcl_mobs.mob:get_angry(target)
	local timestamp = os.time()
	local is_player =  target:is_player()

	local universal = is_player and minetest.settings:get_bool("mclUniversalAnger")
	local target_name = is_player and target:get_player_name() or ""
	local persistent = not is_player

	self:debug("provoked by " .. (target_name or tostring(target))
		.. " persistent: " .. (persistent and "yes" or "no")
		.. " universal: " .. (universal and "yes" or "no")
	)

	if not self:get_angry_raw(target, target_name, timestamp, universal, persistent) then
		return false
	end

	if self.def.group_attack then
		for _, obj in pairs(minetest.get_objects_inside_radius(self.object:get_pos(), self.def.view_range)) do
			local luaentity = obj:get_luaentity()
			if luaentity and self.def.group_attack[luaentity.name] then
				luaentity:get_angry_raw(target, target_name, timestamp, universal_anger, persistent)
			end
		end
	end

	return true
end

minetest.register_on_dieplayer(function(player)
	player:get_meta():set_int("mcl_mobs:last_death", os.time())
end)
