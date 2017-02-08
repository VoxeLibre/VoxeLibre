--[[
  mcl_clock, renew of the renew of the watch mod

  Original from Echo, here: http://forum.minetest.net/viewtopic.php?id=3795
]]--

local watch = {}
watch.old_time = -1

-- Image of all 64 possible faces
watch.images = {}
for frame=0,63 do
	table.insert(watch.images, "mcl_clock_clock.png^[verticalframe:64:"..frame)
end

local function round(num)
	return math.floor(num + 0.5)
end

function watch.get_clock_frame()
	local t = 64 * minetest.get_timeofday()
	return tostring(round(t))
end

-- Register items
function watch.register_item(name, image, creative)
	local g = 1
	if creative then
		g = 0
	end
	minetest.register_craftitem(name, {
		description = "Clock",
		inventory_image = image,
		groups = {not_in_creative_inventory=g, tool=1, clock=1},
		wield_image = "",
		stack_max = 64,
	})
end

-- This timer makes sure the clocks get updated from time to time regardless of time_speed,
-- just in case some clocks in the world go wrong
local force_clock_update_timer = 0

minetest.register_globalstep(function(dtime)
	local now = watch.get_clock_frame()
	force_clock_update_timer = force_clock_update_timer + dtime

	if watch.old_time == now and force_clock_update_timer < 60 then
		return
	end
	force_clock_update_timer = 0

	watch.old_time = now

	local players = minetest.get_connected_players()
	for p, player in ipairs(players) do
		for s, stack in ipairs(player:get_inventory():get_list("main")) do
			local count = stack:get_count()
			if stack:get_name() == "mcl_clock:clock" then
				player:get_inventory():set_stack("main", s, "mcl_clock:clock_"..now.." "..count)
			elseif string.sub(stack:get_name(), 1, 16) == "mcl_clock:clock_" then
				player:get_inventory():set_stack("main", s, "mcl_clock:clock_"..now.." "..count)
			end
		end
	end
end)

-- Immediately set correct clock time after crafting
minetest.register_on_craft(function(itemstack)
	if itemstack:get_name() == "mcl_clock:clock" then
		itemstack:set_name("mcl_clock:clock_"..watch.get_clock_frame())
	end
end)

-- Clock recipe
minetest.register_craft({
	output = 'mcl_clock:clock',
	recipe = {
		{'', 'mcl_core:gold_ingot', ''},
		{'mcl_core:gold_ingot', 'mesecons:redstone', 'mcl_core:gold_ingot'},
		{'', 'mcl_core:gold_ingot', ''}
	}
})

-- Clock tool
watch.register_item("mcl_clock:clock", watch.images[1], true)

-- Faces
for a=0,63,1 do
	local b = a
	if b > 31 then
		b = b - 32
	else
		b = b + 32
	end
	watch.register_item("mcl_clock:clock_"..tostring(a), watch.images[b+1], false)
end
