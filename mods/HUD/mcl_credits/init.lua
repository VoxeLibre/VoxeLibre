mcl_credits = {
	players = {},
}

mcl_credits.description = "A faithful Open Source imitation of Minecraft"

-- Sub-lists are sorted by number of commits
mcl_credits.people = {
	{"Creator of MineClone", {
		"davedevils",
	}},
	{"Creator of MineClone2", {
		"Wuzzy",
	}},
	{"Maintainers", {
		"Fleckenstein",
		"kay27",
		"oilboi",
	}},
	{"Developers", {
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
	{"Contributors", {
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
	}},
	{"3D Models", {
		"22i",
		"tobyplowy",
	}},
	{"Textures", {
		"XSSheep",
		"kingoscargames",
		"leorockway",
		"xMrVizzy",
	}},
}

function mcl_credits.show(player)
	local name = player:get_player_name()
	if mcl_credits.players[name] then
		return
	end
	local hud_list = {
		player:hud_add({
			hud_elem_type = "image",
			text = "menu_bg.png",
			position = {x = 0, y = 0},
			alignment = {x = 1, y = 1},
			scale = {x = -100, y = -100},
			z_index = 1000,
		})
	}
	mcl_credits.players[name] = hud_list
end

function mcl_credits.hide(player)
	local name = player:get_player_name()
	local list = mcl_credits.players[name]
	if list then
		for _, id in pairs(list) do
			player:hud_remove(id)
		end
	end
	mcl_credits.players[name] = nil
end

controls.register_on_press(function(player, key)
	if key == "sneak" then
		mcl_credits.hide(player)
	elseif key == "aux1" then
		mcl_credits.show(player)
	end
end)
