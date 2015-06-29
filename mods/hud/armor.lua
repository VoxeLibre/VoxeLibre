minetest.after(0, function()
 if not armor.def then
	minetest.after(2,minetest.chat_send_all,"#Better HUD: Please update your version of 3darmor")
	HUD_SHOW_ARMOR = false
 end
end)

function hud.get_armor(player)
	if not player or not armor.def then
		return
	end
	local name = player:get_player_name()
	hud.set_armor(player, armor.def[name].state, armor.def[name].count)
end

function hud.set_armor(player, ges_state, items)
	if not player then return end

	local max_items = 4
	if items == 5 then max_items = items end
	local max = max_items*65535
	local lvl = max - ges_state
	lvl = lvl/max
	if ges_state == 0 and items == 0 then
		lvl = 0
	end

	hud.armor[player:get_player_name()] = lvl*(items*(20/max_items))


end