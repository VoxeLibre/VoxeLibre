local S = minetest.get_translator(minetest.get_current_modname())

mcl_entity_invs = {}

local open_invs = {}

local function mcl_log (message)
	mcl_util.mcl_log (message, "[Entity Invs]")
end

local function check_distance(inv,player,count)
	for _,o in pairs(minetest.get_objects_inside_radius(player:get_pos(),5)) do
		local l = o:get_luaentity()
		if l and l._inv_id and inv:get_location().name == l._inv_id then return count end
	end
	return 0
end

local function create_entity_callbacks(ent)
	return {
		allow_take = function(inv, listname, index, stack, player)
			return check_distance(inv, player, stack:get_count())
		end,
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			return check_distance(inv, player, count)
		end,
		allow_put = function(inv, listname, index, stack, player)
			return check_distance(inv, player, stack:get_count())
		end,
		on_take = function(inv, listname, index, stack, player)
			if ent and ent.object then
				mcl_entity_invs.save_inv(ent)
			end
		end,
		on_put = function(inv, listname, index, stack, player)
			if ent and ent.object then
				mcl_entity_invs.save_inv(ent)
			end
		end,
		on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			if ent and ent.object then
				mcl_entity_invs.save_inv(ent)
			end
		end,
	}
end

function mcl_entity_invs.load_inv(ent,size)
	if not ent._inv_id then return end
	local inv = minetest.get_inventory({type="detached", name=ent._inv_id})
	if not inv then
		local callbacks = create_entity_callbacks(ent)
		inv =  minetest.create_detached_inventory(ent._inv_id, callbacks)
		inv:set_size("main", size)
		if ent._mcl_entity_invs_load_items then
			local lists = ent:_mcl_entity_invs_load_items()
			vl_legacy.convert_inventory_lists(lists)
			inv:set_list("main", lists)
		elseif ent._items then
			vl_legacy.convert_inventory_lists(ent._items)
			inv:set_list("main",ent._items)
		end
	end
	return inv
end

function mcl_entity_invs.save_inv(ent)
	if ent._inv then
		local items = {}
		for i,it in ipairs(ent._inv:get_list("main")) do
			items[i] = it:to_string()
		end
		if ent._mcl_entity_invs_save_items then
			ent:_mcl_entity_invs_save_items(items)
		else
			ent._items = items
		end
		ent._inv = nil
	end
end

local function load_default_formspec (ent, text)
	text = text or ""

	local invent_size = ent._inv_size
	local div_by_two = invent_size % 2 == 0
	local div_by_three =  invent_size % 3 == 0

	--mcl_log("Div by 3: ".. tostring(div_by_three))
	--mcl_log("Div by 2: ".. tostring(div_by_two))
	--mcl_log("invent_size: ".. tostring(invent_size))
	local rows = 3
	if invent_size > 18 or (div_by_three == true and invent_size > 8) then
		--mcl_log("Div by 3")
		rows = 3
	elseif (div_by_two == true and invent_size > 3) or invent_size > 9 then
		--mcl_log("Div by 2")
		rows = 2
	else
		--mcl_log("Not div by 2 or 3")
		rows = 1
	end

	--local rows = 3
	local cols = (math.ceil(ent._inv_size/rows))
	local spacing = (9 - cols) / 2

	local formspec = "size[9,8.75]"
			.. "label[0,0;" .. minetest.formspec_escape(
			minetest.colorize("#313131", ent._inv_title .. " ".. text)) .. "]"
			.. "list[detached:"..ent._inv_id..";main;"..spacing..",0.5;"..cols..","..rows..";]"
			.. mcl_formspec.get_itemslot_bg(spacing,0.5,cols,rows)
			.. "label[0,4.0;" .. minetest.formspec_escape(
			minetest.colorize("#313131", S("Inventory"))) .. "]"
			.. "list[current_player;main;0,4.5;9,3;9]"
			.. mcl_formspec.get_itemslot_bg(0,4.5,9,3)
			.. "list[current_player;main;0,7.74;9,1;]"
			.. mcl_formspec.get_itemslot_bg(0,7.74,9,1)
			.. "listring[detached:"..ent._inv_id..";main]"
			.. "listring[current_player;main]"
	return formspec
end

function mcl_entity_invs.show_inv_form(ent,player,text)
	if not ent._inv_id then return end
	if not open_invs[ent] then
		open_invs[ent] = 0
	end
	ent._inv = mcl_entity_invs.load_inv(ent,ent._inv_size)
	open_invs[ent] = open_invs[ent] + 1

	local playername = player:get_player_name()

	-- Workaround: wait at least 50ms to ensure that the detached inventory exists before
	-- the formspec attempts to use it. (See https://git.minetest.land/VoxeLibre/VoxeLibre/issues/4670#issuecomment-84875)
	minetest.after(0.05, function()
		minetest.show_formspec(playername, ent._inv_id, load_default_formspec (ent, text))
	end)
end

local function drop_inv(ent)
	if not ent._items then return end
	local pos = ent.object:get_pos()
	for i,it in pairs(ent._items) do
		local p = vector.add(pos,vector.new(math.random() - 0.5, math.random()-0.5, math.random()-0.5))
		minetest.add_item(p,it)
	end
	ent._items = nil
end

local function on_remove(self,killer,oldf)
	mcl_entity_invs.save_inv(self)
	if self._inv_id then
		minetest.remove_detached_inventory(self._inv_id)
	end
	drop_inv(self)
	if oldf then return oldf(self,killer) end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	for k,v in pairs(open_invs) do
		if formname == k._inv_id then
			open_invs[k] = open_invs[k] - 1
			if open_invs[k] < 1 then
				mcl_entity_invs.save_inv(k)
				open_invs[k] = nil
			end
		end
	end
end)

function mcl_entity_invs.register_inv(entity_name,show_name,size,no_on_righclick,no_sneak)
	assert(minetest.registered_entities[entity_name],"mcl_entity_invs.register_inv called with invalid entity: "..tostring(entity_name))
	minetest.registered_entities[entity_name]._inv_size = size
	minetest.registered_entities[entity_name]._inv_title = show_name

	local old_oa = minetest.registered_entities[entity_name].on_activate
	minetest.registered_entities[entity_name].on_activate  = function(self,staticdata,dtime_s)
		local r
		if old_oa then r=old_oa(self,staticdata,dtime_s) end
		local d = minetest.deserialize(staticdata)
		if type(d) == "table" and d._inv_id then
			self._inv_id = d._inv_id
			self._items = d._items
			self._inv_size = d._inv_size
		else
			self._inv_id="entity_inv_"..mcl_util.gen_uuid()
		end
		return r
	end
	if not no_on_righclick then
		local old_rc = minetest.registered_entities[entity_name].on_rightclick
		minetest.registered_entities[entity_name].on_rightclick = function(self,clicker)
			if no_sneak or clicker:get_player_control().sneak  then
				mcl_entity_invs.show_inv_form(self,clicker,"")
				if not no_sneak then return end
			end
			if old_rc then return old_rc(self,clicker) end
		end
	end

	local old_gsd = minetest.registered_entities[entity_name].get_staticdata
	minetest.registered_entities[entity_name].get_staticdata  = function(self)
		local old_sd = old_gsd(self)
		local d = minetest.deserialize(old_sd)
		assert(type(d) == "table","mcl_entity_invs currently only works with entities that return a (serialized) table in get_staticdata. "..tostring(self.name).." returned: "..tostring(old_sd))
		d._inv_id = self._inv_id
		d._inv_size = self._inv_size
		d._items = {}
		if self._items then
			for i,it in ipairs(self._items) do
				d._items[i] = it
			end
		end
		return minetest.serialize(d)
	end

	local old_ode = minetest.registered_entities[entity_name].on_deactivate
	minetest.registered_entities[entity_name].on_deactivate = function(self,removal)
		mcl_entity_invs.save_inv(self)
		if removal then
			on_remove(self)
		end
		if old_ode then return old_ode(self,removal) end
	end

	local old_od = minetest.registered_entities[entity_name].on_death
	minetest.registered_entities[entity_name].on_death = function(self,killer)
		if not self.is_mob then
			on_remove(self,killer,old_od)
		end
	end
	local old_odi = minetest.registered_entities[entity_name].on_die
	minetest.registered_entities[entity_name].on_die = function(self,killer)
		if self.is_mob then
			on_remove(self,killer,old_od)
		end
	end
end
