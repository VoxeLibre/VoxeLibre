local S = minetest.get_translator("mesecons_noteblock")

minetest.register_node("mesecons_noteblock:noteblock", {
	description = S("Note Block"),
	_doc_items_longdesc = S("A note block is a musical block which plays one of many musical notes and different intruments when it is punched or supplied with redstone power."),
	_doc_items_usagehelp = S("Use the note block to choose the next musical note (there are 25 semitones, or 2 octaves). The intrument played depends on the material of the block below the note block:").."\n\n"..

S("• Glass: Sticks").."\n"..
S("• Wood: Bass guitar").."\n"..
S("• Stone: Bass drum").."\n"..
S("• Sand or gravel: Snare drum").."\n"..
S("• Anything else: Piano").."\n\n"..

S("The note block will only play a note when it is below air, otherwise, it stays silent."),
	tiles = {"mesecons_noteblock.png"},
	groups = {handy=1,axey=1, material_wood=1},
	is_ground_content = false,
	place_param2 = 0,
	on_rightclick = function (pos, node, clicker) -- change sound when rightclicked
		local protname = clicker:get_player_name()
		if minetest.is_protected(pos, protname) then
			minetest.record_protection_violation(pos, protname)
			return
		end
		node.param2 = (node.param2+1)%25
		mesecon.noteblock_play(pos, node.param2)
		minetest.set_node(pos, node)
	end,
	on_punch = function (pos, node) -- play current sound when punched
		mesecon.noteblock_play(pos, node.param2)
	end,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	mesecons = {effector = { -- play sound when activated
		action_on = function (pos, node)
			mesecon.noteblock_play(pos, node.param2)
		end,
		rules = mesecon.rules.alldirs,
	}},
	_mcl_blast_resistance = 4,
	_mcl_hardness = 0.8,
})

minetest.register_craft({
	output = '"mesecons_noteblock:noteblock" 1',
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"group:wood", "mesecons:redstone", "group:wood"},
		{"group:wood", "group:wood", "group:wood"},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mesecons_noteblock:noteblock",
	burntime = 15
})

local soundnames_piano = {
	[0] = "mesecons_noteblock_c",
	"mesecons_noteblock_csharp",
	"mesecons_noteblock_d",
	"mesecons_noteblock_dsharp",
	"mesecons_noteblock_e",
	"mesecons_noteblock_f",
	"mesecons_noteblock_fsharp",
	"mesecons_noteblock_g",
	"mesecons_noteblock_gsharp",
	"mesecons_noteblock_a",
	"mesecons_noteblock_asharp",
	"mesecons_noteblock_b",

	"mesecons_noteblock_c2",
	"mesecons_noteblock_csharp2",
	"mesecons_noteblock_d2",
	"mesecons_noteblock_dsharp2",
	"mesecons_noteblock_e2",
	"mesecons_noteblock_f2",
	"mesecons_noteblock_fsharp2",
	"mesecons_noteblock_g2",
	"mesecons_noteblock_gsharp2",
	"mesecons_noteblock_a2",
	"mesecons_noteblock_asharp2",
	"mesecons_noteblock_b2",

	-- TODO: Add dedicated sound file?
	"mesecons_noteblock_b2",
}

mesecon.noteblock_play = function (pos, param2)
	local block_above_name = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z}).name
	if block_above_name ~= "air" then
		-- Don't play sound if no air is above
		return
	end

	local block_below_name = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name
	local param2_to_pitch = function(param2)
		return 2^((param2-12)/12)
	end
	local soundname, pitch
	if minetest.get_item_group(block_below_name, "material_glass") ~= 0 then
		soundname="mesecons_noteblock_stick"
		pitch = param2_to_pitch(param2)
	elseif minetest.get_item_group(block_below_name, "material_wood") ~= 0 then
		soundname="mesecons_noteblock_bass_guitar"
		pitch = param2_to_pitch(param2)
	elseif minetest.get_item_group(block_below_name, "material_sand") ~= 0 then
		soundname="mesecons_noteblock_snare"
		pitch = param2_to_pitch(param2)
	elseif minetest.get_item_group(block_below_name, "material_stone") ~= 0 then
		soundname="mesecons_noteblock_kick"
		pitch = param2_to_pitch(param2)
	else
		-- Default: One of 25 piano notes
		soundname = soundnames_piano[param2]
		-- Workaround: Final sound gets automatic higher pitch instead
		if param2 == 24 then
			pitch = 2^(1/12)
		end
	end

	minetest.sound_play(soundname,
	{pos = pos, gain = 1.0, max_hear_distance = 48, pitch = pitch})
end
