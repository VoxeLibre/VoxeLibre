if minetest.get_modpath("sfinv") then
	local S
	if minetest.get_modpath("intllib") then
		S = intllib.Getter()
	else
		S = function ( s ) return s end
	end

	sfinv.register_page("awards:awards", {
		title = S("Awards"),
		on_enter = function(self, player, context)
			context.awards_idx = 1
		end,
		get = function(self, player, context)
			local name = player:get_player_name()
			return sfinv.make_formspec(player, context,
				awards.getFormspec(name, name, context.awards_idx or 1),
				false, "size[11,5]")
		end,
		on_player_receive_fields = function(self, player, context, fields)
			if fields.awards then
				local event = minetest.explode_textlist_event(fields.awards)
				if event.type == "CHG" then
					context.awards_idx = event.index
					sfinv.set_player_inventory_formspec(player, context)
				end
			end
		end
	})
end
