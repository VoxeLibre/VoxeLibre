local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local S = core.get_translator(modname)


core.register_tool("mcl_shepherd:shepherd_staff", {
	description = S("Shepherd Staff"),
	_doc_items_longdesc = "Sheep happily follow you when you hold this staff of authority",
	_doc_items_usagehelp = "Hold in hand to lead sheep. Can serve as a weak melee weapon.",
	inventory_image = "mcl_tool_shepherd_staff.png",
	wield_scale = 1.3*mcl_vars.tool_wield_scale,
	stack_max = 1,
	groups = { weapon=1, tool=1, staff=1, enchantability=-1 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level = 1,
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

local ironized_tex = "mcl_tool_shepherd_staff.png^[hsl:0:-100:40"
local esc_iron_tex = "mcl_tool_shepherd_staff.png\\^[hsl\\:0\\:-100\\:40"
local iron_rod_tex = table.concat{
	ironized_tex,
	"^[hardlight:", esc_iron_tex,
	"^[hardlight:", esc_iron_tex,
	"^[hardlight:", esc_iron_tex
}

core.register_tool("mcl_shepherd:rod_of_iron", {
	description = S("Shepherd's Rod of Iron"),
	_doc_items_longdesc = "Use it to selectively lead animals",
	_doc_items_usagehelp = "Right-click an animal to lead it. Right-click again to release. Can serve as a melee weapon.",
	inventory_image = iron_rod_tex,
	wield_scale = 1.3*mcl_vars.tool_wield_scale,
	stack_max = 1,
	groups = { weapon=1, tool=1, staff=1, enchantability=-1 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level = 4,
		damage_groups = {fleshy=5},
		punch_attack_uses = 300,
	},
	sound = { breaks = "default_tool_breaks" },
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 1, level = 1, uses = 300 },
		swordy_cobweb = { speed = 1, level = 1, uses = 300 }
	},
	_mcl_not_consumable = true,
})

core.register_on_mods_loaded(function()
	for _, def in pairs(core.registered_entities) do
		if def.type == "animal" then
			local old_f = def.on_rightclick
			def.on_rightclick = function(self, clicker)
				local item = clicker:get_wielded_item()
				if item and item:get_name() == "mcl_shepherd:rod_of_iron" then
					if self.led_by_rod_of_iron then
						for i, f in ipairs(self.follow) do
							if f == "mcl_shepherd:rod_of_iron" then
								table.remove(self.follow, i)
								break
							end
						end
						self.led_by_rod_of_iron = false
					else
						if type(self.follow ~= "table") then
							self.follow = {self.follow}
						end
						table.insert(self.follow, "mcl_shepherd:rod_of_iron")
						self.led_by_rod_of_iron = true
					end
				else old_f(self, clicker) end
			end
		end
	end
end)



if mcl_util.is_it_christmas() then
	core.register_globalstep(function(dtime)
		local time = core.get_timeofday()
		if time < 0.005 or time > 0.995 then
			for _, player in pairs(core.get_connected_players()) do
				local meta = player:get_meta()
				local sp = meta:get_int("mcl_shepherd:special")
				if sp == 0 and player:get_wielded_item():get_definition().groups.staff then
					local has_sheep = false
					for _, obj in pairs(core.get_objects_inside_radius(player:get_pos(), 3)) do
						local ent = obj:get_luaentity()
						if ent and ent.name == "mobs_mc:sheep" then
							has_sheep = true
							break
						end
					end
					if has_sheep then
						core.sound_play(
							{name="shepherd-midnight", gain=3, pitch=1.0},
							{to_player=player:get_player_name(), gain=1.0, fade=0.0, pitch=1.0},
							false
						)
						meta:set_int("mcl_shepherd:special", 1)
						mcl_weather.skycolor.update_sky_color({player})
						core.after(45, function(name)
							local player = core.get_player_by_name(name)
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
	core.register_on_joinplayer(function(player)
		local meta = player:get_meta()
		meta:set_int("mcl_shepherd:special", 0)
	end)
end



core.register_craft({
	output = "mcl_shepherd:shepherd_staff",
	recipe = {
		{"","","mcl_core:stick"},
		{"","mcl_core:stick",""},
		{"mcl_core:stick","",""},
	}
})
core.register_craft({
	output = "mcl_shepherd:shepherd_staff",
	recipe = {
		{"mcl_core:stick", "", ""},
		{"", "mcl_core:stick", ""},
		{"","","mcl_core:stick"},
	}
})
core.register_craft({
	type = "fuel",
	recipe = "mcl_shepherd:shepherd_staff",
	burntime = 15,
})

core.register_craft({
	output = "mcl_shepherd:rod_of_iron",
	recipe = {
		{"","","mcl_core:iron_ingot"},
		{"","mcl_core:iron_ingot",""},
		{"mcl_core:iron_ingot","",""},
	}
})
core.register_craft({
	output = "mcl_shepherd:rod_of_iron",
	recipe = {
		{"mcl_core:iron_ingot", "", ""},
		{"", "mcl_core:iron_ingot", ""},
		{"","","mcl_core:iron_ingot"},
	}
})
