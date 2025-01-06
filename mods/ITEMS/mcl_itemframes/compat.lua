local entity_stub = {
	on_activate = function(self)
		self.object:remove()
	end
}

core.register_entity("mcl_itemframes:item_frame_item", entity_stub)
core.register_entity("mcl_itemframes:item_frame_map", entity_stub)
core.register_entity("mcl_itemframes:glow_item_frame_item", entity_stub)
core.register_entity("mcl_itemframes:glow_item_frame_map", entity_stub)

core.register_alias("mcl_itemframes:item_frame", "mcl_itemframes:frame")
core.register_alias("mcl_itemframes:glow_item_frame", "mcl_itemframes:glow_frame")

-- TODO: add compatibility with the old API

core.register_lbm({
	label = "Convert old itemframes",
	name = "mcl_itemframes:convert_old_itemframes",
	nodenames = { "mcl_itemframes:item_frame", "mcl_itemframes:glow_item_frame" },
	run_at_every_load = false,
	action = function(pos, node)
		node.name = node.name:gsub("item_","")
		node.param2 = core.dir_to_wallmounted(core.facedir_to_dir(node.param2))
		core.swap_node(pos, node)
		mcl_itemframes.remove_entity(pos)
		mcl_itemframes.update_entity(pos)
	end
})
