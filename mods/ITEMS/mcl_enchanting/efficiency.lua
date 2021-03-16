local efficiency_cache_table = {}

-- Compute a hash value.
function compute_hash(value)
	-- minetest.get_password_hash is quite fast, even if it uses a
	-- cryptographic hashing function (SHA-1).  It is written in C++ and it
	-- is probably hard to write a faster hashing function in Lua.
	return string.sub(minetest.get_password_hash("ryvnf", minetest.serialize(value)), 1, 8)
end

-- Get the efficiency groupcaps and hash for a tool and efficiency level.  If
-- this function is called repeatedly with the same values it will return data
-- from a cache.
--
-- Returns a table with the following two fields:
-- values - the groupcaps table
-- hash - the hash of the groupcaps table
local function get_efficiency_groupcaps(toolname, level)
	local toolcache = efficiency_cache_table[toolname]
	if not toolcache then
		toolcache = {}
		efficiency_cache_table[toolname] = toolcache
	end

	local levelcache = toolcache[level]
	if not levelcache then
		levelcache = {}
		levelcache.values = mcl_autogroup.get_groupcaps(toolname, level)
		levelcache.hash = compute_hash(levelcache.values)
		toolcache[level] = levelcache
	end

	return levelcache
end

-- Apply efficiency enchantment to a tool.  This will update the tools
-- tool_capabilities to give it new digging times.  This function will be called
-- repeatedly to make sure the digging times stored in groupcaps stays in sync
-- when the digging times of nodes can change.
--
-- To make it more efficient it will first check a hash value to determine if
-- the tool needs to be updated.
function mcl_enchanting.apply_efficiency(itemstack, level)
	local name = itemstack:get_name()
	local groupcaps = get_efficiency_groupcaps(name, level)
	local hash = itemstack:get_meta():get_string("groupcaps_hash")

	if not hash or hash ~= groupcaps.hash then
		local tool_capabilities = itemstack:get_tool_capabilities()
		tool_capabilities.groupcaps = groupcaps.values
		itemstack:get_meta():set_tool_capabilities(tool_capabilities)
		itemstack:get_meta():set_string("groupcaps_hash", groupcaps.hash)
	end
end
