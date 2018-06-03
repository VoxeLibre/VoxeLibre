--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

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
		random = "mobs_mc_villager_noise",
		death = "mobs_mc_villager_death",
		damage = "mobs_mc_villager_damage",
		distance = 16,
	},
	animation = {
		stand_speed = 25,
		stand_start = 40,
		stand_end = 59,
		walk_speed = 25,
		walk_start = 0,
		walk_end = 40,
		run_speed = 25,
		run_start = 0,
		run_end = 40,
		die_speed = 15,
		die_start = 210,
		die_end = 220,
		die_loop = false,
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
					if listname == "input" or listname == "output" then
						return stack:get_count()
					else
						return 0
					end
				end,
				allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
					if from_list == "wanted" or from_list == "offered" or to_list == "wanted" or to_list == "offered" then
						return 0
					elseif from_list == "output" and inv:get_stack(to_list, to_index):is_empty() then
						return count
					elseif from_list == "input" then
						return count
					else
						return 0
					end
				end,
				allow_put = function(inv, listname, index, stack, player)
					if listname == "input" then
						return stack:get_count()
					else
						return 0
					end
				end,
				on_put = function(inv, listname, index, stack, player)
					if inv:contains_item("input", inv:get_stack("wanted", 1)) then
						inv:set_stack("output", 1, inv:get_stack("offered", 1))
						minetest.sound_play("mobs_mc_villager_accept", {to_player = player:get_player_name()})
					else
						inv:set_stack("output", 1, ItemStack(""))
						minetest.sound_play("mobs_mc_villager_deny", {to_player = player:get_player_name()})
					end
				end,
				on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
					if inv:contains_item("input", inv:get_stack("wanted", 1)) then
						inv:set_stack("output", 1, inv:get_stack("offered", 1))
						minetest.sound_play("mobs_mc_villager_accept", {to_player = player:get_player_name()})
					else
						inv:set_stack("output", 1, ItemStack(""))
						minetest.sound_play("mobs_mc_villager_deny", {to_player = player:get_player_name()})
					end
				end,
				on_take = function(inv, listname, index, stack, player)
					local accept
					if listname == "output" then
						inv:remove_item("input", inv:get_stack("wanted", 1))
						accept = true
					end
					if inv:contains_item("input", inv:get_stack("wanted", 1)) then
						inv:set_stack("output", 1, inv:get_stack("offered", 1))
						accept = true
					else
						inv:set_stack("output", 1, ItemStack(""))
						accept = false
					end
					if accept then
						minetest.sound_play("mobs_mc_villager_accept", {to_player = player:get_player_name()})
					else
						minetest.sound_play("mobs_mc_villager_deny", {to_player = player:get_player_name()})
					end
				end,
			})
			end
			inv:set_size("input", 2)
			inv:set_size("output", 1)
			inv:set_size("wanted", 2)
			inv:set_size("offered", 1)

		local trades = {
			{"mcl_core:apple 12",		"mcl_core:emerald 1"},
			{"mcl_core:coal_lump 20",	"mcl_core:emerald 1"},
			{"mcl_core:paper 30",		"mcl_core:emerald 1"},
			{"mcl_mobitems:leather 10",	"mcl_core:emerald 1"},
			{"mcl_books:book 2",		"mcl_core:emerald 1"},
			{"mcl_core:emerald 3",		"mcl_core:emerald 1"},
			{"mcl_farming:potato_item 15",	"mcl_core:emerald 1"},
			{"mcl_farming:wheat_item 20",	"mcl_core:emerald 1"},
			{"mcl_farming:carrot_item 15",	"mcl_core:emerald 1"},
			{"mcl_farming:melon_item 8",	"mcl_core:emerald 1"},
			{"mcl_mobitems:rotten_flesh 40","mcl_core:emerald 1"},
			{"mcl_core:gold_ingot 10",	"mcl_core:emerald 1"},
			{"mcl_wool:white 15",		"mcl_core:emerald 1"},
			{"mcl_farming:pumpkin_face 8",	"mcl_core:emerald 1"},

			{"mcl_core:emerald 1",		"mcl_mobitems:cooked_beef 5"},
			{"mcl_core:emerald 1",		"mcl_mobitems:cooked_chicken 7"},
			{"mcl_core:emerald 1",		"mcl_farming:cookie 6"},
			{"mcl_core:emerald 1",		"mcl_bows:arrow 10"},
			{"mcl_core:emerald 3",		"mcl_bows:bow 1"},
			{"mcl_core:emerald 1",		"mcl_cake:cake 1"},
			{"mcl_core:emerald 10",		"mcl_mobitems:saddle 1"},
			{"mcl_core:emerald 10",		"mcl_clock:clock 1"},
			{"mcl_core:emerald 10",		"mcl_compass:compass 1"},
			{"mcl_core:emerald 1",		"mcl_core:glass 5"},
			{"mcl_core:emerald 1",		"mcl_nether:glowstone 3"},
			{"mcl_core:emerald 3",		"mcl_tools:shears 1"},
			{"mcl_core:emerald 10",		"mcl_tools:sword_diamond 1"},
			{"mcl_core:emerald 20",		"3d_armor:chestplate_diamond 1"},
		}
		local tradenum = math.random(#trades)
		inv:set_stack("wanted", 1, ItemStack(trades[tradenum][1]))
		inv:set_stack("offered", 1, ItemStack(trades[tradenum][2]))
		
		local formspec = 
		"size[9,8.75]"..
		"background[-0.19,-0.25;9.41,9.49;mobs_mc_trading_formspec_bg.png]"..
		mcl_vars.inventory_header..
		"list[current_player;main;0,4.5;9,3;9]"..
		"list[current_player;main;0,7.74;9,1;]"
		.."list[detached:trading_inv;wanted;2,1;2,1;]"
		.."list[detached:trading_inv;offered;5.76,1;1,1;]"
		.."list[detached:trading_inv;input;2,2.5;2,1;]"
		.."list[detached:trading_inv;output;5.76,2.55;1,1;]"
		.."listring[detached:trading_inv;output]"
		.."listring[current_player;main]"
		.."listring[detached:trading_inv;input]"
		.."listring[current_player;main]"
		minetest.sound_play("mobs_mc_villager_trade", {to_player = clicker:get_player_name()})
		minetest.show_formspec(clicker:get_player_name(), "mobs_mc:trade", formspec)
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
