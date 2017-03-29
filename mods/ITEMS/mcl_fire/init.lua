-- Global namespace for functions

mcl_fire = {}


--
-- Items
--

-- Flame nodes

local fire_help = "Fire is a damaging and destructive but short-lived kind of block. It will destroy and spread towards near flammable blocks, but fire will disappear when there is nothing to burn left. It will be extinguished by nearby water and rain. Fire can be destroyed safely by punching it, but it is hurtful if you stand directly in it."
local eternal_fire_help = "Eternal fire is a damaging and destructive block. It will create fire around it when flammable blocks are nearby. Other than (normal) fire, an eternal fire will not go out by time alone. An eternal fire is still extinguished by punching it, by nearby water or by rain. Punching is is safe, but it hurts if you stand inside."

minetest.register_node("mcl_fire:fire", {
	description = "Fire",
	_doc_items_longdesc = fire_help,
	drawtype = "firelike",
	tiles = {
		{
			name = "fire_basic_flame_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1
			},
		},
	},
	inventory_image = "fire_basic_flame.png",
	paramtype = "light",
	-- Real light level: 15 (but Minetest caps at 14)
	light_source = 14,
	walkable = false,
	buildable_to = true,
	sunlight_propagates = true,
	damage_per_second = 1,
	groups = {igniter = 1, dig_immediate = 3, not_in_creative_inventory = 1, dig_by_piston=1},
	on_timer = function(pos)
		local f = minetest.find_node_near(pos, 1, {"group:flammable"})
		if not f then
			minetest.remove_node(pos)
			return
		end
		-- Restart timer
		return true
	end,
	drop = "",
	sounds = {},
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(math.random(30, 60))
	end,
	_mcl_blast_resistance = 0,
})

minetest.register_node("mcl_fire:eternal_fire", {
	description = "Eternal Fire",
	_doc_items_longdesc = eternal_fire_help,
	drawtype = "firelike",
	tiles = {
		{
			name = "fire_basic_flame_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1
			},
		},
	},
	inventory_image = "fire_basic_flame.png",
	paramtype = "light",
	-- Real light level: 15 (but Minetest caps at 14)
	light_source = 14,
	walkable = false,
	buildable_to = true,
	sunlight_propagates = true,
	damage_per_second = 1,
	groups = {igniter = 1, dig_immediate = 3, not_in_creative_inventory = 1, dig_by_piston = 1},
	sounds = {},
	drop = "",
	_mcl_blast_resistance = 0,
})

--
-- Sound
--

local flame_sound = minetest.setting_getbool("flame_sound")
if flame_sound == nil then
	-- Enable if no setting present
	flame_sound = true
end

if flame_sound then

	local handles = {}
	local timer = 0

	-- Parameters

	local radius = 8 -- Flame node search radius around player
	local cycle = 3 -- Cycle time for sound updates

	-- Update sound for player

	function mcl_fire.update_player_sound(player)
		local player_name = player:get_player_name()
		-- Search for flame nodes in radius around player
		local ppos = player:getpos()
		local areamin = vector.subtract(ppos, radius)
		local areamax = vector.add(ppos, radius)
		local fpos, num = minetest.find_nodes_in_area(
			areamin,
			areamax,
			{"mcl_fire:fire", "mcl_fire:eternal_fire"}
		)
		-- Total number of flames in radius
		local flames = (num["mcl_fire:fire"] or 0) +
			(num["mcl_fire:eternal_fire"] or 0)
		-- Stop previous sound
		if handles[player_name] then
			minetest.sound_stop(handles[player_name])
			handles[player_name] = nil
		end
		-- If flames
		if flames > 0 then
			-- Find centre of flame positions
			local fposmid = fpos[1]
			-- If more than 1 flame
			if #fpos > 1 then
				local fposmin = areamax
				local fposmax = areamin
				for i = 1, #fpos do
					local fposi = fpos[i]
					if fposi.x > fposmax.x then
						fposmax.x = fposi.x
					end
					if fposi.y > fposmax.y then
						fposmax.y = fposi.y
					end
					if fposi.z > fposmax.z then
						fposmax.z = fposi.z
					end
					if fposi.x < fposmin.x then
						fposmin.x = fposi.x
					end
					if fposi.y < fposmin.y then
						fposmin.y = fposi.y
					end
					if fposi.z < fposmin.z then
						fposmin.z = fposi.z
					end
				end
				fposmid = vector.divide(vector.add(fposmin, fposmax), 2)
			end
			-- Play sound
			local handle = minetest.sound_play(
				"fire_fire",
				{
					pos = fposmid,
					to_player = player_name,
					gain = math.min(0.06 * (1 + flames * 0.125), 0.18),
					max_hear_distance = 32,
					loop = true, -- In case of lag
				}
			)
			-- Store sound handle for this player
			if handle then
				handles[player_name] = handle
			end
		end
	end

	-- Cycle for updating players sounds

	minetest.register_globalstep(function(dtime)
		timer = timer + dtime
		if timer < cycle then
			return
		end

		timer = 0
		local players = minetest.get_connected_players()
		for n = 1, #players do
			mcl_fire.update_player_sound(players[n])
		end
	end)

	-- Stop sound and clear handle on player leave

	minetest.register_on_leaveplayer(function(player)
		local player_name = player:get_player_name()
		if handles[player_name] then
			minetest.sound_stop(handles[player_name])
			handles[player_name] = nil
		end
	end)
end


--
-- ABMs
--

-- Extinguish all flames quickly with water, snow, ice

minetest.register_abm({
	label = "Extinguish flame",
	nodenames = {"mcl_fire:fire", "mcl_fire:eternal_fire"},
	neighbors = {"group:puts_out_fire"},
	interval = 3,
	chance = 1,
	catch_up = false,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.remove_node(pos)
		minetest.sound_play("fire_extinguish_flame",
			{pos = pos, max_hear_distance = 16, gain = 0.15})
	end,
})


-- Enable the following ABMs according to 'enable fire' setting

local fire_enabled = minetest.setting_getbool("enable_fire")
if fire_enabled == nil then
	-- New setting not specified, check for old setting.
	-- If old setting is also not specified, 'not nil' is true.
	fire_enabled = not minetest.setting_getbool("disable_fire")
end

if not fire_enabled then

	-- Remove basic flames only if fire disabled

	minetest.register_abm({
		label = "Remove disabled fire",
		nodenames = {"fire:basic_flame"},
		interval = 7,
		chance = 1,
		catch_up = false,
		action = minetest.remove_node,
	})

else -- Fire enabled

	-- Ignite neighboring nodes, add basic flames

	minetest.register_abm({
		label = "Ignite flame",
		nodenames = {"group:flammable"},
		neighbors = {"group:igniter"},
		interval = 7,
		chance = 12,
		catch_up = false,
		action = function(pos, node, active_object_count, active_object_count_wider)
			-- If there is water or stuff like that around node, don't ignite
			if minetest.find_node_near(pos, 1, {"group:puts_out_fire"}) then
				return
			end
			local p = minetest.find_node_near(pos, 1, {"air"})
			if p then
				minetest.set_node(p, {name = "mcl_fire:fire"})
			end
		end,
	})

	-- Remove flammable nodes around fire

	minetest.register_abm({
		label = "Remove flammable nodes",
		nodenames = {"mcl_fire:fire"},
		neighbors = "group:flammable",
		interval = 5,
		chance = 18,
		catch_up = false,
		action = function(pos, node, active_object_count, active_object_count_wider)
			local p = minetest.find_node_near(pos, 1, {"group:flammable"})
			if p then
				local flammable_node = minetest.get_node(p)
				local def = minetest.registered_nodes[flammable_node.name]
				if def.on_burn then
					def.on_burn(p)
				else
					minetest.remove_node(p)
					minetest.check_for_falling(p)
				end
			end
		end,
	})

end

-- Set pointed_thing on fire
mcl_fire.set_fire = function(pointed_thing)
	local n = minetest.get_node(pointed_thing.above)
	if n.name ~= ""  and n.name == "air" and not minetest.is_protected(pointed_thing.above, "fire") then
		minetest.add_node(pointed_thing.above, {name="mcl_fire:fire"})
	end
end

minetest.register_alias("mcl_fire:basic_flame", "mcl_fire:fire")
minetest.register_alias("fire:basic_flame", "mcl_fire:fire")
minetest.register_alias("fire:permanent_flame", "mcl_fire:eternal_flame")

dofile(minetest.get_modpath(minetest.get_current_modname()).."/flint_and_steel.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/fire_charge.lua")
