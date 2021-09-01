local S = minetest.get_translator("mcl_totems")

mcl_totems = {
	totem_fail_nodes = {
		["mcl_core:void"] = true,
		["mcl_core:realm_barrier"] = true
	},
}

local hud_totem = {}

minetest.register_craftitem("mcl_totems:totem", {
	description = S("Totem of Undying"),
	_tt_help = minetest.colorize(mcl_colors.GREEN, S("Protects you from death while wielding it")),
	_doc_items_longdesc = S("A totem of undying is a rare artifact which may safe you from certain death."),
	_doc_items_usagehelp = S("The totem only works while you hold it in your hand. If you receive fatal damage, you are saved from death and you get a second chance with 1 HP. The totem is destroyed in the process, however."),
	inventory_image = "mcl_totems_totem.png",
	wield_image = "mcl_totems_totem.png",
	stack_max = 1,
	groups = {combat_item = 1},
})

minetest.register_on_leaveplayer(function(player)
	hud_totem[player] = nil
end)

-- Save the player from death when holding totem of undying in hand
mcl_damage.register_modifier(function(obj, damage, reason)
	if obj:is_player() then
		local hp = obj:get_hp()
		if hp - damage <= 0 then
			local wield = obj:get_wielded_item()
			if wield:get_name() == "mcl_totems:totem" then
				local ppos = obj:get_pos()
				local pnname = minetest.get_node(ppos).name
				-- Some exceptions when _not_ to save the player
				if mcl_totems.fail_nodes[pnname] then
					return
				end
				-- Reset breath as well
				if obj:get_breath() < 11 then
					obj:set_breath(10)
				end

				if not minetest.is_creative_enabled(obj:get_player_name()) then
					wield:take_item()
					obj:set_wielded_item(wield)
				end

				-- Effects
				minetest.sound_play({name = "mcl_totems_totem", gain=1}, {pos=ppos, max_hear_distance=16}, true)

				-- Big totem overlay
				if not hud_totem[obj] then
					hud_totem[obj] = obj:hud_add({
						hud_elem_type = "image",
						text = "mcl_totems_totem.png",
						position = { x=0.5, y=1 },
						scale = { x=17, y=17 },
						offset = { x=0, y=-178 },
						z_index = 100,
					})
					minetest.after(3, function()
						if obj:is_player() then
							obj:hud_remove(hud_totem[obj])
							hud_totem[obj] = nil
						end
					end)
				end

				-- Set HP to exactly 1
				return hp - 1
			end
		end
	end
end, 1000)
