mcl_itemframes = {}
mcl_itemframes.registered_nodes = {}
mcl_itemframes.registered_itemframes = {}
local S = minetest.get_translator(minetest.get_current_modname())

--[[ TODO: implement stubs for these entities and remove/replace them
	minetest.register_entity("mcl_itemframes:map", map_item_base)
	minetest.register_entity("mcl_itemframes:glow_item", frame_item_base)
	minetest.register_entity("mcl_itemframes:glow_map", map_item_base)
--]]

local fbox = {type = "fixed", fixed = {-6/16, -1/2, -6/16, 7/16, -7/16, 6/16}}

local base_props = {
	visual = "wielditem",
	visual_size = { x = 0.3, y = 0.3 },
	physical = false,
	pointable = false,
	textures = { "blank.png" },
}

local map_props = {
	visual = "upright_sprite",
	visual_size = { x = 1, y = 1 },
	collide_with_objects = false,
	textures = { "blank.png" },
}

local function block_inv() return 0 end

mcl_itemframes.tpl_node = {
	drawtype = "nodebox",
	is_ground_content = false,
	node_box = fbox,
	selection_box = fbox,
	collision_box = fbox,
	use_texture_alpha = "opaque",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	sounds = mcl_sounds.node_sound_defaults(),
	node_placement_prediction = "",
	_mcl_hardness = 0.5,
	_mcl_blast_resistance = 0.5,
	after_dig_node = mcl_util.drop_items_from_meta_container({"main"}),
	allow_metadata_inventory_move = block_inv,
	allow_metadata_inventory_put = block_inv,
	allow_metadata_inventory_take = block_inv,
}

mcl_itemframes.tpl_entity = {
	initial_properties = base_props,
}

local function find_entity(pos)
	for _,o in pairs(minetest.get_objects_inside_radius(pos, 0.45)) do
		local l = o:get_luaentity()
		if l and l.name == "mcl_itemframes:item" then
			return l
		end
	end
end

local function find_or_create_entity(pos)
	local l = find_entity(pos)
	if not l then
		l = minetest.add_entity(pos, "mcl_itemframes:item"):get_luaentity()
	end
	return l
end

local function remove_entity(pos)
	local l = find_entity(pos)
	if l then
		l.object:remove()
	end
end

local function drop_item(pos)
	local inv = minetest.get_meta(pos):get_inventory()
	minetest.add_item(pos, inv:get_stack("main", 1))
	inv:set_stack("main", 1, ItemStack(""))
	remove_entity(pos)
end

local function get_map_id(itemstack)
	local map_id = itemstack:get_meta():get_string("mcl_maps:id")
	if map_id == "" then map_id = nil end
	return map_id
end

local function update_entity(pos, itemstack)
	if not itemstack then
		local inv = minetest.get_meta(pos):get_inventory()
		itemstack = inv:get_stack("main", 1)
		if not itemstack then
			remove_entity(pos)
			return
		end
	end
	local itemstring = itemstack:get_name()
	local l = find_or_create_entity(pos)
	if not itemstring or itemstring == "" then
		remove_entity(pos)
		return
	end
	l:set_item(itemstack, pos)
	return l
end

function mcl_itemframes.tpl_node.on_rightclick(pos, node, clicker, pstack, pointed_thing)
	local itemstack = pstack:take_item()
	local inv = minetest.get_meta(pos):get_inventory()
	drop_item(pos)
	inv:set_stack("main", 1, itemstack)
	update_entity(pos, itemstack)
	if not minetest.is_creative_enabled(clicker:get_player_name()) then
		return pstack
	end
end

mcl_itemframes.tpl_node.on_destruct = remove_entity

function mcl_itemframes.tpl_node.on_construct(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	inv:set_size("main", 1)
end

function mcl_itemframes.tpl_entity:set_item(itemstack, pos)
	self._itemframe_pos = pos
	self._item = itemstack:get_name()
	self._stack = itemstack
	self._map_id = get_map_id(itemstack)

	local dir = minetest.wallmounted_to_dir(minetest.get_node(pos).param2)
	self.object:set_pos(vector.add(self._itemframe_pos, dir * 0.42))
	self.object:set_rotation(vector.dir_to_rotation(dir))

	if self._map_id then
		mcl_maps.load_map(self._map_id, function(texture)
			if self.object and self.object:get_pos() then
				self.object:set_properties(table.merge(map_props, { textures = { texture }}))
			end
		end)
		return
	end
	self.object:set_properties(table.merge(base_props, { wield_item = self._item}))
end
function mcl_itemframes.tpl_entity:get_staticdata()
	local s = { item = self._item, itemframe_pos = self._itemframe_pos, itemstack = self._itemstack, map_id = self._map_id }
	s.props = self.object:get_properties()
	return minetest.serialize(s)
end
function mcl_itemframes.tpl_entity:on_activate(staticdata, dtime_s)
	local s = minetest.deserialize(staticdata)
	if s then
		self._itemframe_pos = s.itemframe_pos
		self._itemstack = s.itemstack
		self._item = s.item
		self._map_id = s.map_id
		update_entity(self._itemframe_pos, ItemStack(self._itemstack))
		return
	end
end
function mcl_itemframes.tpl_entity:on_step(dtime)
	self._timer = (self._timer and self._timer - dtime) or 1
	if self._timer > 0 then return end
	self._timer = 1
	if minetest.get_item_group(minetest.get_node(self._itemframe_pos).name, "itemframe") <= 0 then
		self.object:remove()
		return
	end
	if minetest.get_item_group(self._item, "clock") > 0 then
		self:set_item("mcl_clock:clock_"..mcl_clock.get_clock_frame())
	end
end

function mcl_itemframes.register_itemframe(name, def)
	if not def.node then return end
	local nodename = "mcl_itemframes:"..name
	table.insert(mcl_itemframes.registered_nodes, nodename)
	mcl_itemframes.registered_itemframes[name] = def
	minetest.register_node(":"..nodename, table.merge(mcl_itemframes.tpl_node, def.node, {
		_mcl_itemframe = name,
		groups = table.merge({ dig_immediate = 3, deco_block = 1, dig_by_piston = 1, handy = 1, axey = 1, itemframe = 1 }, def.node.groups),
	}))
end

minetest.register_entity("mcl_itemframes:item", mcl_itemframes.tpl_entity)

mcl_itemframes.register_itemframe("frame", {
	node = {
		description = S("Item Frame"),
		_tt_help = S("Can hold an item"),
		_doc_items_longdesc = S("Item frames are decorative blocks in which items can be placed."),
		_doc_items_usagehelp = S("Just place any item on the item frame. Use the item frame again to retrieve the item."),
		tiles = { "mcl_itemframes_item_frame.png" },
		inventory_image = "mcl_itemframes_item_frame.png",
		wield_image = "mcl_itemframes_item_frame.png",
	},
})

mcl_itemframes.register_itemframe("glow_frame", {
	node = {
		description = S("Glow Item Frame"),
		_tt_help = S("Can hold an item and glows"),
		_doc_items_longdesc = S("Item frames are decorative blocks in which items can be placed."),
		_doc_items_usagehelp = S("Just place any item on the item frame. Use the item frame again to retrieve the item."),
		tiles = { "mcl_itemframes_glow_item_frame.png" },
		inventory_image = "mcl_itemframes_glow_item_frame.png",
		wield_image = "mcl_itemframes_glow_item_frame.png",
	},
	object_properties = { glow = 15 },
})

minetest.register_lbm({
	label = "Respawn item frame item entities",
	name = "mcl_itemframes:respawn_entities",
	nodenames = { "group:itemframe" },
	run_at_every_load = true,
	action = function(pos,_)
		update_entity(pos)
	end
})

-- Register the base frame's recipes.
minetest.register_craft({
	output = "mcl_itemframes:item_frame",
	recipe = {
		{ "mcl_core:stick", "mcl_core:stick", "mcl_core:stick" },
		{ "mcl_core:stick", "mcl_mobitems:leather", "mcl_core:stick" },
		{ "mcl_core:stick", "mcl_core:stick", "mcl_core:stick" },
	}
})

minetest.register_craft({
	type = "shapeless",
	output = 'mcl_itemframes:glow_item_frame',
	recipe = { 'mcl_mobitems:glow_ink_sac', 'mcl_itemframes:item_frame' },
})
