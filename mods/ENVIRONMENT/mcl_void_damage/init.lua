local S = minetest.get_translator(minetest.get_current_modname())
--local enable_damage = minetest.settings:get_bool("enable_damage")

local pos_to_dim = mcl_worlds.pos_to_dimension
local dim_change = mcl_worlds.dimension_change
local is_in_void = mcl_worlds.is_in_void
local get_spawn_pos = mcl_spawn.get_player_spawn_pos
local send_chat = minetest.chat_send_player
local get_connected = minetest.get_connected_players

local voidtimer = 0
local VOID_DAMAGE_FREQ = 0.5
local VOID_DAMAGE = 4

-- Remove entities that fall too deep into the void
minetest.register_on_mods_loaded(function()
	-- We do this by overwriting on_step of all entities
	for entitystring, def in pairs(minetest.registered_entities) do
		local on_step_old = def.on_step
		if not on_step_old then
			on_step_old = function() end
		end
		local on_step = function(self, dtime, moveresult)
			-- Add safety checks to prevent crashes
			if not self or not self.object then
				return
			end
			
			-- Safely call old on_step function with error handling
			local success, err = pcall(on_step_old, self, dtime, moveresult)
			if not success then
				-- Log error but don't crash the game
				minetest.log("warning", "Void damage on_step error for " .. tostring(entitystring) .. ": " .. tostring(err))
				return
			end
			
			local obj = self.object
			if not obj or not obj:get_pos then
				return
			end
			
			local pos = obj:get_pos()
			-- Old on_step function might have deleted object,
			-- so we delete it
			if not pos then
				return
			end

			if not self._void_timer then
				self._void_timer = 0
			end
			
			-- Ensure dtime is a valid number
			if type(dtime) ~= "number" or dtime < 0 then
				dtime = 0.05  -- Default fallback value
			end
			
			self._void_timer = self._void_timer + dtime
			if self._void_timer <= VOID_DAMAGE_FREQ then
				return
			end
			self._void_timer = 0

			-- Safely check void status
			local void_status, void_deadly = pcall(is_in_void, pos)
			if not void_status then
				-- If is_in_void fails, assume not in void
				return
			end
			
			if void_deadly then
				--local ent = obj:get_luaentity()
				obj:remove()
				return
			end
		end
		def.on_step = on_step
		minetest.register_entity(":"..entitystring, def)
	end
end)

-- Hurt players or teleport them back to spawn if they are too deep in the void
minetest.register_globalstep(function(dtime)
	-- Add safety check for dtime
	if type(dtime) ~= "number" or dtime < 0 then
		dtime = 0.05  -- Default fallback
	end
	
	voidtimer = voidtimer + dtime
	if voidtimer > VOID_DAMAGE_FREQ then
		voidtimer = 0
		local enable_damage = minetest.settings:get_bool("enable_damage")
		local players = get_connected()
		
		if not players then
			return
		end
		
		for p=1, #players do
			local player = players[p]
			if not player or not player:get_pos then
				-- Skip invalid players
				goto continue
			end
			
			local pos = player:get_pos()
			if not pos then
				goto continue
			end
			
			-- Safely check void status with error handling
			local void_status, void_deadly = pcall(is_in_void, pos)
			if not void_status then
				-- If is_in_void check fails, skip this player
				goto continue
			end
			
			if void_deadly then
				local immortal_val = 0
				local armor_groups = player:get_armor_groups()
				if armor_groups and armor_groups.immortal then
					immortal_val = armor_groups.immortal
				end
				
				local is_immortal = immortal_val and immortal_val > 0
				
				if is_immortal or not enable_damage then
					-- If damage is disabled, we can't kill players.
					-- So we just teleport the player back to spawn.
					local spawn_status, spawn = pcall(get_spawn_pos, player)
					if spawn_status and spawn then
						player:set_pos(spawn)
						pcall(dim_change, player, pos_to_dim(spawn))
						pcall(send_chat, player:get_player_name(), S("The void is off-limits to you!"))
					end
				elseif enable_damage and not is_immortal then
					-- Damage enabled, not immortal: Deal void damage (4 HP / 0.5 seconds)
					local hp = player:get_hp()
					if hp and hp > 0 then
						local damage_status, damage_err = pcall(mcl_util.deal_damage, player, VOID_DAMAGE, {type = "out_of_world"})
						if not damage_status then
							-- Fallback to direct HP damage if mcl_util.deal_damage fails
							player:set_hp(math.max(0, hp - VOID_DAMAGE))
						end
					end
				end
			end
			::continue::
		end
	end
end)