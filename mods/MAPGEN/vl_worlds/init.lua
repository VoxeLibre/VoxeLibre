vl_worlds = {}

local storage = core.get_mod_storage()

local registered_worlds = {}

-- API - attempts to register a world - crashes on failure to prevent damaging the save
-- required parameters in def:
-- id - string - world ID in code and mod storage
-- name - translated string - world name wherever it would be displayed
-- height - buildable height of the world, this includes bedrock and such
function vl_worlds.register_world(def)
	local modname = minetest.get_current_modname()
	local id = def.id
	assert(id ~= nil, "Unable to register world: id is nil")
	assert(type(id) == "string", "Unable to register world: id is not a string")
	assert(not registered_worlds[id], "World \""..id.."\" already registered!")
	assert(type(def.name) == "string", "Unable to register world \""..id.."\": name is not a string")

	local wdef = {}
	wdef.name = name

	registered_worlds[id] = wdef
end
