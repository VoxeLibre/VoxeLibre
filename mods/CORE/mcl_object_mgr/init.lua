mcl_object_mgr = {
	players = {}
}

-- functions

function mcl_object_mgr.get(obj)
	local rval

	if mcl_object_mgr.is_mcl_object(obj) then
		rval = obj
	elseif mcl_object_mgr.is_player(obj) then
		rval = mcl_object_mgr.get_player(obj)
	elseif mcl_object_mgr.is_entity(obj) then
		rval = mcl_object_mgr.get_entity(obj)
	end

	return assert(rval, "No matching MCLObject found. This is most likely an error caused by custom mods.")
end

function mcl_object_mgr.is_mcl_object(obj)
	return type(obj) == "table" and obj.IS_MCL_OBJECT
end

function mcl_object_mgr.is_player(obj)
	return type(obj) == "string" or type(obj) == "userdata" and obj:is_player()
end

function mcl_object_mgr.is_is_entity(obj)
	return type(obj) == "table" and obj.object or type(obj) == "userdata" and obj:get_luaentity()
end

function mcl_object_mgr.get_entity(ent)
	if type(ent) == "userdata" then
		ent = ent:get_luaentity()
	end
	return ent.mcl_entity
end

function mcl_object_mgr.get_player(name)
	if type(name) == "userdata" then
		name = name:get_player_name()
	end
	return mcl_player_mgr.players[name]
end

-- entity wrappers

local function add_entity_wrapper(def, name)
	def[name] = function(luaentity, ...)
		local func = self.mcl_entity[name]
		if func then
			return func(self.mcl_entity, ...)
		end
	end
end

function mcl_object_mgr.register_entity(name, initial_properties, base_class)
	 local def = {
		initial_properties = initial_properties,

		on_activate = function(self, ...)
			local entity = base_class(self.object)
			self.mcl_entity = entity
			if entity.on_activate then
				entity:on_activate(...)
			end
		end,
	}

	add_entity_wrapper(def, "on_deactivate")
	add_entity_wrapper(def, "on_step")
	add_entity_wrapper(def, "on_death")
	add_entity_wrapper(def, "on_rightclick")
	add_entity_wrapper(def, "on_attach_child")
	add_entity_wrapper(def, "on_detach_child")
	add_entity_wrapper(def, "on_detach")
	add_entity_wrapper(def, "get_staticdata")

	minetest.register_entity(name, def)
end

-- player wrappers

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	mcl_player_mgr.players[name] = MCLPlayer(player)
	mcl_player_mgr.players[name]:on_join()
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	mcl_player_mgr.players[name]:on_leave()
	mcl_player_mgr.players[name] = nil
end)

local function add_player_wrapper(wrapper, regfunc)
	minetest[regfunc or "register_" .. wrapper .. "player"](function(player, ...)
		local mclplayer = mcl_player_mgr.players[player:get_player_name()]
		local func = mclplayer[funcname or wrapper]
		if func then
			func(mclplayer, ...)
		end
	end)
end

add_player_wrapper("on_punch")
add_player_wrapper("on_rightclick")
add_player_wrapper("on_death", "register_on_dieplayer")
add_player_wrapper("on_respawn")

minetest.register_on_player_hpchange(function(player, hp_change, reason))
