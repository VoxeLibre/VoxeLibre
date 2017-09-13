--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

--dofile(minetest.get_modpath("mobs").."/api.lua")
--###################
--################### VILLAGER
--###################



mobs:register_mob("mobs_mc:villager", {
	type = "npc",
	hp_min = 20,
	hp_max = 20,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_villager.b3d",
	textures = {
	{
		"mobs_mc_villager.png",
		"mobs_mc_villager.png", --hat
	},
	{
		"mobs_mc_villager_farmer.png",
		"mobs_mc_villager_farmer.png", --hat
	},
	{
		"mobs_mc_villager_priest.png",
		"mobs_mc_villager_priest.png", --hat
	},
	{
		"mobs_mc_villager_librarian.png",
		"mobs_mc_villager_librarian.png", --hat
	},
	{
		"mobs_mc_villager_butcher.png",
		"mobs_mc_villager_butcher.png", --hat
	},
	{
		"mobs_mc_villager_smith.png",
		"mobs_mc_villager_smith.png", --hat
	},
	},
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
	walk_velocity = 1.2,
	run_velocity = 2.4,
	drops = {},
	sounds = {
		random = "Villager1",
		death = "Villagerdead",
		damage = "Villagerhurt1",
		distance = 16,
	},
	animation = {
		stand_speed = 25, walk_speed = 25, run_speed = 50,
		stand_start = 40,		stand_end = 59,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},
	water_damage = 0,
	lava_damage = 4,
	light_damage = 0,
	view_range = 16,
	fear_height = 4,
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
			{"default:apple 12",			"default:clay_lump 1"},
			{"default:coal_lump 20",		"default:clay_lump 1"},
			{"default:paper 30",			"default:clay_lump 1"},
			{"mobs:leather 10",			"default:clay_lump 1"},
			{"default:book 2",			"default:clay_lump 1"},
			{"default:clay_lump 3",		"default:clay_lump 1"},
			{"farming:potato 15",		"default:clay_lump 1"},
			{"farming:wheat 20",			"default:clay_lump 1"},
			{"farming:carrot 15",			"default:clay_lump 1"},
			{"farming:melon_8 8",		"default:clay_lump 1"},
			{"mobs:rotten_flesh 40",		"default:clay_lump 1"},
			{"default:gold_ingot 10",		"default:clay_lump 1"},
			{"farming:cotton 10",			"default:clay_lump 1"},
			{"wool:white 15",			"default:clay_lump 1"},
			{"farming:pumpkin 8",		"default:clay_lump 1"},

			{"default:clay_lump 1",		"mobs:beef_cooked 5"},
			{"default:clay_lump 1",		"mobs:chicken_cooked 7"},
			{"default:clay_lump 1",		"farming:cookie 6"},
			{"default:clay_lump 1",		"farming:pumpkin_bread 3"},
			{"default:clay_lump 1",		"mobs:arrow 10"},
			{"default:clay_lump 3",		"mobs:bow_wood 1"},
			{"default:clay_lump 8",		"fishing:pole_wood 1"},
			--{"default:clay_lump 4",		"potionspack:healthii 1"},
			{"default:clay_lump 1",		"cake:cake 1"},
			{"default:clay_lump 10",		"mobs:saddle 1"},
			{"default:clay_lump 10",		"clock:1 1"},
			{"default:clay_lumpd 10",		"compass:0 1"},
			{"default:clay_lump 1",		"default:glass 5"},
			{"default:clay_lump 1",		"nether:glowstone 3"},
			{"default:clay_lump 3",		"mobs:shears 1"},
			{"default:clay_lump 10",		"default:sword_diamond 1"},
			{"default:clay_lump 20",		"3d_armor:chestplate_diamond 1"},
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

mobs:spawn_specific("mobs_mc:villager", mobs_mc.spawn.village, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 8000, 4, mobs_mc.spawn_height.water+1, mobs_mc.spawn_height.overworld_max)

-- compatibility
mobs:alias_mob("mobs:villager", "mobs_mc:villager")

-- spawn eggs
mobs:register_egg("mobs_mc:villager", S("Villager"), "mobs_mc_spawn_icon_villager.png", 0)

if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC mobs loaded")
end
