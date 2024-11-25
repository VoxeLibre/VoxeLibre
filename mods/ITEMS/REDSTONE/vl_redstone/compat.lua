local function mesecons_compat_on_power_change(pos, node, def, power, old_power)
	if power == 0 and old_power ~= 0 then
		local hook = def.mesecons.effector.action_off
		if hook then hook(pos) end

		hook = def.mesecons.effector.action_change
		if hook then hook(pos) end
	end
	if power ~= 0 and old_power == 0 then
		local hook = def.mesecons.effector.action_on
		if hook then hook(pos) end

		hook = def.mesecons.effector.action_change
		if hook then hook(pos) end
	end
end

core.register_on_mods_loaded(function()
	for name,def in pairs(core.registered_nodes) do
		if def.mesecons and not def.vl_redstone then
			local new_groups = table.copy(def.groups)
			new_groups.redstone = 1
			core.override_item(def.name,{
				groups = new_groups,
				vl_redstone = {
					on_power_change = mesecons_compat_on_power_change,
					sink = def.mesecons.effector and true,
					source = def.mesecons.receptor and true,
				}
			})
		end
	end
end)
