--[[
  mcl_clock, renew of the renew of the watch mod

  Original from Echo, here: http://forum.minetest.net/viewtopic.php?id=3795
]]--

watch = {}
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
	minetest.register_tool(name, {
		description = "Clock",
		inventory_image = image,
		groups = {not_in_creative_inventory=g, clock=1},
		wield_image = "",
		stack_max = 1,
	})
end

minetest.register_globalstep(function(dtime)
	local now = watch.get_clock_frame()

	if watch.old_time == now then
		return
	end

	watch.old_time = now

	local players = minetest.get_connected_players()
	for p, player in ipairs(players) do
		for s, stack in ipairs(player:get_inventory():get_list("main")) do
			if stack:get_name() == "mcl_clock:clock" then
				player:get_inventory():set_stack("main", s, "mcl_clock:clock_"..now)
			elseif string.sub(stack:get_name(), 1, 16) == "mcl_clock:clock_" then
				player:get_inventory():set_stack("main", s, "mcl_clock:clock_"..now)
			end
		end
	end
end)
