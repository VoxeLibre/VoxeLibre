local modname = core.get_current_modname()

local S = core.get_translator(modname)
local N = function(t) return t end


vl_dripstone = {}

local dripstone_segments = {
	{ name = "base", desc = N("@1 Base") },
	{ name = "frustum", desc = N("@1 Frustum") },
	{ name = "middle", desc = N("@1 Middle") },
	{ name = "tip", desc = N("@1 Tip") },
	{ name = "tip_merge", desc = N("@1 Long Tip") }
}

function vl_dripstone.register_dripstone_set(def)
	assert(type(def.name) == "string", "Set must be named")
	assert(type(def.desc) == "string", "Set must have a translatable name")
	assert(type(def.tex) == "table" and #(def.tex) == 5,
		   "5 textures have to be provided (base, frustum, middle, tip, tip merge)")
	assert(type(def.groups) == "table", "Groups have to be provided")
	assert(type(def.sounds) == "table", "Sounds have to be provided")

	local name = def.name
	local caller = core.get_current_modname()

	for i, seg in pairs(dripstone_segments) do
		core.register_node(caller .. ":" .. name .. "_" .. seg.name, {
			description = S(seg.desc, def.desc),
			_doc_items_longdesc = def.longdesc or "",
			drawtype = "mesh",
			mesh = "vl_dripstone_" .. seg.name .. ".obj",
			tiles = { def.tex[i] },
			paramtype = "light",
			paramtype2 = "facedir",
			use_texture_alpha = "clip",
			stack_max = 64,
			on_place = core.rotate_node,
			groups = def.groups,
			drop = "",
			sounds = def.sounds,
			_mcl_blast_resistance = 0.5,
			_mcl_hardness = 0.5,
			_mcl_silk_touch_drop = true,
		})
	end
end

vl_dripstone.register_dripstone_set({
	name = "icicle",
	desc = S("Icicle"),
	groups = {handy=1, pickaxey=1, slippery=3, building_block=1, ice=1},
	sounds = mcl_sounds.node_sound_ice_defaults(),
	tex = {
		"vl_icicle_base.png",
		"vl_icicle_frustum.png",
		"vl_icicle_middle.png",
		"vl_icicle_tip.png",
		"vl_icicle_tip_merge.png",
	}
})


