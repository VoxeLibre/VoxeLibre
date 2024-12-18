local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)


minetest.register_tool("mcl_shepherd:shepherd_staff", {
	description = S("Shepherd Staff"),
	_doc_items_longdesc = "", -- TODO
	_doc_items_usagehelp = "", -- TODO
	inventory_image = "mcl_tool_shepherd_staff.png",
	wield_scale = 1.3*mcl_vars.tool_wield_scale,
	stack_max = 1,
	groups = { weapon=1, tool=1, staff=1, enchantability=-1 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=1,
		damage_groups = {fleshy=2},
		punch_attack_uses = 45,
	},
	sound = { breaks = "default_tool_breaks" },
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 1, level = 1, uses = 60 },
		swordy_cobweb = { speed = 1, level = 1, uses = 60 }
	},
	_mcl_not_consumable = true,
})

if mcl_util.is_it_christmas() then
	minetest.register_globalstep(function(dtime)
		local time = minetest.get_timeofday()
		if time < 0.005 or time > 0.995 then
			for _, player in pairs(minetest.get_connected_players()) do
				local meta = player:get_meta()
				local sp = meta:get_int("mcl_shepherd:special")
				if sp == 0 and player:get_wielded_item():get_definition().groups.staff then
					local has_sheep = false
					for _, obj in pairs(minetest.get_objects_inside_radius(player:get_pos(), 3)) do
						local ent = obj:get_luaentity()
						if ent and ent.name == "mobs_mc:sheep" then
							has_sheep = true
							break
						end
					end
					if has_sheep then
						minetest.sound_play(
							{name="shepherd-midnight", gain=3, pitch=1.0},
							{to_player=player:get_player_name(), gain=1.0, fade=0.0, pitch=1.0},
							false
						)
						meta:set_int("mcl_shepherd:special", 1)
						mcl_weather.skycolor.update_sky_color({player})
						minetest.after(45, function(name)
							local player = minetest.get_player_by_name(name)
							if not player then return end
							local meta = player:get_meta()
							meta:set_int("mcl_shepherd:special", 0)
							mcl_weather.skycolor.update_sky_color({player})
						end, player:get_player_name())
					end
				end
			end
		end
	end)
	minetest.register_on_joinplayer(function(player)
		local meta = player:get_meta()
		meta:set_int("mcl_shepherd:special", 0)
	end)
end

minetest.register_craft({
	output = "mcl_shepherd:shepherd_staff",
	recipe = {
		{"","","mcl_core:stick"},
		{"","mcl_core:stick",""},
		{"mcl_core:stick","",""},
	}
})
minetest.register_craft({
	output = "mcl_shepherd:shepherd_staff",
	recipe = {
		{"mcl_core:stick", "", ""},
		{"", "mcl_core:stick", ""},
		{"","","mcl_core:stick"},
	}
})
minetest.register_craft({
	type = "fuel",
	recipe = "mcl_shepherd:shepherd_staff",
	burntime = 15,
})
