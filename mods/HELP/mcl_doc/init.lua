-- Disable built-in factoids; it is planned to add custom ones as replacements
doc.sub.items.disable_core_factoid("node_mining")
doc.sub.items.disable_core_factoid("tool_capabilities")

-- Help button callback
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.__mcl_doc then
		doc.show_doc(player:get_player_name())
	end
end)
