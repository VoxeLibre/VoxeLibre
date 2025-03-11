-- only loaded if core.settings:get_bool("mcl_cozy_sit_on_stairs")

local function sit(pos, node, player, itemstack, pointed_thing)
	-- avoid bugs with stair/slabs' `on_rightclick`
	if not pointed_thing then return end
	return mcl_cozy.sit(pos, node, player, itemstack, pointed_thing)
end

local function check_param2_and_sit(pos, node, ...)
	-- avoid inverted stairs
	if node.param2 >= 20 then return end
	return sit(pos, node, ...)
end

core.register_on_mods_loaded(function()
	for name, _ in pairs(core.registered_nodes) do
		-- bottom slabs
		if name:find("^mcl_stairs:slab") and not (name:find("_top$") or name:find("_double$")) then
			core.override_item(name, {
				on_rightclick = sit,
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
