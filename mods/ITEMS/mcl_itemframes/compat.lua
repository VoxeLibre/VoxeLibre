local S = core.get_translator(core.get_current_modname())

local entity_stub = {
	on_activate = function(self)
		self.object:remove()
	end
}

-- Replace old item frames and their entities
core.register_entity("mcl_itemframes:item_frame_item", entity_stub)
core.register_entity("mcl_itemframes:item_frame_map", entity_stub)
core.register_entity("mcl_itemframes:glow_item_frame_item", entity_stub)
core.register_entity("mcl_itemframes:glow_item_frame_map", entity_stub)

core.register_alias("mcl_itemframes:item_frame", "mcl_itemframes:frame")
core.register_alias("mcl_itemframes:glow_item_frame", "mcl_itemframes:glow_frame")

core.register_lbm({
	label = "Convert old itemframes",
	name = "mcl_itemframes:convert_old_itemframes",
	nodenames = {"mcl_itemframes:item_frame", "mcl_itemframes:glow_item_frame"},
	run_at_every_load = false,
	action = function(pos, node)
		node.name = node.name:gsub("item_","")
		node.param2 = core.dir_to_wallmounted(core.facedir_to_dir(node.param2))
		core.swap_node(pos, node)
		mcl_itemframes.remove_entity(pos)
		mcl_itemframes.update_entity(pos)
	end
})

-- Wrapper for backwards compatibility with the old API
function mcl_itemframes.create_custom_frame(_, name, has_glow, tiles, _, ttframe, description, inv_wield_image)
	if not inv_wield_image or inv_wield_image == "" then
		inv_wield_image = tiles
	end

	local def = {
		node = {
			description = description,
			_tt_help = ttframe,
			_doc_items_longdesc = S("Item frames are decorative blocks in which items can be placed."),
			_doc_items_usagehelp = S("Just place any item on the item frame. Use the item frame again to retrieve the item."),
			tiles = {tiles},
			inventory_image = inv_wield_image,
			wield_image = inv_wield_image,
		}
	}
	if has_glow then
		def.object_properties = {glow = 15}
	end

	return mcl_itemframes.register_itemframe(name, def)
end
