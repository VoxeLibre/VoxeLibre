local providers = {}
local provider_order = {}

local function check_string(value, what)
	assert(type(value) == "string" and value ~= "", what .. " must be a non-empty string")
end

---@param def {id: string, name: string, icon: string, order?: number}
function vl_announcements.register_provider(def)
	assert(type(def) == "table", "provider definition must be a table")
	check_string(def.id, "provider ID")
	assert(def.id:match("^[a-z0-9_]+$"), "provider ID may only contain lowercase letters, digits, and underscores")
	check_string(def.name, "provider name")
	check_string(def.icon, "provider icon")
	assert(not providers[def.id], "announcement provider already registered: " .. def.id)

	providers[def.id] = {
		id = def.id,
		name = def.name,
		icon = def.icon,
		order = tonumber(def.order) or 100,
		announcements = {},
	}
	provider_order[#provider_order + 1] = providers[def.id]
end

---@param provider_id string
---@param def {id: string, version: string, title: string, poster?: string, intro: string, features?: table[], details?: table[]}
function vl_announcements.register_announcement(provider_id, def)
	local provider = providers[provider_id]
	assert(provider, "unknown announcement provider: " .. tostring(provider_id))
	assert(type(def) == "table", "announcement definition must be a table")
	check_string(def.id, "announcement ID")
	check_string(def.version, "announcement version")
	check_string(def.title, "announcement title")
	assert(type(def.intro) == "string", "announcement intro must be a string")

	for _, announcement in ipairs(provider.announcements) do
		assert(announcement.id ~= def.id,
			"duplicate announcement ID " .. def.id .. " for provider " .. provider_id)
	end

	def.features = def.features or {}
	def.details = def.details or {}
	assert(type(def.features) == "table", "announcement features must be a table")
	assert(type(def.details) == "table", "announcement details must be a table")
	table.insert(provider.announcements, def)
end

function vl_announcements.get_provider(id)
	return providers[id]
end

function vl_announcements.get_providers()
	local result = {}
	for _, provider in ipairs(provider_order) do
		if #provider.announcements > 0 then result[#result + 1] = provider end
	end
	table.sort(result, function(a, b)
		if a.order == b.order then return a.name < b.name end
		return a.order < b.order
	end)
	return result
end
