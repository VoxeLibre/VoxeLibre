-- Automatically assign the “solid” group for solid nodes
local overwrite = function()
	for nname, ndef in pairs(minetest.registered_nodes) do
		if (nname ~= "ignore")
				and (ndef.walkable == nil or ndef.walkable == true)
				and (ndef.collision_box == nil or ndef.collision_box.type == "regular")
				and (ndef.node_box == nil or ndef.node_box.type == "regular")
				and (ndef.groups.falling_node == 0 or ndef.groups.falling_node == nil)
				and (ndef.groups.not_solid == 0 or ndef.groups.not_solid == nil) then
			local groups = table.copy(ndef.groups)
			groups.solid = 1
			minetest.override_item(nname, {
				groups = groups
			})
		end
	end
end

overwrite()
