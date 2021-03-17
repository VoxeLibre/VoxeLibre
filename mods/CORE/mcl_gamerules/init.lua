mcl_gamerules = {
	__defaults = {},
	__rules = {},
}

setmetatable(mcl_gamerules, {__index = mcl_gamerules.__rules})

local worldpath = minetest.get_worldpath()

function mcl_gamerules.__load()
	local file = io.open(worldpath .. "gamerules.json", "r")
	if file then
		local contents = file:read("*all")
		file:close()
		local data = minetest.parse_json(contents)
		local rules = mcl_gamerules.__rules
		for rule, default in pairs(mcl_gamerules.__defaults) do
			local value = data[rule]
			if value == nil then
				value = default
			end
			rules[rule] = value
		end
	end
end

function mcl_gamerules.__save()
	local file = io.open(worldpath .. "gamerules.json", "w")
	file:write(minetest.write_json(mcl_gamerules.__rules, true))
	file:close()
end

function mcl_gamerules.__set(rule, value)
	if not mcl_gamerules.__defaults[rule] then
		return false
	end
	mcl_gamerules.__rules[rule] = value
	mcl_gamerules.__save()
	return true
end

function mcl_gamerules.__register(rule, default)
	mcl_gamerules.__defaults[rule] = default
end

mcl_gamerules.__register("announceAdvancements", true)
mcl_gamerules.__register("commandBlockOutput", true)
mcl_gamerules.__register("doDaylightCycle", true)
mcl_gamerules.__register("doFireTick", true)
mcl_gamerules.__register("doImmediateRespawn", false)
mcl_gamerules.__register("doMobLoot", true)
mcl_gamerules.__register("doMobSpawning", true)
mcl_gamerules.__register("doTileDrops", true)
mcl_gamerules.__register("doWeatherCycle", true)
mcl_gamerules.__register("drowningDamage", true)
mcl_gamerules.__register("fallDamage", true)
mcl_gamerules.__register("fireDamage", true)
mcl_gamerules.__register("keepInventory", false)
mcl_gamerules.__register("logAdminCommands", true)
mcl_gamerules.__register("mobGriefing", true)
mcl_gamerules.__register("naturalRegeneration", true)
mcl_gamerules.__register("pvp", true)
mcl_gamerules.__register("showDeathMessages", true)
mcl_gamerules.__register("tntExplodes", true)

minetest.register_on_mods_loaded(mcl_gamerules.__load)
