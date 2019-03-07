minetest.register_on_joinplayer(function(player)
	local bg = ""--"bgcolor[#080808BB;true]"
	local slots = "listcolors[#9990;#FFF7;#FFF0;#000;#FFF]"
	local prepend = bg .. slots
--	player:set_formspec_prepend(prepend)
end)
