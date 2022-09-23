mcl_entity_invs = {}

local function check_distance(inv,player,count)
	for _,o in pairs(minetest.get_objects_inside_radius(player:get_pos(),5)) do
		local l = o:get_luaentity()
		if l and l._inv_id and inv:get_location().name == l._inv_id then return count end
	end
	return 0
end

local inv_callbacks = {
	allow_take = function(inv, listname, index, stack, player)
		return check_distance(inv,player,stack:get_count())
	end,
	allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
		return check_distance(inv,player,count)
	end,
	allow_put = function(inv, listname, index, stack, player)
		return check_distance(inv,player,stack:get_count())
	end,
}

local function load_inv(ent,size)
	if not ent._inv_id then return end
	local inv = minetest.get_inventory({type="detached", name=ent._inv_id})
	if not inv then
		inv =  minetest.create_detached_inventory(ent._inv_id, inv_callbacks)
		inv:set_size("main", size)
		if ent._items then
			inv:set_list("main",ent._items)
		end
	end
	return inv
end

local function show_form(ent,player,show_name)
	if not ent._inv_id then return end
	local playername = player:get_player_name()
	local formspec = "size[9,8.75]"
	.. "label[0,0;" .. minetest.formspec_escape(
			minetest.colorize("#313131", show_name)) .. "]"
	.. "list[detached:"..ent._inv_id..";main;0,0.5;9,3;]"
	.. mcl_formspec.get_itemslot_bg(0,0.5,9,3)
	.. "label[0,4.0;" .. minetest.formspec_escape(
			minetest.colorize("#313131", "Inventory")) .. "]"
	.. "list[current_player;main;0,4.5;9,3;9]"
	.. mcl_formspec.get_itemslot_bg(0,4.5,9,3)
	.. "list[current_player;main;0,7.74;9,1;]"
	.. mcl_formspec.get_itemslot_bg(0,7.74,9,1)
	.. "listring[detached:"..ent._inv_id..";main]"
	.. "listring[current_player;main]"
	minetest.show_formspec(playername,ent._inv_id,formspec)
end

local function drop_inv(ent)
	local pos = ent.object:get_pos()
	for i,it in pairs(ent._inv:get_list("main")) do
		local p = vector.add(pos,vector.new(math.random() - 0.5, math.random()-0.5, math.random()-0.5))
		minetest.add_item(p,it:to_string())
	end
end

function mcl_entity_invs.register_inv(entity_name,show_name,size)
	local old_oa = minetest.registered_entities[entity_name].on_activate
	minetest.registered_entities[entity_name].on_activate  = function(self,staticdata,dtime_s)
		local d = minetest.deserialize(staticdata)
		if type(d) == "table" and d._inv_id then
			self._inv_id = d._inv_id
			self._items = d._items
		else
			self._inv_id="entity_inv_"..minetest.sha1(minetest.get_gametime()..minetest.pos_to_string(self.object:get_pos())..tostring(math.random()))
			--gametime and position for collision safety and math.random salt to protect against position brute-force
		end
		if self._inv_id then
			self._inv = load_inv(self,size)
		end
		if old_oa then return old_oa(self,clicker) end
	end

	local old_rc = minetest.registered_entities[entity_name].on_rightclick
	minetest.registered_entities[entity_name].on_rightclick = function(self,clicker)
		show_form(self,clicker,show_name)
		if old_rc then return old_rc(self,clicker) end
	end
	local old_gsd = minetest.registered_entities[entity_name].get_staticdata
	minetest.registered_entities[entity_name].get_staticdata  = function(self)
		local old_sd = old_gsd(self)
		local d = minetest.deserialize(old_sd)
		assert(type(d) == "table","Entyinvs currently only works with entities that return a (serialized) table in get_staticdata. "..tostring(self.name).." returned: "..tostring(old_sd))
		d._inv_id = self._inv_id
		d._items = {}
		for i,it in pairs(self._inv:get_list("main")) do
			d._items[i] = it:to_string()
		end
		return minetest.serialize(d)
	end

	local old_ode = minetest.registered_entities[entity_name].on_deactivate
	minetest.registered_entities[entity_name].on_deactivate = function(self,removal)
		minetest.remove_detached_inventory(self._inv_id)
		if old_ode then return old_ode(self,removal) end
	end

	local old_od = minetest.registered_entities[entity_name].on_death
	minetest.registered_entities[entity_name].on_death = function(self,clicker)
		drop_inv(self)
		minetest.remove_detached_inventory(self._inv_id)
		if old_od then return old_od(self,clicker) end
	end
end
