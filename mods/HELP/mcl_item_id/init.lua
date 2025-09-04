mcl_item_id = {
    mod_namespaces = {},
}

local game = "voxelibre"

function mcl_item_id.set_mod_namespace(modname, namespace)
    namespace = namespace or modname
    mcl_item_id.mod_namespaces[modname] = namespace
end

function mcl_item_id.get_mod_namespace(modname)
    local namespace = mcl_item_id.mod_namespaces[modname]
    if namespace then
        return namespace
    else
        return game
    end
end

local same_id = {
    enchanting = { "table" },
    experience = { "bottle" },
    heads = { "skeleton", "zombie", "stalker", "wither_skeleton" },
    mobitems = { "rabbit", "chicken" },
    walls = {
        "andesite", "brick", "cobble", "diorite", "endbricks",
        "granite", "mossycobble", "netherbrick", "prismarine",
        "rednetherbrick", "redsandstone", "sandstone",
        "stonebrick", "stonebrickmossy",
    },
    wool = {
        "black", "blue", "brown", "cyan", "green",
        "grey", "light_blue", "lime", "magenta", "orange",
        "pink", "purple", "red", "silver", "white", "yellow",
    },
}

---@class core.ItemDef
---@field _mcl_item_id string?

tt.register_snippet(function(itemstring)
	if not core.settings:get_bool("mcl_item_id_debug", false) then return end
	local def = core.registered_items[itemstring]
	if not def then return end
	new_id = def._mcl_item_id
	return new_id, "#555555"
end)

core.register_on_mods_loaded(function()
	for itemstring,_ in pairs(core.registered_items) do
		local item_split = itemstring:find(":")
		if item_split then
			local id_string = itemstring:sub(item_split)
			local id_modname = itemstring:sub(1, item_split - 1)
			local new_id = game .. id_string
			local alt_id = "mineclone" .. id_string
			local mod_namespace = mcl_item_id.get_mod_namespace(id_modname)
			for mod, ids in pairs(same_id) do
				for _, id in pairs(ids) do
					if itemstring == "mcl_" .. mod .. ":" .. id  then
						new_id = game .. ":" .. id .. "_" .. mod:gsub("s", "")
						alt_id = "mineclone:" .. id .. "_" .. mod:gsub("s", "")
					end
				end
			end
			if mod_namespace ~= game then
				new_id = mod_namespace .. id_string
			end
			if mod_namespace ~= id_modname then
				core.register_alias_force(new_id, itemstring)
				core.register_alias_force(alt_id, itemstring)
			end

			core.override_item(itemstring, {_mcl_item_id = new_id})
		end
	end
end)
