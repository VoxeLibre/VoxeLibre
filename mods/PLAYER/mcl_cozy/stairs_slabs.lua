-- only loaded if core.settings:get_bool("mcl_cozy_sit_on_stairs")

local function check_param2_and_sit(pos, ...)
	local param2 = core.get_node(pos).param2
	-- avoid inverted stairs
	if param2 >= 20 then return end
	return mcl_cozy.sit(pos, ...)
end

core.register_on_mods_loaded(function()
	for name, _ in pairs(core.registered_nodes) do
		-- bottom slabs
		if name:find("^mcl_stairs:slab") and not (name:find("_top$")) then
			core.override_item(name, {
				on_rightclick = mcl_cozy.sit,
			})
		-- stairs
		elseif name:find("^mcl_stairs:stair") then
			core.override_item(name, {
				on_rightclick = check_param2_and_sit,
				_mcl_cozy_offset = vector.new(0, 0, -0.15),
			})
		end
	end
end)
