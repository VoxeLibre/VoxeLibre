local active_tracks = {}

local recorddata = {
	{ "The Evil Sister (Jordach's Mix)", "SoundHelix", "13" } ,
	{ "The Energetic Rat (Jordach's Mix)", "SoundHelix", "wait" },
	{ "Eastern Feeling", "Jordach", "blocks"},
	{ "Minetest", "Jordach", "far" },
	{ "Credit Roll (Jordach's HD Mix)", "Junichi Masuda", "chirp" },
	{ "Moonsong (Jordach's Mix)", "HeroOfTheWinds", "strad" },
	{ "Synthgroove (Jordach's Mix)", "HeroOfTheWinds", "mellohi" },
	{ "The Clueless Frog (Jordach's Mix)", "SoundHelix", "mall" },
}
local records = #recorddata

for r=1, records do
	minetest.register_craftitem("mcl_jukebox:record_"..r, {
		description =
			"Music Disc" .. "\n" ..
			recorddata[r][1] .. "\n" ..
			recorddata[r][2],
		inventory_image = "mcl_jukebox_record_"..recorddata[r][3]..".png",
		stack_max = 1,
		groups = { music_record = r },
	})
end


-- Jukebox crafting
minetest.register_craft({
	output = 'mcl_jukebox:jukebox',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'group:wood', 'default:diamond', 'group:wood'},
		{'group:wood', 'group:wood', 'group:wood'},
	}
})

-- Jukebox
minetest.register_node("mcl_jukebox:jukebox", {
	description = "Jukebox",
	tiles = {"mcl_jukebox_top.png", "mcl_jukebox_side.png", "mcl_jukebox_side.png"},
	sounds = default.node_sound_wood_defaults(),
	groups = {oddly_breakable_by_hand=1, flammable=1, choppy=3},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("main", 1)
	end,
	on_punch = function(pos, node, puncher, pointed_thing)
		if not puncher then return end
	
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if not inv:is_empty("main") then
			-- Jukebox contains a disc: Stop music and remove disc
			if active_tracks[puncher:get_player_name()] ~= nil then
				minetest.sound_stop(active_tracks[puncher:get_player_name()])
			end
			local lx = pos.x
			local ly = pos.y+1
			local lz = pos.z
			local record = inv:get_stack("main", 1)
			minetest.add_item({x=lx, y=ly, z=lz}, record:get_name())
			inv:set_stack("main", 1, "")
			if active_tracks[puncher:get_player_name()] ~= nil then
				minetest.sound_stop(active_tracks[puncher:get_player_name()])
			end
		else
			-- Jukebox is empty: Play track if player holds music record
			local wield = puncher:get_wielded_item():get_name()
			local record_id = minetest.get_item_group(wield, "music_record")
			if record_id ~= 0 then
				if active_tracks[puncher:get_player_name()] ~= nil then
					minetest.sound_stop(active_tracks[puncher:get_player_name()])
				end
				puncher:set_wielded_item("")
				active_tracks[puncher:get_player_name()] = minetest.sound_play("mcl_jukebox_track_"..record_id, {
					to_player = puncher:get_player_name(),
					--max_hear_distance = 16,
					gain = 1,
				})
				inv:set_stack("main", 1, wield)
			end
		end
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest.get_meta(pos)
		local meta2 = meta
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		local stack = inv:get_stack("main", 1)
		if not stack:is_empty() then
			local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
			minetest.add_item(p, stack)
		end
		meta:from_table(meta2:to_table())
	end,
})

