--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

-- TODO: Per-player trading inventories
-- TODO: Trading tiers
-- TODO: Trade locking

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

-- playername-indexed table containing the previously used tradenum
local player_tradenum = {}
-- playername-indexed table containing the objectref of trader, if trading formspec is open
local player_trading_with = {}

--###################
--################### VILLAGER
--###################

-- LIST OF VILLAGER PROFESSIONS AND TRADES
local E1 = { "mcl_core:emerald", 1, 1 } -- one emerald
local professions = {
	farmer = {
		name = "Farmer",
		texture = "mobs_mc_villager_farmer.png",
		trades = {
			{
			{ { "mcl_farming:wheat_item", 18, 22, }, E1 },
			{ { "mcl_farming:potato_item", 15, 15, }, E1 },
			{ { "mcl_farming:carrot_item", 15, 19, }, E1 },
			{ E1, { "mcl_farming:bread", 2, 4 } },
			},

			{
			{ { "mcl_farming:pumpkin_face", 8, 13 }, E1 },
			{ E1, { "mcl_farming:pumpkin_pie", 2, 3} },
			},

			{
			{ { "mcl_farming:melon", 7, 12 }, E1 },
			{ E1, { "mcl_core:apple", 5, 7 }, },
			},

			{
			{ E1, { "mcl_farming:cookie", 6, 10 } },
			{ E1, { "mcl_cake:cake", 1, 1 } },
			},
		}
	},
	fisherman = {
		name = "Fisherman",
		texture = "mobs_mc_villager_farmer.png",
		trades = {
			{
			{ { "mcl_fishing:fish_raw", 6, 6, "mcl_core:emerald", 1, 1 }, { "mcl_fishing:fish_cooked", 6, 6 } },
			{ { "mcl_mobitems:string", 15, 20 }, E1 },
			{ { "mcl_core:coal_lump", 16, 24 }, E1 },
			},
			-- TODO: enchanted fishing rod
		},
	},
	fletcher = {
		name = "Fletcher",
		texture = "mobs_mc_villager_farmer.png",
		trades = {
			{
			{ { "mcl_mobitems:string", 15, 20 }, E1 },
			{ E1, { "mcl_bows:arrow", 8, 12 } },
			},

			{
			{ { "mcl_core:gravel", 10, 10, "mcl_core:emerald", 1, 1 }, { "mcl_core:flint", 6, 10 } },
			{ { "mcl_core:emerald", 2, 3 }, { "mcl_bows:bow", 1, 1 } },
			},
		}
	},
	shepherd ={
		name = "Shepherd",
		texture = "mobs_mc_villager_farmer.png",
		trades = {
			{
			{ { "mcl_wool:white", 16, 22 }, E1 },
			{ { "mcl_core:emerald", 3, 4 }, { "mcl_tools:shears", 1, 1 } },
			},

			{
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:white", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:grey", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:silver", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:yellow", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:red", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:purple", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:blue", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:light_blue", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:brown", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:lime", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:green", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:magenta", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:black", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:cyan", 1, 1 } },
			{ { "mcl_core:emerald", 1, 2 }, { "mcl_wool:pink", 1, 1 } },
			},
		},
	},
	librarian = {
		name = "Librarian",
		texture = "mobs_mc_villager_librarian.png",
		trades = {
			{
			{ { "mcl_core:paper", 24, 36 }, E1 },
			-- TODO: enchanted book
			{ { "mcl_books:book", 8, 10 }, E1 },
			{ { "mcl_core:emerald", 10, 12 }, { "mcl_compass:compass", 1 ,1 }},
			{ { "mcl_core:emerald", 3, 4 }, { "mcl_books:bookshelf", 1 ,1 }},
			},

			{
			{ { "mcl_books:written_book", 2, 2 }, E1 },
			{ { "mcl_core:emerald", 10, 12 }, { "mcl_clock:clock", 1, 1 } },
			{ E1, { "mcl_core:glass", 3, 5 } },
			},

			{
			{ E1, { "mcl_core:glass", 3, 5 } },
			},

			-- TODO: 2 enchanted book tiers

			{
			{ { "mcl_core:emerald", 20, 22 }, { "mcl_mobs:nametag", 1, 1 } },
			}
		},
	},
	cartographer = {
		name = "Cartographer",
		texture = "mobs_mc_villager_librarian.png",
		trades = {
			{
			{ { "mcl_core:paper", 24, 36 }, E1 },
			},

--			{
			-- TODO: compass
			-- the difficulty lies in supporting the compass group, not the concrete item
--			{ { "mcl_compass:compass", 1, 1 }, E1 },
--			},

			{
			-- TODO: replace with empty map
			{ { "mcl_core:emerald", 7, 11}, { "mcl_maps:filled_map", 1, 1 } },
			},

			-- TODO: special maps
		},
	},
	armorer = {
		name = "Armorer",
		texture = "mobs_mc_villager_smith.png",
		trades = {
			{
			{ { "mcl_core:coal_lump", 16, 24 }, E1 },
			{ { "mcl_core:emerald", 6, 8 }, { "3d_armor:helmet_iron", 1, 1 } },
			},

			{
			{ { "mcl_core:iron_ingot", 7, 9 }, E1 },
			{ { "mcl_core:emerald", 10, 14 }, { "3d_armor:chestplate_iron", 1, 1 } },
			},

			{
			{ { "mcl_core:diamond", 3, 4 }, E1 },
			-- TODO: enchant
			{ { "mcl_core:emerald", 16, 19 }, { "3d_armor:chestplate_diamond", 1, 1 } },
			},

			{
			{ { "mcl_core:emerald", 5, 7 }, { "3d_armor:boots_chain", 1, 1 } },
			{ { "mcl_core:emerald", 9, 11 }, { "3d_armor:leggings_chain", 1, 1 } },
			{ { "mcl_core:emerald", 5, 7 }, { "3d_armor:helmet_chain", 1, 1 } },
			{ { "mcl_core:emerald", 11, 15 }, { "3d_armor:chestplate_chain", 1, 1 } },
			},
		},
	},
	leatherworker = {
		name = "Leatherworker",
		texture = "mobs_mc_villager_butcher.png",
		trades = {
			{
			{ { "mcl_mobitems:leather", 9, 12 }, E1 },
			{ { "mcl_core:emerald", 2, 4 }, { "3d_armor:leggings_leather", 2, 4 } },
			},

			{
			-- TODO: enchant
			{ { "mcl_core:emerald", 7, 12 }, { "3d_armor:chestplate_leather", 1, 1 } },
			},

			{
			{ { "mcl_core:emerald", 8, 10 }, { "mcl_mobitems:saddle", 1, 1 } },
			},
		},
	},
	butcher = {
		name = "Butcher",
		texture = "mobs_mc_villager_butcher.png",
		trades = {
			{
			{ { "mcl_mobitems:beef", 14, 18 }, E1 },
			{ { "mcl_mobitems:chicken", 14, 18 }, E1 },
			},

			{
			{ { "mcl_core:coal_lump", 16, 24 }, E1 },
			{ E1, { "mcl_mobitems:cooked_beef", 5, 7 } },
			{ E1, { "mcl_mobitems:cooked_chicken", 6, 8 } },
			},
		},
	},
	weapon_smith = {
		name = "Weapon Smith",
		texture = "mobs_mc_villager_smith.png",
		trades = {
			{
			{ { "mcl_core:coal_lump", 16, 24 }, E1 },
			{ { "mcl_core:emerald", 6, 8 }, { "mcl_tools:axe_iron", 1, 1 } },
			},

			{
			{ { "mcl_core:iron_ingot", 7, 9 }, E1 },
			-- TODO: enchant
			{ { "mcl_core:emerald", 9, 10 }, { "mcl_tools:sword_iron", 1, 1 } },
			},

			{
			{ { "mcl_core:diamond", 3, 4 }, E1 },
			-- TODO: enchant
			{ { "mcl_core:emerald", 12, 15 }, { "mcl_tools:sword_diamond", 1, 1 } },
			-- TODO: enchant
			{ { "mcl_core:emerald", 9, 12 }, { "mcl_tools:axe_diamond", 1, 1 } },
			},
		},
	},
	tool_smith = {
		name = "Tool Smith",
		texture = "mobs_mc_villager_smith.png",
		trades = {
			{
			{ { "mcl_core:coal_lump", 16, 24 }, E1 },
			-- TODO: enchant
			{ { "mcl_core:emerald", 5, 7 }, { "mcl_tools:shovel_iron", 1, 1 } },
			},

			{
			{ { "mcl_core:iron_ingot", 7, 9 }, E1 },
			-- TODO: enchant
			{ { "mcl_core:emerald", 9, 11 }, { "mcl_tools:pick_iron", 1, 1 } },
			},

			{
			{ { "mcl_core:diamond", 3, 4 }, E1 },
			-- TODO: enchant
			{ { "mcl_core:emerald", 12, 15 }, { "mcl_tools:pick_diamond", 1, 1 } },
			},
		},
	},
	cleric = {
		name = "Cleric",
		texture = "mobs_mc_villager_priest.png",
		trades = {
			{
			{ { "mcl_mobitems:rotten_flesh", 36, 40 }, E1 },
			{ { "mcl_core:gold_ingot", 8, 10 }, E1 },
			},

			{
			{ E1, { "mesecons:redstone", 1, 4  } },
			{ E1, { "mcl_dye:blue", 1, 2 } },
			},

			{
			{ E1, { "mcl_nether:glowstone", 1, 3 } },
			{ { "mcl_core:emerald", 4, 7 }, { "mcl_throwing:ender_pearl", 1, 1 } },
			},

			-- TODO: Bottle 'o enchanting
		},
	},
	nitwit = {
		name = "Nitwit",
		texture = "mobs_mc_villager.png",
		-- No trades for nitwit
		trades = nil,
	}
}

local profession_names = {}
for id, _ in pairs(professions) do
	table.insert(profession_names, id)
end

local init_profession = function(self)
	if not self._profession then
		-- Select random profession from all professions with matching clothing
		local texture = self.base_texture[1]
		local matches = {}
		for prof_id, prof in pairs(professions) do
			if texture == prof.texture then
				table.insert(matches, prof_id)
			end
		end
		local p = math.random(1, #matches)
		self._profession = matches[p]
	end
	if not self._max_trade_tier then
		-- TODO: Start with tier 1
		self._max_trade_tier = 10
	end
end

local update_trades = function(self, inv)
	local profession = professions[self._profession]
	local trade_tiers = profession.trades
	if trade_tiers == nil then
		-- Empty trades
		self._trades = false
		return
	end

	local max_tier = math.min(#trade_tiers, self._max_trade_tier)
	local trades = {}
	for tiernum=1, max_tier do
		local tier = trade_tiers[tiernum]
		for tradenum=1, #tier do
			local trade = tier[tradenum]
			local wanted1_item = trade[1][1]
			local wanted1_count = math.random(trade[1][2], trade[1][3])
			local offered_item = trade[2][1]
			local offered_count = math.random(trade[2][2], trade[2][3])

			local wanted = { wanted1_item .. " " ..wanted1_count }
			if trade[1][4] then
				local wanted2_item = trade[1][4]
				local wanted2_count = math.random(trade[1][5], trade[1][6])
				table.insert(wanted, wanted2_item .. " " ..wanted2_count)
			end

			table.insert(trades, {
				wanted = wanted,
				offered = offered_item .. " " .. offered_count,
				tier = tiernum,
			})
		end
	end
	self._trades = minetest.serialize(trades)
end

local set_trade = function(self, player, inv, concrete_tradenum)
	local trades = minetest.deserialize(self._trades)
	if not trades then
		update_trades(self)
		trades = minetest.deserialize(self._trades)
		if not trades then
			minetest.log("error", "[mobs_mc] Failed to select villager trade!")
			return
		end
	end

	if concrete_tradenum > #trades then
		concrete_tradenum = 1
		player_tradenum[player:get_player_name()] = concrete_tradenum
	elseif concrete_tradenum < 1 then
		concrete_tradenum = #trades
		player_tradenum[player:get_player_name()] = concrete_tradenum
	end
	local trade = trades[concrete_tradenum]
	inv:set_stack("wanted", 1, ItemStack(trade.wanted[1]))
	inv:set_stack("offered", 1, ItemStack(trade.offered))
	if trade.wanted[2] then
		local wanted2 = ItemStack(trade.wanted[2])
		inv:set_stack("wanted", 2, wanted2)
	else
		inv:set_stack("wanted", 2, "")
	end

end

local function show_trade_formspec(playername, trader, is_disabled)
	local profession = professions[trader._profession].name
	local disabled = ""
	if is_disabled then
		disabled = "image[4.3,2.52;1,1;mobs_mc_trading_formspec_disabled.png]"
	end
	local formspec =
	"size[9,8.75]"..
	"background[-0.19,-0.25;9.41,9.49;mobs_mc_trading_formspec_bg.png]"..
	disabled..
	mcl_vars.inventory_header..
	"label[4,0;"..minetest.formspec_escape(profession).."]"
	.."list[current_player;main;0,4.5;9,3;9]"
	.."list[current_player;main;0,7.74;9,1;]"
	.."button[1,1;0.5,1;prev_trade;<]"
	.."button[7.26,1;0.5,1;next_trade;>]"
	.."list[detached:mobs_mc:trade;wanted;2,1;2,1;]"
	.."list[detached:mobs_mc:trade;offered;5.76,1;1,1;]"
	.."list[detached:mobs_mc:trade;input;2,2.5;2,1;]"
	.."list[detached:mobs_mc:trade;output;5.76,2.55;1,1;]"
	.."listring[detached:mobs_mc:trade;output]"
	.."listring[current_player;main]"
	.."listring[detached:mobs_mc:trade;input]"
	.."listring[current_player;main]"
	minetest.sound_play("mobs_mc_villager_trade", {to_player = playername})
	minetest.show_formspec(playername, "mobs_mc:trade", formspec)
end

local update_offer = function(inv, player, sound)
	if inv:contains_item("input", inv:get_stack("wanted", 1)) and
			(inv:get_stack("wanted", 2):is_empty() or inv:contains_item("input", inv:get_stack("wanted", 2))) then
		inv:set_stack("output", 1, inv:get_stack("offered", 1))
		if sound then
			minetest.sound_play("mobs_mc_villager_accept", {to_player = player:get_player_name()})
		end
		return true
	else
		inv:set_stack("output", 1, ItemStack(""))
		if sound then
			minetest.sound_play("mobs_mc_villager_deny", {to_player = player:get_player_name()})
		end
		return false
	end
end

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
	on_rightclick = function(self, clicker)
		local name = clicker:get_player_name()

		init_profession(self)
		if self._trades == nil then
			update_trades(self)
		end
		if self._trades == false then
			-- Villager has no trades, rightclick is a no-op
			return
		end

		player_trading_with[name] = self

		-- TODO: Create per-player trading inventories
		local inv = minetest.get_inventory({type="detached", name="mobs_mc:trade"})
		if not inv then
			inv = minetest.create_detached_inventory("mobs_mc:trade", {
				allow_take = function(inv, listname, index, stack, player)
					if listname == "input" then
						return stack:get_count()
					elseif listname == "output" then
						-- Only allow taking full stack
						local count = stack:get_count()
						if count == inv:get_stack(listname, index):get_count() then
							-- Also update output stack again.
							-- If input has double the wanted items, the
							-- output will stay because there will be still
							-- enough items in input after the trade
							local wanted1 = inv:get_stack("wanted", 1)
							local wanted2 = inv:get_stack("wanted", 2)
							wanted1:set_count(wanted1:get_count()*2)
							wanted2:set_count(wanted2:get_count()*2)
							if inv:contains_item("input", wanted1) and
								(wanted2:is_empty() or inv:contains_item("input", wanted2)) then
								return -1
							else
								-- If less than double the wanted items,
								-- remove items from output (final trade,
								-- input runs empty)
								return count
							end
						else
							return 0
						end
					else
						return 0
					end
				end,
				allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
					if from_list == "input" and to_list == "input" then
						return count
					elseif from_list == "output" and to_list == "input" then
						local move_stack = inv:get_stack(from_list, from_index)
						if inv:get_stack(to_list, to_index):item_fits(move_stack) then
							return count
						end
					end
					return 0
				end,
				allow_put = function(inv, listname, index, stack, player)
					if listname == "input" then
						return stack:get_count()
					else
						return 0
					end
				end,
				on_put = function(inv, listname, index, stack, player)
					update_offer(inv, player, true)
				end,
				on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
					if from_list == "output" and to_list == "input" then
						inv:remove_item("input", inv:get_stack("wanted", 1))
						local wanted2 = inv:get_stack("wanted", 2)
						if not wanted2:is_empty() then
							inv:remove_item("input", inv:get_stack("wanted", 2))
						end
						minetest.sound_play("mobs_mc_villager_accept", {to_player = player:get_player_name()})
					end
					update_offer(inv, player, true)
				end,
				on_take = function(inv, listname, index, stack, player)
					local accept
					if listname == "output" then
						inv:remove_item("input", inv:get_stack("wanted", 1))
						local wanted2 = inv:get_stack("wanted", 2)
						if not wanted2:is_empty() then
							inv:remove_item("input", inv:get_stack("wanted", 2))
						end
						accept = true
					elseif listname == "input" then
						update_offer(inv, player, false)
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

		player_tradenum[name] = 1
		set_trade(self, player, inv, player_tradenum[name])

		show_trade_formspec(name, self)
	end,

	on_spawn = function(self)
		init_profession(self)
	end,
})

-- Returns a single itemstack in the given inventory to the player's main inventory, or drop it when there's no space left
local function return_item(itemstack, dropper, pos, inv_p)
	if dropper:is_player() then
		-- Return to main inventory
		if inv_p:room_for_item("main", itemstack) then
			inv_p:add_item("main", itemstack)
		else
			-- Drop item on the ground
			local v = dropper:get_look_dir()
			local p = {x=pos.x, y=pos.y+1.2, z=pos.z}
			p.x = p.x+(math.random(1,3)*0.2)
			p.z = p.z+(math.random(1,3)*0.2)
			local obj = minetest.add_item(p, itemstack)
			if obj then
				v.x = v.x*4
				v.y = v.y*4 + 2
				v.z = v.z*4
				obj:setvelocity(v)
				obj:get_luaentity()._insta_collect = false
			end
		end
	else
		-- Fallback for unexpected cases
		minetest.add_item(pos, itemstack)
	end
	return itemstack
end

local return_fields = function(player)
	local inv_t = minetest.get_inventory({type="detached", name = "mobs_mc:trade"})
	local inv_p = player:get_inventory()
	for i=1, inv_t:get_size("input") do
		local stack = inv_t:get_stack("input", i)
		return_item(stack, player, player:get_pos(), inv_p)
		stack:clear()
		inv_t:set_stack("input", i, stack)
	end
	inv_t:set_stack("output", 1, "")
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mobs_mc:trade" then
		local name = player:get_player_name()
		if fields.quit then
			return_fields(player)
			player_trading_with[name] = nil
		elseif fields.next_trade then
			local trader = player_trading_with[name]
			if not trader or not trader.object:get_luaentity() then
				return
			end
			player_tradenum[name] = player_tradenum[name] + 1
			local inv = minetest.get_inventory({type="detached", name="mobs_mc:trade"})
			set_trade(trader, player, inv, player_tradenum[name])
			update_offer(inv, player, false)
			show_trade_formspec(name, trader)
		elseif fields.prev_trade then
			local trader = player_trading_with[name]
			if not trader or not trader.object:get_luaentity() then
				return
			end
			player_tradenum[name] = player_tradenum[name] - 1
			local inv = minetest.get_inventory({type="detached", name="mobs_mc:trade"})
			set_trade(trader, player, inv, player_tradenum[name])
			update_offer(inv, player, false)
			show_trade_formspec(name, trader)
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	return_fields(player)
	player_tradenum[player:get_player_name()] = nil
	player_trading_with[player:get_player_name()] = nil
end)

minetest.register_on_joinplayer(function(player)
	player_tradenum[player:get_player_name()] = 1
	player_trading_with[player:get_player_name()] = nil
end)

mobs:spawn_specific("mobs_mc:villager", mobs_mc.spawn.village, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 8000, 4, mobs_mc.spawn_height.water+1, mobs_mc.spawn_height.overworld_max)

-- compatibility
mobs:alias_mob("mobs:villager", "mobs_mc:villager")

-- spawn eggs
mobs:register_egg("mobs_mc:villager", S("Villager"), "mobs_mc_spawn_icon_villager.png", 0)

if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC mobs loaded")
end
