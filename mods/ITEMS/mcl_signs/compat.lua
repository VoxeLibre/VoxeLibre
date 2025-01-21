mcl_signs.old_rotnames = {}

-- these are the "rotation strings" of the old sign rotation scheme
local rotkeys = {
	"22_5",
	"45",
	"67_5"
}

-- this is a translation table for the old sign rotation scheme to degrotate
-- the first level is the itemstring part and the second level represents
-- the facedir param2 (+1) mapped to the degrotate param2
local nidp2_degrotate = {
	["22_5"] = {
		225,
		165,
		105,
		45,
	},
	["45"] = {
		210,
		150,
		90,
		30,
	},
	["67_5"] = {
		195,
		135,
		75,
		15,
	}
}

local signs = {
	[""] = "_oak",
	["_acaciawood"] = "_acacia",
	["_junglewood"] = "_jungle",
	["_birchwood"] = "_birch",
	["_darkwood"] = "_dark_oak",
	["_sprucewood"] = "_spruce",
	["_mangrove_wood"] = "_mangrove",
	["_crimson_hyphae_wood"] = "_crimson",
	["_warped_hyphae_wood"] = "_warped",
	["_cherrywood"] = "_cherry",
}

local mcl2standingsigns = {}
local mcl2rotsigns = {}
for old, new in pairs(signs) do
	local newname = "mcl_signs:standing_sign"..new

	mcl2standingsigns["mcl_signs:standing_sign"..old] = newname
	for _, rotkey in ipairs(rotkeys) do
		mcl2rotsigns["mcl_signs:standing_sign"..rotkey..old] = newname
	end
	core.register_alias("mcl_signs:wall_sign"..old, newname)
end

function mcl_signs.upgrade_sign_meta(pos)
	local m = core.get_meta(pos)
	local color = m:get_string("mcl_signs:text_color")
	local glow = m:get_string("mcl_signs:glowing_sign")
	if color ~= "" then
		m:set_string("color", color)
		m:set_string("mcl_signs:text_color", "")
	end
	if glow == "true" then
		m:set_string("glow", glow)
	end
	if glow ~= "" then
		m:set_string("mcl_signs:glowing_sign", "")
	end
	mcl_signs.get_text_entity(pos, true) -- the 2nd "true" arg means deleting the entity for respawn
end

function mcl_signs.upgrade_sign_rot(pos,node)
	local numsign = false

	for _,v in pairs(rotkeys) do
		if mcl2rotsigns[node.name] then
			node.name = mcl2rotsigns[node.name]
			node.param2 = nidp2_degrotate[v][node.param2 + 1]
			numsign = true
		elseif node.name:find(v) then
			node.name = node.name:gsub(v,"")
			node.param2 = nidp2_degrotate[v][node.param2 + 1]
			numsign = true
		end
	end

	if not numsign then
		if mcl2standingsigns[node.name] then
			node.name = mcl2standingsigns[node.name]
		end
		local def = core.registered_nodes[node.name]
		if def and def._mcl_sign_type == "standing" then
			if node.param2 == 1 or node.param2 == 121 then
				node.param2 = 180
			elseif node.param2 == 2 or node.param2 == 122 then
				node.param2 = 120
			elseif node.param2 == 3 or node.param2 == 123 then
				node.param2 = 60
			end
		end
	end
	core.swap_node(pos,node)
	mcl_signs.upgrade_sign_meta(pos)
	mcl_signs.update_sign(pos)
end

core.register_lbm({
	nodenames = {"group:sign"},
	name = "mcl_signs:update_old_signs",
	label = "Update old signs",
	run_at_every_load = false,
	action = mcl_signs.upgrade_sign_rot,
})

for k,_ in pairs(mcl2rotsigns) do table.insert(mcl_signs.old_rotnames, k) end
for k,_ in pairs(mcl2standingsigns) do table.insert(mcl_signs.old_rotnames, k) end

core.register_lbm({
	nodenames = mcl_signs.old_rotnames,
	name = "mcl_signs:update_old_rotated_standing",
	label = "Update old standing rotated signs",
	run_at_every_load = true, --these nodes are supposed to completely be replaced
	action = mcl_signs.upgrade_sign_rot
})
