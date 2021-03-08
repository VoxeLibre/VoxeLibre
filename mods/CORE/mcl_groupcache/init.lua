mcl_groupcache = {
	cache = {},
}

local function check_insert(item, group, cache)
	if minetest.get_item_group(item, group) ~= 0 then
		table.insert(cache, item)
	end
end

local old_register_item = minetest.register_item

function minetest.register_item(name, def)
	old_register_item(name, def)
	for group, cache in pairs(mcl_groupcache.cache) do
		check_insert(item, group, cache)
	end
end

function mcl_groupcache.init_cache(group)
	local cache = {}
	for item in pairs(minetest.registered_items) do
		check_insert(item, group, cache)
	end
	return cache
end

function mcl_groupcache.get_items_in_group(group)
	local cache = mcl_groupcache.cache[group] or mcl_groupcache.init_cache(group)
	mcl_groupcache.cache[group] = cache
	return cache
end
