local modpath = core.get_modpath(core.get_current_modname())
local S = core.get_translator(core.get_current_modname())

local LADDER_SUFFIX = "^vl_hollow_logs_ladder.png"

vl_hollow_logs = {}
--- Function to register a hollow log. See API.md to learn how to use this function.
---@param defs table {name:string, stripped_name>string, desc:string, stripped_desc:string, not_flammable:boolean|nil}
function vl_hollow_logs.register_hollow_log(defs)
	assert(defs and #defs >= 4, "Incomplete definition provided")
	for i = 1, 4 do
		assert(type(defs[i]) == "string", "defs["..i.."] must be a string")
	end
	assert(not defs[5] or type(defs[5]) == "boolean", "defs[5] must be a boolean if present")

	local modname = core.get_current_modname()

	if #defs > 5 then
		core.log("warning", "[vl_hollow_logs] unused vars passed, dumping the table")
		core.log("warning", "from mod " .. modname .. ": " .. dump(defs))
	end

	local name = defs[1]
	local stripped_name = defs[2]
	local desc = defs[3]
	local stripped_desc = defs[4]

	local collisionbox = {
		type = "fixed",
		-- Note: visually, we have 3/16 pixels, but for collision we only use 1/16
		-- to allow smoke to better pass through. Can be reduced when Luanti has
		-- resolved https://github.com/luanti-org/luanti/issues/15820
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, -0.4375},
			{-0.5, -0.5, -0.5, -0.4375, 0.5, 0.5},
			{0.4375, -0.5, -0.5, 0.5, 0.5, 0.5},
			{-0.5, -0.5, 0.4375, 0.5, 0.5, 0.5},
		}
	}

	local groups = {axey = 1, building_block = 1, handy = 1, hollow_log = 1}

	if not defs[5] then
		table.update(groups, {fire_encouragement = 5, fire_flammability = 5, flammable = 2, hollow_log_burnable = 1})
	end

	local hollow_log_def = {
		collision_box = collisionbox,
		description = desc,
		drawtype = "mesh",
		groups = groups,
		mesh = "vl_hollow_logs_log.obj",
		on_place = mcl_util.rotate_axis,
		paramtype = "light",
		paramtype2 = "facedir",
		use_texture_alpha = "clip",
		sounds = mcl_sounds.node_sound_wood_defaults(),
		sunlight_propagates = true,
		tiles = {modname .. "_"..name..".png"},
		_mcl_blast_resistance = 2,
		_mcl_hardness = 2,
		_mcl_stripped_variant = modname .. ":" .. stripped_name .. "_hollow"
	}
	core.register_node(modname .. ":" .. name .. "_hollow", hollow_log_def)

	local stripped_hollow_log_def = table.copy(hollow_log_def)
	stripped_hollow_log_def.description = stripped_desc
	stripped_hollow_log_def.tiles = {modname .. "_stripped_"..name..".png"}
	stripped_hollow_log_def._mcl_stripped_variant = nil

	core.register_node(modname .. ":" .. stripped_name .. "_hollow", stripped_hollow_log_def)

	-- ladder variant
	local ladder_hl_def = table.copy(hollow_log_def)
	ladder_hl_def.description = S("@1 with a Ladder", desc)
	ladder_hl_def.tiles[1] = ladder_hl_def.tiles[1] .. LADDER_SUFFIX
	ladder_hl_def._mcl_stripped_variant = ladder_hl_def._mcl_stripped_variant .. "_ladder"
	ladder_hl_def.climbable = true

	core.register_node(modname .. ":" .. name .. "_hollow_ladder", ladder_hl_def)

	local ladder_stripped_hl_def = table.copy(stripped_hollow_log_def)
	ladder_stripped_hl_def.description = S("@1 with a Ladder", desc)
	ladder_stripped_hl_def.tiles[1] = ladder_stripped_hl_def.tiles[1] .. LADDER_SUFFIX
	ladder_stripped_hl_def.climbable = true

	core.register_node(modname .. ":" .. stripped_name .. "_hollow_ladder", ladder_stripped_hl_def)
end

vl_hollow_logs.logs = {
	{"tree", "stripped_oak", S("Hollow Oak Log"), S("Stripped Hollow Oak Log")},
	{"acaciatree", "stripped_acacia", S("Hollow Acacia Log"), S("Stripped Hollow Acacia Log")},
	{"birchtree", "stripped_birch", S("Hollow Birch Log"), S("Stripped Hollow Birch Log")},
	{"darktree", "stripped_dark_oak", S("Hollow Dark Oak Log"), S("Stripped Hollow Dark Oak Log")},
	{"jungletree", "stripped_jungle", S("Hollow Jungle Log"), S("Stripped Hollow Jungle Log")},
	{"sprucetree", "stripped_spruce", S("Hollow Spruce Log"), S("Stripped Hollow Spruce Log")},
}


if core.get_modpath("mcl_cherry_blossom") then
	table.insert(vl_hollow_logs.logs, {"cherrytree", "stripped_cherrytree", S("Hollow Cherry Log"), S("Stripped Hollow Cherry Log")})
end

if core.get_modpath("mcl_mangrove") then
	table.insert(vl_hollow_logs.logs, {"mangrove_tree", "mangrove_stripped", S("Hollow Mangrove Log"), S("Stripped Hollow Mangrove Log")})
end

if core.get_modpath("mcl_crimson") then
	table.insert(vl_hollow_logs.logs, {"crimson_hyphae", "stripped_crimson_hyphae", S("Hollow Crimson Stem"), S("Stripped Hollow Crimson Stem"), true})
	table.insert(vl_hollow_logs.logs, {"warped_hyphae", "stripped_warped_hyphae", S("Hollow Warped Stem"), S("Stripped Hollow Warped Stem"), true})
end

for _, defs in pairs(vl_hollow_logs.logs) do
	vl_hollow_logs.register_hollow_log(defs)
end

dofile(modpath.."/recipes.lua")
