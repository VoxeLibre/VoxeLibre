--MCmobs v0.2
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes


--dofile(minetest.get_modpath("mobs").."/api.lua")


mobs:register_mob("mobs_mc:villager", {
	type = "npc",
	hp_min = 20,
	hp_max = 20,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1.95, 0.4},
	textures = {
	{"mobs_farmer.png"}
	},
	visual = "mesh",
	mesh = "mobs_villager.x",
	makes_footstep_sound = true,
	damage = 0,
	walk_velocity = 1.2,
	run_velocity = 2.4,
	group_attack = true,
	attack_type = "dogfight",
	drops = {},
	armor = 100,
	sounds = {
		random = "Villager1",
		death = "Villagerdead",
		damage = "Villagerhurt1",
	},
	animation = {
		speed_normal = 30,
		speed_run = 60,
		stand_start = 0,
		stand_end = 23,
		walk_start = 24,
		walk_end = 49,
		run_start = 24,
		run_end = 49,
		hurt_start = 85,
		hurt_end = 115,
		death_start = 117,
		death_end = 145,
		shoot_start = 50,
		shoot_end = 82,
	},
	drawtype = "front",
	water_damage = 1,
	lava_damage = 5,
	light_damage = 0,
	view_range = 16,
	fear_height = 5,
	--[[
	on_rightclick = function(self, clicker)
		local inv
		inv = minetest.get_inventory({type="detached", name="trading_inv"})
		if not inv then
			inv = minetest.create_detached_inventory("trading_inv", {
				allow_take = function(inv, listname, index, stack, player)
					if listname == "output" then
						inv:remove_item("input", inv:get_stack("wanted", 1))
						minetest.sound_play("Villageraccept", {to_player = player:get_player_name()})
					end
					if listname == "input" or listname == "output" then
						--return 1000
						return 0
					else
						return 0
					end
				end,
				allow_put = function(inv, listname, index, stack, player)
					if listname == "input" then
						return 1000
					else
						return 0
					end
				end,
				on_put = function(inv, listname, index, stack, player)
					if inv:contains_item("input", inv:get_stack("wanted", 1)) then
						inv:set_stack("output", 1, inv:get_stack("offered", 1))
						minetest.sound_play("Villageraccept", {to_player = player:get_player_name()})
					else
						inv:set_stack("output", 1, ItemStack(""))
						minetest.sound_play("Villagerdeny", {to_player = player:get_player_name()})
					end
				end,
				on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
					if inv:contains_item("input", inv:get_stack("wanted", 1)) then
						inv:set_stack("output", 1, inv:get_stack("offered", 1))
						minetest.sound_play("Villageraccept", {to_player = player:get_player_name()})
					else
						inv:set_stack("output", 1, ItemStack(""))
						minetest.sound_play("Villagerdeny", {to_player = player:get_player_name()})
					end
				end,
				on_take = function(inv, listname, index, stack, player)
					if inv:contains_item("input", inv:get_stack("wanted", 1)) then
						inv:set_stack("output", 1, inv:get_stack("offered", 1))
						minetest.sound_play("Villageraccept", {to_player = player:get_player_name()})
					else
						inv:set_stack("output", 1, ItemStack(""))
						minetest.sound_play("Villagerdeny", {to_player = player:get_player_name()})
						
					end
				end,
			})
			end
		inv:set_size("input", 1)
		inv:set_size("output", 1)
		inv:set_size("wanted", 1)
		inv:set_size("offered", 1)

		local trades = {
			{"mcl_core:apple 12",			"mcl_core:clay_lump 1"},
			{"mcl_core:coal_lump 20",		"mcl_core:clay_lump 1"},
			{"mcl_core:paper 30",			"mcl_core:clay_lump 1"},
			{"mobs:leather 10",			"mcl_core:clay_lump 1"},
			{"mcl_core:book 2",			"mcl_core:clay_lump 1"},
			{"mcl_core:clay_lump 3",		"mcl_core:clay_lump 1"},
			{"farming:potato 15",		"mcl_core:clay_lump 1"},
			{"farming:wheat 20",			"mcl_core:clay_lump 1"},
			{"farming:carrot 15",			"mcl_core:clay_lump 1"},
			{"farming:melon_8 8",		"mcl_core:clay_lump 1"},
			{"mobs:rotten_flesh 40",		"mcl_core:clay_lump 1"},
			{"mcl_core:gold_ingot 10",		"mcl_core:clay_lump 1"},
			{"farming:cotton 10",			"mcl_core:clay_lump 1"},
			{"mcl_wool:white 15",			"mcl_core:clay_lump 1"},
			{"farming:pumpkin 8",		"mcl_core:clay_lump 1"},

			{"mcl_core:clay_lump 1",		"mobs:beef_cooked 5"},
			{"mcl_core:clay_lump 1",		"mobs:chicken_cooked 7"},
			{"mcl_core:clay_lump 1",		"farming:cookie 6"},
			{"mcl_core:clay_lump 1",		"farming:pumpkin_bread 3"},
			{"mcl_core:clay_lump 1",		"mobs:arrow 10"},
			{"mcl_core:clay_lump 3",		"mobs:bow_wood 1"},
			{"mcl_core:clay_lump 8",		"fishing:pole_wood 1"},
			--{"mcl_core:clay_lump 4",		"potionspack:healthii 1"},
			{"mcl_core:clay_lump 1",		"cake:cake 1"},
			{"mcl_core:clay_lump 10",		"mobs:saddle 1"},
			{"mcl_core:clay_lump 10",		"clock:1 1"},
			{"mcl_core:clay_lumpd 10",		"compass:0 1"},
			{"mcl_core:clay_lump 1",		"mcl_core:glass 5"},
			{"mcl_core:clay_lump 1",		"nether:glowstone 3"},
			{"mcl_core:clay_lump 3",		"mobs:shears 1"},
			{"mcl_core:clay_lump 10",		"mcl_core:sword_diamond 1"},
			{"mcl_core:clay_lump 20",		"3d_armor:chestplate_diamond 1"},
		}
		local tradenum = math.random(#trades)
		inv:set_stack("wanted", 1, ItemStack(trades[tradenum][1]))
		inv:set_stack("offered", 1, ItemStack(trades[tradenum][2]))
		
		local formspec = 
		"size[9,8.75]"..
		"background[-0.19,-0.25;9.41,9.49;trading_formspec_bg.png]"..
		"bgcolor[#080808BB;true]"..
		"listcolors[#9990;#FFF7;#FFF0;#160816;#D4D2FF]"..
		"list[current_player;main;0,4.5;9,3;9]"..
		"list[current_player;main;0,7.74;9,1;]"
		.."list[detached:trading_inv;wanted;2,1;1,1;]"
		.."list[detached:trading_inv;offered;5.75,1;1,1;]"
		.."list[detached:trading_inv;input;2,2.5;1,1;]"
		.."list[detached:trading_inv;output;5.75,2.5;1,1;]"
		minetest.sound_play("Villagertrade", {to_player = clicker:get_player_name()})
		minetest.show_formspec(clicker:get_player_name(), "tradespec", formspec)
	end,
	
	]]
})
--mobs:register_spawn("mobs_mc:villager", {"mcl_core:gravel"}, 20, 8, 50, 8, 31000)
mobs:register_spawn("mobs_mc:villager", {"mcl_core:gravel"}, 20, 8, 500, 2, 31000)


-- compatibility
mobs:alias_mob("mobs:villager", "mobs_mc:villager")

-- spawn eggs
mobs:register_egg("mobs_mc:villager", "Spawn Villager", "spawn_egg_villager.png")


if minetest.setting_get("log_mods") then
	minetest.log("action", "MC mobs loaded")
end
