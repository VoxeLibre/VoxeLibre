local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
vl_node_entity = {}
local mod = vl_node_entity

local cube_node_entity = {
	initial_properties = {
		hp_max = 1,
		physical = true,
		pointable = false,
		collide_with_objects = true,
		collision_box = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
	},
	visual = "wielditem",
	textures = { "mcl_core:dirt_with_grass" },
}
function cube_node_entity:on_activate(staticdata, dtime_unloaded)
	local staticdata = minetest.deserialize(staticdata)
	self._staticdata = staticdata

	local props = {
		visual = "wielditem",
		textures = { staticdata.nodename },
	}
	self.object:set_properties(props)
end
function cube_node_entity:get_staticdata()
	return minetest.serialize(self._staticdata)
end
minetest.register_entity("vl_node_entity:cube_node", cube_node_entity)

function mod.create_node_entity(pos, nodename)
	local staticdata = {
		nodename = nodename
	}
	return minetest.add_entity(pos, "vl_node_entity:cube_node",minetest.serialize(staticdata))
end

