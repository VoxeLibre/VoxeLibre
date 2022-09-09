---@diagnostic disable lowercase-global

local S = minetest.get_translator("mcl_gamemode")

mcl_gamemode = {}

mcl_gamemode.gamemodes = {
	"survival",
	"creative",
}

---@param n any
---@param h table
---@return boolean
local function in_table(n, h)
	for k, v in pairs(h) do
		if v == n then return true end
	end
	return false
end

---@type fun(player: ObjectRef, old_gamemode: '"survival"'|'"creative"', new_gamemode: '"survival"'|'"creative"')[]
mcl_gamemode.registered_on_gamemode_change = {}

---@param func fun(player: ObjectRef, old_gamemode: '"survival"'|'"creative"', new_gamemode: '"survival"'|'"creative"')
function mcl_gamemode.register_on_gamemode_change(func)
	table.insert(mcl_gamemode.registered_on_gamemode_change, func)
end

---@param player ObjectRef
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

---@param player ObjectRef
---@return '"survival"'|'"creative"'
function mcl_gamemode.get_gamemode(player)
	if mt_is_creative_enabled(player:get_player_name()) then
		return "creative"
	end
	return player:get_meta():get_string("gamemode")
end

function minetest.is_creative_enabled(name)
	if mt_is_creative_enabled(name) then return true end
	if not name then return false end
	local p = minetest.get_player_by_name(name)
	if p then
		return p:get_meta():get_string("gamemode") == "creative"
	end
	return false
end

-- Insta "digging" nodes in gamemode-creative
minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
	if not puncher or not puncher:is_player() then return end
	if minetest.is_creative_enabled() then return end
	local name = puncher:get_player_name()
	if not minetest.is_creative_enabled(name) then return end
	if pointed_thing.type ~= "node" then return end
	local def = minetest.registered_nodes[node.name]
	if def then
		if def.on_destruct then def.on_destruct(pos) end
		minetest.remove_node(pos)
		return true
	end
end)

-- Don't subtract from inv when placing in gamemode-creative
minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	if placer and placer:is_player() and minetest.is_creative_enabled(placer:get_player_name()) then return true end
end)

minetest.register_chatcommand("gamemode", {
	params = S("[<gamemode>] [<player>]"),
	description = S("Change gamemode (survival/creative) for yourself or player"),
	privs = { server = true },
	func = function(n, param)
		-- Full input validation ( just for @erlehmann <3 )
		local p = minetest.get_player_by_name(n)
		local args = param:split(" ")
		if args[2] ~= nil then
			p = minetest.get_player_by_name(args[2])
		end
		if not p then
			return false, S("Player not online")
		end
		if args[1] ~= nil and not in_table(args[1], gamemodes) then
			return false, S("Gamemode " .. args[1] .. " does not exist.")
		elseif args[1] ~= nil then
			mcl_inventory.player_set_gamemode(p, args[1])
		end
		--Result message - show effective game mode
		local gm = p:get_meta():get_string("gamemode")
		if gm == "" then gm = gamemodes[1] end
		return true, S("Gamemode for player ") .. n .. S(": " .. gm)
	end
})
