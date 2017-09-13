--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

local cow_def = {
	type = "animal",
	hp_min = 10,
	hp_max = 10,
	collisionbox = {-0.45, -0.01, -0.45, 0.45, 1.39, 0.45},
	visual = "mesh",
	mesh = "mobs_mc_cow.b3d",
	textures = { {
		"mobs_mc_cow.png",
		"blank.png",
	}, },
	visual_size = {x=2.8, y=2.8},
	makes_footstep_sound = true,
	walk_velocity = 1,
	drops = {
		{name = mobs_mc.items.beef_raw,
		chance = 1,
		min = 1,
		max = 3,},
		{name = mobs_mc.items.leather,
		chance = 1,
		min = 0,
		max = 2,},
	},
	water_damage = 1,
	lava_damage = 5,
	light_damage = 0,
	runaway = true,
	sounds = {
		random = "mobs_mc_cow",
		death = "Cowhurt1", -- TODO: Replace
		damage = "Cowhurt1", -- TODO: Replace
		distance = 16,
	},
	animation = {
		stand_speed = 25, walk_speed = 25, run_speed = 50,
		stand_start = 0,		stand_end = 0,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},
	follow = mobs_mc.follow.cow,
	on_rightclick = function(self, clicker)
		if mobs:feed_tame(self, clicker, 1, true, true) then return end
		if mobs:protect(self, clicker) then return end

		if self.child then
			return
		end

		local item = clicker:get_wielded_item()
		if item:get_name() == mobs_mc.items.bucket and clicker:get_inventory() then
			local inv = clicker:get_inventory()
			inv:remove_item("main", mobs_mc.items.bucket)
			-- if room add bucket of milk to inventory, otherwise drop as item
			if inv:room_for_item("main", {name=mobs_mc.items.milk}) then
				clicker:get_inventory():add_item("main", mobs_mc.items.milk)
			else
				local pos = self.object:getpos()
				pos.y = pos.y + 0.5
				minetest.add_item(pos, {name = mobs_mc.items.milk})
			end
			return
		end
		mobs:capture_mob(self, clicker, 0, 5, 60, false, nil)
	end,
	follow = mobs_mc.items.wheat,
	view_range = 10,
	fear_height = 4,
}

mobs:register_mob("mobs_mc:cow", cow_def)

-- Mooshroom
local mooshroom_def = table.copy(cow_def)

mooshroom_def.mesh = "mobs_mc_cow.b3d"
mooshroom_def.textures = { {"mobs_mc_mooshroom.png", "mobs_mc_mushroom_red.png"}, }
mooshroom_def.on_rightclick = function(self, clicker)
	if mobs:feed_tame(self, clicker, 1, true, true) then return end
	if mobs:protect(self, clicker) then return end

	if self.child then
		return
	end
	local item = clicker:get_wielded_item()
	-- Use shears to get mushrooms and turn mooshroom into cow
	if item:get_name() == mobs_mc.items.shears then
		local pos = self.object:getpos()
		minetest.sound_play("shears", {pos = pos})
		minetest.add_item({x=pos.x, y=pos.y+1.4, z=pos.z}, mobs_mc.items.mushroom_red .. " 5")

		local oldyaw = self.object:getyaw()
		self.object:remove()
		local cow = minetest.add_entity(pos, "mobs_mc:cow")
		cow:setyaw(oldyaw)

		if not minetest.settings:get_bool("creative_mode") then
			item:add_wear(mobs_mc.misc.shears_wear)
			clicker:get_inventory():set_stack("main", clicker:get_wield_index(), item)
		end
	-- Use bucket to milk
	elseif item:get_name() == mobs_mc.items.bucket and clicker:get_inventory() then
		local inv = clicker:get_inventory()
		inv:remove_item("main", mobs_mc.items.bucket)
		-- If room, add milk to inventory, otherwise drop as item
		if inv:room_for_item("main", {name=mobs_mc.items.milk}) then
			clicker:get_inventory():add_item("main", mobs_mc.items.milk)
		else
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs_mc.items.milk})
		end
	-- Use bowl to get mushroom stew
	elseif item:get_name() == mobs_mc.items.bowl and clicker:get_inventory() then
		local inv = clicker:get_inventory()
		inv:remove_item("main", mobs_mc.items.bowl)
		-- If room, add mushroom stew to inventory, otherwise drop as item
		if inv:room_for_item("main", {name=mobs_mc.items.mushroom_stew}) then
			clicker:get_inventory():add_item("main", mobs_mc.items.mushroom_stew)
		else
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs_mc.items.mushroom_stew})
		end
	end
	mobs:capture_mob(self, clicker, 0, 5, 60, false, nil)
end
mobs:register_mob("mobs_mc:mooshroom", mooshroom_def)


-- Spawning
mobs:spawn_specific("mobs_mc:cow", mobs_mc.spawn.grassland, {"air"}, 9, minetest.LIGHT_MAX+1, 30, 17000, 20, mobs_mc.spawn_height.overworld_min, mobs_mc.spawn_height.overworld_max)
mobs:spawn_specific("mobs_mc:mooshroom", mobs_mc.spawn.mushroom_island, {"air"}, 9, minetest.LIGHT_MAX+1, 30, 17000, 10, mobs_mc.spawn_height.overworld_min, mobs_mc.spawn_height.overworld_max)

-- compatibility
mobs:alias_mob("mobs_animal:cow", "mobs_mc:cow")

-- spawn egg
mobs:register_egg("mobs_mc:cow", S("Cow"), "mobs_mc_spawn_icon_cow.png", 0)
mobs:register_egg("mobs_mc:mooshroom", S("Mooshroom"), "mobs_mc_spawn_icon_mooshroom.png", 0)

if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC Cow loaded")
end
