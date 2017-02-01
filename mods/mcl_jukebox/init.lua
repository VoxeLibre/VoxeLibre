local active_tracks = {}
local active_huds = {}

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
			core.colorize("#55FFFF", "Music Disc") .. "\n" ..
			core.colorize("#989898", recorddata[r][2] .. "—" .. recorddata[r][1]),
		inventory_image = "mcl_jukebox_record_"..recorddata[r][3]..".png",
		stack_max = 1,
		groups = { music_record = r },
	})
end

local function now_playing(player, track_id)
	local hud = active_huds[player:get_player_name()]
	local text = "Now playing: " .. recorddata[track_id][2] .. "—" .. recorddata[track_id][1]

	local id
	if hud ~= nil then
		player:hud_change(active_huds[player:get_player_name()], "text", text)
	else
		id = player:hud_add({
			hud_elem_type = "text",
			position = { x=0.5, y=0.8 },
			offset = { x=0, y = 0 },
			size = { x=100, y=100},
			number = 0x55FFFF,
			text = text,
		})
		active_huds[player:get_player_name()] = id
	end
	minetest.after(5, function(tab)
		local player = tab[1]
		local id = tab[2]
		if not player or not player:is_player() or not active_huds[player:get_player_name()] then
			return
		end
		if id == active_huds[player:get_player_name()] then
			player:hud_remove(active_huds[player:get_player_name()])
			active_huds[player:get_player_name()] = nil
		end
	end, {player, id})
	
end

minetest.register_on_leaveplayer(function(player)
	active_tracks[player:get_player_name()] = nil
	active_huds[player:get_player_name()] = nil
end)

-- Jukebox crafting
minetest.register_craft({
	output = 'mcl_jukebox:jukebox',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'group:wood', 'mcl_core:diamond', 'group:wood'},
		{'group:wood', 'group:wood', 'group:wood'},
	}
})


-- Jukebox
minetest.register_node("mcl_jukebox:jukebox", {
	description = "Jukebox",
	tiles = {"mcl_jukebox_top.png", "mcl_jukebox_side.png", "mcl_jukebox_side.png"},
	sounds = mcl_core.node_sound_wood_defaults(),
	groups = {oddly_breakable_by_hand=1, choppy=3, deco_block=1},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("main", 1)
	end,
	on_rightclick= function(pos, node, clicker, itemstack, pointed_thing)
		if not clicker then return end
		local cname = clicker:get_player_name()
	
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if not inv:is_empty("main") then
			-- Jukebox contains a disc: Stop music and remove disc
			if active_tracks[cname] ~= nil then
				minetest.sound_stop(active_tracks[cname])
			end
			local lx = pos.x
			local ly = pos.y+1
			local lz = pos.z
			local record = inv:get_stack("main", 1)
			minetest.add_item({x=lx, y=ly, z=lz}, record:get_name())
			inv:set_stack("main", 1, "")
			if active_tracks[cname] ~= nil then
				minetest.sound_stop(active_tracks[cname])
				clicker:hud_remove(active_huds[cname])
				active_tracks[cname] = nil
				active_huds[cname] = nil
			end
		else
			-- Jukebox is empty: Play track if player holds music record
			local record_id = minetest.get_item_group(itemstack:get_name(), "music_record")
			if record_id ~= 0 then
				if active_tracks[cname] ~= nil then
					minetest.sound_stop(active_tracks[cname])
					active_tracks[cname] = nil
				end
				active_tracks[cname] = minetest.sound_play("mcl_jukebox_track_"..record_id, {
					to_player = cname,
					--max_hear_distance = 16,
					gain = 1,
				})
				now_playing(clicker, record_id)
				inv:set_stack("main", 1, itemstack:get_name())
				itemstack:take_item()
				return itemstack
			end
		end
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local name = digger:get_player_name()
		local meta = minetest.get_meta(pos)
		local meta2 = meta
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		local stack = inv:get_stack("main", 1)
		if not stack:is_empty() then
			local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
			minetest.add_item(p, stack)
			if active_tracks[name] ~= nil then
				minetest.sound_stop(active_tracks[name])
				digger:hud_remove(active_huds[name])
				active_tracks[name] = nil
				active_huds[name] = nil
			end
		end
		meta:from_table(meta2:to_table())
	end,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_jukebox:jukebox",
	burntime = 15,
})
