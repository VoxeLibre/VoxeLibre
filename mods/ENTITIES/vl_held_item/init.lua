local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
vl_held_item = {}
local mod = vl_held_item

local held_item_entity = {
	initial_properties = {
		hp_max = 1,
		physical = true,
		pointable = false,
		collide_with_objects = true,
		static_save = false, -- TODO remove/change later when needed to persist
		-- WARNING persisting held items not recommended, mob can recreate it after_activate
		collision_box = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
		visual = "wielditem",
		textures = { "mcl_core:dirt_with_grass" },
	},
}
function held_item_entity:on_activate(staticdata, dtime_unloaded)
	local staticdata = minetest.deserialize(staticdata)
	self._staticdata = staticdata

	local props = {
		visual = "wielditem",
		textures = { staticdata.itemname },
	}
	self.object:set_properties(props)
end
function held_item_entity:get_staticdata()
	return minetest.serialize(self._staticdata)
end
minetest.register_entity("vl_held_item:held_item_entity", held_item_entity)

function mod.create_item_entity(pos, itemname)
	local staticdata = {
		itemname = itemname
	}
	return minetest.add_entity(pos, "vl_held_item:held_item_entity", minetest.serialize(staticdata))
end

