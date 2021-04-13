mcl_credits = {
	players = {},
}

mcl_credits.description = "A faithful Open Source clone of Minecraft"

-- Sub-lists are sorted by number of commits, but the list should not be rearranged (-> new contributors are just added at the end of the list)
mcl_credits.people = {
	{"Creator of MineClone", 0x0A9400, {
		"davedevils",
	}},
	{"Creator of MineClone2", 0xFBF837, {
		"Wuzzy",
	}},
	{"Maintainers", 0xFF51D5, {
		"Fleckenstein",
		"kay27",
		"oilboi",
	}},
	{"Developers", 0xF84355, {
		"bzoss",
		"AFCMS",
		"epCode",
		"ryvnf",
		"iliekprogrammar",
		"MysticTempest",
		"Rootyjr",
		"Nicu",
		"aligator",
	}},
	{"Contributors", 0x52FF00, {
		"Code-Sploit",
		"Laurent Rocher",
		"HimbeerserverDE",
		"TechDudie",
		"Alexander Minges",
		"ArTee3",
		"ZeDique la Ruleta",
		"pitchum",
		"wuniversales",
		"Bu-Gee",
		"David McMackins II",
		"Nicholas Niro",
		"Wouters Dorian",
		"Blue Blancmange",
		"Jared Moody",
		"Li0n",
		"Midgard",
		"NO11",
		"Saku Laesvuori",
		"Yukitty",
		"ZedekThePD",
		"aldum",
		"dBeans",
		"nickolas360",
		"yutyo",
		"ztianyang",
	}},
	{"MineClone5", 0xA60014, {
		"kay27",
		"Debiankaios",
		"epCode",
		"NO11",
		"j45",
	}},
	{"3D Models", 0x0019FF, {
		"22i",
		"tobyplowy",
		"epCode",
	}},
	{"Textures", 0xFF9705, {
		"XSSheep",
		"Wuzzy",
		"kingoscargames",
		"leorockway",
		"xMrVizzy",
		"yutyo"
	}},
	{"Translations", 0x00FF60, {
		"Wuzzy",
		"Rocher Laurent",
		"wuniversales",
		"kay27",
		"pitchum",
	}},
}

local function add_hud_element(def, huds, y)
	def.alignment = {x = 0, y = 0}
	def.position = {x = 0.5, y = 0}
	def.offset = {x = 0, y = y}
	def.z_index = 1001
	local id = huds.player:hud_add(def)
	table.insert(huds.ids, id)
	huds.moving[id] = y
	return id
end

function mcl_credits.show(player)
	local name = player:get_player_name()
	if mcl_credits.players[name] then
		return
	end
	local huds = {
		new = true,		-- workaround for MT < 5.5 (sending hud_add and hud_remove in the same tick)
		player = player,
		moving = {},
		ids = {
			player:hud_add({
				hud_elem_type = "image",
				text = "menu_bg.png",
				position = {x = 0, y = 0},
				alignment = {x = 1, y = 1},
				scale = {x = -100, y = -100},
				z_index = 1000,
			}),
			player:hud_add({
				hud_elem_type = "text",
				text = "Sneak to skip",
				position = {x = 1, y = 1},
				alignment = {x = -1, y = -1},
				offset = {x = -5, y = -5},
				z_index = 1001,
				number = 0xFFFFFF,
			})
		},
	}
	add_hud_element({
		hud_elem_type = "image",
		text = "mineclone2_logo.png",
		scale = {x = 1, y = 1},
	}, huds, 300, 0)
	add_hud_element({
		hud_elem_type = "text",
		text = mcl_credits.description,
		number = 0x757575,
		scale = {x = 5, y = 5},
	}, huds, 350, 0)
	local y = 450
	for _, group in ipairs(mcl_credits.people) do
		add_hud_element({
			hud_elem_type = "text",
			text = group[1],
			number = group[2],
			scale = {x = 3, y = 3},
		}, huds, y, 0)
		y = y + 25
		for _, name in ipairs(group[3]) do
			y = y + 25
			add_hud_element({
				hud_elem_type = "text",
				text = name,
				number = 0xFFFFFF,
				scale = {x = 1, y = 1},
			}, huds, y, 0)
		end
		y = y + 200
	end
	huds.icon = add_hud_element({
		hud_elem_type = "image",
		text = "mineclone2_icon.png",
		scale = {x = 1, y = 1},
	}, huds, y)
	mcl_credits.players[name] = huds
end

function mcl_credits.hide(player)
	local name = player:get_player_name()
	local huds = mcl_credits.players[name]
	if huds then
		for _, id in pairs(huds.ids) do
			player:hud_remove(id)
		end
	end
	mcl_credits.players[name] = nil
end

minetest.register_on_leaveplayer(function(player)
	mcl_credits.players[player:get_player_name()] = nil
end)

minetest.register_globalstep(function(dtime)
	for _, huds in pairs(mcl_credits.players) do
		local player = huds.player
		if not huds.new and player:get_player_control().sneak then
			mcl_credits.hide(player)
		else
			local moving = {}
			local any
			for id, y in pairs(huds.moving) do
				y = y - 1
				if y > -100 then
					if id == huds.icon then
						y = math.max(400, y)
					else
						any = true
					end
					player:hud_change(id, "offset", {x = 0, y = y})
					moving[id] = y
				end
			end
			if not any then
				mcl_credits.hide(player)
			end
			huds.moving = moving
		end
		huds.new = false
	end
end)
