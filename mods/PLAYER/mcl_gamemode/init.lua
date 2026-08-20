local S = minetest.get_translator("mcl_gamemode")

mcl_gamemode = {}

mcl_gamemode.gamemodes = {
	"survival",
	"creative",
}

mcl_gamemode.default_gamemode = core.settings:get_bool("creative_mode") and "creative" or "survival"

---@type fun(player: mt.PlayerObjectRef, old_gamemode: '"survival"'|'"creative"', new_gamemode: '"survival"'|'"creative"')[]
mcl_gamemode.registered_on_gamemode_change = {}

---@param func fun(player: mt.PlayerObjectRef, old_gamemode: '"survival"'|'"creative"', new_gamemode: '"survival"'|'"creative"')
function mcl_gamemode.register_on_gamemode_change(func)
	table.insert(mcl_gamemode.registered_on_gamemode_change, func)
end

---@param player mt.PlayerObjectRef
---@param gamemode '"survival"'|'"creative"'
function mcl_gamemode.set_gamemode(player, gamemode)
	local meta = player:get_meta()
	local old_gamemode = meta:get_string("gamemode")
	meta:set_string("gamemode", gamemode)
	for _, f in ipairs(mcl_gamemode.registered_on_gamemode_change) do
		f(player, old_gamemode, gamemode)
	end
end

---@param player mt.PlayerObjectRef
---@return string
function mcl_gamemode.get_gamemode(player)
	local gamemode = player:get_meta():get_string("gamemode")
	if gamemode == "" then return mcl_gamemode.default_gamemode end
	return gamemode
end

function minetest.is_creative_enabled(name)
	if not name or name == "" then return false end
	local player = core.get_player_by_name(name)
	if player then
		return mcl_gamemode.get_gamemode(player) == "creative"
	end
	return false
end

minetest.register_chatcommand("gamemode", {
	params = S("[<gamemode>] [<player>]"),
	description = S("Change gamemode (survival/creative) for yourself or player"),
	privs = { server = true },
	func = function(n, param)
		-- Full input validation ( just for @erle <3 )
		local p = minetest.get_player_by_name(n)
		local args = param:split(" ")
		if args[2] ~= nil then
			p = minetest.get_player_by_name(args[2])
		end
		if not p then
			return false, S("Player not online")
		end
		if args[1] ~= nil then
			local gmode = mcl_util.search_in_table(args[1], mcl_gamemode.gamemodes)
			if not gmode then
				return false, S("Gamemode @1 does not exist.", args[1])
			elseif type(gmode) == "table" then
				return false, S("More than one gamemode fit @1", args[1])
					.. ": " .. table.concat(gmode, ", ")
			else
				mcl_gamemode.set_gamemode(p, gmode)
			end
		end
		--Result message - show effective game mode
		local gm = p:get_meta():get_string("gamemode")
		if gm == "" then gm = mcl_gamemode.gamemodes[1] end
		return true, S("Gamemode for player ") .. p:get_player_name() .. S(": " .. gm)
	end
})
