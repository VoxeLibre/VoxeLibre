local auto_refill = false  -- set to false if you dont want get refilled your stack automatic

function refill(player, stck_name, index)
	local inv = player:get_inventory()
	for i,stack in ipairs(inv:get_list("main")) do
		if stack:get_name() == stck_name then
			inv:set_stack("main", index, stack)
			stack:clear()
			inv:set_stack("main", i, stack)
			minetest.log("action", "intweak-mod: refilled stack of"  .. player:get_player_name()  )
			return
		end
	end
end

if auto_refill == true then
	minetest.register_on_placenode(function(pos, newnode, placer, oldnode)
		if not placer then return end
		local index = placer:get_wield_index()
		local cnt = placer:get_wielded_item():get_count()-1
		if cnt == 0 then minetest.after(0.01, refill, placer, newnode.name, index) end
	end)
end

local typ = ""
local tname = ""
minetest.register_on_punchnode(function(pos, node, puncher)
	if not puncher then return end
	tname = puncher:get_wielded_item():get_name()
	typ = minetest.registered_items[tname].type
	if typ == "tool" and puncher:get_wielded_item():get_wear() == 65535 then
		minetest.sound_play("intweak_tool_break", {gain = 1.5, max_hear_distance = 5})
		if auto_refill == true then minetest.after(0.01, refill, puncher, tname, puncher:get_wield_index()) end
	end
end)

minetest.register_on_dignode(function(pos, oldnode, digger)
		if not digger then return end
		local num = digger:get_wielded_item():get_wear()
		local index = digger:get_wield_index()
		if num == 0 and typ == "tool" then
			minetest.sound_play("intweak_tool_break", {gain = 1.5, max_hear_distance = 5})
			if auto_refill == true then minetest.after(0.01, refill, digger, tname, index) end
		end
end)