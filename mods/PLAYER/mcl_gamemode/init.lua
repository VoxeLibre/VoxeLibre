local S = minetest.get_translator("mcl_gamemode")

mcl_gamemode = {}

mcl_gamemode.gamemodes = {
	"survival",
	"creative",
}

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

local mt_is_creative_enabled = minetest.is_creative_enabled

---@param player mt.PlayerObjectRef
---@return '"survival"'|'"creative"'
function mcl_gamemode.get_gamemode(player)
	if mt_is_creative_enabled(player:get_player_name()) then
		return "creative"
	end

	local gm = player:get_meta():get("gamemode")
	if gm then
		---@diagnostic disable-next-line: return-type-mismatch
		return gm
	else
		player:get_meta():set_string("gamemode", "survival")
		return "survival"
	end
end

function minetest.is_creative_enabled(name)
	if mt_is_creative_enabled(name) then return true end
	if not name or name == "" then return false end
	local p = minetest.get_player_by_name(name)
	if p then
		return p:get_meta():get_string("gamemode") == "creative"
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
