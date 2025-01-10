mcl_itemframes = {
	registered_nodes = {},
	registered_itemframes = {},
}

local S = core.get_translator(core.get_current_modname())

local longdesc = S("Item frames are decorative blocks in which items can be placed.")
local usagehelp = S("Just place any item on the item frame. Use the item frame again to retrieve the item.")

local function table_merge(t, ...)
	local t2 = table.copy(t)
	return table.update(t2, ...)
end

local fbox = {
	type = "fixed",
	fixed = {-6/16, -1/2, -6/16, 6/16, -7/16, 6/16}
}

local base_props = {
	visual = "wielditem",
	visual_size = {x = 0.3, y = 0.3},
	physical = false,
	pointable = false,
	textures = {"blank.png"},
}

local map_props = {
	visual = "upright_sprite",
	visual_size = {x = 1, y = 1},
	collide_with_objects = false,
	textures = {"blank.png"},
}

local tpl_node = {
	drawtype = "mesh",
	is_ground_content = false,
	mesh = "mcl_itemframes_frame.obj",
	selection_box = fbox,
	collision_box = fbox,
	use_texture_alpha = "opaque",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	node_placement_prediction = "",
	_mcl_hardness = 0.5,
	_mcl_blast_resistance = 0.5,
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usagehelp,
	after_dig_node = mcl_util.drop_items_from_meta_container("main"),
	allow_metadata_inventory_move = function() return 0 end,
	allow_metadata_inventory_put = function() return 0 end,
	allow_metadata_inventory_take = function() return 0 end,
}

local tpl_entity = {
	initial_properties = base_props,
}

local tpl_groups = {
	dig_immediate = 3,
	deco_block = 1,
	dig_by_piston = 1,
	handy = 1,
	axey = 1,
	attached_node = 1,
	itemframe = 1
}

-- Utility functions
local function find_entity(pos)
	for _,o in pairs(core.get_objects_inside_radius(pos, 0.45)) do
		local l = o:get_luaentity()
		if l and l.name == "mcl_itemframes:item" then
			return l
		end
	end
end

local function find_or_create_entity(pos)
	local l = find_entity(pos)
	if not l then
		l = core.add_entity(pos, "mcl_itemframes:item"):get_luaentity()
	end
	return l
end

local function remove_entity(pos)
	local l = find_entity(pos)
	if l then
		l.object:remove()
	end
end
mcl_itemframes.remove_entity = remove_entity

local function drop_item(pos)
	local inv = core.get_meta(pos):get_inventory()
	core.add_item(pos, inv:get_stack("main", 1))
	inv:set_stack("main", 1, ItemStack(""))
	remove_entity(pos)
end

local function get_map_id(itemstack)
	local map_id = itemstack:get_meta():get_string("mcl_maps:id")
	if map_id == "" then map_id = nil end
	return map_id
end

local function update_entity(pos)
	if not pos then return end
	local inv = core.get_meta(pos):get_inventory()
	local itemstack = inv:get_stack("main", 1)
	if not itemstack then
		remove_entity(pos)
		return
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
mcl_itemframes.update_entity = update_entity

-- Node functions
function tpl_node.on_rightclick(pos, node, clicker, ostack, pointed_thing)
	local name = clicker:get_player_name()
	if core.is_protected(pos, name) then
		core.record_protection_violation(pos, name)
		return ostack
	end
	local pstack = ItemStack(ostack)
	local itemstack = pstack:take_item()
	local inv = core.get_meta(pos):get_inventory()
	drop_item(pos)
	inv:set_stack("main", 1, itemstack)
	update_entity(pos)
	if not core.is_creative_enabled(clicker:get_player_name()) then
		return pstack
	end
	return ostack
end

tpl_node.on_destruct = remove_entity

function tpl_node.on_construct(pos)
	local meta = core.get_meta(pos)
	local inv = meta:get_inventory()
	inv:set_size("main", 1)
end

function tpl_node.after_place_node(pos, placer, itemstack, pointed_thing)
	-- hack to force the place sound to play
	local idef = itemstack:get_definition()
	if idef and idef.sounds and idef.sounds.place then
		core.sound_play(idef.sounds.place, {pos = pos}, true)
	end
end

-- Entity functions
function tpl_entity:set_item(itemstack, pos)
	if not itemstack or not itemstack.get_name then
		self.object:remove()
		update_entity(pos)
		return
	end

	if pos then
		self._itemframe_pos = pos
	else
		pos = self._itemframe_pos
	end

	local ndef = core.registered_nodes[core.get_node(pos).name]
	if not ndef._mcl_itemframe then
		self.object:remove()
		update_entity(pos)
		return
	end

	local def = mcl_itemframes.registered_itemframes[ndef._mcl_itemframe]

	self._item = itemstack:get_name()
	self._stack = itemstack
	self._map_id = get_map_id(itemstack)

	local dir = core.wallmounted_to_dir(core.get_node(pos).param2)
	self.object:set_pos(vector.add(self._itemframe_pos, dir * 0.42))
	self.object:set_rotation(vector.dir_to_rotation(dir))

	-- map support
	if self._map_id then
		local unran_callback = true
		mcl_maps.load_map(self._map_id, function(texture)
			unran_callback = false
			if self.object and self.object:get_pos() then
				self.object:set_properties(table_merge(map_props, {textures = {texture}}))
			end
		end)
		-- dirty recursive hack because dynamic_add_media is unreliable
		-- (and subsequently, mcl_maps.load_map is just as unreliable)
		core.after(0, function()
			if unran_callback then
				update_entity(pos)
			end
		end)
		return
	end

	local idef = itemstack:get_definition()
	local ws = idef.wield_scale
	self.object:set_properties(table_merge(base_props, {
		wield_item = self._item,
		-- apply the wield_scale to the set item
		visual_size = {
			x = base_props.visual_size.x / ws.x,
			y = base_props.visual_size.y / ws.y
		},
	}, def.object_properties or {}))
end

function tpl_entity:get_staticdata()
	local s = {
		item = self._item,
		itemframe_pos = self._itemframe_pos,
		itemstack = self._itemstack,
		map_id = self._map_id
	}
	s.props = self.object:get_properties()
	return core.serialize(s)
end

function tpl_entity:on_activate(staticdata, dtime_s)
	local s = core.deserialize(staticdata)
	if (type(staticdata) == "string" and dtime_s and dtime_s > 0) then
		-- try to re-initialize items without proper staticdata
		local p = core.find_node_near(self.object:get_pos(), 1, {"group:itemframe"})
		self.object:remove()
		if p then
			update_entity(p)
		end
		return
	elseif s then
		self._itemframe_pos = s.itemframe_pos
		self._itemstack = s.itemstack
		self._item = s.item
		self._map_id = s.map_id
		update_entity(self._itemframe_pos)
		return
	end
end

function tpl_entity:on_step(dtime)
	self._timer = (self._timer and self._timer - dtime) or 1
	if self._timer > 0 then return end
	self._timer = 1

	if core.get_item_group(core.get_node(self._itemframe_pos).name, "itemframe") <= 0 then
		self.object:remove()
		return
	end

	-- update clock if present
	if core.get_item_group(self._item, "clock") > 0 then
		self:set_item(ItemStack("mcl_clock:clock_"..mcl_clock.get_clock_frame()))
	end
end

function mcl_itemframes.register_itemframe(name, def)
	if not def.node then return end
	local nodename = "mcl_itemframes:"..name
	table.insert(mcl_itemframes.registered_nodes, nodename)
	mcl_itemframes.registered_itemframes[name] = def
	core.register_node(":"..nodename, table_merge(tpl_node, def.node, {
		_mcl_itemframe = name,
		groups = table_merge(tpl_groups, def.node.groups)
	}))
end

core.register_entity("mcl_itemframes:item", tpl_entity)

core.register_lbm({
	label = "Respawn item frame item entities",
	name = "mcl_itemframes:respawn_entities",
	nodenames = {"group:itemframe"},
	run_at_every_load = true,
	action = function(pos)
		update_entity(pos)
	end
})

local modpath = core.get_modpath(core.get_current_modname())

dofile(modpath .. "/register.lua")
dofile(modpath .. "/compat.lua")
