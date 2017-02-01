local init = os.clock()
minetest.register_node("mcl_fire:basic_flame", {
	description = "Fire",
	drawtype = "firelike",
	tiles = {{
		name="fire_basic_flame_animated.png",
		animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=1},
	}},
	inventory_image = "fire_basic_flame.png",
	-- Real light level: 15 (but Minetest caps at 14)
	light_source = 14,
	groups = {igniter=2,dig_immediate=3,dig_by_water=1,not_in_creative_inventory=1},
	drop = '',
	walkable = false,
	buildable_to = true,
	damage_per_second = 4,
	
	after_place_node = function(pos, placer)
		mcl_fire.on_flame_add_at(pos)
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		mcl_fire.on_flame_remove_at(pos)
	end,
})

mcl_fire = {}
mcl_fire.D = 6
-- key: position hash of low corner of area
-- value: {handle=sound handle, name=sound name}
mcl_fire.sounds = {}

function mcl_fire.get_area_p0p1(pos)
	local p0 = {
		x=math.floor(pos.x/mcl_fire.D)*mcl_fire.D,
		y=math.floor(pos.y/mcl_fire.D)*mcl_fire.D,
		z=math.floor(pos.z/mcl_fire.D)*mcl_fire.D,
	}
	local p1 = {
		x=p0.x+mcl_fire.D-1,
		y=p0.y+mcl_fire.D-1,
		z=p0.z+mcl_fire.D-1
	}
	return p0, p1
end

function mcl_fire.update_sounds_around(pos)
	local p0, p1 = mcl_fire.get_area_p0p1(pos)
	local cp = {x=(p0.x+p1.x)/2, y=(p0.y+p1.y)/2, z=(p0.z+p1.z)/2}
	local flames_p = minetest.find_nodes_in_area(p0, p1, {"mcl_fire:basic_flame"})
	--print("number of flames at "..minetest.pos_to_string(p0).."/"
	--		..minetest.pos_to_string(p1)..": "..#flames_p)
	local should_have_sound = (#flames_p > 0)
	local wanted_sound = nil
	if #flames_p >= 9 then
		wanted_sound = {name="fire_large", gain=1.5}
	elseif #flames_p > 0 then
		wanted_sound = {name="fire_small", gain=1.5}
	end
	local p0_hash = minetest.hash_node_position(p0)
	local sound = mcl_fire.sounds[p0_hash]
	if not sound then
		if should_have_sound then
			mcl_fire.sounds[p0_hash] = {
				handle = minetest.sound_play(wanted_sound, {pos=cp, loop=true}),
				name = wanted_sound.name,
			}
		end
	else
		if not wanted_sound then
			minetest.sound_stop(sound.handle)
			mcl_fire.sounds[p0_hash] = nil
		elseif sound.name ~= wanted_sound.name then
			minetest.sound_stop(sound.handle)
			mcl_fire.sounds[p0_hash] = {
				handle = minetest.sound_play(wanted_sound, {pos=cp, loop=true}),
				name = wanted_sound.name,
			}
		end
	end
end

function mcl_fire.on_flame_add_at(pos)
	--print("flame added at "..minetest.pos_to_string(pos))
	mcl_fire.update_sounds_around(pos)
end

function mcl_fire.on_flame_remove_at(pos)
	--print("flame removed at "..minetest.pos_to_string(pos))
	mcl_fire.update_sounds_around(pos)
end

function mcl_fire.find_pos_for_flame_around(pos)
	return minetest.find_node_near(pos, 1, {"air"})
end

function mcl_fire.flame_should_extinguish(pos)
	if minetest.setting_getbool("disable_fire") then return true end
	--return minetest.find_node_near(pos, 1, {"group:puts_out_fire"})
	local p0 = {x=pos.x-2, y=pos.y, z=pos.z-2}
	local p1 = {x=pos.x+2, y=pos.y, z=pos.z+2}
	local ps = minetest.find_nodes_in_area(p0, p1, {"group:puts_out_fire"})
	return (#ps ~= 0)
end

-- Ignite neighboring nodes
minetest.register_abm({
	nodenames = {"group:flammable"},
	neighbors = {"group:igniter"},
	interval = 1,
	chance = 2,
	action = function(p0, node, _, _)
		-- If there is water or stuff like that around flame, don't ignite
		if mcl_fire.flame_should_extinguish(p0) then
			return
		end
		local p = mcl_fire.find_pos_for_flame_around(p0)
		if p then
			minetest.set_node(p, {name="mcl_fire:basic_flame"})
			mcl_fire.on_flame_add_at(p)
		end
	end,
})

-- Rarely ignite things from far
minetest.register_abm({
	nodenames = {"group:igniter"},
	neighbors = {"air"},
	interval = 2,
	chance = 10,
	action = function(p0, node, _, _)
		local reg = minetest.registered_nodes[node.name]
		if not reg or not reg.groups.igniter or reg.groups.igniter < 2 then
			return
		end
		local d = reg.groups.igniter
		local p = minetest.find_node_near(p0, d, {"group:flammable"})
		if p then
			-- If there is water or stuff like that around flame, don't ignite
			if mcl_fire.flame_should_extinguish(p) then
				return
			end
			local p2 = mcl_fire.find_pos_for_flame_around(p)
			if p2 then
				minetest.set_node(p2, {name="mcl_fire:basic_flame"})
				mcl_fire.on_flame_add_at(p2)
			end
		end
	end,
})

-- Remove flammable nodes and flame
minetest.register_abm({
	nodenames = {"mcl_fire:basic_flame"},
	interval = 1,
	chance = 2,
	action = function(p0, node, _, _)
		-- If there is water or stuff like that around flame, remove flame

		if mcl_fire.flame_should_extinguish(p0) then
			minetest.remove_node(p0)
			mcl_fire.on_flame_remove_at(p0)
			return
		end
		-- Make the following things rarer
		if math.random(1,3) == 1 then
			return
		end
		-- If there are no flammable nodes around flame, remove flame
		if not minetest.find_node_near(p0, 1, {"group:flammable"}) then
			minetest.remove_node(p0)
			mcl_fire.on_flame_remove_at(p0)
			return
		end
		if math.random(1,3) == 1 then
			-- remove a flammable node around flame
			local p = minetest.find_node_near(p0, 1, {"group:flammable"})
			if p then
				-- If there is water or stuff like that around flame, don't remove
				if mcl_fire.flame_should_extinguish(p0) then
					return
				end
				minetest.remove_node(p)
				core.check_for_falling(p)
			end
		else
			-- remove flame
			minetest.remove_node(p0)
			mcl_fire.on_flame_remove_at(p0)
		end
	end,
})

--
-- Flint and Steel
--

function mcl_fire.set_fire(pointed_thing)
	local n = minetest.get_node(pointed_thing.above)
	if n.name ~= ""  and n.name == "air" and not minetest.is_protected(pointed_thing.above, "fire") then
		minetest.add_node(pointed_thing.above, {name="mcl_fire:basic_flame"})
	end
end

--
-- Fire Particles
--

function mcl_fire.add_fire(pos)
	local null = {x=0, y=0, z=0}
	pos.y = pos.y+0.19
	minetest.add_particle(pos, null, null, 1.1,
   					1.5, true, "default_fire_particle"..tostring(math.random(1,2)) ..".png")
	pos.y = pos.y +0.01
	minetest.add_particle(pos, null, null, 0.8,
   					1.5, true, "default_fire_particle"..tostring(math.random(1,2)) ..".png")
end

dofile(minetest.get_modpath(minetest.get_current_modname()).."/flint_and_steel.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/fire_charge.lua")

local time_to_load= os.clock() - init
print(string.format("[MOD] "..minetest.get_current_modname().." loaded in %.4f s", time_to_load))
